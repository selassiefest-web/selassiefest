// Creates a Stripe Checkout Session for either a marketplace pre-order or a
// donation, and returns its hosted URL for the browser to redirect to. Card
// data never touches our server — Stripe's hosted page handles it entirely.
//
// Payment confirmation does NOT happen here. A Postgres trigger on
// stripe.payment_intents (populated by the existing Stripe Sync Engine
// webhook) fires once Stripe confirms the charge succeeded — see the
// (uncommitted, like notify-submission's trigger) handle_stripe_payment_succeeded
// function in the database. This function only ever creates a pending
// session; nothing is treated as a real order/donation until Stripe says so.

import Stripe from 'npm:stripe@17';
import { createClient } from 'npm:@supabase/supabase-js@2';

const stripe = new Stripe(Deno.env.get('STRIPE_SECRET_KEY')!, {
  apiVersion: '2024-06-20',
  httpClient: Stripe.createFetchHttpClient(),
});

const SITE_URL = 'https://selassiefest.com';

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { ...CORS_HEADERS, 'Content-Type': 'application/json' },
  });
}

// Server-side menu catalog — the only source of truth for marketplace
// prices. The client only sends an item `id` + `qty`; any client-submitted
// name/variant/price is ignored so a tampered request can never make Stripe
// charge less than the real menu price. Keep in sync with the
// data-id/data-name/data-variant/data-price attributes in
// marketplace/jamaican-kitchen.html.
const MENU_ITEMS: Record<string, { name: string; variant?: string; price: number }> = {
  'jerk-14': { name: 'Jerk Chicken', variant: '1/4 Chicken', price: 7.00 },
  'jerk-12': { name: 'Jerk Chicken', variant: '1/2 Chicken', price: 14.00 },
  'kabob-shrimp': { name: 'Kabobs', variant: 'Shrimp', price: 14.00 },
  'kabob-veg': { name: 'Kabobs', variant: 'Vegetable', price: 12.00 },
  'oxtails': { name: 'Oxtails', variant: 'Sample Size', price: 15.00 },
  'snapper': { name: 'Red Snapper', variant: 'Whole Fish', price: 25.00 },
  'wrap-veg': { name: 'Jerk Wrap', variant: 'Vegetable', price: 12.00 },
  'wrap-chicken': { name: 'Jerk Wrap', variant: 'Chicken', price: 12.00 },
  'wrap-shrimp': { name: 'Jerk Wrap', variant: 'Shrimp', price: 14.00 },
  'taco-veg': { name: 'Jerk Taco', variant: 'Vegetable', price: 4.50 },
  'taco-jerk': { name: 'Jerk Taco', variant: 'Jerk Chicken', price: 4.50 },
  'wings': { name: 'Jerk Wings', variant: '5 pcs', price: 12.00 },
  'festival': { name: 'Festival', variant: 'Sweet Fried Dumpling', price: 6.00 },
  'plantains': { name: 'Plantains', variant: 'Fried Sweet', price: 6.00 },
  'rice-jerk': { name: 'Jerk Fried Rice', variant: 'with Peas', price: 10.00 },
  'rice-veg': { name: 'Vegetable Fried Rice', variant: 'with Peas', price: 10.00 },
  'cabbage': { name: 'Cabbage', variant: 'Stewed', price: 6.00 },
  // Ital Kitchen menu (marketplace/ital-kitchen.html) — all meals $20.
  'ital-curry': { name: 'Curry Chunks', price: 20.00 },
  'ital-brownstew': { name: 'Brown Stew Chunks', price: 20.00 },
  'ital-veganfish': { name: 'Vegan Fish', price: 20.00 },
  'ital-riceandpeas': { name: 'Rice n Peas', price: 20.00 },
  'ital-veges': { name: 'Veges', price: 20.00 },
  'ital-coleslaw': { name: 'Cole Slaw', price: 20.00 },
  'ital-soupstew': { name: 'Soup Stew', price: 20.00 },
  'ital-italstew': { name: 'Ital Stew', price: 20.00 },
};

// Where to send the customer if they cancel out of Stripe Checkout —
// keyed by an explicit `source` the client sends, not a raw client URL, so
// this can never become an open redirect.
const CANCEL_PATHS: Record<string, string> = {
  marketplace: '/marketplace/jamaican-kitchen.html',
  'ital-marketplace': '/marketplace/ital-kitchen.html',
  'bowl-order': '/bowl-order-system.html',
};

// Yawd bowl-order-system.html pricing. Server-side only — the client never
// sends a price. Whether an order is "the Bem Bem Bowl" is derived from the
// build itself (protein + both finishing touches), not a client-asserted
// flag, so a tampered request can only ever get the price that build
// actually corresponds to.
const BOWL_PRICE = 12.50;
const BEM_BEM_PRICE = 15.00;

function isBemBemBuild(build: any[]): boolean {
  if (!Array.isArray(build)) return false;
  const protein = build.find((s) => s?.key === 'protein')?.value;
  const extras = build.find((s) => s?.key === 'extras')?.value || '';
  return (
    protein === 'Jerk Salmon + Shrimp' &&
    extras.includes('Toasted Coconut Flakes') &&
    extras.includes('Mango-Scotch Bonnet Drizzle')
  );
}

// Validates the shape of a bowl-order build (array of {key,label,value}
// steps as produced by bowl-order-system.html's buildSteps()) without
// trusting any of its content for pricing.
function resolveBowlOrderBuild(rawBuild: any): { build: any[]; steps: string[] } | null {
  if (!Array.isArray(rawBuild) || !rawBuild.length) return null;
  const steps: string[] = [];
  for (const s of rawBuild) {
    if (typeof s?.label !== 'string' || typeof s?.value !== 'string') return null;
    steps.push(`${s.label}: ${s.value}`);
  }
  return { build: rawBuild, steps };
}

type ResolvedItem = { id: string; name: string; variant?: string; qty: number; price: number };

// Resolves + validates client-submitted cart lines against MENU_ITEMS.
// Returns null if any line references an unknown item id or a bad quantity.
function resolveCartItems(rawItems: any[]): ResolvedItem[] | null {
  const resolved: ResolvedItem[] = [];
  for (const raw of rawItems) {
    const catalogItem = MENU_ITEMS[raw?.id];
    const qty = Math.trunc(Number(raw?.qty));
    if (!catalogItem || !Number.isFinite(qty) || qty < 1) return null;
    resolved.push({ id: raw.id, name: catalogItem.name, variant: catalogItem.variant, qty, price: catalogItem.price });
  }
  return resolved;
}

// Metadata values are capped at 500 chars by Stripe; food pre-orders are
// small enough that this is never a practical concern.
function buildMarketplaceMetadata(items: ResolvedItem[], body: Record<string, any>) {
  return {
    order_type: 'marketplace',
    customer_name: String(body.customerName ?? ''),
    customer_phone: String(body.customerPhone ?? ''),
    pickup_time: String(body.pickupTime ?? ''),
    guest_count: String(body.guestCount ?? ''),
    items_json: JSON.stringify(
      items.map((i) => ({ name: i.name, variant: i.variant, qty: i.qty, price: i.price }))
    ).slice(0, 500),
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: CORS_HEADERS });

  try {
    const body = await req.json();
    const mode = body.mode;

    if (mode === 'marketplace') {
      const rawItems = Array.isArray(body.items) ? body.items : [];
      if (!rawItems.length) return json({ error: 'Cart is empty' }, 400);

      const items = resolveCartItems(rawItems);
      if (!items) return json({ error: 'Invalid item in cart' }, 400);

      const metadata = buildMarketplaceMetadata(items, body);
      const cancelPath = CANCEL_PATHS[body.source] ?? CANCEL_PATHS.marketplace;

      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        line_items: items.map((i) => ({
          price_data: {
            currency: 'usd',
            product_data: { name: i.variant ? `${i.name} (${i.variant})` : i.name },
            unit_amount: Math.round(i.price * 100),
          },
          quantity: i.qty,
        })),
        customer_email: body.customerEmail || undefined,
        metadata,
        payment_intent_data: { metadata },
        success_url: `${SITE_URL}/marketplace/order-success.html?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${SITE_URL}${cancelPath}`,
      });

      return json({ url: session.url });
    }

    // Cash ask on a partner's personal page (/partner/?k=...). The browser
    // sends only the partner key and item ids/quantities (plus an amount for
    // open-amount items); every price is decided here from the partner's own
    // stored menu -- see supabase/fs-partner-pay.sql.
    if (mode === 'partner_gift') {
      const key = String(body.key || '').trim().toLowerCase();
      if (!/^[a-z0-9]{6,12}$/.test(key)) return json({ error: 'Invalid link' }, 400);
      const admin = createClient(Deno.env.get('SUPABASE_URL')!, Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!);
      const { data: menu, error: menuErr } = await admin.rpc('fs_partner_cash_menu', { p_key: key });
      if (menuErr || !menu || !menu.length) return json({ error: 'Invitation not found' }, 404);
      const partner = menu[0];
      const catalog: Record<string, any> = {};
      for (const i of Array.isArray(partner.ask_items) ? partner.ask_items : []) if (i && i.cash && i.id) catalog[String(i.id)] = i;

      const lines: { name: string; cents: number; qty: number }[] = [];
      for (const r of Array.isArray(body.items) ? body.items.slice(0, 20) : []) {
        const it = catalog[String(r && r.id)];
        if (!it) return json({ error: 'Unknown item' }, 400);
        const qty = Math.max(1, Math.min(1000, Math.round(Number(r.qty) || 1)));
        const unit = Number(it.value) > 0 ? Number(it.value) : Number(r.amount);
        const cents = Math.round(unit * 100);
        if (!cents || cents < 100) return json({ error: 'Each gift must be at least $1' }, 400);
        lines.push({ name: String(it.label).slice(0, 120), cents, qty: Number(it.value) > 0 ? qty : 1 });
      }
      if (!lines.length) return json({ error: 'Choose a gift first' }, 400);
      const total = lines.reduce((s, l) => s + l.cents * l.qty, 0);
      if (total > 5_000_000) return json({ error: 'For gifts over $50,000 please call Stephen at 414-909-3279' }, 400);

      const summary = lines.map((l) => `${l.name} x${l.qty}`).join('; ').slice(0, 480);
      const metadata = { order_type: 'partner_gift', pitch_key: key, partner_name: String(partner.name).slice(0, 100), summary };
      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        line_items: lines.map((l) => ({
          price_data: { currency: 'usd', product_data: { name: `Full Spectrum: ${l.name}` }, unit_amount: l.cents },
          quantity: l.qty,
        })),
        customer_email: body.donorEmail || undefined,
        metadata,
        payment_intent_data: { metadata },
        success_url: `${SITE_URL}/partner/?k=${key}&paid=1`,
        cancel_url: `${SITE_URL}/partner/?k=${key}`,
      });
      return json({ url: session.url });
    }

    if (mode === 'donation') {
      const amount = Math.round(Number(body.amount) * 100);
      if (!amount || amount < 100) return json({ error: 'Minimum donation is $1' }, 400);
      const recurring = Boolean(body.recurring);

      // Each fund has separate one-time and monthly Stripe products, so
      // Stripe's own reporting stays meaningful. `fund` is the only thing
      // the client needs to pick — product IDs stay server-side.
      const FUND_PRODUCTS: Record<string, { once: string; monthly: string }> = {
        general: { once: 'prod_Uq6JmXb3pIWc9Q', monthly: 'prod_Uq4ep19taCtHNe' },
        scholarship: { once: 'prod_Ur7mINiSdb8wAB', monthly: 'prod_Uq2xF7nL2NUpHf' },
      };
      const fund = FUND_PRODUCTS[body.fund] ? body.fund : 'general';
      const fundProductId = FUND_PRODUCTS[fund][recurring ? 'monthly' : 'once'];

      const metadata = {
        order_type: 'donation',
        fund,
        fund_product_id: fundProductId,
        recurring: String(recurring),
      };

      const session = await stripe.checkout.sessions.create({
        mode: recurring ? 'subscription' : 'payment',
        line_items: [
          {
            price_data: {
              currency: 'usd',
              product: fundProductId,
              unit_amount: amount,
              ...(recurring ? { recurring: { interval: 'month' } } : {}),
            },
            quantity: 1,
          },
        ],
        customer_email: body.donorEmail || undefined,
        metadata,
        ...(recurring
          ? { subscription_data: { metadata } }
          : { payment_intent_data: { metadata } }),
        success_url: `${SITE_URL}/donate/success.html?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${SITE_URL}/donate/`,
      });

      return json({ url: session.url });
    }

    if (mode === 'bowl_order') {
      const resolved = resolveBowlOrderBuild(body.build);
      if (!resolved) return json({ error: 'Invalid bowl build' }, 400);

      const format = body.format === 'Taco' ? 'Taco' : 'Bowl';
      const customerName = String(body.customerName || 'Walk-in').slice(0, 200);
      const isSpecial = isBemBemBuild(resolved.build);
      const price = isSpecial ? BEM_BEM_PRICE : BOWL_PRICE;
      const productName = isSpecial ? `Bem Bem ${format}` : `Yawd ${format}`;

      const metadata = {
        order_type: 'bowl_order',
        customer_name: customerName,
        format,
        // Stripe caps metadata values at 500 chars — a built bowl's step
        // list comfortably fits; if it ever doesn't, better to truncate
        // here (a slightly short kitchen ticket) than fail the whole order.
        build_json: JSON.stringify(resolved.build).slice(0, 500),
      };

      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        payment_method_types: ['card', 'cashapp', 'paypal'],
        line_items: [
          {
            price_data: {
              currency: 'usd',
              product_data: {
                name: productName,
                description: resolved.steps.join(' · ').slice(0, 500),
              },
              unit_amount: Math.round(price * 100),
            },
            quantity: 1,
          },
        ],
        metadata,
        payment_intent_data: { metadata },
        success_url: `${SITE_URL}/bowl-order-success.html?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${SITE_URL}${CANCEL_PATHS['bowl-order']}`,
      });

      return json({ url: session.url });
    }

    return json({ error: 'invalid mode' }, 400);
  } catch (e) {
    console.error('create-checkout-session error:', e);
    return json({ error: String(e) }, 500);
  }
});

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

// Metadata values are capped at 500 chars by Stripe; food pre-orders are
// small enough that this is never a practical concern.
function buildMarketplaceMetadata(body: Record<string, any>) {
  const items = Array.isArray(body.items) ? body.items : [];
  return {
    order_type: 'marketplace',
    customer_name: String(body.customerName ?? ''),
    customer_phone: String(body.customerPhone ?? ''),
    pickup_time: String(body.pickupTime ?? ''),
    guest_count: String(body.guestCount ?? ''),
    items_json: JSON.stringify(
      items.map((i: any) => ({ name: i.name, variant: i.variant, qty: i.qty, price: i.price }))
    ).slice(0, 500),
  };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: CORS_HEADERS });

  try {
    const body = await req.json();
    const mode = body.mode;

    if (mode === 'marketplace') {
      const items = Array.isArray(body.items) ? body.items : [];
      if (!items.length) return json({ error: 'Cart is empty' }, 400);

      const metadata = buildMarketplaceMetadata(body);

      const session = await stripe.checkout.sessions.create({
        mode: 'payment',
        line_items: items.map((i: any) => ({
          price_data: {
            currency: 'usd',
            product_data: { name: i.variant ? `${i.name} (${i.variant})` : i.name },
            unit_amount: Math.round(Number(i.price) * 100),
          },
          quantity: i.qty,
        })),
        customer_email: body.customerEmail || undefined,
        metadata,
        payment_intent_data: { metadata },
        success_url: `${SITE_URL}/marketplace/order-success.html?session_id={CHECKOUT_SESSION_ID}`,
        cancel_url: `${SITE_URL}/marketplace/`,
      });

      return json({ url: session.url });
    }

    if (mode === 'donation') {
      const amount = Math.round(Number(body.amount) * 100);
      if (!amount || amount < 100) return json({ error: 'Minimum donation is $1' }, 400);
      const recurring = Boolean(body.recurring);
      // General Fund is split into separate one-time and monthly Stripe
      // products (Youth Scholarship Fund has the same split, see
      // prod_Ur7mINiSdb8wAB / prod_Uq2xF7nL2NUpHf, for when the donate page
      // grows a fund selector) — route to whichever matches what was
      // actually chosen so Stripe's own records stay meaningful.
      const fundProductId =
        body.fundProductId || (recurring ? 'prod_Uq4ep19taCtHNe' : 'prod_Uq6JmXb3pIWc9Q');

      const metadata = {
        order_type: 'donation',
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

    return json({ error: 'invalid mode' }, 400);
  } catch (e) {
    console.error('create-checkout-session error:', e);
    return json({ error: String(e) }, 500);
  }
});

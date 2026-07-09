// Fires on inserts into notification-worthy tables (raffle_entries,
// marketplace_preorders, and more as they're added) via a database trigger
// that calls net.http_post — see supabase/schema.sql. Not called from any
// client-side code; only the database itself calls this, authenticated by
// the shared WEBHOOK_SECRET header rather than a user JWT.

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const WEBHOOK_SECRET = Deno.env.get('WEBHOOK_SECRET')!;
const NOTIFY_TO = 'selassiefest@gmail.com';
const FROM = 'SelassieFest Notifications <onboarding@resend.dev>';

function escapeHtml(s: unknown): string {
  return String(s ?? '').replace(/[&<>"']/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' } as Record<string, string>)[c]
  );
}

function formatRaffleEntry(record: Record<string, any>) {
  return {
    subject: `New Raffle Entry — ${record.buyer_name}`,
    html: `
      <h2>New Raffle Entry</h2>
      <p><strong>Buyer:</strong> ${escapeHtml(record.buyer_name)} (${escapeHtml(record.buyer_email)})</p>
      <p><strong>Tickets:</strong> ${escapeHtml(record.ticket_qty)} ($${escapeHtml(record.total_amount)})</p>
      <p><strong>Prize:</strong> ${escapeHtml(record.prize_name)}</p>
      <p><strong>Payment:</strong> ${escapeHtml(record.payment_method)}, TX: ${escapeHtml(record.transaction_id)}</p>
      <p><strong>Status:</strong> ${escapeHtml(record.status)}</p>
    `,
  };
}

function formatMarketplacePreorder(record: Record<string, any>) {
  const items = Array.isArray(record.items) ? record.items : [];
  const itemsList = items
    .map((i: any) => `${escapeHtml(i.name)}${i.variant ? ' (' + escapeHtml(i.variant) + ')' : ''} x${escapeHtml(i.qty)}`)
    .join('<br>');
  return {
    subject: `New Marketplace Pre-Order — ${record.customer_name}`,
    html: `
      <h2>New Marketplace Pre-Order</h2>
      <p><strong>Customer:</strong> ${escapeHtml(record.customer_name)} (${escapeHtml(record.customer_email)}, ${escapeHtml(record.customer_phone)})</p>
      <p><strong>Pickup:</strong> ${escapeHtml(record.pickup_time)}</p>
      <p><strong>Guests:</strong> ${escapeHtml(record.guest_count)}</p>
      <p><strong>Items:</strong><br>${itemsList}</p>
      <p><strong>Total:</strong> $${escapeHtml(record.total_amount)}</p>
    `,
  };
}

const FORMATTERS: Record<string, (record: Record<string, any>) => { subject: string; html: string }> = {
  raffle_entries: formatRaffleEntry,
  marketplace_preorders: formatMarketplacePreorder,
};

Deno.serve(async (req: Request) => {
  if (req.headers.get('x-webhook-secret') !== WEBHOOK_SECRET) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }

  try {
    const payload = await req.json();
    const table: string = payload.table;
    const record = payload.record;

    const formatter = FORMATTERS[table];
    if (!formatter) {
      return new Response(JSON.stringify({ skipped: true, reason: `no formatter for table ${table}` }), { status: 200 });
    }

    const { subject, html } = formatter(record);

    const resendRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ from: FROM, to: NOTIFY_TO, subject, html }),
    });

    if (!resendRes.ok) {
      const errText = await resendRes.text();
      console.error('Resend send failed:', resendRes.status, errText);
      return new Response(JSON.stringify({ error: errText }), { status: 502 });
    }

    return new Response(JSON.stringify({ sent: true }), { status: 200 });
  } catch (e) {
    console.error('notify-submission error:', e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});

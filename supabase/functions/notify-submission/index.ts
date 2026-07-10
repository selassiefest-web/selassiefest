// Fires on inserts into notification-worthy tables (raffle_entries,
// marketplace_preorders, and more as they're added) via a database trigger
// that calls net.http_post — see supabase/schema.sql. Not called from any
// client-side code; only the database itself calls this, authenticated by
// the shared WEBHOOK_SECRET header rather than a user JWT.

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const WEBHOOK_SECRET = Deno.env.get('WEBHOOK_SECRET')!;
const NOTIFY_TO = 'selassiefest@gmail.com';
const FROM = 'SelassieFest Notifications <onboarding@resend.dev>';
// "SelassieFest Newsletter" Resend Audience — lets staff compose and send
// campaigns to subscribers directly from the Resend dashboard (Broadcasts)
// without any code here. Every newsletter_subscribers insert gets synced
// into it below, in addition to the subscriber's own confirmation email.
const NEWSLETTER_AUDIENCE_ID = '6561e97b-31be-45c8-a069-e8d8ae29711e';

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

function formatVolunteerSignup(record: Record<string, any>) {
  return {
    subject: `New Volunteer Application — ${record.full_name}`,
    html: `
      <h2>New Volunteer Application</h2>
      <p><strong>Name:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.email)}, ${escapeHtml(record.phone)})</p>
      <p><strong>Age:</strong> ${escapeHtml(record.age)}</p>
      <p><strong>Preferred Role:</strong> ${escapeHtml(record.role_choice)}</p>
      <p><strong>Shift:</strong> ${escapeHtml(record.shift_preference)}</p>
      <p><strong>T-Shirt:</strong> ${escapeHtml(record.tshirt_size)}</p>
      <p><strong>Emergency Contact:</strong> ${escapeHtml(record.emergency_contact)}</p>
      <p><strong>Accommodations:</strong> ${escapeHtml(record.accommodations)}</p>
      <p><strong>Referral:</strong> ${escapeHtml(record.referral_source)}</p>
      <p><strong>Waiver Accepted:</strong> ${record.waiver_accepted ? 'Yes' : 'No'}</p>
    `,
  };
}

function formatSponsorInquiry(record: Record<string, any>) {
  const fields = Array.isArray(record.fields) ? record.fields : [];
  const fieldsList = fields.map((f: any) => `<p><strong>${escapeHtml(f.label)}:</strong> ${escapeHtml(f.value)}</p>`).join('');
  return {
    subject: `New Sponsor Inquiry — ${record.source_page || 'sponsors'}`,
    html: `
      <h2>New Sponsor Inquiry</h2>
      <p><strong>From page:</strong> ${escapeHtml(record.source_page)}</p>
      ${fieldsList}
    `,
  };
}

function formatCampRegistration(record: Record<string, any>) {
  const data = record.registration_data || {};
  const weeks = Object.keys(data)
    .filter((k) => /^week\d+$/.test(k) && data[k])
    .map((k) => k.replace('week', 'Week '));
  return {
    subject: `New Camp Registration — ${record.camper_name}`,
    html: `
      <h2>New Camp Registration</h2>
      <p><strong>Camper:</strong> ${escapeHtml(record.camper_name)}</p>
      <p><strong>Guardian:</strong> ${escapeHtml(record.guardian_name)} (${escapeHtml(record.guardian_email)}, ${escapeHtml(record.guardian_phone)})</p>
      <p><strong>Weeks Selected:</strong> ${weeks.length ? escapeHtml(weeks.join(', ')) : 'None selected'}</p>
      <p><strong>Full details:</strong> see the camp_registrations table in Supabase (registration_data column) for allergies, medical info, consents, and everything else submitted.</p>
    `,
  };
}

function formatDonation(record: Record<string, any>) {
  const fundLabel = record.fund === 'scholarship' ? 'Youth Scholarship Fund' : 'General Fund';
  return {
    subject: `New Donation — $${escapeHtml(record.amount)}${record.recurring === 'true' ? '/mo' : ''} (${fundLabel})`,
    html: `
      <h2>New Donation</h2>
      <p><strong>Fund:</strong> ${escapeHtml(fundLabel)}</p>
      <p><strong>Amount:</strong> $${escapeHtml(record.amount)} ${escapeHtml((record.currency || 'usd').toUpperCase())}${record.recurring === 'true' ? ' / month (recurring)' : ' (one-time)'}</p>
      <p><strong>Donor Email:</strong> ${escapeHtml(record.email)}</p>
      <p><strong>Stripe Payment Intent:</strong> ${escapeHtml(record.payment_intent_id)}</p>
    `,
  };
}

// The only formatter that emails the SUBMITTER instead of the org — every
// other table's trigger exists to notify staff of a new submission, but
// newsletter signups get a subscriber-facing confirmation instead (see
// TABLE_CONFIG's `to` below).
function formatNewsletterConfirmation(record: Record<string, any>) {
  return {
    subject: `You're on the list — SelassieFest`,
    html: `
      <h2>Welcome to SelassieFest!</h2>
      <p>You're signed up for festival dates, camp registration, and community updates.</p>
      <p>We'll only email you when there's something worth sharing.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">If you didn't sign up for this, you can safely ignore this email.</p>
    `,
  };
}

type TableConfig = {
  to: (record: Record<string, any>) => string;
  format: (record: Record<string, any>) => { subject: string; html: string };
};

const TABLE_CONFIG: Record<string, TableConfig> = {
  raffle_entries: { to: () => NOTIFY_TO, format: formatRaffleEntry },
  marketplace_preorders: { to: () => NOTIFY_TO, format: formatMarketplacePreorder },
  volunteer_signups: { to: () => NOTIFY_TO, format: formatVolunteerSignup },
  sponsor_inquiries: { to: () => NOTIFY_TO, format: formatSponsorInquiry },
  camp_registrations: { to: () => NOTIFY_TO, format: formatCampRegistration },
  stripe_donations: { to: () => NOTIFY_TO, format: formatDonation },
  newsletter_subscribers: { to: (record) => record.email, format: formatNewsletterConfirmation },
};

Deno.serve(async (req: Request) => {
  if (req.headers.get('x-webhook-secret') !== WEBHOOK_SECRET) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }

  try {
    const payload = await req.json();
    const table: string = payload.table;
    const record = payload.record;

    const config = TABLE_CONFIG[table];
    if (!config) {
      return new Response(JSON.stringify({ skipped: true, reason: `no formatter for table ${table}` }), { status: 200 });
    }

    const to = config.to(record);
    if (!to) {
      return new Response(JSON.stringify({ skipped: true, reason: 'no recipient email on record' }), { status: 200 });
    }

    // Best-effort — a Resend Audience hiccup shouldn't block the
    // confirmation email itself.
    if (table === 'newsletter_subscribers') {
      try {
        await fetch(`https://api.resend.com/audiences/${NEWSLETTER_AUDIENCE_ID}/contacts`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email: record.email, unsubscribed: false }),
        });
      } catch (e) {
        console.error('Resend audience sync failed:', e);
      }
    }

    const { subject, html } = config.format(record);

    const resendRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({ from: FROM, to, subject, html }),
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

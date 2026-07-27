// Emails a point-in-time snapshot of a live-editable SelassieFest planning
// page (currently the 2027 committee-structure page) to a staff inbox when
// someone clicks its "Save & Email" button. Unlike notify-submission.ts,
// this isn't fired by a database trigger on a row insert -- it's invoked
// directly from client JS (via supabase.functions.invoke, using the anon
// key, which satisfies this project's default JWT verification) with
// whatever the page's editable fields currently hold, since there's no
// single "record" being created here, just a copy of the whole document.
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const TO = 'stephen@selassiefest.com';
const FROM = 'SelassieFest <hello@selassiefest.com>';
const REPLY_TO = 'selassiefest@gmail.com';

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

function escapeHtml(s: unknown): string {
  return String(s ?? '').replace(/[&<>"']/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' } as Record<string, string>)[c]
  );
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response(null, { headers: CORS_HEADERS });

  if (req.method !== 'POST') {
    return json({ error: 'method not allowed' }, 405);
  }

  try {
    const payload = await req.json();
    const pageTitle: string = payload.pageTitle || 'SelassieFest planning document';
    const pageUrl: string = payload.pageUrl || '';
    const sentBy: string = payload.sentBy || 'Unknown';
    const sections: { label?: string; content?: string }[] = Array.isArray(payload.sections) ? payload.sections : [];

    if (!sections.length) {
      return json({ error: 'no sections provided' }, 400);
    }

    const bodyHtml = sections
      .map(
        (s) => `
        <div style="margin-bottom:16px;">
          <div style="font-size:11px;text-transform:uppercase;letter-spacing:0.05em;color:#71786f;margin-bottom:3px;">${escapeHtml(s.label)}</div>
          <div style="white-space:pre-line;font-size:14px;color:#1a1e1b;">${escapeHtml(s.content)}</div>
        </div>`
      )
      .join('');

    const html = `
      <h2 style="margin-bottom:4px;">${escapeHtml(pageTitle)}</h2>
      <p style="color:#71786f;font-size:13px;margin-top:0;">Saved snapshot &middot; sent by <strong>${escapeHtml(sentBy)}</strong>${
      pageUrl ? ` from <a href="${escapeHtml(pageUrl)}">${escapeHtml(pageUrl)}</a>` : ''
    }</p>
      <hr style="border:none;border-top:1px solid #ddd6c4;margin:16px 0;" />
      ${bodyHtml}
    `;

    const resendRes = await fetch('https://api.resend.com/emails', {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: FROM,
        to: TO,
        reply_to: REPLY_TO,
        subject: `${pageTitle} — saved by ${sentBy}`,
        html,
      }),
    });

    if (!resendRes.ok) {
      const errText = await resendRes.text();
      console.error('Resend send failed:', resendRes.status, errText);
      return json({ error: errText }, 502);
    }

    return json({ sent: true });
  } catch (e) {
    console.error('send-planning-snapshot error:', e);
    return json({ error: String(e) }, 500);
  }
});

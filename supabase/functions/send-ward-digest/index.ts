// Emails the weekly "South Side ward meetings & events" digest (Wards 3, 5,
// 20 around Washington Park / Jackson Park, plus adjoining Wards 4, 6, 7, 8)
// to Stephen and the shared festival inbox. Not called from any site page --
// a scheduled Claude Code cloud routine researches the week's ward events
// every Sunday morning and POSTs them here. Like send-planning-snapshot,
// the anon key satisfies JWT verification; on top of that the caller must
// send the DIGEST_SECRET header, since recipients are fixed below and this
// shouldn't be something any visitor holding the public anon key can fire.
const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const DIGEST_SECRET = Deno.env.get('DIGEST_SECRET')!;
const TO = ['stephen@selassiefest.com', 'selassiefest@gmail.com'];
const FROM = 'SelassieFest <hello@selassiefest.com>';
const REPLY_TO = 'selassiefest@gmail.com';

const PRIMARY_WARDS = ['3', '5', '20'];

type DigestEvent = {
  ward?: string;
  title?: string;
  date?: string;
  time?: string;
  location?: string;
  url?: string;
  notes?: string;
};

function json(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function escapeHtml(s: unknown): string {
  return String(s ?? '').replace(/[&<>"']/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' } as Record<string, string>)[c]
  );
}

function safeUrl(u: unknown): string {
  const s = String(u ?? '');
  return /^https?:\/\//i.test(s) ? s : '';
}

function renderEvent(e: DigestEvent): string {
  const url = safeUrl(e.url);
  const title = url
    ? `<a href="${escapeHtml(url)}" style="color:#1f5f3a;">${escapeHtml(e.title)}</a>`
    : escapeHtml(e.title);
  const when = [e.date, e.time].filter(Boolean).map(escapeHtml).join(' &middot; ');
  return `
    <tr>
      <td style="padding:8px 10px;border-bottom:1px solid #eee;vertical-align:top;white-space:nowrap;font-weight:600;">Ward ${escapeHtml(e.ward)}</td>
      <td style="padding:8px 10px;border-bottom:1px solid #eee;vertical-align:top;">
        <div style="font-size:14px;font-weight:600;">${title}</div>
        <div style="font-size:13px;color:#444;">${when}${e.location ? ` &middot; ${escapeHtml(e.location)}` : ''}</div>
        ${e.notes ? `<div style="font-size:12px;color:#71786f;margin-top:2px;">${escapeHtml(e.notes)}</div>` : ''}
      </td>
    </tr>`;
}

function renderSection(heading: string, events: DigestEvent[]): string {
  const rows = events.length
    ? events.map(renderEvent).join('')
    : `<tr><td style="padding:8px 10px;color:#71786f;font-size:13px;">Nothing found for the coming weeks.</td></tr>`;
  return `
    <h3 style="margin:24px 0 6px;color:#1f5f3a;">${escapeHtml(heading)}</h3>
    <table style="border-collapse:collapse;width:100%;font-family:Arial,sans-serif;">${rows}</table>`;
}

Deno.serve(async (req: Request) => {
  if (req.method !== 'POST') return json({ error: 'method not allowed' }, 405);
  if (req.headers.get('x-digest-secret') !== DIGEST_SECRET) return json({ error: 'unauthorized' }, 401);

  try {
    const payload = await req.json();
    const weekOf: string = payload.weekOf || new Date().toISOString().slice(0, 10);
    const events: DigestEvent[] = Array.isArray(payload.events) ? payload.events : [];
    const summary: string = payload.summary || '';
    const sourcesNote: string = payload.sourcesNote || '';

    const isPrimary = (e: DigestEvent) => PRIMARY_WARDS.includes(String(e.ward ?? '').replace(/\D/g, ''));
    const primary = events.filter(isPrimary);
    const adjoining = events.filter((e) => !isPrimary(e));

    const html = `
      <div style="font-family:Arial,sans-serif;color:#1a1e1b;max-width:720px;">
        <h2 style="margin-bottom:4px;">South Side ward meetings &amp; events</h2>
        <p style="color:#71786f;font-size:13px;margin-top:0;">Week of ${escapeHtml(weekOf)} &middot; Washington Park / Jackson Park area</p>
        ${summary ? `<p style="font-size:14px;white-space:pre-line;">${escapeHtml(summary)}</p>` : ''}
        ${renderSection('Primary wards: 3, 5, 20', primary)}
        ${renderSection('Adjoining wards: 4, 6, 7, 8', adjoining)}
        ${sourcesNote ? `<p style="color:#71786f;font-size:12px;margin-top:24px;white-space:pre-line;">${escapeHtml(sourcesNote)}</p>` : ''}
      </div>`;

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
        subject: `Ward meetings & events — week of ${weekOf} (${events.length})`,
        html,
      }),
    });

    if (!resendRes.ok) {
      const errText = await resendRes.text();
      console.error('Resend send failed:', resendRes.status, errText);
      return json({ error: errText }, 502);
    }

    return json({ sent: true, count: events.length });
  } catch (e) {
    console.error('send-ward-digest error:', e);
    return json({ error: String(e) }, 500);
  }
});

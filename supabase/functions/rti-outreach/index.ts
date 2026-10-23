// Supabase Edge Function: rti-outreach
// CLI-only: sends one outreach email from Ras Tafari Inc. (e.g. a support request
// letter to an alderman or police district), optionally with a PDF attachment.
//
//   { secret, to: [..], cc?: [..], reply_to?, subject, text, html, attachments?: [{ filename, content (base64) }] }
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, RTI_SIGN_ADMIN_SECRET.
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";
// From a real, monitored mailbox (stephen@) rather than hello@: better trust with Gmail and Outlook filters.
const FROM_EMAIL = "Stephen Henry, Ras Tafari Inc. <stephen@selassiefest.com>";
const isEmail = (s: string) => /^[^\s@<>()",;:]+@[^\s@<>()",;:]+\.[^\s@<>()",;:]+$/.test(s);

Deno.serve(async (req) => {
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  let b: Record<string, any>;
  try { b = await req.json(); } catch { return reply({ ok: false, error: "Bad JSON." }, 400); }
  if (!ADMIN_SECRET || String(b.secret ?? "") !== ADMIN_SECRET) return reply({ ok: false, error: "Not allowed." }, 403);
  const to = (Array.isArray(b.to) ? b.to : []).map(String).filter(isEmail);
  const cc = (Array.isArray(b.cc) ? b.cc : []).map(String).filter(isEmail);
  if (!to.length || !b.subject || !b.html) return reply({ ok: false, error: "to, subject and html are required." }, 400);
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM_EMAIL, to, cc: cc.length ? cc : undefined, reply_to: b.reply_to || "stephen@selassiefest.com",
      subject: String(b.subject).slice(0, 200), text: b.text, html: b.html,
      attachments: Array.isArray(b.attachments) ? b.attachments.slice(0, 3) : undefined,
    }),
  });
  const out = await res.json().catch(() => ({}));
  return reply({ ok: res.ok, id: out.id, error: res.ok ? undefined : (out.message || res.status) }, res.ok ? 200 : 502);
});

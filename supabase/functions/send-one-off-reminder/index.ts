// One-off reminder email. POST {"subject": "...", "html": "..."} with header
// x-webhook-secret (ONE_OFF_REMINDER_SECRET). Used by a self-removing pg_cron
// job scheduled for a single date and time. Header x-dry-run: 1 returns the
// rendered message without sending. Recipients are fixed below.
const WEBHOOK_SECRET = Deno.env.get("ONE_OFF_REMINDER_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "SelassieFest <hello@selassiefest.com>";
const TO = ["stephen@selassiefest.com", "selassiefest@gmail.com"];

Deno.serve(async (req) => {
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const body = await req.json().catch(() => ({}));
  const subject = String(body.subject ?? "").slice(0, 200);
  const html = String(body.html ?? "");
  if (!subject || !html) {
    return new Response(JSON.stringify({ error: "subject and html are required" }), { status: 400 });
  }
  if (req.headers.get("x-dry-run") === "1") {
    return new Response(JSON.stringify({ ok: true, sent: false, to: TO, subject, html }), { status: 200 });
  }
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, subject, html }),
  });
  if (!res.ok) {
    return new Response(JSON.stringify({ error: await res.text() }), { status: 502 });
  }
  return new Response(JSON.stringify({ ok: true, sent: true }), { status: 200 });
});

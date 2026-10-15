// Emails Stephen the link to the Full Spectrum CPD ARCS application kit, then a
// reminder every 48 hours until he clicks "I've submitted it" in the email.
// POST from pg_cron (daily, header x-webhook-secret) sends on every second day
// counted from arcs_kit_reminder.started_on; body {"force":true} sends now.
// Header x-dry-run: 1 returns the rendered email without sending.
// GET ?stop=<ARCS_KIT_STOP_TOKEN> stops the reminders (see supabase/arcs-kit-reminder.sql).
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("ARCS_KIT_REMINDER_SECRET");
const STOP_TOKEN = Deno.env.get("ARCS_KIT_STOP_TOKEN");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Full Spectrum at Rainbow Beach <hello@selassiefest.com>";
const TO = ["stephen@selassiefest.com"];
const KIT = "https://claude.ai/artifact/Htmv2nQv8FkucTynqLAr8R";
const STOP_URL = `${SUPABASE_URL}/functions/v1/send-arcs-kit-reminder?stop=`;

function page(msg: string, status = 200) {
  return new Response(
    `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>ARCS reminders</title>
    <body style="font-family:system-ui,sans-serif;max-width:520px;margin:60px auto;padding:0 16px;color:#1d2420;line-height:1.5">${msg}</body>`,
    { status, headers: { "Content-Type": "text/html; charset=utf-8" } },
  );
}

Deno.serve(async (req) => {
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const url = new URL(req.url);

  if (req.method === "GET") {
    const tok = url.searchParams.get("stop");
    if (!STOP_TOKEN || tok !== STOP_TOKEN) return page("<p>This link isn't valid.</p>", 403);
    if (url.searchParams.get("confirm") !== "1") {
      return page(`<h2>Stop the ARCS reminders?</h2><p>Only do this once the proposal is sent to partnerships.app@chicagoparkdistrict.com.</p>
        <p><a href="?stop=${encodeURIComponent(tok)}&confirm=1" style="background:#2f6b45;color:#fff;padding:10px 18px;border-radius:8px;text-decoration:none;font-weight:600">Yes, I've submitted it. Stop the reminders</a></p>`);
    }
    const { error } = await admin.from("arcs_kit_reminder").update({ stopped_at: new Date().toISOString() }).eq("id", 1);
    if (error) return page(`<p>Couldn't stop the reminders: ${error.message}</p>`, 500);
    return page("<h2>Reminders stopped.</h2><p>Nice work getting the Full Spectrum proposal in. CPD asks for at least 30 days to review it.</p>");
  }

  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const body = await req.json().catch(() => ({}));
  const { data: row, error } = await admin.from("arcs_kit_reminder").select("*").eq("id", 1).maybeSingle();
  if (error || !row) return new Response(JSON.stringify({ error: error?.message ?? "no row" }), { status: 500 });
  if (row.stopped_at) return new Response(JSON.stringify({ ok: true, sent: false, reason: "stopped" }), { status: 200 });

  const today = new Date().toLocaleDateString("en-CA", { timeZone: "America/Chicago" });
  const day = Math.round((Date.parse(`${today}T12:00:00Z`) - Date.parse(`${row.started_on}T12:00:00Z`)) / 86400000);
  if (!body.force && day % 2 !== 0) {
    return new Response(JSON.stringify({ ok: true, sent: false, reason: "off day", day }), { status: 200 });
  }

  const first = day === 0 || !row.last_sent_at;
  const subject = first
    ? "Your CPD partnership application kit for Full Spectrum"
    : `Reminder: finish the CPD ARCS application (day ${day})`;
  const html = `
    <p>${first
      ? "Here's your kit for the Chicago Park District ARCS partnership application for Full Spectrum at Rainbow Beach. Ivry gave the go-ahead on Oct. 14."
      : "A reminder to finish and send the Full Spectrum ARCS partnership application to the Chicago Park District."}</p>
    <p style="margin:20px 0;"><a href="${KIT}" style="background:#2f6b45;color:#fff;padding:12px 20px;border-radius:8px;text-decoration:none;display:inline-block;font-weight:600;">Open the application kit</a></p>
    <p style="font-size:0.9rem;color:#5c665f;margin-top:-8px;">${KIT}<br>Private link: open it while signed in to claude.ai.</p>
    <h3 style="margin:22px 0 6px;">What's left</h3>
    <ol style="padding-left:20px;">
      <li><strong>Certificate of Insurance.</strong> CPD won't consider the application complete without a COI naming the Chicago Park District, 4830 S. Western Ave., Chicago, IL 60609, as additional insured. Plan for $1M general liability plus sexual abuse and molestation coverage.</li>
      <li><strong>Check the 10 flagged answers</strong> in the kit (gold edges), and ask Ivry about partner type (Service Provider or Resident), which room, and in-kind contributions.</li>
      <li><strong>Download the filled CPD form</strong> from the kit and gather the attachments: COI, IRS 501(c)(3) letter, Full Spectrum proposal PDF.</li>
      <li><strong>Email it</strong> to partnerships.app@chicagoparkdistrict.com and Cc ivry.ector@chicagoparkdistrict.com. The message is ready to copy in the kit.</li>
    </ol>
    <p style="margin:24px 0 8px;">Sent it? <a href="${STOP_URL}${encodeURIComponent(STOP_TOKEN ?? "")}">I've submitted it. Stop these reminders</a></p>
    <p style="color:#5c665f;font-size:0.8rem;">Sent automatically every 48 hours until you stop it.</p>`;

  if (req.headers.get("x-dry-run") === "1") {
    return new Response(JSON.stringify({ ok: true, sent: false, subject, to: TO, day, html }), { status: 200, headers: { "Content-Type": "application/json" } });
  }
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, subject, html }),
  });
  if (!res.ok) return new Response(JSON.stringify({ error: await res.text() }), { status: 502 });
  await admin.from("arcs_kit_reminder").update({ last_sent_at: new Date().toISOString() }).eq("id", 1);
  return new Response(JSON.stringify({ ok: true, sent: true, day }), { status: 200 });
});

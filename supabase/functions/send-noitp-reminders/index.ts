// Emails Stephen the dated steps for the Night Out in the Parks 2027 application.
// POST from pg_cron (daily, header x-webhook-secret) sends every noitp_reminders row whose
// send_on has arrived (Chicago date) and isn't sent; once the application is marked submitted,
// only rows flagged after_submit still go. Header x-dry-run: 1 lists what would send.
// GET ?submitted=<NOITP_STOP_TOKEN> marks the application submitted (see supabase/noitp-reminders.sql).
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("NOITP_REMINDER_SECRET");
const STOP_TOKEN = Deno.env.get("NOITP_STOP_TOKEN");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Ras Tafari Inc. <hello@selassiefest.com>";
const TO = ["stephen@selassiefest.com"];
const KIT = "https://claude.ai/artifact/JL1QozVMeGDTPXh8iSyH5D";
const STOP_URL = `${SUPABASE_URL}/functions/v1/send-noitp-reminders?submitted=`;

const esc = (s: string) => s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]!));
function page(msg: string, status = 200) {
  return new Response(
    `<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>Night Out reminders</title>
    <body style="font-family:system-ui,sans-serif;max-width:520px;margin:60px auto;padding:0 16px;color:#191b1f;line-height:1.5">${msg}</body>`,
    { status, headers: { "Content-Type": "text/html; charset=utf-8" } },
  );
}

Deno.serve(async (req) => {
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const url = new URL(req.url);

  if (req.method === "GET") {
    const tok = url.searchParams.get("submitted");
    if (!STOP_TOKEN || tok !== STOP_TOKEN) return page("<p>This link isn't valid.</p>", 403);
    if (url.searchParams.get("confirm") !== "1") {
      return page(`<h2>Mark the Night Out application as submitted?</h2><p>Do this once Submittable has confirmed the application.</p>
        <p><a href="?submitted=${encodeURIComponent(tok)}&confirm=1" style="background:#1f7a45;color:#fff;padding:10px 18px;border-radius:8px;text-decoration:none;font-weight:600">Yes, it's submitted</a></p>`);
    }
    const { error } = await admin.from("noitp_settings").update({ submitted_at: new Date().toISOString() }).eq("id", 1);
    if (error) return page(`<p>Couldn't save that: ${esc(error.message)}</p>`, 500);
    return page("<h2>Marked as submitted.</h2><p>Deadline reminders are off. CPD expects to notify applicants in early March 2027.</p>");
  }

  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) return new Response("Unauthorized", { status: 401 });

  const today = new Date().toLocaleDateString("en-CA", { timeZone: "America/Chicago" });
  const { data: settings } = await admin.from("noitp_settings").select("submitted_at").eq("id", 1).maybeSingle();
  let q = admin.from("noitp_reminders").select("*").is("sent_at", null).lte("send_on", today).order("send_on");
  if (settings?.submitted_at) q = q.eq("after_submit", true);
  const { data: due, error } = await q;
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  if (req.headers.get("x-dry-run") === "1") return new Response(JSON.stringify({ ok: true, today, due: (due ?? []).map((r) => [r.send_on, r.subject]) }), { headers: { "Content-Type": "application/json" } });

  const sent = [];
  for (const r of due ?? []) {
    // Full https:// addresses in a reminder become clickable links
    const linkify = (t: string) => t.replace(/(https:\/\/[^\s<]+[^\s<.,;:)])/g, '<a href="$1">$1</a>');
    const paras = String(r.body).split(/\n{2,}/).map((p) => `<p>${linkify(esc(p)).replace(/\n/g, "<br>")}</p>`).join("");
    const html = `${paras}
      <p style="margin:20px 0;"><a href="${KIT}" style="background:#1c2333;color:#fff;padding:12px 20px;border-radius:8px;text-decoration:none;display:inline-block;font-weight:600;">Open the Night Out kit</a></p>
      <p style="font-size:0.85rem;color:#5d6068;">${KIT}<br>Private link: open it while signed in to claude.ai.</p>
      ${settings?.submitted_at ? "" : `<p style="margin-top:22px;">Already submitted? <a href="${STOP_URL}${encodeURIComponent(STOP_TOKEN ?? "")}">Mark it submitted and stop the deadline reminders</a></p>`}`;
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: FROM, to: TO, subject: r.subject, html }),
    });
    if (!res.ok) { console.error("send-noitp-reminders: resend", res.status, (await res.text()).slice(0, 200)); continue; }
    await admin.from("noitp_reminders").update({ sent_at: new Date().toISOString() }).eq("id", r.id);
    sent.push(r.subject);
  }
  return new Response(JSON.stringify({ ok: true, today, sent }), { headers: { "Content-Type": "application/json" } });
});

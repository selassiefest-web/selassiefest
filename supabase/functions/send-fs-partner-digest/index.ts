// Weekly Full Spectrum Partner Tracker digest, emailed Monday mornings to
// Stephen and Paksipras: how many partners are still uncontacted, next steps
// due this week or overdue, partners in play with no contact in 14+ days,
// and the pipeline by stage. Triggered by
// pg_cron with the shared x-webhook-secret header (see
// supabase/full-spectrum-partners.sql); reads via fs_partners_digest(),
// which is service_role-only. Sends nothing when there's nothing to act on.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("FS_PARTNER_DIGEST_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Full Spectrum at Rainbow Beach <hello@selassiefest.com>";
const TO = ["stephen@selassiefest.com", "paksipras@gmail.com"];
const TRACKER = "https://selassiefest.com/full-spectrum/partners.html";

const STAGES: Record<string, string> = {
  not_contacted: "Not contacted", reached_out: "Reached out", in_conversation: "In conversation",
  meeting_set: "Meeting set", committed: "Committed", confirmed: "Confirmed in writing",
  declined: "Declined", on_hold: "On hold",
};

function esc(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}
function fmtDate(d: string) {
  return new Date(`${d.slice(0, 10)}T12:00:00`).toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" });
}

Deno.serve(async (req) => {
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data, error } = await admin.rpc("fs_partners_digest");
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });

  const due = (data?.due ?? []) as { name: string; stage: string; next_step: string | null; due: string }[];
  const stale = (data?.stale ?? []) as { name: string; stage: string; last: string | null }[];
  const counts = (data?.counts ?? {}) as Record<string, number>;
  const untouched = counts.not_contacted ?? 0;
  if (!due.length && !stale.length && !untouched && req.headers.get("x-force") !== "1") {
    return new Response(JSON.stringify({ ok: true, sent: false, reason: "nothing to act on" }), { status: 200 });
  }

  const today = new Date().toISOString().slice(0, 10);
  const dueHtml = due.length ? `<h3 style="margin:18px 0 6px;">Next steps due this week</h3><ul style="padding-left:18px;">${due.map((r) => `
      <li style="margin-bottom:8px;"><strong>${esc(r.name)}</strong> &middot; ${esc(STAGES[r.stage] ?? r.stage)}
      <br><span style="color:${r.due < today ? "#a83a3a" : "#5b6b7a"};font-size:0.9rem;">${r.due < today ? "OVERDUE, was due" : "Due"} ${fmtDate(r.due)}</span>
      ${r.next_step ? `<br><span style="font-size:0.9rem;">${esc(r.next_step)}</span>` : ""}</li>`).join("")}</ul>` : "";
  const staleHtml = stale.length ? `<h3 style="margin:18px 0 6px;">Gone quiet (no contact in 14+ days)</h3><ul style="padding-left:18px;">${stale.map((r) => `
      <li style="margin-bottom:6px;"><strong>${esc(r.name)}</strong> &middot; ${esc(STAGES[r.stage] ?? r.stage)} &middot;
      <span style="color:#5b6b7a;font-size:0.9rem;">${r.last ? "last contact " + fmtDate(r.last) : "no contact logged"}</span></li>`).join("")}</ul>` : "";
  const order = ["not_contacted", "reached_out", "in_conversation", "meeting_set", "committed", "confirmed", "declined", "on_hold"];
  const pipeline = order.filter((k) => counts[k]).map((k) => `${esc(STAGES[k])}: <strong>${counts[k]}</strong>`).join(" &middot; ");

  const html = `
    <p>Your weekly Full Spectrum partner check-in.</p>
    ${untouched ? `<p><strong>${untouched}</strong> partner${untouched === 1 ? " has" : "s have"} not been contacted yet.</p>` : ""}
    ${dueHtml}${staleHtml}
    <h3 style="margin:18px 0 6px;">Pipeline</h3><p style="font-size:0.9rem;">${pipeline || "No partners yet."}</p>
    <p style="margin:20px 0;"><a href="${TRACKER}" style="background:#2F3DB5;color:#fff;padding:10px 18px;border-radius:8px;text-decoration:none;display:inline-block;font-weight:600;">Open the Partner Tracker</a></p>
    <p style="color:#5b6b7a;font-size:0.8rem;">Sent automatically every Monday morning.</p>`;
  const subject = `Partner check-in: ${due.length} due${stale.length ? `, ${stale.length} gone quiet` : ""}${untouched ? `, ${untouched} not contacted` : ""}`;

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, subject, html }),
  });
  if (!res.ok) return new Response(JSON.stringify({ error: await res.text() }), { status: 502 });
  return new Response(JSON.stringify({ ok: true, sent: true, due: due.length, stale: stale.length }), { status: 200 });
});

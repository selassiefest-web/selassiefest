// Weekly Full Spectrum grant-deadline email, sent Sunday mornings to Stephen,
// Kirk and Paksipras. Reads the staff-only fs_grant_deadlines table and groups
// it: closing soon, expected windows, rolling/apply-anytime, and paused or
// relationship funders. Triggered by pg_cron with the shared x-webhook-secret
// header (see supabase/fs-grant-deadlines.sql). Always sends on schedule;
// send header x-dry-run: 1 to get the rendered email back without sending.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("FS_GRANT_DIGEST_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Full Spectrum at Rainbow Beach <hello@selassiefest.com>";
const TO = ["stephen@selassiefest.com", "prestigesoundkirk@gmail.com", "paksipras@gmail.com"];
const TRACKER = "https://selassiefest.com/full-spectrum/partners.html";

type Row = {
  funder: string; program: string | null; kind: string; deadline_date: string | null;
  opens_date: string | null; amount: string | null; verified: boolean; url: string | null; notes: string | null;
  status?: string | null; next_step?: string | null; next_step_due?: string | null; owner?: string | null; priority?: number | null;
  amount_requested?: number | null; decision_on?: string | null;
};
// Statuses where there is nothing left to apply for (pipeline tab in partners.html).
const DONE = new Set(["submitted", "awarded", "declined", "not_eligible", "skip"]);

function esc(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}
function fmtDate(d: string) {
  return new Date(`${d.slice(0, 10)}T12:00:00`).toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric", year: "numeric" });
}
function daysUntil(d: string, today: string) {
  return Math.round((Date.parse(`${d}T12:00:00Z`) - Date.parse(`${today}T12:00:00Z`)) / 86400000);
}
function item(r: Row, lead: string) {
  const name = r.url ? `<a href="${esc(r.url)}">${esc(r.funder)}</a>` : esc(r.funder);
  return `<li style="margin-bottom:10px;"><strong>${name}</strong>${r.program ? ` &middot; ${esc(r.program)}` : ""}
    ${lead ? `<br>${lead}` : ""}
    ${r.amount ? `<br><span style="font-size:0.9rem;">Amount: ${esc(r.amount)}</span>` : ""}
    ${r.notes ? `<br><span style="color:#5b6b7a;font-size:0.88rem;">${esc(r.notes)}</span>` : ""}</li>`;
}
function section(title: string, rows: string[]) {
  return rows.length ? `<h3 style="margin:20px 0 6px;">${title}</h3><ul style="padding-left:18px;">${rows.join("")}</ul>` : "";
}

Deno.serve(async (req) => {
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data, error } = await admin.from("fs_grant_deadlines").select("*").eq("active", true).order("deadline_date", { ascending: true, nullsFirst: false });
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  const all = (data ?? []) as Row[];
  const rows = all.filter((r) => !DONE.has(r.status ?? "to_research"));

  const today = new Date().toLocaleDateString("en-CA", { timeZone: "America/Chicago" });
  const dated = rows.filter((r) => r.kind === "dated" && r.deadline_date && daysUntil(r.deadline_date, today) >= 0);
  const closing = dated.map((r) => ({ r, d: daysUntil(r.deadline_date!, today) }));
  const soon = closing.filter((x) => x.d <= 60);
  const later = closing.filter((x) => x.d > 60);
  const expDate = (r: Row) => r.deadline_date ?? r.opens_date;
  const expected = rows.filter((r) => r.kind === "expected" && expDate(r) && daysUntil(expDate(r)!, today) >= 0)
    .sort((a, b) => expDate(a)!.localeCompare(expDate(b)!));
  const dueSteps = rows.filter((r) => r.next_step_due && daysUntil(r.next_step_due, today) <= 7)
    .sort((a, b) => a.next_step_due!.localeCompare(b.next_step_due!));
  const waiting = all.filter((r) => r.status === "submitted");
  const stepLead = (r: Row) => { const d = daysUntil(r.next_step_due!, today); return `<span style="color:${d < 0 ? "#a83a3a" : "#1f2d3d"};font-weight:600;">${esc(r.next_step ?? "Next step")} &middot; ${d < 0 ? "overdue since " : "due "}${fmtDate(r.next_step_due!)}${r.owner ? " (" + esc(r.owner) + ")" : ""}</span>`; };
  const waitLead = (r: Row) => `Submitted${r.amount_requested ? " for $" + Number(r.amount_requested).toLocaleString() : ""}${r.decision_on ? ", decision expected " + fmtDate(r.decision_on) : ""}`;
  const rolling = rows.filter((r) => r.kind === "rolling");
  const paused = rows.filter((r) => r.kind === "paused");
  const rel = rows.filter((r) => r.kind === "relationship");

  const lead = (x: { r: Row; d: number }) =>
    `<span style="color:${x.d <= 14 ? "#a83a3a" : "#1f2d3d"};font-weight:600;">Closes ${fmtDate(x.r.deadline_date!)} (${x.d === 0 ? "TODAY" : x.d + " day" + (x.d === 1 ? "" : "s")})</span>${x.r.verified ? "" : " <em>(date unverified)</em>"}`;
  const expLead = (r: Row) =>
    `Expected ${r.opens_date ? "to open ~" + fmtDate(r.opens_date) + (r.deadline_date ? ", " : "") : ""}${r.deadline_date ? "close ~" + fmtDate(r.deadline_date) : ""} <em>(estimate, confirm when posted)</em>`;

  const html = `
    <p>Your Sunday grant-deadline rundown for Full Spectrum at Rainbow Beach.</p>
    ${section("Your next steps (due this week or overdue)", dueSteps.map((r) => item(r, stepLead(r))))}
    ${section("Submitted, waiting on a decision", waiting.map((r) => item(r, waitLead(r))))}
    ${soon.length ? "" : `<p><strong>No confirmed deadlines in the next 60 days.</strong></p>`}
    ${section("Closing in the next 60 days", soon.map((x) => item(x.r, lead(x))))}
    ${section("Later confirmed dates", later.map((x) => item(x.r, lead(x))))}
    ${section("Expected windows (estimates, plan ahead)", expected.map((r) => item(r, expLead(r))))}
    ${section("Apply any time (rolling)", rolling.map((r) => item(r, "")))}
    ${section("Paused or closed: check back", paused.map((r) => item(r, "")))}
    ${section("Relationship outreach (no application)", rel.map((r) => item(r, "")))}
    <p style="margin:20px 0;"><a href="${TRACKER}" style="background:#2F3DB5;color:#fff;padding:10px 18px;border-radius:8px;text-decoration:none;display:inline-block;font-weight:600;">Open the Partner Tracker</a></p>
    <p style="color:#5b6b7a;font-size:0.8rem;">Sent automatically every Sunday morning. Dates marked unverified come from search results or last year&rsquo;s pattern; confirm on the funder&rsquo;s site before relying on them.</p>`;
  const subject = soon.length
    ? `Grant deadlines: ${soon[0].r.funder} closes in ${soon[0].d} day${soon[0].d === 1 ? "" : "s"}${soon.length > 1 ? ` (+${soon.length - 1} more)` : ""}`
    : "Grant deadlines: weekly rundown";

  if (req.headers.get("x-dry-run") === "1") {
    return new Response(JSON.stringify({ ok: true, sent: false, subject, to: TO, html }), { status: 200, headers: { "Content-Type": "application/json" } });
  }
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, subject, html }),
  });
  if (!res.ok) return new Response(JSON.stringify({ error: await res.text() }), { status: 502 });
  return new Response(JSON.stringify({ ok: true, sent: true, soon: soon.length }), { status: 200 });
});

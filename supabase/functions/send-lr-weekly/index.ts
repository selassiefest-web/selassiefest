// Monday-morning Live Reggae Rotation email to everyone on the lr_users
// roster: this week's lineup (date, venue, featured singer, deal), how many
// holds in the next 3 weeks still need a yes from the venue, played gigs not
// fully paid, and venue follow-ups due. Triggered by pg_cron with the shared
// x-webhook-secret header (see supabase/live-reggae-rotation.sql); reads via
// lr_weekly_digest(), which is service_role-only. Sends nothing when there's
// nothing to report.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("LR_WEEKLY_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Live Reggae Rotation <hello@selassiefest.com>";
const BOARD = "https://selassiefest.com/live-reggae/rotation.html";

const STATUS: Record<string, string> = { hold: "HOLD", offered: "Offered", confirmed: "Confirmed", played: "Played", cancelled: "Cancelled" };
const DEAL: Record<string, string> = { flat: "$1,200 flat", door: "Door split", guarantee_door: "Guarantee + door", bar: "Bar deal", hybrid: "Custom deal" };
const STAGES: Record<string, string> = {
  prospect: "Prospect", contacted: "Contacted", talking: "Talking", trial_booked: "Trial booked",
  in_rotation: "In rotation", paused: "Paused", declined: "Declined",
};

function esc(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}
function fmtDate(d: string) {
  return new Date(`${d.slice(0, 10)}T12:00:00`).toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric" });
}
function fmtTime(t: string | null) {
  if (!t) return "";
  const [h, m] = t.split(":").map(Number);
  return `${((h + 11) % 12) + 1}${m ? ":" + String(m).padStart(2, "0") : ""}${h < 12 ? "am" : "pm"}`;
}
const money = (n: number) => "$" + Number(n || 0).toLocaleString("en-US", { maximumFractionDigits: 0 });

Deno.serve(async (req) => {
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data, error } = await admin.rpc("lr_weekly_digest");
  if (error) return new Response(JSON.stringify({ error: error.message }), { status: 500 });

  const week = (data?.week ?? []) as any[];
  const unpaid = (data?.unpaid ?? []) as { date: string; venue: string; owed: number }[];
  const due = (data?.due ?? []) as { name: string; stage: string; next_step: string | null; due: string }[];
  const holds = Number(data?.holds_next ?? 0);
  const counts = (data?.counts ?? {}) as Record<string, number>;
  const to = (data?.to ?? []) as string[];
  if (!to.length) return new Response(JSON.stringify({ ok: true, sent: false, reason: "no roster" }), { status: 200 });
  if (!week.length && !unpaid.length && !due.length && !holds && req.headers.get("x-force") !== "1") {
    return new Response(JSON.stringify({ ok: true, sent: false, reason: "nothing to report" }), { status: 200 });
  }

  const today = new Date().toISOString().slice(0, 10);
  const weekHtml = week.length
    ? `<h3 style="margin:18px 0 6px;">This week's lineup</h3><ul style="padding-left:18px;">${week.map((g) => `
      <li style="margin-bottom:10px;"><strong>${esc(fmtDate(g.date))}${g.start ? " &middot; " + esc(fmtTime(g.start)) : ""}</strong> &middot; ${esc(g.venue)}${g.area ? ` <span style="color:#5b6b7a;">(${esc(g.area)})</span>` : ""}
      <br>Ifficial Reggae Movement${g.headliner ? " with <strong>" + esc(g.headliner) + "</strong>" : ""}${g.support ? " + " + esc(g.support) : ""}
      <br><span style="font-size:0.9rem;color:${g.status === "confirmed" || g.status === "played" ? "#1F7A3E" : "#a8620a"};">${esc(STATUS[g.status] ?? g.status)}</span>
      <span style="font-size:0.9rem;color:#5b6b7a;"> &middot; ${esc(DEAL[g.deal] ?? g.deal)}${g.fee ? " &middot; " + money(g.fee) : ""}</span>
      ${g.address ? `<br><span style="font-size:0.85rem;color:#5b6b7a;">${esc(g.address)}</span>` : ""}</li>`).join("")}</ul>`
    : `<p>No gigs on the calendar this week.</p>`;
  const holdsHtml = holds ? `<p><strong>${holds}</strong> night${holds === 1 ? " is" : "s are"} still on hold or offered in the next 3 weeks. Get a yes from the venue or release them.</p>` : "";
  const unpaidHtml = unpaid.length ? `<h3 style="margin:18px 0 6px;">Played, not fully paid</h3><ul style="padding-left:18px;">${unpaid.map((u) =>
      `<li>${esc(fmtDate(u.date))} &middot; ${esc(u.venue)} &middot; <strong>${money(u.owed)}</strong> owed</li>`).join("")}</ul>` : "";
  const dueHtml = due.length ? `<h3 style="margin:18px 0 6px;">Venue follow-ups</h3><ul style="padding-left:18px;">${due.map((r) => `
      <li style="margin-bottom:6px;"><strong>${esc(r.name)}</strong> &middot; ${esc(STAGES[r.stage] ?? r.stage)}
      <span style="color:${r.due < today ? "#a83a3a" : "#5b6b7a"};font-size:0.9rem;"> &middot; ${r.due < today ? "OVERDUE, was due" : "due"} ${fmtDate(r.due)}</span>
      ${r.next_step ? `<br><span style="font-size:0.9rem;">${esc(r.next_step)}</span>` : ""}</li>`).join("")}</ul>` : "";
  const order = ["prospect", "contacted", "talking", "trial_booked", "in_rotation", "paused", "declined"];
  const pipeline = order.filter((k) => counts[k]).map((k) => `${esc(STAGES[k])}: <strong>${counts[k]}</strong>`).join(" &middot; ");

  const html = `
    ${weekHtml}${holdsHtml}${unpaidHtml}${dueHtml}
    <h3 style="margin:18px 0 6px;">Venues</h3><p style="font-size:0.9rem;">${pipeline || "No venues yet."}</p>
    <p style="margin:20px 0;"><a href="${BOARD}" style="background:#1F7A3E;color:#fff;padding:10px 18px;border-radius:8px;text-decoration:none;display:inline-block;font-weight:600;">Open the Rotation board</a></p>
    <p style="color:#5b6b7a;font-size:0.8rem;">Sent automatically every Monday morning.</p>`;
  const confirmed = week.filter((g) => g.status === "confirmed").length;
  const subject = `Live reggae this week: ${week.length} night${week.length === 1 ? "" : "s"}${week.length ? ` (${confirmed} confirmed)` : ""}${unpaid.length ? `, ${unpaid.length} unpaid` : ""}`;

  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to, subject, html }),
  });
  if (!res.ok) return new Response(JSON.stringify({ error: await res.text() }), { status: 502 });
  return new Response(JSON.stringify({ ok: true, sent: true, week: week.length }), { status: 200 });
});

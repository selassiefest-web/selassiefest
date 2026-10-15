// Supabase Edge Function: rti-grant-deadlines
// The 2ND CH INC. grant-deadline tracker behind /rti/ai-lab/ (table ch_grant_deadlines).
//
//   { action: "list" | "save" | "delete", pass, row? }   From the page. Needs a
//       pass from rti-bgcheck-access (an active rti_members email).
//   { action: "weekly" }    Sunday rundown to Paul, cc Stephen.
//   { action: "reminder" }  Daily; sends only when a deadline is 7, 1 or 0 days out.
//       Both need the x-webhook-secret header (CH_GRANT_DIGEST_SECRET); add
//       x-dry-run: 1 to get the email back without sending.
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, CH_GRANT_DIGEST_SECRET.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const DIGEST_SECRET = Deno.env.get("CH_GRANT_DIGEST_SECRET") ?? "";

const FROM = "Ras Tafari Inc. <hello@selassiefest.com>";
const TO = ["paksipras@gmail.com"];
const CC = ["stephen@selassiefest.com"];
const PAGE = "https://selassiefest.com/rti/ai-lab/#deadlines";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const STATUSES = ["to_research", "preparing", "submitted", "awarded", "declined", "skip"];
const OPEN = new Set(["to_research", "preparing"]);
const REMIND_AT = new Set([7, 1, 0]);

type Row = {
  id: string; funder: string; program: string | null; url: string | null; opens_date: string | null;
  deadline_date: string | null; verified: boolean; status: string; notes: string | null; sort: number;
};

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}
async function sha256(text: string) {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}
// Same pass check as rti-bgcheck-access: unexpired session, still an active member
async function sessionFor(supabase: any, pass: string) {
  if (!/^[0-9a-f]{64}$/.test(pass)) return null;
  const { data: s } = await supabase.from("rti_bgcheck_sessions").select("*").eq("token_hash", await sha256(pass)).maybeSingle();
  if (!s || new Date(s.expires_at) < new Date()) return null;
  const { data: m } = await supabase.from("rti_members").select("active").eq("email", s.email).maybeSingle();
  return m?.active ? s : null;
}
const clean = (v: unknown, max = 500) => { const s = String(v ?? "").trim().slice(0, max); return s || null; };
const isDate = (v: unknown) => typeof v === "string" && /^\d{4}-\d{2}-\d{2}$/.test(v) ? v : null;
const isUrl = (v: unknown) => { const s = clean(v, 1000); return s && /^https?:\/\//i.test(s) ? s : null; };

function esc(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}
function fmtDate(d: string) {
  return new Date(`${d}T12:00:00`).toLocaleDateString("en-US", { weekday: "short", month: "short", day: "numeric", year: "numeric" });
}
function daysUntil(d: string, today: string) {
  return Math.round((Date.parse(`${d}T12:00:00Z`) - Date.parse(`${today}T12:00:00Z`)) / 86400000);
}
function item(r: Row, lead: string) {
  const name = r.url ? `<a href="${esc(r.url)}">${esc(r.funder)}</a>` : esc(r.funder);
  return `<li style="margin-bottom:10px;"><strong>${name}</strong>${r.program ? ` &middot; ${esc(r.program)}` : ""}
    ${lead ? `<br>${lead}` : ""}${r.notes ? `<br><span style="color:#5b6b7a;font-size:0.88rem;">${esc(r.notes)}</span>` : ""}</li>`;
}
const section = (title: string, rows: string[]) =>
  rows.length ? `<h3 style="margin:20px 0 6px;">${title}</h3><ul style="padding-left:18px;">${rows.join("")}</ul>` : "";
const closeLead = (r: Row, d: number) =>
  `<span style="color:${d <= 14 ? "#a83a3a" : "#1f2d3d"};font-weight:600;">Due ${fmtDate(r.deadline_date!)} (${d === 0 ? "TODAY" : d + " day" + (d === 1 ? "" : "s")})</span>${r.verified ? "" : " <em>(not yet confirmed on the funder's site)</em>"}`;

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);

  let body: Record<string, any>;
  try { body = JSON.parse((await req.text()) || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // ---- Emails (cron) ----
  if (body.action === "weekly" || body.action === "reminder") {
    if (!DIGEST_SECRET || req.headers.get("x-webhook-secret") !== DIGEST_SECRET) return new Response("Unauthorized", { status: 401 });
    const { data, error } = await supabase.from("ch_grant_deadlines").select("*").order("deadline_date", { ascending: true, nullsFirst: false }).order("sort");
    if (error) return reply({ ok: false, error: error.message }, 500);
    const rows = (data ?? []) as Row[];
    const today = new Date().toLocaleDateString("en-CA", { timeZone: "America/Chicago" });
    const open = rows.filter((r) => OPEN.has(r.status));
    const dated = open.filter((r) => r.deadline_date && daysUntil(r.deadline_date, today) >= 0)
      .map((r) => ({ r, d: daysUntil(r.deadline_date!, today) }));

    let subject: string, html: string;
    if (body.action === "reminder") {
      const due = dated.filter((x) => REMIND_AT.has(x.d));
      if (!due.length) return reply({ ok: true, sent: false, reason: "nothing at 7, 1 or 0 days" });
      const first = due[0];
      subject = `Reminder: ${first.r.funder} application due ${first.d === 0 ? "TODAY" : first.d === 1 ? "tomorrow" : "in 7 days"}${due.length > 1 ? ` (+${due.length - 1} more)` : ""}`;
      html = `<p>Paul, a 2ND CH INC. grant deadline is coming up.</p>
        ${section("Due soon", due.map((x) => item(x.r, closeLead(x.r, x.d))))}
        <p><a href="${PAGE}">Open the deadline tracker</a></p>`;
    } else {
      const soon = dated.filter((x) => x.d <= 60), later = dated.filter((x) => x.d > 60);
      const noDate = open.filter((r) => !r.deadline_date);
      const opensSoon = open.filter((r) => r.opens_date && !r.deadline_date && daysUntil(r.opens_date, today) >= 0);
      const missed = open.filter((r) => r.deadline_date && daysUntil(r.deadline_date, today) < 0);
      const waiting = rows.filter((r) => r.status === "submitted");
      subject = soon.length
        ? `2ND CH INC. grant deadlines: ${soon[0].r.funder} due in ${soon[0].d} day${soon[0].d === 1 ? "" : "s"}${soon.length > 1 ? ` (+${soon.length - 1} more)` : ""}`
        : "2ND CH INC. grant deadlines: weekly rundown";
      html = `<p>Paul, here is your Sunday rundown of 2ND CH INC. grant deadlines.</p>
        ${soon.length ? "" : "<p><strong>No deadlines in the next 60 days.</strong></p>"}
        ${section("Due in the next 60 days", soon.map((x) => item(x.r, closeLead(x.r, x.d))))}
        ${section("Later deadlines", later.map((x) => item(x.r, closeLead(x.r, x.d))))}
        ${section("Opening soon", opensSoon.map((r) => item(r, `Expected to open ${fmtDate(r.opens_date!)}`)))}
        ${section("No date yet: find it this week", noDate.filter((r) => !r.opens_date).map((r) => item(r, "")))}
        ${section("Deadline passed: update the status", missed.map((r) => item(r, `Was due ${fmtDate(r.deadline_date!)}`)))}
        ${section("Submitted, waiting on a decision", waiting.map((r) => item(r, "")))}
        <p style="margin:20px 0;"><a href="${PAGE}" style="background:#1f5f45;color:#fff;padding:10px 18px;border-radius:8px;text-decoration:none;display:inline-block;font-weight:600;">Open the deadline tracker</a></p>
        <p style="color:#5b6b7a;font-size:0.8rem;">Sent every Sunday morning, plus a reminder 7 days and 1 day before each deadline. Only trust a date you confirmed on the funder's own website.</p>`;
    }
    if (req.headers.get("x-dry-run") === "1") return reply({ ok: true, sent: false, subject, to: TO, cc: CC, html });
    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: FROM, to: TO, cc: CC, subject, html }),
    });
    if (!res.ok) return reply({ ok: false, error: (await res.text()).slice(0, 300) }, 502);
    return reply({ ok: true, sent: true, subject });
  }

  // ---- Tracker (page) ----
  const session = await sessionFor(supabase, String(body.pass ?? ""));
  if (!session) return reply({ ok: false, relogin: true, error: "Your sign-in expired. Sign in again with your email." }, 401);

  if (body.action === "list") {
    const { data, error } = await supabase.from("ch_grant_deadlines").select("*").order("sort").order("created_at");
    if (error) return reply({ ok: false, error: "Couldn't load the deadlines." }, 500);
    return reply({ ok: true, rows: data });
  }

  if (body.action === "save") {
    const r = body.row ?? {};
    const funder = clean(r.funder, 200);
    if (!funder) return reply({ ok: false, error: "Give the funder a name." }, 400);
    const row = {
      funder, program: clean(r.program, 300), url: isUrl(r.url), opens_date: isDate(r.opens_date), deadline_date: isDate(r.deadline_date),
      verified: r.verified === true, status: STATUSES.includes(r.status) ? r.status : "to_research", notes: clean(r.notes, 1000),
      updated_by: session.email, updated_at: new Date().toISOString(),
    };
    const q = r.id
      ? supabase.from("ch_grant_deadlines").update(row).eq("id", String(r.id)).select().single()
      : supabase.from("ch_grant_deadlines").insert(row).select().single();
    const { data, error } = await q;
    if (error) return reply({ ok: false, error: "Couldn't save just now." }, 500);
    return reply({ ok: true, row: data });
  }

  if (body.action === "delete") {
    const { error } = await supabase.from("ch_grant_deadlines").delete().eq("id", String(body.id ?? ""));
    if (error) return reply({ ok: false, error: "Couldn't remove it." }, 500);
    return reply({ ok: true });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});

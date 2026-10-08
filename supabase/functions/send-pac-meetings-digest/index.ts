// Sunday-morning email listing upcoming Park Advisory Council meetings for
// the PACs we belong to (pac_councils), to Stephen, Paksipras and
// peopleofthesun1@prodigy.net. Not called
// from any client-side code -- pg_cron calls it via net.http_post with the
// x-webhook-secret header, same pattern as send-bbpac-tracker-deadline-
// reminders. See supabase/pac-meetings-digest.sql for the tables and the
// cron jobs.
//
// Dates come from two places: each council's regular schedule (e.g. "2nd
// Monday, 7 pm"), expanded here month by month, and one-off pac_meetings
// rows, which add a meeting or -- on the same council and date -- replace
// or cancel the regular one. Confirmed-or-tentative SSCC bylaws committee
// meetings (sscc_bylaws_meetings) are folded in under SSCC.
//
// Body: {} or {"mode":"scheduled"} sends only when it is 8 am Sunday in
// Chicago (cron fires at both 13:00 and 14:00 UTC so DST doesn't matter);
// {"mode":"test"} sends right away.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("PAC_DIGEST_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "PAC Meetings <hello@selassiefest.com>";
const TO = ["stephen@selassiefest.com", "paksipras@gmail.com", "peopleofthesun1@prodigy.net"];
const REPLY_TO = "stephen@selassiefest.com";
const TZ = "America/Chicago";
const WINDOW_DAYS = 42;

type Council = {
  slug: string;
  name: string;
  short_name: string;
  sort: number;
  schedule_label: string | null;
  rule_weekday: number | null; // 0 = Sunday
  rule_nth: number | null; // 1-5, or -1 for the last one in the month
  rule_time_label: string | null;
  skip_months: number[] | null; // 1-12
  location: string | null;
  url: string | null;
  contact: string | null;
  notes: string | null;
};

type MeetingRow = {
  council_slug: string;
  meets_on: string;
  time_label: string | null;
  title: string | null;
  location: string | null;
  notes: string | null;
  url: string | null;
  status: "scheduled" | "tentative" | "canceled";
};

type Item = {
  council: Council;
  date: string;
  time: string;
  title: string;
  location: string;
  notes: string;
  url: string;
  status: "scheduled" | "tentative" | "regular";
};

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

function safeUrl(u: unknown) {
  const s = String(u ?? "");
  return /^https?:\/\//i.test(s) ? s : "";
}

function chicagoNow() {
  const parts = Object.fromEntries(
    new Intl.DateTimeFormat("en-US", { timeZone: TZ, year: "numeric", month: "2-digit", day: "2-digit", hour: "2-digit", hourCycle: "h23", weekday: "short" })
      .formatToParts(new Date())
      .map((p) => [p.type, p.value]),
  );
  return { date: `${parts.year}-${parts.month}-${parts.day}`, hour: Number(parts.hour), weekday: parts.weekday };
}

// Plain calendar-date arithmetic in UTC, so no time zone shifts the day.
function addDays(iso: string, n: number) {
  const d = new Date(iso + "T00:00:00Z");
  d.setUTCDate(d.getUTCDate() + n);
  return d.toISOString().slice(0, 10);
}

function nthWeekday(year: number, month: number, weekday: number, nth: number): string | null {
  if (nth === -1) {
    const last = new Date(Date.UTC(year, month, 0));
    last.setUTCDate(last.getUTCDate() - ((last.getUTCDay() - weekday + 7) % 7));
    return last.toISOString().slice(0, 10);
  }
  const first = new Date(Date.UTC(year, month - 1, 1));
  const day = 1 + ((weekday - first.getUTCDay() + 7) % 7) + (nth - 1) * 7;
  const d = new Date(Date.UTC(year, month - 1, day));
  return d.getUTCMonth() === month - 1 ? d.toISOString().slice(0, 10) : null;
}

function regularDates(c: Council, from: string, to: string): string[] {
  if (c.rule_weekday == null || c.rule_nth == null) return [];
  const out: string[] = [];
  let y = Number(from.slice(0, 4));
  let m = Number(from.slice(5, 7));
  for (let i = 0; i < 4; i++) {
    if (!(c.skip_months || []).includes(m)) {
      const d = nthWeekday(y, m, c.rule_weekday, c.rule_nth);
      if (d && d >= from && d <= to) out.push(d);
    }
    m++;
    if (m > 12) { m = 1; y++; }
  }
  return out;
}

function longDate(iso: string) {
  return new Date(iso + "T12:00:00Z").toLocaleDateString("en-US", { timeZone: "UTC", weekday: "short", month: "short", day: "numeric" });
}

function badge(status: Item["status"]) {
  if (status === "tentative") return ` <span style="font-size:11px;color:#8a5a00;background:#fff4d6;border-radius:3px;padding:1px 5px;">tentative</span>`;
  if (status === "regular") return ` <span style="font-size:11px;color:#555;background:#eef0ee;border-radius:3px;padding:1px 5px;">regular schedule</span>`;
  return "";
}

function renderRows(items: Item[], empty: string) {
  if (!items.length) return `<p style="color:#71786f;font-size:13px;margin:4px 0 0;">${empty}</p>`;
  return `<table style="border-collapse:collapse;width:100%;">${items.map((it) => {
    const url = safeUrl(it.url) || safeUrl(it.council.url);
    const name = url ? `<a href="${escapeHtml(url)}" style="color:#1f5f3a;">${escapeHtml(it.council.name)}</a>` : escapeHtml(it.council.name);
    return `
      <tr>
        <td style="padding:8px 10px;border-bottom:1px solid #eee;vertical-align:top;white-space:nowrap;font-weight:600;">${escapeHtml(longDate(it.date))}<div style="font-weight:400;font-size:12px;color:#444;">${escapeHtml(it.time)}</div></td>
        <td style="padding:8px 10px;border-bottom:1px solid #eee;vertical-align:top;">
          <div style="font-size:14px;font-weight:600;">${name}${badge(it.status)}</div>
          ${it.title ? `<div style="font-size:13px;">${escapeHtml(it.title)}</div>` : ""}
          ${it.location ? `<div style="font-size:13px;color:#444;">${escapeHtml(it.location)}</div>` : ""}
          ${it.notes ? `<div style="font-size:12px;color:#71786f;margin-top:2px;">${escapeHtml(it.notes)}</div>` : ""}
        </td>
      </tr>`;
  }).join("")}</table>`;
}

Deno.serve(async (req: Request) => {
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405 });
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) return new Response("Unauthorized", { status: 401 });

  const body = await req.json().catch(() => ({}));
  const now = chicagoNow();
  if (body.mode !== "test" && (now.weekday !== "Sun" || now.hour !== 8)) {
    return new Response(JSON.stringify({ skipped: true, reason: "not 8 am Sunday in Chicago", now }), { status: 200 });
  }

  const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const today = now.date;
  const end = addDays(today, WINDOW_DAYS);

  const [{ data: councils, error: e1 }, { data: rows, error: e2 }, { data: sscc, error: e3 }] = await Promise.all([
    supabase.from("pac_councils").select("*").eq("active", true).order("sort"),
    supabase.from("pac_meetings").select("*").gte("meets_on", today).lte("meets_on", end),
    supabase.from("sscc_bylaws_meetings").select("meets_on, time_label, location, title, agenda, confirmed, kind").eq("kind", "meeting").gte("meets_on", today).lte("meets_on", end),
  ]);
  if (e1 || e2) return new Response(JSON.stringify({ error: (e1 || e2)!.message }), { status: 500 });
  if (e3) console.error("sscc_bylaws_meetings read failed:", e3.message);

  const bySlug = new Map((councils as Council[]).map((c) => [c.slug, c]));
  const overrides = new Map((rows as MeetingRow[]).map((r) => [`${r.council_slug}|${r.meets_on}`, r]));
  const items: Item[] = [];

  for (const c of councils as Council[]) {
    for (const d of regularDates(c, today, end)) {
      if (overrides.has(`${c.slug}|${d}`)) continue;
      items.push({ council: c, date: d, time: c.rule_time_label || "", title: "Regular meeting", location: c.location || "", notes: "", url: "", status: "regular" });
    }
  }
  for (const r of rows as MeetingRow[]) {
    const c = bySlug.get(r.council_slug);
    if (!c || r.status === "canceled") continue;
    items.push({
      council: c, date: r.meets_on, time: r.time_label || c.rule_time_label || "", title: r.title || "Meeting",
      location: r.location || c.location || "", notes: r.notes || "", url: r.url || "", status: r.status,
    });
  }
  const ssccCouncil = bySlug.get("sscc");
  if (ssccCouncil) {
    for (const m of (sscc || []) as any[]) {
      items.push({
        council: ssccCouncil, date: m.meets_on, time: m.time_label || "Time TBD", title: `By-laws Review Committee: ${m.title}`,
        location: m.location || "", notes: m.confirmed ? "" : "Not yet confirmed by the coordinator.", url: "https://selassiefest.com/sscc-bylaws/",
        status: m.confirmed ? "scheduled" : "tentative",
      });
    }
  }
  items.sort((a, b) => a.date.localeCompare(b.date) || a.council.sort - b.council.sort);

  const weekEnd = addDays(today, 7);
  const thisWeek = items.filter((i) => i.date <= weekEnd);
  const later = items.filter((i) => i.date > weekEnd);
  const noDates = (councils as Council[]).filter((c) => !items.some((i) => i.council.slug === c.slug));

  const councilList = (councils as Council[]).map((c) => `
    <li style="margin-bottom:6px;"><strong>${escapeHtml(c.name)}</strong> &mdash; ${escapeHtml(c.schedule_label || "No regular schedule on file")}${c.location ? `, ${escapeHtml(c.location)}` : ""}
      ${c.contact ? `<br><span style="color:#71786f;">${escapeHtml(c.contact)}</span>` : ""}
      ${c.notes ? `<br><span style="color:#71786f;">${escapeHtml(c.notes)}</span>` : ""}</li>`).join("");

  const html = `
    <div style="font-family:Arial,sans-serif;color:#1a1e1b;max-width:720px;">
      <h2 style="margin-bottom:4px;">Upcoming PAC meetings</h2>
      <p style="color:#71786f;font-size:13px;margin-top:0;">Week of ${escapeHtml(longDate(today))} &middot; next ${WINDOW_DAYS / 7} weeks</p>
      <h3 style="margin:20px 0 4px;color:#1f5f3a;">This week</h3>
      ${renderRows(thisWeek, "No PAC meetings in the next 7 days.")}
      <h3 style="margin:24px 0 4px;color:#1f5f3a;">Coming up</h3>
      ${renderRows(later, "Nothing else on the calendar yet.")}
      ${noDates.length ? `<p style="font-size:13px;margin-top:16px;"><strong>No date posted yet:</strong> ${noDates.map((c) => escapeHtml(c.name)).join(", ")}</p>` : ""}
      <p style="font-size:12px;color:#71786f;margin-top:12px;">"Regular schedule" dates come from each council's usual pattern and haven't been confirmed for that month &mdash; check the council's page or contact before going, especially around holidays.</p>
      <h3 style="margin:24px 0 4px;color:#1f5f3a;">Our councils</h3>
      <ul style="font-size:13px;padding-left:18px;">${councilList}</ul>
    </div>`;

  if (!RESEND_API_KEY) return new Response(JSON.stringify({ error: "RESEND_API_KEY not set" }), { status: 500 });
  const subject = `${body.mode === "test" ? "[Test] " : ""}PAC meetings — ${thisWeek.length} this week, ${later.length} coming up`;
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, reply_to: REPLY_TO, subject, html }),
  });
  if (!res.ok) {
    const err = await res.text();
    console.error("Resend send failed:", res.status, err);
    return new Response(JSON.stringify({ error: err }), { status: 502 });
  }
  return new Response(JSON.stringify({ sent: true, thisWeek: thisWeek.length, later: later.length }), { status: 200 });
});

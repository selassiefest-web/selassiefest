// Daily digest of Opportunity Tracker deadlines 1 week, 2 days and 1 day
// out, emailed to Stephen. Not called from any client-side code --
// triggered on a schedule via pg_cron calling net.http_post with the shared
// x-webhook-secret header, same pattern as send-deadline-reminders. Reads
// via bbpac_tracker_deadlines_due_for_reminder() (see
// supabase/bbpac-tracker-deadline-reminders-schema.sql), service_role-only.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("BBPAC_TRACKER_REMINDER_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Bongo Beach PAC <hello@selassiefest.com>";
const TO = "stephen@selassiefest.com";

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

type DeadlineRow = {
  id: string;
  title: string;
  link: string | null;
  deadline_date: string;
  lead_days: number;
  date_basis: string | null;
  why: string | null;
};

function badgeFor(leadDays: number) {
  if (leadDays === 7) return "1 week away";
  if (leadDays === 2) return "2 days away";
  return "1 day away";
}

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data, error } = await admin.rpc("bbpac_tracker_deadlines_due_for_reminder");
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  const rows = (data ?? []) as DeadlineRow[];
  if (rows.length === 0) {
    return new Response(JSON.stringify({ ok: true, sent: false, reason: "nothing due" }), { status: 200 });
  }

  const itemsHtml = rows
    .map((r) => {
      const flag = r.date_basis && r.date_basis !== "Confirmed"
        ? ` <strong style="color:#a83a3a;">(${escapeHtml(r.date_basis).toUpperCase()} — confirm this date)</strong>`
        : "";
      const dateStr = new Date(`${r.deadline_date}T00:00:00`).toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      });
      return `
        <li style="margin-bottom:14px;">
          <strong>${escapeHtml(r.title)}</strong>${flag}
          <br><span style="color:#5b6b7a;font-size:0.85rem;">${dateStr} &middot; ${badgeFor(r.lead_days)}</span>
          ${r.why ? `<br><span style="font-size:0.9rem;">${escapeHtml(r.why)}</span>` : ""}
          ${r.link ? `<br><a href="${escapeHtml(r.link)}" style="font-size:0.85rem;">${escapeHtml(r.link)}</a>` : ""}
        </li>`;
    })
    .join("");

  const subject = rows.length === 1 ? `Opportunity Tracker: ${rows[0].title}` : `${rows.length} Opportunity Tracker deadlines coming up`;

  const html = `
    <p>Here's what's coming up on the Opportunity Tracker's deadline calendar:</p>
    <ul style="padding-left:18px;">${itemsHtml}</ul>
    <p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically — 1-week, 2-day and 1-day reminders, from
      <a href="https://selassiefest.com/bbpac/organization/opportunity-tracker.html">the Opportunity Tracker</a>.</p>
  `;

  const resendRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, subject, html }),
  });

  if (!resendRes.ok) {
    return new Response(JSON.stringify({ error: await resendRes.text() }), { status: 502 });
  }

  return new Response(JSON.stringify({ ok: true, sent: true, count: rows.length }), { status: 200 });
});

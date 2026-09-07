// Daily digest of upcoming deadlines (2 weeks and 1 week out) emailed to
// selassiefest@gmail.com. Not called from any client-side code -- triggered
// on a schedule via pg_cron calling net.http_post with the shared
// x-webhook-secret header, same pattern as
// notify-stale-items/sync-notion-dancehall. Reads via
// deadlines_due_for_reminder() (see supabase/schema.sql), service_role-only.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("DEADLINE_REMINDER_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "SelassieFest <hello@selassiefest.com>";
const TO = "selassiefest@gmail.com";

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

type DeadlineRow = {
  id: string;
  title: string;
  description: string | null;
  due_date: string;
  category: string;
  source_url: string | null;
  confirmed: boolean;
  lead_days: number;
};

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
  const { data, error } = await admin.rpc("deadlines_due_for_reminder");
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  const rows = (data ?? []) as DeadlineRow[];
  if (rows.length === 0) {
    return new Response(JSON.stringify({ ok: true, sent: false, reason: "nothing due" }), { status: 200 });
  }

  const itemsHtml = rows
    .map((r) => {
      const badge = r.lead_days === 14 ? "2 weeks away" : "1 week away";
      const flag = r.confirmed
        ? ""
        : ' <strong style="color:#a83a3a;">(ESTIMATED — confirm this date)</strong>';
      const dateStr = new Date(`${r.due_date}T00:00:00`).toLocaleDateString("en-US", {
        weekday: "long",
        year: "numeric",
        month: "long",
        day: "numeric",
      });
      return `
        <li style="margin-bottom:14px;">
          <strong>${escapeHtml(r.title)}</strong>${flag}
          <br><span style="color:#5b6b7a;font-size:0.85rem;">${dateStr} &middot; ${badge}</span>
          ${r.description ? `<br><span style="font-size:0.9rem;">${escapeHtml(r.description)}</span>` : ""}
          ${r.source_url ? `<br><a href="${escapeHtml(r.source_url)}" style="font-size:0.85rem;">${escapeHtml(r.source_url)}</a>` : ""}
        </li>`;
    })
    .join("");

  const subject = rows.length === 1 ? `Upcoming: ${rows[0].title}` : `${rows.length} upcoming deadlines this week`;

  const html = `
    <p>Here's what's coming up:</p>
    <ul style="padding-left:18px;">${itemsHtml}</ul>
    <p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically — 2-week and 1-week reminders, from the deadlines calendar in the SelassieFest Supabase project.</p>
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

// Weekly "come back to this" reminder -- not a hand-off between two people
// (the person who'd know CPD called back is the same one who made the
// call), just a scheduled nudge to your own future self for open-loop items
// that nothing else ever forces back into view. Not called from any
// client-side code; triggered on a schedule via pg_cron calling net.http_post
// with the shared x-webhook-secret header, same pattern as
// sync-notion-dancehall/notify-submission. Reads via
// bbpac_formation_stale_items_for_digest() (see supabase/schema.sql),
// service_role-only since it returns other members' emails.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("STALE_ITEM_NUDGE_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "SelassieFest <hello@selassiefest.com>";
const REPLY_TO = "stephen@selassiefest.com";
const STALE_DAYS = 7;

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

type StaleRow = {
  member_id: string;
  member_name: string;
  member_email: string;
  item_no: number;
  item_label: string;
  section_no: number;
  section_title: string;
  days_stale: number;
};

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }

  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const { data, error } = await admin.rpc("bbpac_formation_stale_items_for_digest", { p_stale_days: STALE_DAYS });
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 });
  }

  const rows = (data ?? []) as StaleRow[];
  const byMember = new Map<string, StaleRow[]>();
  for (const row of rows) {
    const list = byMember.get(row.member_email) ?? [];
    list.push(row);
    byMember.set(row.member_email, list);
  }

  let sent = 0;
  const failures: string[] = [];

  for (const [email, items] of byMember) {
    const name = items[0].member_name;
    const itemsHtml = items
      .map((it) => `
        <li style="margin-bottom:10px;">
          <a href="https://selassiefest.com/bbpac/organization/my-section.html#owned-item-${it.item_no}">
            #${it.item_no} ${escapeHtml(it.item_label)}
          </a>
          <br><span style="color:#5b6b7a;font-size:0.85rem;">Section ${it.section_no}: ${escapeHtml(it.section_title)} &middot; quiet for ${it.days_stale} days</span>
        </li>`)
      .join("");

    const subject = items.length === 1
      ? `Still open: #${items[0].item_no} ${items[0].item_label}`
      : `${items.length} items you started haven't moved in a while`;

    const html = `
      <p>Hi ${escapeHtml(name)},</p>
      <p>These are still marked in progress in your section(s), and nothing's been logged on them in over a week -- easy to lose track of, especially the ones waiting on a callback. Here's exactly where you left off:</p>
      <ul style="padding-left:18px;">${itemsHtml}</ul>
      <p>Each link opens straight to the item, already expanded. If one's actually done or no longer relevant, a quick log entry (or marking it complete) will stop it showing up here.</p>
      <p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically, weekly, by the Bongo Beach formation tracking system.</p>
    `;

    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: FROM, to: email, reply_to: REPLY_TO, subject, html }),
    });

    if (resendRes.ok) {
      sent++;
    } else {
      failures.push(`${email}: ${await resendRes.text()}`);
    }
  }

  return new Response(JSON.stringify({ ok: true, members_notified: sent, item_count: rows.length, failures }), { status: 200 });
});

// Approve or reject a matrix item that a section worker/head submitted for
// review. This is the ONLY path that can ever move review_status to
// approved/rejected or progress_status to complete/reviewed_no_change --
// the bbpac_formation_guard_item_review_transition trigger blocks those
// same writes from a direct authenticated client update, so this function
// running as service_role is structurally required, not just convention.
//
// Approver pool is sitewide and section-agnostic (any member with
// is_approver = true, set via set-approver-optin) -- by design, so one
// person's absence never blocks the whole matrix. Self-review is blocked:
// whoever submitted an item can never be the one who approves or rejects
// it, regardless of role.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "SelassieFest <hello@selassiefest.com>";
const REPLY_TO = "stephen@selassiefest.com";

const ALLOWED_ORIGINS = ["https://selassiefest.com", "http://localhost:8000"];

function corsHeaders(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
}

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

Deno.serve(async (req) => {
  const cors = corsHeaders(req);
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: cors });
  const jsonHeaders = { ...cors, "Content-Type": "application/json" };

  const authHeader = req.headers.get("Authorization");
  if (!authHeader) {
    return new Response(JSON.stringify({ error: "Missing Authorization header -- log in first." }), { status: 401, headers: jsonHeaders });
  }

  const callerClient = createClient(SUPABASE_URL, ANON_KEY, { global: { headers: { Authorization: authHeader } } });
  const { data: userData, error: userErr } = await callerClient.auth.getUser();
  if (userErr || !userData?.user) {
    return new Response(JSON.stringify({ error: "Not logged in." }), { status: 401, headers: jsonHeaders });
  }

  let body;
  try {
    body = await req.json();
  } catch {
    return new Response(JSON.stringify({ error: "Invalid JSON body." }), { status: 400, headers: jsonHeaders });
  }
  const { item_no, action } = body;
  const note = (body.note || "").toString().trim();
  if (!item_no || !["approve", "reject"].includes(action)) {
    return new Response(JSON.stringify({ error: "Missing or invalid item_no/action." }), { status: 400, headers: jsonHeaders });
  }
  if (action === "reject" && !note) {
    return new Response(JSON.stringify({ error: "A note is required when sending an item back." }), { status: 400, headers: jsonHeaders });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: caller } = await admin
    .from("bbpac_formation_members")
    .select("id, name, is_approver")
    .eq("auth_user_id", userData.user.id)
    .maybeSingle();
  if (!caller) {
    return new Response(JSON.stringify({ error: "You are not a registered member." }), { status: 403, headers: jsonHeaders });
  }
  if (!caller.is_approver) {
    return new Response(JSON.stringify({ error: "You are not currently opted in as an approver." }), { status: 403, headers: jsonHeaders });
  }

  const { data: item } = await admin
    .from("bbpac_formation_matrix_items")
    .select("item_no, item_label, section_no, section_title, review_status, proposed_status, submitted_by")
    .eq("item_no", item_no)
    .maybeSingle();
  if (!item) {
    return new Response(JSON.stringify({ error: "Item not found." }), { status: 404, headers: jsonHeaders });
  }
  if (item.review_status !== "pending_review") {
    return new Response(JSON.stringify({ error: "This item is not currently awaiting review." }), { status: 409, headers: jsonHeaders });
  }
  if (item.submitted_by === caller.id) {
    return new Response(JSON.stringify({ error: "You can't review your own submission -- ask another approver." }), { status: 403, headers: jsonHeaders });
  }

  const update: Record<string, unknown> = {
    reviewed_by: caller.id,
    reviewed_at: new Date().toISOString(),
  };
  if (action === "approve") {
    update.review_status = "approved";
    update.review_note = null;
    update.progress_status = item.proposed_status || "complete";
  } else {
    update.review_status = "rejected";
    update.review_note = note;
  }

  const { error: updateErr } = await admin
    .from("bbpac_formation_matrix_items")
    .update(update)
    .eq("item_no", item_no);
  if (updateErr) {
    return new Response(JSON.stringify({ error: updateErr.message }), { status: 500, headers: jsonHeaders });
  }

  if (item.submitted_by && RESEND_API_KEY) {
    const { data: submitter } = await admin
      .from("bbpac_formation_members")
      .select("name, email")
      .eq("id", item.submitted_by)
      .maybeSingle();
    if (submitter?.email) {
      const subject = action === "approve"
        ? `Approved: #${item.item_no} ${item.item_label}`
        : `Sent back for revision: #${item.item_no} ${item.item_label}`;
      const html = action === "approve"
        ? `<p>Hi ${escapeHtml(submitter.name)},</p><p><strong>${escapeHtml(caller.name)}</strong> approved your update to #${item.item_no} ${escapeHtml(item.item_label)} (Section ${item.section_no}: ${escapeHtml(item.section_title)}). It's now marked <strong>${escapeHtml(update.progress_status as string)}</strong>.</p><p><a href="https://selassiefest.com/bbpac/organization/my-section.html">View it in My Section</a></p>`
        : `<p>Hi ${escapeHtml(submitter.name)},</p><p><strong>${escapeHtml(caller.name)}</strong> sent your update to #${item.item_no} ${escapeHtml(item.item_label)} back for revision:</p><blockquote style="border-left:3px solid #DC8311; margin:10px 0; padding:6px 14px; color:#4a3a1e;">${escapeHtml(note)}</blockquote><p>Revise it and resubmit whenever you're ready.</p><p><a href="https://selassiefest.com/bbpac/organization/my-section.html">View it in My Section</a></p>`;
      await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify({ from: FROM, to: submitter.email, reply_to: REPLY_TO, subject, html }),
      }).catch(() => {}); // best-effort -- a failed email should never fail the review itself
    }
  }

  return new Response(JSON.stringify({ ok: true, action }), { status: 200, headers: jsonHeaders });
});

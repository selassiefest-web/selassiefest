// Called from My Section (bbpac/organization/my-section.html) when a
// logged-in section owner clicks "Notify" next to an internal blocker --
// "Stanley is awaiting action from you" made real, not just something
// visible if the blocked-on person happens to check their own dashboard.
//
// Authenticated by the CALLER's own user JWT (not the shared WEBHOOK_SECRET
// pattern used by notify-submission, since this fires from a live logged-in
// user action, not a database trigger). The service role is used only for
// the two privileged lookups this needs -- resolving the caller's own
// member row and the target member's email, neither of which is public --
// exactly what Edge Functions' auto-injected service role key is for.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "SelassieFest <hello@selassiefest.com>";
const REPLY_TO = "stephen@selassiefest.com";

const ALLOWED_ORIGINS = ["https://selassiefest.com", "http://localhost:8000"];

function corsHeaders(req) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
  };
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

  // Scoped to the caller's own JWT -- getUser() returns null for the bare
  // anon key, which is exactly the case this is meant to reject.
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

  const { to_member_id, item_no, item_label, blocking_item_no, blocking_item_label } = body;
  if (!to_member_id || !item_no || !blocking_item_no) {
    return new Response(JSON.stringify({ error: "Missing to_member_id, item_no, or blocking_item_no." }), { status: 400, headers: jsonHeaders });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: fromMember } = await admin
    .from("bbpac_formation_members")
    .select("id, name")
    .eq("auth_user_id", userData.user.id)
    .maybeSingle();
  if (!fromMember) {
    return new Response(JSON.stringify({ error: "You are not a registered section owner." }), { status: 403, headers: jsonHeaders });
  }

  const { data: toMember } = await admin
    .from("bbpac_formation_members")
    .select("id, name, email")
    .eq("id", to_member_id)
    .maybeSingle();
  if (!toMember) {
    return new Response(JSON.stringify({ error: "Target member not found." }), { status: 404, headers: jsonHeaders });
  }

  const subject = `Bongo Beach Formation: ${fromMember.name} is waiting on you`;
  const html = `
    <p><strong>${escapeHtml(fromMember.name)}</strong> is waiting on you to move item
    <strong>#${blocking_item_no} ${escapeHtml(blocking_item_label || "")}</strong> forward, so they can progress
    <strong>#${item_no} ${escapeHtml(item_label || "")}</strong> in their own section.</p>
    <p>Log in at the <a href="https://selassiefest.com/bbpac/organization/my-section.html">My Section</a>
    workspace to see the full status, or open the public
    <a href="https://selassiefest.com/bbpac/organization/matrix.html">Master Due-Diligence Matrix</a>
    (item #${blocking_item_no}) for context.</p>
    <p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically by the Bongo Beach formation tracking system.</p>
  `;

  const resendRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: toMember.email, reply_to: REPLY_TO, subject, html }),
  });

  if (!resendRes.ok) {
    const errText = await resendRes.text();
    return new Response(JSON.stringify({ error: `Email send failed: ${errText}` }), { status: 502, headers: jsonHeaders });
  }

  await admin.from("bbpac_formation_notifications").insert({
    from_member_id: fromMember.id,
    to_member_id: toMember.id,
    item_no,
    blocking_item_no,
    reason_type: "internal_dependency",
  });

  return new Response(JSON.stringify({ ok: true, notified: toMember.name }), { status: 200, headers: jsonHeaders });
});

function escapeHtml(s) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);
}

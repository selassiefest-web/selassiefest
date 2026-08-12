// Approve or decline a Join a Section request (bbpac_formation_section_signup_requests).
// Approving creates the bbpac_formation_members row for this email if one
// doesn't exist yet, and adds a bbpac_formation_section_owners row for each
// granted section. This used to be a manual "add rows via the Table Editor"
// step (see notify-submission's formatter); this function is now the only
// path that does it, running as service_role since neither table grants
// authenticated clients direct insert.
//
// Deliberately does NOT send the decision email itself -- that's the job of
// the bbpac_formation_notify_section_request_decision AFTER UPDATE trigger
// (see notify-section-request-decision), which fires on this function's own
// status write same as it would on a manual Table Editor edit. Sending it
// here too would double-email the applicant on every approve/decline; one
// path (the trigger) that fires no matter how status changed is simpler and
// more robust than two paths that have to be kept in sync.
//
// Approver pool is the same sitewide, section-agnostic one used for item
// review (any member with is_approver = true, set via set-approver-optin).
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const ANON_KEY = Deno.env.get("SUPABASE_ANON_KEY");

const ALLOWED_ORIGINS = ["https://selassiefest.com", "http://localhost:8000"];

function corsHeaders(req: Request) {
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
  const { request_id, action } = body;
  const note = (body.note || "").toString().trim();
  const sections: number[] = Array.isArray(body.sections) ? body.sections.map(Number).filter((n: number) => Number.isInteger(n)) : [];
  if (!request_id || !["approve", "decline"].includes(action)) {
    return new Response(JSON.stringify({ error: "Missing or invalid request_id/action." }), { status: 400, headers: jsonHeaders });
  }
  if (action === "approve" && !sections.length) {
    return new Response(JSON.stringify({ error: "Select at least one section to grant." }), { status: 400, headers: jsonHeaders });
  }
  if (action === "decline" && !note) {
    return new Response(JSON.stringify({ error: "A note is required when declining." }), { status: 400, headers: jsonHeaders });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: caller } = await admin
    .from("bbpac_formation_members")
    .select("id, is_approver")
    .eq("auth_user_id", userData.user.id)
    .maybeSingle();
  if (!caller) {
    return new Response(JSON.stringify({ error: "You are not a registered member." }), { status: 403, headers: jsonHeaders });
  }
  if (!caller.is_approver) {
    return new Response(JSON.stringify({ error: "You are not currently opted in as an approver." }), { status: 403, headers: jsonHeaders });
  }

  const { data: reqRow } = await admin
    .from("bbpac_formation_section_signup_requests")
    .select("id, full_name, email, requested_sections, status")
    .eq("id", request_id)
    .maybeSingle();
  if (!reqRow) {
    return new Response(JSON.stringify({ error: "Request not found." }), { status: 404, headers: jsonHeaders });
  }
  if (reqRow.status !== "pending") {
    return new Response(JSON.stringify({ error: "This request was already reviewed." }), { status: 409, headers: jsonHeaders });
  }
  if (action === "approve" && sections.some((s) => !reqRow.requested_sections.includes(s))) {
    return new Response(JSON.stringify({ error: "Can only grant sections that were actually requested." }), { status: 400, headers: jsonHeaders });
  }

  if (action === "decline") {
    const { error: updateErr } = await admin
      .from("bbpac_formation_section_signup_requests")
      .update({ status: "declined", reviewed_by: caller.id, reviewed_at: new Date().toISOString(), review_note: note })
      .eq("id", request_id);
    if (updateErr) {
      return new Response(JSON.stringify({ error: updateErr.message }), { status: 500, headers: jsonHeaders });
    }
    return new Response(JSON.stringify({ ok: true, action }), { status: 200, headers: jsonHeaders });
  }

  // action === "approve"
  let { data: existingMember } = await admin
    .from("bbpac_formation_members")
    .select("id")
    .ilike("email", reqRow.email)
    .maybeSingle();

  let memberId = existingMember?.id;
  if (!memberId) {
    const { data: newMember, error: insertErr } = await admin
      .from("bbpac_formation_members")
      .insert({ name: reqRow.full_name, email: reqRow.email, role: "member" })
      .select("id")
      .single();
    if (insertErr) {
      return new Response(JSON.stringify({ error: `Could not create member: ${insertErr.message}` }), { status: 500, headers: jsonHeaders });
    }
    memberId = newMember.id;
  }

  const ownerRows = sections.map((section_no) => ({ section_no, member_id: memberId, role: "worker" }));
  const { error: ownerErr } = await admin
    .from("bbpac_formation_section_owners")
    .upsert(ownerRows, { onConflict: "section_no,member_id", ignoreDuplicates: true });
  if (ownerErr) {
    return new Response(JSON.stringify({ error: `Could not grant sections: ${ownerErr.message}` }), { status: 500, headers: jsonHeaders });
  }

  const { error: updateErr } = await admin
    .from("bbpac_formation_section_signup_requests")
    .update({ status: "approved", reviewed_by: caller.id, reviewed_at: new Date().toISOString() })
    .eq("id", request_id);
  if (updateErr) {
    return new Response(JSON.stringify({ error: updateErr.message }), { status: 500, headers: jsonHeaders });
  }

  return new Response(JSON.stringify({ ok: true, action, granted_sections: sections }), { status: 200, headers: jsonHeaders });
});

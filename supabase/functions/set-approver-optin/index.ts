// Lets a current section head opt themselves in (or out) of the
// sitewide, section-agnostic approver pool for the Master Due-Diligence
// Matrix review workflow -- see review-item-submission for the other
// half of this. Deliberately NOT scoped to "head of section N approves
// only section N": the whole point is a wide, resilient pool so one
// person's absence never bottlenecks approval. Authenticated by the
// caller's own JWT, same pattern as manage-section-worker.
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
  if (typeof body.optIn !== "boolean") {
    return new Response(JSON.stringify({ error: "Missing boolean 'optIn'." }), { status: 400, headers: jsonHeaders });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: caller } = await admin
    .from("bbpac_formation_members")
    .select("id")
    .eq("auth_user_id", userData.user.id)
    .maybeSingle();
  if (!caller) {
    return new Response(JSON.stringify({ error: "You are not a registered member." }), { status: 403, headers: jsonHeaders });
  }

  if (body.optIn) {
    const { data: headRow } = await admin
      .from("bbpac_formation_section_owners")
      .select("id")
      .eq("member_id", caller.id)
      .eq("role", "head")
      .limit(1)
      .maybeSingle();
    if (!headRow) {
      return new Response(JSON.stringify({ error: "Only a current section head can opt in as an approver." }), { status: 403, headers: jsonHeaders });
    }
  }

  const { error: updateErr } = await admin
    .from("bbpac_formation_members")
    .update({ is_approver: body.optIn })
    .eq("id", caller.id);
  if (updateErr) {
    return new Response(JSON.stringify({ error: updateErr.message }), { status: 500, headers: jsonHeaders });
  }

  return new Response(JSON.stringify({ ok: true, isApprover: body.optIn }), { status: 200, headers: jsonHeaders });
});

// Lets a section HEAD add or remove workers on their own section directly
// from My Section (bbpac/organization/my-section.html), without a Table
// Editor round-trip through staff for every single addition. Authenticated
// by the caller's own user JWT, same pattern as notify-blocked-owner. Uses
// the service role only for the two privileged steps this needs: verifying
// the caller is actually a head of the section (bbpac_formation_members has
// no public read of who-owns-what-role), and find-or-creating the worker's
// member row by email. A head can only ever create/remove WORKER rows --
// promoting or removing a HEAD stays a manual Table Editor action, so one
// head can never unilaterally demote or replace another.
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

function escapeHtml(s) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" })[c]);
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

  const { action, section_no, email, member_id } = body;
  if (!["add", "remove"].includes(action) || !section_no || (action === "add" && !email) || (action === "remove" && !member_id)) {
    return new Response(JSON.stringify({ error: "Missing or invalid action/section_no, or missing email (add) / member_id (remove)." }), { status: 400, headers: jsonHeaders });
  }

  const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const { data: caller } = await admin
    .from("bbpac_formation_members")
    .select("id, name")
    .eq("auth_user_id", userData.user.id)
    .maybeSingle();
  if (!caller) {
    return new Response(JSON.stringify({ error: "You are not a registered section owner." }), { status: 403, headers: jsonHeaders });
  }

  const { data: headRow } = await admin
    .from("bbpac_formation_section_owners")
    .select("id")
    .eq("section_no", section_no)
    .eq("member_id", caller.id)
    .eq("role", "head")
    .maybeSingle();
  if (!headRow) {
    return new Response(JSON.stringify({ error: "You are not the head of that section." }), { status: 403, headers: jsonHeaders });
  }

  if (action === "remove") {
    const { error: delErr } = await admin
      .from("bbpac_formation_section_owners")
      .delete()
      .eq("section_no", section_no)
      .eq("member_id", member_id)
      .eq("role", "worker"); // a head can never remove another head via this function
    if (delErr) {
      return new Response(JSON.stringify({ error: delErr.message }), { status: 500, headers: jsonHeaders });
    }
    return new Response(JSON.stringify({ ok: true, action: "removed" }), { status: 200, headers: jsonHeaders });
  }

  // action === "add"
  const normalizedEmail = String(email).trim().toLowerCase();
  const name = (body.name || normalizedEmail).toString();
  let { data: workerMember } = await admin.from("bbpac_formation_members").select("id, name").eq("email", normalizedEmail).maybeSingle();
  if (!workerMember) {
    const { data: created, error: createErr } = await admin
      .from("bbpac_formation_members")
      .insert({ name, email: normalizedEmail, role: "member" })
      .select("id, name")
      .single();
    if (createErr) {
      return new Response(JSON.stringify({ error: createErr.message }), { status: 500, headers: jsonHeaders });
    }
    workerMember = created;
  }

  const { error: insertErr } = await admin
    .from("bbpac_formation_section_owners")
    .upsert({ section_no, member_id: workerMember.id, role: "worker" }, { onConflict: "section_no,member_id" });
  if (insertErr) {
    return new Response(JSON.stringify({ error: insertErr.message }), { status: 500, headers: jsonHeaders });
  }

  if (RESEND_API_KEY) {
    await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        from: FROM,
        to: normalizedEmail,
        reply_to: REPLY_TO,
        subject: `You've been added to Bongo Beach Section ${section_no}`,
        html: `<p><strong>${escapeHtml(caller.name)}</strong> added you as a worker on Section ${section_no} of the Bongo Beach Master Due-Diligence Matrix.</p>
               <p>Log in with this email at <a href="https://selassiefest.com/bbpac/organization/my-section.html">My Section</a> to get started -- you'll get a one-time login link, no password needed.</p>`,
      }),
    }).catch(() => {}); // best-effort -- a failed welcome email should never fail the actual team addition
  }

  return new Response(JSON.stringify({ ok: true, action: "added", member: workerMember }), { status: 200, headers: jsonHeaders });
});

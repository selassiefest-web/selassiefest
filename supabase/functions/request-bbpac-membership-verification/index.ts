// Called from /bbpac/get-involved/membership.html before it lets someone
// submit the "Join Friends of Bongo Beach" form. Sends a 6-digit code by
// email (never a clickable link -- those get silently consumed by mail
// scanners before the human clicks them). Uses the service role internally
// since the caller is anonymous and bbpac_membership_verifications has no
// public policies at all. Mirrors request-volunteer-verification.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Bongo Beach PAC <hello@selassiefest.com>";
const CODE_TTL_MINUTES = 10;
const COOLDOWN_SECONDS = 60;
// Per-IP throttle -- separate from the per-email cooldown above, which does
// nothing to stop a script rotating through many addresses. See
// verification_ip_rate_limits in schema.sql.
const RATE_LIMIT_PURPOSE = "bbpac_membership";
const RATE_LIMIT_WINDOW_MINUTES = 15;
const RATE_LIMIT_MAX_REQUESTS = 5;

// Called cross-origin (selassiefest.com -> supabase.co) from a browser, so
// the browser sends a CORS preflight OPTIONS request first -- without
// these headers on every response (including OPTIONS), the browser
// silently blocks the whole request before it reaches this code at all.
// Origin is locked to selassiefest.com (not "*") so a script on some other
// site can't drive a visitor's browser into requesting codes on their
// behalf.
const corsHeaders = {
  "Access-Control-Allow-Origin": "https://selassiefest.com",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const jsonHeaders = { ...corsHeaders, "Content-Type": "application/json" };

async function sha256(text) {
  const data = new TextEncoder().encode(text);
  const hashBuffer = await crypto.subtle.digest("SHA-256", data);
  return Array.from(new Uint8Array(hashBuffer)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  }

  const { email } = await req.json();
  if (!email || typeof email !== "string") {
    return new Response(JSON.stringify({ error: "Missing email" }), { status: 400, headers: jsonHeaders });
  }

  const normalizedEmail = email.trim().toLowerCase();
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  const clientIp = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
  const rateLimitWindowStart = new Date(Date.now() - RATE_LIMIT_WINDOW_MINUTES * 60 * 1000).toISOString();
  const { count: recentRequests } = await supabase
    .from("verification_ip_rate_limits")
    .select("*", { count: "exact", head: true })
    .eq("purpose", RATE_LIMIT_PURPOSE)
    .eq("ip", clientIp)
    .gte("created_at", rateLimitWindowStart);

  if ((recentRequests || 0) >= RATE_LIMIT_MAX_REQUESTS) {
    return new Response(JSON.stringify({ error: "Too many requests from this network. Please try again later." }), { status: 200, headers: jsonHeaders });
  }

  await supabase.from("verification_ip_rate_limits").insert({ ip: clientIp, purpose: RATE_LIMIT_PURPOSE });
  await supabase.from("verification_ip_rate_limits").delete().lt("created_at", new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());

  const { data: existing } = await supabase
    .from("bbpac_membership_verifications")
    .select("created_at")
    .eq("email", normalizedEmail)
    .maybeSingle();

  if (existing) {
    const secondsSince = (Date.now() - new Date(existing.created_at).getTime()) / 1000;
    if (secondsSince < COOLDOWN_SECONDS) {
      const wait = Math.ceil(COOLDOWN_SECONDS - secondsSince);
      return new Response(JSON.stringify({ error: `Please wait ${wait}s before requesting another code.` }), { status: 200, headers: jsonHeaders });
    }
  }

  const code = String(Math.floor(100000 + Math.random() * 900000));
  const codeHash = await sha256(code);
  const expiresAt = new Date(Date.now() + CODE_TTL_MINUTES * 60 * 1000).toISOString();

  const { error: dbError } = await supabase
    .from("bbpac_membership_verifications")
    .upsert(
      { email: normalizedEmail, code_hash: codeHash, verified: false, attempts: 0, expires_at: expiresAt },
      { onConflict: "email" },
    );

  if (dbError) {
    return new Response(JSON.stringify({ error: dbError.message }), { status: 500, headers: jsonHeaders });
  }

  const emailRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({
      from: FROM,
      to: [email.trim()],
      reply_to: "selassiefest@gmail.com",
      subject: "Your Bongo Beach PAC membership verification code",
      html: `
        <p>Here's your verification code to join Friends of Bongo Beach:</p>
        <p style="font-size:28px;font-weight:700;letter-spacing:4px;">${code}</p>
        <p>Enter it on the form to confirm your email. It expires in ${CODE_TTL_MINUTES} minutes.</p>
        <p style="margin-top:24px;color:#888;font-size:0.85rem;">If you didn't request this, you can ignore it.</p>
      `,
    }),
  });

  if (!emailRes.ok) {
    const text = await emailRes.text();
    return new Response(JSON.stringify({ error: `Resend error: ${text}` }), { status: 502, headers: jsonHeaders });
  }

  return new Response(JSON.stringify({ ok: true }), { status: 200, headers: jsonHeaders });
});

// Called from the sitewide footer newsletter form (assets/js/newsletter-form.js)
// instead of a direct anon insert into newsletter_subscribers. Bots were using
// that open insert to sign up strangers (10/6/2026), so a signup now has to
// pass a Cloudflare Turnstile check, a hidden honeypot field and a per-IP
// throttle before the row is written with the service role. Once this is live,
// anon INSERT on newsletter_subscribers is revoked (see the comment at the top
// of supabase/schema.sql's newsletter section).
//
// Deploy with --no-verify-jwt: the browser calls it with no session, same as
// request-volunteer-verification. Secret: TURNSTILE_SECRET_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
const TURNSTILE_SECRET_KEY = Deno.env.get("TURNSTILE_SECRET_KEY");
const ALLOWED_HOSTNAMES = ["selassiefest.com", "www.selassiefest.com"];
const RATE_LIMIT_PURPOSE = "newsletter";
const RATE_LIMIT_WINDOW_MINUTES = 60;
const RATE_LIMIT_MAX_REQUESTS = 5;
const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;

// Origin locked to selassiefest.com (not "*"), same as the other public
// functions, so another site can't drive visitors' browsers into signing up.
const corsHeaders = {
  "Access-Control-Allow-Origin": "https://selassiefest.com",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};
const jsonHeaders = { ...corsHeaders, "Content-Type": "application/json" };
const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers: jsonHeaders });

async function turnstileOk(token: string, ip: string): Promise<boolean> {
  const form = new FormData();
  form.append("secret", TURNSTILE_SECRET_KEY || "");
  form.append("response", token);
  if (ip !== "unknown") form.append("remoteip", ip);
  const res = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", { method: "POST", body: form });
  const out = await res.json();
  if (!out.success) console.warn("newsletter-signup: turnstile failed", out["error-codes"]);
  return out.success === true && ALLOWED_HOSTNAMES.includes(out.hostname);
}

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
  if (req.method !== "POST") return new Response("Method not allowed", { status: 405, headers: corsHeaders });
  if (!TURNSTILE_SECRET_KEY) {
    console.error("newsletter-signup: TURNSTILE_SECRET_KEY is not set");
    return reply({ error: "Signups are paused. Please try again later." }, 500);
  }

  try {
    const body = await req.json().catch(() => ({}));
    // Honeypot: a field people never see. Pretend it worked.
    if (String(body.website || "").trim() !== "") return reply({ ok: true });

    const email = String(body.email || "").trim().toLowerCase().slice(0, 254);
    const token = String(body.token || "");
    const source = body.source ? String(body.source).slice(0, 100) : null;
    if (!EMAIL_RE.test(email)) return reply({ error: "Please enter a valid email address." }, 400);
    if (!token) return reply({ error: "Please complete the check above the button." }, 400);

    const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
    if (!(await turnstileOk(token, ip))) return reply({ error: "We couldn't verify you're a person. Please try again." }, 400);

    const supabase = createClient(SUPABASE_URL!, SERVICE_ROLE_KEY!);
    const since = new Date(Date.now() - RATE_LIMIT_WINDOW_MINUTES * 60 * 1000).toISOString();
    const { count } = await supabase
      .from("verification_ip_rate_limits")
      .select("*", { count: "exact", head: true })
      .eq("purpose", RATE_LIMIT_PURPOSE)
      .eq("ip", ip)
      .gte("created_at", since);
    if ((count || 0) >= RATE_LIMIT_MAX_REQUESTS) return reply({ error: "Too many signups from this network. Please try again later." }, 429);
    await supabase.from("verification_ip_rate_limits").insert({ ip, purpose: RATE_LIMIT_PURPOSE });

    const { error } = await supabase.from("newsletter_subscribers").insert({ email, source });
    if (error && error.code === "23505") return reply({ ok: true, already: true });
    if (error) throw error;
    return reply({ ok: true });
  } catch (e) {
    console.error("newsletter-signup error:", e);
    return reply({ error: "Something went wrong. Please try again." }, 500);
  }
});

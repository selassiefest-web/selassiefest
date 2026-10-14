// Supabase Edge Function: rti-bgcheck-access
// The members-only gate in front of /rti/background-check/.
//
//   { action: "request", email, token }  Turnstile-checked. If the email is an
//       active row in rti_members, emails it a 6-digit code (10 minutes). The
//       reply is the same either way, so the page can't be used to test who
//       is on the list.
//   { action: "verify", email, code }    On a correct code, issues a pass: a
//       random token (only its hash is stored) good for 4 hours. The page
//       sends it with the application; rti-background-check checks it again.
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, TURNSTILE_SECRET_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const TURNSTILE_SECRET_KEY = Deno.env.get("TURNSTILE_SECRET_KEY") ?? "";

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const ALLOWED_HOSTNAMES = ["selassiefest.com", "www.selassiefest.com"];
const CODE_TTL_MINUTES = 10;
const COOLDOWN_SECONDS = 60;
const MAX_ATTEMPTS = 5;
const SESSION_HOURS = 4;
const IP_WINDOW_MINUTES = 15;
const IP_MAX_REQUESTS = 5;

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}

async function sha256(text: string) {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}
const randomHex = (bytes: number) => Array.from(crypto.getRandomValues(new Uint8Array(bytes))).map((b) => b.toString(16).padStart(2, "0")).join("");
const randomCode = () => String(100000 + (crypto.getRandomValues(new Uint32Array(1))[0] % 900000));
const isEmail = (s: string) => /^[^\s@<>()",;:]+@[^\s@<>()",;:]+\.[^\s@<>()",;:]+$/.test(s);

async function turnstileOk(token: string, ip: string): Promise<boolean> {
  const form = new FormData();
  form.append("secret", TURNSTILE_SECRET_KEY);
  form.append("response", token);
  if (ip !== "unknown") form.append("remoteip", ip);
  const res = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", { method: "POST", body: form });
  const out = await res.json();
  if (!out.success) console.warn("rti-bgcheck-access: turnstile failed", out["error-codes"]);
  return out.success === true && ALLOWED_HOSTNAMES.includes(out.hostname);
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  if (!RESEND_API_KEY || !TURNSTILE_SECRET_KEY) return reply({ ok: false, error: "Sign-in is paused right now." }, 500);

  let body: Record<string, any>;
  try { body = await req.json(); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const email = String(body.email ?? "").trim().toLowerCase().slice(0, 200);
  if (!isEmail(email)) return reply({ ok: false, error: "That email address doesn't look right." }, 400);

  const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // Both actions share one per-IP throttle, so a script can neither spray codes nor guess them quickly
  const since = new Date(Date.now() - IP_WINDOW_MINUTES * 60 * 1000).toISOString();
  const { count } = await supabase.from("verification_ip_rate_limits").select("*", { count: "exact", head: true })
    .eq("purpose", "rti-bgcheck-access").eq("ip", ip).gte("created_at", since);
  if ((count || 0) >= IP_MAX_REQUESTS * 2) return reply({ ok: false, error: "Too many tries from this network. Please wait 15 minutes." }, 429);
  await supabase.from("verification_ip_rate_limits").insert({ ip, purpose: "rti-bgcheck-access" });

  if (body.action === "request") {
    if (!body.token) return reply({ ok: false, error: "Please wait for the security check to finish, then try again." }, 400);
    if (!(await turnstileOk(String(body.token), ip))) return reply({ ok: false, error: "We couldn't verify you're a person. Please try again." }, 400);
    const generic = { ok: true, message: "If that email is on the Ras Tafari Inc. member list, a 6-digit code is on its way. It can take a minute." };

    const { data: member } = await supabase.from("rti_members").select("email, active").eq("email", email).maybeSingle();
    if (!member || !member.active) return reply(generic);

    const { data: pending } = await supabase.from("rti_bgcheck_codes").select("created_at").eq("email", email).maybeSingle();
    if (pending && (Date.now() - new Date(pending.created_at).getTime()) / 1000 < COOLDOWN_SECONDS) return reply(generic);

    const code = randomCode();
    const { error } = await supabase.from("rti_bgcheck_codes").upsert({
      email, code_hash: await sha256(code), attempts: 0,
      created_at: new Date().toISOString(), expires_at: new Date(Date.now() + CODE_TTL_MINUTES * 60 * 1000).toISOString(),
    }, { onConflict: "email" });
    if (error) { console.error("rti-bgcheck-access: code upsert failed", error.code); return reply({ ok: false, error: "Something went wrong. Please try again." }, 500); }

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({
        from: FROM_EMAIL, to: [email],
        subject: `${code} is your Ras Tafari Inc. background check code`,
        text: `Your code for the Ras Tafari Inc. background check page is ${code}\n\nEnter it on the page to open your application. It expires in ${CODE_TTL_MINUTES} minutes.\n\nIf you didn't ask for this, you can ignore this email.\n`,
        html: `<p>Your code for the Ras Tafari Inc. background check page:</p><p style="font-size:30px;font-weight:700;letter-spacing:5px">${code}</p><p>Enter it on the page to open your application. It expires in ${CODE_TTL_MINUTES} minutes.</p><p style="color:#888;font-size:13px">If you didn't ask for this, you can ignore this email.</p>`,
      }),
    });
    if (!res.ok) console.error("rti-bgcheck-access: resend error", res.status, (await res.text()).slice(0, 300));
    return reply(generic);
  }

  if (body.action === "verify") {
    const code = String(body.code ?? "").replace(/\D/g, "");
    const { data: row } = await supabase.from("rti_bgcheck_codes").select("*").eq("email", email).maybeSingle();
    if (!row) return reply({ ok: false, error: "No code is waiting for this email. Ask for a new one." });
    if (row.attempts >= MAX_ATTEMPTS) return reply({ ok: false, error: "Too many wrong tries. Ask for a new code." });
    if (new Date(row.expires_at) < new Date()) return reply({ ok: false, error: "That code expired. Ask for a new one." });
    if ((await sha256(code)) !== row.code_hash) {
      await supabase.from("rti_bgcheck_codes").update({ attempts: row.attempts + 1 }).eq("email", email);
      return reply({ ok: false, error: "That code doesn't match. Check the email and try again." });
    }
    // Still on the list? (Someone could be removed between asking and entering the code.)
    const { data: member } = await supabase.from("rti_members").select("active, full_name").eq("email", email).maybeSingle();
    if (!member?.active) return reply({ ok: false, error: "This email isn't on the member list." });

    await supabase.from("rti_bgcheck_codes").delete().eq("email", email);
    const pass = randomHex(32);
    const expires = new Date(Date.now() + SESSION_HOURS * 60 * 60 * 1000).toISOString();
    const { error } = await supabase.from("rti_bgcheck_sessions").insert({ token_hash: await sha256(pass), email, expires_at: expires });
    if (error) { console.error("rti-bgcheck-access: session insert failed", error.code); return reply({ ok: false, error: "Something went wrong. Please try again." }, 500); }
    await supabase.from("rti_bgcheck_sessions").delete().lt("expires_at", new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());
    return reply({ ok: true, pass, email, expires, name: member.full_name ?? null });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});

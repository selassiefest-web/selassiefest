// Supabase Edge Function: rti-donor-page
// Stores the thank-you page built by /rti/donation/ and serves it to the donor at /donors/?k=KEY.
//
//   { action: "publish", secret, donor, request_no, html }  Staff only (RTI_SIGN_ADMIN_SECRET). Returns { key }.
//   { action: "get", key }                                   Public, but the key is a 16-character random value.
//
// Deploy with --no-verify-jwt. Secret: RTI_SIGN_ADMIN_SECRET.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const MAX_HTML = 12_000_000;

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}
const ALPHA = "abcdefghjkmnpqrstuvwxyz23456789";
const newKey = () => Array.from(crypto.getRandomValues(new Uint8Array(16))).map((b) => ALPHA[b % ALPHA.length]).join("");
function sameSecret(a: string, b: string) {
  if (!a || !b || a.length !== b.length) return false;
  let r = 0; for (let i = 0; i < a.length; i++) r |= a.charCodeAt(i) ^ b.charCodeAt(i); return r === 0;
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  let body: Record<string, any>;
  try { body = JSON.parse((await req.text()) || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  if (body.action === "publish") {
    if (!sameSecret(String(body.secret ?? ""), ADMIN_SECRET)) return reply({ ok: false, error: "That staff secret is not right." }, 401);
    const html = String(body.html ?? "");
    if (html.length < 500 || html.length > MAX_HTML) return reply({ ok: false, error: "The page is empty or too large." }, 400);
    const key = newKey();
    const { error } = await supabase.from("rti_donor_pages").insert({ key, donor: String(body.donor ?? "").slice(0, 200), request_no: String(body.request_no ?? "").slice(0, 80), html });
    if (error) { console.error("rti-donor-page: insert failed", error.code); return reply({ ok: false, error: "Could not save the page." }, 500); }
    return reply({ ok: true, key });
  }

  if (body.action === "get") {
    const key = String(body.key ?? "");
    if (!/^[a-z0-9]{16}$/.test(key)) return reply({ ok: false, error: "That link is not valid." }, 404);
    const { data, error } = await supabase.from("rti_donor_pages").select("html, views").eq("key", key).maybeSingle();
    if (error || !data) return reply({ ok: false, error: "That link is not valid." }, 404);
    await supabase.from("rti_donor_pages").update({ views: (data.views ?? 0) + 1, last_viewed_at: new Date().toISOString() }).eq("key", key);
    return reply({ ok: true, html: data.html });
  }
  return reply({ ok: false, error: "Unknown action." }, 400);
});

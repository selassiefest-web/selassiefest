// Supabase Edge Function: resident-sign
// Behind /full-spectrum/sign/: South Side residents sign the letter of support for Full Spectrum at Rainbow Beach.
// The checks follow how Illinois petition signatures are judged (see supabase/resident-signatures.sql):
//
//   { action: "submit", token (Turnstile), s: {...} }  Validates the signer, matches the address with the U.S. Census
//       geocoder, finds its Chicago community area, refuses addresses off the South Side and repeat signers,
//       stores the signature as "unconfirmed" and emails a confirmation link.
//   { action: "confirm", c }   The emailed link: confirms the email and puts the signature in the review queue.
//   { action: "summary" }      Public totals (reviewed signatures only).
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, TURNSTILE_SECRET_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const TURNSTILE_SECRET_KEY = Deno.env.get("TURNSTILE_SECRET_KEY") ?? "";
const FROM = "Ras Tafari Inc. <hello@selassiefest.com>";
const STAFF = ["stephen@selassiefest.com"];
const PAGE = "https://selassiefest.com/full-spectrum/sign/";
const REVIEW = "https://selassiefest.com/full-spectrum/sign/review.html";
const LETTER = "full-spectrum-2027";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const ALLOWED_HOSTNAMES = ["selassiefest.com", "www.selassiefest.com"];
// The Rainbow Beach Park neighborhoods (Chicago community areas), and the South Side as a whole (areas 33 to 75).
const RAINBOW_BEACH = new Set([42, 43, 45, 46, 48, 69]); // Woodlawn, South Shore, Avalon Park, South Chicago, Calumet Heights, Greater Grand Crossing
const isSouthSide = (n: number) => n >= 33 && n <= 75;
const IP_WINDOW_MINUTES = 60, IP_MAX = 6, PATTERN_MAX = 3;

const db = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
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
const randomHex = (n: number) => Array.from(crypto.getRandomValues(new Uint8Array(n))).map((b) => b.toString(16).padStart(2, "0")).join("");
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));
const isEmail = (s: string) => /^[^\s@<>()",;:]+@[^\s@<>()",;:]+\.[^\s@<>()",;:]+$/.test(s);
const clean = (v: unknown, max: number) => String(v ?? "").replace(/\s+/g, " ").trim().slice(0, max);
const norm = (s: string) => s.toLowerCase().normalize("NFKD").replace(/[^a-z]/g, "");
const normUnit = (s: string) => s.toUpperCase().replace(/^(APT|APARTMENT|UNIT|STE|SUITE|#)\s*/, "").replace(/[^A-Z0-9]/g, "");

async function turnstileOk(token: string, ip: string) {
  const form = new FormData();
  form.append("secret", TURNSTILE_SECRET_KEY);
  form.append("response", token);
  if (ip !== "unknown") form.append("remoteip", ip);
  const out = await (await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", { method: "POST", body: form })).json();
  return out.success === true && ALLOWED_HOSTNAMES.includes(out.hostname);
}
async function send(to: string[], subject: string, html: string) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to, subject, html, reply_to: STAFF[0] }),
  });
  if (!res.ok) console.error("resident-sign: resend", res.status, (await res.text()).slice(0, 200));
}

// Address check, like comparing a petition line to the registration record: the street address must match
// a real address range in the Census geocoder, and the point must fall inside a South Side community area.
async function geocode(street: string, zip: string) {
  const u = new URL("https://geocoding.geo.census.gov/geocoder/locations/onelineaddress");
  u.searchParams.set("address", `${street}, Chicago, IL ${zip}`);
  u.searchParams.set("benchmark", "Public_AR_Current");
  u.searchParams.set("format", "json");
  const out = await (await fetch(u)).json();
  const m = out?.result?.addressMatches?.[0];
  if (!m || String(m.addressComponents?.city || "").toUpperCase() !== "CHICAGO") return null;
  return { matched: String(m.matchedAddress), lon: Number(m.coordinates.x), lat: Number(m.coordinates.y) };
}
async function communityArea(lon: number, lat: number) {
  const u = new URL("https://data.cityofchicago.org/resource/igwz-8jzy.json");
  u.searchParams.set("$select", "community,area_numbe");
  u.searchParams.set("$where", `intersects(the_geom, 'POINT (${lon} ${lat})')`);
  const rows = await (await fetch(u)).json();
  const r = Array.isArray(rows) ? rows[0] : null;
  return r ? { name: String(r.community), number: Number(r.area_numbe) } : null;
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ error: "POST only" }, 405);
  let body: any;
  try { body = await req.json(); } catch { return reply({ error: "Bad request." }, 400); }

  if (body.action === "summary") {
    const { data, error } = await db.rpc("rs_public_summary", { p_letter: LETTER });
    if (error) return reply({ error: "Could not load the totals." }, 500);
    return reply({ ok: true, summary: data });
  }

  if (body.action === "confirm") {
    const c = clean(body.c, 80);
    if (!/^[0-9a-f]{40}$/.test(c)) return reply({ error: "That confirmation link is not valid." }, 400);
    const { data: s } = await db.from("rs_signatures").select("id, first_name, last_name, community_area, status, email_confirmed_at")
      .eq("confirm_hash", await sha256(c)).maybeSingle();
    if (!s) return reply({ error: "That confirmation link is not valid." }, 404);
    if (!s.email_confirmed_at) {
      await db.from("rs_signatures").update({ email_confirmed_at: new Date().toISOString(), status: s.status === "unconfirmed" ? "pending_review" : s.status }).eq("id", s.id);
      const { count } = await db.from("rs_signatures").select("id", { count: "exact", head: true }).eq("letter", LETTER).eq("status", "pending_review");
      await send(STAFF, `Letter of support: ${s.first_name} ${s.last_name} (${s.community_area}) is ready for review`,
        `<p>${esc(s.first_name)} ${esc(s.last_name)} of ${esc(s.community_area)} confirmed their signature on the Full Spectrum resident letter.</p>
         <p>${count ?? "Some"} signature(s) are waiting for review: <a href="${REVIEW}">${REVIEW}</a></p>`);
    }
    return reply({ ok: true, first_name: s.first_name });
  }

  if (body.action !== "submit") return reply({ error: "Unknown action." }, 400);
  const ip = (req.headers.get("x-forwarded-for") || "unknown").split(",")[0].trim();
  if (!(await turnstileOk(String(body.token || ""), ip))) return reply({ error: "The security check failed. Please reload the page and try again." }, 403);

  const s = body.s || {};
  const first = clean(s.first_name, 60), last = clean(s.last_name, 60);
  const street = clean(s.street, 120), unit = clean(s.unit, 20), zip = clean(s.zip, 10).slice(0, 5);
  const email = clean(s.email, 160).toLowerCase(), comment = clean(s.comment, 500);
  const sig = String(s.signature || "");
  if (!first || !last) return reply({ error: "Please enter your first and last name." }, 400);
  if (!/^\d+\s+\S/.test(street)) return reply({ error: "Please enter your full street address, starting with the house number." }, 400);
  if (!/^606\d\d$/.test(zip)) return reply({ error: "Please enter your Chicago ZIP code (606xx)." }, 400);
  if (!isEmail(email)) return reply({ error: "Please enter a valid email address. We send a link to confirm your signature." }, 400);
  if (s.says_adult !== true) return reply({ error: "Signers must be 18 or older." }, 400);
  if (s.says_own_person !== true) return reply({ error: "Please confirm that you are signing for yourself only." }, 400);
  if (!/^data:image\/png;base64,[A-Za-z0-9+/=]+$/.test(sig) || sig.length < 1500 || sig.length > 150000) return reply({ error: "Please sign in the signature box." }, 400);

  const ipHash = await sha256("rs:" + ip);
  const since = new Date(Date.now() - IP_WINDOW_MINUTES * 60000).toISOString();
  const { count: recent } = await db.from("rs_signatures").select("id", { count: "exact", head: true }).eq("ip_hash", ipHash).gte("created_at", since);
  if ((recent ?? 0) >= IP_MAX) return reply({ error: "Too many signatures from this connection in the last hour. Please try again later." }, 429);

  const geo = await geocode(street, zip).catch(() => null);
  if (!geo) return reply({ error: "We could not find that address in Chicago's public address records. Please check the house number, street direction (N, S, E, W) and street name." }, 400);
  const area = await communityArea(geo.lon, geo.lat).catch(() => null);
  if (!area) return reply({ error: "We could not place that address in a Chicago community area. Please check it and try again." }, 400);
  if (!isSouthSide(area.number)) return reply({ error: `This letter is signed by residents of Chicago's South Side. Your address is in ${area.name.toLowerCase().replace(/\b\w/g, (c) => c.toUpperCase())}. Thank you for your support all the same.`, code: "NOT_IN_AREA" }, 400);

  const nameNorm = norm(first) + "|" + norm(last);
  const addressNorm = geo.matched.toUpperCase() + (unit ? " #" + normUnit(unit) : "");
  const { data: dupPerson } = await db.from("rs_signatures").select("id").eq("letter", LETTER).neq("status", "struck")
    .eq("name_norm", nameNorm).eq("address_norm", addressNorm).limit(1);
  const { data: dupEmail } = await db.from("rs_signatures").select("id").eq("letter", LETTER).neq("status", "struck")
    .ilike("email", email.replace(/[%_\\]/g, "\\$&")).limit(1);
  if (dupPerson?.length || dupEmail?.length) return reply({ error: "This person or email address has already signed the letter. Each resident signs once.", code: "DUPLICATE" }, 409);

  const c = randomHex(20);
  const { error } = await db.from("rs_signatures").insert({
    letter: LETTER, first_name: first, last_name: last, name_norm: nameNorm,
    street, unit, zip, matched_address: geo.matched, address_norm: addressNorm, lat: geo.lat, lon: geo.lon,
    community_area: area.name, community_area_number: area.number, area_tier: RAINBOW_BEACH.has(area.number) ? "rainbow_beach" : "south_side",
    email, confirm_hash: await sha256(c), signature_png: sig,
    says_adult: true, says_own_person: true, says_registered: s.says_registered === true, show_publicly: s.show_publicly === true,
    comment, ip_hash: ipHash, pattern_flag: (recent ?? 0) >= PATTERN_MAX - 1,
  });
  if (error) {
    if (String(error.code) === "23505") return reply({ error: "This person or email address has already signed the letter. Each resident signs once.", code: "DUPLICATE" }, 409);
    console.error("resident-sign: insert", error.message);
    return reply({ error: "Something went wrong saving your signature. Please try again." }, 500);
  }
  const link = `${PAGE}?c=${c}`;
  await send([email], "Please confirm your signature: Full Spectrum at Rainbow Beach",
    `<p>Hi ${esc(first)},</p>
     <p>Thank you for signing the residents' letter of support for Full Spectrum at Rainbow Beach Park.</p>
     <p><b>One more step:</b> please confirm it is really you by opening this link:<br><a href="${link}">${link}</a></p>
     <p>We matched your address to <b>${esc(geo.matched)}</b> (${esc(area.name)}). After you confirm, our team reviews each signature before it is counted.</p>
     <p>If you did not sign, ignore this email and the signature will not be counted.</p>
     <p>Stephen Henry<br>President, Ras Tafari Inc.<br>(872) 255-9333</p>`);
  return reply({ ok: true, matched_address: geo.matched, community_area: area.name, rainbow_beach: RAINBOW_BEACH.has(area.number) });
});

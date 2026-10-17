// Supabase Edge Function: support-letter
// Behind /support-letter/: partners write and sign a letter of support for a Ras Tafari Inc. program.
//
//   { action: "submit", token (Turnstile), letter: {...} }  Stores the letter, emails Stephen and the
//       signer a private link (?t=) to the printable signed letter.
//   { action: "view", t }      The letter for the private link (print it to PDF for a funder).
//   { action: "count" }        Public: how many letters, and the names of organizations that agreed to be listed.
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, TURNSTILE_SECRET_KEY.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const TURNSTILE_SECRET_KEY = Deno.env.get("TURNSTILE_SECRET_KEY") ?? "";
const FROM = "Ras Tafari Inc. <hello@selassiefest.com>";
const STAFF = ["stephen@selassiefest.com"];
const PAGE = "https://selassiefest.com/support-letter/";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const ALLOWED_HOSTNAMES = ["selassiefest.com", "www.selassiefest.com"];
const PROGRAMS = ["Full Spectrum at Rainbow Beach", "Rainbow DJ Lab", "Rainbow Wednesdays", "Roots in the Parks", "Anatomy of a Shoreline", "SelassieFest"];
const IP_WINDOW_MINUTES = 60;
const IP_MAX = 6;

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
const clean = (v: unknown, max: number) => String(v ?? "").replace(/\s+\n/g, "\n").trim().slice(0, max);

async function turnstileOk(token: string, ip: string) {
  const form = new FormData();
  form.append("secret", TURNSTILE_SECRET_KEY);
  form.append("response", token);
  if (ip !== "unknown") form.append("remoteip", ip);
  const out = await (await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", { method: "POST", body: form })).json();
  return out.success === true && ALLOWED_HOSTNAMES.includes(out.hostname);
}
async function send(to: string[], subject: string, html: string, replyTo?: string) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to, subject, html, ...(replyTo ? { reply_to: replyTo } : {}) }),
  });
  if (!res.ok) console.error("support-letter: resend", res.status, (await res.text()).slice(0, 200));
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (b: unknown, status = 200) => new Response(JSON.stringify(b), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  const raw = await req.text();
  if (raw.length > 320_000) return reply({ ok: false, error: "That signature is too large. Clear it and sign again." }, 413);
  let body: Record<string, any>;
  try { body = JSON.parse(raw || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  if (body.action === "count") {
    const { data } = await supabase.from("support_letters").select("org_name, public_ok, status").neq("status", "hidden");
    const rows = data ?? [];
    return reply({ ok: true, count: rows.length, listed: [...new Set(rows.filter((r: any) => r.public_ok).map((r: any) => r.org_name))].sort() });
  }

  if (body.action === "view") {
    const t = String(body.t ?? "");
    if (!/^[0-9a-f]{48}$/.test(t)) return reply({ ok: false, error: "This letter link isn't valid." }, 404);
    const { data: l } = await supabase.from("support_letters").select("*").eq("token_hash", await sha256(t)).maybeSingle();
    if (!l || l.status === "hidden") return reply({ ok: false, error: "This letter isn't available." }, 404);
    const { token_hash, ip, user_agent, ...letter } = l;
    return reply({ ok: true, letter });
  }

  if (body.action !== "submit") return reply({ ok: false, error: "Unknown action." }, 400);
  if (!RESEND_API_KEY || !TURNSTILE_SECRET_KEY) return reply({ ok: false, error: "Letters are paused right now." }, 500);

  const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
  const since = new Date(Date.now() - IP_WINDOW_MINUTES * 60_000).toISOString();
  const { count } = await supabase.from("verification_ip_rate_limits").select("*", { count: "exact", head: true }).eq("purpose", "support-letter").eq("ip", ip).gte("created_at", since);
  if ((count || 0) >= IP_MAX) return reply({ ok: false, error: "Too many letters from this network. Please try again in an hour." }, 429);
  await supabase.from("verification_ip_rate_limits").insert({ ip, purpose: "support-letter" });
  if (!body.token || !(await turnstileOk(String(body.token), ip))) return reply({ ok: false, error: "We couldn't verify you're a person. Please try again." }, 400);

  const L = body.letter ?? {};
  const letter = {
    org_name: clean(L.org_name, 160), org_about: clean(L.org_about, 600), signer_name: clean(L.signer_name, 120), signer_title: clean(L.signer_title, 120),
    email: clean(L.email, 200).toLowerCase(), phone: clean(L.phone, 40), address: clean(L.address, 200), relationship: clean(L.relationship, 600),
    programs: (Array.isArray(L.programs) ? L.programs : []).filter((p: string) => PROGRAMS.includes(p)).slice(0, 6),
    why: clean(L.why, 2000), commitment: clean(L.commitment, 800), public_ok: L.public_ok === true, signature_png: String(L.signature_png ?? ""),
  };
  if (!letter.org_name || !letter.signer_name) return reply({ ok: false, error: "Add your organization and your name." }, 400);
  if (!isEmail(letter.email)) return reply({ ok: false, error: "That email address doesn't look right." }, 400);
  if (!letter.programs.length) return reply({ ok: false, error: "Choose at least one program you support." }, 400);
  if (letter.why.length < 60) return reply({ ok: false, error: "Tell funders, in a few sentences, why this program matters to you." }, 400);
  if (!/^data:image\/png;base64,[A-Za-z0-9+/=]+$/.test(letter.signature_png) || letter.signature_png.length < 400) return reply({ ok: false, error: "Draw your signature first." }, 400);
  if (L.attest !== true) return reply({ ok: false, error: "Tick the box confirming you may sign for your organization." }, 400);

  const t = randomHex(24);
  const { data: row, error } = await supabase.from("support_letters").insert({ ...letter, token_hash: await sha256(t), ip, user_agent: (req.headers.get("user-agent") || "").slice(0, 300) }).select("id").single();
  if (error) { console.error("support-letter: insert", error.code); return reply({ ok: false, error: "Couldn't save your letter. Please try again." }, 500); }

  const link = `${PAGE}view/?t=${t}`;
  const progs = letter.programs.join(", ");
  await send(STAFF, `New letter of support: ${letter.org_name}`,
    `<p><b>${esc(letter.signer_name)}</b>${letter.signer_title ? ", " + esc(letter.signer_title) : ""} of <b>${esc(letter.org_name)}</b> signed a letter of support for ${esc(progs)}.</p>
     <blockquote style="border-left:3px solid #1f7a45;margin:12px 0;padding:4px 12px;color:#333">${esc(letter.why).replace(/\n/g, "<br>")}</blockquote>
     ${letter.commitment ? `<p><b>They offer:</b> ${esc(letter.commitment)}</p>` : ""}
     <p><a href="${link}">Open and print the signed letter</a></p>
     <p style="color:#666;font-size:13px">${esc(letter.email)}${letter.phone ? " · " + esc(letter.phone) : ""} · listed publicly: ${letter.public_ok ? "yes" : "no"}</p>`);
  await send([letter.email], "Thank you for your letter of support",
    `<p>Thank you, ${esc(letter.signer_name.split(" ")[0])}. Your letter of support for ${esc(progs)} is signed and on file with Ras Tafari Inc.</p>
     <p><a href="${link}">View or print your signed letter</a></p>
     <p>We'll include it with our applications to funders and the Chicago Park District. If anything in it needs changing, just reply to this email.</p>
     <p>Stephen Henry<br>President, Ras Tafari Inc.<br>(872) 255-9333</p>`, STAFF[0]);
  return reply({ ok: true, id: row.id, link });
});

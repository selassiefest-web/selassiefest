// Supabase Edge Function: rti-finance
// Behind /rti/finance/: Ras Tafari Inc.'s books, for the officers only.
//
//   { action: "link", email }   Public: if the email belongs to an officer on
//       rti_fin_viewers, emails them a personal link. Same reply either way.
//   { action: "load", token }   The books, for a valid link.
//   { action: "invite", secret, emails? }   From the CLI (RTI_SIGN_ADMIN_SECRET):
//       emails a link to each listed officer (or all of them).
//
// Links never expire; every link sent stays valid. Only hashes are stored.
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, RTI_SIGN_ADMIN_SECRET.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const PAGE_URL = "https://selassiefest.com/rti/finance/";
const BOOKS_ID = "fy2026";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];

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
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));
const maskEmail = (e: string) => e.replace(/^(.{2})[^@]*/, "$1***");

async function sendLink(supabase: any, v: any) {
  const token = randomHex(32);
  const hashes = [...(v.token_hashes ?? []), await sha256(token)].slice(-20);
  const { error } = await supabase.from("rti_fin_viewers").update({ token_hashes: hashes, last_sent_at: new Date().toISOString() }).eq("id", v.id);
  if (error) { console.error("rti-finance: token save failed", error.code); return false; }
  const link = `${PAGE_URL}?t=${token}`;
  const first = v.full_name.split(/\s+/)[0];
  const text = `Hello ${first},\n\nHere is your personal link to Ras Tafari Inc.'s financials (P&L, balance sheet, bank and card ledgers, open items):\n\n${link}\n\nThe link is personal to you as ${v.title}; please don't forward it. It keeps working, so you can bookmark it.\n\nQuestions: stephen@selassiefest.com or (872) 255-9333.\n`;
  const html = `<p>Hello ${esc(first)},</p><p>Here is your personal link to <b>Ras Tafari Inc.'s financials</b>: P&amp;L, balance sheet, bank and card ledgers, and open items.</p><p><a href="${link}" style="display:inline-block;background:#1f5b3a;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none;font-weight:700">Open RTI financials</a></p><p>The link is personal to you as ${esc(v.title)}; please don't forward it. It keeps working, so you can bookmark it.</p><p style="color:#666;font-size:13px">Questions: stephen@selassiefest.com or (872) 255-9333.</p>`;
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM_EMAIL, to: [v.email], subject: "Your link: Ras Tafari Inc. financials", text, html }),
  });
  if (!res.ok) console.error("rti-finance: resend error", res.status);
  return res.ok;
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);

  let body: Record<string, any>;
  try { body = JSON.parse((await req.text()) || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  if (body.action === "link") {
    const email = String(body.email ?? "").trim().toLowerCase();
    if (/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      const { data: v } = await supabase.from("rti_fin_viewers").select("*").eq("email", email).maybeSingle();
      if (v && RESEND_API_KEY) await sendLink(supabase, v);
    }
    return reply({ ok: true, message: "If that email belongs to an RTI officer, a link is on its way." });
  }

  if (body.action === "invite") {
    if (!ADMIN_SECRET || String(body.secret ?? "") !== ADMIN_SECRET) return reply({ ok: false, error: "Not allowed." }, 403);
    let q = supabase.from("rti_fin_viewers").select("*");
    if (Array.isArray(body.emails) && body.emails.length) q = q.in("email", body.emails.map((e: unknown) => String(e).toLowerCase()));
    const { data: list } = await q;
    const sent = [];
    for (const v of list ?? []) if (await sendLink(supabase, v)) sent.push(maskEmail(v.email));
    return reply({ ok: true, sent });
  }

  if (body.action === "load") {
    const token = String(body.token ?? "");
    if (!/^[0-9a-f]{64}$/.test(token)) return reply({ ok: false, error: "This link isn't valid. Ask for a new one below." }, 401);
    const { data: v } = await supabase.from("rti_fin_viewers").select("id, full_name, title").contains("token_hashes", [await sha256(token)]).maybeSingle();
    if (!v) return reply({ ok: false, error: "This link isn't valid. Ask for a new one below." }, 401);
    await supabase.from("rti_fin_viewers").update({ last_viewed_at: new Date().toISOString() }).eq("id", v.id);
    const { data: books } = await supabase.from("rti_fin_books").select("data, updated_at").eq("id", BOOKS_ID).maybeSingle();
    if (!books) return reply({ ok: false, error: "The books haven't been loaded yet." }, 404);
    return reply({ ok: true, viewer: { full_name: v.full_name, title: v.title }, updated_at: books.updated_at, books: books.data });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});

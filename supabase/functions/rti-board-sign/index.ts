// Supabase Edge Function: rti-board-sign
// Behind /rti/board/sign/: each Ras Tafari Inc. director reads a packet of
// board documents and signs it from a personal link (?t=TOKEN, emailed by
// Resend). Only the token's hash is stored; a new invite replaces the old link.
//
//   { action: "load", token }     The packet, every director's status and, once
//       signed, their signature (so the signed packet can be printed).
//   { action: "sign", token, typed_name, signature, doc_hash, esign, attest, conflict }
//       Records the signature with time, IP and browser. When the last director
//       signs, the packet is marked complete and everyone is emailed.
//   { action: "invite", token }   Admin signers only: emails a fresh link to every
//       director who hasn't signed yet (except the admin).
//   { action: "bootstrap", secret, packet }   From the CLI (RTI_SIGN_ADMIN_SECRET):
//       emails the admin signer(s) their link to start a packet.
//
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, RTI_SIGN_ADMIN_SECRET.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const PAGE_URL = "https://selassiefest.com/rti/board/sign/";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const MAX_SIG_CHARS = 300_000;

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
const firstName = (n: string) => n.split(/\s+/)[0];

async function sendEmail(to: string, subject: string, text: string, html: string) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM_EMAIL, to: [to], subject, text, html }),
  });
  if (!res.ok) console.error("rti-board-sign: resend error", res.status, (await res.text()).slice(0, 300));
  return res.ok;
}

// Mint a fresh link for a signer (replacing any old one) and email it
async function invite(supabase: any, packet: any, s: any, from: string) {
  const token = randomHex(32);
  const { error } = await supabase.from("rti_sign_signers")
    .update({ token_hash: await sha256(token), invited_at: new Date().toISOString() }).eq("id", s.id);
  if (error) { console.error("rti-board-sign: token update failed", error.code); return false; }
  const link = `${PAGE_URL}?t=${token}`;
  const subject = `Please review and sign: ${packet.title}`;
  const text = `Hello ${firstName(s.full_name)},\n\n${from} has sent you Ras Tafari Inc. board documents to review and sign as ${s.title}:\n\n${packet.title}\n\nOpen your personal signing link (don't forward it, it signs as you):\n${link}\n\nRead each document, then sign at the bottom of the page. Once every director has signed, the page lets you print or save the signed packet as a PDF.\n\nQuestions: stephen@selassiefest.com or (872) 255-9333.\n`;
  const html = `<p>Hello ${esc(firstName(s.full_name))},</p><p>${esc(from)} has sent you Ras Tafari Inc. board documents to review and sign as <b>${esc(s.title)}</b>:</p><p style="font-size:18px;font-weight:700">${esc(packet.title)}</p><p><a href="${link}" style="display:inline-block;background:#1f5b3a;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none;font-weight:700">Review and sign</a></p><p>This link is personal: it signs as you, so please don't forward it. Read each document, then sign at the bottom of the page. Once every director has signed, the page lets you print or save the signed packet as a PDF.</p><p style="color:#666;font-size:13px">Questions: stephen@selassiefest.com or (872) 255-9333.</p>`;
  return await sendEmail(s.email, subject, text, html);
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  if (!RESEND_API_KEY) return reply({ ok: false, error: "Signing is paused right now." }, 500);

  const raw = await req.text();
  if (raw.length > MAX_SIG_CHARS + 5000) return reply({ ok: false, error: "That signature is too large. Clear it and sign again." }, 413);
  let body: Record<string, any>;
  try { body = JSON.parse(raw || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);

  // ---- CLI: start a packet by emailing its admin signer(s) ----
  if (body.action === "bootstrap") {
    if (!ADMIN_SECRET || String(body.secret ?? "") !== ADMIN_SECRET) return reply({ ok: false, error: "Not allowed." }, 403);
    const { data: packet } = await supabase.from("rti_sign_packets").select("*").eq("id", String(body.packet ?? "")).maybeSingle();
    if (!packet) return reply({ ok: false, error: "No such packet." }, 404);
    const { data: admins } = await supabase.from("rti_sign_signers").select("*").eq("packet_id", packet.id).eq("is_admin", true);
    const sent = [];
    for (const s of admins ?? []) if (await invite(supabase, packet, s, "Ras Tafari Inc.")) sent.push(maskEmail(s.email));
    return reply({ ok: true, sent });
  }

  // ---- Everything else is by personal link ----
  const token = String(body.token ?? "");
  if (!/^[0-9a-f]{64}$/.test(token)) return reply({ ok: false, error: "This signing link isn't valid. Use the newest link from your email." }, 401);
  const { data: me } = await supabase.from("rti_sign_signers").select("*").eq("token_hash", await sha256(token)).maybeSingle();
  if (!me) return reply({ ok: false, error: "This signing link has expired or been replaced. Use the newest link from your email." }, 401);
  const { data: packet } = await supabase.from("rti_sign_packets").select("*").eq("id", me.packet_id).maybeSingle();
  if (!packet) return reply({ ok: false, error: "This packet no longer exists." }, 404);
  const loadSigners = async () => (await supabase.from("rti_sign_signers").select("*").eq("packet_id", packet.id).order("sort")).data ?? [];

  if (body.action === "load") {
    if (!me.viewed_at) await supabase.from("rti_sign_signers").update({ viewed_at: new Date().toISOString() }).eq("id", me.id);
    const signers = (await loadSigners()).map((s: any) => ({
      sort: s.sort, full_name: s.full_name, title: s.title, email: maskEmail(s.email),
      invited_at: s.invited_at, viewed_at: s.id === me.id ? (s.viewed_at ?? new Date().toISOString()) : s.viewed_at,
      signed_at: s.signed_at, typed_name: s.signed_at ? s.typed_name : null,
      signature_png: s.signed_at ? s.signature_png : null, conflict: s.signed_at ? s.conflict : null,
      doc_hash_signed: s.doc_hash_signed, ip: s.signed_at ? s.ip : null,
    }));
    return reply({
      ok: true,
      packet: { id: packet.id, title: packet.title, docs: packet.docs, doc_hash: packet.doc_hash, completed_at: packet.completed_at },
      me: { sort: me.sort, full_name: me.full_name, title: me.title, is_admin: me.is_admin, signed_at: me.signed_at },
      signers,
    });
  }

  if (body.action === "sign") {
    if (me.signed_at) return reply({ ok: false, error: "You've already signed this packet." }, 409);
    const typed = String(body.typed_name ?? "").trim().replace(/\s+/g, " ").slice(0, 120);
    const sig = String(body.signature ?? "");
    const conflict = String(body.conflict ?? "").trim().slice(0, 1000);
    if (body.esign !== true || body.attest !== true) return reply({ ok: false, error: "Please tick both boxes above the Sign button." }, 400);
    if (typed.length < 3) return reply({ ok: false, error: "Type your full name." }, 400);
    const last = me.full_name.split(/\s+/).pop()!.toLowerCase();
    if (!typed.toLowerCase().includes(last)) return reply({ ok: false, error: `Type your full name as it appears on the packet (${me.full_name}).` }, 400);
    if (!/^data:image\/png;base64,[A-Za-z0-9+/=]+$/.test(sig) || sig.length < 400) return reply({ ok: false, error: "Draw your signature in the box first." }, 400);
    if (!conflict) return reply({ ok: false, error: "Answer the conflict-of-interest question." }, 400);
    if (String(body.doc_hash ?? "") !== packet.doc_hash) return reply({ ok: false, reload: true, error: "The documents changed since you opened them. Reload the page and read them again before signing." }, 409);

    const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
    const now = new Date().toISOString();
    const { data: updated, error } = await supabase.from("rti_sign_signers").update({
      signed_at: now, typed_name: typed, signature_png: sig, conflict, doc_hash_signed: packet.doc_hash,
      ip, user_agent: (req.headers.get("user-agent") || "").slice(0, 300),
    }).eq("id", me.id).is("signed_at", null).select("id");
    if (error || !updated?.length) { console.error("rti-board-sign: sign failed", error?.code); return reply({ ok: false, error: "Couldn't save your signature. Please try again." }, 500); }

    const signers = await loadSigners();
    const remaining = signers.filter((s: any) => !s.signed_at);
    const admins = signers.filter((s: any) => s.is_admin && s.id !== me.id);
    const disclosed = conflict.toLowerCase() === "none" ? "No conflict of interest." : `Conflict disclosure: ${conflict}`;

    if (remaining.length === 0) {
      await supabase.from("rti_sign_packets").update({ completed_at: now }).eq("id", packet.id).is("completed_at", null);
      for (const s of signers) {
        await sendEmail(s.email, `Signed by all directors: ${packet.title}`,
          `Hello ${firstName(s.full_name)},\n\nAll ${signers.length} directors have signed "${packet.title}". The last signature was ${me.full_name}'s.\n\nTo print or save the signed packet as a PDF, open the signing link from your earlier email and press "Print / save signed PDF".\n\nThe Secretary files the signed packet in the corporate records book (Bylaws, Article XIV).\n`,
          `<p>Hello ${esc(firstName(s.full_name))},</p><p>All ${signers.length} directors have signed <b>${esc(packet.title)}</b>. The last signature was ${esc(me.full_name)}'s.</p><p>To print or save the signed packet as a PDF, open the signing link from your earlier email and press <b>Print / save signed PDF</b>.</p><p style="color:#666;font-size:13px">The Secretary files the signed packet in the corporate records book (Bylaws, Article XIV).</p>`);
      }
    } else {
      for (const a of admins) {
        await sendEmail(a.email, `${me.full_name} signed: ${packet.title}`,
          `${me.full_name} (${me.title}) signed "${packet.title}".\n${disclosed}\n\nStill to sign: ${remaining.map((s: any) => s.full_name).join(", ")}.\n`,
          `<p><b>${esc(me.full_name)}</b> (${esc(me.title)}) signed <b>${esc(packet.title)}</b>.</p><p>${esc(disclosed)}</p><p>Still to sign: ${esc(remaining.map((s: any) => s.full_name).join(", "))}.</p>`);
      }
    }
    return reply({ ok: true, complete: remaining.length === 0 });
  }

  if (body.action === "invite") {
    if (!me.is_admin) return reply({ ok: false, error: "Only the President can send signing links." }, 403);
    const targets = (await loadSigners()).filter((s: any) => !s.signed_at && !s.is_admin);
    const sent = [];
    for (const s of targets) if (await invite(supabase, packet, s, me.full_name)) sent.push(s.full_name);
    return reply({ ok: true, sent });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});

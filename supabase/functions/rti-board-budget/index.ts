// Supabase Edge Function: rti-board-budget
// Behind /rti/board/budget/: the Ras Tafari Inc. board discusses and decides
// the budget of each Friday series (e.g. The Ultimate Friday Lime at ILU Club).
//
//   { action: "link", email }   Public: if the email belongs to a director on
//       rti_bb_members, emails them a personal link. Same reply either way.
//   { action: "load", token }   Every series with its budget, discussion, votes and
//       recent edit history. The page polls this every 20s, which also marks the
//       director as "on the page now".
//   { action: "comment", token, series_id, body }   Adds to the discussion and
//       emails the other directors that there is something new to read.
//   { action: "vote", token, series_id, vote, note }   approve | reject | abstain.
//   { action: "save", token, series, base_updated_at, new_series }   Any director:
//       create or change a series (title, venue, status, fridays_per_year, budget
//       lines, notes). Logged with before/after. Refused if someone else saved
//       since base_updated_at, so two people editing at once never overwrite.
//   { action: "invite", secret, emails? }   From the CLI (RTI_SIGN_ADMIN_SECRET):
//       emails a link to each listed director (or all of them).
//
// Links never expire; every link sent stays valid. Only hashes are stored.
// Deploy with --no-verify-jwt. Secrets: RESEND_API_KEY, RTI_SIGN_ADMIN_SECRET.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const PAGE_URL = "https://selassiefest.com/rti/board/budget/";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const STATUSES = ["discussion", "approved", "rejected", "tabled"];
const VOTES = ["approve", "reject", "abstain"];

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
  if (!RESEND_API_KEY) return false;
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM_EMAIL, to: [to], subject, text, html }),
  });
  if (!res.ok) console.error("rti-board-budget: resend error", res.status);
  return res.ok;
}

async function sendLink(supabase: any, m: any) {
  const token = randomHex(32);
  const hashes = [...(m.token_hashes ?? []), await sha256(token)].slice(-20);
  const { error } = await supabase.from("rti_bb_members").update({ token_hashes: hashes, last_sent_at: new Date().toISOString() }).eq("id", m.id);
  if (error) { console.error("rti-board-budget: token save failed", error.code); return false; }
  const link = `${PAGE_URL}?t=${token}`;
  const first = firstName(m.full_name);
  const text = `Hello ${first},\n\nHere is your personal link to the Ras Tafari Inc. board budget room, where the board discusses and decides the budget for each Friday series:\n\n${link}\n\nThe link is personal to you as ${m.title}; please don't forward it. It keeps working, so you can bookmark it.\n\nQuestions: stephen@selassiefest.com or (872) 255-9333.\n`;
  const html = `<p>Hello ${esc(first)},</p><p>Here is your personal link to the <b>Ras Tafari Inc. board budget room</b>, where the board discusses and decides the budget for each Friday series.</p><p><a href="${link}" style="display:inline-block;background:#1f5b3a;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none;font-weight:700">Open the budget room</a></p><p>The link is personal to you as ${esc(m.title)}; please don't forward it. It keeps working, so you can bookmark it.</p><p style="color:#666;font-size:13px">Questions: stephen@selassiefest.com or (872) 255-9333.</p>`;
  return sendEmail(m.email, "Your link: RTI board budget room", text, html);
}

// Budget lines: [{label, amount|null, note}], capped and cleaned.
function cleanLines(v: unknown) {
  if (!Array.isArray(v)) return [];
  return v.slice(0, 60).map((l: any) => {
    const label = String(l?.label ?? "").trim().slice(0, 120);
    const raw = l?.amount;
    const n = raw === null || raw === "" || raw === undefined ? null : Number(raw);
    const amount = n === null || !Number.isFinite(n) ? null : Math.round(Math.min(Math.max(n, -10_000_000), 10_000_000) * 100) / 100;
    return { label, amount, note: String(l?.note ?? "").trim().slice(0, 300) };
  }).filter((l) => l.label);
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
      const { data: m } = await supabase.from("rti_bb_members").select("*").eq("email", email).maybeSingle();
      if (m) await sendLink(supabase, m);
    }
    return reply({ ok: true, message: "If that email belongs to an RTI director, a link is on its way." });
  }

  if (body.action === "invite") {
    if (!ADMIN_SECRET || String(body.secret ?? "") !== ADMIN_SECRET) return reply({ ok: false, error: "Not allowed." }, 403);
    let q = supabase.from("rti_bb_members").select("*");
    if (Array.isArray(body.emails) && body.emails.length) q = q.in("email", body.emails.map((e: unknown) => String(e).toLowerCase()));
    const { data: list } = await q;
    const sent = [];
    for (const m of list ?? []) if (await sendLink(supabase, m)) sent.push(maskEmail(m.email));
    return reply({ ok: true, sent });
  }

  // Everything below needs a valid personal link.
  const token = String(body.token ?? "");
  const bad = () => reply({ ok: false, error: "This link isn't valid. Ask for a new one below." }, 401);
  if (!/^[0-9a-f]{64}$/.test(token)) return bad();
  const { data: me } = await supabase.from("rti_bb_members").select("id, full_name, title, email, is_editor").contains("token_hashes", [await sha256(token)]).maybeSingle();
  if (!me) return bad();

  const seriesExists = async (id: string) => {
    const { data } = await supabase.from("rti_bb_series").select("id, title").eq("id", id).maybeSingle();
    return data;
  };

  if (body.action === "load") {
    await supabase.from("rti_bb_members").update({ last_viewed_at: new Date().toISOString() }).eq("id", me.id);
    const [members, series, comments, votes, history] = await Promise.all([
      supabase.from("rti_bb_members").select("id, full_name, title, is_editor, last_viewed_at").order("id"),
      supabase.from("rti_bb_series").select("*").order("created_at"),
      supabase.from("rti_bb_comments").select("id, series_id, member_id, body, created_at").order("created_at"),
      supabase.from("rti_bb_votes").select("series_id, member_id, vote, note, updated_at"),
      supabase.from("rti_bb_history").select("id, series_id, member_id, before, after, created_at").order("created_at", { ascending: false }).limit(200),
    ]);
    if (members.error || series.error || comments.error || votes.error || history.error) return reply({ ok: false, error: "Couldn't load the budget room. Try again." }, 500);
    return reply({
      ok: true,
      me: { id: me.id, full_name: me.full_name, title: me.title, is_editor: me.is_editor },
      members: members.data, series: series.data, comments: comments.data, votes: votes.data, history: history.data,
    });
  }

  if (body.action === "comment") {
    const text = String(body.body ?? "").trim().slice(0, 4000);
    const s = await seriesExists(String(body.series_id ?? ""));
    if (!s || !text) return reply({ ok: false, error: "Write something first." }, 400);
    const { error } = await supabase.from("rti_bb_comments").insert({ series_id: s.id, member_id: me.id, body: text });
    if (error) return reply({ ok: false, error: "Couldn't post that. Try again." }, 500);
    // Let the rest of the board know (no link in the email: they use their bookmarked one).
    const { data: others } = await supabase.from("rti_bb_members").select("full_name, email").neq("id", me.id);
    const preview = text.length > 600 ? text.slice(0, 600) + "…" : text;
    await Promise.all((others ?? []).map((o: any) => sendEmail(
      o.email,
      `Board budget: ${me.full_name} commented on ${s.title}`,
      `Hello ${firstName(o.full_name)},\n\n${me.full_name} (${me.title}) wrote on ${s.title}:\n\n${preview}\n\nRead and reply: ${PAGE_URL}\n(If the page asks, enter your email and a fresh link arrives.)\n`,
      `<p>Hello ${esc(firstName(o.full_name))},</p><p><b>${esc(me.full_name)}</b> (${esc(me.title)}) wrote on <b>${esc(s.title)}</b>:</p><blockquote style="border-left:3px solid #1f5b3a;margin:0;padding:6px 12px;color:#333;white-space:pre-wrap">${esc(preview)}</blockquote><p><a href="${PAGE_URL}">Read and reply in the budget room</a>. If the page asks, enter your email and a fresh link arrives.</p>`,
    )));
    return reply({ ok: true });
  }

  if (body.action === "vote") {
    const vote = String(body.vote ?? "");
    const s = await seriesExists(String(body.series_id ?? ""));
    if (!s || !VOTES.includes(vote)) return reply({ ok: false, error: "Choose approve, reject or abstain." }, 400);
    const { error } = await supabase.from("rti_bb_votes").upsert({ series_id: s.id, member_id: me.id, vote, note: String(body.note ?? "").trim().slice(0, 1000), updated_at: new Date().toISOString() });
    if (error) return reply({ ok: false, error: "Couldn't record your vote. Try again." }, 500);
    return reply({ ok: true });
  }

  if (body.action === "save") {
    const x = body.series ?? {};
    const id = String(x.id ?? "").trim().toLowerCase();
    if (!/^[a-z0-9][a-z0-9-]{1,59}$/.test(id)) return reply({ ok: false, error: "The series needs a short id (letters, numbers, dashes)." }, 400);
    const title = String(x.title ?? "").trim().slice(0, 140);
    if (!title) return reply({ ok: false, error: "The series needs a title." }, 400);
    const fridays = Math.round(Number(x.fridays_per_year));
    const row = {
      id, title,
      venue: String(x.venue ?? "").trim().slice(0, 200),
      status: STATUSES.includes(x.status) ? x.status : "discussion",
      fridays_per_year: fridays >= 1 && fridays <= 53 ? fridays : 52,
      budget: { income: cleanLines(x.budget?.income), expense: cleanLines(x.budget?.expense), one_time: cleanLines(x.budget?.one_time) },
      notes: String(x.notes ?? "").slice(0, 8000),
      updated_at: new Date().toISOString(),
      updated_by: me.id,
    };
    const { data: cur } = await supabase.from("rti_bb_series").select("title, venue, status, fridays_per_year, budget, notes, updated_at, updated_by").eq("id", id).maybeSingle();
    if (cur && body.new_series) return reply({ ok: false, error: "A series with that short id already exists. Pick another id." }, 409);
    if (cur && body.base_updated_at && new Date(cur.updated_at).getTime() !== new Date(String(body.base_updated_at)).getTime()) {
      const { data: who } = await supabase.from("rti_bb_members").select("full_name").eq("id", cur.updated_by).maybeSingle();
      return reply({ ok: false, conflict: true, error: `${who?.full_name ?? "Another director"} saved changes to this budget while you were editing, so yours were not saved. Note your changes, press Cancel to see the new numbers, then edit again.` }, 409);
    }
    const before = cur ? { title: cur.title, venue: cur.venue, status: cur.status, fridays_per_year: cur.fridays_per_year, budget: cur.budget, notes: cur.notes } : null;
    const { error } = await supabase.from("rti_bb_series").upsert(row);
    if (error) return reply({ ok: false, error: "Couldn't save. Try again." }, 500);
    const { id: _i, updated_at: _u, updated_by: _b, ...after } = row;
    await supabase.from("rti_bb_history").insert({ series_id: id, member_id: me.id, before: before ?? null, after });
    return reply({ ok: true });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});

// Supabase Edge Function: cert-hub
// Private, encrypted client files for the Certification Hub (/rti/certify/).
//
// Client (personal link /rti/certify/?k=KEY, only sha256(KEY) is stored):
//   { action: "load", key }                          -> { ok, client, profile, version, updated_at }
//   { action: "save", key, profile, summary, version } -> { ok, version }   (optimistic concurrency)
//   { action: "extract", key, files:[{media_type,data}] } -> { ok, data }   Claude reads uploaded IRS / ilsos.gov images or PDFs
//        and returns structured facts. Files are processed in memory and never stored. SSNs are never returned.
// Staff (RTI_SIGN_ADMIN_SECRET, the same admin secret used by the other RTI tools):
//   { action: "admin_list", secret }
//   { action: "admin_create", secret, name, email, note? }  -> { ok, link }  (link shown once)
//   { action: "admin_get", secret, id }                     -> client + decrypted profile
//   { action: "admin_save", secret, id, profile, summary, version }
//   { action: "admin_rotate", secret, id }                  -> { ok, link }  (old link stops working)
//   { action: "admin_active", secret, id, active }          -> turn a client's access on/off
//   { action: "admin_extract", secret, id, files }       same as extract, for staff
//   { action: "admin_email", secret, id }                   -> rotates the key and emails the link to the client
//
// The whole profile is AES-GCM encrypted with CERT_HUB_KEY (base64, 32 bytes) before it is stored;
// the database never sees the contents. Social Security numbers are refused.
// Deploy with --no-verify-jwt. Secrets: CERT_HUB_KEY, RTI_SIGN_ADMIN_SECRET, RESEND_API_KEY (email only).
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const ADMIN_SECRET = Deno.env.get("RTI_SIGN_ADMIN_SECRET") ?? "";
const HUB_KEY = Deno.env.get("CERT_HUB_KEY") ?? "";
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const ANTHROPIC_API_KEY = Deno.env.get("ANTHROPIC_API_KEY") ?? "";
const EXTRACT_MODEL = Deno.env.get("CERT_HUB_MODEL") ?? "claude-sonnet-5-5";
const MAX_EXTRACTS_PER_DAY = 10;
const MAX_FILES = 6;
const MAX_FILE_B64 = 7_000_000;

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const PAGE_URL = "https://selassiefest.com/rti/certify/";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const MAX_PROFILE_BYTES = 900_000;

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}

const enc = new TextEncoder();
const dec = new TextDecoder();
async function sha256(text: string) {
  const buf = await crypto.subtle.digest("SHA-256", enc.encode(text));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}
const randomHex = (n: number) => Array.from(crypto.getRandomValues(new Uint8Array(n))).map((b) => b.toString(16).padStart(2, "0")).join("");
const b64 = (u: Uint8Array) => { let s = ""; for (let i = 0; i < u.length; i += 0x8000) s += String.fromCharCode(...u.subarray(i, i + 0x8000)); return btoa(s); };
const unb64 = (s: string) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));
const isEmail = (s: string) => /^[^\s@<>()",;:]+@[^\s@<>()",;:]+\.[^\s@<>()",;:]+$/.test(s);
const clean = (v: unknown, max = 200) => String(v ?? "").replace(/[\r\n\t]+/g, " ").trim().slice(0, max);

let _key: CryptoKey | null = null;
async function aesKey() {
  if (_key) return _key;
  _key = await crypto.subtle.importKey("raw", unb64(HUB_KEY), "AES-GCM", false, ["encrypt", "decrypt"]);
  return _key;
}
async function encrypt(clientId: string, obj: unknown) {
  const iv = crypto.getRandomValues(new Uint8Array(12));
  const ct = new Uint8Array(await crypto.subtle.encrypt({ name: "AES-GCM", iv, additionalData: enc.encode(clientId) }, await aesKey(), enc.encode(JSON.stringify(obj))));
  return { iv: b64(iv), ciphertext: b64(ct) };
}
async function decrypt(clientId: string, row: { iv: string; ciphertext: string }) {
  const pt = await crypto.subtle.decrypt({ name: "AES-GCM", iv: unb64(row.iv), additionalData: enc.encode(clientId) }, await aesKey(), unb64(row.ciphertext));
  return JSON.parse(dec.decode(pt));
}

// Social Security numbers are never stored: refuse anything shaped like one.
const SSN = /\b\d{3}[- ]\d{2}[- ]\d{4}\b|\b\d{9}\b/;
function hasSSN(profile: unknown) {
  const text = JSON.stringify(profile);
  // EINs look like 00-0000000 (2-7), which the patterns above do not match.
  return SSN.test(text);
}

const EXTRACT_SYSTEM = `You read screenshots and PDFs of PUBLIC business records and IRS letters for a business-certification intake. Return ONLY one JSON object, no prose.
Rules: copy only what is visibly printed; use null for anything not visible; never guess. Dates as YYYY-MM-DD. Money as plain numbers (no $ or commas).
NEVER output a Social Security number, ITIN, bank account number or date of birth, even if visible: omit them.
Identify each file in "documents" with kind: sos_entity (Illinois Secretary of State entity page), sos_file_history, sos_managers, sos_reinstatement, irs_ein_letter (CP 575 / 147C), irs_return_transcript, irs_account_transcript, irs_other, other.
Schema:
{"documents":[{"file":1,"kind":"","confidence":"high|medium|low","note":""}],
"sos":{"entityName":null,"fileNumber":null,"status":null,"statusDate":null,"entityType":null,"llcType":null,"jurisdiction":null,"orgDate":null,"duration":null,"annualReportDate":null,"annualReportYear":null,"principalAddress":{"street":null,"city":null,"state":null,"zip":null},"agent":{"name":null,"street":null,"city":null,"state":null,"zip":null,"changedDate":null},"managers":[{"name":null}],"filings":[{"form":"LLC-50.1","date":"YYYY-MM-DD"}],"assumedNames":[],"oldNames":[]},
"irs":{"ein":null,"legalName":null,"address":{"street":null,"city":null,"state":null,"zip":null},"letterType":null,"letterDate":null,"taxClassification":null,"taxPeriods":[{"year":null,"form":null,"grossReceipts":null,"totalIncome":null,"filedDate":null}]}}`;

const SSN_RE = /\b\d{3}[- ]\d{2}[- ]\d{4}\b/g;
function scrub(v: unknown): unknown {
  if (typeof v === "string") return v.replace(SSN_RE, "[removed]");
  if (Array.isArray(v)) return v.map(scrub);
  if (v && typeof v === "object") return Object.fromEntries(Object.entries(v as Record<string, unknown>).map(([k, x]) => [k, scrub(x)]));
  return v;
}
async function claudeRead(files: { media_type: string; data: string }[]) {
  const content: any[] = [];
  for (const f of files) {
    if (f.media_type === "application/pdf") content.push({ type: "document", source: { type: "base64", media_type: "application/pdf", data: f.data } });
    else content.push({ type: "image", source: { type: "base64", media_type: f.media_type, data: f.data } });
  }
  content.push({ type: "text", text: "Read these " + files.length + " file(s) in order (file 1 is first) and return the JSON object." });
  const res = await fetch("https://api.anthropic.com/v1/messages", {
    method: "POST",
    headers: { "x-api-key": ANTHROPIC_API_KEY, "anthropic-version": "2023-06-01", "content-type": "application/json" },
    body: JSON.stringify({ model: EXTRACT_MODEL, max_tokens: 3000, system: EXTRACT_SYSTEM, messages: [{ role: "user", content }] }),
  });
  if (!res.ok) { const bodyText = (await res.text()).slice(0, 300); console.error("cert-hub: anthropic error", res.status, bodyText); let msg = ""; try { msg = JSON.parse(bodyText)?.error?.message ?? ""; } catch { /* ignore */ } return { error: res.status + " " + msg.slice(0, 160) }; }
  const j = await res.json();
  const text = (j.content ?? []).map((c: any) => c.text ?? "").join("");
  const m = text.match(/\{[\s\S]*\}/);
  if (!m) return { error: "unreadable" };
  try { return { data: scrub(JSON.parse(m[0])) }; } catch { return { error: "unreadable" }; }
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  if (!HUB_KEY) return reply({ ok: false, error: "The Hub is not configured yet." }, 503);

  let body: Record<string, any>;
  try { body = JSON.parse((await req.text()) || "{}"); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  const audit = (client_id: string, action: string, actor = "client") => supabase.from("cert_audit").insert({ client_id, action, actor }).then(() => {}, () => {});

  const isAdmin = String(body.action ?? "").startsWith("admin_");
  if (isAdmin && (!ADMIN_SECRET || String(body.secret ?? "") !== ADMIN_SECRET)) return reply({ ok: false, error: "Not allowed." }, 403);

  async function newLink(id: string) {
    const key = randomHex(32);
    const { error } = await supabase.from("cert_clients").update({ token_hash: await sha256(key) }).eq("id", id);
    if (error) return null;
    return `${PAGE_URL}?k=${key}`;
  }
  async function clientByKey(key: string) {
    if (!/^[0-9a-f]{64}$/.test(key)) return null;
    const { data } = await supabase.from("cert_clients").select("id, name, active").eq("token_hash", await sha256(key)).maybeSingle();
    return data && data.active ? data : null;
  }
  async function saveProfile(id: string, profile: unknown, summary: unknown, version: number, by: string) {
    if (!profile || typeof profile !== "object") return { status: 400, out: { ok: false, error: "Nothing to save." } };
    if (JSON.stringify(profile).length > MAX_PROFILE_BYTES) return { status: 413, out: { ok: false, error: "That file is too large to save." } };
    if (hasSSN(profile)) return { status: 422, out: { ok: false, error: "Something looks like a Social Security number. Remove it: the Hub never stores SSNs. Write those in by hand on the printed forms." } };
    const { data: cur } = await supabase.from("cert_profiles").select("version").eq("client_id", id).maybeSingle();
    const sum = summary && typeof summary === "object" ? summary : {};
    const e = await encrypt(id, profile);
    if (!cur) {
      const { error } = await supabase.from("cert_profiles").insert({ client_id: id, ...e, version: 1, summary: sum, updated_by: by });
      if (error) return { status: 500, out: { ok: false, error: "Could not save." } };
      return { status: 200, out: { ok: true, version: 1 } };
    }
    if (Number(version) !== cur.version) return { status: 409, out: { ok: false, conflict: true, version: cur.version, error: "This file was changed somewhere else. Reload to get the latest, then redo your last edit." } };
    const next = cur.version + 1;
    const { error } = await supabase.from("cert_profiles").update({ ...e, version: next, summary: sum, updated_at: new Date().toISOString(), updated_by: by }).eq("client_id", id).eq("version", cur.version);
    if (error) return { status: 500, out: { ok: false, error: "Could not save." } };
    return { status: 200, out: { ok: true, version: next } };
  }

  async function extractFor(clientId: string, files: unknown, actor: string) {
    if (!ANTHROPIC_API_KEY) return reply({ ok: false, error: "Reading documents is not configured yet." }, 503);
    if (!Array.isArray(files) || !files.length) return reply({ ok: false, error: "Add at least one image or PDF." }, 400);
    if (files.length > MAX_FILES) return reply({ ok: false, error: "Please send " + MAX_FILES + " files or fewer at a time." }, 400);
    const ok = new Set(["image/jpeg", "image/png", "image/webp", "image/gif", "application/pdf"]);
    for (const f of files as any[]) {
      if (!f || !ok.has(String(f.media_type)) || typeof f.data !== "string" || !/^[A-Za-z0-9+/=]+$/.test(f.data)) return reply({ ok: false, error: "Only JPEG, PNG, WebP, GIF or PDF files can be read." }, 400);
      if (f.data.length > MAX_FILE_B64) return reply({ ok: false, error: "One of the files is too large. Use a smaller screenshot or fewer PDF pages." }, 413);
    }
    const since = new Date(Date.now() - 24 * 3600 * 1000).toISOString();
    const { count } = await supabase.from("cert_audit").select("id", { count: "exact", head: true }).eq("client_id", clientId).eq("action", "extract").gte("at", since);
    if ((count ?? 0) >= MAX_EXTRACTS_PER_DAY) return reply({ ok: false, error: "The daily limit for reading documents was reached. Try again tomorrow, or enter the answers by hand." }, 429);
    await audit(clientId, "extract", actor);
    const r = await claudeRead(files as any);
    if ((r as any).error) return reply({ ok: false, detail: String((r as any).error), error: "The documents could not be read. Try a clearer, larger screenshot." }, 502);
    return reply({ ok: true, data: (r as any).data });
  }
  if (body.action === "extract") {
    const c = await clientByKey(String(body.key ?? ""));
    if (!c) return reply({ ok: false, error: "This link isn't valid. Ask for a new one." }, 401);
    return await extractFor(c.id, body.files, "client");
  }
  if (body.action === "admin_extract") {
    const id = String(body.id ?? "");
    const { data: c } = await supabase.from("cert_clients").select("id").eq("id", id).maybeSingle();
    if (!c) return reply({ ok: false, error: "No such client." }, 404);
    return await extractFor(id, body.files, "staff");
  }

  // ---------------- client ----------------
  if (body.action === "load") {
    const c = await clientByKey(String(body.key ?? ""));
    if (!c) return reply({ ok: false, error: "This link isn't valid. Ask for a new one." }, 401);
    await supabase.from("cert_clients").update({ last_seen_at: new Date().toISOString() }).eq("id", c.id);
    const { data: row } = await supabase.from("cert_profiles").select("*").eq("client_id", c.id).maybeSingle();
    await audit(c.id, "load");
    if (!row) return reply({ ok: true, client: { name: c.name }, profile: null, version: 0 });
    try { return reply({ ok: true, client: { name: c.name }, profile: await decrypt(c.id, row), version: row.version, updated_at: row.updated_at }); }
    catch { return reply({ ok: false, error: "Could not open your file." }, 500); }
  }
  if (body.action === "save") {
    const c = await clientByKey(String(body.key ?? ""));
    if (!c) return reply({ ok: false, error: "This link isn't valid. Ask for a new one." }, 401);
    const r = await saveProfile(c.id, body.profile, body.summary, Number(body.version ?? 0), "client");
    if (r.out.ok) await audit(c.id, "save");
    return reply(r.out, r.status);
  }

  // ---------------- staff ----------------
  if (body.action === "admin_list") {
    const { data: clients } = await supabase.from("cert_clients").select("id, name, email, note, active, created_at, last_seen_at, last_sent_at").order("created_at", { ascending: false });
    const { data: profs } = await supabase.from("cert_profiles").select("client_id, version, summary, updated_at, updated_by");
    const by: Record<string, any> = {}; for (const p of profs ?? []) by[p.client_id] = p;
    return reply({ ok: true, clients: (clients ?? []).map((c: any) => ({ ...c, profile: by[c.id] ?? null })) });
  }
  if (body.action === "admin_create") {
    const name = clean(body.name, 120), email = clean(body.email, 200).toLowerCase();
    if (!name || !isEmail(email)) return reply({ ok: false, error: "Name and a valid email are required." }, 400);
    const { data: c, error } = await supabase.from("cert_clients").insert({ name, email, note: clean(body.note, 400) || null }).select("id").single();
    if (error || !c) return reply({ ok: false, error: error?.code === "23505" ? "A client with that email already exists." : "Could not create the client." }, 400);
    const link = await newLink(c.id);
    await audit(c.id, "created", "staff");
    return reply({ ok: true, id: c.id, link });
  }
  if (body.action === "admin_get") {
    const id = String(body.id ?? "");
    const { data: c } = await supabase.from("cert_clients").select("id, name, email, active").eq("id", id).maybeSingle();
    if (!c) return reply({ ok: false, error: "No such client." }, 404);
    const { data: row } = await supabase.from("cert_profiles").select("*").eq("client_id", id).maybeSingle();
    await audit(id, "staff_view", "staff");
    if (!row) return reply({ ok: true, client: c, profile: null, version: 0 });
    try { return reply({ ok: true, client: c, profile: await decrypt(id, row), version: row.version, updated_at: row.updated_at }); }
    catch { return reply({ ok: false, error: "Could not open that file." }, 500); }
  }
  if (body.action === "admin_save") {
    const id = String(body.id ?? "");
    const { data: c } = await supabase.from("cert_clients").select("id").eq("id", id).maybeSingle();
    if (!c) return reply({ ok: false, error: "No such client." }, 404);
    const r = await saveProfile(id, body.profile, body.summary, Number(body.version ?? 0), "staff");
    if (r.out.ok) await audit(id, "staff_save", "staff");
    return reply(r.out, r.status);
  }
  if (body.action === "admin_rotate") {
    const id = String(body.id ?? "");
    const link = await newLink(id);
    if (!link) return reply({ ok: false, error: "Could not make a new link." }, 400);
    await audit(id, "rotated", "staff");
    return reply({ ok: true, link });
  }
  if (body.action === "admin_active") {
    const id = String(body.id ?? "");
    await supabase.from("cert_clients").update({ active: body.active === true }).eq("id", id);
    await audit(id, body.active === true ? "enabled" : "disabled", "staff");
    return reply({ ok: true });
  }
  if (body.action === "admin_email") {
    if (!RESEND_API_KEY) return reply({ ok: false, error: "Email is not configured." }, 503);
    const id = String(body.id ?? "");
    const { data: c } = await supabase.from("cert_clients").select("id, name, email, active").eq("id", id).maybeSingle();
    if (!c || !c.active) return reply({ ok: false, error: "No such active client." }, 404);
    const link = await newLink(id);
    if (!link) return reply({ ok: false, error: "Could not make a new link." }, 400);
    const first = c.name.split(/\s+/)[0];
    const text = `Hello ${first},\n\nHere is your personal, private link to your certification workspace. Enter your information once and it fills every form that needs it:\n\n${link}\n\nThe link is personal to you; please don't forward it. It keeps working, so you can bookmark it. Please never type a Social Security number into it. You write those by hand on the printed forms.\n\nQuestions: stephen@selassiefest.com or (872) 255-9333.\n`;
    const html = `<p>Hello ${esc(first)},</p><p>Here is your personal, private link to your <b>certification workspace</b>. Enter your information once and it fills every form that needs it.</p><p><a href="${link}" style="display:inline-block;background:#1f5b3a;color:#fff;padding:12px 18px;border-radius:8px;text-decoration:none;font-weight:700">Open my workspace</a></p><p>The link is personal to you; please don't forward it. It keeps working, so you can bookmark it. Please never type a Social Security number into it: write those by hand on the printed forms.</p><p style="color:#666;font-size:13px">Questions: stephen@selassiefest.com or (872) 255-9333.</p>`;
    const res = await fetch("https://api.resend.com/emails", { method: "POST", headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" }, body: JSON.stringify({ from: FROM_EMAIL, to: [c.email], cc: ["stephen@selassiefest.com"], subject: "Your certification workspace link", text, html }) });
    if (!res.ok) { console.error("cert-hub: resend error", res.status); return reply({ ok: false, error: "The email could not be sent." }, 502); }
    await supabase.from("cert_clients").update({ last_sent_at: new Date().toISOString() }).eq("id", id);
    await audit(id, "emailed", "staff");
    return reply({ ok: true });
  }

  return reply({ ok: false, error: "Unknown action." }, 400);
});

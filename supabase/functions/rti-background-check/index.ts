// Supabase Edge Function: rti-background-check
// Receives a Ras Tafari Inc. member's filled-in Chicago Park District Long Term
// Adult Volunteer Application (PDF, built in the browser by
// /rti/background-check/) and emails it through Resend to the Park District's
// volunteer office, which then sends the member background check instructions.
//
// Recipients are fixed here on the server, so the page can't be used to mail
// anyone else. The PDF is never stored or logged: only the member's
// name, email, phone, RTI role and park go into rti_bgcheck_submissions, and a
// short notice (no PDF) goes to Stephen so RTI can see who has applied.
//
// Members only: every send needs a pass from rti-bgcheck-access (an emailed code
// to an rti_members address), and the member's copy goes to that verified email.
// Deploy with --no-verify-jwt; also protected by Turnstile, the honeypot, an
// origin check, a per-IP throttle and per-pass / per-day send limits.
//
// Secrets:
//   RESEND_API_KEY, TURNSTILE_SECRET_KEY (shared with other functions)
//   RTI_BGCHECK_TEST_RECIPIENT  optional. While set, every application goes ONLY
//                               to this address, marked [TEST]; nothing reaches
//                               the Park District and the member gets no copy.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY") ?? "";
const TURNSTILE_SECRET_KEY = Deno.env.get("TURNSTILE_SECRET_KEY") ?? "";
const TEST_RECIPIENT = (Deno.env.get("RTI_BGCHECK_TEST_RECIPIENT") ?? "").trim();

const FROM_EMAIL = "Ras Tafari Inc. <hello@selassiefest.com>";
const VOLUNTEERS = "volunteers@chicagoparkdistrict.com";
const STEWARDSHIP = "stewardship@chicagoparkdistrict.com";
const STAFF_TO = "stephen@selassiefest.com";
const STAFF_CC = ["paksipras@gmail.com"];

const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com"];
const ALLOWED_HOSTNAMES = ["selassiefest.com", "www.selassiefest.com"];
const PER_IP_PER_HOUR = 6;
const MAX_PDF_BYTES = 6 * 1024 * 1024;
const MAX_SENDS_PER_PASS = 2; // a send plus one corrected resend
const DRAFT_KEY = Deno.env.get("RTI_DRAFT_KEY") ?? "";

// After a live send, the member's saved draft (rti_bgcheck_drafts, encrypted by
// rti-bgcheck-access with the same key) keeps their answers but drops the SSN /
// license digits, and is marked sent.
async function scrubDraftAfterSend(supabase: any, email: string) {
  try {
    const { data: row } = await supabase.from("rti_bgcheck_drafts").select("*").eq("email", email).maybeSingle();
    if (!row || !DRAFT_KEY) return;
    const k = await crypto.subtle.importKey("raw", Uint8Array.from(atob(DRAFT_KEY), (c) => c.charCodeAt(0)), "AES-GCM", false, ["encrypt", "decrypt"]);
    const unb64 = (s: string) => Uint8Array.from(atob(s), (c) => c.charCodeAt(0));
    const b64 = (u: Uint8Array) => { let s = ""; for (let i = 0; i < u.length; i += 0x8000) s += String.fromCharCode(...u.subarray(i, i + 0x8000)); return btoa(s); };
    const draft = JSON.parse(new TextDecoder().decode(await crypto.subtle.decrypt({ name: "AES-GCM", iv: unb64(row.iv) }, k, unb64(row.ciphertext))));
    if (draft?.fields) { delete draft.fields.ssn; delete draft.fields.dl; }
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const ct = new Uint8Array(await crypto.subtle.encrypt({ name: "AES-GCM", iv }, k, new TextEncoder().encode(JSON.stringify(draft))));
    await supabase.from("rti_bgcheck_drafts").update({ iv: b64(iv), ciphertext: b64(ct), sent_at: new Date().toISOString() }).eq("email", email);
  } catch {
    console.error("rti-background-check: draft scrub failed");
  }
}

async function sha256(text: string) {
  const buf = await crypto.subtle.digest("SHA-256", new TextEncoder().encode(text));
  return Array.from(new Uint8Array(buf)).map((b) => b.toString(16).padStart(2, "0")).join("");
}

// The member picks one of these on the page; it completes "I am ___ with Ras Tafari Inc."
const RTI_ROLES = [
  "an officer or board member",
  "a program coach or instructor",
  "a volunteer",
  "a member of the sound and stage crew",
  "an associate",
];

function cors(req: Request) {
  const origin = req.headers.get("origin") || "";
  return {
    "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(origin) ? origin : ALLOWED_ORIGINS[0],
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
    "Access-Control-Allow-Methods": "POST, OPTIONS",
    Vary: "Origin",
  };
}

// One line, trimmed, length-capped: keeps form text out of email headers safely
const clean = (v: unknown, max = 200) => String(v ?? "").replace(/[\r\n\t]+/g, " ").trim().slice(0, max);
const isEmail = (s: string) => /^[^\s@<>()",;:]+@[^\s@<>()",;:]+\.[^\s@<>()",;:]+$/.test(s);
const esc = (s: string) => s.replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]!));

async function turnstileOk(token: string, ip: string): Promise<boolean> {
  const form = new FormData();
  form.append("secret", TURNSTILE_SECRET_KEY);
  form.append("response", token);
  if (ip !== "unknown") form.append("remoteip", ip);
  const res = await fetch("https://challenges.cloudflare.com/turnstile/v0/siteverify", { method: "POST", body: form });
  const out = await res.json();
  if (!out.success) console.warn("rti-background-check: turnstile failed", out["error-codes"]);
  return out.success === true && ALLOWED_HOSTNAMES.includes(out.hostname);
}

async function resend(payload: Record<string, unknown>) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify(payload),
  });
  if (!res.ok) {
    // Log only the status and Resend's error, never the application contents
    console.error("rti-background-check: resend error", res.status, (await res.text()).slice(0, 500));
    return null;
  }
  return await res.json().catch(() => ({}));
}

// Keep in step with emailBody() in /rti/background-check/index.html (the "send it yourself" fallback)
function emailBody(name: string, phone: string, email: string, rtiRole: string, park: string, stewardshipRole: string) {
  return `Hello,\n\n` +
    `Attached is my completed Long Term Adult Volunteer Application for the Park District background check. ` +
    `I am ${rtiRole} with Ras Tafari Inc., a 501(c)(3) nonprofit proposing youth and cultural programs at ${park}. ` +
    `Ras Tafari Inc. has asked all of its members and associates to complete the Park District's background check.` +
    (stewardshipRole
      ? ` I am also applying for a Community Stewardship role${stewardshipRole === "Not sure yet" ? "" : ` (${stewardshipRole})`}, so I've copied the Stewardship Program Manager and only need one background check.`
      : ``) +
    `\n\nPlease send me the background check instructions when you're ready.\n\n` +
    `Thank you,\n${name}\n${phone}\n${email}\n`;
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (body: unknown, status = 200) => new Response(JSON.stringify(body), { status, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ ok: false, error: "Use POST." }, 405);
  if (!RESEND_API_KEY || !TURNSTILE_SECRET_KEY) {
    console.error("rti-background-check: RESEND_API_KEY or TURNSTILE_SECRET_KEY is not set");
    return reply({ ok: false, error: "Sending is paused right now." }, 500);
  }

  let body: Record<string, any>;
  try { body = await req.json(); } catch { return reply({ ok: false, error: "Couldn't read the request." }, 400); }

  // Honeypot: real people never fill the hidden "website" field. Pretend success so bots move on.
  if (clean(body.website)) return reply({ ok: true, to: [VOLUNTEERS], cc: [] });

  if (!body.token) return reply({ ok: false, error: "Please wait for the security check to finish, then try again." }, 400);
  const ip = (req.headers.get("x-forwarded-for") || "").split(",")[0].trim() || "unknown";
  if (!(await turnstileOk(String(body.token), ip))) return reply({ ok: false, error: "We couldn't verify you're a person. Please try again." }, 400);

  // Members only: a pass from rti-bgcheck-access (code emailed to an rti_members address).
  // The member's copy always goes to that verified address, never to one typed in the form.
  const supabase = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
  const pass = clean(body.pass, 100);
  if (!/^[0-9a-f]{64}$/.test(pass)) return reply({ ok: false, error: "Please confirm your email again before sending.", relogin: true }, 401);
  const { data: session } = await supabase.from("rti_bgcheck_sessions").select("*").eq("token_hash", await sha256(pass)).maybeSingle();
  if (!session || new Date(session.expires_at) < new Date()) return reply({ ok: false, error: "Your sign-in expired. Confirm your email again, then send.", relogin: true }, 401);
  if (session.sends >= MAX_SENDS_PER_PASS) return reply({ ok: false, error: "This sign-in has already sent the most applications allowed. Email stephen@selassiefest.com if you need to resend." }, 429);
  // Open mode (secret RTI_BGCHECK_OPEN = "1"): any confirmed email may send, unless its rti_members row is switched off
  const { data: member } = await supabase.from("rti_members").select("active").eq("email", session.email).maybeSingle();
  if (member ? !member.active : Deno.env.get("RTI_BGCHECK_OPEN") !== "1") return reply({ ok: false, error: "This email isn't on the member list." }, 403);

  // And per member across sign-ins: at most 3 live sends a day (test sends don't count)
  const { count: todays } = await supabase.from("rti_bgcheck_submissions").select("*", { count: "exact", head: true })
    .eq("email", session.email).eq("test_mode", false).gte("created_at", new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString());
  if ((todays || 0) >= 3) return reply({ ok: false, error: "You've already sent your application today. Email stephen@selassiefest.com if you need to resend." }, 429);

  const name = clean(body.applicant?.name, 120);
  const email = session.email as string;
  const phone = clean(body.applicant?.phone, 40);
  const park = clean(body.park, 120);
  const rtiRole = clean(body.rtiRole, 80);
  const stewardshipRole = clean(body.stewardshipRole, 60);

  if (!name || !park) return reply({ ok: false, error: "Name and park are required." }, 400);
  if (!isEmail(email)) return reply({ ok: false, error: "That email address doesn't look right." }, 400);
  if (!RTI_ROLES.includes(rtiRole)) return reply({ ok: false, error: "Choose your role with Ras Tafari Inc." }, 400);

  const pdf = String(body.pdfBase64 ?? "").replace(/\s+/g, "");
  if (!pdf.startsWith("JVBER")) return reply({ ok: false, error: "The attachment isn't a PDF." }, 400); // "%PDF" in base64
  if ((pdf.length * 3) / 4 > MAX_PDF_BYTES) return reply({ ok: false, error: "The PDF is too large." }, 413);

  const since = new Date(Date.now() - 60 * 60 * 1000).toISOString();
  const { count } = await supabase.from("verification_ip_rate_limits").select("*", { count: "exact", head: true })
    .eq("purpose", "rti-bgcheck").eq("ip", ip).gte("created_at", since);
  if ((count || 0) >= PER_IP_PER_HOUR) return reply({ ok: false, error: "Too many applications from this network. Please try again in an hour." }, 429);
  await supabase.from("verification_ip_rate_limits").insert({ ip, purpose: "rti-bgcheck" });

  let filename = clean(body.filename, 120).replace(/[^\w .,()'-]/g, "") || "Volunteer Application";
  if (!/\.pdf$/i.test(filename)) filename += ".pdf";

  const subject = `Long Term Adult Volunteer Application - ${name} - ${park} (Ras Tafari Inc.)`;
  const text = emailBody(name, phone, email, rtiRole, park, stewardshipRole);
  const liveTo = [VOLUNTEERS];
  const liveCc = [...(stewardshipRole ? [STEWARDSHIP] : []), email];
  const testing = TEST_RECIPIENT !== "";

  const payload: Record<string, unknown> = {
    from: FROM_EMAIL,
    to: testing ? [TEST_RECIPIENT] : liveTo,
    reply_to: email, // replies from the Park District go straight to the member
    subject: (testing ? "[TEST] " : "") + subject,
    text: testing ? `TEST MODE. In live mode this goes to ${liveTo.join(", ")}, cc ${liveCc.join(", ")}.\n\n${text}` : text,
    attachments: [{ filename, content: pdf }],
  };
  if (!testing) payload.cc = liveCc;

  const sent = await resend(payload);
  if (!sent) return reply({ ok: false, error: "The email service didn't accept the message." }, 502);
  await supabase.from("rti_bgcheck_sessions").update({ sends: session.sends + 1 }).eq("token_hash", session.token_hash);
  if (!testing) await scrubDraftAfterSend(supabase, email);

  // Who's done: a row for the tracker and a short notice to Stephen. Neither carries the application.
  const { error: logError } = await supabase.from("rti_bgcheck_submissions").insert({
    full_name: name, email, phone, rti_role: rtiRole, park, stewardship_role: stewardshipRole || null,
    test_mode: testing, resend_id: sent?.id ?? null,
  });
  if (logError) console.error("rti-background-check: log insert failed", logError.code);

  const when = new Date().toLocaleString("en-US", { timeZone: "America/Chicago", dateStyle: "medium", timeStyle: "short" });
  const rows: [string, string][] = [
    ["Name", name], ["Email", email], ["Phone", phone || "-"], ["Role", `${rtiRole} with Ras Tafari Inc.`],
    ["Park", park], ["Stewardship", stewardshipRole || "No"], ["Sent", `${when} (Chicago)`],
    ["Went to", testing ? `${TEST_RECIPIENT} only (test mode)` : [...liveTo, ...liveCc].join(", ")],
  ];
  await resend({
    from: "Ras Tafari Inc. <hello@selassiefest.com>",
    to: [STAFF_TO], cc: STAFF_CC,
    subject: `${testing ? "[TEST] " : ""}CPD background check application sent: ${name}`,
    text: `${name} sent their Chicago Park District volunteer application.\n\n` +
      rows.map(([k, v]) => `${k}: ${v}`).join("\n") +
      `\n\nThe application itself (date of birth, ID numbers, emergency contacts) went only to the Park District and the member. It isn't copied here.\n`,
    html: `<p><b>${esc(name)}</b> sent their Chicago Park District volunteer application.</p><table cellpadding="4">` +
      rows.map(([k, v]) => `<tr><td style="color:#666">${esc(k)}</td><td>${esc(v)}</td></tr>`).join("") +
      `</table><p style="color:#666;font-size:13px">The application itself (date of birth, ID numbers, emergency contacts) went only to the Park District and the member. It isn't copied here.</p>`,
  });

  return reply({ ok: true, id: sent?.id ?? null, test: testing, to: payload.to, cc: testing ? [] : liveCc, liveTo: [...liveTo, ...liveCc] });
});

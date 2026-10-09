// Rainbow DJ Lab session recaps. The coach taps "Email today's recaps" on the
// Coach tab; the page posts { session, cohort, unit, lesson } here. We check
// the coach session, read each opted-in family's kid for that unit (service
// role, djlab_recap_rows), and send one Resend email per family: the
// mission, the kid's prediction / self-rating / "next time" line, the
// coach's glow, Passport stamps, a Mix Log line and the dinner question.
// Each (kid, unit) is sent once (djlab_recaps_sent) unless resend=true.
// The lesson text (title, mission, dinner question, stamp checks) comes from
// the page's curriculum, which only a signed-in coach can trigger.
// Deploy with --no-verify-jwt.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "Rainbow DJ Lab <hello@selassiefest.com>";
const REPLY_TO = "stephen@selassiefest.com";
const ALLOWED_ORIGINS = ["https://selassiefest.com", "https://www.selassiefest.com", "http://localhost:8765"];

const COLORS: Record<string, string> = { red: "#E0453A", orange: "#F08A24", yellow: "#F2C230", green: "#2E9E58", blue: "#1E8FBF", indigo: "#3F48B8", violet: "#8E44AD" };
const LIGHT: Record<string, string> = { green: "I got it", yellow: "Getting there", red: "Not yet" };

function cors(req: Request) {
  const o = req.headers.get("origin") || "";
  return { "Access-Control-Allow-Origin": ALLOWED_ORIGINS.includes(o) ? o : ALLOWED_ORIGINS[0], "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type", "Access-Control-Allow-Methods": "POST, OPTIONS", Vary: "Origin" };
}
function esc(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}
function cap(s: string) { return s ? s.charAt(0).toUpperCase() + s.slice(1) : s; }

type Lesson = { label: string; color: string; title: string; mission: string; home: string; checks: string[] };

function recapHtml(kidName: string, guardian: string | null, l: Lesson, ci: Record<string, any>, stamps: boolean[], glow: string | null) {
  const first = esc(kidName.split(" ")[0]);
  const col = COLORS[l.color] || "#2F3DB5";
  const got = stamps.filter(Boolean).length;
  const facts: string[] = [];
  if (ci.predict) facts.push(`<li>Before starting, ${first} predicted today would be <b>${esc(ci.predict)}</b>.</li>`);
  if (ci.level) facts.push(`<li>In Deck Time, ${first} chose the <b>${esc(cap(ci.level))}</b> challenge.</li>`);
  if (ci.data) facts.push(`<li>${first} turned <b>${ci.data}</b> crash${ci.data > 1 ? "es" : ""} into “Data!”, our word for learning from a mistake.</li>`);
  if (ci.light) facts.push(`<li>At Check Out, ${first} rated the Mission: <b>${esc(LIGHT[ci.light] || ci.light)}</b>.</li>`);
  const mix = Array.isArray(ci.mixlog) && ci.mixlog.length ? ci.mixlog[ci.mixlog.length - 1] : null;
  return `
  <div style="font-family:Arial,Helvetica,sans-serif;max-width:560px;margin:0 auto;color:#16182B;">
    <div style="height:8px;background:linear-gradient(90deg,#E0453A,#F08A24,#F2C230,#2E9E58,#1E8FBF,#3F48B8,#8E44AD);"></div>
    <p style="font-size:12px;letter-spacing:2px;text-transform:uppercase;color:#7B7F93;margin:18px 0 4px;">Rainbow DJ Lab &middot; ${esc(l.label)}</p>
    <h1 style="font-size:22px;margin:0 0 6px;">${first}'s recap: <span style="color:${col};">${esc(l.title)}</span></h1>
    <p style="margin:0 0 14px;">${guardian ? "Hi " + esc(guardian.split(" ")[0]) + ", here" : "Here"}'s how today went.</p>
    <div style="border-left:5px solid ${col};background:#F7F5F0;padding:10px 14px;border-radius:8px;margin-bottom:14px;">
      <div style="font-size:11px;letter-spacing:1.5px;text-transform:uppercase;color:#7B7F93;">Today's Mission</div>
      <div style="font-weight:bold;font-size:16px;">${esc(l.mission)}</div>
    </div>
    ${facts.length ? `<ul style="padding-left:18px;margin:0 0 14px;line-height:1.6;">${facts.join("")}</ul>` : ""}
    ${ci.next ? `<p style="margin:0 0 14px;"><b>Next time ${first} will:</b> ${esc(ci.next)}</p>` : ""}
    ${glow ? `<div style="background:#FCEFD2;padding:12px 14px;border-radius:8px;margin-bottom:14px;"><div style="font-size:11px;letter-spacing:1.5px;text-transform:uppercase;color:#9A6400;">Coach's glow for ${first}</div><div style="font-size:15px;">${esc(glow)}</div></div>` : ""}
    ${mix ? `<p style="margin:0 0 14px;font-size:14px;"><b>From the Mix Log:</b> ${esc(mix.pair || "")}${mix.what ? " &mdash; " + esc(mix.what) : ""}</p>` : ""}
    <p style="margin:0 0 6px;"><b>Passport stamps today: ${got} of ${l.checks.length || 3}</b></p>
    <ul style="padding-left:18px;margin:0 0 14px;line-height:1.6;">${(l.checks || []).map((c, i) => `<li>${stamps[i] ? "&#10003;" : "&#9675;"} ${esc(c)}</li>`).join("")}</ul>
    <div style="background:#E1F1E6;padding:12px 14px;border-radius:8px;margin-bottom:18px;">
      <div style="font-size:11px;letter-spacing:1.5px;text-transform:uppercase;color:#1F7A3E;">Ask at dinner</div>
      <div style="font-size:15px;font-weight:bold;">${esc(l.home)}</div>
    </div>
    <p style="font-size:13px;color:#555;">Follow the next class live at <a href="https://selassiefest.com/dj-lab/#parent">selassiefest.com/dj-lab</a>. Questions? Reply to this email or call Stephen Henry at 414-909-3279.</p>
    <p style="font-size:11px;color:#999;">Rainbow DJ Lab &middot; Full Spectrum at Rainbow Beach &middot; Ras Tafari Inc., a 501(c)(3) nonprofit. You're getting this because you asked for session recaps when you registered. Reply "stop" to opt out.</p>
  </div>`;
}

Deno.serve(async (req) => {
  const headers = { ...cors(req), "Content-Type": "application/json" };
  const reply = (b: unknown, s = 200) => new Response(JSON.stringify(b), { status: s, headers });
  if (req.method === "OPTIONS") return new Response("ok", { headers: cors(req) });
  if (req.method !== "POST") return reply({ error: "POST only" }, 405);
  try {
    const body = await req.json();
    const { session, cohort, unit, lesson, resend } = body || {};
    if (!session || !cohort || !/^(s([1-9]|1[0-4])|w[1-6])$/.test(String(unit || ""))) return reply({ error: "Missing session, class or unit." }, 400);
    const l = lesson as Lesson;
    if (!l || !l.title || !l.mission) return reply({ error: "Missing lesson details." }, 400);

    const admin = createClient(SUPABASE_URL, SERVICE_ROLE_KEY);
    const { data: who, error: werr } = await admin.rpc("djlab_coach", { p_session: session });
    if (werr || !who || !(Array.isArray(who) ? who[0]?.v_email : (who as any).v_email)) return reply({ error: "Please sign in as a coach again." }, 401);

    const { data: rows, error } = await admin.rpc("djlab_recap_rows", { p_cohort: cohort, p_unit: unit });
    if (error) throw error;
    let sent = 0, skipped = 0, absent = 0;
    const failures: string[] = [];
    for (const r of (rows || []) as any[]) {
      if (!r.here) { absent++; continue; }
      if (r.already_sent && !resend) { skipped++; continue; }
      const stamps: boolean[] = (r.stamps && r.stamps[unit]) || [false, false, false];
      const html = recapHtml(r.kid_name, r.guardian_name, l, r.checkin || {}, stamps, r.glow);
      const res = await fetch("https://api.resend.com/emails", {
        method: "POST",
        headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
        body: JSON.stringify({ from: FROM, to: [r.guardian_email], reply_to: REPLY_TO, subject: `${r.kid_name.split(" ")[0]}'s Rainbow DJ Lab recap: ${l.title}`, html }),
      });
      if (res.ok) {
        sent++;
        await admin.from("djlab_recaps_sent").upsert({ kid_id: r.kid_id, unit, sent_at: new Date().toISOString() });
      } else failures.push(r.kid_name);
    }
    return reply({ ok: true, sent, skipped, absent, failed: failures });
  } catch (e) {
    console.error("djlab-send-recaps", e);
    return reply({ error: "Couldn't send recaps. Try again in a minute." }, 500);
  }
});

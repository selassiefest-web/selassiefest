// Emails a BIOS102 student their own Research Match plan (button on
// /BIOS102/research-match.html). Auth is the student's BIOS102 session token:
// the recipient is looked up server-side from the roster, so the email can only
// ever go to the signed-in student. Content is built here from their saved
// state, never taken from the request. One email per 60 seconds per student.
// Deploy: supabase functions deploy send-bios102-research-plan --no-verify-jwt
import { createClient } from "npm:@supabase/supabase-js@2";

const admin = createClient(Deno.env.get("SUPABASE_URL")!, Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!);
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "UWP Research Match <hello@selassiefest.com>";
const INSTRUCTOR = "harria01@uwp.edu";
const CORS = { "Access-Control-Allow-Origin": "*", "Access-Control-Allow-Headers": "authorization, apikey, content-type", "Content-Type": "application/json" };

const FAC: Record<string, { n: string; e: string }> = {
  orlofske: { n: "Dr. Jessica Orlofske", e: "orlofske@uwp.edu" }, richards: { n: "Dr. Gregory Richards", e: "richarg0@uwp.edu" },
  preuss: { n: "Dr. Fabian Preuss", e: "preussf@uwp.edu" }, higgs: { n: "Dr. David Higgs", e: "higgs@uwp.edu" },
  lee: { n: "Dr. Traci Lee", e: "leet@uwp.edu" }, barber: { n: "Dr. Robert Barber", e: "barber@uwp.edu" },
  noto: { n: "Dr. Christopher Noto", e: "noto@uwp.edu" }, taft: { n: "Dr. Natalia Taft", e: "taft@uwp.edu" },
  rogers: { n: "Dr. David Rogers", e: "rogersd@uwp.edu" },
  mayer: { n: "Dr. Gregory Mayer", e: "mayerg@uwp.edu" },
};
const STATUS: Record<string, string> = { none: "Not started", drafted: "Email drafted", sent: "Email sent", scheduled: "Interview scheduled", done: "Interview done", declined: "Said not now", noreply: "No reply, moved on" };
const esc = (s: unknown) => String(s ?? "").replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
// ilike treats % and _ as wildcards; an underscore in an email must match only itself.
const lit = (s: unknown) => String(s ?? "").replace(/[\\%_]/g, "\\$&");
const reply = (status: number, body: unknown) => new Response(JSON.stringify(body), { status, headers: CORS });

Deno.serve(async (req) => {
  if (req.method === "OPTIONS") return new Response("ok", { headers: CORS });
  if (req.method !== "POST") return reply(405, { error: "POST only" });
  try {
    const { session } = await req.json();
    if (!session || !/^[0-9a-f-]{36}$/i.test(String(session))) return reply(400, { error: "Missing session." });
    const { data: link } = await admin.from("bios102_login_links").select("email").eq("id", session).eq("status", "active").maybeSingle();
    if (!link) return reply(401, { error: "Please sign in again." });
    const { data: stu } = await admin.from("bios102_students").select("email, display_name").ilike("email", lit(link.email)).maybeSingle();
    if (!stu) return reply(401, { error: "Not on the roster." });
    const { data: row } = await admin.from("bios102_research_state").select("state, last_emailed_at").ilike("email", lit(stu.email)).maybeSingle();
    if (!row) return reply(400, { error: "Nothing saved yet." });
    if (row.last_emailed_at && Date.now() - new Date(row.last_emailed_at).getTime() < 60000) return reply(429, { error: "Wait a minute before sending another." });

    const s = row.state ?? {};
    const first = esc(String(stu.display_name ?? "").trim().split(/\s+/)[0] || "there");
    const top = (s.matchTop ?? []).slice(0, 3).filter((i: string) => FAC[i]);
    const list: string[] = (s.shortlist ?? []).filter((i: string) => FAC[i]);
    const fin = s.final?.faculty && FAC[s.final.faculty] ? FAC[s.final.faculty] : null;
    const li = (x: string) => `<li style="margin-bottom:6px">${x}</li>`;
    const html = `<div style="font-family:Arial,sans-serif;max-width:600px;color:#1b1f1d;line-height:1.5">
      <div style="background:#154734;color:#fff;padding:14px 18px;font-size:18px;font-weight:bold">Your research plan</div>
      <p>Hi ${first},</p>
      <p>Here is where you are in finding a research mentor.</p>
      ${top.length ? `<p><b>Your top matches</b></p><ol>${top.map((i: string) => li(esc(FAC[i].n))).join("")}</ol>` : ""}
      ${list.length ? `<p><b>Your interview list</b></p><ul>${list.map((i: string) => li(`${esc(FAC[i].n)}: ${esc(STATUS[s.outreach?.[i]?.status ?? "none"] ?? "")}${s.outreach?.[i]?.interviewDate ? ` (${esc(new Date(s.outreach[i].interviewDate).toLocaleString("en-US", { timeZone: "America/Chicago", weekday: "short", month: "short", day: "numeric", hour: "numeric", minute: "2-digit" }))})` : ""}`)).join("")}</ul>` : "<p>You have not picked professors yet.</p>"}
      ${fin ? `<p><b>Your first choice:</b> ${esc(fin.n)}</p>` : ""}
      <p><b>Next steps</b></p><ul>
        ${li("Check your UWP Outlook every day, including Junk and Other. Professors reply there.")}
        ${li("Email only from your UWP Outlook account, with one specific sentence about their work.")}
        ${li("No reply after a week: send one short follow-up, or visit office hours. Then move on.")}
        ${li("Thank each professor by email within 24 hours of an interview.")}
        ${li("Fellowship questions: Dr. Higgs (higgs@uwp.edu) for the Thomson Research Fellowship. Pre-Health advising: Lisa Lee, Greenquist 302.")}
      </ul>
      <p><a href="https://selassiefest.com/BIOS102/research-match.html" style="background:#154734;color:#fff;padding:10px 18px;text-decoration:none">Open Research Match</a></p>
      <p style="color:#4a544f;font-size:12px">An independent tool for UW&ndash;Parkside biology students, not an official UW&ndash;Parkside site. Questions? Reply to this email, or visit the department office, D132, or text 312-296-9816.</p></div>`;

    const res = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: FROM, to: stu.email, reply_to: INSTRUCTOR, subject: "Your research plan", html }),
    });
    if (!res.ok) return reply(502, { error: "The email service refused it. Try again later." });
    await admin.from("bios102_research_state").update({ last_emailed_at: new Date().toISOString() }).ilike("email", lit(stu.email));
    return reply(200, { ok: true });
  } catch (_e) {
    return reply(500, { error: "Something went wrong." });
  }
});

// Email alerts for the SSCC Advisory Council bylaws workspace
// (/sscc-bylaws/). Every alert goes to every member of the committee on
// sscc_bylaws_members, except the person whose action caused it. Called only
// by the database (triggers and a daily pg_cron job, see
// supabase/sscc-bylaws-progress-meetings.sql), authenticated by the
// x-webhook-secret header. Bodies:
//   { event: "proposal", id }   a member submitted a proposal or flagged an issue
//   { event: "version", num }   a chair published a version
//   { event: "reminders" }      confirmed meetings two days out
// Add "dry_run": true to get the recipients and subject without sending, or
// "test_to": "<email>" to send only to that address.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const SECRET = Deno.env.get("SSCC_BYLAWS_NOTIFY_SECRET");
const FROM = "SSCC Bylaws Workspace <hello@selassiefest.com>";
const PAGE = "https://selassiefest.com/sscc-bylaws/";
const REMIND_DAYS_AHEAD = 2;
const KIND: Record<string, string> = { amend: "amend", add: "add a section after", delete: "delete", issue: "raise an issue on" };

type Member = { email: string; display_name: string };
type Mail = { subject: string; html: string };

function esc(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}
const paras = (s: unknown) => String(s || "").split(/\n\s*\n/).map((p) => p.trim()).filter(Boolean)
  .map((p) => `<p style="margin:0 0 8px;">${esc(p)}</p>`).join("");
const clip = (s: unknown, n: number) => { const t = String(s || ""); return t.length > n ? t.slice(0, n).replace(/\s+\S*$/, "") + "…" : t; };
const button = (href: string, label: string) =>
  `<p style="margin:18px 0;"><a href="${href}" style="display:inline-block;background:#1a1712;color:#e9c46a;padding:10px 18px;border-radius:6px;text-decoration:none;font-weight:600;">${esc(label)}</a></p>`;
const wrap = (inner: string) => `<div style="font-family:Georgia,'Times New Roman',serif;color:#1d1a15;font-size:16px;line-height:1.5;max-width:600px;">
  <div style="font-family:Arial,sans-serif;font-size:11px;letter-spacing:.14em;text-transform:uppercase;color:#8a6a1c;font-weight:600;">SSCC Advisory Council &middot; By-laws Review Committee</div>
  ${inner}
  <p style="font-family:Arial,sans-serif;color:#7a705f;font-size:12px;border-top:1px solid #e4dccb;padding-top:10px;margin-top:22px;">
  You get these emails because you're on the By-laws Review Committee. Replies to this email aren't read: discuss on the workspace, or write to the chairs.</p></div>`;
const fmtDay = (d: string) => new Date(d + "T12:00:00Z").toLocaleDateString("en-US", { weekday: "long", month: "long", day: "numeric", timeZone: "UTC" });
const chicagoToday = () => new Date().toLocaleDateString("en-CA", { timeZone: "America/Chicago" });
const addDays = (d: string, n: number) => { const x = new Date(d + "T12:00:00Z"); x.setUTCDate(x.getUTCDate() + n); return x.toISOString().slice(0, 10); };

function reply(body: unknown, status = 200) {
  return new Response(JSON.stringify(body), { status, headers: { "Content-Type": "application/json" } });
}

Deno.serve(async (req) => {
  if (req.method !== "POST") return reply({ error: "method not allowed" }, 405);
  if (!SECRET || req.headers.get("x-webhook-secret") !== SECRET) return reply({ error: "unauthorized" }, 401);
  const body = await req.json().catch(() => ({}));
  const { event, dry_run, test_to } = body;
  const db = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  const { data: settings } = await db.from("sscc_bylaws_settings").select("alerts_enabled").eq("id", 1).maybeSingle();
  if (settings && settings.alerts_enabled === false && !test_to) return reply({ ok: true, skipped: "alerts are off" });

  const { data: members, error: mErr } = await db.from("sscc_bylaws_members").select("email, display_name");
  if (mErr) return reply({ error: mErr.message }, 500);
  const nameOf = (email: string | null, fallback = "A member") =>
    (members as Member[]).find((m) => email && m.email.toLowerCase() === email.toLowerCase())?.display_name || fallback;

  const jobs: { mail: Mail; exclude: string | null; after?: () => Promise<unknown> }[] = [];

  if (event === "proposal") {
    const { data: p } = await db.from("sscc_bylaws_proposals").select("*").eq("id", body.id).maybeSingle();
    if (!p) return reply({ error: "proposal not found" }, 404);
    if (!p.author_email) return reply({ ok: true, skipped: "seeded note" });
    const { data: s } = await db.from("sscc_bylaws_sections").select("article_num, section_num, title").eq("key", p.section_key).maybeSingle();
    const where = s ? `Article ${s.article_num}, Section ${s.section_num} (${s.title})` : `Article ${p.article_num}`;
    const who = nameOf(p.author_email);
    const isIssue = p.kind === "issue";
    let change = "";
    if (p.kind === "amend" || p.kind === "add") {
      change = `<div style="border-left:3px solid #1c6b3f;padding:4px 0 4px 12px;margin:12px 0;color:#2c3a30;">
        ${p.kind === "add" ? `<p style="margin:0 0 6px;font-weight:600;">${esc(p.proposed_title)}</p>` : ""}${paras(clip(p.proposed_body, 900))}</div>`;
    } else if (p.kind === "delete") {
      change = `<p style="color:#9b2c2c;">Proposes removing this section.</p>`;
    }
    jobs.push({
      exclude: p.author_email,
      mail: {
        subject: `${isIssue ? "Issue raised" : "New proposal"} #${p.id}: ${clip(p.summary, 90)}`,
        html: wrap(`
          <h2 style="font-size:20px;margin:8px 0 4px;">${esc(p.summary)}</h2>
          <p style="margin:0 0 12px;color:#4a4338;">${esc(who)} ${isIssue ? "raised an issue on" : `proposes to ${KIND[p.kind]}`} ${esc(where)}.</p>
          ${change}
          ${p.rationale ? `<p style="margin:0;"><b>Why:</b> ${esc(clip(p.rationale, 700))}</p>` : ""}
          ${button(`${PAGE}#proposals/p-${p.id}`, isIssue ? "Read and discuss" : "See the redline and discuss")}
          <p style="font-family:Arial,sans-serif;color:#7a705f;font-size:13px;">Proposal #${p.id}. Sign in with your email if the page asks.</p>`),
      },
    });
  } else if (event === "version") {
    const { data: v } = await db.from("sscc_bylaws_versions").select("num, label, summary, created_by").eq("num", body.num).maybeSingle();
    if (!v) return reply({ error: "version not found" }, 404);
    const { data: changes } = await db.from("sscc_bylaws_proposals").select("id, summary, author_email, author_label").eq("in_version", v.num).order("decided_at");
    const list = (changes || []).map((c) => `<li style="margin:0 0 4px;">${esc(c.summary)} <span style="color:#7a705f;">(${esc(nameOf(c.author_email, c.author_label || "a member"))}, #${c.id})</span></li>`).join("");
    jobs.push({
      exclude: v.created_by,
      mail: {
        subject: `Bylaws ${v.label} published: ${clip(v.summary, 90)}`,
        html: wrap(`
          <h2 style="font-size:20px;margin:8px 0 4px;">${esc(v.label)} is published</h2>
          <p style="margin:0 0 12px;color:#4a4338;">${esc(nameOf(v.created_by, "The chair"))} published ${esc(v.label)} of the draft bylaws: ${esc(v.summary)}</p>
          ${list ? `<p style="margin:0 0 4px;"><b>${(changes || []).length} change${(changes || []).length === 1 ? "" : "s"}:</b></p><ul style="margin:0 0 8px;padding-left:20px;">${list}</ul>` : ""}
          ${button(`${PAGE}#versions/v-${v.num}`, `Read ${v.label}`)}`),
      },
    });
  } else if (event === "reminders") {
    const day = addDays(chicagoToday(), REMIND_DAYS_AHEAD);
    const { data: ms } = await db.from("sscc_bylaws_meetings").select("*")
      .eq("kind", "meeting").eq("confirmed", true).eq("meets_on", day).is("reminded_at", null);
    const { data: secs } = await db.from("sscc_bylaws_sections").select("key, article_num, article_title");
    const { data: sts } = await db.from("sscc_bylaws_section_status").select("section_key, status");
    const { data: open } = await db.from("sscc_bylaws_proposals").select("section_key").eq("status", "open");
    for (const m of ms || []) {
      const focus = (m.focus || []).map((a: string) => {
        const inArt = (secs || []).filter((s) => s.article_num === a);
        const keys = new Set(inArt.map((s) => s.key));
        const settled = (sts || []).filter((x) => keys.has(x.section_key) && x.status === "settled").length;
        const openN = (open || []).filter((x) => keys.has(x.section_key)).length;
        return `<li style="margin:0 0 4px;">Article ${esc(a)}${inArt[0] ? `: ${esc(inArt[0].article_title)}` : ""} <span style="color:#7a705f;">(${settled} of ${inArt.length} sections settled${openN ? `, ${openN} open proposal${openN === 1 ? "" : "s"}` : ""})</span></li>`;
      }).join("");
      jobs.push({
        exclude: null,
        mail: {
          subject: `Reminder: bylaws committee meets ${fmtDay(m.meets_on)}`,
          html: wrap(`
            <h2 style="font-size:20px;margin:8px 0 4px;">${esc(m.title)}</h2>
            <p style="margin:0 0 12px;color:#4a4338;"><b>${esc(fmtDay(m.meets_on))}</b>${m.time_label ? ` &middot; ${esc(m.time_label)}` : ""}${m.location ? `<br>${esc(m.location)}` : ""}</p>
            ${focus ? `<p style="margin:0 0 4px;"><b>We'll work on:</b></p><ul style="margin:0 0 10px;padding-left:20px;">${focus}</ul>` : ""}
            ${m.agenda ? `<p style="margin:0 0 4px;"><b>Agenda</b></p><ul style="margin:0 0 8px;padding-left:20px;">${String(m.agenda).split(/\n+/).filter((l: string) => l.trim()).map((l: string) => `<li>${esc(l.trim())}</li>`).join("")}</ul>` : ""}
            <p style="margin:12px 0 0;">Please read the sections beforehand and mark them reviewed, and post proposals ahead of the meeting so everyone can see them.</p>
            ${button(`${PAGE}#meetings/m-${m.id}`, "Open the workspace")}`),
        },
        after: () => db.from("sscc_bylaws_meetings").update({ reminded_at: new Date().toISOString() }).eq("id", m.id),
      });
    }
  } else {
    return reply({ error: "unknown event" }, 400);
  }

  const results = [];
  for (const job of jobs) {
    const to = test_to ? [String(test_to)]
      : (members as Member[]).map((m) => m.email).filter((e) => !job.exclude || e.toLowerCase() !== job.exclude.toLowerCase());
    if (dry_run) { results.push({ subject: job.mail.subject, to }); continue; }
    if (!to.length) continue;
    // one message per person, so no one sees the others' addresses
    const res = await fetch("https://api.resend.com/emails/batch", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify(to.map((addr) => ({ from: FROM, to: addr, subject: job.mail.subject, html: job.mail.html }))),
    });
    if (!res.ok) { results.push({ subject: job.mail.subject, error: await res.text() }); continue; }
    if (job.after && !test_to) await job.after();
    results.push({ subject: job.mail.subject, sent: to.length });
  }
  return reply({ ok: true, results });
});

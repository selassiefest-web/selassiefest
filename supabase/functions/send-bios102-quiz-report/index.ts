// BIOS102 Mock Quiz 2 progress emails to Stephen. Not called from any
// client-side code -- pg_cron calls it via net.http_post with the
// x-webhook-secret header, same pattern as
// send-bbpac-tracker-deadline-reminders. See
// supabase/bios102-quiz-report-schema.sql for the modes and the cron jobs.
import { createClient } from "npm:@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;
const WEBHOOK_SECRET = Deno.env.get("BIOS102_REPORT_SECRET");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const FROM = "BIOS102 Lab Companion <hello@selassiefest.com>";
const TO = "stephen@selassiefest.com";
const STORAGE_ID = 9102; // mock-quiz-2.html's exercise_number sentinel
const TZ = "America/Chicago";

type Round = { finishedAt: number; correct: number; firstTry: number; total: number; attempts: number };
type QState = { status?: string; attempts?: number };
type Student = {
  email: string;
  name: string;
  history: Round[];
  answered: number; // questions with at least one try, current round
  correctNow: number;
  lastActivity: string | null;
};

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

function when(ms: number | string) {
  return new Date(ms).toLocaleString("en-US", {
    timeZone: TZ, weekday: "short", month: "short", day: "numeric", hour: "numeric", minute: "2-digit",
  });
}

function scoreLine(r: Round) {
  const pct = r.total ? Math.round((r.correct / r.total) * 100) : 0;
  return `${r.correct} of ${r.total} correct (${pct}%) &middot; ${r.firstTry} on the first try &middot; ${r.attempts} attempts`;
}

async function loadStudents(admin: ReturnType<typeof createClient>): Promise<Student[]> {
  const { data: roster, error: rErr } = await admin
    .from("bios102_students").select("email, display_name, major");
  if (rErr) throw rErr;
  const { data: tables, error: tErr } = await admin
    .from("bios102_student_tables").select("email, rows, updated_at").eq("exercise_number", STORAGE_ID);
  if (tErr) throw tErr;
  const byEmail = new Map((tables ?? []).map((t) => [String(t.email).toLowerCase(), t]));

  return (roster ?? [])
    .filter((s) => !/^instructor/i.test(s.major ?? ""))
    .map((s) => {
      const t = byEmail.get(String(s.email).toLowerCase());
      const state = t && Array.isArray(t.rows) && t.rows[0] ? t.rows[0].mockQuiz : null;
      const qs = Object.values((state?.q ?? {}) as Record<string, QState>);
      return {
        email: s.email,
        name: s.display_name,
        history: Array.isArray(state?.history) ? state.history : [],
        answered: qs.filter((q) => (q.attempts ?? 0) > 0 || (q.status && q.status !== "open")).length,
        correctNow: qs.filter((q) => q.status === "correct").length,
        lastActivity: t ? t.updated_at : null,
      };
    })
    .sort((a, b) => a.name.localeCompare(b.name));
}

const attempted = (s: Student) => s.history.length > 0 || s.answered > 0;

function list(items: string[]) {
  return items.length
    ? `<ul style="padding-left:18px;margin:6px 0 18px;">${items.map((i) => `<li style="margin-bottom:6px;">${i}</li>`).join("")}</ul>`
    : `<p style="color:#5b6b7a;margin:6px 0 18px;">None.</p>`;
}

function studentLine(s: Student) {
  const best = s.history.reduce<Round | null>((b, r) => (!b || r.correct > b.correct ? r : b), null);
  const bits = [`<strong>${escapeHtml(s.name)}</strong>`];
  if (best) bits.push(`${s.history.length} round${s.history.length === 1 ? "" : "s"} finished; best ${scoreLine(best)}`);
  else if (s.answered) bits.push(`in progress: ${s.answered} answered, ${s.correctNow} correct so far`);
  if (s.lastActivity) bits.push(`<span style="color:#5b6b7a;">last active ${when(s.lastActivity)}</span>`);
  return bits.join(" &middot; ");
}

async function send(subject: string, html: string) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: TO, subject, html }),
  });
  if (!res.ok) throw new Error(await res.text());
}

const footer = `<p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically from the
  <a href="https://selassiefest.com/BIOS102/dashboard.html">BIOS102 Lab Companion</a>. Instructor accounts are not included.</p>`;

Deno.serve(async (req) => {
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const body = await req.json().catch(() => ({}));
  const mode = body.mode ?? "readout";
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const students = await loadStudents(admin);

    if (mode === "finishes") {
      const since = Date.parse(body.since);
      const until = Date.parse(body.until);
      if (!since || !until) return new Response(JSON.stringify({ error: "since/until required" }), { status: 400 });
      if (Date.now() > until + 10 * 60 * 1000) {
        return new Response(JSON.stringify({ ok: true, sent: false, reason: "window closed" }), { status: 200 });
      }
      const candidates = students.flatMap((s) =>
        s.history.filter((r) => r.finishedAt >= since && r.finishedAt <= until).map((r) => ({ s, r })));
      if (!candidates.length) return new Response(JSON.stringify({ ok: true, sent: false }), { status: 200 });

      const { data: done, error } = await admin.from("bios102_quiz_report_sent").select("email, finished_at")
        .in("email", [...new Set(candidates.map((c) => c.s.email))]);
      if (error) throw error;
      const seen = new Set((done ?? []).map((d) => `${String(d.email).toLowerCase()}|${d.finished_at}`));
      const fresh = candidates.filter((c) => !seen.has(`${c.s.email.toLowerCase()}|${c.r.finishedAt}`));
      if (!fresh.length) return new Response(JSON.stringify({ ok: true, sent: false }), { status: 200 });

      const subject = fresh.length === 1
        ? `Mock Quiz 2: ${fresh[0].s.name} finished (${fresh[0].r.correct}/${fresh[0].r.total})`
        : `Mock Quiz 2: ${fresh.length} students finished`;
      await send(subject, `
        <p>Finished Mock Quiz 2:</p>
        ${list(fresh.map(({ s, r }) => `<strong>${escapeHtml(s.name)}</strong> &middot; ${scoreLine(r)}
          <br><span style="color:#5b6b7a;">finished ${when(r.finishedAt)}${s.history.length > 1 ? ` &middot; round ${s.history.indexOf(r) + 1}` : ""}</span>`))}
        <p style="color:#5b6b7a;font-size:0.85rem;">"Correct" counts only questions answered right; answers a student chose to reveal after 3 misses are not counted.</p>
        ${footer}`);
      const { error: insErr } = await admin.from("bios102_quiz_report_sent")
        .insert(fresh.map(({ s, r }) => ({ email: s.email, finished_at: r.finishedAt })));
      if (insErr) throw insErr;
      return new Response(JSON.stringify({ ok: true, sent: true, count: fresh.length }), { status: 200 });
    }

    const completed = students.filter((s) => s.history.length > 0);
    const inProgress = students.filter((s) => !s.history.length && s.answered > 0);
    const notStarted = students.filter((s) => !attempted(s));

    if (mode === "summary") {
      await send(`Mock Quiz 2 summary: ${completed.length} of ${students.length} completed`, `
        <p>Mock Quiz 2 status as of ${when(Date.now())}, ${students.length} students on the roster.</p>
        <h3 style="margin:18px 0 0;">Did not attempt (${notStarted.length})</h3>${list(notStarted.map((s) => `<strong>${escapeHtml(s.name)}</strong>`))}
        <h3 style="margin:0;">Attempted but did not finish (${inProgress.length})</h3>${list(inProgress.map(studentLine))}
        <h3 style="margin:0;">Completed (${completed.length})</h3>${list(completed.map(studentLine))}
        ${footer}`);
      return new Response(JSON.stringify({ ok: true, sent: true }), { status: 200 });
    }

    // readout
    const tried = students.filter(attempted);
    await send(`Mock Quiz 2: ${tried.length} of ${students.length} students have attempted it`, `
      <p>Students who have attempted Mock Quiz 2 as of ${when(Date.now())}:</p>
      ${list(tried.map(studentLine))}
      <p>${notStarted.length} of ${students.length} students have not started yet.</p>
      ${footer}`);
    return new Response(JSON.stringify({ ok: true, sent: true, attempted: tried.length }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: String((err as Error)?.message ?? err) }), { status: 500 });
  }
});

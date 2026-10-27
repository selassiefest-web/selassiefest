// BIOS102 mock quiz progress emails to Stephen (Mock Quiz 2 and 3; the
// request body's `quiz` picks which, defaulting to 2). Not called from any
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
const INSTRUCTOR = "harria01@uwp.edu"; // students' replies to the invite go here
// exercise_number sentinel each mock-quiz-N.html saves under
const QUIZZES: Record<number, { storageId: number; name: string; topic: string }> = {
  2: { storageId: 9102, name: "Mock Quiz 2", topic: "protists &amp; fungi" },
  3: { storageId: 9103, name: "Mock Quiz 3", topic: "liverworts &amp; mosses" },
};
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

async function loadStudents(admin: ReturnType<typeof createClient>, storageId: number): Promise<Student[]> {
  const { data: roster, error: rErr } = await admin
    .from("bios102_students").select("email, display_name, major");
  if (rErr) throw rErr;
  const { data: tables, error: tErr } = await admin
    .from("bios102_student_tables").select("email, rows, updated_at").eq("exercise_number", storageId);
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
  const quiz = QUIZZES[Number(body.quiz ?? 2)];
  if (!quiz) return new Response(JSON.stringify({ error: "unknown quiz" }), { status: 400 });
  const Q = quiz.name;
  const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

  try {
    const students = await loadStudents(admin, quiz.storageId);

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
        ? `${Q}: ${fresh[0].s.name} finished (${fresh[0].r.correct}/${fresh[0].r.total})`
        : `${Q}: ${fresh.length} students finished`;
      await send(subject, `
        <p>Finished ${Q}:</p>
        ${list(fresh.map(({ s, r }) => `<strong>${escapeHtml(s.name)}</strong> &middot; ${scoreLine(r)}
          <br><span style="color:#5b6b7a;">finished ${when(r.finishedAt)}${s.history.length > 1 ? ` &middot; round ${s.history.indexOf(r) + 1}` : ""}</span>`))}
        <p style="color:#5b6b7a;font-size:0.85rem;">"Correct" counts only questions answered right; answers a student chose to reveal after 3 misses are not counted.</p>
        ${footer}`);
      const { error: insErr } = await admin.from("bios102_quiz_report_sent")
        .insert(fresh.map(({ s, r }) => ({ email: s.email, finished_at: r.finishedAt })));
      if (insErr) throw insErr;
      return new Response(JSON.stringify({ ok: true, sent: true, count: fresh.length }), { status: 200 });
    }

    if (mode === "invite") {
      // One email per student (not one email with everyone in To), so no
      // student sees another's address. `test: true` sends a single copy
      // to Stephen instead, to proof it before the real send.
      // {"lesson":"videograde"} announces the Cnidaria video quiz (3 Lab 7 points, due Tue Oct 27 3pm) and the My grades planner.
      // Students the gradebook marks dropped or on leave are left out.
      const videograde = body.lesson === "videograde";
      let excluded = new Set<string>();
      if (videograde) {
        const { data: gr, error: gErr } = await admin.from("bios102_grade_rows").select("email, data");
        if (gErr) throw gErr;
        excluded = new Set((gr ?? []).filter((r) => r.data?.status && r.email).map((r) => String(r.email).toLowerCase()));
      }
      const recipients = body.test
        ? [{ email: TO, name: "Preview Student" }]
        : videograde ? students.filter((s) => !excluded.has(String(s.email).toLowerCase())) : students;
      const failed: string[] = [];
      // {"lesson":"spores"} announces the Studio vs. Duplex lesson instead of a quiz.
      const spores = body.lesson === "spores";
      // {"lesson":"arrived"} announces the Exercise 6 study guide, live slides and Lab Exam 1 mock.
      const arrived = body.lesson === "arrived";
      // {"lesson":"mockopen"} says the Lab Exam 1 mock is open to all until Tue Oct 20, 2pm.
      const mockopen = body.lesson === "mockopen";
      for (const s of recipients) {
        const first = escapeHtml(String(s.name).split(" ")[0]);
        const subject = videograde ? "BIOS102: Cnidaria video quiz (due Tuesday 3 PM) and your grade planner" : mockopen ? "BIOS102 mock exam is open now" : arrived ? "ARRIVED" : spores ? "BIOS102: a 5-minute way to lock in homosporous vs. heterosporous" : `BIOS102 ${Q} is ready`;
        const html = videograde ? `
              <p>Hi ${first},</p>
              <p>Two new things are ready on the BIOS102 Lab Companion. Both need you to log in the usual way: go to <a href="https://selassiefest.com/BIOS102/index.html">selassiefest.com/BIOS102</a>, type your class email, and click the link that arrives.</p>
              <p><strong>1. Cnidaria video quiz (Lab 7 movie worksheet). Completing it earns your 3 Lab 7 participation points. It is due Tuesday, Oct 27 at 3:00 PM Central.</strong><br>
              <a href="https://selassiefest.com/BIOS102/cnidaria-video-quiz.html">Open the video quiz</a></p>
              <p>Watch the <em>Shape of Life</em> Cnidaria film and answer all 11 worksheet questions as you go. The film pauses right after each clue and the question appears on screen. You can slow the video down, loop a section, step frame by frame, turn on captions, search the transcript, and bookmark moments. Every question has a hint and a &ldquo;watch the clue&rdquo; button. Your progress saves to your account, so you can stop on your phone and pick up on your laptop.</p>
              <p><strong>2. My grades: your own grade planner</strong><br>
              <a href="https://selassiefest.com/BIOS102/my-grades.html">Open My grades</a></p>
              <p>This page lets you ask &ldquo;what if?&rdquo; questions about your grade:</p>
              <ul>
                <li><strong>If I were excused from an assignment:</strong> see how excusing it changes your grade. An excused assignment leaves the course entirely. It is not a zero and not a score. Your workload stays the same, but each remaining point counts for more.</li>
                <li><strong>If I turned in missed work:</strong> see what late work would be worth. Whether late work is accepted is my decision, so this is only a what-if.</li>
                <li><strong>What if I score this on the rest of the course?</strong> Move the sliders for what you expect on the exams, quizzes and labs still to come, and it shows your projected final grade. Type a target, like 90%, to see what average you would need.</li>
              </ul>
              <p>Nothing you do on the page changes your actual grade. Canvas is the official record, and the page uses a Canvas export from Oct 26, so it can lag behind. The grade bands (A, B, C and so on) use the usual 90/80/70/60 cut-offs; the syllabus has the official ones.</p>
              <p>If a number looks wrong, or the page says your grades are not available, reply to this email.</p>
              <p>Professor Harris</p>` : mockopen ? `
              <p>Hi ${first},</p>
              <p>The Lab Exam 1 mock exam is now open to everyone. You don't need to ask for access.</p>
              <p>It stays open until <strong>Tuesday, Oct 20, 2:00 PM Central</strong>, when the in-person exam starts. It closes at exactly 2:00, so submit before then. You can retake it as many times as you like.</p>
              <p><a href="https://selassiefest.com/BIOS102/mock-exam.html">Take the mock exam</a></p>
              <p>Professor Harris</p>` : arrived ? `
              <p>Hi ${first},</p>
              <p><strong>The door is unlocked.</strong></p>
              <p>Log in to the Lab Companion to see:</p>
              <ul>
                <li>how to earn the 3 lab points</li>
                <li>how to study</li>
                <li>the mock exam, open <strong>Tuesday, Oct 13, 11:00 AM to 6:00 PM Central</strong></li>
              </ul>
              <p><a href="https://selassiefest.com/BIOS102/dashboard.html">Log in to the dashboard</a></p>
              <p>Professor Harris</p>` : spores ? `
              <p>Hi ${first},</p>
              <p>There is a new short lesson on the Lab Companion dashboard: <strong>Studio vs. Duplex</strong>, homosporous vs. heterosporous. It takes about 5 minutes, one small screen at a time, and it remembers where you stopped.</p>
              <p>You will rate how well you know it, sort organisms, and set up quick calendar reminders for reviews over the next few weeks. Short, spaced reviews are what move this into long-term memory.</p>
              <p><a href="https://selassiefest.com/BIOS102/homosporous-heterosporous.html">Start the lesson</a></p>
              <p>Professor Harris</p>` : `
              <p>Hi ${first},</p>
              <p>${Q} (${quiz.topic}) is up on the Lab Companion dashboard. Every question comes from the lab manual, and you can retry as often as you like.</p>
              <p><a href="https://selassiefest.com/BIOS102/dashboard.html">Open the dashboard</a></p>
              <p>Professor Harris</p>`;
        const res = await fetch("https://api.resend.com/emails", {
          method: "POST",
          headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
          body: JSON.stringify({
            from: FROM,
            to: s.email,
            reply_to: INSTRUCTOR,
            subject,
            html,
          }),
        });
        if (!res.ok) failed.push(`${s.email}: ${await res.text()}`);
        await new Promise((r) => setTimeout(r, 600)); // stay under Resend's rate limit
      }
      // {"notify":true} emails Stephen a confirmation once the batch is done (used by the scheduled send).
      if (body.notify) {
        const sentCount = recipients.length - failed.length;
        await send(
          failed.length ? `${mockopen ? "Mock exam open" : arrived ? "ARRIVED" : "BIOS102 invite"}: sent to ${sentCount}, ${failed.length} failed` : `${mockopen ? "Mock exam open" : arrived ? "ARRIVED" : "BIOS102 invite"} was sent to ${sentCount} students`,
          `<p>The ${mockopen ? "mock-exam-open" : arrived ? "ARRIVED" : "BIOS102"} email went out at ${when(Date.now())}.</p>
           <p>Delivered to Resend for <strong>${sentCount}</strong> of ${recipients.length} students.</p>
           ${failed.length ? `<p>These failed:</p>${list(failed.map((f) => escapeHtml(f)))}` : ""}
           ${footer}`,
        );
      }
      return new Response(JSON.stringify({ ok: failed.length === 0, sent: recipients.length - failed.length, failed }), { status: 200 });
    }

    const completed = students.filter((s) => s.history.length > 0);
    const inProgress = students.filter((s) => !s.history.length && s.answered > 0);
    const notStarted = students.filter((s) => !attempted(s));

    if (mode === "summary") {
      await send(`${Q} summary: ${completed.length} of ${students.length} completed`, `
        <p>${Q} status as of ${when(Date.now())}, ${students.length} students on the roster.</p>
        <h3 style="margin:18px 0 0;">Did not attempt (${notStarted.length})</h3>${list(notStarted.map((s) => `<strong>${escapeHtml(s.name)}</strong>`))}
        <h3 style="margin:0;">Attempted but did not finish (${inProgress.length})</h3>${list(inProgress.map(studentLine))}
        <h3 style="margin:0;">Completed (${completed.length})</h3>${list(completed.map(studentLine))}
        ${footer}`);
      return new Response(JSON.stringify({ ok: true, sent: true }), { status: 200 });
    }

    // readout
    const tried = students.filter(attempted);
    await send(`${Q}: ${tried.length} of ${students.length} students have attempted it`, `
      <p>Students who have attempted ${Q} as of ${when(Date.now())}:</p>
      ${list(tried.map(studentLine))}
      <p>${notStarted.length} of ${students.length} students have not started yet.</p>
      ${footer}`);
    return new Response(JSON.stringify({ ok: true, sent: true, attempted: tried.length }), { status: 200 });
  } catch (err) {
    return new Response(JSON.stringify({ error: String((err as Error)?.message ?? err) }), { status: 500 });
  }
});

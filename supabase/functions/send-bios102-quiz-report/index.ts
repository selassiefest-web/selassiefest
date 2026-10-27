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

async function send(subject: string, html: string, to = TO) {
  const res = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to, subject, html }),
  });
  if (!res.ok) throw new Error(await res.text());
}

// ── Cnidaria video quiz (BIOS102/cnidaria-video-quiz.html) ───────────────
// Saved under exercise_number 9201 as rows[0].cnidariaVideoQuiz:
//   { answers: { <qid>: { tries, wrong[], ok, revealed, hinted, at } }, completedAt, attempts[] }
// Finishing (all 11 answered; a revealed answer counts) earns the 3 Lab 7 points.
const VIDEO_STORAGE_ID = 9201;
const VIDEO_TABLE = "Cnidaria Video Quiz";
const VIDEO_DUE = Date.parse("2026-10-27T20:00:00Z"); // Tue Oct 27, 3:00 PM Central
const VQ: [string, string][] = [
  ["tent", "Q4 first to develop tentacles"], ["move", "Q1 first phylum to move (T/F)"],
  ["sets", "Q7 sets of muscles"], ["nerve", "Q3 structures that contract muscles"],
  ["nema", "Q9 function of nematocysts"], ["touch", "Q6 nematocysts need no contact (T/F)"],
  ["polyp", "Q2b polyp form"], ["stom", "Q10 how Stomphia escapes"],
  ["swim", "Q8 first to swim (T/F)"], ["med", "Q2a medusa form"], ["praya", "Q5 Praya shapes (T/F)"],
];

type VAnswer = { tries?: number; wrong?: unknown[]; ok?: boolean; revealed?: boolean; hinted?: boolean; at?: number };
type VStudent = {
  name: string; email: string; answers: Record<string, VAnswer>; completedAt: number; updatedAt: string | null;
  done: number; ok: number; first: number; tries: number; hints: number; revealed: number; sessions: number;
  status: "Finished" | "In progress" | "Not started";
};

async function loadVideoStudents(admin: ReturnType<typeof createClient>): Promise<{ students: VStudent[]; excluded: number }> {
  const { data: roster, error: rErr } = await admin.from("bios102_students").select("email, display_name, major");
  if (rErr) throw rErr;
  const { data: tables, error: tErr } = await admin.from("bios102_student_tables")
    .select("email, rows, updated_at").eq("exercise_number", VIDEO_STORAGE_ID).eq("table_name", VIDEO_TABLE);
  if (tErr) throw tErr;
  const { data: gr, error: gErr } = await admin.from("bios102_grade_rows").select("email, data");
  if (gErr) throw gErr;
  const dropped = new Set((gr ?? []).filter((r) => r.data?.status && r.email).map((r) => String(r.email).toLowerCase()));
  const byEmail = new Map((tables ?? []).map((t) => [String(t.email).toLowerCase(), t]));
  const all = (roster ?? []).filter((s) => !/^instructor/i.test(s.major ?? ""));
  const students = all.filter((s) => !dropped.has(String(s.email).toLowerCase())).map((s): VStudent => {
    const t = byEmail.get(String(s.email).toLowerCase());
    const state = t && Array.isArray(t.rows) && t.rows[0] ? t.rows[0].cnidariaVideoQuiz : null;
    const answers: Record<string, VAnswer> = state?.answers && typeof state.answers === "object" ? state.answers : {};
    let done = 0, ok = 0, first = 0, tries = 0, hints = 0, revealed = 0, last = 0;
    for (const [id] of VQ) {
      const x = answers[id];
      if (!x) continue;
      if (x.ok || x.revealed) done++;
      if (x.ok) ok++;
      if (x.ok && x.tries === 1) first++;
      if (x.revealed && !x.ok) revealed++;
      tries += x.tries ?? 0;
      if (x.hinted) hints++;
      if (x.at && x.at > last) last = x.at;
    }
    const completedAt = state?.completedAt ?? (done === VQ.length ? (last || (t ? Date.parse(t.updated_at) : 0)) : 0);
    return {
      name: s.display_name, email: s.email, answers, completedAt, updatedAt: t ? t.updated_at : null,
      done, ok, first, tries, hints, revealed, sessions: Array.isArray(state?.attempts) ? state.attempts.length : 0,
      status: done === VQ.length ? "Finished" : done > 0 ? "In progress" : "Not started",
    };
  }).sort((a, b) => a.name.localeCompare(b.name));
  return { students, excluded: all.length - students.length };
}

function videoDetail(s: VStudent) {
  const rows = VQ.map(([id, label]) => {
    const x = s.answers[id];
    if (!x || (!x.ok && !x.revealed && !x.tries)) return null;
    const res = x.ok ? (x.tries === 1 ? "correct, first try" : `correct after ${x.tries} tries`) : x.revealed ? "answer shown" : "in progress";
    const wrong = (x.wrong ?? []).map((w) => escapeHtml(String(w).slice(0, 60))).join("; ");
    return `<li>${escapeHtml(label)}: ${res}${x.hinted ? " (hint)" : ""}${wrong ? ` <span style="color:#5b6b7a;">&mdash; wrong: ${wrong}</span>` : ""}</li>`;
  }).filter(Boolean) as string[];
  return rows.length ? `<ul style="padding-left:18px;margin:4px 0 14px;font-size:0.9rem;">${rows.join("")}</ul>` : "";
}

function videoReportHtml(students: VStudent[], excluded: number) {
  const fin = students.filter((s) => s.status === "Finished").sort((a, b) => a.completedAt - b.completedAt);
  const prog = students.filter((s) => s.status === "In progress");
  const none = students.filter((s) => s.status === "Not started");
  const td = "padding:5px 8px;border-bottom:1px solid #e3e8ee;";
  const th = `${td}text-align:left;font-size:0.8rem;color:#5b6b7a;`;
  const late = (s: VStudent) => (s.completedAt > VIDEO_DUE ? ` <span style="color:#b3261e;">(late)</span>` : "");
  const row = (s: VStudent) => `<tr>
    <td style="${td}"><strong>${escapeHtml(s.name)}</strong></td>
    <td style="${td}">${s.completedAt ? when(s.completedAt) + late(s) : "&mdash;"}</td>
    <td style="${td}">${s.ok}/${VQ.length}</td><td style="${td}">${s.first}</td><td style="${td}">${s.tries}</td>
    <td style="${td}">${s.hints}</td><td style="${td}">${s.revealed}</td></tr>`;
  const table = (list: VStudent[]) => list.length ? `<table style="border-collapse:collapse;font-size:0.9rem;margin:6px 0 18px;">
    <tr><th style="${th}">Student</th><th style="${th}">Finished</th><th style="${th}">Correct</th><th style="${th}">First try</th>
    <th style="${th}">Tries</th><th style="${th}">Hints</th><th style="${th}">Answer shown</th></tr>${list.map(row).join("")}</table>`
    : `<p style="color:#5b6b7a;margin:6px 0 18px;">None.</p>`;

  const hard = VQ.map(([id, label]) => {
    const xs = students.map((s) => s.answers[id]).filter((a) => a && (a.ok || a.revealed || a.tries)) as VAnswer[];
    const first = xs.filter((a) => a.ok && a.tries === 1).length;
    return { label, n: xs.length, first, shown: xs.filter((a) => a.revealed && !a.ok).length,
      avg: xs.length ? xs.reduce((t, a) => t + (a.tries ?? 0), 0) / xs.length : 0 };
  });
  const hardRows = hard.map((h) => `<tr><td style="${td}">${escapeHtml(h.label)}</td><td style="${td}">${h.n}</td>
    <td style="${td}">${h.n ? Math.round((h.first / h.n) * 100) + "%" : "-"}</td><td style="${td}">${h.n ? h.avg.toFixed(1) : "-"}</td>
    <td style="${td}">${h.shown}</td></tr>`).join("");

  const detailed = [...fin, ...prog].map((s) => `<p style="margin:10px 0 0;"><strong>${escapeHtml(s.name)}</strong></p>${videoDetail(s)}`).join("");

  return `
    <p>Cnidaria video quiz (Lab 7, due Tue Oct 27, 3:00 PM Central) as of ${when(Date.now())}.
    Finishing earns the 3 Lab 7 participation points.</p>
    <p><strong>${fin.length}</strong> of ${students.length} students finished
    (${fin.filter((s) => s.completedAt > VIDEO_DUE).length} after the deadline),
    ${prog.length} in progress, ${none.length} not started.${excluded ? ` ${excluded} dropped or on-leave students are left out.` : ""}</p>
    <h3 style="margin:18px 0 0;">Finished (${fin.length})</h3>${table(fin)}
    <h3 style="margin:0;">In progress (${prog.length})</h3>${table(prog)}
    <h3 style="margin:0;">Not started (${none.length})</h3>${none.length ? list(none.map((s) => escapeHtml(s.name))) : `<p style="color:#5b6b7a;margin:6px 0 18px;">None.</p>`}
    <h3 style="margin:0;">Which questions were hard?</h3>
    <table style="border-collapse:collapse;font-size:0.9rem;margin:6px 0 18px;"><tr><th style="${th}">Question</th><th style="${th}">Answered</th>
    <th style="${th}">Right first try</th><th style="${th}">Avg tries</th><th style="${th}">Answer shown</th></tr>${hardRows}</table>
    <h3 style="margin:0;">Question by question</h3>${detailed || `<p style="color:#5b6b7a;">No one has started.</p>`}
    <p style="color:#5b6b7a;font-size:0.85rem;">"Correct" counts only questions answered right; an answer a student chose to reveal counts as done
    but not correct. Tries and wrong answers are the student's own entries. A student who starts over keeps the first finish time.
    Sent automatically from the <a href="https://selassiefest.com/BIOS102/grades.html">BIOS102 Lab Companion</a>; the same data is on the Video quiz tab there.</p>`;
}

const footer = `<p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically from the
  <a href="https://selassiefest.com/BIOS102/dashboard.html">BIOS102 Lab Companion</a>. Instructor accounts are not included.</p>`;

Deno.serve(async (req) => {
  if (!WEBHOOK_SECRET || req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  const body = await req.json().catch(() => ({}));
  const mode = body.mode ?? "readout";

  // {"mode":"video"} emails the Cnidaria video quiz report to the instructor.
  // {"test":true} sends it to Stephen instead, to proof it first.
  if (mode === "video") {
    try {
      const admin = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);
      const { students, excluded } = await loadVideoStudents(admin);
      const fin = students.filter((s) => s.status === "Finished").length;
      await send(
        `BIOS102 Cnidaria video quiz: ${fin} of ${students.length} finished`,
        videoReportHtml(students, excluded),
        body.test ? TO : INSTRUCTOR,
      );
      return new Response(JSON.stringify({ ok: true, sent: true, to: body.test ? TO : INSTRUCTOR, finished: fin }), { status: 200 });
    } catch (err) {
      return new Response(JSON.stringify({ error: String((err as Error)?.message ?? err) }), { status: 500 });
    }
  }

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

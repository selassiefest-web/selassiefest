-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 Mock Quiz 2 progress emails (send-bios102-quiz-report Edge
-- Function). Students' quiz state lives in bios102_student_tables under the
-- exercise_number 9102 sentinel (see BIOS102/mock-quiz-2.html); each
-- finished round is appended to rows[0].mockQuiz.history. The function reads
-- that with the service role and emails stephen@selassiefest.com:
--   mode 'readout'  -- who has attempted the quiz so far
--   mode 'finishes' -- each round finished inside a {since, until} window,
--                      once (tracked in the table below); polled by pg_cron
--   mode 'summary'  -- completed / attempted-not-finished / not attempted
-- Instructor accounts (major like 'Instructor%') are left out of every mode.
-- ─────────────────────────────────────────────────────────────────────────

-- One row per finished round already emailed, so the polling job never
-- reports the same finish twice. finished_at is the client's Date.now()
-- stored in the history entry. Service role only: RLS on, no policies.
create table if not exists bios102_quiz_report_sent (
  email text not null,
  finished_at bigint not null,
  sent_at timestamptz not null default now(),
  primary key (email, finished_at)
);

alter table bios102_quiz_report_sent enable row level security;

-- The pg_cron jobs that drive this are applied directly against the live
-- project, not reproduced here (they embed the function URL and its
-- BIOS102_REPORT_SECRET) -- same pattern as bbpac-tracker-deadline-reminders.
-- Shape, if they ever need recreating:
--   select cron.schedule('bios102-quiz-finishes', '*/5 * * * *',
--     $$ select net.http_post(url := '<function URL>', headers :=
--        jsonb_build_object('Content-Type', 'application/json',
--        'x-webhook-secret', '<BIOS102_REPORT_SECRET>'), body :=
--        '{"mode":"finishes","since":"<ISO>","until":"<ISO>"}'::jsonb) $$);
--   select cron.schedule('bios102-quiz-summary', '<min> <hour UTC> <day> <month> *',
--     $$ select net.http_post(... body := '{"mode":"summary"}'::jsonb);
--        select cron.unschedule('bios102-quiz-finishes');
--        select cron.unschedule('bios102-quiz-summary') $$);
-- pg_cron runs in UTC; the summary job unschedules both jobs after it
-- fires so neither repeats next year.

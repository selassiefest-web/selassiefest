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
-- Every mode takes an optional "quiz": 2 (default) or 3 in the JSON body.
-- Mock Quiz 3 (BIOS102/mock-quiz-3.html) saves under exercise_number 9103
-- the same way; its cron jobs just add "quiz":3 to each body below.
-- bios102_quiz_report_sent is shared: finished_at is a millisecond
-- timestamp, so one student's Quiz 2 and Quiz 3 finishes never collide.
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
--
-- Mock Quiz 3 jobs (applied live 2026-09-29): finish emails from Mon Oct 5
-- 12:00 pm to Tue Oct 6 2:00 pm Central (17:00Z-19:00Z), then the summary
-- at Tue 2:00 pm, which unschedules both. These read the secret from Vault
-- (name 'bios102_report_secret', same value as the function's
-- BIOS102_REPORT_SECRET) instead of embedding it:
--   select cron.schedule('bios102-quiz3-finishes', '*/5 * 5-6 10 *',
--     $$ select net.http_post(url := '<function URL>', headers :=
--        jsonb_build_object('Content-Type', 'application/json',
--        'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets
--        where name = 'bios102_report_secret')), body :=
--        '{"mode":"finishes","quiz":3,"since":"2026-10-05T17:00:00Z","until":"2026-10-06T19:00:00Z"}'::jsonb) $$);
--   select cron.schedule('bios102-quiz3-summary', '0 19 6 10 *',
--     $$ select net.http_post(... body := '{"mode":"summary","quiz":3}'::jsonb);
--        select cron.unschedule('bios102-quiz3-finishes');
--        select cron.unschedule('bios102-quiz3-summary') $$);
-- Mock Quiz 3 student invite (applied live 2026-10-01): one-time job at
-- Thu Oct 1 8:00 am Central (13:00Z), same Vault secret, then it unschedules
-- itself. timeout_milliseconds is raised because the invite loop paces its
-- 21 sends ~0.6 s apart, past pg_net's 5 s default:
--   select cron.schedule('bios102-quiz3-invite', '0 13 1 10 *',
--     $$ select net.http_post(... body := '{"mode":"invite","quiz":3}'::jsonb,
--        timeout_milliseconds := 120000);
--        select cron.unschedule('bios102-quiz3-invite') $$);

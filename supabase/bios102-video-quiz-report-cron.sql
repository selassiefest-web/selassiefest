-- One-time jobs: email the Cnidaria video quiz report to harria01@uwp.edu at
-- Tue Oct 27 2026, 1:00, 2:00 and 3:00 pm Central (18:00Z, 19:00Z, 20:00Z; the
-- quiz is due at 3:00 pm). Each unschedules itself after it fires.
-- Applied live 2026-10-27; replaces the earlier single 3:05 pm job.
select cron.unschedule('bios102-video-quiz-report');
select cron.schedule('bios102-video-quiz-report-1pm', '0 18 27 10 *',
  $$ select net.http_post(
       url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
       headers := jsonb_build_object('Content-Type', 'application/json',
         'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
       body := '{"mode":"video"}'::jsonb, timeout_milliseconds := 60000);
     select cron.unschedule('bios102-video-quiz-report-1pm') $$);
select cron.schedule('bios102-video-quiz-report-2pm', '0 19 27 10 *',
  $$ select net.http_post(
       url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
       headers := jsonb_build_object('Content-Type', 'application/json',
         'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
       body := '{"mode":"video"}'::jsonb, timeout_milliseconds := 60000);
     select cron.unschedule('bios102-video-quiz-report-2pm') $$);
select cron.schedule('bios102-video-quiz-report-3pm', '0 20 27 10 *',
  $$ select net.http_post(
       url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
       headers := jsonb_build_object('Content-Type', 'application/json',
         'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
       body := '{"mode":"video"}'::jsonb, timeout_milliseconds := 60000);
     select cron.unschedule('bios102-video-quiz-report-3pm') $$);

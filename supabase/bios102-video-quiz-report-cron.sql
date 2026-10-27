-- One-time job: emails the Cnidaria video quiz report to harria01@uwp.edu at
-- Tue Oct 27 2026, 3:05 pm Central (20:05Z), five minutes after the 3:00 pm
-- deadline, then unschedules itself. Applied live 2026-10-27.
select cron.schedule('bios102-video-quiz-report', '5 20 27 10 *',
  $$ select net.http_post(
       url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
       headers := jsonb_build_object('Content-Type', 'application/json',
         'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
       body := '{"mode":"video"}'::jsonb,
       timeout_milliseconds := 60000);
     select cron.unschedule('bios102-video-quiz-report') $$);

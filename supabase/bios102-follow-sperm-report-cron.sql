-- Follow the Sperm report to the instructor (harria01@uwp.edu): daily at 8 am Central, Oct 28 - Nov 3, 2026.
-- Oct 28-31 is CDT (13:00 UTC); Nov 1-3 is CST (14:00 UTC). Each job posts {"mode":"sperm"}.
select cron.unschedule(jobname) from cron.job where jobname in ('bios102-sperm-report-oct','bios102-sperm-report-nov');
select cron.schedule('bios102-sperm-report-oct', '0 13 28-31 10 *', $$
  select net.http_post(
    url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
    headers := jsonb_build_object('Content-Type','application/json',
      'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
    body := '{"mode":"sperm"}'::jsonb, timeout_milliseconds := 60000);$$);
select cron.schedule('bios102-sperm-report-nov', '0 14 1-3 11 *', $$
  select net.http_post(
    url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
    headers := jsonb_build_object('Content-Type','application/json',
      'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
    body := '{"mode":"sperm"}'::jsonb, timeout_milliseconds := 60000);$$);

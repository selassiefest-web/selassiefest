-- Real send: "Follow the Sperm is required" to every enrolled student (not instructors, page-restricted,
-- dropped or on-leave students). notify:true emails Stephen a count when done.
select net.http_post(
  url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
  headers := jsonb_build_object('Content-Type','application/json',
    'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
  body := '{"mode":"invite","lesson":"sperm","notify":true}'::jsonb, timeout_milliseconds := 300000) as request_id;

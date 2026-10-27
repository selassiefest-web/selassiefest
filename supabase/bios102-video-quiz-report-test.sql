-- Proof copy of the Cnidaria video quiz report: goes to Stephen only ("test": true).
select net.http_post(
  url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
  headers := jsonb_build_object('Content-Type', 'application/json',
    'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
  body := '{"mode":"video","test":true}'::jsonb,
  timeout_milliseconds := 60000
) as request_id;

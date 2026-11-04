-- Proof copy to Stephen only ("test": true) of the Lab Exam 2 mock invite.
select net.http_post(
  url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
  headers := jsonb_build_object('Content-Type','application/json',
    'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
  body := '{"mode":"invite","lesson":"mockexam2","test":true}'::jsonb, timeout_milliseconds := 60000) as request_id;

-- Tells lab instructors about Follow the Sperm and its planted error (mesophyll -> mesohyl).
-- Proof copy to Stephen first; the real send goes to the two lab instructors.
select net.http_post(
  url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/send-bios102-quiz-report',
  headers := jsonb_build_object('Content-Type','application/json',
    'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets where name = 'bios102_report_secret')),
  body := '{"mode":"instructors","to":["mossman@uwp.edu","rogersd@uwp.edu"]}'::jsonb, timeout_milliseconds := 60000) as request_id;

-- Reminder emails for the Full Spectrum CPD ARCS application kit (2026-10-14).
-- One row; send-arcs-kit-reminder reads it, and the "I've submitted it" link in
-- the email sets stopped_at, which ends the reminders.
create table if not exists arcs_kit_reminder (
  id int primary key default 1 check (id = 1),
  started_on date not null default current_date,
  stopped_at timestamptz,
  last_sent_at timestamptz
);
alter table arcs_kit_reminder enable row level security;
-- No policies: only the service role (the Edge Function) touches it.
insert into arcs_kit_reminder (id, started_on) values (1, '2026-10-14') on conflict (id) do nothing;

-- The cron job runs daily at 14:00 UTC (9am Chicago, 8am in winter) and the
-- function sends only every second day counted from started_on, so the email
-- lands every 48 hours. It carries the shared secret, so it is created out of
-- band (not in git):
-- select cron.schedule('arcs-kit-reminder', '0 14 * * *', $$ select net.http_post(
--   url := 'https://<ref>.supabase.co/functions/v1/send-arcs-kit-reminder',
--   headers := jsonb_build_object('Content-Type','application/json','x-webhook-secret','<ARCS_KIT_REMINDER_SECRET>'),
--   body := '{}'::jsonb) $$);

-- Dated reminder emails for Ras Tafari Inc.'s Night Out in the Parks 2027 application (2026-10-16).
-- send-noitp-reminders runs daily from pg_cron and emails Stephen every row whose send_on has
-- arrived and that hasn't been sent. The "I've submitted it" link in each email sets
-- submitted_at on the settings row, which stops everything except the info-session note.
create table if not exists noitp_reminders (
  id         serial primary key,
  send_on    date not null,
  subject    text not null,
  body       text not null,           -- plain text; blank lines become paragraphs
  after_submit boolean not null default false,  -- still send once the application is in
  sent_at    timestamptz
);
create table if not exists noitp_settings (
  id int primary key default 1 check (id = 1),
  submitted_at timestamptz
);
alter table noitp_reminders enable row level security;
alter table noitp_settings enable row level security;
-- No policies: only the service role (the Edge Function) touches these.
insert into noitp_settings (id) values (1) on conflict (id) do nothing;

-- The schedule itself is loaded out of band (it names private kit links), and the cron job
-- carries the shared secret, so neither is committed:
-- select cron.schedule('noitp-reminders', '0 14 * * *', $$ select net.http_post(
--   url := 'https://<ref>.supabase.co/functions/v1/send-noitp-reminders',
--   headers := jsonb_build_object('Content-Type','application/json','x-webhook-secret','<NOITP_REMINDER_SECRET>'),
--   body := '{}'::jsonb) $$);

-- Answers a partner prepares on a meeting agenda page (first use:
-- /rti/night-out/livingston/, Albert Harris + Livingston, Oct 2026).
-- Write-only: rows arrive through public-submit (form "noitp_agenda_answers");
-- anon can neither insert directly nor read. The AFTER INSERT trigger emails
-- staff through notify-submission (formatNoitpAgendaAnswers).
create table if not exists noitp_agenda_answers (
  id uuid primary key default gen_random_uuid(),
  agenda_key text not null,
  respondent_name text,
  respondent_contact text,
  part_label text,                 -- "1 of 1", or "2 of 3" when a long send is split
  answers jsonb not null default '[]'::jsonb,   -- [{section, question, answer}]
  extra jsonb not null default '{}'::jsonb,     -- other filled fields: {label: value}
  source_page text,
  created_at timestamptz not null default now()
);
alter table noitp_agenda_answers enable row level security;
revoke all on noitp_agenda_answers from anon, authenticated;

drop trigger if exists noitp_agenda_answers_notify on noitp_agenda_answers;
create trigger noitp_agenda_answers_notify after insert on noitp_agenda_answers
  for each row execute function notify_submission_webhook();

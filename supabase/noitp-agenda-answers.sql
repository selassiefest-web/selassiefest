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

-- Shared, cloud-saved agenda (10/21): every answer and note on the page is
-- saved here as it is typed, so nothing is lost when someone switches
-- devices, and Albert and Livingston see the same page. Access is by the
-- secret doc_key in the link (?k=...). The row is seeded out of band; the key
-- is never committed. Every patch is also appended to the log.
create table if not exists noitp_agenda_docs (
  doc_key text primary key,
  agenda_key text not null,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
alter table noitp_agenda_docs enable row level security;
revoke all on noitp_agenda_docs from anon, authenticated;

create table if not exists noitp_agenda_doc_log (
  id bigserial primary key,
  doc_key text not null,
  patch jsonb not null,
  created_at timestamptz not null default now()
);
alter table noitp_agenda_doc_log enable row level security;
revoke all on noitp_agenda_doc_log from anon, authenticated;

create or replace function noitp_agenda_get(p_key text) returns jsonb
language sql security definer set search_path = public stable as $$
  select jsonb_build_object('data', data, 'updated_at', updated_at)
  from noitp_agenda_docs where doc_key = p_key and length(p_key) >= 20;
$$;
grant execute on function noitp_agenda_get(text) to anon, authenticated;

create or replace function noitp_agenda_patch(p_key text, p_patch jsonb) returns timestamptz
language plpgsql security definer set search_path = public as $$
declare v_at timestamptz;
begin
  if p_patch is null or jsonb_typeof(p_patch) <> 'object' then raise exception 'bad patch'; end if;
  if length(p_patch::text) > 200000 then raise exception 'too much at once'; end if;
  update noitp_agenda_docs set data = data || p_patch, updated_at = now()
   where doc_key = p_key and length(p_key) >= 20
   returning updated_at into v_at;
  if v_at is null then raise exception 'unknown link'; end if;
  insert into noitp_agenda_doc_log (doc_key, patch) values (p_key, p_patch);
  return v_at;
end;
$$;
grant execute on function noitp_agenda_patch(text, jsonb) to anon, authenticated;

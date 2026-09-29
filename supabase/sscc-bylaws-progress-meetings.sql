-- SSCC bylaws workspace: review progress by section, the meeting timeline
-- to the December 12, 2026 PAC meeting, and email alerts to every member.
-- Same access shape as sscc-bylaws-schema.sql: RLS on with zero policies,
-- all reads and writes through security-definer functions.
--
-- Progress: each section has a chair-set status (no row = not started,
-- 'in_review', 'settled') plus per-member "I've reviewed this" marks. A
-- mark counts only if it is newer than the section's last change, so an
-- accepted amendment sends a section back for re-reading. A section can't
-- be settled while it has open proposals, and a new proposal on a settled
-- section reopens it.
--
-- Meetings: public (the 2022 bylaws, Art. V §1, require notice of committee
-- meetings to the general membership). Chair-edited. `kind` 'milestone'
-- marks a deadline rather than a meeting. Only `confirmed` meetings get the
-- two-day email reminder.
--
-- Alerts: sscc-bylaws-notify (Edge Function) emails every member, except
-- whoever caused it, on a new proposal or a published version, plus the
-- meeting reminders from a daily pg_cron job. A chair can switch alerts off
-- (sscc_bylaws_settings.alerts_enabled).

create table if not exists sscc_bylaws_section_status (
  section_key text primary key,
  status text not null check (status in ('in_review', 'settled')),
  note text,
  set_by text,
  set_at timestamptz not null default now()
);
alter table sscc_bylaws_section_status enable row level security;

create table if not exists sscc_bylaws_section_reads (
  section_key text not null,
  member_email text not null,
  read_at timestamptz not null default now(),
  primary key (section_key, member_email)
);
alter table sscc_bylaws_section_reads enable row level security;

create table if not exists sscc_bylaws_meetings (
  id bigserial primary key,
  kind text not null default 'meeting' check (kind in ('meeting', 'milestone')),
  meets_on date not null,
  time_label text,
  location text,
  title text not null,
  focus text[] not null default '{}',      -- article numbers, e.g. {III,IV}
  agenda text,
  notes text,
  confirmed boolean not null default false,
  reminded_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table sscc_bylaws_meetings enable row level security;

create table if not exists sscc_bylaws_settings (
  id int primary key default 1 check (id = 1),
  alerts_enabled boolean not null default true
);
alter table sscc_bylaws_settings enable row level security;
insert into sscc_bylaws_settings (id) values (1) on conflict do nothing;

-- ---------------- progress ----------------

create or replace function sscc_bylaws_review_state(p_token uuid)
returns jsonb
language plpgsql security definer set search_path = public stable
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  return jsonb_build_object(
    'alerts_enabled', (select alerts_enabled from sscc_bylaws_settings where id = 1),
    'member_count', (select count(*) from sscc_bylaws_members),
    'sections', coalesce((
      select jsonb_agg(jsonb_build_object(
        'key', s.key,
        'status', coalesce(st.status, 'not_started'),
        'note', st.note,
        'set_by', case when st.set_by is null then null else sscc_bylaws_name(st.set_by) end,
        'set_at', st.set_at,
        'readers', coalesce((
          select jsonb_agg(sscc_bylaws_name(r.member_email) order by r.read_at)
          from sscc_bylaws_section_reads r
          where r.section_key = s.key and r.read_at >= s.updated_at
            and exists (select 1 from sscc_bylaws_members m where lower(m.email) = lower(r.member_email))), '[]'::jsonb),
        'read_by_me', exists (select 1 from sscc_bylaws_section_reads r
          where r.section_key = s.key and lower(r.member_email) = lower(me.email) and r.read_at >= s.updated_at))
        order by s.article_order, s.section_order)
      from sscc_bylaws_sections s
      left join sscc_bylaws_section_status st on st.section_key = s.key), '[]'::jsonb)
  );
end;
$$;
grant execute on function sscc_bylaws_review_state(uuid) to anon, authenticated;

create or replace function sscc_bylaws_mark_read(p_token uuid, p_section_key text, p_read boolean)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if not exists (select 1 from sscc_bylaws_sections where key = p_section_key) then raise exception 'section not found'; end if;
  if p_read then
    insert into sscc_bylaws_section_reads (section_key, member_email) values (p_section_key, lower(me.email))
    on conflict (section_key, member_email) do update set read_at = now();
  else
    delete from sscc_bylaws_section_reads where section_key = p_section_key and lower(member_email) = lower(me.email);
  end if;
end;
$$;
grant execute on function sscc_bylaws_mark_read(uuid, text, boolean) to anon, authenticated;

-- p_status: not_started | in_review | settled
create or replace function sscc_bylaws_set_section_status(p_token uuid, p_section_key text, p_status text, p_note text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
  n int;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can set a section''s status'; end if;
  if not exists (select 1 from sscc_bylaws_sections where key = p_section_key) then raise exception 'section not found'; end if;
  if p_status not in ('not_started', 'in_review', 'settled') then raise exception 'unknown status'; end if;
  if p_status = 'settled' then
    select count(*) into n from sscc_bylaws_proposals where section_key = p_section_key and status = 'open';
    if n > 0 then
      raise exception 'this section has % open proposal%; decide or defer them before settling it', n, case when n = 1 then '' else 's' end;
    end if;
  end if;
  if p_status = 'not_started' then
    delete from sscc_bylaws_section_status where section_key = p_section_key;
  else
    insert into sscc_bylaws_section_status (section_key, status, note, set_by, set_at)
    values (p_section_key, p_status, nullif(trim(p_note), ''), me.email, now())
    on conflict (section_key) do update set status = excluded.status, note = excluded.note, set_by = excluded.set_by, set_at = now();
  end if;
end;
$$;
grant execute on function sscc_bylaws_set_section_status(uuid, text, text, text) to anon, authenticated;

-- A new proposal on a settled section puts it back in review.
create or replace function sscc_bylaws_reopen_on_proposal()
returns trigger
language plpgsql security definer set search_path = public
as $$
begin
  update sscc_bylaws_section_status
  set status = 'in_review', note = 'Reopened by proposal #' || new.id, set_by = null, set_at = now()
  where section_key = new.section_key and status = 'settled';
  return new;
end;
$$;
revoke execute on function sscc_bylaws_reopen_on_proposal() from public, anon, authenticated;
drop trigger if exists sscc_bylaws_reopen_on_proposal on sscc_bylaws_proposals;
create trigger sscc_bylaws_reopen_on_proposal
  after insert on sscc_bylaws_proposals
  for each row execute function sscc_bylaws_reopen_on_proposal();

-- ---------------- meetings ----------------

create or replace function sscc_bylaws_meetings()
returns jsonb
language sql security definer set search_path = public stable
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
      'id', id, 'kind', kind, 'meets_on', meets_on, 'time_label', time_label, 'location', location,
      'title', title, 'focus', to_jsonb(focus), 'agenda', agenda, 'notes', notes, 'confirmed', confirmed)
    order by meets_on, kind desc, id), '[]'::jsonb)
  from sscc_bylaws_meetings;
$$;
grant execute on function sscc_bylaws_meetings() to anon, authenticated;

-- p_id null = new meeting
create or replace function sscc_bylaws_save_meeting(
  p_token uuid, p_id bigint, p_kind text, p_meets_on date, p_time_label text, p_location text,
  p_title text, p_focus text[], p_agenda text, p_notes text, p_confirmed boolean)
returns bigint
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
  new_id bigint;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can edit the meeting schedule'; end if;
  if p_meets_on is null then raise exception 'a date is required'; end if;
  if nullif(trim(p_title), '') is null then raise exception 'a title is required'; end if;
  if p_kind not in ('meeting', 'milestone') then raise exception 'unknown kind'; end if;
  if p_id is null then
    insert into sscc_bylaws_meetings (kind, meets_on, time_label, location, title, focus, agenda, notes, confirmed)
    values (p_kind, p_meets_on, nullif(trim(p_time_label), ''), nullif(trim(p_location), ''), trim(p_title),
            coalesce(p_focus, '{}'), nullif(trim(p_agenda), ''), nullif(trim(p_notes), ''), coalesce(p_confirmed, false))
    returning id into new_id;
    return new_id;
  end if;
  update sscc_bylaws_meetings set
    kind = p_kind, time_label = nullif(trim(p_time_label), ''), location = nullif(trim(p_location), ''),
    title = trim(p_title), focus = coalesce(p_focus, '{}'), agenda = nullif(trim(p_agenda), ''),
    notes = nullif(trim(p_notes), ''), confirmed = coalesce(p_confirmed, false),
    -- a new date gets a new reminder
    reminded_at = case when meets_on <> p_meets_on then null else reminded_at end,
    meets_on = p_meets_on, updated_at = now()
  where id = p_id;
  if not found then raise exception 'meeting not found'; end if;
  return p_id;
end;
$$;
grant execute on function sscc_bylaws_save_meeting(uuid, bigint, text, date, text, text, text, text[], text, text, boolean) to anon, authenticated;

create or replace function sscc_bylaws_delete_meeting(p_token uuid, p_id bigint)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can edit the meeting schedule'; end if;
  delete from sscc_bylaws_meetings where id = p_id;
end;
$$;
grant execute on function sscc_bylaws_delete_meeting(uuid, bigint) to anon, authenticated;

-- ---------------- alerts ----------------

create or replace function sscc_bylaws_set_alerts(p_token uuid, p_enabled boolean)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can change email alerts'; end if;
  update sscc_bylaws_settings set alerts_enabled = coalesce(p_enabled, true) where id = 1;
end;
$$;
grant execute on function sscc_bylaws_set_alerts(uuid, boolean) to anon, authenticated;

-- The trigger function that calls the Edge Function embeds its shared
-- secret (SSCC_BYLAWS_NOTIFY_SECRET), so, like notify_submission_webhook(),
-- it is applied directly to the database and not committed. To recreate
-- it: a plpgsql security-definer function sscc_bylaws_notify_webhook()
-- that does
--   perform net.http_post(
--     url := 'https://xdjbgcqaynnzykrglgnf.supabase.co/functions/v1/sscc-bylaws-notify',
--     headers := jsonb_build_object('Content-Type', 'application/json', 'x-webhook-secret', '<secret>'),
--     body := case when TG_TABLE_NAME = 'sscc_bylaws_proposals'
--       then jsonb_build_object('event', 'proposal', 'id', to_jsonb(new)->'id')
--       else jsonb_build_object('event', 'version', 'num', to_jsonb(new)->'num') end);
--   (to_jsonb, not new.num: plpgsql resolves both branches, and a
--   proposals row has no num, which would fail every insert.)
--   return new;
-- attached as the two triggers below. The daily reminder job is
--   select cron.schedule('sscc-bylaws-meeting-reminders', '0 15 * * *',
--     $$ select net.http_post(url := '<same url>', headers := <same headers>,
--        body := '{"event":"reminders"}'::jsonb) $$);
-- (15:00 UTC = 10 am Chicago in summer, 9 am in winter.)
--
-- drop trigger if exists sscc_bylaws_notify_proposal on sscc_bylaws_proposals;
-- create trigger sscc_bylaws_notify_proposal after insert on sscc_bylaws_proposals
--   for each row when (new.author_email is not null) execute function sscc_bylaws_notify_webhook();
-- drop trigger if exists sscc_bylaws_notify_version on sscc_bylaws_versions;
-- create trigger sscc_bylaws_notify_version after insert on sscc_bylaws_versions
--   for each row execute function sscc_bylaws_notify_webhook();

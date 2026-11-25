-- BIOS102 grades: late-work deadline (Nov 25, 2026). One value, set by instructors, shown to every student on My grades.
--  * bios102_grade_settings            key/value table (no API access; reached only through the functions below)
--  * bios102_grades_setting_set/get    instructor-only
--  * bios102_grades_payload            now also carries 'late_until' (everything else unchanged; checked below)
-- Safe to re-run. Apply with: supabase db query --linked -f supabase/bios102-grades-late-deadline.sql
begin;

create temp table _before as
select lower(email) as e, bios102_grades_payload(email) as j from bios102_grade_rows where email is not null;

create table if not exists bios102_grade_settings (
  key text primary key,
  value jsonb not null,
  updated_at timestamptz not null default now(),
  updated_by text
);
alter table bios102_grade_settings enable row level security;

-- Final acceptance for late work: Tuesday Dec 1, 2026, 4:50 PM Chicago time (CST, UTC-6). Only seeded if not set yet.
insert into bios102_grade_settings (key, value, updated_by)
values ('late_until', to_jsonb('2026-12-01T16:50:00-06:00'::text), 'seed')
on conflict (key) do nothing;

create or replace function bios102_grades_setting_get(p_session uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  return coalesce((select jsonb_object_agg(key, value) from bios102_grade_settings), '{}'::jsonb);
end;
$$;

create or replace function bios102_grades_setting_set(p_session uuid, p_key text, p_value jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_who text;
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  if p_key <> 'late_until' then
    raise exception 'Unknown setting.';
  end if;
  v_who := bios102_session_email(p_session);
  if p_value is null or jsonb_typeof(p_value) = 'null' then
    delete from bios102_grade_settings where key = p_key;
  else
    perform (p_value #>> '{}')::timestamptz;   -- must be a real date and time, or this raises
    insert into bios102_grade_settings (key, value, updated_by) values (p_key, p_value, v_who)
    on conflict (key) do update set value = excluded.value, updated_at = now(), updated_by = excluded.updated_by;
  end if;
  return bios102_grades_setting_get(p_session);
end;
$$;
grant execute on function bios102_grades_setting_get(uuid) to anon, authenticated;
grant execute on function bios102_grades_setting_set(uuid, text, jsonb) to anon, authenticated;

create or replace function bios102_grades_payload(p_email text)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_set bios102_grade_sets;
  v_row bios102_grade_rows;
begin
  select r.* into v_row
  from bios102_grade_rows r join bios102_grade_sets gs on gs.id = r.set_id
  where lower(r.email) = lower(p_email)
  order by gs.updated_at desc limit 1;
  if not found or v_row.data->>'status' = 'dropped' then
    return jsonb_build_object('found', false);
  end if;
  select * into v_set from bios102_grade_sets where id = v_row.set_id;
  return jsonb_build_object(
    'found', true,
    'first', split_part(v_row.student, ' ', 1),
    'gradebook', v_set.name,
    'columns', v_set.columns,
    'data', v_row.data - 'status',   -- internal notes (dropped / medical leave) never go to the student
    'late_until', (select value from bios102_grade_settings where key = 'late_until')
  );
end;
$$;
revoke execute on function bios102_grades_payload(text) from public, anon, authenticated;

-- the only change to what a student receives is the added 'late_until' key
do $$
declare bad int;
begin
  select count(*) into bad from _before b where (bios102_grades_payload(b.e) - 'late_until') is distinct from b.j;
  if bad > 0 then raise exception 'payload changed for % students beyond late_until; nothing applied', bad; end if;
end $$;

select (select value from bios102_grade_settings where key = 'late_until') as late_until, (select count(*) from _before) as students_checked;
commit;

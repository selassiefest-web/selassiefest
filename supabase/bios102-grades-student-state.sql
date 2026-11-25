-- BIOS102 My grades: the numbers a student types (lecture percent, wanted Exam 3 score, wanted overall grade)
-- are saved to the student's account so they follow the student to any device (Nov 25, 2026).
-- A student only ever reads and writes their OWN row: the row is found from the session's email, never from a parameter.
-- Safe to re-run. Apply with: supabase db query --linked -f supabase/bios102-grades-student-state.sql
begin;

create table if not exists bios102_grade_student_state (
  email text primary key,
  state jsonb not null default '{}'::jsonb,   -- {lec, exam3, want}: numbers only
  updated_at timestamptz not null default now()
);
alter table bios102_grade_student_state enable row level security;   -- no policies: reachable only through the functions below

create or replace function bios102_grades_state_get(p_session uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_email text := bios102_session_email(p_session);
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  return coalesce((select state from bios102_grade_student_state where lower(email) = lower(v_email)), '{}'::jsonb);
end;
$$;

create or replace function bios102_grades_state_set(p_session uuid, p_state jsonb)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_email text := bios102_session_email(p_session);
  v_new jsonb;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  -- only these three numbers, each held inside a sane range; anything else in p_state is ignored
  v_new := jsonb_strip_nulls(jsonb_build_object(
    'lec',   least(greatest((p_state->>'lec')::numeric, 0), 100),
    'exam3', least(greatest((p_state->>'exam3')::numeric, 0), 500),
    'want',  least(greatest((p_state->>'want')::numeric, 0), 100)));
  insert into bios102_grade_student_state (email, state, updated_at) values (lower(v_email), v_new, now())
  on conflict (email) do update set state = excluded.state, updated_at = now();
  return v_new;
end;
$$;

grant execute on function bios102_grades_state_get(uuid) to anon, authenticated;
grant execute on function bios102_grades_state_set(uuid, jsonb) to anon, authenticated;

select 'ok' as result, (select count(*) from bios102_grade_student_state) as saved_rows;
commit;

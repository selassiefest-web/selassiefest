-- BIOS102 My grades: the student's saved numbers now MERGE instead of replace, and also hold the Exam 3 study-guide checklist
-- (Nov 25, 2026). The guide's marks used to live only in one browser; now they follow the student to any device.
-- Stored under bios102_grade_student_state.state:
--   lec, exam3, want : numbers (see bios102-grades-student-state.sql)
--   study            : { marks: { "task-N-M": "ready" | "again" }, next: "task-N-M" | "" }
-- Only the keys present in p_state change; a JSON null removes that key. Everything is validated server-side; the row is found
-- from the session's own email, never from a parameter. Safe to re-run.
-- Apply with: supabase db query --linked -f supabase/bios102-grades-study-state.sql
begin;

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
  v_marks jsonb;
  v_next text;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception 'bad state';
  end if;
  v_new := coalesce((select state from bios102_grade_student_state where lower(email) = lower(v_email)), '{}'::jsonb);

  -- the three numbers, each held inside a sane range
  if p_state ? 'lec' then
    v_new := case when jsonb_typeof(p_state->'lec') = 'null' then v_new - 'lec'
                  else v_new || jsonb_build_object('lec', least(greatest((p_state->>'lec')::numeric, 0), 100)) end;
  end if;
  if p_state ? 'exam3' then
    v_new := case when jsonb_typeof(p_state->'exam3') = 'null' then v_new - 'exam3'
                  else v_new || jsonb_build_object('exam3', least(greatest((p_state->>'exam3')::numeric, 0), 500)) end;
  end if;
  if p_state ? 'want' then
    v_new := case when jsonb_typeof(p_state->'want') = 'null' then v_new - 'want'
                  else v_new || jsonb_build_object('want', least(greatest((p_state->>'want')::numeric, 0), 100)) end;
  end if;

  -- the study guide checklist: only well-formed task ids with the two allowed marks survive
  if p_state ? 'study' then
    if jsonb_typeof(p_state->'study') <> 'object' then
      v_new := v_new - 'study';
    else
      if jsonb_typeof(p_state->'study'->'marks') = 'object' and (select count(*) from jsonb_object_keys(p_state->'study'->'marks')) > 300 then
        raise exception 'too many marks';
      end if;
      v_marks := case when jsonb_typeof(p_state->'study'->'marks') = 'object'
        then coalesce((select jsonb_object_agg(k, v) from jsonb_each_text(p_state->'study'->'marks') as t(k, v)
                       where k ~ '^task-[0-9]{1,2}-[0-9]{1,3}$' and v in ('ready', 'again')), '{}'::jsonb)
        else '{}'::jsonb end;
      v_next := case when (p_state->'study'->>'next') ~ '^task-[0-9]{1,2}-[0-9]{1,3}$' then p_state->'study'->>'next' else '' end;
      v_new := v_new || jsonb_build_object('study', jsonb_build_object('marks', v_marks, 'next', v_next));
    end if;
  end if;

  insert into bios102_grade_student_state (email, state, updated_at) values (lower(v_email), v_new, now())
  on conflict (email) do update set state = excluded.state, updated_at = now();
  return v_new;
end;
$$;
grant execute on function bios102_grades_state_set(uuid, jsonb) to anon, authenticated;

select 'ok' as result;
commit;

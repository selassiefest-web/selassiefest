-- BIOS102 grades: instructor "view as" + privacy audit (Nov 25, 2026).
-- Why: an instructor must be able to confirm that a student sees only their own row.
--  * bios102_grades_payload(email)  = the ONE function that builds what a student receives.
--  * bios102_grades_mine(session)   = student path: session -> email -> payload (behavior unchanged).
--  * bios102_grades_view_as(...)    = instructor path: student name -> same payload + an audit + a log row.
--  * bios102_grades_isolation_audit = runs the audit for every linked student at once.
-- Safe to re-run. Apply with: supabase db query --linked -f supabase/bios102-grades-view-as.sql
-- The transaction aborts if the refactored mine path would return anything different from the old one.
begin;

create temp table _old_payload as
select lower(r.email) as e,
       case when r.data->>'status' = 'dropped' then jsonb_build_object('found', false)
            else jsonb_build_object('found', true, 'first', split_part(r.student, ' ', 1), 'gradebook', gs.name,
                                    'columns', gs.columns, 'data', r.data - 'status') end as j
from bios102_grade_rows r join bios102_grade_sets gs on gs.id = r.set_id
where r.email is not null;

create table if not exists bios102_grade_view_log (
  id bigint generated always as identity primary key,
  at timestamptz not null default now(),
  instructor_email text not null,
  student text not null,
  kind text not null
);
alter table bios102_grade_view_log enable row level security;   -- no policies: nobody reads it through the API

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
    'data', v_row.data - 'status'   -- internal notes (dropped / medical leave) never go to the student
  );
end;
$$;
revoke execute on function bios102_grades_payload(text) from public, anon, authenticated;

create or replace function bios102_grades_mine(p_session uuid)
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
  return bios102_grades_payload(v_email);
end;
$$;

-- what the audit measures: rows sent, size, and any OTHER student's name or email appearing in the payload
create or replace function bios102_grades_audit_of(p_email text)
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  with p as (select bios102_grades_payload(p_email) as j),
       t as (select j::text as s from p)
  select jsonb_build_object(
    'rows_sent', case when (select j->>'found' from p) = 'true' then 1 else 0 end,
    'bytes', (select octet_length(s) from t),
    'other_students_named', (select count(*) from bios102_grade_rows o, t
                              where lower(coalesce(o.email, '')) <> lower(p_email) and position(o.student in t.s) > 0),
    'other_emails_present', (select count(*) from bios102_students st, t
                              where lower(st.email) <> lower(p_email) and position(lower(st.email) in lower(t.s)) > 0)
  );
$$;
revoke execute on function bios102_grades_audit_of(text) from public, anon, authenticated;

create or replace function bios102_grades_view_as(p_session uuid, p_student text)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_instr text;
  v_email text;
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  v_instr := bios102_session_email(p_session);
  select r.email into v_email
  from bios102_grade_rows r join bios102_grade_sets gs on gs.id = r.set_id
  where r.student = p_student order by gs.updated_at desc limit 1;
  insert into bios102_grade_view_log (instructor_email, student, kind) values (v_instr, p_student, 'view_as');
  if v_email is null then
    return jsonb_build_object('found', false, 'audit', jsonb_build_object('note', 'this student has no login linked'));
  end if;
  return bios102_grades_payload(v_email) || jsonb_build_object('audit', bios102_grades_audit_of(v_email));
end;
$$;

create or replace function bios102_grades_isolation_audit(p_session uuid)
returns jsonb
language plpgsql
volatile
security definer
set search_path = public
as $$
declare
  v_out jsonb := '[]'::jsonb;
  r record;
  a jsonb;
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  for r in select distinct on (lower(email)) student, email from bios102_grade_rows where email is not null order by lower(email), student loop
    a := bios102_grades_audit_of(r.email);
    v_out := v_out || jsonb_build_array(jsonb_build_object(
      'student', r.student, 'rows_sent', a->'rows_sent', 'bytes', a->'bytes',
      'other_students_named', a->'other_students_named', 'other_emails_present', a->'other_emails_present',
      'ok', ((a->>'rows_sent')::int <= 1 and (a->>'other_students_named')::int = 0 and (a->>'other_emails_present')::int = 0)));
  end loop;
  insert into bios102_grade_view_log (instructor_email, student, kind)
    values (coalesce(bios102_session_email(p_session), '?'), '(all students)', 'privacy_check');
  return v_out;
end;
$$;

grant execute on function bios102_grades_mine(uuid) to anon, authenticated;
grant execute on function bios102_grades_view_as(uuid, text) to anon, authenticated;
grant execute on function bios102_grades_isolation_audit(uuid) to anon, authenticated;

-- the refactored student path must return exactly what the old one did, for every student, or nothing is applied
do $$
declare bad int;
begin
  select count(*) into bad from _old_payload o where bios102_grades_payload(o.e) is distinct from o.j;
  if bad > 0 then raise exception 'payload differs from the old mine() for % students; nothing applied', bad; end if;
end $$;

select (select count(*) from _old_payload) as students_compared, 'identical to the old student path' as result;
commit;

-- BIOS102 page-restricted students. A roster row with allowed_pages set may
-- only open those pages (null = the whole site, the normal case). Restricted
-- students are also left out of every instructor report and invite, and the
-- gradebook roster. Enforcement is in BIOS102/js/app.js (requireSession);
-- this function is how the browser learns the list after sign-in.
alter table bios102_students add column if not exists allowed_pages text[];

create or replace function bios102_session_pages(p_session uuid)
returns text[]
language sql
security definer
set search_path = public
stable
as $$
  select s.allowed_pages
  from bios102_login_links l
  join bios102_students s on lower(s.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';
$$;
grant execute on function bios102_session_pages(uuid) to anon, authenticated;

-- Keep restricted students out of the instructor's video-quiz results tab.
create or replace function bios102_video_quiz_results(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  return jsonb_build_object('students', coalesce((
    select jsonb_agg(jsonb_build_object(
      'name', s.display_name,
      'updated_at', t.updated_at,
      'state', t.rows -> 0 -> 'cnidariaVideoQuiz'
    ) order by s.display_name)
    from bios102_students s
    left join bios102_student_tables t
      on lower(t.email) = lower(s.email) and t.exercise_number = 9201 and t.table_name = 'Cnidaria Video Quiz'
    where s.major not ilike 'Instructor%' and s.allowed_pages is null
  ), '[]'::jsonb));
end;
$$;
grant execute on function bios102_video_quiz_results(uuid) to anon, authenticated;

-- parso004@rangers.uwp.edu: the Cnidaria video quiz and the Porifera/Cnidaria lesson only.
insert into bios102_students (email, display_name, major, allowed_pages)
values ('parso004@rangers.uwp.edu', 'Guest student', 'Student',
        array['/BIOS102/cnidaria-video-quiz.html', '/BIOS102/porifera-cnidaria.html'])
on conflict (email) do update set allowed_pages = excluded.allowed_pages;

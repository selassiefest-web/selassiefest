-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 Cnidaria video quiz: instructor-only results (/BIOS102/grades.html,
-- "Video quiz" tab). Finishing the quiz earns the 3 Lab 7 participation points, so
-- the instructor needs to see who finished.
-- Students save their quiz state under exercise_number 9201 in bios102_student_tables
-- (see BIOS102/cnidaria-video-quiz.html), readable by each student only through
-- bios102_load_tables. This function is the instructor's read: it answers only an
-- instructor session (bios102_session_is_instructor), lists every non-instructor
-- roster student, and returns each one's saved quiz state, or null if not started.
-- ─────────────────────────────────────────────────────────────────────────
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
    where s.major not ilike 'Instructor%'
  ), '[]'::jsonb));
end;
$$;

grant execute on function bios102_video_quiz_results(uuid) to anon, authenticated;

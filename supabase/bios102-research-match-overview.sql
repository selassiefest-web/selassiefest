-- BIOS102 Research Match: instructor overview returns progress only.
-- Removes each student's interview fit ratings from the output (the page promises instructors never
-- see written answers or notes, and the Class view never used the ratings), and counts a student as
-- "decided" only once the ask email is marked sent, not as soon as a first choice is clicked.
-- Safe to re-run. Apply: supabase db query --linked -f supabase/bios102-research-match-overview.sql
begin;

create or replace function bios102_rm_overview(p_session uuid)
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
  return jsonb_build_object(
    'students', coalesce((
      select jsonb_agg(jsonb_build_object(
        'name', s.display_name,
        'started', r.email is not null,
        'stage', r.state ->> 'stage',
        'profileDone', coalesce((r.state -> 'profileDone')::text = 'true', false),
        'shortlist', coalesce(r.state -> 'shortlist', '[]'::jsonb),
        'outreach', coalesce((
          select jsonb_object_agg(k, jsonb_build_object('status', v ->> 'status'))
          from jsonb_each(coalesce(r.state -> 'outreach', '{}'::jsonb)) as o(k, v)
        ), '{}'::jsonb),
        'final', case when r.state -> 'final' ->> 'askSentAt' is not null then r.state -> 'final' ->> 'faculty' end,
        'updated_at', r.updated_at
      ) order by s.display_name)
      from bios102_students s
      left join bios102_research_state r on lower(r.email) = lower(s.email)
      where s.major not ilike 'Instructor%' and s.allowed_pages is null
    ), '[]'::jsonb)
  );
end;
$$;
grant execute on function bios102_rm_overview(uuid) to anon;

commit;

select proname from pg_proc where proname = 'bios102_rm_overview';

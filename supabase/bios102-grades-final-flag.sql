-- BIOS102 grades: "lab scores are final" marker (Nov 25, 2026).
-- Dr. Taft and Dr. Mossman make the final course score; the lab instructor marks the lab scores final so they know when to take them.
-- Only harria01@uwp.edu can set or clear lab_final_at; every instructor can read it. Safe to re-run.
-- Apply with: supabase db query --linked -f supabase/bios102-grades-final-flag.sql
begin;

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
  if p_key not in ('late_until', 'lab_final_at') then
    raise exception 'Unknown setting.';
  end if;
  v_who := bios102_session_email(p_session);
  if p_key = 'lab_final_at' and lower(coalesce(v_who, '')) <> 'harria01@uwp.edu' then
    raise exception 'Only the lab instructor can mark lab scores final.';
  end if;
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
grant execute on function bios102_grades_setting_set(uuid, text, jsonb) to anon, authenticated;

select 'ok' as result, (select count(*) from bios102_grade_settings) as settings_rows;
commit;

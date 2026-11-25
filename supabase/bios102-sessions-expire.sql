-- BIOS102 sessions now expire (Nov 25, 2026). Before this, a sign-in link became a permanent session: bios102_verify_login_link
-- marked it 'active' and nothing ever looked at a date again.
--
-- Rule (Stephen): sessions end 30 days after the final. One setting holds the cutoff: bios102_grade_settings.sessions_expire_at.
--   * seeded 2027-01-01 23:59 Chicago (30 days after Wed Dec 2, 2026, the day the lab scores are final)
--   * when the lab instructor marks lab scores final, the server moves it to that moment + 30 days
--   * after the cutoff nobody can sign in or use a session until the setting is changed (new term: change it)
-- bios102_sessions_alive() is the one test; every function that reads bios102_login_links calls it.
-- Safe to re-run. Apply with: supabase db query --linked -f supabase/bios102-sessions-expire.sql
-- The transaction aborts if any session that works today would stop working before the cutoff.
begin;

create temp table _sess_before as
select id, bios102_session_email(id) as email, bios102_session_is_instructor(id) as instr
from bios102_login_links where status = 'active';

insert into bios102_grade_settings (key, value, updated_by)
values ('sessions_expire_at', to_jsonb('2027-01-01T23:59:00-06:00'::text), 'seed')
on conflict (key) do nothing;

create or replace function bios102_sessions_alive()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(now() < (select (value #>> '{}')::timestamptz from bios102_grade_settings where key = 'sessions_expire_at'), true);
$$;
revoke execute on function bios102_sessions_alive() from public, anon, authenticated;

-- Wire the test into every function that checks a session. Each rewrite is asserted, never assumed.
do $$
declare
  r record;
  v_def text;
  v_new text;
  v_done int := 0;
begin
  for r in
    select p.oid, p.proname from pg_proc p
    where p.pronamespace = 'public'::regnamespace and p.prokind = 'f'
      and p.prosrc ilike '%bios102_login_links%' and p.proname <> 'bios102_sessions_alive'
  loop
    v_def := pg_get_functiondef(r.oid);
    continue when position('bios102_sessions_alive' in v_def) > 0;          -- already done (re-run)
    if r.proname = 'bios102_verify_login_link' then
      -- a sign-in link cannot be redeemed after the cutoff either
      v_new := replace(v_def, 'and (l.status = ''active'' or', 'and bios102_sessions_alive() and (l.status = ''active'' or');
    else
      v_new := replace(v_def, 'l.status = ''active''', 'l.status = ''active'' and bios102_sessions_alive()');
    end if;
    if v_new = v_def or position('bios102_sessions_alive' in v_new) = 0 then
      raise exception 'could not wire the session test into %', r.proname;
    end if;
    execute v_new;
    v_done := v_done + 1;
  end loop;
  raise notice 'session test wired into % functions', v_done;
end $$;

-- the lab instructor can move the cutoff, and marking the lab final sets it to that moment + 30 days
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
  if p_key not in ('late_until', 'lab_final_at', 'sessions_expire_at') then
    raise exception 'Unknown setting.';
  end if;
  v_who := bios102_session_email(p_session);
  if p_key in ('lab_final_at', 'sessions_expire_at') and lower(coalesce(v_who, '')) <> 'harria01@uwp.edu' then
    raise exception 'Only the lab instructor can change this.';
  end if;
  if p_value is null or jsonb_typeof(p_value) = 'null' then
    if p_key = 'sessions_expire_at' then raise exception 'The session cutoff cannot be cleared; set a new date.'; end if;
    delete from bios102_grade_settings where key = p_key;
  else
    perform (p_value #>> '{}')::timestamptz;   -- must be a real date and time, or this raises
    insert into bios102_grade_settings (key, value, updated_by) values (p_key, p_value, v_who)
    on conflict (key) do update set value = excluded.value, updated_at = now(), updated_by = excluded.updated_by;
    if p_key = 'lab_final_at' then
      insert into bios102_grade_settings (key, value, updated_by)
      values ('sessions_expire_at', to_jsonb(to_char(((p_value #>> '{}')::timestamptz + interval '30 days') at time zone 'America/Chicago', 'YYYY-MM-DD"T"HH24:MI:SS') || '-06:00'), v_who)
      on conflict (key) do update set value = excluded.value, updated_at = now(), updated_by = excluded.updated_by;
    end if;
  end if;
  return bios102_grades_setting_get(p_session);
end;
$$;
grant execute on function bios102_grades_setting_set(uuid, text, jsonb) to anon, authenticated;

-- every session that worked before still works (the cutoff is in the future)
do $$
declare bad int;
begin
  select count(*) into bad from _sess_before b
  where bios102_session_email(b.id) is distinct from b.email or bios102_session_is_instructor(b.id) is distinct from b.instr;
  if bad > 0 then raise exception '% sessions changed behavior; nothing applied', bad; end if;
end $$;

select (select count(*) from _sess_before) as sessions_checked,
       (select value #>> '{}' from bios102_grade_settings where key = 'sessions_expire_at') as sessions_expire_at,
       (select count(*) from pg_proc where pronamespace = 'public'::regnamespace and prokind = 'f' and prosrc ilike '%bios102_sessions_alive%') as functions_using_it;
commit;

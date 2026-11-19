-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 Research Match (/BIOS102/research-match.html).
-- Students find a UW-Parkside Biological Sciences research mentor in four
-- moves: know yourself -> meet the researchers -> interview them -> decide.
--
-- One row per student holds their whole working state as jsonb (answers,
-- shortlist, per-professor outreach and interview notes, final choice).
-- Same security model as bios102_student_tables: RLS on, ZERO policies, and
-- every read/write goes through a security-definer function that resolves
-- p_session against bios102_login_links itself, so a browser can never read
-- or write another student's row by guessing an email.
--
-- A student can read and write ONLY their own row. The instructor overview
-- returns structure only (stage, who is on whose shortlist, outreach
-- status). It never returns free-text answers or interview notes.
--
-- WARNING: re-running this file reverts bios102_rm_save to the version WITHOUT the two-device conflict check.
-- After any re-run, also apply supabase/bios102-research-match-conflict.sql AND supabase/bios102-research-match-overview.sql
-- (this file still has the old overview that returns interview fit ratings).
-- Safe to re-run: create-if-not-exists and create-or-replace throughout.
-- Apply with:  supabase db query --linked -f supabase/bios102-research-match.sql
-- ─────────────────────────────────────────────────────────────────────────
begin;

create table if not exists bios102_research_state (
  email text primary key,
  state jsonb not null default '{}'::jsonb,
  last_emailed_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table bios102_research_state enable row level security;
-- Deliberately no policies: service role and the functions below only.

drop trigger if exists bios102_research_state_touch on bios102_research_state;
create trigger bios102_research_state_touch
  before update on bios102_research_state
  for each row execute function bios102_set_updated_at();

-- Internal: the roster email behind an active session (null if none).
create or replace function bios102_rm_email(p_session uuid)
returns text
language sql
security definer
set search_path = public
stable
as $$
  select s.email
  from bios102_login_links l
  join bios102_students s on lower(s.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';
$$;
revoke execute on function bios102_rm_email(uuid) from public, anon, authenticated;

-- A student loads their own state ('{}' when they have not started).
create or replace function bios102_rm_load(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  v_email text := bios102_rm_email(p_session);
  v_state jsonb;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  select r.state into v_state from bios102_research_state r where lower(r.email) = lower(v_email);
  return coalesce(v_state, '{}'::jsonb);
end;
$$;
grant execute on function bios102_rm_load(uuid) to anon;

-- A student saves their own state. Capped at 200 KB so a runaway client
-- cannot stuff the table.
create or replace function bios102_rm_save(p_session uuid, p_state jsonb)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := bios102_rm_email(p_session);
  v_at timestamptz;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception 'state must be a JSON object';
  end if;
  if octet_length(p_state::text) > 200000 then
    raise exception 'state too large';
  end if;
  insert into bios102_research_state (email, state)
  values (v_email, p_state)
  on conflict (email) do update set state = excluded.state
  returning updated_at into v_at;
  return v_at;
end;
$$;
grant execute on function bios102_rm_save(uuid, jsonb) to anon;

-- Instructor overview: who has started, where they are, and how many
-- students are approaching each professor (so no one professor is swamped).
-- Structure only: no free text, no interview notes, no emails.
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
          select jsonb_object_agg(k, jsonb_build_object('status', v ->> 'status', 'fit', v -> 'fit'))
          from jsonb_each(coalesce(r.state -> 'outreach', '{}'::jsonb)) as o(k, v)
        ), '{}'::jsonb),
        'final', r.state -> 'final' ->> 'faculty',
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

-- Verify
select 'table' as what, count(*)::text as n from bios102_research_state
union all select 'rls_on', relrowsecurity::text from pg_class where relname = 'bios102_research_state'
union all select 'policies', count(*)::text from pg_policies where tablename = 'bios102_research_state'
union all select 'functions', count(*)::text from pg_proc where proname in ('bios102_rm_load','bios102_rm_save','bios102_rm_overview','bios102_rm_email');

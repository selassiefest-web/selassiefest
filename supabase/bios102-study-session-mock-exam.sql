-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 study-session calendar + Lab Exam 1 mock exam
-- (/BIOS102/study-guide.html and /BIOS102/mock-exam.html).
--
-- Same trust model as bios102_student_tables: every table has RLS on and no
-- policies, and every read/write goes through a security-definer function
-- that resolves the session token (bios102_login_links) back to a roster
-- email. Instructor = a bios102_students row whose major starts with
-- 'Instructor' (same rule send-bios102-quiz-report uses).
--
-- The exam itself (questions + answer key) lives in bios102_mock_exam and is
-- seeded out of band against the live project, never committed here: this
-- repo and site are public, and the whole point of the table is that the
-- questions only leave the database through bios102_mock_start while the
-- window is open (or the student has been granted access).
-- Window: Tue Oct 13 2026, 11:00 am - 6:00 pm Central (UTC-5 in October).
-- ─────────────────────────────────────────────────────────────────────────

-- Session helpers (not callable from the browser; the public functions below
-- call them as the function owner).
create or replace function bios102_session_email(p_session uuid)
returns text
language sql
security definer
set search_path = public
stable
as $$
  select s.email
  from bios102_login_links l
  join bios102_students s on lower(s.email) = lower(l.email)
  where l.id = p_session and l.status = 'active'
  limit 1;
$$;

create or replace function bios102_session_is_instructor(p_session uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((
    select s.major ilike 'Instructor%'
    from bios102_login_links l
    join bios102_students s on lower(s.email) = lower(l.email)
    where l.id = p_session and l.status = 'active'
    limit 1
  ), false);
$$;

revoke execute on function bios102_session_email(uuid) from public, anon, authenticated;
revoke execute on function bios102_session_is_instructor(uuid) from public, anon, authenticated;

create or replace function bios102_norm(t text)
returns text
language sql
immutable
set search_path = ''
as $$
  select btrim(regexp_replace(regexp_replace(lower(coalesce(t, '')), '[^a-z0-9 ]', ' ', 'g'), '\s+', ' ', 'g'));
$$;

-- ── Study-session calendar ───────────────────────────────────────────────
create table if not exists bios102_study_picks (
  email text not null,
  slot_key text not null,
  created_at timestamptz not null default now(),
  primary key (email, slot_key)
);
alter table bios102_study_picks enable row level security;

create table if not exists bios102_study_decisions (
  slot_key text primary key,
  status text not null check (status in ('accepted', 'rejected')),
  decided_at timestamptz not null default now()
);
alter table bios102_study_decisions enable row level security;

-- slot_key = '<yyyy-mm-dd>_<hh>' (24 h start hour), Thu Oct 15 - Mon Oct 19 2026, 09-20.
create or replace function bios102_study_load(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  v_email text := bios102_session_email(p_session);
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  return jsonb_build_object(
    'instructor', bios102_session_is_instructor(p_session),
    'picks', coalesce((
      select jsonb_agg(jsonb_build_object(
        'slot', p.slot_key, 'name', s.display_name, 'mine', lower(p.email) = lower(v_email)
      ) order by p.created_at)
      from bios102_study_picks p
      join bios102_students s on lower(s.email) = lower(p.email)
    ), '[]'::jsonb),
    'decisions', coalesce((select jsonb_object_agg(slot_key, status) from bios102_study_decisions), '{}'::jsonb)
  );
end;
$$;

create or replace function bios102_study_toggle(p_session uuid, p_slot text, p_on boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := bios102_session_email(p_session);
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  if bios102_session_is_instructor(p_session) then
    raise exception 'Instructors accept or reject times instead of picking them.';
  end if;
  if p_slot !~ '^2026-10-(15|16|17|18|19)_(09|1[0-9]|20)$' then
    raise exception 'That is not a time on the calendar.';
  end if;
  if p_on then
    if exists (select 1 from bios102_study_decisions where slot_key = p_slot and status = 'rejected') then
      raise exception 'That time is not available.';
    end if;
    if (select count(*) from bios102_study_picks where lower(email) = lower(v_email) and slot_key <> p_slot) >= 3 then
      raise exception 'You can pick up to 3 times. Remove one first.';
    end if;
    insert into bios102_study_picks (email, slot_key) values (v_email, p_slot) on conflict do nothing;
  else
    delete from bios102_study_picks where lower(email) = lower(v_email) and slot_key = p_slot;
  end if;
end;
$$;

create or replace function bios102_study_decide(p_session uuid, p_slot text, p_status text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not bios102_session_is_instructor(p_session) then
    raise exception 'Instructor only.';
  end if;
  if p_slot !~ '^2026-10-(15|16|17|18|19)_(09|1[0-9]|20)$' then
    raise exception 'That is not a time on the calendar.';
  end if;
  if p_status is null then
    delete from bios102_study_decisions where slot_key = p_slot;
  elsif p_status in ('accepted', 'rejected') then
    insert into bios102_study_decisions (slot_key, status) values (p_slot, p_status)
    on conflict (slot_key) do update set status = excluded.status, decided_at = now();
  else
    raise exception 'Bad status.';
  end if;
end;
$$;

grant execute on function bios102_study_load(uuid) to anon, authenticated;
grant execute on function bios102_study_toggle(uuid, text, boolean) to anon, authenticated;
grant execute on function bios102_study_decide(uuid, text, text) to anon, authenticated;

-- ── Mock exam ────────────────────────────────────────────────────────────
-- One row (id = 1). questions = what the browser renders; key = answer key
-- and notes, only ever read by bios102_mock_grade.
create table if not exists bios102_mock_exam (
  id int primary key check (id = 1),
  questions jsonb not null,
  key jsonb not null
);
alter table bios102_mock_exam enable row level security;

create table if not exists bios102_mock_access (
  email text primary key,
  attended boolean not null default false,
  until timestamptz,
  updated_at timestamptz not null default now()
);
alter table bios102_mock_access enable row level security;

-- Someone who asked for access after the window, or started during it.
create table if not exists bios102_mock_requests (
  email text primary key,
  kind text not null check (kind in ('asked', 'started')),
  requested_at timestamptz not null default now()
);
alter table bios102_mock_requests enable row level security;

create table if not exists bios102_mock_attempts (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  score int not null,
  total int not null,
  parts jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now()
);
alter table bios102_mock_attempts enable row level security;
create index if not exists bios102_mock_attempts_email_idx on bios102_mock_attempts (lower(email));

create or replace function bios102_mock_opens() returns timestamptz
language sql immutable set search_path = '' as $$ select timestamptz '2026-10-13 11:00:00-05'; $$;
create or replace function bios102_mock_closes() returns timestamptz
language sql immutable set search_path = '' as $$ select timestamptz '2026-10-13 18:00:00-05'; $$;

create or replace function bios102_mock_allowed(p_session uuid)
returns boolean
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  v_email text := bios102_session_email(p_session);
begin
  if v_email is null then
    return false;
  end if;
  if bios102_session_is_instructor(p_session) then
    return true;
  end if;
  if now() >= bios102_mock_opens() and now() < bios102_mock_closes() then
    return true;
  end if;
  return exists (
    select 1 from bios102_mock_access a
    where lower(a.email) = lower(v_email) and (a.attended or a.until > now())
  );
end;
$$;
revoke execute on function bios102_mock_allowed(uuid) from public, anon, authenticated;

create or replace function bios102_mock_state(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  v_email text := bios102_session_email(p_session);
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  return jsonb_build_object(
    'instructor', bios102_session_is_instructor(p_session),
    'allowed', bios102_mock_allowed(p_session),
    'opens', bios102_mock_opens(),
    'closes', bios102_mock_closes(),
    'now', now(),
    'asked', exists (select 1 from bios102_mock_requests r where lower(r.email) = lower(v_email))
  );
end;
$$;

create or replace function bios102_mock_request_access(p_session uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := bios102_session_email(p_session);
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  insert into bios102_mock_requests (email, kind) values (v_email, 'asked')
  on conflict (email) do update set requested_at = now() where bios102_mock_requests.kind = 'asked';
end;
$$;

-- Returns the questions (never the key) only if the window is open or the
-- student has been let in; otherwise raises 'closed'.
create or replace function bios102_mock_start(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := bios102_session_email(p_session);
  v_q jsonb;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  if not bios102_mock_allowed(p_session) then
    raise exception 'closed';
  end if;
  select questions into v_q from bios102_mock_exam where id = 1;
  if v_q is null then
    raise exception 'The mock exam is not loaded yet.';
  end if;
  if not bios102_session_is_instructor(p_session) then
    insert into bios102_mock_requests (email, kind) values (v_email, 'started')
    on conflict (email) do update set kind = 'started', requested_at = now();
  end if;
  return v_q;
end;
$$;

-- p_answers = { "<question id>": "<answer string or choice index>" }.
-- Anyone who started inside the window may finish for 3 more hours; everyone
-- else needs current access.
create or replace function bios102_mock_grade(p_session uuid, p_answers jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := bios102_session_email(p_session);
  v_key jsonb;
  r record;
  v_given text;
  v_ok boolean;
  v_results jsonb := '{}'::jsonb;
  v_parts jsonb := '{}'::jsonb;
  v_sec text;
  v_score int := 0;
  v_total int := 0;
  v_started boolean;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  select exists (
    select 1 from bios102_mock_requests q
    where lower(q.email) = lower(v_email) and q.kind = 'started'
      and q.requested_at >= bios102_mock_opens() - interval '1 minute'
      and now() < q.requested_at + interval '3 hours'
  ) into v_started;
  if not (bios102_mock_allowed(p_session) or v_started) then
    raise exception 'closed';
  end if;
  select key into v_key from bios102_mock_exam where id = 1;
  if v_key is null then
    raise exception 'The mock exam is not loaded yet.';
  end if;

  for r in select k.key as qid, k.value as spec from jsonb_each(v_key) k loop
    v_given := p_answers ->> r.qid;
    if r.spec ->> 't' = 'text' then
      v_ok := bios102_norm(v_given) <> '' and exists (
        select 1 from jsonb_array_elements_text(r.spec -> 'a') tok
        where position(tok in bios102_norm(v_given)) > 0
      );
    elsif r.spec ->> 't' = 'choice' then
      v_ok := v_given is not null and v_given = (r.spec ->> 'a');
    else
      v_ok := v_given is not null and v_given = (r.spec ->> 'ans');
    end if;
    v_sec := left(r.qid, 1);
    v_total := v_total + 1;
    if v_ok then v_score := v_score + 1; end if;
    v_parts := jsonb_set(v_parts, array[v_sec],
      jsonb_build_array(
        coalesce((v_parts -> v_sec ->> 0)::int, 0) + case when v_ok then 1 else 0 end,
        coalesce((v_parts -> v_sec ->> 1)::int, 0) + 1));
    v_results := v_results || jsonb_build_object(r.qid, jsonb_build_object(
      'ok', v_ok, 'ans', r.spec ->> 'ans', 'note', coalesce(r.spec ->> 'note', '')));
  end loop;

  if not bios102_session_is_instructor(p_session) then
    insert into bios102_mock_attempts (email, score, total, parts) values (v_email, v_score, v_total, v_parts);
  end if;
  return jsonb_build_object('score', v_score, 'total', v_total, 'parts', v_parts, 'results', v_results);
end;
$$;

-- Instructor roster: every non-instructor on the class roster, who asked or
-- started, their access, and their best score.
create or replace function bios102_mock_admin_load(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
begin
  if not bios102_session_is_instructor(p_session) then
    raise exception 'Instructor only.';
  end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object(
      'email', s.email,
      'name', s.display_name,
      'kind', r.kind,
      'requested_at', r.requested_at,
      'attended', coalesce(a.attended, false),
      'until', a.until,
      'best', (select max(t.score) from bios102_mock_attempts t where lower(t.email) = lower(s.email)),
      'total', (select max(t.total) from bios102_mock_attempts t where lower(t.email) = lower(s.email))
    ) order by (r.requested_at is null), r.requested_at desc, s.display_name)
    from bios102_students s
    left join bios102_mock_requests r on lower(r.email) = lower(s.email)
    left join bios102_mock_access a on lower(a.email) = lower(s.email)
    where coalesce(s.major, '') not ilike 'Instructor%'
  ), '[]'::jsonb);
end;
$$;

-- p_mode: 'attended' (let in for good), 'temp' (24 hours), 'revoke'.
create or replace function bios102_mock_set_access(p_session uuid, p_email text, p_mode text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not bios102_session_is_instructor(p_session) then
    raise exception 'Instructor only.';
  end if;
  if not exists (select 1 from bios102_students where lower(email) = lower(p_email)) then
    raise exception 'Not on the roster.';
  end if;
  if p_mode = 'attended' then
    insert into bios102_mock_access (email, attended) values (lower(p_email), true)
    on conflict (email) do update set attended = true, updated_at = now();
  elsif p_mode = 'temp' then
    insert into bios102_mock_access (email, until) values (lower(p_email), now() + interval '24 hours')
    on conflict (email) do update set until = now() + interval '24 hours', updated_at = now();
  elsif p_mode = 'revoke' then
    delete from bios102_mock_access where lower(email) = lower(p_email);
  else
    raise exception 'Bad mode.';
  end if;
end;
$$;

grant execute on function bios102_mock_state(uuid) to anon, authenticated;
grant execute on function bios102_mock_request_access(uuid) to anon, authenticated;
grant execute on function bios102_mock_start(uuid) to anon, authenticated;
grant execute on function bios102_mock_grade(uuid, jsonb) to anon, authenticated;
grant execute on function bios102_mock_admin_load(uuid) to anon, authenticated;
grant execute on function bios102_mock_set_access(uuid, text, text) to anon, authenticated;

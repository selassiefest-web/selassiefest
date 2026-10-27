-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 instructor gradebook (/BIOS102/grades.html).
-- Instructors only. Students never read, and never see a hint of, this data.
-- Same trust model as the rest of BIOS102: RLS on, NO policies on either
-- table, and every read/write goes through a security-definer function that
-- resolves the session token and checks bios102_session_is_instructor (from
-- bios102-study-session-mock-exam.sql; roster major starts with 'Instructor').
-- A student session, an unknown token or no token raises 'Instructor only.'
--
-- A "set" is one gradebook (columns + one row per student). Names are stored
-- as first name + last initial only, never IDs, logins or emails. Values are
-- jsonb keyed by column key; a null value means excused / no score (left out
-- of every statistic, never counted as zero).
-- NOTE: bios102_grades_load / bios102_grades_save are superseded by the versions in
-- bios102-grades-student.sql (they carry the email link). Apply that file after this one,
-- and never re-run only this file on a live database: it would put the old versions back.
-- The grade rows themselves are loaded out of band or through the page's
-- Import tab, and are never committed to this repo.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists bios102_grade_sets (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  columns jsonb not null default '[]'::jsonb,   -- [{key,label,max,group}]
  updated_at timestamptz not null default now()
);

create table if not exists bios102_grade_rows (
  id bigint generated always as identity primary key,
  set_id uuid not null references bios102_grade_sets(id) on delete cascade,
  student text not null,
  data jsonb not null default '{}'::jsonb       -- {columnKey: number|null, excused:[keys]}
);

alter table bios102_grade_sets enable row level security;
alter table bios102_grade_rows enable row level security;
create index if not exists bios102_grade_rows_set_idx on bios102_grade_rows (set_id);

create or replace function bios102_grades_is_instructor(p_session uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce(bios102_session_is_instructor(p_session), false);
$$;

create or replace function bios102_grades_load(p_session uuid)
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
  return jsonb_build_object('sets', coalesce((
    select jsonb_agg(jsonb_build_object(
      'id', gs.id, 'name', gs.name, 'columns', gs.columns, 'updated_at', gs.updated_at,
      'rows', coalesce((
        select jsonb_agg(jsonb_build_object('student', r.student, 'data', r.data) order by r.id)
        from bios102_grade_rows r where r.set_id = gs.id
      ), '[]'::jsonb)
    ) order by gs.updated_at desc)
    from bios102_grade_sets gs
  ), '[]'::jsonb));
end;
$$;

-- Replaces the named set wholesale (columns and every row). The page sends
-- the whole edited gradebook, so a save is always a consistent snapshot.
create or replace function bios102_grades_save(p_session uuid, p_name text, p_columns jsonb, p_rows jsonb)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id uuid;
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  if coalesce(btrim(p_name), '') = '' then
    raise exception 'A gradebook needs a name.';
  end if;
  if jsonb_typeof(p_columns) <> 'array' or jsonb_typeof(p_rows) <> 'array' then
    raise exception 'Bad gradebook.';
  end if;

  insert into bios102_grade_sets (name, columns) values (btrim(p_name), p_columns)
  on conflict (name) do update set columns = excluded.columns, updated_at = now()
  returning id into v_id;

  delete from bios102_grade_rows where set_id = v_id;
  insert into bios102_grade_rows (set_id, student, data)
  select v_id, x->>'student', coalesce(x->'data', '{}'::jsonb)
  from jsonb_array_elements(p_rows) x
  where coalesce(x->>'student', '') <> '';
  return v_id;
end;
$$;

create or replace function bios102_grades_delete(p_session uuid, p_set uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  delete from bios102_grade_sets where id = p_set;
end;
$$;

grant execute on function bios102_grades_is_instructor(uuid) to anon, authenticated;
grant execute on function bios102_grades_load(uuid) to anon, authenticated;
grant execute on function bios102_grades_save(uuid, text, jsonb, jsonb) to anon, authenticated;
grant execute on function bios102_grades_delete(uuid, uuid) to anon, authenticated;

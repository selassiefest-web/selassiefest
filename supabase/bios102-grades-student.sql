-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 student view of their OWN grades (/BIOS102/my-grades.html).
-- Builds on bios102-grades.sql. The rule that matters: a student's session
-- can only ever read the single row whose email matches that session. There is
-- no function that returns another student's row, a class list, or any
-- class-wide statistic to a student.
--
-- bios102_grade_rows gets an email column linking a gradebook row to its roster
-- account. A unique index guarantees one email never points at two rows in a
-- gradebook, so a student can never be shown someone else's record because of
-- a duplicate. Links are filled by bios102_grades_automatch (first name, plus
-- the last initial when the gradebook name carries one, e.g. 'Jackson F.') and
-- are re-applied on every save; the instructor page round-trips them.
-- ─────────────────────────────────────────────────────────────────────────
alter table bios102_grade_rows add column if not exists email text;
create unique index if not exists bios102_grade_rows_set_email_uniq
  on bios102_grade_rows (set_id, lower(email)) where email is not null;

-- Internal: link unlinked rows to roster accounts. Not callable from the browser.
-- A row is linked only when EXACTLY ONE roster account fits it (so an extra roster
-- student who shares a first name can never be picked arbitrarily), and never to an
-- account already linked to another row of the same gradebook.
create or replace function bios102_grades_automatch(p_set uuid)
returns void
language sql
security definer
set search_path = public
as $$
  with cand as (
    select r.id as row_id, s.email,
           count(*) over (partition by r.id) as fits
    from bios102_grade_rows r
    join bios102_students s
      on s.major not ilike 'Instructor%'
     and lower(split_part(r.student, ' ', 1)) = lower(split_part(s.display_name, ' ', 1))
     and (r.student !~ '^\S+ [A-Za-z]\.$'
          or upper(left(regexp_replace(s.display_name, '^.* ', ''), 1)) = upper(substr(r.student, length(r.student) - 1, 1)))
    where r.set_id = p_set and r.email is null
  )
  update bios102_grade_rows r set email = c.email
  from cand c
  where r.id = c.row_id and c.fits = 1
    and not exists (select 1 from bios102_grade_rows o where o.set_id = p_set and lower(o.email) = lower(c.email));
$$;
revoke execute on function bios102_grades_automatch(uuid) from public, anon, authenticated;

-- Instructor load/save now carry the email link so a save never drops it.
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
        select jsonb_agg(jsonb_build_object('student', r.student, 'data', r.data, 'email', r.email) order by r.id)
        from bios102_grade_rows r where r.set_id = gs.id
      ), '[]'::jsonb)
    ) order by gs.updated_at desc)
    from bios102_grade_sets gs
  ), '[]'::jsonb));
end;
$$;

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
  insert into bios102_grade_rows (set_id, student, data, email)
  select v_id, x->>'student', coalesce(x->'data', '{}'::jsonb), nullif(x->>'email', '')
  from jsonb_array_elements(p_rows) x
  where coalesce(x->>'student', '') <> '';
  perform bios102_grades_automatch(v_id);
  return v_id;
end;
$$;

-- The student view: the caller's own row, nothing else.
create or replace function bios102_grades_mine(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
declare
  v_email text := bios102_session_email(p_session);
  v_set bios102_grade_sets;
  v_row bios102_grade_rows;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  select r.* into v_row
  from bios102_grade_rows r join bios102_grade_sets gs on gs.id = r.set_id
  where lower(r.email) = lower(v_email)
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

grant execute on function bios102_grades_load(uuid) to anon, authenticated;
grant execute on function bios102_grades_save(uuid, text, jsonb, jsonb) to anon, authenticated;
grant execute on function bios102_grades_mine(uuid) to anon, authenticated;

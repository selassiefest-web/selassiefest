-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 letter-grade scale, kept in the database so the instructor gradebook
-- (/BIOS102/grades.html) and the student page (/BIOS102/my-grades.html) read ONE
-- list instead of each carrying its own copy.
-- Same trust model as the rest of BIOS102: RLS on, NO policies; every read and
-- write goes through a security-definer function that resolves the session
-- token. Any logged-in BIOS102 session may read the scale; only an instructor
-- session may change it, and a change is validated before it is stored.
-- Safe to re-run: the table is created if missing and the seed only fills an
-- empty table (it never overwrites a scale an instructor has edited).
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists bios102_grade_scale (
  letter  text primary key check (letter ~ '^[A-Z][+-]?$'),
  min_pct numeric(5,2) not null unique check (min_pct >= 0 and min_pct <= 100)
);
alter table bios102_grade_scale enable row level security;

insert into bios102_grade_scale (letter, min_pct)
select v.letter, v.min_pct
from (values ('A',92),('A-',90),('B+',88),('B',82),('B-',80),('C+',78),('C',72),
             ('C-',70),('D+',68),('D',62),('D-',60),('F',0)) as v(letter, min_pct)
where not exists (select 1 from bios102_grade_scale);

-- Any active BIOS102 session (student or instructor) may read the scale.
create or replace function bios102_grade_scale_get(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
begin
  if bios102_session_email(p_session) is null then
    raise exception 'Please log in again.';
  end if;
  return coalesce((
    select jsonb_agg(jsonb_build_object('letter', letter, 'min', min_pct) order by min_pct desc)
    from bios102_grade_scale
  ), '[]'::jsonb);
end;
$$;

-- Instructor only. p_scale = [{"letter":"A","min":92}, ...]. Replaces the whole
-- scale, or changes nothing (one transaction). Rules: 2 to 20 steps, unique
-- letters (one capital, optional + or -), minimums between 0 and 100 with no
-- repeats, and exactly one step at 0 so every score gets a letter.
create or replace function bios102_grade_scale_set(p_session uuid, p_scale jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_n int;
begin
  if not coalesce(bios102_session_is_instructor(p_session), false) then
    raise exception 'Instructor only.';
  end if;
  if p_scale is null or jsonb_typeof(p_scale) <> 'array' then
    raise exception 'Bad grade scale.';
  end if;
  v_n := jsonb_array_length(p_scale);
  if v_n < 2 or v_n > 20 then
    raise exception 'A grade scale needs between 2 and 20 steps.';
  end if;
  if exists (
    select 1 from jsonb_array_elements(p_scale) x
    where jsonb_typeof(x) <> 'object'
       or coalesce(jsonb_typeof(x->'letter') <> 'string', true)
       or coalesce(jsonb_typeof(x->'min') <> 'number', true)
  ) or exists (
    select 1 from jsonb_array_elements(p_scale) x
    where (x->>'letter') !~ '^[A-Z][+-]?$'
       or (x->>'min')::numeric < 0 or (x->>'min')::numeric > 100
  ) then
    raise exception 'Each step needs a letter like A or B+ and a minimum from 0 to 100.';
  end if;
  if (select count(distinct x->>'letter') from jsonb_array_elements(p_scale) x) <> v_n
     or (select count(distinct (x->>'min')::numeric) from jsonb_array_elements(p_scale) x) <> v_n then
    raise exception 'Letters and minimums must each be different.';
  end if;
  if (select count(*) from jsonb_array_elements(p_scale) x where (x->>'min')::numeric = 0) <> 1 then
    raise exception 'Exactly one step must start at 0 so every score gets a letter.';
  end if;

  delete from bios102_grade_scale;
  insert into bios102_grade_scale (letter, min_pct)
  select x->>'letter', (x->>'min')::numeric from jsonb_array_elements(p_scale) x;
  return bios102_grade_scale_get(p_session);
end;
$$;

grant execute on function bios102_grade_scale_get(uuid) to anon, authenticated;
grant execute on function bios102_grade_scale_set(uuid, jsonb) to anon, authenticated;

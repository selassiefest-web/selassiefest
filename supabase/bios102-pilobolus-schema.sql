-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 Pilobolus data sheet (BIOS102/pilobolus.html; lab manual pp. 39-40).
-- Table 1 is each lab group's own data; Table 2 pools all six groups and
-- averages them. One row per (group, light condition). Any logged-in
-- student can write any group's row (group members share one row, and it's
-- low-stakes class data); the last editor's display name is kept so the
-- class can see who entered what. Same access pattern as
-- bios102_student_tables: RLS on with zero policies, every read/write goes
-- through the session-scoped functions below, which resolve p_session
-- against bios102_login_links rather than trusting a client-sent email.
-- Unlike bios102_load_tables, the load here returns every group's rows
-- (that's the point of pooled class data) -- but never an email address.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists bios102_pilobolus_data (
  group_number int not null check (group_number between 1 and 6),
  light_condition text not null check (light_condition in ('light', 'dark')),
  mycelium_squares numeric check (mycelium_squares >= 0),
  developing_sporangiophores int check (developing_sporangiophores >= 0),
  developed_sporangiophores int check (developed_sporangiophores >= 0),
  sporangia_shot int check (sporangia_shot >= 0),
  observations text check (char_length(observations) <= 2000),
  updated_by_email text,
  updated_by_name text,
  updated_at timestamptz not null default now(),
  primary key (group_number, light_condition)
);

alter table bios102_pilobolus_data enable row level security;

create or replace function bios102_load_pilobolus(p_session uuid)
returns table (
  group_number int,
  light_condition text,
  mycelium_squares numeric,
  developing_sporangiophores int,
  developed_sporangiophores int,
  sporangia_shot int,
  observations text,
  updated_by_name text,
  updated_at timestamptz
)
language plpgsql
security definer
set search_path = public
stable
as $$
begin
  if not exists (
    select 1 from bios102_login_links l
    where l.id = p_session and l.status = 'active'
  ) then
    raise exception 'invalid or expired BIOS102 session';
  end if;

  return query
    select d.group_number, d.light_condition, d.mycelium_squares,
           d.developing_sporangiophores, d.developed_sporangiophores,
           d.sporangia_shot, d.observations, d.updated_by_name, d.updated_at
    from bios102_pilobolus_data d
    order by d.light_condition, d.group_number;
end;
$$;

grant execute on function bios102_load_pilobolus(uuid) to anon, authenticated;

-- Returns nothing (void), which sidesteps the output-column/column-name
-- ambiguity described above bios102_save_table.
create or replace function bios102_save_pilobolus(
  p_session uuid,
  p_group_number int,
  p_light_condition text,
  p_mycelium_squares numeric,
  p_developing int,
  p_developed int,
  p_shot int,
  p_observations text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
  v_name text;
begin
  select s.email, s.display_name into v_email, v_name
  from bios102_login_links l
  join bios102_students s on lower(s.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';

  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;

  insert into bios102_pilobolus_data as d (
    group_number, light_condition, mycelium_squares,
    developing_sporangiophores, developed_sporangiophores, sporangia_shot,
    observations, updated_by_email, updated_by_name, updated_at
  )
  values (
    p_group_number, p_light_condition, p_mycelium_squares,
    p_developing, p_developed, p_shot,
    nullif(trim(p_observations), ''), v_email, v_name, now()
  )
  on conflict on constraint bios102_pilobolus_data_pkey do update
    set mycelium_squares = excluded.mycelium_squares,
        developing_sporangiophores = excluded.developing_sporangiophores,
        developed_sporangiophores = excluded.developed_sporangiophores,
        sporangia_shot = excluded.sporangia_shot,
        observations = excluded.observations,
        updated_by_email = excluded.updated_by_email,
        updated_by_name = excluded.updated_by_name,
        updated_at = now();
end;
$$;

grant execute on function bios102_save_pilobolus(uuid, int, text, numeric, int, int, int, text) to anon, authenticated;

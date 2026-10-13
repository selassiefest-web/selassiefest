-- ─────────────────────────────────────────────────────────────────────────
-- BIOS102 live presentation (/BIOS102/live.html): the instructor steps
-- through the slides and every student's page follows along.
-- One row (id = 1) holds the slide the instructor is on. Same trust model as
-- the rest of BIOS102: RLS on, no policies, and every read/write goes through
-- a security-definer function that resolves the session token. Students poll
-- bios102_live_get; only an instructor session can call bios102_live_set.
-- Depends on bios102_session_email / bios102_session_is_instructor from
-- bios102-study-session-mock-exam.sql.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists bios102_live_state (
  id int primary key check (id = 1),
  slide int not null default 0,
  active boolean not null default false,
  updated_at timestamptz not null default now()
);
alter table bios102_live_state enable row level security;

insert into bios102_live_state (id) values (1) on conflict (id) do nothing;

create or replace function bios102_live_get(p_session uuid)
returns jsonb
language plpgsql
security definer
set search_path = public
stable
as $$
begin
  if bios102_session_email(p_session) is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  return (
    select jsonb_build_object(
      'slide', s.slide, 'active', s.active, 'updated_at', s.updated_at,
      'instructor', bios102_session_is_instructor(p_session))
    from bios102_live_state s where s.id = 1
  );
end;
$$;

create or replace function bios102_live_set(p_session uuid, p_slide int, p_active boolean)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not bios102_session_is_instructor(p_session) then
    raise exception 'Instructor only.';
  end if;
  if p_slide < 0 or p_slide > 200 then
    raise exception 'Bad slide.';
  end if;
  update bios102_live_state
    set slide = p_slide, active = p_active, updated_at = now()
    where id = 1;
end;
$$;

grant execute on function bios102_live_get(uuid) to anon, authenticated;
grant execute on function bios102_live_set(uuid, int, boolean) to anon, authenticated;

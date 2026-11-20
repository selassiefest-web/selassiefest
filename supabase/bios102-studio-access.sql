-- BIOS102 Research-to-Grant Studio: invite list (Nov 19, 2026).
-- Only invited students (and instructors) may open the Studio. Same trust model
-- as the rest of BIOS102: RLS on, NO policies, access only through a
-- security-definer function that resolves the session token. Safe to re-run.
begin;

create table if not exists bios102_studio_access (
  email      text primary key,
  invited_at timestamptz not null default now(),
  note       text
);
alter table bios102_studio_access enable row level security;

create or replace function bios102_studio_has_access(p_session uuid)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select coalesce((
    select (
      bios102_session_is_instructor(p_session)
      or exists (select 1 from bios102_studio_access a where lower(a.email) = lower(l.email))
    )
    from bios102_login_links l
    where l.id = p_session and l.status = 'active'
    limit 1
  ), false);
$$;
grant execute on function bios102_studio_has_access(uuid) to anon, authenticated;

insert into bios102_studio_access (email, note)
values ('harria01@uwp.edu', 'Albert Harris, instructor: administers invitations')
on conflict (email) do nothing;

commit;

select (select count(*) from bios102_studio_access) as invited,
       (select relrowsecurity from pg_class where relname = 'bios102_studio_access') as rls_on,
       bios102_studio_has_access('00000000-0000-0000-0000-000000000000') as bogus_token_has_access;

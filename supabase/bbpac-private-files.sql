-- BBPAC private records (Nov 2, 2026). The records are sensitive (FOIA work), the GitHub repo is public,
-- so the files live here instead of on the website. Only the existing BBPAC sign-in (bbpac_tracker_login_links,
-- roster = bbpac_tracker_volunteers) can read them, through the function below. No anon table access.
-- Apply: supabase db query --linked -f supabase/bbpac-private-files.sql   (safe to re-run; content is loaded by a private script, never committed)
create table if not exists bbpac_private_files (
  path text not null,                    -- e.g. /bbpac/organization/matrix.html
  part integer not null default 0,       -- big files are stored in chunks of about 1 MB; the function joins them
  mime text not null,
  is_text boolean not null,
  body text not null,                    -- text files as-is, binary files base64
  bytes integer not null default 0,      -- size of the whole file (repeated on each part)
  updated_at timestamptz not null default now(),
  primary key (path, part)
);
alter table bbpac_private_files enable row level security;
revoke all on bbpac_private_files from anon, authenticated;

-- A session = an 'active' tracker login link for a person on the roster, used within the last 90 days.
create or replace function bbpac_private_session_ok(p_session uuid) returns boolean
language sql security definer set search_path = public stable as $$
  select exists (
    select 1 from bbpac_tracker_login_links l
    join bbpac_tracker_volunteers v on lower(v.email) = lower(l.email)
    where l.id = p_session and l.status = 'active' and l.created_at > now() - interval '90 days');
$$;
revoke all on function bbpac_private_session_ok(uuid) from public, anon, authenticated;

create or replace function bbpac_private_file(p_session uuid, p_path text)
returns table (path text, mime text, is_text boolean, body text)
language plpgsql security definer set search_path = public as $$
declare v_path text;
begin
  if not bbpac_private_session_ok(p_session) then raise exception 'not signed in'; end if;
  select f.path into v_path from bbpac_private_files f
    where f.path = p_path or f.path = rtrim(p_path,'/') || '/index.html' order by (f.path = p_path) desc limit 1;
  if v_path is null then return; end if;
  return query select f.path, min(f.mime), bool_or(f.is_text), string_agg(f.body, '' order by f.part)
    from bbpac_private_files f where f.path = v_path group by f.path;
end $$;
revoke all on function bbpac_private_file(uuid, text) from public;
grant execute on function bbpac_private_file(uuid, text) to anon, authenticated;

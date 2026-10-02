-- ============================================================================
-- Yawd Dry Goods supplier outreach tracker (/yawd-dry-goods/outreach/)
-- ============================================================================
-- Apply to the linked project with:
--     npx supabase db query --linked -f supabase/yawd-tracker.sql
--
-- Same magic-link sign-in as BIOS102 (see bios102_login_links in schema.sql):
-- an emailed link whose unguessable id becomes the browser's session token.
--
-- Nothing here is readable by anon. The access list (yawd_tracker_users) and
-- the supplier records (yawd_tracker_docs) are seeded out of band through the
-- SQL editor / `db query`, never committed -- this repo and site are public,
-- and the records hold suppliers' personal phone numbers and email addresses.
-- Every read and write goes through the session-checked security-definer
-- functions below.
-- ============================================================================

create table if not exists public.yawd_tracker_users (
  email         text primary key,
  display_name  text,
  created_at    timestamptz not null default now()
);
alter table public.yawd_tracker_users enable row level security;

create or replace function public.yawd_tracker_is_allowed(p_email text)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from yawd_tracker_users where lower(email) = lower(trim(p_email))
  );
$$;
grant execute on function public.yawd_tracker_is_allowed(text) to anon, authenticated;

create table if not exists public.yawd_tracker_login_links (
  id          uuid primary key default gen_random_uuid(),
  email       text not null,
  status      text not null default 'pending' check (status in ('pending', 'active')),
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default (now() + interval '30 minutes')
);
alter table public.yawd_tracker_login_links enable row level security;

-- A non-listed email can't even create a row, so it can't trigger a send.
drop policy if exists "listed user can request a yawd tracker link" on public.yawd_tracker_login_links;
create policy "listed user can request a yawd tracker link" on public.yawd_tracker_login_links
  for insert to anon, authenticated
  with check (public.yawd_tracker_is_allowed(email));
grant insert on public.yawd_tracker_login_links to anon, authenticated;

create index if not exists yawd_tracker_login_links_email_idx on public.yawd_tracker_login_links (lower(email));

-- Sends the link -- see formatYawdTrackerLoginLink in notify-submission.
drop trigger if exists yawd_tracker_login_links_notify on public.yawd_tracker_login_links;
create trigger yawd_tracker_login_links_notify
  after insert on public.yawd_tracker_login_links
  for each row execute function notify_submission_webhook();

-- Resolves a session token to a still-listed user's email, or null.
-- Removing someone from yawd_tracker_users revokes every session they hold.
create or replace function public.yawd_tracker_session_email(p_session uuid)
returns text
language sql
stable
security definer
set search_path = public
as $$
  select u.email
  from yawd_tracker_login_links l
  join yawd_tracker_users u on lower(u.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';
$$;
revoke execute on function public.yawd_tracker_session_email(uuid) from public, anon, authenticated;

-- Activates a clicked link (within 30 minutes) or re-validates an active
-- session. No rows = request a new link.
create or replace function public.yawd_tracker_verify(p_token uuid)
returns table (session_token uuid, email text, display_name text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
begin
  select u.email into v_email
  from yawd_tracker_login_links l
  join yawd_tracker_users u on lower(u.email) = lower(l.email)
  where l.id = p_token
    and (l.status = 'active' or (l.status = 'pending' and l.expires_at > now()));

  if v_email is null then
    return;
  end if;

  update yawd_tracker_login_links set status = 'active' where id = p_token and status <> 'active';

  return query
    select p_token, u.email, u.display_name from yawd_tracker_users u where lower(u.email) = lower(v_email);
end;
$$;
grant execute on function public.yawd_tracker_verify(uuid) to anon, authenticated;

-- Supplier records and page metadata. collection = 'suppliers' | 'meta'.
create table if not exists public.yawd_tracker_docs (
  collection  text not null check (collection in ('suppliers', 'meta')),
  id          text not null check (char_length(id) between 1 and 80),
  data        jsonb not null,
  updated_at  timestamptz not null default now(),
  updated_by  text,
  primary key (collection, id)
);
alter table public.yawd_tracker_docs enable row level security;

create or replace function public.yawd_tracker_load(p_session uuid)
returns table (collection text, id text, data jsonb, updated_at timestamptz, updated_by text)
language plpgsql
stable
security definer
set search_path = public
as $$
begin
  if yawd_tracker_session_email(p_session) is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  return query select d.collection, d.id, d.data, d.updated_at, d.updated_by from yawd_tracker_docs d;
end;
$$;
grant execute on function public.yawd_tracker_load(uuid) to anon, authenticated;

create or replace function public.yawd_tracker_save(p_session uuid, p_id text, p_data jsonb)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := yawd_tracker_session_email(p_session);
  v_now timestamptz := now();
begin
  if v_email is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  if jsonb_typeof(p_data) <> 'object' or coalesce(p_data->>'company', '') = '' then
    raise exception 'a supplier needs a company name' using errcode = '22023';
  end if;
  insert into yawd_tracker_docs (collection, id, data, updated_at, updated_by)
  values ('suppliers', p_id, p_data, v_now, v_email)
  on conflict (collection, id) do update
    set data = excluded.data, updated_at = v_now, updated_by = v_email;
  return v_now;
end;
$$;
grant execute on function public.yawd_tracker_save(uuid, text, jsonb) to anon, authenticated;

create or replace function public.yawd_tracker_delete(p_session uuid, p_id text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if yawd_tracker_session_email(p_session) is null then
    raise exception 'not signed in' using errcode = '28000';
  end if;
  delete from yawd_tracker_docs where collection = 'suppliers' and id = p_id;
end;
$$;
grant execute on function public.yawd_tracker_delete(uuid, text) to anon, authenticated;

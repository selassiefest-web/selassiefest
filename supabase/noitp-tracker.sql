-- Night Out in the Parks 2027 submission tracker (/rti/night-out/?k=<team key>).
-- Both tables are locked (RLS on, no policies). The page reads and writes only through the two
-- functions below, which check the team key. The key row and the seed rows are loaded out of
-- band and are never committed. Apply with: supabase db query --linked -f supabase/noitp-tracker.sql

create table if not exists noitp_tracks (
  id text primary key,
  data jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);
create table if not exists noitp_team (k text primary key);
alter table noitp_tracks enable row level security;
alter table noitp_team enable row level security;

create or replace function noitp_list(p_key text)
returns table(id text, data jsonb)
language plpgsql security definer set search_path = public as $$
begin
  if not exists (select 1 from noitp_team where k = p_key) then
    raise exception 'not allowed';
  end if;
  return query select t.id, t.data from noitp_tracks t order by t.id;
end $$;

-- Merges a patch into one track. gates and steps merge key by key so two people ticking
-- different boxes do not overwrite each other; every other field is replaced.
create or replace function noitp_save(p_key text, p_id text, p_patch jsonb)
returns void
language plpgsql security definer set search_path = public as $$
declare cur jsonb;
begin
  if not exists (select 1 from noitp_team where k = p_key) then
    raise exception 'not allowed';
  end if;
  if p_id not in ('t1','t2','t3','t4') then
    raise exception 'unknown track';
  end if;
  select data into cur from noitp_tracks where id = p_id;
  cur := coalesce(cur, '{}'::jsonb);
  insert into noitp_tracks(id, data) values (p_id,
    (cur || (p_patch - 'gates' - 'steps'))
    || jsonb_build_object(
         'gates', coalesce(cur->'gates','{}'::jsonb) || coalesce(p_patch->'gates','{}'::jsonb),
         'steps', coalesce(cur->'steps','{}'::jsonb) || coalesce(p_patch->'steps','{}'::jsonb)))
  on conflict (id) do update set data = excluded.data, updated_at = now();
end $$;

revoke all on function noitp_list(text) from public;
revoke all on function noitp_save(text, text, jsonb) from public;
grant execute on function noitp_list(text) to anon, authenticated;
grant execute on function noitp_save(text, text, jsonb) to anon, authenticated;

-- Track-only links (10/21): a key row with `track` set opens just that one track,
-- e.g. Max sees only Track 4. Team keys (track null) still see all four.
alter table noitp_team add column if not exists track text;

create or replace function noitp_list(p_key text)
returns table(id text, data jsonb)
language plpgsql security definer set search_path = public as $$
declare v_track text;
begin
  if not exists (select 1 from noitp_team where k = p_key) then
    raise exception 'not allowed';
  end if;
  select nt.track into v_track from noitp_team nt where nt.k = p_key;
  return query select t.id, t.data from noitp_tracks t
    where v_track is null or t.id = v_track order by t.id;
end $$;

create or replace function noitp_save(p_key text, p_id text, p_patch jsonb)
returns void
language plpgsql security definer set search_path = public as $$
declare cur jsonb; v_track text;
begin
  if not exists (select 1 from noitp_team where k = p_key) then
    raise exception 'not allowed';
  end if;
  select nt.track into v_track from noitp_team nt where nt.k = p_key;
  if v_track is not null and p_id <> v_track then
    raise exception 'not allowed';
  end if;
  if p_id not in ('t1','t2','t3','t4') then
    raise exception 'unknown track';
  end if;
  select data into cur from noitp_tracks where id = p_id;
  cur := coalesce(cur, '{}'::jsonb);
  insert into noitp_tracks(id, data) values (p_id,
    (cur || (p_patch - 'gates' - 'steps'))
    || jsonb_build_object(
         'gates', coalesce(cur->'gates','{}'::jsonb) || coalesce(p_patch->'gates','{}'::jsonb),
         'steps', coalesce(cur->'steps','{}'::jsonb) || coalesce(p_patch->'steps','{}'::jsonb)))
  on conflict (id) do update set data = excluded.data, updated_at = now();
end $$;

-- Which track a key is limited to (null = all four). The page uses it to hide the board.
create or replace function noitp_scope(p_key text)
returns text
language plpgsql security definer set search_path = public stable as $$
declare v_track text;
begin
  if not exists (select 1 from noitp_team where k = p_key) then
    raise exception 'not allowed';
  end if;
  select nt.track into v_track from noitp_team nt where nt.k = p_key;
  return v_track;
end $$;
revoke all on function noitp_scope(text) from public;
grant execute on function noitp_scope(text) to anon, authenticated;

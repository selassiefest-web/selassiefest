-- Follow-up walk (Nov 6-8, 2026): QR scan log + a walk-only load for /full-spectrum/walk.html.
-- Apply with: supabase db query --linked -f supabase/fs-walk.sql   (safe to re-run)

-- One row per QR scan: the partner page calls fs_scan_log when its link carries ?s=walk.
-- Locked down: RLS on, no policies; anon can only call the function.
create table if not exists fs_partner_scans (
  id bigint generated always as identity primary key,
  pitch_key text not null,
  src text not null default 'walk',
  created_at timestamptz not null default now()
);
alter table fs_partner_scans enable row level security;
revoke all on fs_partner_scans from anon, authenticated;
create index if not exists fs_partner_scans_key_idx on fs_partner_scans (pitch_key, created_at desc);

create or replace function fs_scan_log(p_key text, p_src text default 'walk')
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_key !~ '^[a-z0-9]{6,12}$' then return; end if;
  if not exists (select 1 from fs_partners where pitch_key = p_key) then return; end if;
  -- a reload within 2 minutes is the same scan
  if exists (select 1 from fs_partner_scans where pitch_key = p_key and created_at > now() - interval '2 minutes') then return; end if;
  insert into fs_partner_scans (pitch_key, src) values (p_key, case when p_src ~ '^[a-z0-9_-]{1,20}$' then p_src else 'walk' end);
end $$;
revoke all on function fs_scan_log(text, text) from public;
grant execute on function fs_scan_log(text, text) to anon, authenticated;

-- Walk page: only the walk stops and only the fields it needs (not the whole tracker),
-- the latest walk answer per stop, and QR scan counts. Needs a signed-in staff session.
create or replace function fs_walk_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return jsonb_build_object(
    'partners', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', p.id, 'name', p.name, 'category', p.category, 'address', p.address, 'phone', p.phone,
        'stage', p.stage, 'next_step', p.next_step, 'next_step_due', p.next_step_due, 'hours_note', p.hours_note,
        'pitch_key', p.pitch_key,
        'walk_last', (select a.summary from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %' order by a.created_at desc limit 1),
        'scans', (select count(*) from fs_partner_scans s where s.pitch_key = p.pitch_key),
        'scan_last', (select max(s.created_at) from fs_partner_scans s where s.pitch_key = p.pitch_key)
      ) order by p.name)
      from fs_partners p
      where (p.stage = 'not_contacted' and p.next_step_due between date '2026-11-06' and date '2026-11-08')
         or exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %')
    ), '[]'::jsonb)
  );
end $$;
revoke all on function fs_walk_load(uuid) from public;
grant execute on function fs_walk_load(uuid) to anon, authenticated;

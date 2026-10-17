-- ─────────────────────────────────────────────────────────────────────────
-- Live Reggae Rotation (/live-reggae/) -- a weekly live reggae / dancehall
-- gig rotation across Chicago, the suburbs and Northwest Indiana, with
-- Ifficial Reggae Movement as the house band and a rotating featured singer
-- (JayRebl and the other main acts). The band's rate is $1,200 a night, or a
-- deal worked out with the club owner (door split, guarantee + door, bar).
--
-- Three pages:
--   /live-reggae/rotation.html  private booking board (magic link, lr_users)
--   /live-reggae/venue/?k=KEY   one club owner's personal pitch page
--   /live-reggae/               public calendar of confirmed, public nights
--
-- Same lockdown as the Full Spectrum tracker: every table has RLS on and NO
-- policies except the roster-checked login-link insert. The board reads and
-- writes only through the security-definer functions below, each of which
-- re-validates the magic-link session. Venue rows (contacts, phones) and the
-- roster are seeded out of band, never committed -- this file deploys
-- publicly with the rest of the repo. Act names below are already public.
-- ─────────────────────────────────────────────────────────────────────────

-- ── Sign-in ──────────────────────────────────────────────────────────────
create table if not exists lr_users (
  email text primary key,
  display_name text not null,
  created_at timestamptz not null default now()
);
alter table lr_users enable row level security;

create or replace function lr_is_user(p_email text)
returns boolean language sql security definer set search_path = public stable as $$
  select exists (select 1 from lr_users where lower(email) = lower(trim(p_email)));
$$;
grant execute on function lr_is_user(text) to anon, authenticated;

create table if not exists lr_login_links (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  status text not null default 'pending' check (status in ('pending', 'active')),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 minutes')
);
alter table lr_login_links enable row level security;
drop policy if exists "known user can request a rotation login link" on lr_login_links;
create policy "known user can request a rotation login link" on lr_login_links
  for insert to anon, authenticated
  with check (lr_is_user(email));
create index if not exists lr_login_links_email_idx on lr_login_links (lower(email));

-- notify-submission emails the link (formatLrLoginLink). Only pending rows:
-- team-link sessions (below) are inserted already active and need no email.
drop trigger if exists lr_login_links_notify on lr_login_links;
create trigger lr_login_links_notify
  after insert on lr_login_links
  for each row when (new.status = 'pending') execute function notify_submission_webhook();

create or replace function lr_verify_login_link(p_token uuid)
returns table (session_token uuid, email text, display_name text)
language plpgsql security definer set search_path = public as $$
declare v_email text;
begin
  select u.email into v_email
  from lr_login_links l
  join lr_users u on lower(u.email) = lower(l.email)
  where l.id = p_token
    and (l.status = 'active' or (l.status = 'pending' and l.expires_at > now()));
  if v_email is null then return; end if;
  update lr_login_links set status = 'active' where id = p_token and status <> 'active';
  return query select p_token, u.email, u.display_name from lr_users u where lower(u.email) = lower(v_email);
end;
$$;
grant execute on function lr_verify_login_link(uuid) to anon, authenticated;

-- Shared team link: rotation.html?team=<key> opens the board for anyone who
-- has the link, no email sign-in. The key lives in lr_settings (set out of
-- band, never committed); change or delete it to close the link. Each person
-- types a name once so the activity log says who did what; that name becomes
-- an lr_users row with a 'link:' pseudo-email (never emailed).
create table if not exists lr_settings (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);
alter table lr_settings enable row level security;

create or replace function lr_team_session(p_key text, p_name text)
returns table (session_token uuid, email text, display_name text)
language plpgsql security definer set search_path = public as $$
declare v_name text := left(coalesce(nullif(trim(p_name),''), 'Team'), 60); v_email text; v_id uuid;
begin
  if p_key is null or not exists (select 1 from lr_settings where key = 'team_link_key' and value = p_key) then return; end if;
  v_email := 'link:' || lower(regexp_replace(v_name, '\s+', ' ', 'g'));
  insert into lr_users (email, display_name) values (v_email, v_name || ' (team link)') on conflict on constraint lr_users_pkey do nothing;
  insert into lr_login_links (email, status, expires_at) values (v_email, 'active', now()) returning id into v_id;
  return query select v_id, u.email, u.display_name from lr_users u where u.email = v_email;
end;
$$;
grant execute on function lr_team_session(text, text) to anon, authenticated;

-- Opening a session with a key that has since changed should stop working.
create or replace function lr_session_user(p_session uuid, out v_email text, out v_name text)
language plpgsql security definer set search_path = public stable as $$
begin
  select u.email, u.display_name into v_email, v_name
  from lr_login_links l
  join lr_users u on lower(u.email) = lower(l.email)
  where l.id = p_session and l.status = 'active'
    and (u.email not like 'link:%' or exists (select 1 from lr_settings where key = 'team_link_key' and l.created_at >= updated_at));
  if v_email is null then raise exception 'invalid or expired rotation session'; end if;
end;
$$;
revoke all on function lr_session_user(uuid) from public, anon, authenticated;

-- ── Acts ─────────────────────────────────────────────────────────────────
-- kind: band | singer | dj | mc. is_main marks the featured singers the
-- rotation cycles through (about three).
create table if not exists lr_acts (
  id uuid primary key default gen_random_uuid(),
  name text not null unique,
  kind text not null default 'singer' check (kind in ('band','singer','dj','mc')),
  is_main boolean not null default false,
  active boolean not null default true,
  rate_note text,
  instagram text,
  website text,
  phone text,
  email text,
  blackout_dates date[] not null default '{}',     -- nights the act can't play
  notes text,
  sort int not null default 100,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table lr_acts enable row level security;

insert into lr_acts (name, kind, is_main, rate_note, website, instagram, sort) values
  ('Ifficial Reggae Movement', 'band', false, '$1,200 per event, or a deal worked out with the club owner', 'https://www.ifficialreggae.com/', null, 1),
  ('JayRebl', 'singer', true, null, null, 'https://www.instagram.com/jayreblmusic/', 10),
  ('Nego Hights', 'singer', true, null, 'https://www.youtube.com/c/NegoHights', null, 11),
  ('Main act #3 (to be named)', 'singer', true, null, null, null, 12)
on conflict (name) do nothing;

-- ── Venues (the pipeline) ────────────────────────────────────────────────
create or replace function lr_new_pitch_key() returns text language plpgsql as $$
declare a text := 'abcdefghjkmnpqrstuvwxyz23456789'; k text;
begin
  loop
    k := '';
    for i in 1..8 loop k := k || substr(a, 1 + floor(random() * length(a))::int, 1); end loop;
    exit when not exists (select 1 from lr_venues where pitch_key = k);
  end loop;
  return k;
end;
$$;

create table if not exists lr_venues (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  region text not null default 'Chicago – South Side',
  neighborhood text,
  address text,
  phone text,
  email text,
  website text,
  instagram text,
  contacts jsonb not null default '[]'::jsonb,       -- [{name, role, email, phone}]
  tier text check (tier in ('A','B','C')),            -- A hosts reggae now, B live-music room, C Caribbean restaurant
  capacity int,
  has_stage_pa text,
  music_nights text,
  reggae_history text,
  evidence text,
  evidence_url text,
  stage text not null default 'prospect'
    check (stage in ('prospect','contacted','talking','trial_booked','in_rotation','paused','declined')),
  preferred_night text check (preferred_night in ('Mon','Tue','Wed','Thu','Fri','Sat','Sun')),
  cadence text not null default 'weekly' check (cadence in ('weekly','biweekly','monthly','one_off')),
  rotation_offset int not null default 0,             -- biweekly: which week (0/1) of the pair
  default_start time,
  deal_type text not null default 'tbd' check (deal_type in ('tbd','flat','door','guarantee_door','bar','hybrid')),
  deal_terms jsonb not null default '{}'::jsonb,      -- {flat, cover, door_pct, guarantee, bar_pct, notes}
  offer_note text,                                    -- shown on their pitch page if set
  next_step text,
  next_step_due date,
  last_contact_at timestamptz,
  source text,
  notes text,
  pitch_key text unique default lr_new_pitch_key(),
  pitch_views int not null default 0,
  pitch_last_viewed timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table lr_venues enable row level security;
create index if not exists lr_venues_stage_idx on lr_venues (stage, next_step_due);

-- ── Gigs ─────────────────────────────────────────────────────────────────
-- status: hold (penciled by the rotation) -> offered -> confirmed -> played,
-- or cancelled. Only confirmed/played gigs with is_public show on the fan
-- calendar.
create table if not exists lr_gigs (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references lr_venues(id) on delete cascade,
  gig_date date not null,
  start_time time,
  end_time time,
  status text not null default 'hold' check (status in ('hold','offered','confirmed','played','cancelled')),
  headliner_id uuid references lr_acts(id) on delete set null,
  support_ids uuid[] not null default '{}',
  band_id uuid references lr_acts(id) on delete set null,
  deal_type text not null default 'flat' check (deal_type in ('flat','door','guarantee_door','bar','hybrid')),
  deal_terms jsonb not null default '{}'::jsonb,
  fee_agreed numeric(10,2),                           -- what the band is owed for the night
  cover_charge numeric(8,2),
  door_gross numeric(10,2),
  bar_gross numeric(10,2),
  attendance int,
  amount_paid numeric(10,2) not null default 0,
  paid_status text not null default 'unpaid' check (paid_status in ('unpaid','deposit','paid','waived')),
  is_public boolean not null default true,
  public_note text,                                   -- e.g. "21+, $10 cover"
  notes text,
  created_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table lr_gigs enable row level security;
create index if not exists lr_gigs_date_idx on lr_gigs (gig_date);
create index if not exists lr_gigs_venue_idx on lr_gigs (venue_id, gig_date);

-- ── Activity log ─────────────────────────────────────────────────────────
create table if not exists lr_activity (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid references lr_venues(id) on delete cascade,
  gig_id uuid references lr_gigs(id) on delete set null,
  kind text not null check (kind in ('call','email','visit','meeting','text','note','stage','gig')),
  summary text,
  stage_after text,
  by_email text not null,
  by_name text not null,
  created_at timestamptz not null default now()
);
alter table lr_activity enable row level security;
create index if not exists lr_activity_venue_idx on lr_activity (venue_id, created_at desc);

-- ── Board RPCs ───────────────────────────────────────────────────────────
create or replace function lr_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from lr_session_user(p_session);
  return jsonb_build_object(
    'venues',   coalesce((select jsonb_agg(to_jsonb(v) order by v.name) from lr_venues v), '[]'::jsonb),
    'acts',     coalesce((select jsonb_agg(to_jsonb(a) order by a.sort, a.name) from lr_acts a), '[]'::jsonb),
    'gigs',     coalesce((select jsonb_agg(to_jsonb(g) order by g.gig_date, g.start_time) from lr_gigs g
                          where g.gig_date >= current_date - 120), '[]'::jsonb),
    'activity', coalesce((select jsonb_agg(to_jsonb(x) order by x.created_at desc)
                          from (select * from lr_activity order by created_at desc limit 600) x), '[]'::jsonb)
  );
end;
$$;
grant execute on function lr_load(uuid) to anon, authenticated;

create or replace function lr_venue_save(p_session uuid, p_id uuid, p jsonb)
returns lr_venues language plpgsql security definer set search_path = public as $$
declare u record; r lr_venues; v_old text;
begin
  select * into u from lr_session_user(p_session);
  if p_id is null then
    insert into lr_venues (name, source) values (coalesce(nullif(trim(p->>'name'),''),'Untitled venue'), coalesce(nullif(p->>'source',''),'Added by '||u.v_name))
    returning * into r;
    p_id := r.id;
  end if;
  select stage into v_old from lr_venues where id = p_id;
  update lr_venues set
    name            = case when p ? 'name' then coalesce(nullif(trim(p->>'name'),''), name) else name end,
    region          = case when p ? 'region' then coalesce(nullif(p->>'region',''), region) else region end,
    neighborhood    = case when p ? 'neighborhood' then nullif(trim(p->>'neighborhood'),'') else neighborhood end,
    address         = case when p ? 'address' then nullif(trim(p->>'address'),'') else address end,
    phone           = case when p ? 'phone' then nullif(trim(p->>'phone'),'') else phone end,
    email           = case when p ? 'email' then nullif(trim(p->>'email'),'') else email end,
    website         = case when p ? 'website' then nullif(trim(p->>'website'),'') else website end,
    instagram       = case when p ? 'instagram' then nullif(trim(p->>'instagram'),'') else instagram end,
    contacts        = case when p ? 'contacts' then coalesce(p->'contacts','[]'::jsonb) else contacts end,
    tier            = case when p ? 'tier' then nullif(p->>'tier','') else tier end,
    capacity        = case when p ? 'capacity' then nullif(p->>'capacity','')::int else capacity end,
    music_nights    = case when p ? 'music_nights' then nullif(trim(p->>'music_nights'),'') else music_nights end,
    stage           = case when p ? 'stage' then p->>'stage' else stage end,
    preferred_night = case when p ? 'preferred_night' then nullif(p->>'preferred_night','') else preferred_night end,
    cadence         = case when p ? 'cadence' then coalesce(nullif(p->>'cadence',''), cadence) else cadence end,
    rotation_offset = case when p ? 'rotation_offset' then coalesce(nullif(p->>'rotation_offset','')::int, 0) else rotation_offset end,
    default_start   = case when p ? 'default_start' then nullif(p->>'default_start','')::time else default_start end,
    deal_type       = case when p ? 'deal_type' then coalesce(nullif(p->>'deal_type',''), deal_type) else deal_type end,
    deal_terms      = case when p ? 'deal_terms' then coalesce(p->'deal_terms','{}'::jsonb) else deal_terms end,
    offer_note      = case when p ? 'offer_note' then nullif(trim(p->>'offer_note'),'') else offer_note end,
    next_step       = case when p ? 'next_step' then nullif(trim(p->>'next_step'),'') else next_step end,
    next_step_due   = case when p ? 'next_step_due' then nullif(p->>'next_step_due','')::date else next_step_due end,
    notes           = case when p ? 'notes' then nullif(trim(p->>'notes'),'') else notes end,
    updated_at      = now()
  where id = p_id
  returning * into r;
  if p ? 'stage' and v_old is distinct from r.stage then
    insert into lr_activity (venue_id, kind, summary, stage_after, by_email, by_name)
    values (r.id, 'stage', 'Stage changed to ' || r.stage, r.stage, u.v_email, u.v_name);
  end if;
  return r;
end;
$$;
grant execute on function lr_venue_save(uuid, uuid, jsonb) to anon, authenticated;

create or replace function lr_venue_log(p_session uuid, p_venue uuid, p_kind text, p_summary text,
                                        p_stage text default null, p_next_step text default null, p_next_due date default null)
returns lr_activity language plpgsql security definer set search_path = public as $$
declare u record; a lr_activity;
begin
  select * into u from lr_session_user(p_session);
  update lr_venues set
    stage = coalesce(nullif(p_stage,''), stage),
    next_step = case when p_next_step is not null then nullif(trim(p_next_step),'') else next_step end,
    next_step_due = case when p_next_step is not null then p_next_due else next_step_due end,
    last_contact_at = case when p_kind in ('call','email','visit','meeting','text') then now() else last_contact_at end,
    updated_at = now()
  where id = p_venue;
  insert into lr_activity (venue_id, kind, summary, stage_after, by_email, by_name)
  values (p_venue, p_kind, nullif(trim(p_summary),''), nullif(p_stage,''), u.v_email, u.v_name)
  returning * into a;
  return a;
end;
$$;
grant execute on function lr_venue_log(uuid, uuid, text, text, text, text, date) to anon, authenticated;

create or replace function lr_venue_delete(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from lr_session_user(p_session);
  delete from lr_venues where id = p_id;
end;
$$;
grant execute on function lr_venue_delete(uuid, uuid) to anon, authenticated;

-- Create (p_id null) or update one gig. The page warns about double-booking
-- the band before calling this; the database doesn't block it, because an
-- early show and a late show on the same night is a real possibility.
create or replace function lr_gig_save(p_session uuid, p_id uuid, p jsonb)
returns lr_gigs language plpgsql security definer set search_path = public as $$
declare u record; r lr_gigs; v_old text; v_venue text;
begin
  select * into u from lr_session_user(p_session);
  if p_id is null then
    insert into lr_gigs (venue_id, gig_date, created_by)
    values ((p->>'venue_id')::uuid, (p->>'gig_date')::date, u.v_name)
    returning * into r;
    p_id := r.id;
    v_old := null;
  else
    select status into v_old from lr_gigs where id = p_id;
  end if;
  update lr_gigs set
    venue_id     = case when p ? 'venue_id' then (p->>'venue_id')::uuid else venue_id end,
    gig_date     = case when p ? 'gig_date' then (p->>'gig_date')::date else gig_date end,
    start_time   = case when p ? 'start_time' then nullif(p->>'start_time','')::time else start_time end,
    end_time     = case when p ? 'end_time' then nullif(p->>'end_time','')::time else end_time end,
    status       = case when p ? 'status' then coalesce(nullif(p->>'status',''), status) else status end,
    headliner_id = case when p ? 'headliner_id' then nullif(p->>'headliner_id','')::uuid else headliner_id end,
    support_ids  = case when p ? 'support_ids' then array(select jsonb_array_elements_text(p->'support_ids')::uuid) else support_ids end,
    band_id      = case when p ? 'band_id' then nullif(p->>'band_id','')::uuid else band_id end,
    deal_type    = case when p ? 'deal_type' then coalesce(nullif(p->>'deal_type',''), deal_type) else deal_type end,
    deal_terms   = case when p ? 'deal_terms' then coalesce(p->'deal_terms','{}'::jsonb) else deal_terms end,
    fee_agreed   = case when p ? 'fee_agreed' then nullif(p->>'fee_agreed','')::numeric else fee_agreed end,
    cover_charge = case when p ? 'cover_charge' then nullif(p->>'cover_charge','')::numeric else cover_charge end,
    door_gross   = case when p ? 'door_gross' then nullif(p->>'door_gross','')::numeric else door_gross end,
    bar_gross    = case when p ? 'bar_gross' then nullif(p->>'bar_gross','')::numeric else bar_gross end,
    attendance   = case when p ? 'attendance' then nullif(p->>'attendance','')::int else attendance end,
    amount_paid  = case when p ? 'amount_paid' then coalesce(nullif(p->>'amount_paid','')::numeric, 0) else amount_paid end,
    paid_status  = case when p ? 'paid_status' then coalesce(nullif(p->>'paid_status',''), paid_status) else paid_status end,
    is_public    = case when p ? 'is_public' then coalesce((p->>'is_public')::boolean, true) else is_public end,
    public_note  = case when p ? 'public_note' then nullif(trim(p->>'public_note'),'') else public_note end,
    notes        = case when p ? 'notes' then nullif(trim(p->>'notes'),'') else notes end,
    updated_at   = now()
  where id = p_id
  returning * into r;
  if v_old is distinct from r.status then
    select name into v_venue from lr_venues where id = r.venue_id;
    insert into lr_activity (venue_id, gig_id, kind, summary, by_email, by_name)
    values (r.venue_id, r.id, 'gig', to_char(r.gig_date, 'Dy Mon DD') || ' gig ' || case when v_old is null then 'added as ' else 'moved to ' end || r.status, u.v_email, u.v_name);
  end if;
  return r;
end;
$$;
grant execute on function lr_gig_save(uuid, uuid, jsonb) to anon, authenticated;

-- Save a whole generated rotation in one call: p is a jsonb array of gig
-- objects (same keys as lr_gig_save). Returns how many were created.
create or replace function lr_gigs_bulk_create(p_session uuid, p jsonb)
returns int language plpgsql security definer set search_path = public as $$
declare u record; g jsonb; n int := 0;
begin
  select * into u from lr_session_user(p_session);
  for g in select * from jsonb_array_elements(p) loop
    perform lr_gig_save(p_session, null, g);
    n := n + 1;
  end loop;
  return n;
end;
$$;
grant execute on function lr_gigs_bulk_create(uuid, jsonb) to anon, authenticated;

create or replace function lr_gig_delete(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from lr_session_user(p_session);
  delete from lr_gigs where id = p_id;
end;
$$;
grant execute on function lr_gig_delete(uuid, uuid) to anon, authenticated;

create or replace function lr_act_save(p_session uuid, p_id uuid, p jsonb)
returns lr_acts language plpgsql security definer set search_path = public as $$
declare u record; r lr_acts;
begin
  select * into u from lr_session_user(p_session);
  if p_id is null then
    insert into lr_acts (name) values (coalesce(nullif(trim(p->>'name'),''),'New act ' || to_char(now(),'HH24MISS'))) returning * into r;
    p_id := r.id;
  end if;
  update lr_acts set
    name       = case when p ? 'name' then coalesce(nullif(trim(p->>'name'),''), name) else name end,
    kind       = case when p ? 'kind' then coalesce(nullif(p->>'kind',''), kind) else kind end,
    is_main    = case when p ? 'is_main' then coalesce((p->>'is_main')::boolean, false) else is_main end,
    active     = case when p ? 'active' then coalesce((p->>'active')::boolean, true) else active end,
    rate_note  = case when p ? 'rate_note' then nullif(trim(p->>'rate_note'),'') else rate_note end,
    instagram  = case when p ? 'instagram' then nullif(trim(p->>'instagram'),'') else instagram end,
    website    = case when p ? 'website' then nullif(trim(p->>'website'),'') else website end,
    phone      = case when p ? 'phone' then nullif(trim(p->>'phone'),'') else phone end,
    email      = case when p ? 'email' then nullif(trim(p->>'email'),'') else email end,
    blackout_dates = case when p ? 'blackout_dates' then array(select jsonb_array_elements_text(p->'blackout_dates')::date) else blackout_dates end,
    notes      = case when p ? 'notes' then nullif(trim(p->>'notes'),'') else notes end,
    sort       = case when p ? 'sort' then coalesce(nullif(p->>'sort','')::int, sort) else sort end,
    updated_at = now()
  where id = p_id
  returning * into r;
  return r;
end;
$$;
grant execute on function lr_act_save(uuid, uuid, jsonb) to anon, authenticated;

create or replace function lr_act_delete(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from lr_session_user(p_session);
  delete from lr_acts where id = p_id;
end;
$$;
grant execute on function lr_act_delete(uuid, uuid) to anon, authenticated;

-- ── Public: fan calendar ─────────────────────────────────────────────────
-- Confirmed or played public gigs from 2 days ago through 4 months out.
-- Only show-facing fields: venue name/area/address, date, time, lineup.
create or replace function lr_public_calendar()
returns table (gig_id uuid, gig_date date, start_time time, end_time time, status text, public_note text,
               venue text, neighborhood text, region text, address text, website text,
               headliner text, support text[], band text)
language sql security definer set search_path = public stable as $$
  select g.id, g.gig_date, g.start_time, g.end_time, g.status, g.public_note,
         v.name, v.neighborhood, v.region, v.address, v.website,
         h.name,
         array(select a.name from lr_acts a where a.id = any(g.support_ids) order by a.sort, a.name),
         b.name
  from lr_gigs g
  join lr_venues v on v.id = g.venue_id
  left join lr_acts h on h.id = g.headliner_id
  left join lr_acts b on b.id = g.band_id
  where g.is_public and g.status in ('confirmed','played')
    and g.gig_date between current_date - 2 and current_date + 120
  order by g.gig_date, g.start_time;
$$;
grant execute on function lr_public_calendar() to anon, authenticated;

-- ── Public: a venue's pitch page ─────────────────────────────────────────
-- Returns only the venue's name, area and the offer note; counts the view.
create or replace function lr_pitch_view(p_key text)
returns table (name text, neighborhood text, region text, preferred_night text, offer_note text)
language plpgsql security definer set search_path = public as $$
begin
  update lr_venues v set pitch_views = v.pitch_views + 1, pitch_last_viewed = now() where v.pitch_key = p_key;
  return query select v.name, v.neighborhood, v.region, v.preferred_night, v.offer_note from lr_venues v where v.pitch_key = p_key;
end;
$$;
grant execute on function lr_pitch_view(text) to anon, authenticated;

-- Answers from the pitch page (with a key) or the open "book a night" form
-- (no key, venue_name typed in). Write-only: inserted by public-submit.
create table if not exists lr_venue_responses (
  id uuid primary key default gen_random_uuid(),
  pitch_key text,
  venue_name text,                       -- typed on the open form; stamped from lr_venues when keyed
  decision text not null check (decision in ('book_trial','call_me','not_now')),
  preferred_night text,
  cadence text,
  deal_pref text check (deal_pref is null or deal_pref in ('flat','deal','talk')),
  contact_name text,
  contact_title text,
  phone text,
  email text,
  city text,
  message text,
  created_at timestamptz not null default now()
);
alter table lr_venue_responses enable row level security;

create or replace function lr_venue_response_stamp() returns trigger
language plpgsql security definer set search_path = public as $$
declare v_name text;
begin
  if new.pitch_key is not null then
    select name into v_name from lr_venues where pitch_key = new.pitch_key;
    if v_name is not null then new.venue_name := v_name; end if;
  end if;
  return new;
end;
$$;
drop trigger if exists lr_venue_responses_stamp on lr_venue_responses;
create trigger lr_venue_responses_stamp before insert on lr_venue_responses
  for each row execute function lr_venue_response_stamp();

-- Keyed answers move the venue along and log it; open-form answers create a
-- new prospect so nothing falls through the cracks.
create or replace function lr_venue_response_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare v lr_venues; v_stage text; v_label text; v_contact jsonb;
begin
  v_label := case new.decision when 'book_trial' then 'Book a trial night' when 'call_me' then 'Call me' else 'Not right now' end;
  v_contact := case when coalesce(nullif(new.contact_name,''), nullif(new.phone,''), nullif(new.email,'')) is null then '[]'::jsonb
                    else jsonb_build_array(jsonb_strip_nulls(jsonb_build_object('name', nullif(new.contact_name,''), 'role', nullif(new.contact_title,''),
                                                                                 'email', nullif(new.email,''), 'phone', nullif(new.phone,'')))) end;
  if new.pitch_key is not null then select * into v from lr_venues where pitch_key = new.pitch_key; end if;
  if v.id is null then
    insert into lr_venues (name, neighborhood, contacts, stage, preferred_night, source, next_step, next_step_due)
    values (coalesce(nullif(trim(new.venue_name),''), 'Venue from the booking form'), nullif(trim(new.city),''), v_contact,
            case when new.decision = 'not_now' then 'paused' else 'talking' end,
            case when new.preferred_night in ('Mon','Tue','Wed','Thu','Fri','Sat','Sun') then new.preferred_night end,
            'Booking form (/live-reggae/venue/)',
            case when new.decision <> 'not_now' then 'Call ' || coalesce(nullif(new.contact_name,''), 'them') || ' back (booking form)' end,
            case when new.decision <> 'not_now' then current_date + 1 end)
    returning * into v;
  else
    v_stage := case
      when new.decision = 'book_trial' and v.stage in ('prospect','contacted','talking','paused') then 'trial_booked'
      when new.decision = 'call_me' and v.stage in ('prospect','contacted','paused') then 'talking'
      when new.decision = 'not_now' and v.stage in ('prospect','contacted') then 'paused'
      else null end;
    update lr_venues set
      stage = coalesce(v_stage, stage),
      -- Fill the night only if none is set; a requested change is in the log/email.
      preferred_night = coalesce(preferred_night, case when new.preferred_night in ('Mon','Tue','Wed','Thu','Fri','Sat','Sun') then new.preferred_night end),
      last_contact_at = now(),
      next_step = case when new.decision <> 'not_now' then 'Call ' || coalesce(nullif(new.contact_name,''), 'them') || ' back (answered the pitch page)' else next_step end,
      next_step_due = case when new.decision <> 'not_now' then current_date + 1 else next_step_due end,
      contacts = contacts || v_contact,
      updated_at = now()
    where id = v.id;
  end if;
  insert into lr_activity (venue_id, kind, summary, stage_after, by_email, by_name)
  values (v.id, 'note', 'Pitch page answer: ' || v_label ||
            coalesce(' from ' || nullif(new.contact_name,''), '') || coalesce(' (' || nullif(new.contact_title,'') || ')', '') ||
            coalesce('. Night: ' || nullif(new.preferred_night,''), '') || coalesce(', ' || nullif(new.cadence,''), '') ||
            coalesce('. Deal: ' || case new.deal_pref when 'flat' then '$1,200 flat' when 'deal' then 'wants to work a deal' when 'talk' then 'wants to talk it through' end, '') ||
            coalesce('. Phone ' || nullif(new.phone,''), '') || coalesce('. Email ' || nullif(new.email,''), '') ||
            coalesce('. "' || nullif(new.message,'') || '"', ''),
          v_stage, 'pitch-page', 'Pitch page');
  return new;
end;
$$;
drop trigger if exists lr_venue_responses_apply on lr_venue_responses;
create trigger lr_venue_responses_apply after insert on lr_venue_responses
  for each row execute function lr_venue_response_apply();

drop trigger if exists lr_venue_responses_notify on lr_venue_responses;
create trigger lr_venue_responses_notify after insert on lr_venue_responses
  for each row execute function notify_submission_webhook();

-- ── Monday lineup email source (service_role only) ───────────────────────
create or replace function lr_weekly_digest()
returns jsonb language sql security definer set search_path = public stable as $$
  select jsonb_build_object(
    'week', coalesce((select jsonb_agg(jsonb_build_object(
                'date', g.gig_date, 'start', g.start_time, 'status', g.status, 'venue', v.name,
                'area', coalesce(v.neighborhood, v.region), 'address', v.address,
                'headliner', h.name,
                'support', (select string_agg(a.name, ', ') from lr_acts a where a.id = any(g.support_ids)),
                'deal', g.deal_type, 'fee', g.fee_agreed) order by g.gig_date, g.start_time)
              from lr_gigs g join lr_venues v on v.id = g.venue_id left join lr_acts h on h.id = g.headliner_id
              where g.gig_date between current_date and current_date + 6 and g.status <> 'cancelled'), '[]'::jsonb),
    'holds_next', (select count(*) from lr_gigs where status in ('hold','offered') and gig_date between current_date and current_date + 21),
    'unpaid', coalesce((select jsonb_agg(jsonb_build_object('date', g.gig_date, 'venue', v.name, 'owed', coalesce(g.fee_agreed,0) - g.amount_paid) order by g.gig_date)
              from lr_gigs g join lr_venues v on v.id = g.venue_id
              where g.status = 'played' and g.paid_status in ('unpaid','deposit') and coalesce(g.fee_agreed,0) > g.amount_paid), '[]'::jsonb),
    'due', coalesce((select jsonb_agg(jsonb_build_object('name', name, 'stage', stage, 'next_step', next_step, 'due', next_step_due) order by next_step_due)
              from lr_venues where next_step_due is not null and next_step_due <= current_date + 7
                and stage not in ('declined')), '[]'::jsonb),
    'counts', coalesce((select jsonb_object_agg(stage, n) from (select stage, count(*) n from lr_venues group by stage) s), '{}'::jsonb),
    'to', coalesce((select jsonb_agg(email) from lr_users where email like '%@%' and email not like 'link:%'), '[]'::jsonb)
  );
$$;
revoke all on function lr_weekly_digest() from public, anon, authenticated;
grant execute on function lr_weekly_digest() to service_role;

-- The Monday pg_cron job that calls send-lr-weekly is applied directly to
-- the live project (it embeds the function URL and LR_WEEKLY_SECRET):
-- cron.schedule('lr-weekly', '0 13 * * 1', $$ select net.http_post(url :=
-- '<function URL>', headers := jsonb_build_object('Content-Type',
-- 'application/json','x-webhook-secret','<LR_WEEKLY_SECRET>'), body :=
-- '{}'::jsonb) $$);

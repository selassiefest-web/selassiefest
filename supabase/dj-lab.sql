-- ─────────────────────────────────────────────────────────────────────────
-- Rainbow DJ Lab (/dj-lab/) -- the live classroom app for Full Spectrum's
-- DJ classes. One shared session clock, station board, kid check-ins,
-- Passport stamps and coach messages, shared by Kid, Coach and Parent
-- screens.
--
-- Access model:
--   * Families and kids join a class with its join code (?c=CODE). With the
--     code they can read the class state (kids appear as first name + last
--     initial only) and write their OWN check-in fields (prediction, level,
--     light, next-time line, Data! count, Mix Log) -- the same trust the
--     original classroom app gave every screen in the room.
--   * Coaches sign in by magic link (djlab_coaches roster). Only a coach
--     session can run the clock, edit the roster, stamp Passports, write
--     glows, approve registrations and send recap emails.
--   * Guardian contact details live only on djlab_kids / djlab_registrations
--     and are never returned to the page; the djlab-send-recaps Edge
--     Function reads them with the service role.
-- Every table has RLS on and zero policies except the login-link insert;
-- all access goes through the security-definer functions below. Clients poll
-- djlab_state(code, version) every couple of seconds; each write bumps the
-- class version so unchanged polls return almost nothing.
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists djlab_coaches (
  email text primary key,
  display_name text not null,
  created_at timestamptz not null default now()
);
alter table djlab_coaches enable row level security;

create or replace function djlab_is_coach(p_email text) returns boolean
language sql security definer set search_path = public stable as $$
  select exists (select 1 from djlab_coaches where lower(email) = lower(trim(p_email)));
$$;
grant execute on function djlab_is_coach(text) to anon, authenticated;

create table if not exists djlab_coach_login_links (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  status text not null default 'pending' check (status in ('pending','active')),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 minutes')
);
alter table djlab_coach_login_links enable row level security;
drop policy if exists "known coach can request a DJ Lab login link" on djlab_coach_login_links;
create policy "known coach can request a DJ Lab login link" on djlab_coach_login_links
  for insert to anon, authenticated with check (djlab_is_coach(email));
drop trigger if exists djlab_coach_login_links_notify on djlab_coach_login_links;
create trigger djlab_coach_login_links_notify after insert on djlab_coach_login_links
  for each row execute function notify_submission_webhook();

create or replace function djlab_verify_login_link(p_token uuid)
returns table (session_token uuid, email text, display_name text)
language plpgsql security definer set search_path = public as $$
declare v_email text;
begin
  select c.email into v_email from djlab_coach_login_links l join djlab_coaches c on lower(c.email) = lower(l.email)
  where l.id = p_token and (l.status = 'active' or (l.status = 'pending' and l.expires_at > now()));
  if v_email is null then return; end if;
  update djlab_coach_login_links set status = 'active' where id = p_token and status <> 'active';
  return query select p_token, c.email, c.display_name from djlab_coaches c where lower(c.email) = lower(v_email);
end;
$$;
grant execute on function djlab_verify_login_link(uuid) to anon, authenticated;

create or replace function djlab_coach(p_session uuid, out v_email text, out v_name text)
language plpgsql security definer set search_path = public stable as $$
begin
  select c.email, c.display_name into v_email, v_name
  from djlab_coach_login_links l join djlab_coaches c on lower(c.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';
  if v_email is null then raise exception 'invalid or expired coach session'; end if;
end;
$$;
revoke all on function djlab_coach(uuid) from public, anon, authenticated;
grant execute on function djlab_coach(uuid) to service_role;

-- A class (cohort). live holds the shared clock exactly as the app uses it:
-- {mode, session, ws, running, base, markAt, msg, msgAt, feed, spot}.
create table if not exists djlab_cohorts (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text not null unique,
  live jsonb not null default '{}'::jsonb,
  version bigint not null default 1,
  archived boolean not null default false,
  created_at timestamptz not null default now()
);
alter table djlab_cohorts enable row level security;

create table if not exists djlab_kids (
  id uuid primary key default gen_random_uuid(),
  cohort_id uuid not null references djlab_cohorts(id) on delete cascade,
  name text not null,                       -- first name + last initial
  station int not null default 1,
  seat int not null default 0,
  stamps jsonb not null default '{}'::jsonb, -- {s1:[true,false,true], w2:[...]}
  here jsonb not null default '{}'::jsonb,   -- {s1: epoch ms checked in}
  glow jsonb not null default '{}'::jsonb,   -- {s1: "coach glow note"}
  guardian_name text,                        -- private
  guardian_email text,                       -- private
  guardian_phone text,                       -- private
  recap_opt_in boolean not null default false,
  registration_id uuid,
  created_at timestamptz not null default now()
);
alter table djlab_kids enable row level security;
create index if not exists djlab_kids_cohort_idx on djlab_kids (cohort_id);

create table if not exists djlab_checkins (
  kid_id uuid not null references djlab_kids(id) on delete cascade,
  unit text not null,                       -- s1..s14 (course) or w1..w6 (fast track)
  data jsonb not null default '{}'::jsonb,  -- {predict, level, light, next, data, mixlog:[...]}
  updated_at timestamptz not null default now(),
  primary key (kid_id, unit)
);
alter table djlab_checkins enable row level security;

create table if not exists djlab_recaps_sent (
  kid_id uuid not null references djlab_kids(id) on delete cascade,
  unit text not null,
  sent_at timestamptz not null default now(),
  primary key (kid_id, unit)
);
alter table djlab_recaps_sent enable row level security;

-- Public registration (posted through public-submit with Turnstile).
create table if not exists djlab_registrations (
  id uuid primary key default gen_random_uuid(),
  cohort_code text,
  kid_first_name text not null,
  kid_last_initial text,
  kid_age int,
  guardian_name text not null,
  guardian_email text not null,
  guardian_phone text,
  emergency_contact text,
  accommodations text,
  consent boolean not null default false,
  photo_consent boolean not null default false,
  recap_opt_in boolean not null default true,
  status text not null default 'pending' check (status in ('pending','approved','declined')),
  created_at timestamptz not null default now()
);
alter table djlab_registrations enable row level security;
drop trigger if exists djlab_registrations_notify on djlab_registrations;
create trigger djlab_registrations_notify after insert on djlab_registrations
  for each row execute function notify_submission_webhook();

create or replace function djlab_bump(p_cohort uuid) returns void
language sql security definer set search_path = public as $$
  update djlab_cohorts set version = version + 1 where id = p_cohort;
$$;
revoke all on function djlab_bump(uuid) from public, anon, authenticated;

-- ---- reads ----
create or replace function djlab_state(p_code text, p_since bigint default 0)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare c djlab_cohorts; v_now bigint := (extract(epoch from clock_timestamp()) * 1000)::bigint;  -- server clock for client time sync
begin
  select * into c from djlab_cohorts where code = upper(trim(p_code)) and not archived;
  if c.id is null then return jsonb_build_object('error','unknown_code'); end if;
  if c.version <= coalesce(p_since,0) then return jsonb_build_object('version', c.version, 'unchanged', true, 'now', v_now); end if;
  return jsonb_build_object(
    'version', c.version,
    'now', v_now,
    'cohort', jsonb_build_object('id', c.id, 'name', c.name),
    'live', c.live,
    'kids', coalesce((select jsonb_agg(jsonb_build_object('id',k.id,'name',k.name,'station',k.station,'seat',k.seat,
                     'stamps',k.stamps,'here',k.here,'glow',k.glow,'recap',k.recap_opt_in and k.guardian_email is not null) order by k.station,k.seat,k.name)
                     from djlab_kids k where k.cohort_id = c.id), '[]'::jsonb),
    'checkins', coalesce((select jsonb_object_agg(ch.kid_id::text || '_' || ch.unit, ch.data || jsonb_build_object('kid', ch.kid_id, 'unit', ch.unit))
                     from djlab_checkins ch join djlab_kids k on k.id = ch.kid_id where k.cohort_id = c.id), '{}'::jsonb));
end;
$$;
grant execute on function djlab_state(text, bigint) to anon, authenticated;

-- ---- kid / family writes (class code) ----
-- p_op: 'merge' (whitelisted fields), 'inc_data', 'append_mixlog'
create or replace function djlab_checkin(p_code text, p_kid uuid, p_unit text, p_op text, p jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_cohort uuid; cur jsonb; nxt jsonb;
begin
  select k.cohort_id into v_cohort from djlab_kids k join djlab_cohorts c on c.id = k.cohort_id
  where k.id = p_kid and c.code = upper(trim(p_code)) and not c.archived;
  if v_cohort is null then raise exception 'unknown kid or class code'; end if;
  if p_unit !~ '^(s([1-9]|1[0-4])|w[1-6])$' then raise exception 'bad unit'; end if;
  select data into cur from djlab_checkins where kid_id = p_kid and unit = p_unit;
  cur := coalesce(cur, '{}'::jsonb);
  if p_op = 'inc_data' then
    nxt := cur || jsonb_build_object('data', least(coalesce((cur->>'data')::int,0) + 1, 999));
  elsif p_op = 'append_mixlog' then
    declare arr jsonb := coalesce(cur->'mixlog','[]'::jsonb) || jsonb_build_array(jsonb_build_object(
          'pair', left(coalesce(p->>'pair',''),80), 'what', left(coalesce(p->>'what',''),120), 'fix', left(coalesce(p->>'fix',''),120),
          'at', (extract(epoch from now())*1000)::bigint));
    begin
      nxt := cur || jsonb_build_object('mixlog', (select jsonb_agg(e order by n) from jsonb_array_elements(arr) with ordinality t(e, n)
                                                  where n > jsonb_array_length(arr) - 10));
    end;
  else
    nxt := cur;
    if p ? 'predict' and p->>'predict' in ('easy','medium','hard') then nxt := nxt || jsonb_build_object('predict', p->>'predict'); end if;
    if p ? 'level' and p->>'level' in ('mild','medium','spicy') then nxt := nxt || jsonb_build_object('level', p->>'level'); end if;
    if p ? 'light' and p->>'light' in ('green','yellow','red') then nxt := nxt || jsonb_build_object('light', p->>'light'); end if;
    if p ? 'next' then nxt := nxt || jsonb_build_object('next', left(p->>'next',140)); end if;
  end if;
  insert into djlab_checkins (kid_id, unit, data, updated_at) values (p_kid, p_unit, nxt, now())
  on conflict (kid_id, unit) do update set data = excluded.data, updated_at = now();
  perform djlab_bump(v_cohort);
  return nxt;
end;
$$;
grant execute on function djlab_checkin(text, uuid, text, text, jsonb) to anon, authenticated;

-- ---- coach writes (session) ----
create or replace function djlab_coach_cohorts(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from djlab_coach(p_session);
  return jsonb_build_object('coach', u.v_name, 'cohorts', coalesce((select jsonb_agg(jsonb_build_object('id',id,'name',name,'code',code) order by created_at desc)
    from djlab_cohorts where not archived), '[]'::jsonb));
end;
$$;
grant execute on function djlab_coach_cohorts(uuid) to anon, authenticated;

create or replace function djlab_coach_new_cohort(p_session uuid, p_name text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; a text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; k text; r djlab_cohorts;
begin
  select * into u from djlab_coach(p_session);
  loop
    k := ''; for i in 1..6 loop k := k || substr(a, 1 + floor(random()*length(a))::int, 1); end loop;
    exit when not exists (select 1 from djlab_cohorts where code = k);
  end loop;
  insert into djlab_cohorts (name, code, live) values (left(coalesce(nullif(trim(p_name),''),'DJ Lab class'),80), k,
    jsonb_build_object('mode','course','session',1,'ws',1,'running',false,'base',0,'markAt',(extract(epoch from now())*1000)::bigint,'msg','','msgAt',0,'feed','[]'::jsonb,'spot',null))
  returning * into r;
  return jsonb_build_object('id', r.id, 'name', r.name, 'code', r.code);
end;
$$;
grant execute on function djlab_coach_new_cohort(uuid, text) to anon, authenticated;

create or replace function djlab_coach_set_live(p_session uuid, p_cohort uuid, p_live jsonb)
returns bigint language plpgsql security definer set search_path = public as $$
declare u record; v bigint;
begin
  select * into u from djlab_coach(p_session);
  update djlab_cohorts set live = p_live, version = version + 1 where id = p_cohort returning version into v;
  return v;
end;
$$;
grant execute on function djlab_coach_set_live(uuid, uuid, jsonb) to anon, authenticated;

-- Create (p_kid null) or patch a kid: name, station, seat, stamps, here, glow.
create or replace function djlab_coach_kid(p_session uuid, p_cohort uuid, p_kid uuid, p jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; r djlab_kids;
begin
  select * into u from djlab_coach(p_session);
  if p_kid is null then
    insert into djlab_kids (cohort_id, name, station, seat) values (p_cohort, left(coalesce(nullif(trim(p->>'name'),''),'New kid'),24),
      coalesce((p->>'station')::int,1), coalesce((p->>'seat')::int,0)) returning * into r;
  else
    update djlab_kids set
      name = case when p ? 'name' then left(coalesce(nullif(trim(p->>'name'),''),name),24) else name end,
      station = case when p ? 'station' then (p->>'station')::int else station end,
      seat = case when p ? 'seat' then (p->>'seat')::int else seat end,
      stamps = case when p ? 'stamps' then p->'stamps' else stamps end,
      here = case when p ? 'here' then p->'here' else here end,
      glow = case when p ? 'glow' then p->'glow' else glow end
    where id = p_kid and cohort_id = p_cohort returning * into r;
  end if;
  perform djlab_bump(p_cohort);
  return jsonb_build_object('id', r.id);
end;
$$;
grant execute on function djlab_coach_kid(uuid, uuid, uuid, jsonb) to anon, authenticated;

create or replace function djlab_coach_kid_delete(p_session uuid, p_cohort uuid, p_kid uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from djlab_coach(p_session);
  delete from djlab_kids where id = p_kid and cohort_id = p_cohort;
  perform djlab_bump(p_cohort);
end;
$$;
grant execute on function djlab_coach_kid_delete(uuid, uuid, uuid) to anon, authenticated;

-- Pending registrations for a class (by its code), for the coach to approve.
create or replace function djlab_coach_registrations(p_session uuid, p_cohort uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; v_code text;
begin
  select * into u from djlab_coach(p_session);
  select code into v_code from djlab_cohorts where id = p_cohort;
  return coalesce((select jsonb_agg(jsonb_build_object('id',r.id,'kid',r.kid_first_name || coalesce(' ' || nullif(upper(left(r.kid_last_initial,1)),'') || '.',''),
            'age',r.kid_age,'guardian',r.guardian_name,'accommodations',r.accommodations,'photo',r.photo_consent,'recap',r.recap_opt_in,'at',r.created_at) order by r.created_at)
          from djlab_registrations r where r.status = 'pending' and (r.cohort_code is null or upper(r.cohort_code) = v_code)), '[]'::jsonb);
end;
$$;
grant execute on function djlab_coach_registrations(uuid, uuid) to anon, authenticated;

create or replace function djlab_coach_approve(p_session uuid, p_cohort uuid, p_reg uuid, p_station int, p_seat int, p_approve boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; r djlab_registrations; k djlab_kids;
begin
  select * into u from djlab_coach(p_session);
  select * into r from djlab_registrations where id = p_reg and status = 'pending';
  if r.id is null then raise exception 'registration not found'; end if;
  if not p_approve then
    update djlab_registrations set status = 'declined' where id = p_reg;
    return jsonb_build_object('declined', true);
  end if;
  insert into djlab_kids (cohort_id, name, station, seat, guardian_name, guardian_email, guardian_phone, recap_opt_in, registration_id)
  values (p_cohort, left(r.kid_first_name || coalesce(' ' || nullif(upper(left(r.kid_last_initial,1)),'') || '.',''),24), coalesce(p_station,1), coalesce(p_seat,0),
          r.guardian_name, lower(trim(r.guardian_email)), r.guardian_phone, r.recap_opt_in, r.id)
  returning * into k;
  update djlab_registrations set status = 'approved' where id = p_reg;
  perform djlab_bump(p_cohort);
  return jsonb_build_object('id', k.id, 'name', k.name);
end;
$$;
grant execute on function djlab_coach_approve(uuid, uuid, uuid, int, int, boolean) to anon, authenticated;

-- Recap source for the Edge Function (service role only).
create or replace function djlab_recap_rows(p_cohort uuid, p_unit text)
returns table (kid_id uuid, kid_name text, guardian_name text, guardian_email text, checkin jsonb, stamps jsonb, glow text, here boolean, already_sent boolean)
language sql security definer set search_path = public stable as $$
  select k.id, k.name, k.guardian_name, k.guardian_email, coalesce(ch.data,'{}'::jsonb), k.stamps, k.glow->>p_unit, k.here ? p_unit,
         exists (select 1 from djlab_recaps_sent s where s.kid_id = k.id and s.unit = p_unit)
  from djlab_kids k left join djlab_checkins ch on ch.kid_id = k.id and ch.unit = p_unit
  where k.cohort_id = p_cohort and k.recap_opt_in and k.guardian_email is not null;
$$;
revoke all on function djlab_recap_rows(uuid, text) from public, anon, authenticated;
grant execute on function djlab_recap_rows(uuid, text) to service_role;

-- ─────────────────────────────────────────────────────────────────────────
-- Safety upgrade (10/8/2026): fuller registration (authorized pickup,
-- medical/allergy, two emergency contacts, consents) and a sign-out log.
-- All of it is coach-only; none of it is ever returned by djlab_state.
-- ─────────────────────────────────────────────────────────────────────────
alter table djlab_registrations add column if not exists details jsonb not null default '{}'::jsonb;
  -- {age_group, medical, allergies, epinephrine, emergency:[{name,relationship,phone}x2],
  --  pickup:[{name,relationship,phone}], self_signout, media_consent, performance_consent,
  --  tracking_consent, conduct_agreed, custody_note}
alter table djlab_kids add column if not exists details jsonb not null default '{}'::jsonb;

-- Copy the registration details onto the kid at approval.
create or replace function djlab_coach_approve(p_session uuid, p_cohort uuid, p_reg uuid, p_station int, p_seat int, p_approve boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; r djlab_registrations; k djlab_kids;
begin
  select * into u from djlab_coach(p_session);
  select * into r from djlab_registrations where id = p_reg and status = 'pending';
  if r.id is null then raise exception 'registration not found'; end if;
  if not p_approve then
    update djlab_registrations set status = 'declined' where id = p_reg;
    return jsonb_build_object('declined', true);
  end if;
  insert into djlab_kids (cohort_id, name, station, seat, guardian_name, guardian_email, guardian_phone, recap_opt_in, registration_id, details)
  values (p_cohort, left(r.kid_first_name || coalesce(' ' || nullif(upper(left(r.kid_last_initial,1)),'') || '.',''),24), coalesce(p_station,1), coalesce(p_seat,0),
          r.guardian_name, lower(trim(r.guardian_email)), r.guardian_phone, r.recap_opt_in, r.id,
          r.details || jsonb_build_object('age', r.kid_age, 'accommodations', r.accommodations, 'emergency_contact_legacy', r.emergency_contact,
                                          'photo_consent', r.photo_consent))
  returning * into k;
  update djlab_registrations set status = 'approved' where id = p_reg;
  perform djlab_bump(p_cohort);
  return jsonb_build_object('id', k.id, 'name', k.name);
end;
$$;
grant execute on function djlab_coach_approve(uuid, uuid, uuid, int, int, boolean) to anon, authenticated;

-- Coach-only safety roster: everything needed at the door and in an emergency.
create or replace function djlab_coach_safety_roster(p_session uuid, p_cohort uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from djlab_coach(p_session);
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', k.id, 'name', k.name, 'station', k.station, 'here', k.here,
      'guardian', k.guardian_name, 'guardian_phone', k.guardian_phone,
      'pickup', coalesce(k.details->'pickup','[]'::jsonb), 'self_signout', coalesce((k.details->>'self_signout')::boolean,false),
      'emergency', coalesce(k.details->'emergency','[]'::jsonb), 'custody_note', k.details->>'custody_note',
      'medical', k.details->>'medical', 'allergies', k.details->>'allergies', 'epinephrine', coalesce((k.details->>'epinephrine')::boolean,false),
      'accommodations', k.details->>'accommodations',
      'performance_consent', coalesce((k.details->>'performance_consent')::boolean,false),
      'media_consent', coalesce((k.details->>'media_consent')::boolean, coalesce((k.details->>'photo_consent')::boolean,false)),
      'signouts', coalesce((select jsonb_agg(jsonb_build_object('unit',s.unit,'by',s.picked_up_by,'rel',s.relationship,'id_checked',s.id_checked,'self',s.self_signout,'coach',s.coach_name,'at',s.created_at) order by s.created_at desc)
                            from djlab_signouts s where s.kid_id = k.id), '[]'::jsonb)
    ) order by k.station, k.seat, k.name) from djlab_kids k where k.cohort_id = p_cohort), '[]'::jsonb);
end;
$$;

create table if not exists djlab_signouts (
  id uuid primary key default gen_random_uuid(),
  kid_id uuid not null references djlab_kids(id) on delete cascade,
  cohort_id uuid not null,
  unit text not null,
  picked_up_by text not null,
  relationship text,
  id_checked boolean not null default false,
  self_signout boolean not null default false,
  coach_name text not null,
  kid_name text,               -- stamped for the parent email
  guardian_email text,         -- stamped for the parent email; private table
  guardian_name text,
  created_at timestamptz not null default now()
);
alter table djlab_signouts enable row level security;
drop trigger if exists djlab_signouts_notify on djlab_signouts;
create trigger djlab_signouts_notify after insert on djlab_signouts
  for each row execute function notify_submission_webhook();
grant execute on function djlab_coach_safety_roster(uuid, uuid) to anon, authenticated;

-- Record a release. Refuses anyone not on the authorized list, refuses a
-- release without an ID check, and refuses self sign-out without written
-- permission on file.
create or replace function djlab_coach_signout(p_session uuid, p_cohort uuid, p_kid uuid, p_unit text,
                                               p_picked_up_by text, p_id_checked boolean, p_self boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; k djlab_kids; v_rel text; v_ok boolean := false;
begin
  select * into u from djlab_coach(p_session);
  select * into k from djlab_kids where id = p_kid and cohort_id = p_cohort;
  if k.id is null then raise exception 'unknown child'; end if;
  if coalesce(p_self,false) then
    if not coalesce((k.details->>'self_signout')::boolean,false) then raise exception 'no written permission on file for this child to sign out alone'; end if;
    v_ok := true;
  else
    if not coalesce(p_id_checked,false) then raise exception 'check photo ID before release'; end if;
    select e->>'relationship' into v_rel from jsonb_array_elements(coalesce(k.details->'pickup','[]'::jsonb)) e
      where lower(trim(e->>'name')) = lower(trim(p_picked_up_by)) limit 1;
    if v_rel is null and lower(trim(coalesce(k.guardian_name,''))) = lower(trim(p_picked_up_by)) then v_rel := 'Parent/guardian'; end if;
    if v_rel is null then raise exception 'not on the authorized pickup list: do not release; call the parent'; end if;
    v_ok := true;
  end if;
  insert into djlab_signouts (kid_id, cohort_id, unit, picked_up_by, relationship, id_checked, self_signout, coach_name, kid_name, guardian_email, guardian_name)
  values (k.id, p_cohort, p_unit, case when p_self then k.name || ' (self sign-out)' else trim(p_picked_up_by) end, coalesce(v_rel,'Self'),
          coalesce(p_id_checked,false), coalesce(p_self,false), u.v_name, k.name, k.guardian_email, k.guardian_name);
  return jsonb_build_object('ok', v_ok);
end;
$$;
grant execute on function djlab_coach_signout(uuid, uuid, uuid, text, text, boolean, boolean) to anon, authenticated;

-- Add an adult to a child's authorized-pickup list after the parent asks IN
-- WRITING (email or text from the number on file) and the coach has called
-- back to confirm. The request source is stored with the entry.
create or replace function djlab_coach_add_pickup(p_session uuid, p_cohort uuid, p_kid uuid, p_name text, p_relationship text, p_phone text, p_written_request text)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; k djlab_kids;
begin
  select * into u from djlab_coach(p_session);
  if coalesce(trim(p_name),'') = '' or coalesce(trim(p_written_request),'') = '' then
    raise exception 'name and the written request (how and when the parent asked) are required';
  end if;
  update djlab_kids set details = jsonb_set(details, '{pickup}', coalesce(details->'pickup','[]'::jsonb) || jsonb_build_array(jsonb_build_object(
      'name', left(trim(p_name),80), 'relationship', left(coalesce(p_relationship,''),40), 'phone', left(coalesce(p_phone,''),30),
      'added_by', u.v_name, 'added_at', now(), 'written_request', left(p_written_request,200))))
  where id = p_kid and cohort_id = p_cohort returning * into k;
  if k.id is null then raise exception 'unknown child'; end if;
  return jsonb_build_object('ok', true);
end;
$$;
grant execute on function djlab_coach_add_pickup(uuid, uuid, uuid, text, text, text, text) to anon, authenticated;

-- ─────────────────────────────────────────────────────────────────────────
-- Access & consent hardening (10/8/2026, after external review).
--  * Families no longer use the class code. Each approved child gets a
--    private family link (family_key) emailed to the guardian; it shows ONLY
--    that child (djlab_family_state).
--  * In-room Kid/Station screens use a ROOM CODE the coach issues for each
--    class; it expires (default 4 hours), so a leaked code dies the same day.
--    The permanent cohort code is now only a registration/class identifier
--    and no longer opens the class board.
--  * Consent is enforced server-side: no app check-ins without digital
--    tracking consent; no Spotlight without performance consent.
--  * Incidents can be logged from the coach screen (djlab_incidents) and
--    are emailed to Stephen.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function djlab_new_key(n int, alphabet text) returns text language plpgsql as $$
declare k text := '';
begin
  for i in 1..n loop k := k || substr(alphabet, 1 + floor(random()*length(alphabet))::int, 1); end loop;
  return k;
end;
$$;

alter table djlab_kids add column if not exists family_key text unique;
update djlab_kids set family_key = djlab_new_key(10, 'abcdefghjkmnpqrstuvwxyz23456789') where family_key is null;
alter table djlab_kids alter column family_key set default djlab_new_key(10, 'abcdefghjkmnpqrstuvwxyz23456789');

alter table djlab_cohorts add column if not exists room_code text unique;
alter table djlab_cohorts add column if not exists room_expires_at timestamptz;

-- Coach: get (or renew) today's room code.
create or replace function djlab_coach_room_code(p_session uuid, p_cohort uuid, p_renew boolean default false, p_hours int default 4)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; c djlab_cohorts; k text;
begin
  select * into u from djlab_coach(p_session);
  select * into c from djlab_cohorts where id = p_cohort;
  if c.id is null then raise exception 'unknown class'; end if;
  if p_renew or c.room_code is null or c.room_expires_at is null or c.room_expires_at < now() then
    loop
      k := djlab_new_key(6, 'ABCDEFGHJKMNPQRSTUVWXYZ23456789');
      exit when not exists (select 1 from djlab_cohorts where room_code = k or code = k);
    end loop;
    update djlab_cohorts set room_code = k, room_expires_at = now() + make_interval(hours => greatest(1, least(coalesce(p_hours,4), 12))),
      version = version + 1 where id = p_cohort returning * into c;
  end if;
  return jsonb_build_object('room_code', c.room_code, 'expires_at', c.room_expires_at, 'code', c.code, 'name', c.name);
end;
$$;
grant execute on function djlab_coach_room_code(uuid, uuid, boolean, int) to anon, authenticated;

create or replace function djlab_coach_end_room(p_session uuid, p_cohort uuid) returns void
language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from djlab_coach(p_session);
  update djlab_cohorts set room_expires_at = now(), version = version + 1 where id = p_cohort;
end;
$$;
grant execute on function djlab_coach_end_room(uuid, uuid) to anon, authenticated;

create or replace function djlab_room_cohort(p_code text) returns uuid
language sql security definer set search_path = public stable as $$
  select id from djlab_cohorts where room_code = upper(trim(p_code)) and room_expires_at > now() and not archived;
$$;
revoke all on function djlab_room_cohort(text) from public, anon, authenticated;

-- Room-screen state: only with a live room code; no glow notes, no consents beyond the tracking flag.
create or replace function djlab_state(p_code text, p_since bigint default 0)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare c djlab_cohorts; v_now bigint := (extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  select * into c from djlab_cohorts where id = djlab_room_cohort(p_code);
  if c.id is null then return jsonb_build_object('error','unknown_code', 'now', v_now); end if;
  if c.version <= coalesce(p_since,0) then return jsonb_build_object('version', c.version, 'unchanged', true, 'now', v_now); end if;
  return jsonb_build_object(
    'version', c.version, 'now', v_now, 'expires_at', c.room_expires_at,
    'cohort', jsonb_build_object('id', c.id, 'name', c.name),
    'live', c.live,
    'kids', coalesce((select jsonb_agg(jsonb_build_object('id',k.id,'name',k.name,'station',k.station,'seat',k.seat,
                     'stamps',k.stamps,'here',k.here,'glow','{}'::jsonb,
                     'tracking', coalesce((k.details->>'tracking_consent')::boolean,false)) order by k.station,k.seat,k.name)
                     from djlab_kids k where k.cohort_id = c.id), '[]'::jsonb),
    'checkins', coalesce((select jsonb_object_agg(ch.kid_id::text || '_' || ch.unit, ch.data || jsonb_build_object('kid', ch.kid_id, 'unit', ch.unit))
                     from djlab_checkins ch join djlab_kids k on k.id = ch.kid_id where k.cohort_id = c.id), '{}'::jsonb));
end;
$$;

-- Coach state: full class board, by coach session.
create or replace function djlab_coach_state(p_session uuid, p_cohort uuid, p_since bigint default 0)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; c djlab_cohorts; v_now bigint := (extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  select * into u from djlab_coach(p_session);
  select * into c from djlab_cohorts where id = p_cohort and not archived;
  if c.id is null then return jsonb_build_object('error','unknown_class', 'now', v_now); end if;
  if c.version <= coalesce(p_since,0) then return jsonb_build_object('version', c.version, 'unchanged', true, 'now', v_now); end if;
  return jsonb_build_object(
    'version', c.version, 'now', v_now, 'room_code', c.room_code, 'expires_at', c.room_expires_at,
    'cohort', jsonb_build_object('id', c.id, 'name', c.name, 'code', c.code),
    'live', c.live,
    'kids', coalesce((select jsonb_agg(jsonb_build_object('id',k.id,'name',k.name,'station',k.station,'seat',k.seat,
                     'stamps',k.stamps,'here',k.here,'glow',k.glow,'recap',k.recap_opt_in and k.guardian_email is not null,
                     'tracking', coalesce((k.details->>'tracking_consent')::boolean,false),
                     'perform', coalesce((k.details->>'performance_consent')::boolean,false)) order by k.station,k.seat,k.name)
                     from djlab_kids k where k.cohort_id = c.id), '[]'::jsonb),
    'checkins', coalesce((select jsonb_object_agg(ch.kid_id::text || '_' || ch.unit, ch.data || jsonb_build_object('kid', ch.kid_id, 'unit', ch.unit))
                     from djlab_checkins ch join djlab_kids k on k.id = ch.kid_id where k.cohort_id = c.id), '{}'::jsonb));
end;
$$;
grant execute on function djlab_coach_state(uuid, uuid, bigint) to anon, authenticated;

-- Family state: ONE child, by that family's private key.
create or replace function djlab_family_state(p_key text, p_since bigint default 0)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare k djlab_kids; c djlab_cohorts; v_now bigint := (extract(epoch from clock_timestamp()) * 1000)::bigint;
begin
  select * into k from djlab_kids where family_key = lower(trim(p_key));
  if k.id is null then return jsonb_build_object('error','unknown_key', 'now', v_now); end if;
  select * into c from djlab_cohorts where id = k.cohort_id;
  if c.version <= coalesce(p_since,0) then return jsonb_build_object('version', c.version, 'unchanged', true, 'now', v_now); end if;
  return jsonb_build_object(
    'version', c.version, 'now', v_now, 'family', true,
    'cohort', jsonb_build_object('id', c.id, 'name', c.name),
    'live', (c.live - 'spot') || jsonb_build_object('spot', case when c.live->>'spot' = k.id::text then k.id::text else null end),
    'kids', jsonb_build_array(jsonb_build_object('id',k.id,'name',k.name,'station',k.station,'seat',k.seat,'stamps',k.stamps,'here',k.here,'glow',k.glow,
                              'tracking', coalesce((k.details->>'tracking_consent')::boolean,false))),
    'checkins', coalesce((select jsonb_object_agg(ch.kid_id::text || '_' || ch.unit, ch.data || jsonb_build_object('kid', ch.kid_id, 'unit', ch.unit))
                     from djlab_checkins ch where ch.kid_id = k.id), '{}'::jsonb));
end;
$$;
grant execute on function djlab_family_state(text, bigint) to anon, authenticated;

-- Kid check-ins: only with a live room code AND the family's tracking consent.
create or replace function djlab_checkin(p_code text, p_kid uuid, p_unit text, p_op text, p jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare v_cohort uuid; v_ok boolean; cur jsonb; nxt jsonb; arr jsonb;
begin
  select k.cohort_id, coalesce((k.details->>'tracking_consent')::boolean,false) into v_cohort, v_ok
  from djlab_kids k where k.id = p_kid and k.cohort_id = djlab_room_cohort(p_code);
  if v_cohort is null then raise exception 'room code expired or child not in this class'; end if;
  if not v_ok then raise exception 'this family has not turned on the class app for this child'; end if;
  if p_unit !~ '^(s([1-9]|1[0-4])|w[1-6])$' then raise exception 'bad unit'; end if;
  select data into cur from djlab_checkins where kid_id = p_kid and unit = p_unit;
  cur := coalesce(cur, '{}'::jsonb);
  if p_op = 'inc_data' then
    nxt := cur || jsonb_build_object('data', least(coalesce((cur->>'data')::int,0) + 1, 999));
  elsif p_op = 'append_mixlog' then
    arr := coalesce(cur->'mixlog','[]'::jsonb) || jsonb_build_array(jsonb_build_object(
          'pair', left(coalesce(p->>'pair',''),80), 'what', left(coalesce(p->>'what',''),120), 'fix', left(coalesce(p->>'fix',''),120),
          'at', (extract(epoch from now())*1000)::bigint));
    nxt := cur || jsonb_build_object('mixlog', (select jsonb_agg(e order by n) from jsonb_array_elements(arr) with ordinality t(e, n)
                                                where n > jsonb_array_length(arr) - 10));
  else
    nxt := cur;
    if p ? 'predict' and p->>'predict' in ('easy','medium','hard') then nxt := nxt || jsonb_build_object('predict', p->>'predict'); end if;
    if p ? 'level' and p->>'level' in ('mild','medium','spicy') then nxt := nxt || jsonb_build_object('level', p->>'level'); end if;
    if p ? 'light' and p->>'light' in ('green','yellow','red') then nxt := nxt || jsonb_build_object('light', p->>'light'); end if;
    if p ? 'next' then nxt := nxt || jsonb_build_object('next', left(p->>'next',140)); end if;
  end if;
  insert into djlab_checkins (kid_id, unit, data, updated_at) values (p_kid, p_unit, nxt, now())
  on conflict (kid_id, unit) do update set data = excluded.data, updated_at = now();
  perform djlab_bump(v_cohort);
  return nxt;
end;
$$;

-- Spotlight only for children with performance consent.
create or replace function djlab_coach_set_live(p_session uuid, p_cohort uuid, p_live jsonb)
returns bigint language plpgsql security definer set search_path = public as $$
declare u record; v bigint;
begin
  select * into u from djlab_coach(p_session);
  if nullif(p_live->>'spot','') is not null and not exists (
      select 1 from djlab_kids where id::text = p_live->>'spot' and cohort_id = p_cohort
        and coalesce((details->>'performance_consent')::boolean,false)) then
    raise exception 'no performance consent on file for this child, so they cannot be put in the Spotlight';
  end if;
  update djlab_cohorts set live = p_live, version = version + 1 where id = p_cohort returning version into v;
  return v;
end;
$$;

-- Coach-added kids (paper registration only): record which consents are on paper.
create or replace function djlab_coach_kid(p_session uuid, p_cohort uuid, p_kid uuid, p jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; r djlab_kids;
begin
  select * into u from djlab_coach(p_session);
  if p_kid is null then
    if not coalesce((p->>'paper_forms')::boolean,false) then
      raise exception 'add children through online registration, or confirm their paper registration and consents are on file';
    end if;
    insert into djlab_kids (cohort_id, name, station, seat, details) values (p_cohort, left(coalesce(nullif(trim(p->>'name'),''),'New kid'),24),
      coalesce((p->>'station')::int,1), coalesce((p->>'seat')::int,0),
      jsonb_build_object('paper_forms', true, 'tracking_consent', coalesce((p->>'tracking_consent')::boolean,false),
                         'performance_consent', coalesce((p->>'performance_consent')::boolean,false),
                         'media_consent', coalesce((p->>'media_consent')::boolean,false), 'added_by', u.v_name))
      returning * into r;
  else
    update djlab_kids set
      name = case when p ? 'name' then left(coalesce(nullif(trim(p->>'name'),''),name),24) else name end,
      station = case when p ? 'station' then (p->>'station')::int else station end,
      seat = case when p ? 'seat' then (p->>'seat')::int else seat end,
      stamps = case when p ? 'stamps' then p->'stamps' else stamps end,
      here = case when p ? 'here' then p->'here' else here end,
      glow = case when p ? 'glow' then p->'glow' else glow end
    where id = p_kid and cohort_id = p_cohort returning * into r;
  end if;
  perform djlab_bump(p_cohort);
  return jsonb_build_object('id', r.id);
end;
$$;

-- Incidents, logged from the coach screen; emailed to Stephen only.
create table if not exists djlab_incidents (
  id uuid primary key default gen_random_uuid(),
  cohort_id uuid not null references djlab_cohorts(id) on delete cascade,
  kid_id uuid references djlab_kids(id) on delete set null,
  kid_name text,
  unit text,
  kind text not null check (kind in ('injury','illness','allergic_reaction','behavior','peer_harm','safeguarding','lost_child','pickup','other')),
  what_happened text not null,
  action_taken text,
  parent_notified boolean not null default false,
  called_911 boolean not null default false,
  coach_name text not null,
  cohort_name text,
  created_at timestamptz not null default now()
);
alter table djlab_incidents enable row level security;
drop trigger if exists djlab_incidents_notify on djlab_incidents;
create trigger djlab_incidents_notify after insert on djlab_incidents for each row execute function notify_submission_webhook();

create or replace function djlab_coach_incident(p_session uuid, p_cohort uuid, p_kid uuid, p_unit text, p_kind text,
                                                p_what text, p_action text, p_parent boolean, p_911 boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; v_name text; v_cname text; r djlab_incidents;
begin
  select * into u from djlab_coach(p_session);
  if coalesce(trim(p_what),'') = '' then raise exception 'describe what happened'; end if;
  select name into v_name from djlab_kids where id = p_kid and cohort_id = p_cohort;
  select name into v_cname from djlab_cohorts where id = p_cohort;
  insert into djlab_incidents (cohort_id, kid_id, kid_name, unit, kind, what_happened, action_taken, parent_notified, called_911, coach_name, cohort_name)
  values (p_cohort, p_kid, v_name, p_unit, p_kind, left(p_what,2000), left(coalesce(p_action,''),2000), coalesce(p_parent,false), coalesce(p_911,false), u.v_name, v_cname)
  returning * into r;
  return jsonb_build_object('id', r.id, 'at', r.created_at);
end;
$$;
grant execute on function djlab_coach_incident(uuid, uuid, uuid, text, text, text, text, boolean, boolean) to anon, authenticated;

-- Family link emails (notify-submission formats them).
create table if not exists djlab_family_links_sent (
  id uuid primary key default gen_random_uuid(),
  kid_id uuid not null references djlab_kids(id) on delete cascade,
  kid_name text, guardian_name text, guardian_email text not null, family_key text not null, cohort_name text,
  created_at timestamptz not null default now()
);
alter table djlab_family_links_sent enable row level security;
drop trigger if exists djlab_family_links_notify on djlab_family_links_sent;
create trigger djlab_family_links_notify after insert on djlab_family_links_sent for each row execute function notify_submission_webhook();

create or replace function djlab_coach_send_family_link(p_session uuid, p_cohort uuid, p_kid uuid) returns jsonb
language plpgsql security definer set search_path = public as $$
declare u record; k djlab_kids; c djlab_cohorts;
begin
  select * into u from djlab_coach(p_session);
  select * into k from djlab_kids where id = p_kid and cohort_id = p_cohort;
  if k.id is null or k.guardian_email is null then raise exception 'no guardian email on file for this child'; end if;
  select * into c from djlab_cohorts where id = p_cohort;
  insert into djlab_family_links_sent (kid_id, kid_name, guardian_name, guardian_email, family_key, cohort_name)
  values (k.id, k.name, k.guardian_name, k.guardian_email, k.family_key, c.name);
  return jsonb_build_object('ok', true);
end;
$$;
grant execute on function djlab_coach_send_family_link(uuid, uuid, uuid) to anon, authenticated;

-- Approval now also emails the family link.
create or replace function djlab_coach_approve(p_session uuid, p_cohort uuid, p_reg uuid, p_station int, p_seat int, p_approve boolean)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; r djlab_registrations; k djlab_kids; c djlab_cohorts;
begin
  select * into u from djlab_coach(p_session);
  select * into r from djlab_registrations where id = p_reg and status = 'pending';
  if r.id is null then raise exception 'registration not found'; end if;
  if not p_approve then
    update djlab_registrations set status = 'declined' where id = p_reg;
    return jsonb_build_object('declined', true);
  end if;
  insert into djlab_kids (cohort_id, name, station, seat, guardian_name, guardian_email, guardian_phone, recap_opt_in, registration_id, details)
  values (p_cohort, left(r.kid_first_name || coalesce(' ' || nullif(upper(left(r.kid_last_initial,1)),'') || '.',''),24), coalesce(p_station,1), coalesce(p_seat,0),
          r.guardian_name, lower(trim(r.guardian_email)), r.guardian_phone, r.recap_opt_in, r.id,
          r.details || jsonb_build_object('age', r.kid_age, 'accommodations', r.accommodations, 'emergency_contact_legacy', r.emergency_contact,
                                          'photo_consent', r.photo_consent))
  returning * into k;
  update djlab_registrations set status = 'approved' where id = p_reg;
  select * into c from djlab_cohorts where id = p_cohort;
  insert into djlab_family_links_sent (kid_id, kid_name, guardian_name, guardian_email, family_key, cohort_name)
  values (k.id, k.name, k.guardian_name, k.guardian_email, k.family_key, c.name);
  perform djlab_bump(p_cohort);
  return jsonb_build_object('id', k.id, 'name', k.name);
end;
$$;

-- Interest-list entries (collected before launch, with no health/pickup
-- data) can never be approved onto a class: the family must complete full
-- registration first.
create or replace function djlab_coach_registrations(p_session uuid, p_cohort uuid)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; v_code text;
begin
  select * into u from djlab_coach(p_session);
  select code into v_code from djlab_cohorts where id = p_cohort;
  return coalesce((select jsonb_agg(jsonb_build_object('id',r.id,'kid',r.kid_first_name || coalesce(' ' || nullif(upper(left(r.kid_last_initial,1)),'') || '.',''),
            'age',r.kid_age,'guardian',r.guardian_name,'accommodations',r.accommodations,'photo',r.photo_consent,'recap',r.recap_opt_in,'at',r.created_at) order by r.created_at)
          from djlab_registrations r where r.status = 'pending' and not coalesce((r.details->>'interest_only')::boolean,false)
            and (r.cohort_code is null or upper(r.cohort_code) = v_code)), '[]'::jsonb);
end;
$$;

create or replace function djlab_reg_guard() returns trigger language plpgsql as $$
begin
  if new.status = 'approved' and coalesce((new.details->>'interest_only')::boolean,false) then
    raise exception 'interest-list entries cannot be approved; the family must complete full registration';
  end if;
  return new;
end;
$$;
drop trigger if exists djlab_reg_guard on djlab_registrations;
create trigger djlab_reg_guard before update on djlab_registrations for each row execute function djlab_reg_guard();

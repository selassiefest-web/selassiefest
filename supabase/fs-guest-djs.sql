-- ─────────────────────────────────────────────────────────────────────────
-- Guest DJ outreach for the Rainbow DJ Lab 2027 (/guest-dj/?k=<key>).
-- Chicago women DJs and radio voices are invited to teach the 5:30-6:00 pm
-- guest session on a class Tuesday ($200). Each one gets an unguessable key;
-- her personal page shows only her name, a personal line, her suggested
-- Missions and the program details, and lets her answer yes / maybe / no and
-- pick the Missions, sounds, months and age group that fit her. Answers land
-- in fs_guest_dj_responses (write-only, inserted by the public-submit edge
-- function), which emails Stephen via notify-submission and, through
-- fs_guest_dj_response_apply, updates her status. The tracker
-- (/full-spectrum/guest-djs.html) reads everything through fs_guest_djs_load
-- with a Full Spectrum tracker session and scores best fits per class date.
--
-- Apply with: supabase db query --linked -f supabase/fs-guest-djs.sql
-- Safe to re-run. Roster rows are seeded out of band, never committed.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists fs_guest_djs (
  id uuid primary key default gen_random_uuid(),
  invite_key text unique,
  name text not null,                       -- professional name, used in the greeting
  real_name text,
  email text,                               -- only a publicly published booking address
  email_source text,
  form_url text,                            -- booking/contact form when there is no email
  instagram text,
  website text,
  personal_line text,                       -- one sentence about her work, shown on her page and in the email
  bio_source text,
  specialties text[] not null default '{}',
  suggested_missions int[] not null default '{}',  -- 1-14, Rainbow DJ Lab Missions that fit her
  tier text,                                -- priority / radio / legacy / rising
  status text not null default 'research'
    check (status in ('research','ready','invited','viewed','yes','maybe','no','booked','do_not_contact')),
  invited_at timestamptz,
  invited_via text,                         -- email / form / instagram / phone
  page_views int not null default 0,
  page_last_viewed timestamptz,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table fs_guest_djs enable row level security;
-- Zero policies: read and written only through the functions below.

create or replace function fs_new_guest_dj_key() returns text language plpgsql as $$
declare a text := 'abcdefghjkmnpqrstuvwxyz23456789'; k text;
begin
  loop
    k := '';
    for i in 1..8 loop k := k || substr(a, 1 + floor(random() * length(a))::int, 1); end loop;
    exit when not exists (select 1 from fs_guest_djs where invite_key = k)
          and not exists (select 1 from fs_partners where pitch_key = k);
  end loop;
  return k;
end;
$$;
alter table fs_guest_djs alter column invite_key set default fs_new_guest_dj_key();

create table if not exists fs_guest_dj_responses (
  id uuid primary key default gen_random_uuid(),
  invite_key text not null,
  decision text not null check (decision in ('yes','maybe','no')),
  missions jsonb,          -- ranked Mission numbers she picked, e.g. [6,2,12]
  sounds jsonb,            -- genres/styles she would bring
  months jsonb,            -- 2027 months she could come, e.g. ["Feb","Mar"]
  frequency text,          -- once / few / monthly / open
  age_group text,          -- middle / high / mixed / any
  contact_name text,
  email text,
  phone text,
  message text,
  dj_name text,            -- stamped by the before-insert trigger for the staff email
  created_at timestamptz not null default now()
);
alter table fs_guest_dj_responses enable row level security;
-- Zero policies: only public-submit (service role) inserts; nobody reads via anon.

-- Public read of one invitation by key. Counts the visit and moves an
-- invited DJ to "viewed". Only fields meant for her leave the database.
create or replace function fs_guest_dj_view(p_key text)
returns table (name text, personal_line text, suggested_missions int[], specialties text[], answered text)
language plpgsql security definer set search_path = public as $$
begin
  update fs_guest_djs g set page_views = g.page_views + 1, page_last_viewed = now(),
    status = case when g.status in ('ready','invited') then 'viewed' else g.status end, updated_at = now()
  where g.invite_key = p_key;
  return query
    select g.name, g.personal_line, g.suggested_missions, g.specialties,
           (select r.decision from fs_guest_dj_responses r where r.invite_key = g.invite_key order by r.created_at desc limit 1)
    from fs_guest_djs g where g.invite_key = p_key;
end;
$$;
grant execute on function fs_guest_dj_view(text) to anon, authenticated;

-- Stamp her name onto the answer so the staff email can say who it is.
create or replace function fs_guest_dj_response_stamp() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  select name into new.dj_name from fs_guest_djs where invite_key = new.invite_key;
  return new;
end;
$$;
drop trigger if exists fs_guest_dj_responses_stamp on fs_guest_dj_responses;
create trigger fs_guest_dj_responses_stamp before insert on fs_guest_dj_responses
  for each row execute function fs_guest_dj_response_stamp();

-- Her answer sets her status (never downgrades a booked DJ).
create or replace function fs_guest_dj_response_apply() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  update fs_guest_djs set
    status = case when status in ('booked','do_not_contact') then status else new.decision end,
    updated_at = now()
  where invite_key = new.invite_key;
  return new;
end;
$$;
drop trigger if exists fs_guest_dj_responses_apply on fs_guest_dj_responses;
create trigger fs_guest_dj_responses_apply after insert on fs_guest_dj_responses
  for each row execute function fs_guest_dj_response_apply();

-- Staff email (formatFsGuestDjResponse in notify-submission/index.ts).
drop trigger if exists fs_guest_dj_responses_notify on fs_guest_dj_responses;
create trigger fs_guest_dj_responses_notify after insert on fs_guest_dj_responses
  for each row execute function notify_submission_webhook();

-- Tracker read: the roster with her latest answer, for a signed-in tracker user.
create or replace function fs_guest_djs_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return coalesce((select jsonb_agg(to_jsonb(g) - 'id' || jsonb_build_object('id', g.id,
      'answer', (select to_jsonb(r) - 'invite_key' from fs_guest_dj_responses r where r.invite_key = g.invite_key order by r.created_at desc limit 1))
    order by g.name) from fs_guest_djs g), '[]'::jsonb);
end;
$$;
grant execute on function fs_guest_djs_load(uuid) to anon, authenticated;

-- Tracker write: status, booking notes and the invite channel.
create or replace function fs_guest_dj_mark(p_session uuid, p_id uuid, p_status text, p_note text default null)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_status not in ('research','ready','invited','viewed','yes','maybe','no','booked','do_not_contact') then raise exception 'bad status'; end if;
  update fs_guest_djs set status = p_status,
    invited_at = case when p_status = 'invited' and invited_at is null then now() else invited_at end,
    notes = case when nullif(trim(coalesce(p_note,'')),'') is null then notes
                 else coalesce(notes || E'\n', '') || to_char(now(), 'Mon DD') || ' (' || u.v_name || '): ' || left(trim(p_note), 500) end,
    updated_at = now()
  where id = p_id;
end;
$$;
grant execute on function fs_guest_dj_mark(uuid, uuid, text, text) to anon, authenticated;

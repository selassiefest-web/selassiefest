-- Show pitches: one-off shows we shop to the clubs already in lr_venues.
-- First show: 'marley-live-forever' (Jay RebL as Bob Marley with Ifficial
-- Reggae Movement, the Stanley Theatre set; first choice Sat Feb 6, 2027).
-- Each club keeps its one lr_venues.pitch_key; the show page is
-- /live-reggae/marley/?k=<pitch_key>. The weekly-rotation stage on lr_venues
-- is left alone; a club's progress on a show lives in lr_show_pitches.
-- Apply with: supabase db query --linked -f supabase/lr-show-pitches.sql

create table if not exists lr_show_pitches (
  id uuid primary key default gen_random_uuid(),
  venue_id uuid not null references lr_venues(id) on delete cascade,
  show text not null default 'marley-live-forever' check (show in ('marley-live-forever')),
  stage text not null default 'not_pitched'
    check (stage in ('not_pitched','sent','talking','booked','declined')),
  date_offered date default '2027-02-06',
  date_agreed date,
  last_answer text,                      -- the club's latest answer on the pitch page, in words
  answered_at timestamptz,
  sent_at timestamptz,
  next_step text,
  next_step_due date,
  notes text,
  views int not null default 0,
  last_viewed timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (venue_id, show)
);
alter table lr_show_pitches enable row level security;

-- Public read by key: the club's name for the greeting. Counts the view.
create or replace function lr_show_pitch_view(p_key text, p_show text default 'marley-live-forever')
returns table (name text, neighborhood text, region text)
language plpgsql security definer set search_path = public as $$
declare v lr_venues;
begin
  select * into v from lr_venues where pitch_key = p_key;
  if v.id is null then return; end if;
  insert into lr_show_pitches (venue_id, show, views, last_viewed) values (v.id, p_show, 1, now())
  on conflict (venue_id, show) do update set views = lr_show_pitches.views + 1, last_viewed = now();
  return query select v.name, v.neighborhood, v.region;
end;
$$;
grant execute on function lr_show_pitch_view(text, text) to anon, authenticated;

-- Answers from the show page, keyed or open. Write-only: inserted by public-submit.
create table if not exists lr_show_responses (
  id uuid primary key default gen_random_uuid(),
  show text not null default 'marley-live-forever' check (show in ('marley-live-forever')),
  pitch_key text,
  venue_name text,                       -- typed on the open form; stamped from lr_venues when keyed
  decision text not null check (decision in ('host_feb6','other_date','not_now')),
  date_wish text,                        -- "a Saturday in March", "4/17", in their words
  deal_pref text check (deal_pref is null or deal_pref in ('flat','deal','talk')),
  contact_name text,
  contact_title text,
  phone text,
  email text,
  city text,
  message text,
  created_at timestamptz not null default now()
);
alter table lr_show_responses enable row level security;

create or replace function lr_show_response_stamp() returns trigger
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
drop trigger if exists lr_show_responses_stamp on lr_show_responses;
create trigger lr_show_responses_stamp before insert on lr_show_responses
  for each row execute function lr_show_response_stamp();

-- A keyed answer moves that club's show pitch along and logs it; an open-form
-- answer adds the club as a new prospect so nothing falls through the cracks.
create or replace function lr_show_response_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare v lr_venues; v_label text; v_contact jsonb; v_stage text;
begin
  v_label := case new.decision when 'host_feb6' then 'Host it Feb 6, 2027' when 'other_date' then 'Talk about another date' else 'Not right now' end;
  v_contact := case when coalesce(nullif(new.contact_name,''), nullif(new.phone,''), nullif(new.email,'')) is null then '[]'::jsonb
                    else jsonb_build_array(jsonb_strip_nulls(jsonb_build_object('name', nullif(new.contact_name,''), 'role', nullif(new.contact_title,''),
                                                                                 'email', nullif(new.email,''), 'phone', nullif(new.phone,'')))) end;
  if new.pitch_key is not null then select * into v from lr_venues where pitch_key = new.pitch_key; end if;
  if v.id is null then
    insert into lr_venues (name, neighborhood, contacts, source)
    values (coalesce(nullif(trim(new.venue_name),''), 'Club from the Marley booking form'), nullif(trim(new.city),''), v_contact,
            'Marley show booking form (/live-reggae/marley/)')
    returning * into v;
  else
    update lr_venues set contacts = contacts || v_contact, last_contact_at = now(), updated_at = now() where id = v.id;
  end if;
  v_stage := case when new.decision = 'not_now' then 'declined' else 'talking' end;
  insert into lr_show_pitches (venue_id, show, stage, last_answer, answered_at, next_step, next_step_due)
  values (v.id, new.show, v_stage, v_label || coalesce(' (' || nullif(new.date_wish,'') || ')', ''), now(),
          case when new.decision <> 'not_now' then 'Call ' || coalesce(nullif(new.contact_name,''), 'them') || ' back about the Marley show' end,
          case when new.decision <> 'not_now' then current_date + 1 end)
  on conflict (venue_id, show) do update set
    stage = case when lr_show_pitches.stage = 'booked' then 'booked' else excluded.stage end,
    last_answer = excluded.last_answer, answered_at = now(),
    next_step = coalesce(excluded.next_step, lr_show_pitches.next_step),
    next_step_due = coalesce(excluded.next_step_due, lr_show_pitches.next_step_due),
    updated_at = now();
  insert into lr_activity (venue_id, kind, summary, by_email, by_name)
  values (v.id, 'note', 'Marley show page answer: ' || v_label ||
            coalesce(' from ' || nullif(new.contact_name,''), '') || coalesce(' (' || nullif(new.contact_title,'') || ')', '') ||
            coalesce('. Date: ' || nullif(new.date_wish,''), '') ||
            coalesce('. Deal: ' || case new.deal_pref when 'flat' then 'flat fee' when 'deal' then 'door/bar deal' when 'talk' then 'wants to talk it through' end, '') ||
            coalesce('. Phone ' || nullif(new.phone,''), '') || coalesce('. Email ' || nullif(new.email,''), '') ||
            coalesce('. "' || nullif(new.message,'') || '"', ''),
          'pitch-page', 'Pitch page');
  return new;
end;
$$;
drop trigger if exists lr_show_responses_apply on lr_show_responses;
create trigger lr_show_responses_apply after insert on lr_show_responses
  for each row execute function lr_show_response_apply();

drop trigger if exists lr_show_responses_notify on lr_show_responses;
create trigger lr_show_responses_notify after insert on lr_show_responses
  for each row execute function notify_submission_webhook();

-- Board: every club with its show-pitch row (if any), for one show.
create or replace function lr_show_pitches_load(p_session uuid, p_show text default 'marley-live-forever')
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from lr_session_user(p_session);
  return coalesce((select jsonb_agg(to_jsonb(s) order by s.venue_id) from lr_show_pitches s where s.show = p_show), '[]'::jsonb);
end;
$$;
grant execute on function lr_show_pitches_load(uuid, text) to anon, authenticated;

-- Board: update a club's show pitch (creates the row the first time).
create or replace function lr_show_pitch_save(p_session uuid, p_venue uuid, p jsonb, p_show text default 'marley-live-forever')
returns lr_show_pitches language plpgsql security definer set search_path = public as $$
declare u record; r lr_show_pitches; v_old text;
begin
  select * into u from lr_session_user(p_session);
  insert into lr_show_pitches (venue_id, show) values (p_venue, p_show) on conflict (venue_id, show) do nothing;
  select stage into v_old from lr_show_pitches where venue_id = p_venue and show = p_show;
  update lr_show_pitches set
    stage         = case when p ? 'stage' then coalesce(nullif(p->>'stage',''), stage) else stage end,
    sent_at       = case when p ? 'stage' and p->>'stage' = 'sent' and sent_at is null then now() else sent_at end,
    date_offered  = case when p ? 'date_offered' then nullif(p->>'date_offered','')::date else date_offered end,
    date_agreed   = case when p ? 'date_agreed' then nullif(p->>'date_agreed','')::date else date_agreed end,
    next_step     = case when p ? 'next_step' then nullif(trim(p->>'next_step'),'') else next_step end,
    next_step_due = case when p ? 'next_step_due' then nullif(p->>'next_step_due','')::date else next_step_due end,
    notes         = case when p ? 'notes' then nullif(trim(p->>'notes'),'') else notes end,
    updated_at    = now()
  where venue_id = p_venue and show = p_show
  returning * into r;
  if v_old is distinct from r.stage then
    insert into lr_activity (venue_id, kind, summary, stage_after, by_email, by_name)
    values (p_venue, 'note', 'Marley show: ' || replace(r.stage, '_', ' '), null, u.v_email, u.v_name);
  end if;
  return r;
end;
$$;
grant execute on function lr_show_pitch_save(uuid, uuid, jsonb, text) to anon, authenticated;

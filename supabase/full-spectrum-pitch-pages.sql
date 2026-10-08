-- ─────────────────────────────────────────────────────────────────────────
-- Personal pitch pages for the Full Spectrum Partner Tracker
-- (/partner/?k=<pitch_key>). Each partner gets an unguessable short key; the
-- leave-behind card's QR code opens a public page showing ONLY that
-- partner's name, pitch and ask (never contacts or notes), and lets them
-- answer: yes / call me / not now. Answers land in fs_partner_responses
-- (write-only, inserted by the public-submit edge function), which emails
-- Stephen via notify-submission and, through fs_partner_response_apply,
-- logs the answer on the partner, moves its stage and saves the person's
-- contact details into the partner's contacts.
-- ─────────────────────────────────────────────────────────────────────────
alter table fs_partners add column if not exists pitch_key text unique;
alter table fs_partners add column if not exists pitch_views int not null default 0;
alter table fs_partners add column if not exists pitch_last_viewed timestamptz;

-- 8 characters from an unambiguous alphabet (no 0/O/1/l/I) -- short enough
-- for a clean QR code, ~1e14 combinations so keys can't be walked.
create or replace function fs_new_pitch_key() returns text language plpgsql as $$
declare a text := 'abcdefghjkmnpqrstuvwxyz23456789'; k text;
begin
  loop
    k := '';
    for i in 1..8 loop k := k || substr(a, 1 + floor(random() * length(a))::int, 1); end loop;
    exit when not exists (select 1 from fs_partners where pitch_key = k);
  end loop;
  return k;
end;
$$;
alter table fs_partners alter column pitch_key set default fs_new_pitch_key();
update fs_partners set pitch_key = fs_new_pitch_key() where pitch_key is null;

-- Public read of one pitch by key; counts the scan. Returns nothing for an
-- unknown key. Only safe, already-public-facing fields leave the database.
create or replace function fs_pitch_view(p_key text)
returns table (name text, pitch text, ask text, program_parts text[])
language plpgsql security definer set search_path = public as $$
begin
  update fs_partners p set pitch_views = p.pitch_views + 1, pitch_last_viewed = now()
  where p.pitch_key = p_key;
  return query select p.name, p.pitch, p.ask, p.program_parts from fs_partners p where p.pitch_key = p_key;
end;
$$;
grant execute on function fs_pitch_view(text) to anon, authenticated;

create table if not exists fs_partner_responses (
  id uuid primary key default gen_random_uuid(),
  pitch_key text not null,
  decision text not null check (decision in ('yes', 'call_me', 'not_now')),
  contact_name text,
  contact_title text,
  phone text,
  email text,
  message text,
  created_at timestamptz not null default now()
);
alter table fs_partner_responses enable row level security;
-- Zero policies: only public-submit (service role) inserts; nobody reads via anon.

create or replace function fs_partner_response_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare p fs_partners; v_stage text; v_label text;
begin
  select * into p from fs_partners where pitch_key = new.pitch_key;
  if p.id is null then return new; end if;
  v_label := case new.decision when 'yes' then 'YES, count us in' when 'call_me' then 'Call me, I have questions' else 'Not right now' end;
  v_stage := case
    when new.decision = 'yes' and p.stage in ('not_contacted','reached_out','in_conversation','meeting_set','on_hold') then 'committed'
    when new.decision = 'call_me' and p.stage in ('not_contacted','reached_out','on_hold') then 'in_conversation'
    when new.decision = 'not_now' and p.stage in ('not_contacted','reached_out') then 'on_hold'
    else null end;
  update fs_partners set
    stage = coalesce(v_stage, stage),
    last_contact_at = now(),
    next_step = case when new.decision in ('yes','call_me') then 'Call ' || coalesce(nullif(new.contact_name,''), 'them') || ' back (answered the pitch page)' else next_step end,
    next_step_due = case when new.decision in ('yes','call_me') then current_date + 2 else next_step_due end,
    contacts = case when coalesce(nullif(new.contact_name,''), nullif(new.phone,''), nullif(new.email,'')) is null then contacts
                    else contacts || jsonb_build_array(jsonb_strip_nulls(jsonb_build_object('name', nullif(new.contact_name,''), 'role', nullif(new.contact_title,''),
                                                                                         'email', nullif(new.email,''), 'phone', nullif(new.phone,'')))) end,
    updated_at = now()
  where id = p.id;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  values (p.id, 'note', 'Pitch page answer: ' || v_label ||
            coalesce(' from ' || nullif(new.contact_name,''), '') || coalesce(' (' || nullif(new.contact_title,'') || ')', '') ||
            coalesce('. Phone ' || nullif(new.phone,''), '') || coalesce('. Email ' || nullif(new.email,''), '') ||
            coalesce('. "' || nullif(new.message,'') || '"', ''),
          v_stage, 'pitch-page', 'Pitch page');
  return new;
end;
$$;
drop trigger if exists fs_partner_responses_apply on fs_partner_responses;
create trigger fs_partner_responses_apply after insert on fs_partner_responses
  for each row execute function fs_partner_response_apply();

-- Staff email (formatFsPartnerResponse in notify-submission/index.ts).
drop trigger if exists fs_partner_responses_notify on fs_partner_responses;
create trigger fs_partner_responses_notify after insert on fs_partner_responses
  for each row execute function notify_submission_webhook();

-- Lets the notification email name the business without exposing the
-- partners table to the webhook payload consumer.
create or replace function fs_partner_name_for_key(p_key text) returns text
language sql security definer set search_path = public stable as $$
  select name from fs_partners where pitch_key = p_key;
$$;
revoke all on function fs_partner_name_for_key(text) from public, anon, authenticated;
grant execute on function fs_partner_name_for_key(text) to service_role;

-- The notify-submission formatter is synchronous and only sees the inserted
-- row, so stamp the business name onto the response before insert.
alter table fs_partner_responses add column if not exists partner_name text;
create or replace function fs_partner_response_stamp() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  new.partner_name := (select name from fs_partners where pitch_key = new.pitch_key);
  return new;
end;
$$;
drop trigger if exists fs_partner_responses_stamp on fs_partner_responses;
create trigger fs_partner_responses_stamp before insert on fs_partner_responses
  for each row execute function fs_partner_response_stamp();

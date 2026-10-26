-- Resident letter of support for Full Spectrum at Rainbow Beach (/full-spectrum/sign/).
-- Modeled on how Illinois nominating-petition signatures are judged (10 ILCS 5/7-10, 5/10-4; electoral board
-- records examinations): each signer signs in their own person, gives a complete residence address that is
-- checked against public records, must live in the district (here: Chicago's South Side), may sign only once,
-- and every signature is reviewed line by line, with any strike recorded with its reason.
--
-- rs_signatures holds names, addresses, emails and signature images, so it is locked: RLS on, no anon
-- policies. The resident-sign edge function (service role) writes it; staff review it through the
-- session-checked functions below (same sign-in as /full-spectrum/partners.html).

create table if not exists rs_signatures (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  letter text not null default 'full-spectrum-2027',
  first_name text not null,
  last_name text not null,
  name_norm text not null,
  street text not null,                 -- as typed by the signer
  unit text not null default '',
  zip text not null,
  matched_address text not null,        -- as matched by the U.S. Census geocoder
  address_norm text not null,           -- matched address + unit, for the one-signature-per-person rule
  lat double precision, lon double precision,
  community_area text not null,
  community_area_number int not null,
  area_tier text not null check (area_tier in ('rainbow_beach','south_side')),
  email text not null,
  email_confirmed_at timestamptz,
  confirm_hash text not null,
  signature_png text not null,          -- data:image/png;base64,... drawn by the signer
  says_adult boolean not null,          -- attested: 18 or older
  says_own_person boolean not null,     -- attested: signing for myself only
  says_registered boolean not null default false,  -- signer says they are a registered voter at this address
  show_publicly boolean not null default false,    -- first name, last initial and community area on the page
  comment text not null default '',
  ip_hash text not null default '',
  pattern_flag boolean not null default false,     -- several signatures from one device in a short time
  status text not null default 'unconfirmed'
    check (status in ('unconfirmed','pending_review','accepted','resident','struck')),
  reason_code text check (reason_code in ('NOT_IN_AREA','ADDRESS','NOT_REGISTERED','NOT_GENUINE','DUPLICATE','PATTERN','UNDER_18','UNCONFIRMED','OTHER')),
  voter_check text not null default 'not_checked' check (voter_check in ('not_checked','registered','not_found')),
  review_note text not null default '',
  reviewed_by text,
  reviewed_at timestamptz
);
alter table rs_signatures enable row level security;
create index if not exists rs_signatures_status on rs_signatures (status, created_at);
-- One signature per person: a second signature by the same name at the same address is never stored,
-- and one email address can sign once.
create unique index if not exists rs_signatures_person on rs_signatures (letter, name_norm, address_norm) where status <> 'struck';
create unique index if not exists rs_signatures_email on rs_signatures (letter, lower(email)) where status <> 'struck';

-- Public totals for the page. Counts only signatures that passed review; names only of those who opted in.
create or replace function rs_public_summary(p_letter text default 'full-spectrum-2027')
returns jsonb language sql security definer set search_path = public stable as $$
  select jsonb_build_object(
    'verified', count(*) filter (where status = 'accepted'),
    'verified_rainbow_beach', count(*) filter (where status = 'accepted' and area_tier = 'rainbow_beach'),
    'residents', count(*) filter (where status = 'resident'),
    'in_review', count(*) filter (where status = 'pending_review'),
    'by_area', coalesce((select jsonb_object_agg(community_area, n) from (
        select community_area, count(*) n from rs_signatures
        where letter = p_letter and status in ('accepted','resident') group by community_area) a), '{}'::jsonb),
    'recent', coalesce((select jsonb_agg(x order by x->>'at' desc) from (
        select jsonb_build_object('name', first_name || ' ' || left(last_name, 1) || '.', 'area', initcap(lower(community_area)), 'at', reviewed_at) x
        from rs_signatures where letter = p_letter and status in ('accepted','resident') and show_publicly
        order by reviewed_at desc limit 60) r), '[]'::jsonb)
  ) from rs_signatures where letter = p_letter;
$$;
revoke all on function rs_public_summary(text) from public;
grant execute on function rs_public_summary(text) to anon, authenticated, service_role;

-- Staff: the review queue (everything but the confirmation hash and IP hash).
create or replace function rs_review_list(p_session uuid, p_letter text default 'full-spectrum-2027')
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return coalesce((select jsonb_agg(to_jsonb(s) - 'confirm_hash' - 'ip_hash' order by s.created_at)
                   from rs_signatures s where s.letter = p_letter), '[]'::jsonb);
end;
$$;
grant execute on function rs_review_list(uuid, text) to anon, authenticated;

-- Staff: rule on one signature. accepted = registered voter verified at this address;
-- resident = valid South Side resident, registration not verified; struck = rejected, with a reason.
create or replace function rs_review_decide(p_session uuid, p_id uuid, p_status text, p_reason text, p_voter text, p_note text)
returns void language plpgsql security definer set search_path = public as $$
declare u record; s rs_signatures;
begin
  select * into u from fs_partner_session_user(p_session);
  select * into s from rs_signatures where id = p_id;
  if s.id is null then raise exception 'signature not found'; end if;
  if p_status not in ('accepted','resident','struck','pending_review') then raise exception 'bad status'; end if;
  if p_status = 'struck' and coalesce(p_reason, '') = '' then raise exception 'a struck signature needs a reason'; end if;
  if p_status = 'accepted' and p_voter <> 'registered' then raise exception 'accepted means the voter registration was verified'; end if;
  if p_status in ('accepted','resident') and s.email_confirmed_at is null then raise exception 'email not confirmed yet'; end if;
  update rs_signatures set
    status = p_status,
    reason_code = case when p_status = 'struck' then p_reason else null end,
    voter_check = coalesce(nullif(p_voter, ''), voter_check),
    review_note = coalesce(p_note, ''),
    reviewed_by = u.v_email, reviewed_at = now()
  where id = p_id;
end;
$$;
grant execute on function rs_review_decide(uuid, uuid, text, text, text, text) to anon, authenticated;

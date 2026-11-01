-- ─────────────────────────────────────────────────────────────────
-- Full Spectrum FOUNDING CIRCLE: gifts tracker (Gifts tab of
-- /full-spectrum/partners.html).
--
--  1. fs_inkind_offers : items people offer on /full-spectrum/founding-circle/#items.
--     Write-only for the public (inserted through the public-submit edge
--     function); staff read and update it only through the functions below,
--     each of which re-validates the magic-link session via
--     fs_partner_session_user() (see full-spectrum-partners.sql).
--     An AFTER INSERT trigger emails staff through notify_submission_webhook()
--     (the shared secret-bearing function that is deliberately not committed).
--  2. CASH gifts are NOT copied anywhere: they are read live from the Stripe
--     Sync Engine table stripe.payment_intents where metadata.fund =
--     'full-spectrum' and status = 'succeeded' (set by create-checkout-session).
--     Only deposited card gifts show here. PayPal, Venmo, Zelle, checks,
--     stock and pledges are not in Stripe: enter them with fs_gift_manual_add().
--  3. fs_circle_total() : public, returns ONLY the cash total, so the
--     Founding Circle page's progress bar updates itself.
--
-- Apply with:  supabase db query --linked -f supabase/fs-gifts.sql
-- Safe to re-run (idempotent).
-- ─────────────────────────────────────────────────────────────────

create table if not exists fs_inkind_offers (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  items text,                    -- checked categories
  description text,
  condition text,
  delivery text,
  donor_name text not null check (char_length(donor_name) between 1 and 200),
  donor_email text not null check (char_length(donor_email) between 3 and 200),
  donor_phone text,
  introduced_by text,
  value_estimate text,           -- the donor's own estimate; we never set values
  status text not null default 'new' check (status in ('new','accepted','scheduled','received','declined')),
  notes text,
  received_on date,
  ack_sent_on date
);
alter table fs_inkind_offers enable row level security;
revoke all on fs_inkind_offers from anon, authenticated;

drop trigger if exists fs_inkind_offers_notify on fs_inkind_offers;
create trigger fs_inkind_offers_notify after insert on fs_inkind_offers
  for each row execute function notify_submission_webhook();

-- Gifts that did not come through Stripe (PayPal, Venmo, Zelle, check, stock,
-- DAF, pledges). Staff-entered; counts toward the goal only when kind = 'cash'
-- and status = 'deposited'.
create table if not exists fs_gifts_manual (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  donor_name text not null,
  donor_email text,
  amount numeric(12,2) not null check (amount >= 0),
  channel text not null default 'check' check (channel in ('paypal','venmo','zelle','check','stock','daf','other')),
  status text not null default 'deposited' check (status in ('pledged','deposited')),
  introduced_by text,
  gift_date date default current_date,
  ack_sent_on date,
  notes text,
  entered_by text
);
alter table fs_gifts_manual enable row level security;
revoke all on fs_gifts_manual from anon, authenticated;

-- Everything the Gifts tab shows.
create or replace function fs_gifts_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record; cash jsonb; manual jsonb; inkind jsonb;
begin
  select * into u from fs_partner_session_user(p_session);
  select coalesce(jsonb_agg(jsonb_build_object(
      'id', pi.id,
      'amount', pi.amount_received::numeric / 100,
      'email', pi.receipt_email,
      'introduced_by', pi.metadata->>'introduced_by',
      'recurring', pi.metadata->>'recurring',
      'at', to_timestamp(pi.created)
    ) order by pi.created desc), '[]'::jsonb)
    into cash
    from stripe.payment_intents pi
    where pi.metadata->>'fund' = 'full-spectrum' and pi.status = 'succeeded' and pi.livemode;
  select coalesce(jsonb_agg(to_jsonb(m) order by m.gift_date desc, m.created_at desc), '[]'::jsonb) into manual from fs_gifts_manual m;
  select coalesce(jsonb_agg(to_jsonb(o) order by o.created_at desc), '[]'::jsonb) into inkind from fs_inkind_offers o;
  return jsonb_build_object('cash', cash, 'manual', manual, 'inkind', inkind);
end;
$$;
grant execute on function fs_gifts_load(uuid) to anon, authenticated;

create or replace function fs_inkind_update(p_session uuid, p_id uuid, p_status text, p_notes text default null, p_ack boolean default false)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_status not in ('new','accepted','scheduled','received','declined') then raise exception 'bad status'; end if;
  update fs_inkind_offers set
    status = p_status,
    notes = coalesce(nullif(left(trim(coalesce(p_notes,'')), 2000), ''), notes),
    received_on = case when p_status = 'received' then coalesce(received_on, current_date) else received_on end,
    ack_sent_on = case when p_ack then current_date else ack_sent_on end,
    updated_at = now()
  where id = p_id;
end;
$$;
grant execute on function fs_inkind_update(uuid, uuid, text, text, boolean) to anon, authenticated;

create or replace function fs_gift_manual_add(p_session uuid, p jsonb)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  insert into fs_gifts_manual (donor_name, donor_email, amount, channel, status, introduced_by, gift_date, notes, entered_by)
  values (
    left(trim(p->>'donor_name'), 200), nullif(left(trim(coalesce(p->>'donor_email','')), 200), ''),
    (p->>'amount')::numeric, coalesce(nullif(p->>'channel',''), 'check'), coalesce(nullif(p->>'status',''), 'deposited'),
    nullif(left(trim(coalesce(p->>'introduced_by','')), 200), ''),
    coalesce(nullif(p->>'gift_date','')::date, current_date), nullif(left(trim(coalesce(p->>'notes','')), 1000), ''), u.v_email
  );
end;
$$;
grant execute on function fs_gift_manual_add(uuid, jsonb) to anon, authenticated;

create or replace function fs_gift_manual_ack(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  update fs_gifts_manual set ack_sent_on = current_date where id = p_id;
end;
$$;
grant execute on function fs_gift_manual_ack(uuid, uuid) to anon, authenticated;

-- Public: cash total only. Deposited card gifts through Stripe plus manual
-- gifts marked deposited. No names, no emails, no per-gift rows.
create or replace function fs_circle_total()
returns numeric language sql security definer set search_path = public stable as $$
  select coalesce((select sum(pi.amount_received) from stripe.payment_intents pi
                    where pi.metadata->>'fund' = 'full-spectrum' and pi.status = 'succeeded' and pi.livemode), 0) / 100.0
       + coalesce((select sum(m.amount) from fs_gifts_manual m where m.status = 'deposited' and m.channel <> 'stock'), 0);
$$;
grant execute on function fs_circle_total() to anon, authenticated;

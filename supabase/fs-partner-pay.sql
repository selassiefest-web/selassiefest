-- ─────────────────────────────────────────────────────────────────────────
-- Cash asks on partner personal pages (/partner/?k=<pitch_key>).
-- An ask_items entry with "cash": true is a gift the partner can pay on the
-- page: by card through Stripe Checkout (create-checkout-session, mode
-- 'partner_gift'), or by PayPal (paypal.me/RASTAFARIINC, amount prefilled).
--   value > 0  => fixed price per unit (amount = qty x value)
--   no value   => partner types their own amount
-- ask_items entry: {"id":"child-dj","label":"Sponsor a Child DJ","cash":true,"qty":1,"value":250}
--
-- Stripe path: when Stripe confirms the charge, a trigger on
-- stripe.payment_intents (separate from, and untouched by, the live
-- handle_stripe_payment_succeeded) writes one row to fs_partner_gifts.
-- That row logs the gift on the partner (commitment, value, stage,
-- activity) and emails staff via notify-submission. PayPal gifts arrive as an
-- "I sent it" answer through fs_partner_responses and are confirmed by hand
-- in PayPal, since PayPal.me gives us no webhook.
--
-- Apply with: supabase db query --linked -f supabase/fs-partner-pay.sql
-- Safe to re-run. Requires fs-partner-asks.sql first.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists fs_partner_gifts (
  id uuid primary key default gen_random_uuid(),
  pitch_key text not null,
  partner_name text,
  amount numeric(12,2) not null,
  method text not null default 'stripe',
  payment_intent_id text unique,
  email text,
  summary text,
  created_at timestamptz not null default now()
);
alter table fs_partner_gifts enable row level security;
-- Zero policies: only the Stripe trigger (security definer) inserts.

-- The checkout Edge Function (service_role) reads a partner's menu by key.
-- Never exposed to anon: it returns only name + items, but the function is
-- the single place prices are decided.
create or replace function fs_partner_cash_menu(p_key text)
returns table (name text, ask_items jsonb)
language sql security definer set search_path = public stable as $$
  select p.name, p.ask_items from fs_partners p where p.pitch_key = p_key;
$$;
revoke all on function fs_partner_cash_menu(text) from public, anon, authenticated;
grant execute on function fs_partner_cash_menu(text) to service_role;

-- Stripe confirmed a partner gift -> one fs_partner_gifts row (idempotent).
create or replace function fs_partner_gift_from_stripe() returns trigger
language plpgsql security definer set search_path = public as $$
begin
  begin
    if NEW.status is distinct from 'succeeded' then return NEW; end if;
    if TG_OP = 'UPDATE' and OLD.status is not distinct from 'succeeded' then return NEW; end if;
    if NEW.metadata->>'order_type' is distinct from 'partner_gift' then return NEW; end if;
    insert into fs_partner_gifts (pitch_key, partner_name, amount, method, payment_intent_id, email, summary)
    values (NEW.metadata->>'pitch_key',
            (select name from fs_partners where pitch_key = NEW.metadata->>'pitch_key'),
            NEW.amount_received::numeric / 100, 'stripe', NEW.id, NEW.receipt_email, left(NEW.metadata->>'summary', 500))
    on conflict (payment_intent_id) do nothing;
  exception when others then
    raise warning 'fs_partner_gift_from_stripe failed non-fatally: %', SQLERRM;
  end;
  return NEW;
end;
$$;
drop trigger if exists fs_partner_gift_stripe on stripe.payment_intents;
create trigger fs_partner_gift_stripe after insert or update on stripe.payment_intents
  for each row execute function fs_partner_gift_from_stripe();

-- Log the gift on the partner.
create or replace function fs_partner_gift_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare p fs_partners;
begin
  select * into p from fs_partners where pitch_key = new.pitch_key;
  if p.id is null then return new; end if;
  update fs_partners set
    stage = 'confirmed',
    commitment = coalesce(commitment || '; ', '') || 'Gift $' || trim(to_char(new.amount, 'FM999999990.##')) || ' paid by card' || coalesce(' (' || new.summary || ')', ''),
    commitment_value = coalesce(commitment_value, 0) + new.amount,
    last_contact_at = now(),
    next_step = 'Send a thank-you and receipt acknowledgment',
    next_step_due = current_date + 2,
    updated_at = now()
  where id = p.id;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  values (p.id, 'note', 'Gift received by card: $' || trim(to_char(new.amount, 'FM999999990.##')) ||
            coalesce(' for ' || new.summary, '') || coalesce('. Receipt email ' || nullif(new.email, ''), ''),
          'confirmed', 'stripe', 'Stripe');
  return new;
end;
$$;
drop trigger if exists fs_partner_gifts_apply on fs_partner_gifts;
create trigger fs_partner_gifts_apply after insert on fs_partner_gifts
  for each row execute function fs_partner_gift_apply();

-- Staff email (formatFsPartnerGift in notify-submission/index.ts).
drop trigger if exists fs_partner_gifts_notify on fs_partner_gifts;
create trigger fs_partner_gifts_notify after insert on fs_partner_gifts
  for each row execute function notify_submission_webhook();

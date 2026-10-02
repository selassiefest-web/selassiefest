-- ============================================================================
-- Yawd Dry Goods -- early-access list (/yawd-dry-goods/)
-- ============================================================================
-- Apply to the linked project with:
--     npx supabase db query --linked -f supabase/yawd-waitlist.sql
--
-- Do NOT re-run supabase/schema.sql to pick this up. Once applied, this block
-- is also pasted into schema.sql so the full-schema reference stays accurate.
--
-- Same convention as every other public-submission table: write-only (anon
-- may INSERT, never SELECT), RLS enabled, and an AFTER INSERT trigger on the
-- shared notify_submission_webhook() so notify-submission emails staff (see
-- formatYawdWaitlist in notify-submission/index.ts).
-- ============================================================================

create table if not exists public.yawd_waitlist (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz not null default now(),
  full_name      text not null check (char_length(full_name) between 1 and 200),
  email          text not null check (char_length(email) between 3 and 320),
  phone          text check (char_length(phone) <= 40),
  zip            text check (char_length(zip) <= 12),
  -- household = shopping for home; restaurant = kitchen/caterer/food truck
  -- account; maker = a Jamaican producer who wants to be stocked
  customer_type  text not null default 'household'
                 check (customer_type in ('household', 'restaurant', 'maker', 'other')),
  business_name  text check (char_length(business_name) <= 200),
  interests      text[] not null default '{}',
  message        text check (char_length(message) <= 2000),
  source         text check (char_length(source) <= 100)
);

alter table public.yawd_waitlist enable row level security;

drop policy if exists "anon can join the yawd list" on public.yawd_waitlist;
create policy "anon can join the yawd list" on public.yawd_waitlist
  for insert to anon, authenticated
  with check (true);

grant insert on public.yawd_waitlist to anon, authenticated;

drop trigger if exists yawd_waitlist_notify on public.yawd_waitlist;
create trigger yawd_waitlist_notify
  after insert on public.yawd_waitlist
  for each row execute function notify_submission_webhook();

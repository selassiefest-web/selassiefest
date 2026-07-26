-- SelassieFest Supabase schema.
-- Run this in the Supabase SQL editor (or `supabase db push`) for this project.

create table if not exists newsletter_subscribers (
  id uuid primary key default gen_random_uuid(),
  email text not null unique,
  created_at timestamptz not null default now()
);

create table if not exists anansi_story_submissions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  email text not null,
  story_title text not null,
  story_text text not null,
  created_at timestamptz not null default now()
);

alter table newsletter_subscribers enable row level security;
alter table anansi_story_submissions enable row level security;

-- Both forms are public and submit with the anon key. Only INSERT is granted to
-- anon, and there is no SELECT policy, so the anon key can never read back
-- other people's emails or stories.
create policy "Allow anon insert" on newsletter_subscribers
  for insert to anon
  with check (true);

create policy "Allow anon insert" on anansi_story_submissions
  for insert to anon
  with check (true);

-- RLS policies alone are not sufficient — Postgres checks the base table
-- privilege first. Without these grants, anon gets a generic RLS-violation
-- error on every insert even though the policy above is satisfied.
grant usage on schema public to anon;
grant insert on newsletter_subscribers to anon;
grant insert on anansi_story_submissions to anon;

-- ─────────────────────────────────────────────────────────────────────────
-- Calendar (TRC Events dashboard, replacing the static /calendar/ hub)
-- ─────────────────────────────────────────────────────────────────────────

-- A "series" is the constant identity of a recurring or one-off event —
-- e.g. "Dancehall 101", "Soul Sundays", or a single-occurrence festival
-- like "Curry Fest Chicago". category drives which dashboard filter tab
-- (festival / special / weekly / games) an occurrence shows up under.
create table if not exists event_series (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  category text not null check (category in ('festival', 'special', 'weekly', 'games')),
  description text,
  created_at timestamptz not null default now()
);

-- An "occurrence" is one dated instance of a series — the actual "lesson"
-- for weekly series like Dancehall 101, where the DJ/lineup and write-up
-- change every week even though the series name doesn't. For one-off
-- festivals or special events, a series simply has a single occurrence.
create table if not exists event_occurrences (
  id uuid primary key default gen_random_uuid(),
  series_id uuid not null references event_series(id) on delete cascade,
  occurrence_date timestamptz not null,
  theme_title text not null,      -- e.g. "1960s Ska & Rocksteady", or "Curry Fest Chicago" for a one-off
  unit_label text,                -- optional curriculum framing, e.g. "Winter Sem: Foundations — Week 3"
  summary text not null,          -- short blurb shown on the dashboard card
  body text,                      -- long-form detail content, used only when detail_url is null
  lineup jsonb not null default '[]'::jsonb,  -- [{ "name": "...", "role": "DJ" | "Host" | "Performer" }]
  venue text,
  ticket_url text,
  hero_image text,
  -- When set, "View Details" on the dashboard links straight to an existing
  -- hand-built static page (e.g. /calendar/festivals/curry-fest.html)
  -- instead of the generic Supabase-rendered template. Curated festival and
  -- special-event pages keep their own custom content; only the
  -- high-volume weekly "lesson" pages actually need the generic template.
  detail_url text,
  created_at timestamptz not null default now(),
  unique (series_id, occurrence_date)
);

create index if not exists event_occurrences_date_idx on event_occurrences (occurrence_date);

-- Ras Tafari Inc (the nonprofit) runs both selassiefest.com and trcevent.com
-- (TRC Events, its marketing/promotion arm) off this same Supabase project.
-- brand marks which site owns/displays a given series so each site's
-- dashboard can filter to its own events (e.g. `where brand = 'trc'`)
-- without a second copy of this table. Defaults to 'selassiefest' since
-- every series predates TRC Events having its own site.
alter table event_series add column if not exists brand text not null default 'selassiefest' check (brand in ('selassiefest', 'trc'));

alter table event_series enable row level security;
alter table event_occurrences enable row level security;

-- Calendar data is public information (unlike the newsletter/Anansi forms
-- above, which are write-only for anon). Anon gets read-only access; there
-- is no insert/update/delete policy, so events are managed from the
-- Supabase Table Editor (or a future authenticated admin tool), never from
-- the public site.
--
-- IMPORTANT: also grant `authenticated` the same read access, not just
-- anon. supabase-js persists an auth session for the whole selassiefest.com
-- origin, not per-subpath -- once real logins existed on this site (the
-- /chicago-dancehall/ and /dancehall101/checkin/ password gates), any
-- visitor who had signed into either of those in the same browser started
-- getting queried here as `authenticated`, and an anon-only policy meant
-- the public /calendar/ dashboard silently showed all-zero counts for them
-- (a real incident, not theoretical -- caught 2026-07-11). Same fix as
-- dh101_schools/dh101_ambassadors: this data has no PII, so there's no
-- reason to withhold it from `authenticated` too.
create policy "Allow anon read" on event_series
  for select to anon
  using (true);

create policy "Allow anon read" on event_occurrences
  for select to anon
  using (true);

create policy "authenticated read" on event_series
  for select to authenticated
  using (true);

create policy "authenticated read" on event_occurrences
  for select to authenticated
  using (true);

grant select on event_series to anon, authenticated;
grant select on event_occurrences to anon, authenticated;

-- ─────────────────────────────────────────────────────────────────────────
-- Raffle entries and marketplace pre-orders
-- ─────────────────────────────────────────────────────────────────────────
-- Both forms previously had no real backend: raffle entries were saved to
-- the *submitting visitor's own* localStorage (never reaching the org, even
-- though a real payment/transaction ID was involved), and marketplace
-- pre-orders were only console.log'd behind a fake "check your email"
-- success message. These tables give both a real, durable destination.

create table if not exists raffle_entries (
  id uuid primary key default gen_random_uuid(),
  buyer_name text not null,
  buyer_email text not null,
  ticket_qty int not null check (ticket_qty > 0),
  total_amount numeric(10,2) not null,
  payment_method text not null,
  transaction_id text not null,
  prize_id text,
  prize_name text,
  status text not null default 'pending_verification',
  created_at timestamptz not null default now()
);

create table if not exists marketplace_preorders (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null,
  customer_email text not null,
  customer_phone text not null,
  pickup_time text,
  guest_count text,
  items jsonb not null,
  total_amount numeric(10,2) not null,
  created_at timestamptz not null default now()
);

alter table raffle_entries enable row level security;
alter table marketplace_preorders enable row level security;

-- Same write-only pattern as the newsletter/Anansi forms above: anon can
-- insert (submit an entry) but never read back — buyer names, emails, and
-- transaction IDs stay private to the org, viewed via the Supabase Table
-- Editor.
create policy "Allow anon insert" on raffle_entries
  for insert to anon
  with check (true);

grant insert on raffle_entries to anon;

-- marketplace_preorders is intentionally NOT anon-insertable. A row here is
-- only ever supposed to exist because Stripe confirmed a real charge; anon
-- insert was removed (previously `with check (true)` + `grant insert ...
-- to anon`, a leftover from before Stripe checkout existed) because it let
-- anyone holding the public anon key write arbitrary fake "paid" orders
-- directly, bypassing payment entirely and indistinguishable from a real
-- one. The only writer now is handle_stripe_payment_succeeded (see below),
-- a SECURITY DEFINER trigger function owned by the table owner, which
-- bypasses RLS regardless of anon's grants.

-- ─────────────────────────────────────────────────────────────────────────
-- Volunteer signup, sponsor inquiries, camp registration
-- ─────────────────────────────────────────────────────────────────────────
-- All three previously only built a mailto: link and relied on the visitor
-- having a desktop mail client configured to actually send anything.

create table if not exists volunteer_signups (
  id uuid primary key default gen_random_uuid(),
  full_name text not null,
  email text not null,
  phone text not null,
  age int,
  role_choice text,
  shift_preference text,
  tshirt_size text,
  emergency_contact text,
  accommodations text,
  referral_source text,
  waiver_accepted boolean not null default false,
  created_at timestamptz not null default now()
);

-- The 13 sponsor pages all collect the same way (generic loop over every
-- input/select/textarea, using each field's placeholder as its label), and
-- the exact field set varies slightly page to page, so `fields` keeps the
-- full generic {label, value} list rather than forcing per-page columns.
-- `source_page` and `email` are pulled out since every page has them.
create table if not exists sponsor_inquiries (
  id uuid primary key default gen_random_uuid(),
  source_page text not null,
  email text,
  fields jsonb not null,
  created_at timestamptz not null default now()
);

-- Camp registration has ~30 fields (camper info, two guardians, medical/
-- consent details, week selections). A few common fields are broken out for
-- quick scanning in the Table Editor; everything else lives in
-- registration_data so the form can evolve without a migration each time.
create table if not exists camp_registrations (
  id uuid primary key default gen_random_uuid(),
  camper_name text not null,
  guardian_name text not null,
  guardian_email text not null,
  guardian_phone text not null,
  registration_data jsonb not null,
  created_at timestamptz not null default now()
);

alter table volunteer_signups enable row level security;
alter table sponsor_inquiries enable row level security;
alter table camp_registrations enable row level security;

create policy "Allow anon insert" on volunteer_signups
  for insert to anon
  with check (true);

create policy "Allow anon insert" on sponsor_inquiries
  for insert to anon
  with check (true);

create policy "Allow anon insert" on camp_registrations
  for insert to anon
  with check (true);

grant insert on volunteer_signups to anon;
grant insert on sponsor_inquiries to anon;
grant insert on camp_registrations to anon;

-- Pickney Time games archive submissions ("Did You Play [Game]?" on each
-- of the 110 calendar/games/*.html pages). photo_path/video_path are
-- storage object paths within the `game-submissions` Storage bucket (not
-- full URLs) -- see the bucket/policy setup below. video_path is meant to
-- be TEMPORARY: staff review the submission, manually upload approved
-- videos to the org's YouTube channel, then update video_path to the
-- YouTube URL and delete the temp object from Storage (kept deliberately
-- small on the free tier's 1GB/50MB-per-file limits). Staff approve a
-- submission by setting status = 'approved' in the Table Editor (same
-- manual-review pattern as every other form on this site) -- approved rows
-- then appear automatically in each game's "Community Photos & Stories"
-- section via the game_submissions_public view below, no HTML editing
-- required.
create table if not exists game_submissions (
  id uuid primary key default gen_random_uuid(),
  game_slug text not null,
  game_name text not null,
  submitter_name text not null,
  submitter_email text,
  story_text text,
  photo_path text,
  video_path text,
  status text not null default 'pending_verification',
  created_at timestamptz not null default now()
);

alter table game_submissions enable row level security;

create policy "Allow anon insert" on game_submissions
  for insert to anon
  with check (true);

grant insert on game_submissions to anon;

-- Storage bucket for the above: photos stay long-term (served publicly so
-- approved ones can be linked from the static pages), videos are a
-- temporary staging area only (see comment above). 50MB matches Supabase's
-- own free-tier per-file cap, so there's no point allowing more.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'game-submissions', 'game-submissions', true, 52428800,
  array['image/jpeg','image/png','image/webp','image/heic','video/mp4','video/quicktime','video/webm']
)
on conflict (id) do nothing;

create policy "Allow anon insert to game-submissions" on storage.objects
  for insert to anon
  with check (bucket_id = 'game-submissions');

create policy "Allow public read of game-submissions" on storage.objects
  for select to anon
  using (bucket_id = 'game-submissions');

-- game_submissions itself has NO anon select policy (write-only, like every
-- other form table here) -- submitter_email in particular must never be
-- publicly readable. This view is the one sanctioned way anon can read
-- anything back: it drops submitter_email entirely and is pre-filtered to
-- approved rows only. Views run with the privileges of their owner by
-- default (not the querying role), so this correctly bypasses RLS on the
-- base table for just this narrow, already-filtered shape -- do not add
-- `security_invoker` to it, that would break the filtering.
create or replace view game_submissions_public as
select id, game_slug, game_name, submitter_name, story_text, photo_path, video_path, created_at
from game_submissions
where status = 'approved';

grant select on game_submissions_public to anon;

-- The Ital Marketplace email-capture form ("notify me about Ital menu
-- updates") reuses newsletter_subscribers rather than a dedicated table —
-- it's the same shape (just an email address) — tagged via `source` so it
-- can be told apart from the general newsletter signup. Existing rows get
-- source = null, meaning "general newsletter."
alter table newsletter_subscribers add column if not exists source text;

-- Email notifications: an AFTER INSERT trigger on each table above (plus
-- newsletter_subscribers — see below) calls the deployed `notify-submission`
-- Edge Function (supabase/functions/notify-submission/index.ts) via pg_net.
-- For every table except newsletter_subscribers, this emails the org
-- through Resend with the submission details. newsletter_subscribers is
-- the one exception: instead of notifying staff (which would be one email
-- per signup — too noisy), notify-submission special-cases that table and
-- sends a "you're on the list" confirmation to the subscriber's own email
-- instead (see notify-submission's TABLE_CONFIG). The trigger function is
-- intentionally NOT reproduced here: it embeds a shared webhook secret
-- (checked by the Edge Function to reject unauthenticated calls to its
-- public URL) that must never be committed to git. It was applied directly
-- against the database instead. If the function ever needs to be
-- recreated, see the (uncommitted) setup script referenced in the PR/
-- commit that introduced this feature, or regenerate it fresh: a plpgsql
-- function, security definer, that does
-- `perform net.http_post(url := '<function-url>', headers := jsonb_build_object('Content-Type','application/json','x-webhook-secret','<secret>'), body := jsonb_build_object('table', TG_TABLE_NAME, 'record', row_to_json(NEW)))`,
-- attached as an AFTER INSERT trigger on raffle_entries,
-- marketplace_preorders, volunteer_signups, sponsor_inquiries,
-- camp_registrations, newsletter_subscribers, and game_submissions. The
-- secret is also stored as the Edge Function's
-- WEBHOOK_SECRET environment secret (`supabase secrets set`).

-- ─────────────────────────────────────────────────────────────────────────
-- Stripe Checkout (marketplace payment + donations)
-- ─────────────────────────────────────────────────────────────────────────
-- Real payment now runs through the org's existing live Stripe account
-- (see the `stripe` schema below — the Stripe Sync Engine already mirrors
-- it here). The `create-checkout-session` Edge Function
-- (supabase/functions/create-checkout-session/index.ts) creates a Stripe
-- Checkout Session for either mode: 'marketplace' (ad-hoc line items from
-- the cart, metadata carries customer/pickup info + a compact items_json)
-- or mode: 'donation' (a dynamic price against one of the existing Stripe
-- products, one-time or recurring monthly).
--
-- Nothing is treated as a real order or donation until Stripe actually
-- confirms the charge. A trigger (handle_stripe_payment_succeeded,
-- intentionally NOT reproduced here for the same reason as
-- notify_submission_webhook above — it embeds the same webhook secret) sits
-- on stripe.payment_intents, fires only when status transitions to
-- 'succeeded', and branches on metadata->>'order_type':
--   - 'marketplace': inserts into marketplace_preorders (which then fires
--     the existing notify trigger above automatically — no separate
--     donation-specific insert/table needed).
--   - 'donation': calls notify-submission directly with a synthetic
--     table name ('stripe_donations') built from the payment intent's
--     amount/currency/receipt_email, since Stripe's own synced tables are
--     already the durable donation record — no app table required.
--
-- The trigger function wraps its entire body in an exception handler so a
-- bug in this app-specific logic can never fail the Stripe Sync Engine's
-- own insert/update of a table it owns, not this repo.

-- The `stripe` schema below is provisioned and owned by an external Stripe
-- sync tool (customers/charges/subscriptions/etc. tables), not by this repo,
-- so it is not represented here in full. These two trigger functions are
-- tracked in this file only because the Supabase Security Advisor flagged
-- them for a mutable search_path, and fixing that requires a full
-- CREATE OR REPLACE. Logic is unchanged from what is live in the database —
-- only `SET search_path = ''` was added. Neither function body references
-- any table or schema-qualified object (only pg_catalog builtins:
-- jsonb_populate_record, jsonb_build_object, now()), which are always
-- resolved regardless of search_path, so no qualification was needed.
create or replace function stripe.set_updated_at()
returns trigger
language plpgsql
set search_path = ''
as $function$
BEGIN
  -- Support both legacy "updated_at" and newer "_updated_at" columns.
  -- jsonb_populate_record silently ignores keys that are not present on NEW.
  NEW := jsonb_populate_record(
    NEW,
    jsonb_build_object(
      'updated_at', now(),
      '_updated_at', now()
    )
  );
  RETURN NEW;
END;
$function$;

create or replace function stripe.set_updated_at_metadata()
returns trigger
language plpgsql
set search_path = ''
as $function$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$function$;

-- ─────────────────────────────────────────────────────────────────────────
-- Chicago Dancehall Scene dashboard (password-gated, synced from Notion)
-- ─────────────────────────────────────────────────────────────────────────
-- Read-only mirror of the "Chicago Dancehall Scene" Notion database (a
-- separate community-tracking project from SelassieFest's own calendar
-- above), kept in sync by a scheduled Edge Function
-- (supabase/functions/sync-notion-dancehall/index.ts) that reads the Notion
-- API and upserts here on notion_page_id. Flattened (region/venue/promoter
-- as plain text, not FKs) since this is a one-way display mirror feeding a
-- chart, not a system that needs relational integrity of its own.
--
-- Restricted to the `authenticated` role only -- there is no anon policy at
-- all -- because this feeds the password-gated /chicago-dancehall/ page,
-- guarded by a single shared Supabase Auth login. The Edge Function itself
-- writes using the service role key (set as a function secret), which
-- bypasses RLS entirely, so no insert/update policy is needed here.
create table if not exists dancehall_occurrences (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  name text not null,
  occurrence_date date,
  region text,
  venue text,
  promoter text,
  status text,
  notes text,
  synced_at timestamptz not null default now()
);

create index if not exists dancehall_occurrences_date_idx on dancehall_occurrences (occurrence_date);

alter table dancehall_occurrences enable row level security;

create policy "Allow authenticated read" on dancehall_occurrences
  for select to authenticated
  using (true);

grant select on dancehall_occurrences to authenticated;

-- Kept in sync by a pg_cron job ('sync-notion-dancehall', every 3 hours)
-- that calls net.http_post against the deployed sync-notion-dancehall Edge
-- Function. The job is intentionally NOT reproduced here: it embeds a
-- shared x-sync-secret header value (checked by the Edge Function to reject
-- unauthenticated calls to its public URL) that must never be committed to
-- git -- same pattern as notify_submission_webhook above. It was applied
-- directly against the database instead. If it ever needs to be recreated:
-- `select cron.schedule('sync-notion-dancehall', '0 */3 * * *', $$ select
-- net.http_post(url := '<function-url>', headers := jsonb_build_object(
-- 'Content-Type','application/json','x-sync-secret','<secret>'), body :=
-- '{}'::jsonb); $$);`. The secret is also stored as the Edge Function's
-- SYNC_SECRET environment secret (`supabase secrets set`), alongside a
-- NOTION_TOKEN secret for the Notion integration used to read the source
-- "Chicago Dancehall Scene" database.

-- ─────────────────────────────────────────────────────────────────────────
-- Dancehall 101 free student ticketing (dh101_*)
-- ─────────────────────────────────────────────────────────────────────────
-- Dancehall 101 (weekly, Uptown Lounge) is TRC Events' signature event --
-- TRC Events being Ras Tafari Inc's marketing/promotion arm, a sibling brand
-- to SelassieFest, not a sub-feature of it. Originally hosted at
-- /dancehall101/ on selassiefest.com purely for convenience while TRC Events
-- had no site of its own; being rebuilt on trcevent.com against these same
-- tables (no schema changes needed for the move -- dh101_ prefix already
-- keeps this cluster fully separate from SelassieFest's own
-- event_series/event_occurrences tables). 21+ students at 20 partner schools
-- get free entry by verifying a .edu email; each gets a branded digital
-- ticket (QR + redemption code) unique to their school.
create table if not exists dh101_schools (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  name text not null,
  short_code text not null unique,      -- ticket prefix, e.g. 'SAIC' -> SAIC-000001
  edu_domains text[] not null,          -- lowercase, e.g. {'saic.edu'}
  -- NULL until a real logo file is confirmed cleared for this partner-
  -- listing use case (school's own official brand/press page, publicly
  -- downloadable, no login wall) and uploaded to the dh101-branding bucket.
  -- Most school logos are trademarked and many brand pages gate the actual
  -- files behind a login or an explicit "licensed vendors only" clause
  -- (checked individually per school -- do not assume a public brand page
  -- means the logo is cleared for this use). When null, the client renders
  -- a styled text wordmark (school name/short_code + colors) instead of an
  -- image -- see dancehall101/assets/dancehall101-client.js -- rather than
  -- a generic placeholder icon. IMPORTANT: a publicly-downloadable file is
  -- not automatically a clean logo -- always open and visually inspect the
  -- actual image before using it. DePaul's official brand-page PNG was
  -- caught (post-upload) to have a large "DO NOT USE" watermark baked into
  -- the image itself -- a purely text/terms-based check of the brand page
  -- would never catch that; only looking at the pixels does.
  logo_url text,
  -- Some official logo files are white-on-transparent, meant for a dark
  -- header on the school's own site (e.g. Columbia College Chicago's) --
  -- rendered invisible against this site's default light logo-badge
  -- background. 'light' (default) or 'dark' -- which backing color the
  -- client should use so a given school's specific file is actually
  -- visible. Check each file visually, don't assume 'light'.
  logo_bg text not null default 'light',
  color_primary text not null default '#0E5E36',
  color_secondary text not null default '#E5A93C',
  -- Only set for schools with a well-established, unambiguous athletics
  -- mascot/nickname (checked individually) -- left null rather than
  -- guessed for schools with no athletics program or an ambiguous/informal
  -- one. Used in landing-page copy to feel specific to that school instead
  -- of a generic reskin.
  mascot text,
  is_active boolean not null default true,
  default_campaign_code text,           -- e.g. 'SAIC-FALL26' -- the landing page reads this and auto-stamps it onto the signup row; update per-semester without touching any page code
  created_at timestamptz not null default now()
);

-- One row per school; advanced by dh101_next_ticket_id (below) via an atomic
-- UPDATE...RETURNING, never by a read-then-write from the client.
create table if not exists dh101_school_ticket_counters (
  school_id uuid primary key references dh101_schools(id) on delete cascade,
  next_seq int not null default 1
);

-- No email/contact column by design, so the whole table can be safely
-- anon-readable (public leaderboard + shareable-link display) with zero PII.
create table if not exists dh101_ambassadors (
  id uuid primary key default gen_random_uuid(),
  school_id uuid references dh101_schools(id) on delete cascade,
  code text not null unique,
  display_name text not null,
  created_at timestamptz not null default now()
);

-- ticket_id/redemption_code/verified_at are NEVER set by the client -- see
-- dh101_enforce_signup_rules below, which server-overwrites all of them on
-- every insert regardless of what anon sends. DOB/edu-email checks here are
-- a speed bump, not proof of age/enrollment; the real gate is door staff
-- checking physical ID against the name shown by dh101_check_in_ticket.
create table if not exists dh101_signups (
  id uuid primary key default gen_random_uuid(),
  school_id uuid not null references dh101_schools(id),
  full_name text not null,
  edu_email text not null,
  dob date not null,
  referral_code text,
  ambassador_id uuid references dh101_ambassadors(id),
  campaign_code text,
  student_segment text default 'UNDERGRAD',
  verification_token text unique,
  verification_token_expires_at timestamptz not null default (now() + interval '7 days'),
  verified_at timestamptz,
  ticket_id text unique,
  redemption_code text unique,
  checked_in boolean not null default false,
  checked_in_at timestamptz,
  created_at timestamptz not null default now(),
  check (edu_email ~* '@.+\.edu$'),
  check (dob <= (current_date - interval '21 years'))
);

create unique index if not exists dh101_signups_edu_email_uidx on dh101_signups (lower(edu_email));

-- Auto-seeds a counter row whenever a school is added.
create or replace function dh101_seed_counter()
returns trigger
language plpgsql
security definer
set search_path = ''
as $$
begin
  insert into public.dh101_school_ticket_counters (school_id) values (new.id)
  on conflict (school_id) do nothing;
  return new;
end;
$$;

drop trigger if exists dh101_schools_after_insert on dh101_schools;
create trigger dh101_schools_after_insert
  after insert on dh101_schools
  for each row execute function dh101_seed_counter();

-- Race-free sequential ticket ID. Never called at signup time -- only from
-- dh101_verify_and_get_ticket below, at first verification -- so spam/
-- duplicate/unverified inserts can never burn real sequence numbers. Note:
-- pgcrypto's functions live in the `extensions` schema on this project, so
-- with `set search_path = ''` (deliberate, prevents search-path hijacking)
-- gen_random_bytes must be called as extensions.gen_random_bytes -- an
-- unqualified call fails with "function gen_random_bytes does not exist"
-- even though the extension is enabled.
create or replace function dh101_next_ticket_id(p_school_id uuid)
returns text
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_seq int;
  v_code text;
begin
  update public.dh101_school_ticket_counters
    set next_seq = next_seq + 1
    where school_id = p_school_id
    returning next_seq - 1 into v_seq;

  if v_seq is null then
    raise exception 'no ticket counter row for school %', p_school_id;
  end if;

  select short_code into v_code from public.dh101_schools where id = p_school_id;

  return v_code || '-' || lpad(v_seq::text, 6, '0');
end;
$$;

-- IMPORTANT: `revoke ... from public` alone is NOT enough on this project --
-- Supabase's default-privilege scaffold auto-grants EXECUTE on every new
-- public-schema function directly to the anon/authenticated roles (a
-- separate grant from PUBLIC's), so anon could otherwise call this directly
-- and burn through real ticket sequence numbers. Revoke from anon and
-- authenticated explicitly, every time a function like this is added.
revoke execute on function dh101_next_ticket_id(uuid) from public, anon, authenticated;

-- Validates school is active + email domain match, and -- critically --
-- server-overwrites every verification/ticket/check-in field regardless of
-- client input, so anon can never forge a pre-verified/pre-checked-in row.
create or replace function dh101_enforce_signup_rules()
returns trigger
language plpgsql
set search_path = ''
as $$
declare
  v_domains text[];
  v_active boolean;
  v_email_domain text;
  v_ok boolean := false;
  v_d text;
begin
  select edu_domains, is_active into v_domains, v_active
  from public.dh101_schools where id = new.school_id;

  if v_domains is null then
    raise exception 'unknown school_id';
  end if;
  if not v_active then
    raise exception 'school is not currently accepting signups';
  end if;

  v_email_domain := lower(split_part(new.edu_email, '@', 2));
  foreach v_d in array v_domains loop
    if v_email_domain = v_d or v_email_domain like ('%.' || v_d) then
      v_ok := true;
    end if;
  end loop;
  if not v_ok then
    raise exception 'email domain % is not recognized for this school', v_email_domain;
  end if;

  new.verification_token := encode(extensions.gen_random_bytes(32), 'hex');
  new.verification_token_expires_at := now() + interval '7 days';
  new.verified_at := null;
  new.ticket_id := null;
  new.redemption_code := null;
  new.checked_in := false;
  new.checked_in_at := null;

  -- Silently null on a typo/garbage referral code -- no error, no leak of
  -- which codes are valid.
  if new.referral_code is not null then
    select id into new.ambassador_id from public.dh101_ambassadors where code = new.referral_code;
  end if;

  return new;
end;
$$;

drop trigger if exists dh101_signups_before_insert on dh101_signups;
create trigger dh101_signups_before_insert
  before insert on dh101_signups
  for each row execute function dh101_enforce_signup_rules();

revoke execute on function dh101_enforce_signup_rules() from public, anon, authenticated;
revoke execute on function dh101_seed_counter() from public, anon, authenticated;

alter table dh101_schools enable row level security;
alter table dh101_ambassadors enable row level security;
alter table dh101_signups enable row level security;

-- Granted to BOTH anon and authenticated, deliberately -- there is no PII
-- in either table, so there is no reason to restrict this to a role. This
-- matters in practice: supabase-js persists an auth session in localStorage
-- for the whole selassiefest.com origin, not scoped per-subpath, so anyone
-- who has ever logged into /chicago-dancehall/ or /dancehall101/checkin/ in
-- the same browser will be treated as `authenticated` on every other page
-- on the site afterward, including the public /dancehall101/ picker/landing
-- pages. An anon-only policy here would silently 404 the schools list for
-- exactly that visitor (a real bug hit once already -- door staff testing
-- check-in, then browsing the public signup flow in the same browser, saw
-- zero schools).
create policy "anon read active schools" on dh101_schools
  for select to anon
  using (is_active);

create policy "authenticated read active schools" on dh101_schools
  for select to authenticated
  using (is_active);

create policy "anon read ambassadors" on dh101_ambassadors
  for select to anon
  using (true);

create policy "authenticated read ambassadors" on dh101_ambassadors
  for select to authenticated
  using (true);

-- No select/update policy at all on dh101_signups, for anon OR
-- authenticated -- every read/write beyond the initial insert goes through
-- the security-definer functions/view below instead.
create policy "anon insert signups" on dh101_signups
  for insert to anon
  with check (true);

grant select on dh101_schools to anon, authenticated;
grant select on dh101_ambassadors to anon, authenticated;
grant insert on dh101_signups to anon;

-- Verification RPC: looks up by token, checks expiry (only matters
-- pre-first-verification -- once verified the token stays valid forever for
-- re-viewing the ticket, since it's the student's only credential and the
-- real redemption credential checked at the door is ticket_id/QR, not this
-- token), atomically flips verified_at exactly once (guards against e.g. an
-- email client's link-preview prefetch racing the real click), and mints
-- the ticket_id/redemption_code only on the row that won that race. Returns
-- only the safe-to-display fields -- never verification_token itself.
create or replace function dh101_verify_and_get_ticket(p_token text)
returns table (
  status text,
  ticket_id text,
  redemption_code text,
  full_name text,
  school_slug text,
  school_name text,
  school_logo_url text,
  school_logo_bg text,
  school_mascot text,
  color_primary text,
  color_secondary text,
  campaign_code text,
  student_segment text,
  verified_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_school_id uuid;
  v_expires timestamptz;
  v_verified timestamptz;
  v_claimed int;
begin
  select s.id, s.school_id, s.verification_token_expires_at, s.verified_at
    into v_id, v_school_id, v_expires, v_verified
  from public.dh101_signups s where s.verification_token = p_token;

  if v_id is null then
    return query select 'not_found'::text, null::text, null::text, null::text, null::text,
      null::text, null::text, null::text, null::text, null::text, null::text, null::text, null::text, null::timestamptz;
    return;
  end if;

  if v_verified is null and now() > v_expires then
    return query select 'expired'::text, null::text, null::text, null::text, null::text,
      null::text, null::text, null::text, null::text, null::text, null::text, null::text, null::text, null::timestamptz;
    return;
  end if;

  -- Table alias `s` is required in this UPDATE's WHERE clause: a bare
  -- `verified_at` is ambiguous between the table column and the RETURNS
  -- TABLE's implicit `verified_at` OUT-parameter variable of the same name.
  update public.dh101_signups s set verified_at = now()
    where s.id = v_id and s.verified_at is null;
  get diagnostics v_claimed = row_count;

  if v_claimed > 0 then
    update public.dh101_signups s
      set ticket_id = public.dh101_next_ticket_id(v_school_id),
          redemption_code = upper(substr(encode(extensions.gen_random_bytes(6), 'hex'), 1, 8))
      where s.id = v_id;
  end if;

  return query
    select 'ok'::text, s.ticket_id, s.redemption_code, s.full_name, sc.slug, sc.name, sc.logo_url,
           sc.logo_bg, sc.mascot, sc.color_primary, sc.color_secondary, s.campaign_code, s.student_segment, s.verified_at
    from public.dh101_signups s join public.dh101_schools sc on sc.id = s.school_id
    where s.id = v_id;
end;
$$;

revoke execute on function dh101_verify_and_get_ticket(text) from public;
grant execute on function dh101_verify_and_get_ticket(text) to anon;

-- Door check-in: deliberately NOT a broad `authenticated` grant on the base
-- table -- dh101_signups holds edu_email/dob/verification_token, more
-- sensitive than the read-only dancehall_occurrences table guarded the same
-- way for /chicago-dancehall/. A shared door-staff password is the kind of
-- credential that ends up screenshotted/texted around; if it leaks, a broad
-- grant would hand over every student's PII and let someone rewrite
-- ticket_id/verified_at arbitrarily. This RPC also solves the "two staff
-- scan the same code at once" race via one atomic guarded UPDATE.
create or replace function dh101_check_in_ticket(p_code text)
returns table (
  status text,
  ticket_id text,
  full_name text,
  school_name text,
  checked_in_at timestamptz
)
language plpgsql
security definer
set search_path = ''
as $$
declare
  v_id uuid;
  v_verified timestamptz;
  v_rows int;
begin
  select s.id, s.verified_at into v_id, v_verified
  from public.dh101_signups s where s.ticket_id = p_code or s.redemption_code = p_code;

  if v_id is null then
    return query select 'not_found'::text, null::text, null::text, null::text, null::timestamptz;
    return;
  end if;

  if v_verified is null then
    return query select 'not_verified'::text, s.ticket_id, s.full_name, sc.name, null::timestamptz
      from public.dh101_signups s join public.dh101_schools sc on sc.id = s.school_id where s.id = v_id;
    return;
  end if;

  update public.dh101_signups s set checked_in = true, checked_in_at = now()
    where s.id = v_id and s.checked_in = false;
  get diagnostics v_rows = row_count;

  return query
    select (case when v_rows > 0 then 'checked_in' else 'already_checked_in' end)::text,
           s.ticket_id, s.full_name, sc.name, s.checked_in_at
    from public.dh101_signups s join public.dh101_schools sc on sc.id = s.school_id where s.id = v_id;
end;
$$;

-- See the dh101_next_ticket_id comment above -- `from public` alone leaves
-- anon's separate default-privilege grant intact, so it must be revoked
-- explicitly too, even though only `authenticated` should ever call this.
revoke execute on function dh101_check_in_ticket(text) from public, anon;
grant execute on function dh101_check_in_ticket(text) to authenticated;

-- Read-only browse/search for door staff (e.g. name lookup when a phone is
-- dead) -- deliberately omits edu_email/dob/verification_token.
create or replace view dh101_door_checkin as
select s.id, s.ticket_id, s.redemption_code, s.full_name, sc.name as school_name,
  (s.verified_at is not null) as is_verified, s.checked_in, s.checked_in_at,
  s.campaign_code, s.student_segment, s.created_at
from dh101_signups s join dh101_schools sc on sc.id = s.school_id;

grant select on dh101_door_checkin to authenticated;

-- School logos. No anon insert policy -- staff upload via the Supabase
-- dashboard, not client code (unlike game-submissions, there's no
-- legitimate anon-write use case here).
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('dh101-branding', 'dh101-branding', true, 5242880,
  array['image/png','image/jpeg','image/webp','image/svg+xml'])
on conflict (id) do nothing;

create policy "public read dh101-branding" on storage.objects
  for select to anon
  using (bucket_id = 'dh101-branding');

-- Public ambassador leaderboard: counts only, zero signup PII (no name/
-- email/dob ever selected here), safe for anon.
create or replace view dh101_ambassador_leaderboard as
select a.id as ambassador_id, a.code, a.display_name, a.school_id, sc.slug as school_slug, sc.name as school_name,
  count(s.id) as signup_count
from dh101_ambassadors a
join dh101_schools sc on sc.id = a.school_id
left join dh101_signups s on s.ambassador_id = a.id
group by a.id, a.code, a.display_name, a.school_id, sc.slug, sc.name;

grant select on dh101_ambassador_leaderboard to anon;

-- ─────────────────────────────────────────────────────────────────────────
-- Chicago Dancehall Oscars -- production dashboard (password-gated mirror)
-- ─────────────────────────────────────────────────────────────────────────
-- Read-only mirror of the "Chicago Dancehall Oscars -- Master Production
-- Bible" Notion workspace (a separate internal planning tool from the
-- public-facing dh101_*/dancehall_occurrences data above), kept in sync by
-- a scheduled Edge Function (supabase/functions/sync-notion-oscars/
-- index.ts). Feeds a password-gated page for the small production team --
-- NOT public-facing.
--
-- Deliberately AUTHENTICATED-ONLY on every table below, no anon policy at
-- all -- unlike dh101_schools/event_series (public calendar/signup data),
-- this is internal production-planning content: real team member names,
-- unconfirmed sponsor/nominee talks, task assignments. This matches the
-- ORIGINAL dancehall_occurrences pattern from the /chicago-dancehall/
-- build, not the anon+authenticated pattern used for public tables.
create table if not exists oscars_timeline (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  task text not null,
  phase text,
  owner text,
  due_date date,
  status text,
  notes text,
  synced_at timestamptz not null default now()
);

create table if not exists oscars_team (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  name text not null,
  organization text,
  role text,
  email text,
  phone text,
  raci_nominations text,
  raci_production text,
  raci_marketing text,
  raci_sponsors text,
  notes text,
  synced_at timestamptz not null default now()
);

create table if not exists oscars_categories (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  category text not null,
  segment text,
  description text,
  synced_at timestamptz not null default now()
);

create table if not exists oscars_nominees (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  name text not null,
  category_notion_id text,
  category_name text,
  is_finalist boolean,
  public_votes int,
  is_winner boolean,
  notes text,
  synced_at timestamptz not null default now()
);

create table if not exists oscars_sponsors (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  sponsor text not null,
  touchpoint text,
  status text,
  contact text,
  value text,
  synced_at timestamptz not null default now()
);

create table if not exists oscars_risks (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  risk text not null,
  likelihood text,
  impact text,
  mitigation text,
  owner text,
  synced_at timestamptz not null default now()
);

create table if not exists oscars_run_of_show (
  id uuid primary key default gen_random_uuid(),
  notion_page_id text not null unique,
  segment text not null,
  time_label text,
  duration_min int,
  owner text,
  notes text,
  synced_at timestamptz not null default now()
);

-- Applies RLS uniformly across all 7 tables above via a loop, rather than
-- repeating the same three statements seven times.
do $$
declare
  t text;
begin
  foreach t in array array['oscars_timeline','oscars_team','oscars_categories','oscars_nominees','oscars_sponsors','oscars_risks','oscars_run_of_show']
  loop
    execute format('alter table %I enable row level security', t);
    execute format('create policy "Allow authenticated read" on %I for select to authenticated using (true)', t);
    execute format('grant select on %I to authenticated', t);
  end loop;
end $$;

-- Kept in sync by a pg_cron job ('sync-notion-oscars', every 3 hours) that
-- calls net.http_post against the deployed sync-notion-oscars Edge
-- Function. Same not-reproduced-here pattern as sync-notion-dancehall's
-- job (embeds a shared x-sync-secret header value that must never be
-- committed to git) -- applied directly against the database instead. If
-- it ever needs to be recreated: `select cron.schedule('sync-notion-
-- oscars', '0 */3 * * *', $$ select net.http_post(url := '<function-url>',
-- headers := jsonb_build_object('Content-Type','application/json',
-- 'x-sync-secret','<secret>'), body := '{}'::jsonb); $$);`. Reuses the same
-- SYNC_SECRET and NOTION_TOKEN Edge Function secrets already set for
-- sync-notion-dancehall (shared across functions in this project).

-- ─────────────────────────────────────────────────────────────────────────
-- Event "notify me when tickets go live" signups
-- ─────────────────────────────────────────────────────────────────────────
-- Reusable across any TRC/SelassieFest event's ticket waitlist, rather than
-- a one-off table per event (first use: Charly Black — Good Times, on
-- trcevent.com, added because that page had no way to capture a ready-to-
-- buy visitor while its real ticket links weren't live yet).
--
-- event_name and brand are denormalized here (rather than joined against
-- event_series at notify time) so notify-submission's Edge Function can
-- build the confirmation email and pick the right "from" display name
-- without needing its own Supabase client/query.
create table if not exists event_notify_signups (
  id uuid primary key default gen_random_uuid(),
  event_slug text not null references event_series(slug),
  event_name text not null,
  brand text not null check (brand in ('trc', 'selassiefest')),
  email text not null,
  created_at timestamptz not null default now(),
  unique (event_slug, email)
);

alter table event_notify_signups enable row level security;

-- Public form, submits with the anon key. Only INSERT is granted -- no
-- SELECT policy, so the anon key can never read back other people's
-- signups. Same pattern as newsletter_subscribers/anansi_story_submissions
-- above.
create policy "Allow anon insert" on event_notify_signups
  for insert to anon
  with check (true);

grant insert on event_notify_signups to anon;

-- Reuses the existing notify_submission_webhook() function (already live
-- in the database with its webhook secret embedded -- see the
-- notify-submission section above) rather than redefining it, so no
-- secret needs to be committed here.
create trigger event_notify_signups_after_insert
  after insert on event_notify_signups
  for each row execute function notify_submission_webhook();

-- ─────────────────────────────────────────────────────────────────────────
-- Ticket Tailor event setup (internal collaborative form, /ticket-event-setup/)
-- ─────────────────────────────────────────────────────────────────────────
-- A dedicated intake tool: several staff fill in different fields of the
-- same in-progress event over time (venue, dates, ticket tiers, images,
-- etc.), and an admin/Ticket Tailor operator later transfers the finished
-- draft into Ticket Tailor by hand. Unlike every write-only form above,
-- this needs real read+write for the team (autosave per field, live
-- multi-editor sync).
--
-- Originally gated behind its own Supabase Auth login (one specific
-- account's email); removed by request for zero-friction team access --
-- open to anon, no login at all. This means anyone who has the
-- /ticket-event-setup/ URL can read, edit, or delete any draft or upload
-- images to it; there's no access check beyond the URL itself not being
-- linked from anywhere public. Revisit if this page's link ever leaks or
-- needs to be shared outside the immediate team.
create table if not exists ticket_event_drafts (
  id uuid primary key default gen_random_uuid(),
  event_name text,
  event_description text,
  venue_name text,
  venue_address text,
  event_date date,
  start_time text,
  end_time text,
  time_zone text not null default 'Central',
  is_recurring boolean not null default false,
  recurrence_note text,
  promo_codes_needed text,
  booking_fee_handling text,
  age_restriction text,
  refund_policy text,
  custom_checkout_questions text,
  confirmation_message text,
  event_image_path text,
  organizer_logo_path text,
  status text not null default 'draft'
    check (status in ('draft', 'ready_for_ticket_tailor', 'entered_in_ticket_tailor')),
  last_edited_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- One row per ticket tier (GA, VIP, Early Bird, ...) for a draft -- the
-- fill-in sheet's "repeat this block for each tier" becomes repeatable
-- child rows instead of a fixed set of columns.
create table if not exists ticket_event_ticket_types (
  id uuid primary key default gen_random_uuid(),
  draft_id uuid not null references ticket_event_drafts(id) on delete cascade,
  sort_order int not null default 0,
  ticket_name text,
  price numeric(10,2),
  quantity_available int,
  min_per_order int,
  max_per_order int,
  sale_start timestamptz,
  sale_end timestamptz,
  ticket_description text,
  last_edited_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table ticket_event_drafts enable row level security;
alter table ticket_event_ticket_types enable row level security;

-- No login gate anymore -- open to anon (see the page's own comment for
-- why: the team wanted zero login friction and accepted that this means
-- anyone with the URL can read/edit/delete any draft, relying on the link
-- staying unlinked/unshared for privacy rather than a real access check).
-- `drop policy if exists` on the old email-gated names so this file stays
-- re-runnable whether it's a fresh install or an upgrade from the earlier
-- password-gated version.
drop policy if exists "ticket setup account full access" on ticket_event_drafts;
drop policy if exists "ticket setup account full access" on ticket_event_ticket_types;

create policy "public full access" on ticket_event_drafts
  for all to anon, authenticated
  using (true)
  with check (true);

create policy "public full access" on ticket_event_ticket_types
  for all to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on ticket_event_drafts to anon, authenticated;
grant select, insert, update, delete on ticket_event_ticket_types to anon, authenticated;

-- The editor page subscribes to postgres_changes (Supabase Realtime) on
-- both tables so teammates editing the same draft see each other's fields
-- update live. That requires the tables to be added to the
-- `supabase_realtime` publication -- wrapped in existence checks so this
-- file stays safely re-runnable, matching the rest of this schema.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'ticket_event_drafts'
  ) then
    alter publication supabase_realtime add table ticket_event_drafts;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'ticket_event_ticket_types'
  ) then
    alter publication supabase_realtime add table ticket_event_ticket_types;
  end if;
end $$;

-- Event promo image + organizer logo uploads. Public read/write -- same
-- no-login-gate tradeoff as the tables above.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('ticket-event-images', 'ticket-event-images', true, 10485760,
  array['image/jpeg','image/png','image/webp'])
on conflict (id) do nothing;

drop policy if exists "ticket setup account upload images" on storage.objects;
drop policy if exists "ticket setup account manage images" on storage.objects;
drop policy if exists "ticket setup account delete images" on storage.objects;

create policy "public upload ticket-event-images" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'ticket-event-images');

create policy "public manage ticket-event-images" on storage.objects
  for update to anon, authenticated
  using (bucket_id = 'ticket-event-images');

create policy "public delete ticket-event-images" on storage.objects
  for delete to anon, authenticated
  using (bucket_id = 'ticket-event-images');

drop policy if exists "public read of ticket-event-images" on storage.objects;

create policy "public read of ticket-event-images" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'ticket-event-images');

-- ─────────────────────────────────────────────────────────────────────────
-- Heritage Village vendor applications (contact/vendorpackage.html)
-- ─────────────────────────────────────────────────────────────────────────
-- Previously only a mailto: link, same "relies on the visitor having a
-- desktop mail client configured" problem as volunteer/sponsor/camp forms
-- had before their own tables above -- and in this case it silently did
-- nothing at all for visitors with no mail client registered. logo_path and
-- photo_paths are storage object paths within the vendor-applications
-- bucket (not full URLs), same convention as game_submissions.photo_path.
create table if not exists vendor_applications (
  id uuid primary key default gen_random_uuid(),
  business_name text not null,
  contact_email text not null,
  product_description text not null,
  webpage_highlight text,
  marketing_plan text not null,
  preferred_space text,
  logo_path text,
  photo_paths text[] not null default '{}',
  status text not null default 'pending_review',
  created_at timestamptz not null default now()
);

alter table vendor_applications enable row level security;

-- Same write-only pattern as every other public form table above: anon can
-- insert an application but never read one back (business_name/email stay
-- private to the org, reviewed via the Supabase Table Editor).
create policy "Allow anon insert" on vendor_applications
  for insert to anon
  with check (true);

grant insert on vendor_applications to anon;

-- Reuses the existing notify_submission_webhook() function (see the
-- notify-submission section above) rather than redefining it, so no secret
-- needs to be committed here. Staff should add vendor_applications to
-- notify-submission's TABLE_CONFIG (see supabase/functions/notify-submission)
-- the same way the other tables using this trigger already are.
create trigger vendor_applications_after_insert
  after insert on vendor_applications
  for each row execute function notify_submission_webhook();

-- Business logo + product photos. Public read (so an accepted vendor's
-- photos can eventually be shown on their dedicated webpage per the
-- package's "What We Provide" promise), anon insert only -- same shape as
-- the game-submissions bucket above. 10MB/file matches ticket-event-images
-- rather than game-submissions' 50MB, since these are static photos, not
-- video.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'vendor-applications', 'vendor-applications', true, 10485760,
  array['image/jpeg','image/png','image/webp','image/heic']
)
on conflict (id) do nothing;

create policy "Allow anon insert to vendor-applications" on storage.objects
  for insert to anon
  with check (bucket_id = 'vendor-applications');

create policy "Allow public read of vendor-applications" on storage.objects
  for select to anon
  using (bucket_id = 'vendor-applications');

-- ─────────────────────────────────────────────────────────────────────────
-- Security guard contract e-sign (/contracts/security-guard-2026-07-25.html)
-- ─────────────────────────────────────────────────────────────────────────
-- One-off vendor-facing e-sign page for the July 25, 2026 gate security
-- contract. The vendor fills in their company info and types a signature;
-- the page generates a signed PDF client-side and uploads it here. Unlike
-- every other form table above, there is no public-facing reason for this
-- one to exist beyond routing the signed copy to Stephen -- see the
-- notify-submission TABLE_CONFIG entry, which emails stephen@selassiefest.com
-- (not the general NOTIFY_TO inbox) with the PDF attached.
create table if not exists security_guard_contracts (
  id uuid primary key default gen_random_uuid(),
  vendor_company_name text not null,
  vendor_address text,
  vendor_contact text,
  guard_names text,
  signer_name text not null,
  signer_title text,
  pdf_path text not null,
  created_at timestamptz not null default now()
);

alter table security_guard_contracts enable row level security;

create policy "Allow anon insert" on security_guard_contracts
  for insert to anon
  with check (true);

grant insert on security_guard_contracts to anon;

-- Reuses the existing notify_submission_webhook() function (see the
-- notify-submission section above) rather than redefining it, so no secret
-- needs to be committed here.
create trigger security_guard_contracts_after_insert
  after insert on security_guard_contracts
  for each row execute function notify_submission_webhook();

-- Signed PDF copies. Deliberately private (public = false, no anon select
-- policy) -- this is a signed business contract, not user-facing content
-- like the other buckets above. Anon can only insert (the signing page
-- uploads directly with the anon key); the notify-submission Edge Function
-- reads it back with the auto-injected service role key, which bypasses RLS.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('security-guard-contracts', 'security-guard-contracts', false, 5242880, array['application/pdf'])
on conflict (id) do nothing;

create policy "Allow anon insert to security-guard-contracts" on storage.objects
  for insert to anon
  with check (bucket_id = 'security-guard-contracts');

-- ─────────────────────────────────────────────────────────────────────────
-- Main Stage DJ run-of-show (/run-of-show/, internal production tool)
-- ─────────────────────────────────────────────────────────────────────────
-- Same "no login, anyone with the link can edit, last write wins" tradeoff
-- as ticket_event_drafts above -- a small production team coordinating one
-- show, not a general-purpose doc editor. slug (not id) is what seeding
-- below keys off of, so re-running this file is safe.
--
-- The whole point of this tool: the DJ lineup isn't 6 fixed people in 6
-- fixed slots -- times are approximate and a selector may swap chapters
-- day-of, so every selector should be "warmed up" on at least 2, ideally 3
-- chapters, not just the one they're nominally scheduled for. chapter_djs
-- is the many-to-many that makes that visible: a chapter can list several
-- prepared selectors, and a selector can appear under several chapters.
-- role distinguishes "who's actually slated to play this chapter" (primary)
-- from "warmed up and ready if needed" (backup).
create table if not exists run_of_show_chapters (
  id uuid primary key default gen_random_uuid(),
  slug text not null unique,
  sort_order int not null default 0,
  chapter_label text,       -- e.g. "Chapter 1" -- kept as free text, not an auto-numbered column, since chapters can be inserted/reordered
  title text not null,      -- e.g. "The Foundation"
  time_label text,          -- free text, e.g. "4:00-4:30 PM" -- deliberately not a real time range, since times are approximate and this is edited as a label, not scheduled
  musical_direction text,
  description text,
  notes text,
  last_edited_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create table if not exists run_of_show_chapter_djs (
  id uuid primary key default gen_random_uuid(),
  chapter_id uuid not null references run_of_show_chapters(id) on delete cascade,
  dj_name text not null,
  role text not null default 'primary' check (role in ('primary', 'backup')),
  sort_order int not null default 0,
  notes text,
  last_edited_by text,
  created_at timestamptz not null default now(),
  unique (chapter_id, dj_name)
);

alter table run_of_show_chapters enable row level security;
alter table run_of_show_chapter_djs enable row level security;

-- Deliberately open to anon AND authenticated, no login gate at all -- same
-- tradeoff as ticket_event_drafts/ticket_event_ticket_types above (the team
-- wanted zero-friction access via a shared link, not per-member accounts).
create policy "public full access" on run_of_show_chapters
  for all to anon, authenticated
  using (true)
  with check (true);

create policy "public full access" on run_of_show_chapter_djs
  for all to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on run_of_show_chapters to anon, authenticated;
grant select, insert, update, delete on run_of_show_chapter_djs to anon, authenticated;

-- Live multi-editor sync, same as ticket_event_drafts/ticket_event_ticket_types.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'run_of_show_chapters'
  ) then
    alter publication supabase_realtime add table run_of_show_chapters;
  end if;

  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'run_of_show_chapter_djs'
  ) then
    alter publication supabase_realtime add table run_of_show_chapter_djs;
  end if;
end $$;

-- Seed tonight's proposed running order, reframed around Bob Marley's
-- discography (revised 2026-07-21): each chapter maps to an era of his
-- studio/live catalog, anchored by the fact that "War" (Rastaman
-- Vibration, 1976) sets Emperor Haile Selassie I's 1963 UN address to
-- music almost verbatim -- the clearest direct Marley/Selassie thread.
-- on conflict (slug) do nothing keeps this re-runnable -- once the team
-- starts editing in the tool, this INSERT becomes a no-op forever (it will
-- never overwrite live edits, even a deliberate content revision like this
-- one -- that was applied directly against the database instead, same as
-- every other one-off content change in this file).
insert into run_of_show_chapters (slug, sort_order, chapter_label, title, time_label, musical_direction, description, notes)
values
  ('foundation', 1, 'Chapter 1', 'The Wailing Wailers', '4:00-4:30 PM', 'Foundation ska, rocksteady, and early roots — the raw, rebellious sound of Trench Town before the world knew the name Rastafari.', 'Where the story begins. The Wailing Wailers (1965), Soul Rebels (1970), and Soul Revolution (1971) — three young voices laying the rhythmic and spiritual foundation everything after is built on.', 'Reference albums: The Wailing Wailers (1965), Soul Rebels (1970), Soul Revolution (1971), The Best of the Wailers (1971).'),
  ('revival', 2, 'Chapter 2', 'Catch a Fire & Burnin''', '4:30-5:15 PM', 'The Wailers go international — raw roots reggae and righteous fire. "Get Up, Stand Up," "I Shot the Sheriff," "Concrete Jungle," "Burnin'' and Lootin''."', 'The message leaves Jamaica and reaches the world — reggae''s message of justice, unity, and hope, carried by the modern generation.', 'Reference albums: Catch a Fire (1973), Burnin'' (1973). Also: Talkin'' Blues (1991), archival live/interview material from this era, released posthumously.'),
  ('rastafari-message', 3, 'Chapter 3', 'Natty Dread & Rastaman Vibration', '5:15-6:00 PM', 'Deep roots and Rastafari consciousness. "War" lifts its lyrics directly from Emperor Haile Selassie I''s 1963 address to the United Nations — the clearest bridge between Bob Marley''s music and His Imperial Majesty''s own words.', 'Why the music exists — Rastafari faith, African identity, and liberation theology, spoken plainly.', 'Reference albums: Natty Dread (1974), Rastaman Vibration (1976), plus the live album Live! (1975), recorded on the Natty Dread tour. Selassie connection: "War" (Rastaman Vibration) sets Emperor Haile Selassie I''s 1963 UN address to music, nearly word for word.'),
  ('celebration-of-the-people', 4, 'Chapter 4', 'Exodus & Kaya', '6:30-7:15 PM', 'Exile, movement, and joy — "Exodus," "Jamming," "Is This Love," "One Love." Uplifting reggae, lovers rock, sing-alongs, cultural anthems, positive dancehall. Keep the energy rising without abandoning the festival''s mission.', 'The culture in everyday life — even written in exile after the 1976 assassination attempt, this music turns toward love, unity, and celebration.', 'Reference albums: Exodus (1977), Kaya (1978), plus the live album Babylon by Bus (1978).'),
  ('fire-of-the-lion', 5, 'Chapter 5', 'Survival & Uprising', '7:15-8:00 PM', 'Pan-African liberation and righteous resistance — "Zimbabwe," "Africa Unite," "Redemption Song," "Could You Be Loved." High-energy conscious reggae and roots-influenced dancehall centered on righteousness, African pride, resistance, and empowerment. Dubplates are welcome if they support the message rather than overshadow it.', 'The strength, resilience, and spirit of the movement — Marley''s most overtly Pan-Africanist, activist chapter.', 'Reference albums: Survival (1979), Uprising (1980).'),
  ('one-love-one-people-one-africa', 6, 'Chapter 6', 'Confrontation & Legend', '9:25-10:00 PM', '"Buffalo Soldier," "Chant Down Babylon," "Redemption Song" reprise — a collaborative finale for all selectors together.', 'The message outlives the man. Confrontation (1983), released after Marley''s passing, and Legend (1984) — the best-selling reggae album of all time — carried his message, and Emperor Haile Selassie I''s, to generations who never saw him perform live. A collaborative finale celebrating unity, freedom, and that enduring legacy.', 'Reference albums: Confrontation (1983, posthumous). Legacy: Legend (1984), the best-selling reggae album of all time.')
on conflict (slug) do nothing;

-- dj_name/role below reflect the current live roster as of 2026-07-21
-- (Donavan was originally seeded as "St. Louis"; Prestige Sound was added
-- directly in the tool, not by this seed, but is included here so a fresh
-- install matches reality). Each chapter's description field in the live
-- table also carries a bulleted "other artists/albums of this era" list and
-- notable-cover notes -- not mirrored in the short seed text below to keep
-- this file readable; see the live table for the full curated content.
insert into run_of_show_chapter_djs (chapter_id, dj_name, role, sort_order)
select c.id, v.dj_name, v.role, v.sort_order
from (values
  ('foundation', 'Tallas', 'primary', 1),
  ('revival', 'Donavan', 'primary', 1),
  ('rastafari-message', 'Innovation', 'primary', 1),
  ('rastafari-message', 'Prestige Sound', 'backup', 2),
  ('celebration-of-the-people', 'Money Movements', 'primary', 1),
  ('fire-of-the-lion', 'Fatta Fyah', 'primary', 1),
  ('one-love-one-people-one-africa', 'Tallas', 'primary', 1),
  ('one-love-one-people-one-africa', 'Donavan', 'primary', 2),
  ('one-love-one-people-one-africa', 'Innovation', 'primary', 3),
  ('one-love-one-people-one-africa', 'Money Movements', 'primary', 4),
  ('one-love-one-people-one-africa', 'Fatta Fyah', 'primary', 5),
  ('one-love-one-people-one-africa', 'Prestige Sound', 'primary', 6)
) as v(chapter_slug, dj_name, role, sort_order)
join run_of_show_chapters c on c.slug = v.chapter_slug
on conflict (chapter_id, dj_name) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- SelassieFest 2027 proposal — per-person editable notes
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
-- The named contacts/committee members in the 2027 site-use proposal (DCASE's
-- Camille and Jackie, Park District's Denise, Alderman Pat Powell's office,
-- community committee members Denise and Diedra, and Brother JahSyll) each
-- get one editable note directly on the page. section_key is the natural
-- key (one row per named block), matching run_of_show_chapters' slug
-- pattern above. Same "no login, anyone with the link can edit, last write
-- wins" tradeoff as ticket_event_drafts/run_of_show_chapters -- this is a
-- small known group updating their own notes, not a general-purpose doc
-- editor open to the public web.
create table if not exists proposal_2027_sections (
  section_key text primary key,
  label text not null,
  content text not null default '',
  last_edited_by text,
  updated_at timestamptz not null default now()
);

alter table proposal_2027_sections enable row level security;

create policy "public full access" on proposal_2027_sections
  for all to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on proposal_2027_sections to anon, authenticated;

-- Live multi-editor sync, same as ticket_event_drafts/run_of_show_chapters.
do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'proposal_2027_sections'
  ) then
    alter publication supabase_realtime add table proposal_2027_sections;
  end if;
end $$;

-- Seed with the current draft text from the page itself, so a fresh
-- install matches what's already live. on conflict (section_key) do nothing
-- keeps this re-runnable and never overwrites a real edit made in the tool.
insert into proposal_2027_sections (section_key, label, content)
values
  ('contact_camille', 'Camille — DCASE', 'Special event permitting & coordination contact'),
  ('contact_jackie', 'Jackie — DCASE', 'Cultural programming & community engagement contact'),
  ('contact_denise_park', 'Denise — Chicago Park District', 'Permits & park operations liaison for Washington Park — also serves on our community planning committee (see below)'),
  ('contact_alderman', 'Office of Alderman Pat Powell — 3rd Ward', 'Aldermanic support & community notification for events in Washington Park'),
  ('committee_bio', 'Denise & Diedra — bio', 'Both attended the original SelassieFest during its 1981-1997 run and describe it as a profound cultural experience Chicago hasn''t seen replicated since. When asked directly whether they wanted to be part of bringing it back, the answer from both was immediate and unprompted: "I needed this."

They''ve since joined the planning committee for the 2027 revival — not as honorary guests, but as working members helping shape site logistics, programming, and community outreach — driven by wanting their grandchildren to have the same experience they did.'),
  ('committee_quote', 'Denise & Diedra — quote', 'This isn''t nostalgia for its own sake. Something real happened here between 1981 and 1997, and it''s been missing ever since. We want our grandchildren to feel what we felt.'),
  ('jahsyll_note', 'Brother JahSyll', 'Brother JahSyll brought the 2026 historical display and has since agreed to join the SelassieFest organizing body for 2027 — adding a direct cultural/historical resource to the planning team alongside Denise and Diedra''s lived-experience perspective.')
on conflict (section_key) do nothing;

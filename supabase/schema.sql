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

-- Voice notes: each editable section can carry one recorded audio note (a
-- "voice note" button next to the text edit button) in place of, or
-- alongside, typing a text edit. voice_note_path is a storage object path
-- within the proposal-voice-notes bucket below (not a full URL), same
-- convention as game_submissions.photo_path.
alter table proposal_2027_sections add column if not exists voice_note_path text;

-- Public bucket (so the recorded note can be played back by anyone viewing
-- the page, no auth) -- anon can upload (the page records with the anon
-- key) and read. 10MB/file is plenty for a short spoken note; MediaRecorder
-- output is typically audio/webm, but Safari/iOS may produce audio/mp4, so
-- both (plus a couple of other common encodings) are allowed.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'proposal-voice-notes', 'proposal-voice-notes', true, 10485760,
  array['audio/webm', 'audio/ogg', 'audio/mp4', 'audio/mpeg', 'audio/wav', 'audio/x-m4a']
)
on conflict (id) do nothing;

create policy "Allow anon insert to proposal-voice-notes" on storage.objects
  for insert to anon
  with check (bucket_id = 'proposal-voice-notes');

create policy "Allow public read of proposal-voice-notes" on storage.objects
  for select to anon
  using (bucket_id = 'proposal-voice-notes');

-- Editing was expanded from just the 7 named-person notes above to every
-- prose block, stat tile, cost-breakdown row, timeline entry, and ask item
-- in the proposal (~71 additional section_key rows) -- same table, no
-- schema change needed, since section_key was already a free-text natural
-- key. Seeded with the current draft text so a fresh install matches
-- what's live; on conflict do nothing keeps this re-runnable and never
-- overwrites a real edit made in the tool.
insert into proposal_2027_sections (section_key, label, content)
values
  ('cover_title', 'Cover — Title', 'SelassieFest 2027 — Site Use & Special Event Proposal'),
  ('cover_subhead', 'Cover — Subhead', 'Seven Hills, Washington Park · Chicago, IL · 3rd Ward'),
  ('cover_meta', 'Cover — Prepared for', 'Prepared for: Chicago Park District · Dept. of Cultural Affairs & Special Events (DCASE) · Office of Alderman Pat Powell, 3rd Ward'),
  ('cover_date_block', 'Cover — Date line', 'Event date requested: Saturday, July 24, 2027 · Draft — for internal review before submission'),
  ('exec_summary_p1', 'Executive Summary — paragraph 1', 'Ras Tafari Inc., a 501(c)(3) nonprofit, respectfully requests a site-use and special event permit to hold SelassieFest 2027 at Seven Hills in Washington Park on Saturday, July 24, 2027. SelassieFest is Chicago''s roots reggae and Rastafari cultural festival, tracing its lineage to the city''s original Caribbean cultural gatherings held between 1981 and 1997 — a run of festivals that, for many who attended, has never been matched since.'),
  ('exec_summary_p2', 'Executive Summary — paragraph 2', 'This is not a cold request. Over the past several months a cross-agency working group has already come together around this proposal: two DCASE contacts (Camille and Jackie), a Chicago Park District contact (Denise), and two community members — Denise and Diedra — who lived the original festival era first-hand and have joined the planning committee specifically to help bring it back. This document lays out the case for the Seven Hills site, the team already assembled, and what we''re asking the City and the 3rd Ward to help us secure next.'),
  ('stat_days', '2026 stat — Planning to show', '47 days'),
  ('stat_attendance', '2026 stat — Peak attendance', '273'),
  ('stat_acts', '2026 stat — Performing acts', '11'),
  ('stat_cost', '2026 stat — Production cost', '$11,325'),
  ('track_record_intro', '2026 — Built in 47 days', 'Planning for SelassieFest 2026 began June 8, 2026, and the event was successfully produced 47 days later on July 25, 2026 — proof that this organizing team can deliver under a tight runway. For 2027, that same team now has a full year of lead time instead of seven weeks.'),
  ('lineup_music_label', 'Lineup — Music', 'Music — 6 DJs, plus Indika Reggae Band headlining with 4 opening acts'),
  ('lineup_music_val', 'Lineup — Music count', '11 acts'),
  ('lineup_host_label', 'Lineup — Host', 'Host — full-day emcee carrying the show'),
  ('lineup_host_val', 'Lineup — Host count', '1'),
  ('lineup_food_label', 'Lineup — Food vendors', 'Food vendors — Jamaican kitchen & Ital kitchen'),
  ('lineup_food_val', 'Lineup — Food count', '2'),
  ('lineup_cannabis_label', 'Lineup — Cannabis vendors', 'Cannabis vendors'),
  ('lineup_cannabis_val', 'Lineup — Cannabis count', '5'),
  ('lineup_crafts_label', 'Lineup — Arts and crafts vendor', 'Arts & crafts vendor'),
  ('lineup_crafts_val', 'Lineup — Crafts count', '1'),
  ('lineup_historical_label', 'Lineup — Historical display', 'Historical display — Brother JahSyll''s cultural/historical exhibit'),
  ('lineup_historical_val', 'Lineup — Historical count', '1'),
  ('cost_breakdown_intro', '2026 cost breakdown — intro', 'Total production cost for 2026 was $11,325, tracked in the Ras Tafari Inc. finance system we''ll scale up for 2027 planning and City reporting:'),
  ('cost_venue', '2026 cost — Venue and Site', '$1,800'),
  ('cost_stage', '2026 cost — Stage and Production', '$1,150'),
  ('cost_security', '2026 cost — Security', '$1,100'),
  ('cost_sanitation', '2026 cost — Sanitation', '$1,050'),
  ('cost_food', '2026 cost — Food and Beverage', '$1,000'),
  ('cost_tents', '2026 cost — Tents and Structures', '$900'),
  ('cost_print', '2026 cost — Print Materials', '$725'),
  ('cost_hospitality', '2026 cost — Artist Hospitality', '$700'),
  ('cost_artist_fees', '2026 cost — Artist Fees', '$600'),
  ('cost_merch', '2026 cost — Merchandise', '$500'),
  ('cost_insurance', '2026 cost — Insurance', '$500'),
  ('cost_dj', '2026 cost — DJ Fees', '$450'),
  ('cost_marketing', '2026 cost — Marketing', '$300'),
  ('cost_staffing', '2026 cost — Staffing', '$300'),
  ('cost_photo', '2026 cost — Photography', '$150'),
  ('cost_furniture', '2026 cost — Furniture', '$100'),
  ('cost_total', '2026 cost — Total', '$11,325'),
  ('goals_2027', 'Turning 2026 into 2027 goals', '2026 proved the concept at small scale: a real crowd, a full day of programming, a diverse vendor mix, and a team that can execute fast. 2027''s goals build directly from that baseline — a fixed year-long runway instead of 47 days, an expected attendance of 500 at a civic-scaled site instead of 273 at a constrained one, and an organizing body now including Denise, Diedra, and Brother JahSyll in addition to the core team that delivered 2026.'),
  ('why_seven_hills_p1', 'Why Seven Hills — paragraph 1', 'Chicago''s reggae and dancehall community has real venues it loves — but nothing built at the scale the original SelassieFest reached in its 1981-1997 run. Seven Hills'' natural bowl topography inside Washington Park gives us a purpose-built outdoor amphitheater setting: a sloped green that works as a built-in gallery for a main stage, with the surrounding lawn and path network able to host a marketplace, heritage village, healing grove, and a dedicated family/kids zone side by side — without needing to shut down city streets.'),
  ('why_seven_hills_p2', 'Why Seven Hills — paragraph 2', 'The site sits within the 3rd Ward, is served by CTA Green Line and bus routes, and is a short walk from the DuSable Black History Museum — a natural cultural anchor for a festival rooted in Pan-African and Rastafari heritage. Choosing a Chicago Park District green space also puts this proposal squarely inside the Park District''s own mission of hosting civic cultural programming, rather than asking the City to accommodate an ill-fitting private venue.'),
  ('permitting_team_intro', 'Permitting team — intro', 'Click directly into any note below to edit it — it saves automatically as you type, and everyone viewing this page sees the latest version.'),
  ('ov_date', 'Event Overview — Date', 'Saturday, July 24, 2027 (rain date TBD)'),
  ('ov_site', 'Event Overview — Site', 'Seven Hills, Washington Park, Chicago, IL — 3rd Ward'),
  ('ov_hours', 'Event Overview — Hours', '10:00 AM – 10:00 PM, running to the park''s standard closing time'),
  ('ov_footprint', 'Event Overview — Footprint', 'Main stage set into the natural bowl, with Ital Marketplace, Heritage Village, Healing Grove, Higher Learning Roots pavilion, and a dedicated Pickney Time kids zone on the surrounding lawn.'),
  ('ov_attendance', 'Event Overview — Expected attendance', '500 people'),
  ('ov_admission', 'Event Overview — Admission', 'Free to enter'),
  ('ov_loadinout', 'Event Overview — Load-in and load-out', 'TBD — request multi-day access for stage build and teardown'),
  ('tl_1', 'Timeline — August to September 2026', 'Joint site walk at Seven Hills with Denise, Chicago Park District, to confirm footprint, capacity, and any site restrictions.'),
  ('tl_2', 'Timeline — September to October 2026', 'Submit the Chicago Park District Special Event Permit application for Seven Hills, Saturday, July 24, 2027, including requested load-in and load-out dates. The application carries a 45 dollar fee, a minimum 14 day review, and must be filed 30 to 90 days before the reservation depending on event size.'),
  ('tl_3', 'Timeline — October to November 2026', 'DCASE special event registration with Camille and Jackie; coordinate multi-agency review with Police, Fire, and Public Health as required for the event''s scale.'),
  ('tl_4', 'Timeline — November 2, 2026', 'Night Out in the Parks and Chicago Onscreen 2027 season application opens through the Chicago Park District. Apply separately for this program to seek supplemental city-backed programming support and promotion alongside the main site permit.'),
  ('tl_5', 'Timeline — November 2026', 'Request a letter of support from Alderman Pat Powell''s office and begin the required 3rd Ward community notification.'),
  ('tl_6', 'Timeline — December 14, 2026', 'Night Out in the Parks 2027 proposal deadline, 11:59 PM, if applying to that program.'),
  ('tl_7', 'Timeline — December 2026 to February 2027', 'Finalize insurance certificates, the security and medical plan, and the traffic and pedestrian management plan for submission.'),
  ('tl_8', 'Timeline — March 2027', 'If selected for Night Out in the Parks, confirm the performance schedule, matching that program''s usual mid-March confirmation deadline.'),
  ('tl_9', 'Timeline — March to May 2027', 'Lock in vendor contracts, sponsorships, and the public marketing rollout.'),
  ('tl_10', 'Timeline — June 2027', 'Final walk-through with the Park District and DCASE; confirm all permits issued and load-in logistics.'),
  ('tl_11', 'Timeline — Early July 2027', 'Submit the special event liquor license application (Special Event Retailer''s License, Not-For-Profit track), if alcohol service is planned. City rules require filing at least 20 calendar days before the event, with the ward alderman notified at least 5 days before the license is issued — submitting in early July gives buffer ahead of that 20 day floor.'),
  ('tl_12', 'Timeline — Event day', 'SelassieFest 2027, event day.'),
  ('impact_p1', 'Community and Cultural Impact', 'SelassieFest 2027 continues Ras Tafari Inc.''s mission of preserving and reviving Rastafari and Caribbean cultural heritage in Chicago, and directly supports the organization''s ongoing Historical Reconstruction Project documenting the festival''s 1981-1997 era. Hosting in Washington Park roots this revival in the 3rd Ward, bringing foot traffic and vendor opportunity to local businesses and giving the community that lived the original festival — and the generation that never got to — a shared, intergenerational gathering.'),
  ('ask_1', 'The Ask — item 1', 'Chicago Park District site-use / special event permit for Seven Hills, Washington Park, for July 24, 2027, plus requested load-in/out days.'),
  ('ask_2', 'The Ask — item 2', 'DCASE special event registration and coordination support, including guidance on required city departments and timelines.'),
  ('ask_3', 'The Ask — item 3', 'A letter of support and community notification assistance from Alderman Pat Powell''s 3rd Ward office.'),
  ('ask_4', 'The Ask — item 4', 'A scheduled joint site walk-through at Seven Hills with Park District staff in the coming months to finalize the footprint.'),
  ('closing_p1', 'Closing statement', 'SelassieFest 2027 is a chance to give Chicago back something it lost — not as a recreation, but as a living continuation, led in part by the very people who experienced its original run. With DCASE, the Chicago Park District, and the 3rd Ward''s office already engaged and a community planning committee in place, we''re asking the City to help us bring this home to Washington Park.'),
  ('footer_note_text', 'Footer note', 'This is a draft proposal prepared for internal review. Fields marked TBD and the committee quote must be finalized before this document is submitted to the Chicago Park District, DCASE, or the 3rd Ward office.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- SelassieFest 2027 planning & committee structure
-- (/organization/selassiefest-2027-committee-structure.html)
-- ─────────────────────────────────────────────────────────────────────────
-- A second editable document reusing this same table (section_key is a
-- free-text natural key, so no schema change needed) -- the 15 standing
-- committees, executive/steering committee, subcommittees, Chicago
-- compliance notes, and day-of command team, all editable inline the same
-- way as the proposal above. Keys are prefixed cs_ to stay distinct from
-- the proposal's own keys sharing this table.
insert into proposal_2027_sections (section_key, label, content)
values
  ('cs_cover_title', 'Cover — Title', 'SelassieFest 2027 Planning Structure'),
  ('cs_cover_subhead', 'Cover — Subhead', '15 standing committees, a festival executive and steering committee, and a separate day-of command structure'),
  ('cs_intro', 'Overview', 'For SelassieFest — July 24, 2027, we recommend forming 15 standing committees, supported by one centralized festival leadership team and a separate day-of command structure. The committees reflect SelassieFest''s identity as a celebration of roots, culture, music, wellness, knowledge, unity and community, while professionally managing a large, multicultural and multigenerational outdoor festival.'),
  ('cs_exec_members', 'Executive Committee — Members', 'Festival Founder/Executive Producer
Festival Director
Operations Director
Finance Director
Cultural Director
Safety Director
Sponsorship/Revenue Director
Community representative
Legal adviser'),
  ('cs_exec_responsibilities', 'Executive Committee — Responsibilities', 'Establish the mission, size and goals of SelassieFest 2027
Approve budgets, contracts, major performers and sponsors
Resolve disputes between committees
Approve policies and major public announcements
Maintain the master timeline
Protect the SelassieFest name, reputation and cultural integrity
Decide whether admission remains free, becomes ticketed or uses a hybrid model
Establish attendance targets and financial success measures'),
  ('cs_pmo_note', 'Project Management Office', 'A smaller Festival Project Management Office should report to this committee and maintain the master calendar, meeting notes, task tracker, contracts, risk register and decision log.'),
  ('cs_c1', 'Committee 1 — Cultural Integrity, Rastafari and Community Advisory', 'Protect the meaning and cultural integrity of SelassieFest; advise on the representation of His Imperial Majesty Haile Selassie I; develop the "One Love/One People" message; engage Rastafari elders, faith leaders, historians, Jamaican, Ethiopian, African and Caribbean organizations; review cultural language, imagery, ceremonies and educational content.'),
  ('cs_c2', 'Committee 2 — Festival Programming', 'Develop the complete noon-to-midnight program; music, DJs, bands, speakers, tributes, reasoning sessions, cultural presentations, wellness programming, children''s activities, elder recognition, lion-themed processions, contests and community performances; prevent gaps or conflicts in the schedule.'),
  ('cs_c3', 'Committee 3 — Finance, Budget and Cash-Control', 'Build the complete festival budget; maintain cash-flow projections; approve expenditures; process deposits and invoices; establish purchase-order rules; manage petty cash, vendor payments and reimbursements; conduct post-event reconciliation; protect against unauthorized spending.'),
  ('cs_c4', 'Committee 4 — Sponsorship, Grants and Fundraising', 'Create sponsorship packages; recruit presenting, stage, community, wellness, transportation and in-kind sponsors; manage grant applications; organize fundraising events; assign sponsor benefits; collect logos and advertising materials; ensure every promised sponsor benefit is delivered.'),
  ('cs_c5', 'Committee 5 — Legal, Permits, Insurance and Compliance', 'Manage venue agreements, performer contracts, vendor agreements, music licensing, releases, insurance, permits, tax documentation and regulatory compliance; review alcohol, food, cannabis, security, fire, medical and accessibility requirements; maintain copies of all licenses and certificates.'),
  ('cs_c6', 'Committee 6 — Venue, Site Design and Infrastructure', 'Confirm the property; create the site map; determine capacity; position the giant One Umbrella stage, entrances, exits, emergency lanes, vendors, restrooms, first aid, backstage, VIP areas, children''s areas, seating, accessibility routes, sponsor activations, waste stations and utilities.'),
  ('cs_c7', 'Committee 7 — Stage Production and Technical', 'Manage staging, the One Umbrella roof, sound, lighting, power, generators, video, screens, microphones, backline, DJ equipment, livestreaming, internet, stage barricades and technical labor; develop soundcheck, changeover and shutdown schedules.'),
  ('cs_c8', 'Committee 8 — Talent Booking and Artist Relations', 'Recruit performers, DJs, bands, hosts, speakers and cultural presenters; negotiate fees; secure contracts; collect technical riders; arrange transportation, lodging and meals; manage backstage credentials, dressing rooms, hospitality and artist arrival/departure schedules.'),
  ('cs_c9', 'Committee 9 — Vendors, Food, Beverage and Marketplace', 'Recruit and approve food vendors, merchandise vendors, cultural exhibitors, nonprofit organizations and wellness providers; prevent duplicate offerings; collect licenses and insurance; assign spaces; manage vendor fees, arrival instructions, inspections, utilities and cleanup requirements.'),
  ('cs_c10', 'Committee 10 — Cannabis, Wellness and Responsible Participation', 'Define what cannabis-related education, sponsorship, branding or activity is legally permissible; screen cannabis-related businesses; prevent unauthorized or black-market sales; develop age-control and prohibited-item procedures; coordinate wellness education, harm reduction and responsible-use messaging.'),
  ('cs_c11', 'Committee 11 — Public Safety, Security, Medical and Emergency', 'Create the safety plan; hire licensed security; coordinate police, fire and EMS requirements; establish emergency exits, missing-child procedures, severe-weather plans, evacuation, crowd management, incident reporting, lost property, prohibited-item enforcement and emergency communications.'),
  ('cs_c12', 'Committee 12 — Guest Experience, Accessibility and Entry Operations', 'Design the complete guest journey; entrance signage, bag checks, ticket or RSVP scanning, wristbands, information booths, lost-and-found, complaint resolution, hydration, seating and shade; accommodate elders, families and people with disabilities; train hospitality ambassadors.'),
  ('cs_c13', 'Committee 13 — Marketing, Public Relations and Creative', 'Create the campaign strategy; flyers, social media, website, email, radio, press releases, community outreach, performer announcements, countdowns and sponsor content; maintain brand consistency; manage photography, video and media credentials; protect accuracy of dates, addresses and event rules.'),
  ('cs_c14', 'Committee 14 — Staffing, Volunteers and Training', 'Determine every paid and volunteer position; recruit, screen and schedule workers; prepare job descriptions; conduct orientation and safety training; manage check-in, uniforms, meals, breaks, radios, credential levels, supervision and volunteer appreciation.'),
  ('cs_c15', 'Committee 15 — Transportation, Neighborhood, Sanitation and Sustainability', 'Coordinate parking, rideshare, artist transportation, buses, loading areas, street access and traffic flow; communicate with residents and neighboring organizations; manage toilets, handwashing, trash, recycling, overnight cleanup, noise concerns and site restoration.'),
  ('cs_tech_workstream', 'Technology and Data Workstream', 'Festival email accounts and shared files
Website and registration systems
Ticketing or free RSVP registration
QR codes and credential databases
Sponsor and vendor databases
Staff communication systems
Radios and radio assignments
Wi-Fi and internet access
Payment systems
Attendance counting
Surveys and post-event reporting
Data privacy and backups
Cybersecurity and scam prevention'),
  ('cs_sub_elder', 'Elder and Accessibility Council', 'Shaded elder seating
Accessible Rasta-style chairs
Walker and wheelchair routes
Close restroom access
Drop-off areas
Medical support
Quiet rest areas
Elder hosts or escorts
Reserved viewing areas
Recognition of Rastafari and community elders'),
  ('cs_sub_family', 'Children and Family Team', 'Child-friendly programming
Family seating and shade
Missing-child procedures
Parent/guardian wristbands
Safe activity areas
Age-appropriate cultural education
Youth performers
Family restroom considerations
Separation from any age-restricted areas'),
  ('cs_sub_culture', 'Cultural Education and Reasoning Team', 'Haile Selassie I history presentations
Ethiopian and Jamaican history
Rastafari reasoning sessions
Reggae history
Community wellness discussions
Art and literature displays
"Out of Many, One People" programming
African diaspora presentations
Youth education
Community-resource booths'),
  ('cs_sub_entrance', 'Entrance Policy Team', 'Two or more clearly organized entrances
Posted prohibited-item signs
Weapons policy
Glass and cooler restrictions
Alcohol controls
Cannabis policy
Bag-search procedures
Confiscation/refusal procedures
Re-entry rules
Staff scripts for handling disputes
Escalation to supervisors or security'),
  ('cs_compliance_1', 'Compliance — Special Event Permit', 'Assuming SelassieFest remains an outdoor Chicago festival, the Legal and Permits Committee should begin early. Chicago currently requires a Festival/Athletic Event Permit Application for applicable outdoor events, and the application process collects information concerning the event site, organizers, emergency contacts and operating plans. The rules and forms should be checked again when the 2027 application period opens.'),
  ('cs_compliance_2', 'Compliance — Food Safety', 'Food booths and food trucks have separate special-event licensing and food-safety requirements, so the festival should not accept a vendor solely on the basis of payment or popularity. Licensing, sanitation, cooking equipment, insurance and food-handling documentation need to be reviewed before final approval.'),
  ('cs_compliance_3', 'Compliance — EMS and Fire', 'Chicago also publishes outdoor-event EMS and fire-safety requirements. Medical coverage, cooking fuel, generators, tents, stage equipment and any special effects should be reviewed by the Safety Committee and the appropriate authorities before the site plan is finalized.'),
  ('cs_compliance_4', 'Compliance — Cannabis', 'Cannabis-related activities need especially careful legal review. Illinois regulates cannabis businesses, sales and dispensing through licensed programs. SelassieFest should not assume that cannabis-themed sponsorship, possession, sale, sampling and consumption are governed by the same rules. Every proposed activation should be approved individually by legal counsel and the appropriate regulators.'),
  ('cs_dayof_intro', 'Day-of Command — Intro', 'The committees should not attempt to make decisions collectively during the festival. On July 24, 2027, control should transfer to a clearly identified command team.'),
  ('cs_cmd_1', 'Command — Festival Director', 'Final operational authority'),
  ('cs_cmd_2', 'Command — Operations Chief', 'Site, vendors, transportation and infrastructure'),
  ('cs_cmd_3', 'Command — Safety Officer', 'Security, medical, weather and emergency authority'),
  ('cs_cmd_4', 'Command — Production Manager', 'Stage, artists, sound and schedule'),
  ('cs_cmd_5', 'Command — Guest Services Manager', 'Entrances, accessibility, complaints and information'),
  ('cs_cmd_6', 'Command — Volunteer Manager', 'Staffing, breaks and redeployment'),
  ('cs_cmd_7', 'Command — Communications Officer', 'Radios, public announcements and internal updates'),
  ('cs_cmd_8', 'Command — Finance/Cash Manager', 'Onsite financial controls'),
  ('cs_cmd_9', 'Command — Media Representative', 'Press, public statements and crisis messaging'),
  ('cs_cmd_10', 'Command — Documentation Officer', 'Incident log, attendance and operational records'),
  ('cs_cmd_note', 'Command — Safety Officer authority note', 'The Safety Officer should have the authority to pause or stop an activity when conditions become unsafe.'),
  ('cs_deliverables', 'Required Deliverables', 'Written scope and responsibilities
Committee chair and deputy
Budget and spending authority
Timeline with deadlines
Risk and problem register
Day-of staffing and operating procedure
Post-event report and financial closeout'),
  ('cs_deliverables_note', 'Required Deliverables — note', 'This prevents committees from becoming discussion groups without measurable results.'),
  ('cs_first_committees', 'Committees to Form First', 'Executive and Project Management
Cultural Integrity and Community
Finance and Budget
Legal, Permits and Insurance
Venue and Site Operations
Sponsorship and Fundraising
Public Safety and Emergency Planning'),
  ('cs_first_committees_note', 'Committees to Form First — note', 'After those teams establish the festival''s scope, site, budget, capacity and legal framework, the remaining committees can begin booking, recruiting, marketing and detailed production planning.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- 2026 cost breakdown -- fully editable rows (add / delete / edit)
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
-- The cost breakdown table was originally a fixed set of 16 category rows
-- stored as individual proposal_2027_sections keys (cost_venue, cost_stage,
-- ...). That only supports editing existing values, not adding or removing
-- rows, so it's superseded by this dedicated table: one row per line item,
-- with the Total calculated client-side from whatever rows currently
-- exist rather than stored/edited as its own row (so it can never go stale
-- after an add/delete). The old cost_* keys above are left in place,
-- unused, rather than deleted -- harmless dead data, not worth a
-- destructive cleanup step.
--
-- Same "no login, anyone with the link can edit" tradeoff as every other
-- collaborative table in this file (ticket_event_drafts,
-- run_of_show_chapters, proposal_2027_sections).
create table if not exists proposal_2027_cost_rows (
  id uuid primary key default gen_random_uuid(),
  sort_order int not null default 0,
  label text not null default '',
  amount text not null default '',
  last_edited_by text,
  updated_at timestamptz not null default now()
);

alter table proposal_2027_cost_rows enable row level security;

create policy "public full access" on proposal_2027_cost_rows
  for all to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on proposal_2027_cost_rows to anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'proposal_2027_cost_rows'
  ) then
    alter publication supabase_realtime add table proposal_2027_cost_rows;
  end if;
end $$;

-- Seed with the same 16 line items the static table used to show, only if
-- the table is currently empty -- unlike the section_key tables above,
-- there's no natural per-row conflict key to guard a plain re-run with, so
-- emptiness is the idempotency check instead. This never re-seeds once
-- anyone has added or deleted a real row.
insert into proposal_2027_cost_rows (sort_order, label, amount)
select v.sort_order, v.label, v.amount from (values
  (1, 'Venue & Site', '$1,800'),
  (2, 'Stage & Production', '$1,150'),
  (3, 'Security', '$1,100'),
  (4, 'Portable Toilets & Sanitation', '$1,050'),
  (5, 'Food & Beverage — Org', '$1,000'),
  (6, 'Tents & Structures', '$900'),
  (7, 'Print Materials', '$725'),
  (8, 'Artist Hospitality / Rider', '$700'),
  (9, 'Artist Fees', '$600'),
  (10, 'Merchandise & Apparel', '$500'),
  (11, 'Insurance', '$500'),
  (12, 'DJ Fees', '$450'),
  (13, 'Marketing & Advertising', '$300'),
  (14, 'Staffing (uniforms)', '$300'),
  (15, 'Photography & Videography', '$150'),
  (16, 'Tables, Chairs & Furniture', '$100')
) as v(sort_order, label, amount)
where not exists (select 1 from proposal_2027_cost_rows);

-- ─────────────────────────────────────────────────────────────────────────
-- Venue approval gates, site feasibility issues, and master planning
-- sequence added to the committee-structure page
-- (/organization/selassiefest-2027-committee-structure.html)
-- ─────────────────────────────────────────────────────────────────────────
-- Same proposal_2027_sections table, 28 more section_key rows covering the
-- three-gate approval framework (application submitted / pending permit /
-- final permit), the three site-feasibility issues with "7 Hills" at
-- Washington Park, venue/ward contacts, the 8-phase planning sequence, the
-- 90/60/45/30/14-day countdown milestones, and the three approval-gate risk
-- tiers (start now / wait for pending permit / wait for final permit).
insert into proposal_2027_sections (section_key, label, content)
values
  ('gate_intro', 'Venue Gates — Intro', 'Planning should not stop while waiting to secure Washington Park. The work required to determine whether the site is feasible and to submit a complete permit application must begin immediately. However, major public or irreversible commitments should wait until the venue reaches the appropriate approval stage.'),
  ('gate_stages', 'Venue Gates — Three Stages', 'Application submitted — the venue is not secured.
Pending permit / conditional approval received — the date and location are tentatively accepted, subject to payments, insurance, plans and other permits.
Final Special Event Permit issued — the event is authorized to proceed under the approved conditions.'),
  ('gate_note', 'Venue Gates — Park District note', 'Chicago Park District states that submitting an application or paying the application fee does not grant permission to conduct the event. After at least 14 business days, an accepted application receives a pending permit identifying additional requirements and deadlines. The final permit is issued only after all requirements and payments are satisfied.'),
  ('siteissue_1', 'Site Issue 1 — Official site identification', 'The Park District''s official name for the venue is Washington (George) Park, at 5531 S. King Drive. Its published facility list does not identify an area officially called "7 Hills." "7 Hills" may be a familiar community name, but the permit must show the exact field, lawn or geographic footprint on a detailed site map. Do not submit the application merely stating "7 Hills" — it should read something like: "Washington (George) Park — exact lawn area commonly known as ''7 Hills,'' as shown within the attached site-plan boundary." The Park District must confirm the approved official description.'),
  ('siteissue_2', 'Site Issue 2 — Operating hours', 'Washington Park currently publishes park hours of 6:00 AM to 9:00 PM, and Park District permit rules generally restrict events to a park''s posted public operating hours. If SelassieFest intends to operate from noon until midnight, do not assume Washington Park can accommodate that schedule. Ask in writing whether the Park District would approve amplified music after 9:00 PM, audience presence after 9:00 PM, vendor shutdown after 9:00 PM, stage strike and equipment removal after public hours, and overnight security or next-morning teardown. This is a venue-killing question — resolve it before spending money on application design, stage engineering or artist bookings.'),
  ('siteissue_3', 'Site Issue 3 — Cannabis restrictions', 'The current Park District application states that cannabis-derived products may not be consumed, sampled, sold or promoted through signage on Park District property. That potentially affects cannabis sponsor logos, cannabis swag bags, infused-product promotion, cannabis vendors, sampling or giveaways, consumption areas, and cannabis-related signs or banners. SelassieFest can still discuss Rastafari culture and history, but commercial cannabis promotion at this particular venue may need to be removed or substantially restructured. Obtain a written interpretation from the assigned permit coordinator.'),
  ('venuecontact_park_supervisor', 'Contact — Park Supervisor', 'Washington Park supervisor · Washington Park main office: 773-256-1248 · 5531 S. King Drive'),
  ('venuecontact_ward3', 'Contact — Ward 3 Office', 'ward03@cityofchicago.org · 773-373-9273. Note: this source (ward03chicago.com) lists the alderperson as Pat Dowell — this conflicts with "Alderman Pat Powell" used in the companion Site-Use & Permit Proposal. Confirm which name is correct before using either publicly.'),
  ('venuecontact_advisory_council', 'Contact — Advisory Council', 'Generally meets the third Wednesday of the month. Park District guidance encourages early contact with the alderperson, Park Advisory Council, police commander and community organizations whenever an event may affect public access to park amenities.'),
  ('seq_phase1', 'Phase 1 — Establish the Applicant and Proposed Event', 'Step 1 — Select the legal permit applicant: the organization or person who will legally hold the Park District permit. Determine its legal entity name, authorized signatory, EIN/nonprofit status, mailing address, festival bank account, and who is responsible for insurance, permit compliance, and Park District communication. The application and permit are not transferable, so the correct entity must apply from the start.

Step 2 — Approve a preliminary festival scope: expected attendance, admission model, festival hours, setup/teardown dates, stage count and design, vendor counts, sponsors, alcohol, generators, fencing, toilets, security/medical, children''s area, elder/accessible seating, and parking/rideshare/loading needs. Attendance matters because the permit level, deposit, fees and review requirements change with crowd size — 1,001-3,000 attendees is Event Level 4; 3,001-10,000 is Event Level 5; 10,000+ is Event Level 6, which requires provisional Park District Board approval and additional community engagement. At an expected 500 attendees, SelassieFest currently falls below the Level 4 threshold.'),
  ('seq_phase2', 'Phase 2 — Conduct Venue Feasibility Before Applying', 'Step 3 — Request a formal site walk with the Washington Park supervisor (Janie M. Collins, 773-256-1248, 5531 S. King Drive). Bring a printed aerial map, proposed stage dimensions, estimated attendance, proposed entrance locations, operating hours, preliminary vendor count, setup/teardown requirements, utility questions, and photographs of the area locally called "7 Hills."

Step 4 — Obtain preliminary answers on: 7 Hills availability for July 24, 2027; the official name/designation to use; whether the lawn can handle the anticipated crowd; roofed-stage installation; staking permission; equipment truck access; noon-to-midnight hours; amplified music permission; approved stage speaker direction; alcohol; cannabis sponsorship restrictions; restroom/dumpster locations; accessible routes; emergency vehicle access; conflicts with other park programming; setup/teardown dates; rain and turf-restoration requirements; and a backup area within the park.

Step 5 — Decide whether Washington Park passes the feasibility test with a written go/no-go decision, proceeding only if the venue can support the desired hours, capacity, stage and roof, amplified programming, vendors, security/emergency access, cultural and sponsor plans, and adequate setup/teardown. If hours, cannabis promotion, or stage/vehicle access can''t be resolved, leadership must decide whether to modify SelassieFest or select another site.'),
  ('seq_phase3', 'Phase 3 — Begin Community Engagement', 'Step 6 — Brief the Ward 3 office on SelassieFest''s cultural mission, proposed date/hours, estimated attendance, community benefits, youth/elder programming, local-vendor opportunities, safety plan concept, neighborhood notification plan, cleanup commitment, transportation concept, and preliminary site plan. The alderperson''s office does not replace Park District permitting authority, but early support and issue identification matters.

Step 7 — Meet the Washington Park Advisory Council (generally the third Wednesday of the month) for community input, knowledge of the "7 Hills" area, information about competing park uses, neighborhood concerns, local organization participation, and recommendations on sound, traffic and cleanup. Park District guidance encourages early contact with the alderperson, Park Advisory Council, police commander and community organizations whenever an event may affect public access to park amenities.'),
  ('seq_phase4', 'Phase 4 — Prepare the Park District Application Package', 'Step 8 — Produce the preliminary site plan showing the exact festival boundary, stage/roof footprint, speaker locations and sound direction, FOH position, emergency exits, public entrances, security screening lanes, fencing, barricades, vendors, sponsor booths, children''s area, elder/accessible seating, first-aid station, ambulance position, command post, toilets, generators, dumpsters, water stations, artist compound, staff/volunteer check-in, equipment paths, loading areas, and any requested street or sidewalk use. The Park District requires a site map for every special-event application showing all major structures and operational features.

Step 9 — Prepare three choices: first choice is July 24, 2027 at the exact 7 Hills footprint; second choice is an alternate area within Washington Park; third choice is an alternate date or Park District location. Availability generally can''t be confirmed before application review, so alternatives are recommended.

Step 10 — Prepare an application-ready package before the 2027 window opens: as of July 2026 the Park District site shows 2025 and 2026 application links but not yet 2027. Have applicant information, event narrative, attendance estimate, site plan, setup/event/teardown schedule, marketing description, vendor plan, preliminary security/medical plans, alcohol decision, sponsorship/activation list, stage/tent/generator specifications, and backup dates/sites ready in advance. For the 2026 cycle, applications opened in November of the prior year, with the fee establishing processing position and the completed application due within three business days — the 2027 procedure and opening date must be confirmed once published.'),
  ('seq_phase5', 'Phase 5 — Submit Immediately When 2027 Applications Open', 'Step 11 — Pay the application fee first, following the 2027 instructions exactly; the current procedure requires the nonrefundable application fee before submission because the receipt number is required.

Step 12 — Submit the completed application and site plan; do not submit a placeholder, since an incomplete submission may lose its processing position or be delayed.

Step 13 — Monitor the application daily. Review takes a minimum of 14 business days and can result in conditional approval for the requested date/site, a request for more information, an offer of an alternate site or date, or denial with explanation.'),
  ('seq_phase6', 'Phase 6 — Submit the City of Chicago Permit Package', 'Step 14 — File with DCASE as early as permitted. SelassieFest will almost certainly require a separate City of Chicago/DCASE process if it includes merchandise sales, alcohol, food preparation triggering city review, tents exceeding 400 square feet, a stage taller than two feet, or street/public-way use. DCASE currently allows applications up to 180 days before the event and requires them at least 21 days before — for July 24, 2027, the 180-day point is approximately January 25, 2027. A major festival should submit at the earliest opportunity rather than relying on the minimum.'),
  ('seq_phase7', 'Phase 7 — Finalize Production and Operating Plans', 'Step 15 — Contract the stage and production team. The One Umbrella roof will likely be treated as a roofed stage or platform requiring additional review — stages over two feet high, more than 400 square feet, or with roofing/wings require a Department of Buildings permit and a Park District verification letter, and that process should begin at least 60 days before the event. Obtain engineered stage drawings, wind-rating documentation, ballast/staking plan, structural calculations, lighting plot, sound-system specifications, generator/grounding plan, emergency stage-evacuation procedure, and load-in/out schedule.

Step 16 — Finalize security and medical providers. Current Park District requirements call for security and medical provisions for events with 500 or more attendees or events involving alcohol — SelassieFest''s planned 500 attendance sits right at that threshold. Security plans are subject to Park District approval. Complete the security staffing matrix, entrance screening plan, prohibited-items procedure, emergency evacuation plan, severe-weather plan, missing-child procedure, artist security, cash-handling security, medical staffing, ambulance access, incident-reporting system, and command-post structure.

Step 17 — Finalize insurance. Current requirements include at least $1 million in general liability coverage, with the Park District named as an additional insured on a primary, noncontributory basis, covering all setup, event and teardown dates, with both a certificate and endorsement required. Additional coverage may be needed for alcohol, animals, inflatables, amusement devices, contractors, vehicles and workers'' compensation.'),
  ('seq_90', 'Countdown — 90 days out', 'Freeze the fundamental event footprint; confirm final attendance projection; confirm stage count; confirm the alcohol decision; confirm sponsor activation types; confirm all major contractors; complete the community presentation; establish refund and cancellation exposure.'),
  ('seq_60', 'Countdown — 60 days out', 'Begin or complete stage and tent Department of Buildings permits, Park District verification letters, the DCASE alcohol process, the liquor-license process, generator permits if required, food and vendor licensing, fire-safety review, final structural engineering, and the transportation and traffic plan. Park District instructions specifically advise at least 60 days for qualifying stage/tent applications and alcohol paperwork.'),
  ('seq_45', 'Countdown — 45 days out', 'Where alcohol or relevant public-way activity is involved: obtain police district review, submit material to the alderperson''s office, confirm licensed security, finalize the crowd-control plan, and finalize the alcohol perimeter and age verification. Current alcohol instructions specify submission to the appropriate police commander and alderperson''s office at least 45 days before the event.'),
  ('seq_30', 'Countdown — 30 days out', 'Submit all outside agency permits to the Park District; freeze the site plan; submit final security and medical plans; submit stage, tent and generator approvals; submit vendor and food documentation; submit sanitation and waste plans; submit the accessibility plan; confirm emergency contacts; confirm setup and teardown schedules. Event Levels 3-5 and festivals of 10,000 or more must provide required city, state and federal approvals at least 30 days before the reservation begins.'),
  ('seq_14', 'Countdown — 14 days out', 'Subject to final 2027 permit terms: pay the remaining Park District balance; confirm the insurance certificate and endorsement; confirm all contractor certificates; confirm the accessible toilet count; issue final credentials; submit the final vendor roster; complete the final Park District walkthrough; confirm final permit issuance. The current fee schedule uses 14 days before the reservation as a key balance and documentation deadline, though the exact 2027 pending permit will control.'),
  ('seq_finalweek', 'Countdown — Final week', 'Conduct a command-team tabletop exercise; test radios; confirm weather-monitoring responsibility; issue vendor arrival appointments; mark the approved site; verify underground utilities before staking; inspect the stage and tents; conduct a sound-system test only during approved hours; place toilets, waste stations and barricades; complete fire, building and Park District inspections; and keep a copy of the permit onsite.'),
  ('gate_start_now', 'Gate — Start now', 'Legal applicant selection
Site feasibility
Park meeting
Community outreach
Attendance planning
Preliminary budgeting
Preliminary site design
Permit preparation
Backup-site research'),
  ('gate_wait_pending', 'Gate — Wait for pending permit', 'Nonrefundable artist deposits
Nonrefundable equipment deposits
Guaranteed sponsor benefits tied to Washington Park
Final vendor-space sales
Major printing
Public announcement that Washington Park is confirmed'),
  ('gate_after_pending_ok', 'Gate — OK after pending permit', 'Artist negotiations
Sponsor agreements
Vendor recruitment
Production bids
Stage engineering
Security-company negotiations
Medical-provider negotiations
Equipment rentals
Volunteer recruitment
Community outreach
Grant applications'),
  ('gate_pending_note', 'Gate — Pending permit note', 'Contracts should include language making performance dependent upon receipt and continued validity of all government and Park District permits. Public promotion before the final permit remains at the organizer''s risk — the Park District expressly warns that an application does not guarantee approval and that promotional expenses incurred before permit issuance are the organizer''s responsibility.'),
  ('gate_wait_final', 'Gate — Wait for final permit', 'Ticket sales
Unconditional artist contracts
Unconditional production contracts
Large media purchases
Nonrefundable travel
Public claims that the event is officially approved'),
  ('gate_immediate_action', 'Immediate next action', 'The immediate next action is not artist booking or sponsor recruitment. It is a formal site walk and written feasibility meeting addressing the exact 7 Hills footprint, the 9:00 PM park closing time, the One Umbrella stage and the cannabis-promotion restrictions.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- 2027 goal bullets (added under "Turning 2026 into 2027 goals")
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
insert into proposal_2027_sections (section_key, label, content)
values
  ('goal_bullet_1', '2027 Goal — Planning runway', 'Increase planning and promotion time from 47 days to approximately 300 days'),
  ('goal_bullet_2', '2027 Goal — Attendance', 'Double the attendance from 273 to 550 attendees'),
  ('goal_bullet_3', '2027 Goal — Partnership dollars', 'Increase partnership dollars from $0.00 to approximately $20,000')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Corrected expected attendance (500 -> 550) and rewritten "Why Seven
-- Hills" section (historic 1981-1997 home, DuSable Museum, Obama
-- Presidential Center, Olmsted's South Park system)
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
-- Plain UPDATEs, not seed inserts -- these section_keys already exist from
-- earlier migrations and need their content corrected/replaced outright,
-- not left alone by an on-conflict-do-nothing seed.
update proposal_2027_sections set content = '2026 proved the concept at small scale: a real crowd, a full day of programming, a diverse vendor mix, and a team that can execute fast. 2027''s goals build directly from that baseline — a fixed year-long runway instead of 47 days, an expected attendance of 550 at a civic-scaled site instead of 273 at a constrained one, and an organizing body now including Denise, Diedra, and Brother JahSyll in addition to the core team that delivered 2026.', updated_at = now()
where section_key = 'goals_2027';

update proposal_2027_sections set content = '550 people', updated_at = now()
where section_key = 'ov_attendance';

update proposal_2027_sections set content = 'Step 1 — Select the legal permit applicant: the organization or person who will legally hold the Park District permit. Determine its legal entity name, authorized signatory, EIN/nonprofit status, mailing address, festival bank account, and who is responsible for insurance, permit compliance, and Park District communication. The application and permit are not transferable, so the correct entity must apply from the start.

Step 2 — Approve a preliminary festival scope: expected attendance, admission model, festival hours, setup/teardown dates, stage count and design, vendor counts, sponsors, alcohol, generators, fencing, toilets, security/medical, children''s area, elder/accessible seating, and parking/rideshare/loading needs. Attendance matters because the permit level, deposit, fees and review requirements change with crowd size — 1,001-3,000 attendees is Event Level 4; 3,001-10,000 is Event Level 5; 10,000+ is Event Level 6, which requires provisional Park District Board approval and additional community engagement. At an expected 550 attendees, SelassieFest currently falls below the Level 4 threshold.', updated_at = now()
where section_key = 'seq_phase1';

update proposal_2027_sections set content = 'Step 15 — Contract the stage and production team. The One Umbrella roof will likely be treated as a roofed stage or platform requiring additional review — stages over two feet high, more than 400 square feet, or with roofing/wings require a Department of Buildings permit and a Park District verification letter, and that process should begin at least 60 days before the event. Obtain engineered stage drawings, wind-rating documentation, ballast/staking plan, structural calculations, lighting plot, sound-system specifications, generator/grounding plan, emergency stage-evacuation procedure, and load-in/out schedule.

Step 16 — Finalize security and medical providers. Current Park District requirements call for security and medical provisions for events with 500 or more attendees or events involving alcohol — SelassieFest''s planned 550 attendance exceeds that threshold. Security plans are subject to Park District approval. Complete the security staffing matrix, entrance screening plan, prohibited-items procedure, emergency evacuation plan, severe-weather plan, missing-child procedure, artist security, cash-handling security, medical staffing, ambulance access, incident-reporting system, and command-post structure.

Step 17 — Finalize insurance. Current requirements include at least $1 million in general liability coverage, with the Park District named as an additional insured on a primary, noncontributory basis, covering all setup, event and teardown dates, with both a certificate and endorsement required. Additional coverage may be needed for alcohol, animals, inflatables, amusement devices, contractors, vehicles and workers'' compensation.', updated_at = now()
where section_key = 'seq_phase7';

update proposal_2027_sections set content = 'Seven Hills is not merely a possible venue for SelassieFest — it is the festival''s historic home. According to the festival''s history, the original SelassieFest was held at Seven Hills from 1981 through 1997, making a return in 2027 both a homecoming and the restoration of a significant Chicago Rastafari and reggae tradition.', updated_at = now()
where section_key = 'why_seven_hills_p1';

update proposal_2027_sections set content = 'The location also sits within an exceptional South Side cultural corridor. The DuSable Black History Museum and Education Center stands inside Washington Park, while the now-open Obama Presidential Center is nearby in Jackson Park. Washington and Jackson Parks are connected by the Midway Plaisance as parts of Frederick Law Olmsted''s original South Park system. Together, these institutions and landscapes create a powerful setting shaped by Black history, Pan-African identity, civic leadership and community gathering.', updated_at = now()
where section_key = 'why_seven_hills_p2';

insert into proposal_2027_sections (section_key, label, content)
values
  ('why_seven_hills_title', 'Why Seven Hills — card title', 'A homecoming to SelassieFest''s original site — and a landmark South Side cultural corridor'),
  ('why_seven_hills_p3', 'Why Seven Hills — paragraph 3', 'With CTA Green Line and bus access, Seven Hills can welcome residents from across Chicago while providing the open, public and intergenerational environment that SelassieFest requires. Families, elders, youth, artists, educators and members of the wider African diaspora can gather in a setting more inclusive and culturally appropriate than a private entertainment venue.'),
  ('why_seven_hills_p4', 'Why Seven Hills — paragraph 4', 'Choosing Seven Hills is therefore more than selecting a festival site. It is a return to SelassieFest''s roots and an opportunity to reestablish the festival within one of Chicago''s most important landscapes of Black culture, history and public life.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Cross-agency team roster -- blank, add/delete rows by agency
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
-- Replaces the four named contact_camille/contact_jackie/contact_denise_park/
-- contact_alderman cards (left in proposal_2027_sections, unused, rather
-- than deleted) -- the team is not actually confirmed yet, so presenting
-- specific names as already-secured contacts was misleading. This table
-- holds a variable number of blank rows per agency instead, same
-- add/delete-row shape as proposal_2027_cost_rows.
create table if not exists proposal_2027_team_contacts (
  id uuid primary key default gen_random_uuid(),
  agency text not null,
  sort_order int not null default 0,
  role_needed text not null default '',
  name text not null default '',
  title text not null default '',
  last_edited_by text,
  updated_at timestamptz not null default now()
);

alter table proposal_2027_team_contacts enable row level security;

create policy "public full access" on proposal_2027_team_contacts
  for all to anon, authenticated
  using (true)
  with check (true);

grant select, insert, update, delete on proposal_2027_team_contacts to anon, authenticated;

do $$
begin
  if not exists (
    select 1 from pg_publication_tables
    where pubname = 'supabase_realtime' and schemaname = 'public' and tablename = 'proposal_2027_team_contacts'
  ) then
    alter publication supabase_realtime add table proposal_2027_team_contacts;
  end if;
end $$;

-- Blank starter rows (name/title empty) seeded only if the table is
-- currently empty, matching proposal_2027_cost_rows' idempotency pattern --
-- role_needed carries over what each contact card used to describe, so
-- the "what kind of contact do we need here" context isn't lost.
insert into proposal_2027_team_contacts (agency, sort_order, role_needed, name, title)
select v.agency, v.sort_order, v.role_needed, '', '' from (values
  ('DCASE', 1, 'Special event permitting & coordination contact'),
  ('DCASE', 2, 'Cultural programming & community engagement contact'),
  ('Chicago Park District', 1, 'Permits & park operations liaison for Washington Park'),
  ('3rd Ward', 1, 'Aldermanic support & community notification for events in Washington Park')
) as v(agency, sort_order, role_needed)
where not exists (select 1 from proposal_2027_team_contacts);

-- Corrected copy that previously named specific contacts (Camille, Jackie,
-- Denise, Alderman Pat Powell) as already-secured/engaged, which
-- contradicted the team not actually being confirmed yet.
update proposal_2027_sections set content = 'The team is not yet in place. Add names and titles below as each contact is confirmed, organized by agency — every field saves automatically as you type.', updated_at = now()
where section_key = 'permitting_team_intro';

update proposal_2027_sections set content = 'This is not a cold request. We are actively building the cross-agency relationships this proposal depends on — DCASE, the Chicago Park District, and the 3rd Ward''s office — alongside two community members already on board, Denise and Diedra, who lived the original festival era first-hand and have joined the planning committee specifically to help bring it back. This document lays out the case for the Seven Hills site, the team we are assembling, and what we''re asking the City and the 3rd Ward to help us secure next.', updated_at = now()
where section_key = 'exec_summary_p2';

update proposal_2027_sections set content = 'DCASE special event registration with the assigned DCASE contacts; coordinate multi-agency review with Police, Fire, and Public Health as required for the event''s scale.', updated_at = now()
where section_key = 'tl_3';

update proposal_2027_sections set content = 'SelassieFest 2027 is a chance to give Chicago back something it lost — not as a recreation, but as a living continuation, led in part by the very people who experienced its original run. With DCASE, the Chicago Park District, and the 3rd Ward''s office as the partners this plan depends on, and a community planning committee already in place, we''re asking the City to help us bring this home to Washington Park.', updated_at = now()
where section_key = 'closing_p1';

-- ─────────────────────────────────────────────────────────────────────────
-- Concise pass on the cover, plus two more 2027 goal bullets
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
-- Cover date-block dropped the redundant "Event date requested" line
-- (already stated in the executive summary and event overview) and kept
-- just the draft disclaimer. Note: "Planning committee already formed" ->
-- "Planning committee forming" is a static badge, not stored here.
update proposal_2027_sections set content = 'Draft — for internal review before submission', updated_at = now()
where section_key = 'cover_date_block';

insert into proposal_2027_sections (section_key, label, content)
values
  ('goal_bullet_4', '2027 Goal — Organizing body size', 'Increase the number of people on the organizing body'),
  ('goal_bullet_5', '2027 Goal — Address deficiencies', 'Improve all areas noted to be deficient')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Venue feasibility & master planning sequence -- verified, with owner
-- pills per phase (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
-- Replaces the old, shorter tl_1..tl_12 roadmap (left in place, unused) with
-- a verified, phase-by-phase sequence -- fact-checked against Chicago Park
-- District and City of Chicago sources (see commit message for what was
-- corrected: Pat Dowell not Pat Powell, Event Level thresholds, the DOB
-- stage/tent 45-day deadline not 60, and the DCASE fee-tier schedule).
-- Keys are prefixed vf_ ("venue feasibility") to stay distinct from this
-- table's other prefixes (cs_, seq_, gate_, siteissue_, cost_, etc.).
insert into proposal_2027_sections (section_key, label, content)
values
  ('vf_intro', 'Venue feasibility — intro', 'This is the detailed, verified version of our timeline — every claim below has been checked against Chicago Park District and City of Chicago sources. Dates marked "inferred" are projected from the last two years'' pattern and should be reconfirmed closer to the date.'),
  ('vf_gate_intro', 'Venue Gates — Intro', 'Planning should not stop while waiting to secure Washington Park. The work required to determine whether the site is feasible and to submit a complete permit application must begin immediately. However, major public or irreversible commitments should wait until the venue reaches the appropriate approval stage.'),
  ('vf_gate_stage_1', 'Gate stage 1', 'Application submitted — the venue is not secured.'),
  ('vf_gate_stage_2', 'Gate stage 2', 'Pending permit / conditional approval received — the date and location are tentatively accepted, subject to payments, insurance, plans and other permits.'),
  ('vf_gate_stage_3', 'Gate stage 3', 'Final Special Event Permit issued — the event is authorized to proceed under the approved conditions.'),
  ('vf_gate_note', 'Venue Gates — Park District note', 'Confirmed: submitting an application or paying the application fee does not grant permission to conduct the event. An accepted application receives a pending permit after a minimum 14-day review, identifying additional requirements and deadlines. The final permit is issued only after all requirements and payments are satisfied.'),
  ('vf_siteissue_1', 'Site Issue 1 — Official site identification', 'Confirmed: the Park District''s official name for the venue is Washington (George) Park, at 5531 S. King Drive. Its published facility list does not identify an area officially called "7 Hills" — that''s a community name, not an official Park District designation. The permit must show the exact field, lawn or geographic footprint on a detailed site map, described as something like: "Washington (George) Park — exact lawn area commonly known as ''7 Hills,'' as shown within the attached site-plan boundary." The Park District must confirm the approved official description.'),
  ('vf_siteissue_2', 'Site Issue 2 — Operating hours', 'Confirmed: Washington Park''s posted hours are 6:00 AM to 9:00 PM daily, and Park District rules generally restrict events to a park''s posted public operating hours. If SelassieFest intends to run noon to midnight, do not assume the park can accommodate that schedule — ask the Park District in writing whether it would approve amplified music after 9:00 PM, audience presence after 9:00 PM, vendor shutdown after 9:00 PM, stage strike and equipment removal after public hours, and overnight security or next-morning teardown. This is a venue-defining question — resolve it before spending money on application design, stage engineering or artist bookings.'),
  ('vf_siteissue_3', 'Site Issue 3 — Cannabis restrictions', 'The Park District''s application states that cannabis-derived products may not be consumed, sampled, sold or promoted through signage on Park District property. That potentially affects cannabis sponsor logos, swag bags, infused-product promotion, cannabis vendors, sampling or giveaways, consumption areas, and cannabis-related signage. SelassieFest can still discuss Rastafari culture and history, but commercial cannabis promotion at this venue may need to be removed or substantially restructured. Obtain a written interpretation from the assigned permit coordinator before finalizing any cannabis sponsorship.'),
  ('vf_phase1', 'Phase 1 — Applicant and Scope', 'Select the legal permit applicant — the organization that will legally hold the Park District permit, with its legal entity name, authorized signatory, EIN/nonprofit status, mailing address, festival bank account, and named people responsible for insurance, permit compliance, and Park District communication. The permit is not transferable, so the correct entity must apply from the start.

Approve a preliminary festival scope: expected attendance, admission model, hours, setup/teardown dates, stage design, vendor counts, sponsors, alcohol, generators, fencing, toilets, security/medical, children''s area, elder/accessible seating, and parking/loading needs. Confirmed Event Levels: 1-200 (Level 1), 201-500 (Level 2), 501-1,000 (Level 3), 1,001-3,000 (Level 4), 3,001-10,000 (Level 5), 10,000+ (Level 6, requiring provisional Park District Board approval). At 550 expected attendees, SelassieFest falls into Event Level 3.'),
  ('vf_phase2', 'Phase 2 — Venue Feasibility', 'Request a formal site walk with the Washington Park supervisor, Janie M. Collins (773-256-1248, 5531 S. King Drive). Bring an aerial map, proposed stage dimensions, attendance estimate, entrance locations, hours, vendor count, setup/teardown needs, utility questions, and photos of the "7 Hills" area.

Get preliminary answers on: 7 Hills availability for July 24, 2027; the official site designation; crowd/lawn capacity; roofed-stage feasibility; staking and equipment truck access; noon-to-midnight hours; amplified music and speaker direction; alcohol and cannabis restrictions; restroom/dumpster placement; accessible and emergency-vehicle routes; conflicts with other park programming; setup/teardown dates; rain/turf restoration; and a backup area within the park.

Make a written go/no-go decision. Proceed only if the venue supports the desired hours, capacity, stage and roof, amplified programming, vendors, security/emergency access, and adequate setup/teardown.'),
  ('vf_phase3', 'Phase 3 — Community Engagement', 'Brief the 3rd Ward office (Alderman Pat Dowell, ward03@cityofchicago.org, 773-373-9273) on the cultural mission, proposed date/hours, attendance estimate, community benefits, safety concept, notification plan, cleanup commitment, and preliminary site plan. The alderperson''s office doesn''t replace Park District permitting authority, but early support matters.

Meet the Washington Park Advisory Council (President Cecilia Butler, 773-667-4160; meets the 3rd Wednesday of the month at 7:00 PM) for community input, knowledge of the "7 Hills" area, and recommendations on sound, traffic, and cleanup.'),
  ('vf_phase4', 'Phase 4 — Application Package', 'Produce the preliminary site plan: festival boundary, stage/roof footprint, speaker locations, FOH position, exits, entrances, security screening, fencing, vendor and sponsor booths, children''s area, elder/accessible seating, first-aid, ambulance position, command post, toilets, generators, dumpsters, water stations, artist compound, staff check-in, and any requested street or sidewalk use.

Prepare three choices: first choice is July 24, 2027 at the exact 7 Hills footprint; second choice is an alternate area within Washington Park; third choice is an alternate date or Park District location — availability generally can''t be confirmed before review, so alternatives are recommended.

Prepare an application-ready package before the 2027 portal opens (as of this writing, the Park District site shows 2025 and 2026 links but not yet 2027): applicant info, event narrative, attendance estimate, site plan, schedule, vendor plan, preliminary security/medical plans, alcohol decision, sponsorship list, stage/tent/generator specs, and backup dates/sites.'),
  ('vf_now_dates', 'Night Out in the Parks — application opens', 'Night Out in the Parks and Chicago Onscreen 2027 season application opens through the Chicago Park District — a separate, supplemental city-backed programming opportunity alongside the main site permit.'),
  ('vf_phase5', 'Phase 5 — Submit', 'Pay the application fee first — the current procedure requires the non-refundable, non-transferable fee before submission because the receipt number is required (confirm the current amount when the 2027 cycle opens).

Submit the completed application and site plan — not a placeholder, which can lose its processing position or be delayed.

Monitor daily. Review takes a minimum of 14 days and can result in conditional approval, a request for more information, an alternate site/date offer, or denial with explanation.'),
  ('vf_now_deadline', 'Night Out in the Parks — proposal deadline', 'Night Out in the Parks 2027 proposal deadline, 11:59 PM, if applying to that program.'),
  ('vf_phase6', 'Phase 6 — City of Chicago / DCASE Permit', 'File with DCASE as early as possible if the event includes merchandise sales, alcohol, food preparation triggering city review, tents over 400 sq ft, a stage over two feet, or street/public-way use. Confirmed: DCASE will not accept applications less than 21 days before the event, and processing fees rise the later you file — $100 (180-60 days out), $200 (59-45 days), $500 (44-37 days), $1,000 (36-29 days), $2,000 (28-21 days). For July 24, 2027, the 180-day point is approximately January 25, 2027 — filing early is a real cost saving, not just a best practice.'),
  ('vf_now_confirm', 'Night Out in the Parks — confirm schedule', 'If selected for Night Out in the Parks, confirm the performance schedule — that program''s usual mid-March deadline.'),
  ('vf_phase7', 'Phase 7 — Production and Compliance', 'Contract the stage and production team. The One Umbrella roof will likely need a City of Chicago Department of Buildings (DOB) permit — tents/canopies over 400 sq ft, or stages over two feet high or with roofing/wings, require a DOB permit supported by a Park District verification letter (template in the DCASE special events package). Submit this paperwork to DOB at least 45 days before the event.

Finalize security and medical: confirmed Park District rules require a security plan for 500+ attendees or any event with alcohol — our planned 550 exceeds that threshold. An EMS Region XI-approved medical provider must be on site for the full permit duration.

Finalize insurance: confirmed at least $1 million in general liability ($2 million if serving alcohol), Park District named as additional insured on a primary, non-contributory basis, covering all setup/event/teardown dates. Certificate and endorsement must be received and approved at least 48 hours before setup begins.'),
  ('vf_gate1', 'Gate 1 — Conditional venue approval', 'This is the point the venue becomes tentatively secured. Upon receiving the pending permit: review every deadline and condition, pay the first required installment or deposit, confirm the exact permitted footprint and hours, confirm the attendance classification, confirm alcohol/cannabis restrictions, request required Park District support letters, and update the master site plan and compliance calendar. Only after this gate should major festival commitments begin.'),
  ('vf_90', 'Countdown — 90 days out', 'Freeze the event footprint; confirm final attendance projection, stage count, alcohol decision, sponsor activation types, and major contractors; complete the community presentation; establish refund/cancellation exposure.'),
  ('vf_60', 'Countdown — 60 days out', 'Begin the DCASE alcohol process (if applicable), liquor-license process, generator permits, food/vendor licensing, fire-safety review, final structural engineering, and the transportation/traffic plan, so nothing is rushed against the 45-day deadlines below.'),
  ('vf_45', 'Countdown — 45 days out', 'Two confirmed 45-day deadlines: submit stage/tent DOB paperwork and Park District verification letters, and — if serving alcohol or using the public way — submit to the police district commander and Alderman Dowell''s office, confirm licensed security, and finalize the crowd-control and alcohol-perimeter/age-verification plans.'),
  ('vf_30', 'Countdown — 30 days out', 'Submit all outside agency permits to the Park District; freeze the site plan; submit final security, medical, stage, tent, generator, vendor, food, sanitation, and accessibility plans; confirm emergency contacts and setup/teardown schedules.'),
  ('vf_liquor', 'Countdown — Liquor license', 'Submit the special event liquor license application (Special Event Retailer''s License, Not-For-Profit track), if alcohol service is planned. City rules require filing at least 20 calendar days before the event, with the ward alderman notified at least 5 days before the license is issued.'),
  ('vf_14', 'Countdown — 14 days out', 'Pay the remaining Park District balance; confirm the insurance certificate and endorsement, contractor certificates, and accessible toilet count; issue final credentials; submit the final vendor roster; complete the final Park District walkthrough; confirm final permit issuance.'),
  ('vf_finalweek', 'Countdown — Final week', 'Command-team tabletop exercise; test radios; confirm weather-monitoring responsibility; issue vendor arrival appointments; mark the approved site; verify underground utilities before staking; inspect stage and tents; sound-system test only during approved hours; place toilets, waste stations, and barricades; complete fire, building, and Park District inspections; keep a copy of the permit onsite.'),
  ('vf_eventday', 'Countdown — Event day', 'SelassieFest 2027, event day.'),
  ('vf_start_now', 'Gate — Start now', 'Legal applicant selection
Site feasibility
Park meeting
Community outreach
Attendance planning
Preliminary budgeting
Preliminary site design
Permit preparation
Backup-site research'),
  ('vf_wait_pending', 'Gate — Wait for pending permit', 'Nonrefundable artist deposits
Nonrefundable equipment deposits
Guaranteed sponsor benefits tied to Washington Park
Final vendor-space sales
Major printing
Public announcement that Washington Park is confirmed'),
  ('vf_after_pending', 'Gate — OK after pending permit', 'Artist negotiations
Sponsor agreements
Vendor recruitment
Production bids
Stage engineering
Security-company negotiations
Medical-provider negotiations
Equipment rentals
Volunteer recruitment
Community outreach
Grant applications'),
  ('vf_pending_note', 'Gate — Pending permit note', 'Contracts should be contingent on receipt and continued validity of all government and Park District permits. Public promotion before the final permit remains at the organizer''s risk — the Park District doesn''t guarantee approval, and promotional expenses before permit issuance are the organizer''s responsibility.'),
  ('vf_wait_final', 'Gate — Wait for final permit', 'Ticket sales
Unconditional artist contracts
Unconditional production contracts
Large media purchases
Nonrefundable travel
Public claims that the event is officially approved'),
  ('vf_immediate_action', 'Immediate next action', 'Not artist booking or sponsor recruitment. It is a formal site walk and written feasibility meeting addressing the exact 7 Hills footprint, the 9:00 PM park closing time, the One Umbrella stage, and the cannabis-promotion restrictions.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Title change to "Planning Committee" and the confirmed Pat Dowell
-- corrections applied directly in the proposal's own HTML this round
-- (/organization/selassiefest-2027-proposal.html)
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set content = 'SelassieFest Saturday, July 24, 2027 — Planning Committee', updated_at = now()
where section_key = 'cover_title';

update proposal_2027_sections set content = 'Prepared for: Chicago Park District · Dept. of Cultural Affairs & Special Events (DCASE) · Office of Alderman Pat Dowell, 3rd Ward', updated_at = now()
where section_key = 'cover_meta';

update proposal_2027_sections set content = 'Request a letter of support from Alderman Pat Dowell''s office and begin the required 3rd Ward community notification.', updated_at = now()
where section_key = 'tl_5';

update proposal_2027_sections set content = 'A letter of support and community notification assistance from Alderman Pat Dowell''s 3rd Ward office.', updated_at = now()
where section_key = 'ask_3';

-- ─────────────────────────────────────────────────────────────────────────
-- Same-round corrections applied to the committee-structure page's own
-- copy of this content (/organization/selassiefest-2027-committee-structure.html)
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set content = 'ward03@cityofchicago.org · 773-373-9273. Alderman Pat Dowell is confirmed correct (verified against chicago.gov''s official ward page and Wikipedia) — "Alderman Pat Powell," used earlier in this proposal''s drafting, was incorrect and has been corrected throughout.', updated_at = now()
where section_key = 'venuecontact_ward3';

update proposal_2027_sections set content = 'Step 2 — Approve a preliminary festival scope: expected attendance, admission model, festival hours, setup/teardown dates, stage count and design, vendor counts, sponsors, alcohol, generators, fencing, toilets, security/medical, children''s area, elder/accessible seating, and parking/rideshare/loading needs. Attendance matters because the permit level, deposit, fees and review requirements change with crowd size — verified Event Levels are 1-200 (Level 1), 201-500 (Level 2), 501-1,000 (Level 3), 1,001-3,000 (Level 4), 3,001-10,000 (Level 5), and 10,000+ (Level 6, which requires provisional Park District Board approval and additional community engagement). At an expected 550 attendees, SelassieFest falls into Event Level 3.', updated_at = now()
where section_key = 'seq_phase1';

update proposal_2027_sections set content = 'Step 15 — Contract the stage and production team. The One Umbrella roof will likely be treated as a roofed stage or platform requiring additional review — tents/canopies over 400 square feet, or stages/platforms over two feet high or with roofing or wings, require a City of Chicago Department of Buildings (DOB) permit, supported by a Park District verification letter (using the template in the DCASE special events package). Submit this paperwork to DOB at least 45 days before the event. Obtain engineered stage drawings, wind-rating documentation, ballast/staking plan, structural calculations, lighting plot, sound-system specifications, generator/grounding plan, emergency stage-evacuation procedure, and load-in/out schedule.

Step 16 — Finalize security and medical providers. Confirmed Park District requirements call for a security plan for events with 500 or more attendees or events involving alcohol — SelassieFest''s planned 550 attendance exceeds that threshold. An EMS Region XI-approved medical provider must be on site for the full permit duration. Security plans are subject to Park District approval. Complete the security staffing matrix, entrance screening plan, prohibited-items procedure, emergency evacuation plan, severe-weather plan, missing-child procedure, artist security, cash-handling security, medical staffing, ambulance access, incident-reporting system, and command-post structure.

Step 17 — Finalize insurance. Confirmed requirements: at least $1 million in general liability coverage ($2 million if serving alcohol), with the Park District named as an additional insured on a primary, non-contributory basis, covering all setup, event and teardown dates. Both a certificate of insurance and a policy endorsement are required, and must be received and approved at least 48 hours before event setup begins. Additional coverage may be needed for alcohol liquor liability, animals, inflatables, amusement devices, contractors, vehicles and workers'' compensation.', updated_at = now()
where section_key = 'seq_phase7';

update proposal_2027_sections set content = 'Begin the DCASE alcohol process (if applicable), the liquor-license process, generator permits if required, food and vendor licensing, fire-safety review, final structural engineering, and the transportation and traffic plan, so nothing is rushed against the 45-day deadlines below.', updated_at = now()
where section_key = 'seq_60';

update proposal_2027_sections set content = 'Two confirmed 45-day deadlines: submit stage/tent Department of Buildings paperwork and Park District verification letters, and — where alcohol or relevant public-way activity is involved — submit material to the appropriate police commander and Alderman Dowell''s 3rd Ward office, confirm licensed security, and finalize the crowd-control plan and alcohol perimeter/age verification.', updated_at = now()
where section_key = 'seq_45';

-- ─────────────────────────────────────────────────────────────────────────
-- Ras Tafari Inc.'s confirmed legal entity facts (IRS determination letter
-- + Illinois certified Articles of Incorporation), replacing the
-- hypothetical "select a legal applicant" framing in Phase 1 on both pages
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set content = 'Legal permit applicant confirmed: Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6) and an IRS-recognized 501(c)(3) public charity under 509(a)(2) — EIN 42-3036705, exemption effective June 9, 2026, annual Form 990/990-EZ/990-N filing required. Registered agent and incorporator: Stephen Henry. Mailing address: 765 E 154th St, South Holland, IL 60473. Board of Directors: Stephen Henry, Paul Kelly, and Albert Harris. Still open: the dedicated festival bank account, and which of these three (or another named person) is assigned insurance, permit compliance, and Park District communication responsibility — that assignment should come from the Board, not be assumed. The permit is not transferable, so this is the correct entity to apply from the start.', updated_at = now()
where section_key = 'vf_phase1';

update proposal_2027_sections set content = 'Step 1 — Legal permit applicant confirmed: Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6) and an IRS-recognized 501(c)(3) public charity under 509(a)(2) — EIN 42-3036705, exemption effective June 9, 2026, annual Form 990/990-EZ/990-N filing required. Registered agent and incorporator: Stephen Henry. Mailing address: 765 E 154th St, South Holland, IL 60473. Board of Directors: Stephen Henry, Paul Kelly, and Albert Harris. Still open: the dedicated festival bank account, and which of these three (or another named person) is assigned insurance, permit compliance, and Park District communication responsibility — that assignment should come from the Board, not be assumed. The application and permit are not transferable, so this is the correct entity to apply from the start.', updated_at = now()
where section_key = 'seq_phase1';

insert into proposal_2027_sections (section_key, label, content)
values
  ('legal_entity_summary', 'Legal Entity — Confirmed', 'Ras Tafari Inc. is an Illinois domestic not-for-profit corporation, incorporated June 8, 2026 and in good standing (File #7559-872-6), and an IRS-recognized 501(c)(3) public charity under 509(a)(2) — EIN 42-3036705, exemption effective June 9, 2026, with annual Form 990/990-EZ/990-N filing required. Registered agent and incorporator: Stephen Henry. Mailing address: 765 E 154th St, South Holland, IL 60473. This is the confirmed legal entity that will hold the Park District permit.'),
  ('legal_entity_board', 'Legal Entity — Board of Directors', 'Board of Directors (per the Articles of Incorporation):
Stephen Henry
Paul Kelly
Albert Harris'),
  ('legal_entity_open', 'Legal Entity — Still open', 'Still open, and a Board decision rather than an assumption: the dedicated festival bank account, and which of these three (or another named person) is formally assigned insurance, permit compliance, and Park District communication responsibility.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Bank account and responsibility assignments confirmed (Chase Bank /
-- Field Marshall / Brother JahSyll), resolving what the legal_entity_open
-- field above had flagged as still needing a Board decision
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set content = 'Legal permit applicant confirmed: Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6) and an IRS-recognized 501(c)(3) public charity under 509(a)(2) — EIN 42-3036705, exemption effective June 9, 2026, annual Form 990/990-EZ/990-N filing required. Registered agent and incorporator: Stephen Henry. Mailing address: 765 E 154th St, South Holland, IL 60473. Board of Directors: Stephen Henry, Paul Kelly, and Albert Harris. Festival bank account: Chase Bank. Insurance and permit-compliance responsibility: Field Marshall. Park District communication responsibility: Brother JahSyll. The permit is not transferable, so this is the correct entity to apply from the start.', updated_at = now()
where section_key = 'vf_phase1';

update proposal_2027_sections set content = 'Step 1 — Legal permit applicant confirmed: Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6) and an IRS-recognized 501(c)(3) public charity under 509(a)(2) — EIN 42-3036705, exemption effective June 9, 2026, annual Form 990/990-EZ/990-N filing required. Registered agent and incorporator: Stephen Henry. Mailing address: 765 E 154th St, South Holland, IL 60473. Board of Directors: Stephen Henry, Paul Kelly, and Albert Harris. Festival bank account: Chase Bank. Insurance and permit-compliance responsibility: Field Marshall. Park District communication responsibility: Brother JahSyll. The application and permit are not transferable, so this is the correct entity to apply from the start.', updated_at = now()
where section_key = 'seq_phase1';

update proposal_2027_sections set label = 'Legal Entity — Assignments', content = 'Confirmed assignments: festival bank account is held at Chase Bank; insurance and permit-compliance responsibility is assigned to Field Marshall; Park District communication responsibility is assigned to Brother JahSyll.', updated_at = now()
where section_key = 'legal_entity_open';

-- ─────────────────────────────────────────────────────────────────────────
-- Restructured the legal-applicant facts into a bulleted list (bold label +
-- editable content per line, e.g. "Applicant: Ras Tafari Inc.") in all
-- three places it appears: the proposal's Phase 1 row (vf_app_*), the
-- committee-structure page's Phase 1 row (cs_app_*), and the standalone
-- "Legal entity — confirmed" card (legal_entity_applicant etc., reusing
-- legal_entity_board with a shorter single-line value now that the label
-- itself is a separate bold heading). vf_phase1 and seq_phase1 are
-- narrowed to hold only the Step 2 "preliminary festival scope" text now
-- that Step 1's content lives in its own bullet fields. legal_entity_summary
-- and legal_entity_open are left in place, unused.
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set label = 'Phase 1 — Scope', content = 'Approve a preliminary festival scope: expected attendance, admission model, hours, setup/teardown dates, stage design, vendor counts, sponsors, alcohol, generators, fencing, toilets, security/medical, children''s area, elder/accessible seating, and parking/loading needs. Confirmed Event Levels: 1-200 (Level 1), 201-500 (Level 2), 501-1,000 (Level 3), 1,001-3,000 (Level 4), 3,001-10,000 (Level 5), 10,000+ (Level 6, requiring provisional Park District Board approval). At 550 expected attendees, SelassieFest falls into Event Level 3.', updated_at = now()
where section_key = 'vf_phase1';

update proposal_2027_sections set label = 'Phase 1 — Scope', content = 'Approve a preliminary festival scope: expected attendance, admission model, festival hours, setup/teardown dates, stage count and design, vendor counts, sponsors, alcohol, generators, fencing, toilets, security/medical, children''s area, elder/accessible seating, and parking/rideshare/loading needs. Attendance matters because the permit level, deposit, fees and review requirements change with crowd size — verified Event Levels are 1-200 (Level 1), 201-500 (Level 2), 501-1,000 (Level 3), 1,001-3,000 (Level 4), 3,001-10,000 (Level 5), and 10,000+ (Level 6, which requires provisional Park District Board approval and additional community engagement). At an expected 550 attendees, SelassieFest falls into Event Level 3.', updated_at = now()
where section_key = 'seq_phase1';

update proposal_2027_sections set content = 'Stephen Henry, Paul Kelly, and Albert Harris', updated_at = now()
where section_key = 'legal_entity_board';

insert into proposal_2027_sections (section_key, label, content)
values
  ('vf_app_entity', 'Applicant — Legal entity', 'Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6)'),
  ('vf_app_tax', 'Applicant — Tax status', 'IRS-recognized 501(c)(3) public charity under 509(a)(2)'),
  ('vf_app_ein', 'Applicant — EIN', '42-3036705 (exemption effective June 9, 2026; annual Form 990/990-EZ/990-N filing required)'),
  ('vf_app_agent', 'Applicant — Registered agent', 'Stephen Henry'),
  ('vf_app_address', 'Applicant — Mailing address', '765 E 154th St, South Holland, IL 60473'),
  ('vf_app_board', 'Applicant — Board of Directors', 'Stephen Henry, Paul Kelly, and Albert Harris'),
  ('vf_app_bank', 'Applicant — Bank account', 'Chase Bank'),
  ('vf_app_insurance', 'Applicant — Insurance and compliance', 'Field Marshall'),
  ('vf_app_parkcomm', 'Applicant — Park District communication', 'Brother JahSyll'),
  ('vf_app_note', 'Applicant — note', 'The permit is not transferable, so this is the correct entity to apply from the start.'),
  ('cs_app_entity', 'Applicant — Legal entity', 'Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6)'),
  ('cs_app_tax', 'Applicant — Tax status', 'IRS-recognized 501(c)(3) public charity under 509(a)(2)'),
  ('cs_app_ein', 'Applicant — EIN', '42-3036705 (exemption effective June 9, 2026; annual Form 990/990-EZ/990-N filing required)'),
  ('cs_app_agent', 'Applicant — Registered agent', 'Stephen Henry'),
  ('cs_app_address', 'Applicant — Mailing address', '765 E 154th St, South Holland, IL 60473'),
  ('cs_app_board', 'Applicant — Board of Directors', 'Stephen Henry, Paul Kelly, and Albert Harris'),
  ('cs_app_bank', 'Applicant — Bank account', 'Chase Bank'),
  ('cs_app_insurance', 'Applicant — Insurance and compliance', 'Field Marshall'),
  ('cs_app_parkcomm', 'Applicant — Park District communication', 'Brother JahSyll'),
  ('cs_app_note', 'Applicant — note', 'The application and permit are not transferable, so this is the correct entity to apply from the start.'),
  ('legal_entity_applicant', 'Legal Entity — Applicant', 'Ras Tafari Inc., an Illinois domestic not-for-profit corporation (incorporated June 8, 2026, in good standing, File #7559-872-6)'),
  ('legal_entity_tax', 'Legal Entity — Tax status', 'IRS-recognized 501(c)(3) public charity under 509(a)(2)'),
  ('legal_entity_ein', 'Legal Entity — EIN', '42-3036705 (exemption effective June 9, 2026; annual Form 990/990-EZ/990-N filing required)'),
  ('legal_entity_agent', 'Legal Entity — Registered agent', 'Stephen Henry'),
  ('legal_entity_address', 'Legal Entity — Mailing address', '765 E 154th St, South Holland, IL 60473'),
  ('legal_entity_bank', 'Legal Entity — Bank account', 'Chase Bank'),
  ('legal_entity_insurance', 'Legal Entity — Insurance and compliance', 'Field Marshall'),
  ('legal_entity_parkcomm', 'Legal Entity — Park District communication', 'Brother JahSyll'),
  ('legal_entity_note', 'Legal Entity — note', 'This is the confirmed legal entity that will hold the Park District permit.')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Broke the proposal's Master Planning Sequence (Phases 2-7) and Countdown
-- Milestones out of single run-on paragraphs into bold-label bullet lists,
-- matching the Phase 1 row's format, and paired each phase/milestone card
-- with a date/phase pill alongside its committee owner-pill(s) (markup-only
-- change, see proposal.html). Also surfaced two already-confirmed real facts
-- that were previously only stated in Phase 1 (vf_phase2_parkcomm =
-- Brother JahSyll, vf_phase5_payment = Chase Bank; vf_phase7_owner =
-- Field Marshall) into the specific phases they're actually relevant to.
-- The old single-paragraph keys they replace (vf_phase2 .. vf_phase7,
-- vf_90, vf_60, vf_45, vf_30, vf_liquor, vf_14, vf_finalweek) are deleted
-- below. vf_now_dates, vf_now_deadline, vf_now_confirm, vf_eventday and
-- vf_gate1 are unchanged in content — only their surrounding markup moved
-- into the new card format.
-- ─────────────────────────────────────────────────────────────────────────
delete from proposal_2027_sections
where section_key in (
  'vf_phase2', 'vf_phase3', 'vf_phase4', 'vf_phase5', 'vf_phase6', 'vf_phase7',
  'vf_90', 'vf_60', 'vf_45', 'vf_30', 'vf_liquor', 'vf_14', 'vf_finalweek'
);

insert into proposal_2027_sections (section_key, label, content)
values
  ('vf_phase2_contact', 'Phase 2 — Site walk contact', 'Washington Park supervisor Janie M. Collins (773-256-1248, 5531 S. King Drive)'),
  ('vf_phase2_bring', 'Phase 2 — Bring to the walk', 'An aerial map, proposed stage dimensions, attendance estimate, entrance locations, hours, vendor count, setup/teardown needs, utility questions, and photos of the "7 Hills" area'),
  ('vf_phase2_questions', 'Phase 2 — Preliminary answers needed', '7 Hills availability for July 24, 2027; the official site designation; crowd/lawn capacity; roofed-stage feasibility; staking and equipment truck access; noon-to-midnight hours; amplified music and speaker direction; alcohol and cannabis restrictions; restroom/dumpster placement; accessible and emergency-vehicle routes; conflicts with other park programming; setup/teardown dates; rain/turf restoration; and a backup area within the park'),
  ('vf_phase2_decision', 'Phase 2 — Go/no-go decision', 'Proceed only if the venue supports the desired hours, capacity, stage and roof, amplified programming, vendors, security/emergency access, and adequate setup/teardown'),
  ('vf_phase2_parkcomm', 'Phase 2 — Park District communication owner', 'Brother JahSyll'),

  ('vf_phase3_ward', 'Phase 3 — 3rd Ward briefing', 'Brief the 3rd Ward office (Alderman Pat Dowell, ward03@cityofchicago.org, 773-373-9273) on the cultural mission, proposed date/hours, attendance estimate, community benefits, safety concept, notification plan, cleanup commitment, and preliminary site plan. The alderperson''s office doesn''t replace Park District permitting authority, but early support matters'),
  ('vf_phase3_council', 'Phase 3 — Community advisory council', 'Meet the Washington Park Advisory Council (President Cecilia Butler, 773-667-4160; meets the 3rd Wednesday of the month at 7:00 PM) for community input, knowledge of the "7 Hills" area, and recommendations on sound, traffic, and cleanup'),

  ('vf_phase4_siteplan', 'Phase 4 — Site plan elements', 'Festival boundary, stage/roof footprint, speaker locations, FOH position, exits, entrances, security screening, fencing, vendor and sponsor booths, children''s area, elder/accessible seating, first-aid, ambulance position, command post, toilets, generators, dumpsters, water stations, artist compound, staff check-in, and any requested street or sidewalk use'),
  ('vf_phase4_choices', 'Phase 4 — Site/date choices', 'First choice — July 24, 2027 at the exact 7 Hills footprint. Second choice — an alternate area within Washington Park. Third choice — an alternate date or Park District location. Availability generally can''t be confirmed before review, so alternatives are recommended'),
  ('vf_phase4_package', 'Phase 4 — Application package contents', 'Applicant info, event narrative, attendance estimate, site plan, schedule, vendor plan, preliminary security/medical plans, alcohol decision, sponsorship list, stage/tent/generator specs, and backup dates/sites'),
  ('vf_phase4_portal', 'Phase 4 — 2027 portal status', 'As of this writing, the Park District site shows 2025 and 2026 links but not yet 2027 — prepare the package ready to submit the moment the 2027 portal opens'),

  ('vf_phase5_fee', 'Phase 5 — Pay the application fee first', 'The current procedure requires the non-refundable, non-transferable fee before submission because the receipt number is required (confirm the current amount when the 2027 cycle opens)'),
  ('vf_phase5_payment', 'Phase 5 — Payment source', 'Chase Bank festival account'),
  ('vf_phase5_submit', 'Phase 5 — Submit the complete package', 'The completed application and site plan — not a placeholder, which can lose its processing position or be delayed'),
  ('vf_phase5_monitor', 'Phase 5 — Monitor daily', 'Review takes a minimum of 14 days and can result in conditional approval, a request for more information, an alternate site/date offer, or denial with explanation'),

  ('vf_phase6_trigger', 'Phase 6 — When filing is required', 'If the event includes merchandise sales, alcohol, food preparation triggering city review, tents over 400 sq ft, a stage over two feet, or street/public-way use'),
  ('vf_phase6_notice', 'Phase 6 — Minimum notice', 'DCASE will not accept applications less than 21 days before the event'),
  ('vf_phase6_fees', 'Phase 6 — Fee schedule', '$100 (180-60 days out), $200 (59-45 days), $500 (44-37 days), $1,000 (36-29 days), $2,000 (28-21 days)'),
  ('vf_phase6_deadline', 'Phase 6 — Filing deadline for this date', 'For July 24, 2027, the 180-day point is approximately January 25, 2027 — filing early is a real cost saving, not just a best practice'),

  ('vf_phase7_stage', 'Phase 7 — Stage/roof permit', 'The One Umbrella roof will likely need a City of Chicago Department of Buildings (DOB) permit — tents/canopies over 400 sq ft, or stages over two feet high or with roofing/wings, require a DOB permit supported by a Park District verification letter (template in the DCASE special events package). Submit this paperwork to DOB at least 45 days before the event'),
  ('vf_phase7_security', 'Phase 7 — Security and medical', 'Confirmed Park District rules require a security plan for 500+ attendees or any event with alcohol — our planned 550 exceeds that threshold. An EMS Region XI-approved medical provider must be on site for the full permit duration'),
  ('vf_phase7_insurance', 'Phase 7 — Insurance', 'Confirmed at least $1 million in general liability ($2 million if serving alcohol), Park District named as additional insured on a primary, non-contributory basis, covering all setup/event/teardown dates. Certificate and endorsement must be received and approved at least 48 hours before setup begins'),
  ('vf_phase7_owner', 'Phase 7 — Insurance and permit-compliance owner', 'Field Marshall'),

  ('vf_90_freeze', 'Countdown 90 — Freeze', 'The event footprint'),
  ('vf_90_confirm', 'Countdown 90 — Confirm', 'Final attendance projection, stage count, alcohol decision, sponsor activation types, and major contractors'),
  ('vf_90_presentation', 'Countdown 90 — Complete', 'The community presentation'),
  ('vf_90_exposure', 'Countdown 90 — Establish', 'Refund/cancellation exposure'),

  ('vf_60_begin', 'Countdown 60 — Begin these processes', 'DCASE alcohol process (if applicable), liquor-license process, generator permits, food/vendor licensing, fire-safety review, final structural engineering, and the transportation/traffic plan'),
  ('vf_60_why', 'Countdown 60 — Why now', 'So nothing is rushed against the 45-day deadlines below'),

  ('vf_45_dob', 'Countdown 45 — DOB deadline', 'Submit stage/tent DOB paperwork and Park District verification letters'),
  ('vf_45_safety', 'Countdown 45 — Public safety deadline', 'Submit to the police district commander and Alderman Dowell''s office, confirm licensed security, and finalize the crowd-control and alcohol-perimeter/age-verification plans'),

  ('vf_30_submitagency', 'Countdown 30 — Submit', 'All outside agency permits to the Park District'),
  ('vf_30_freeze', 'Countdown 30 — Freeze', 'The site plan'),
  ('vf_30_finalplans', 'Countdown 30 — Submit final plans', 'Security, medical, stage, tent, generator, vendor, food, sanitation, and accessibility plans'),
  ('vf_30_confirm', 'Countdown 30 — Confirm', 'Emergency contacts and setup/teardown schedules'),

  ('vf_liquor_app', 'Countdown — Liquor license application', 'Special Event Retailer''s License, Not-For-Profit track — if alcohol service is planned'),
  ('vf_liquor_deadline', 'Countdown — Liquor license filing deadline', 'At least 20 calendar days before the event'),
  ('vf_liquor_notice', 'Countdown — Liquor license alderman notice', 'Ward alderman notified at least 5 days before the license is issued'),

  ('vf_14_pay', 'Countdown 14 — Pay', 'The remaining Park District balance'),
  ('vf_14_confirminsurance', 'Countdown 14 — Confirm insurance', 'The insurance certificate and endorsement, contractor certificates, and accessible toilet count'),
  ('vf_14_credentials', 'Countdown 14 — Issue credentials', 'Final credentials'),
  ('vf_14_vendor', 'Countdown 14 — Submit vendor roster', 'The final vendor roster'),
  ('vf_14_walkthrough', 'Countdown 14 — Complete walkthrough', 'The final Park District walkthrough'),
  ('vf_14_permit', 'Countdown 14 — Confirm permit issuance', 'Final permit issuance'),

  ('vf_finalweek_1', 'Final week — Item 1', 'Command-team tabletop exercise'),
  ('vf_finalweek_2', 'Final week — Item 2', 'Test radios'),
  ('vf_finalweek_3', 'Final week — Item 3', 'Confirm weather-monitoring responsibility'),
  ('vf_finalweek_4', 'Final week — Item 4', 'Issue vendor arrival appointments'),
  ('vf_finalweek_5', 'Final week — Item 5', 'Mark the approved site'),
  ('vf_finalweek_6', 'Final week — Item 6', 'Verify underground utilities before staking'),
  ('vf_finalweek_7', 'Final week — Item 7', 'Inspect stage and tents'),
  ('vf_finalweek_8', 'Final week — Item 8', 'Sound-system test only during approved hours'),
  ('vf_finalweek_9', 'Final week — Item 9', 'Place toilets, waste stations, and barricades'),
  ('vf_finalweek_10', 'Final week — Item 10', 'Complete fire, building, and Park District inspections'),
  ('vf_finalweek_11', 'Final week — Item 11', 'Keep a copy of the permit onsite')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Sourced from DCASE's official "Special Event Permit Tutorial" PDF
-- (chicago.gov/.../dca/permit_app/sepermittutorial.pdf), replacing generic/
-- hypothetical language in Phase 4, Phase 6, Phase 7 and the Liquor License
-- countdown card with confirmed specifics: named Service Providers
-- (incl. Streets & Sanitation contact and the Police/Fire prohibition),
-- the real required-document list and application mechanics, a corrected
-- explanation of the DCASE fee-tier timing (no savings from filing right
-- at 180 days vs. any time past 60 days), refined liquor-license facts
-- (COI content, Police Commander/property letter, City app not required
-- for a not-for-profit), and a new Food Vendor Licensing card that also
-- fills the previously-identified gap of no phase/countdown card carrying
-- the "Vendors, Food, Beverage & Marketplace" committee pill.
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set label = 'Phase 6 — Earliest submission date', content = 'Confirmed: DCASE accepts applications starting 180 days before the event and will not accept them less than 21 days before. For July 24, 2027, the 180-day mark is January 25, 2027 — the earliest possible submission day (the tutorial specifies no particular time of day)', updated_at = now()
where section_key = 'vf_phase6_notice';

update proposal_2027_sections set label = 'Phase 6 — When filing is required', content = 'Confirmed per DCASE''s Special Event Permit Tutorial: streets closed or private property open to the public, liquor sold, food prepared outdoors, merchandise sold, tent(s) over 20''x20''/400 sq ft, and/or stage(s) over 24" tall', updated_at = now()
where section_key = 'vf_phase6_trigger';

update proposal_2027_sections set label = 'Phase 6 — Fee schedule', content = '$100 (60+ days out), $200 (59-45 days), $500 (44-37 days), $1,000 (36-29 days), $2,000 (28-21 days). Fees are based on when the application is COMPLETE and ready for DCASE review, not just submitted', updated_at = now()
where section_key = 'vf_phase6_fees';

update proposal_2027_sections set label = 'Phase 6 — Filing deadline for this date', content = 'Correction to an earlier assumption: the $100 minimum fee applies to any complete application filed more than 60 days before the event — there''s no added cost saving to filing at the 180-day mark specifically versus any time before the 60-day cutoff. The real benefit of filing as early as possible is avoiding the escalating fee tiers and leaving time to resolve follow-up questions', updated_at = now()
where section_key = 'vf_phase6_deadline';

update proposal_2027_sections set content = 'At least 20 calendar days before the event, confirmed per DCASE''s tutorial', updated_at = now()
where section_key = 'vf_liquor_deadline';

insert into proposal_2027_sections (section_key, label, content)
values
  ('vf_phase4_serviceproviders', 'Phase 4 — Named service providers', 'DCASE''s application has a dedicated "Service Providers" step requiring an actual named company (not a description) for each of: Ambulance/EMS Provider, Security Company, Type III Barricade/Traffic Management Company (only if closing a street), Portable Toilet Vendor, Propane Company, Producing Agent, and Waste Management Company. Chicago Police and Chicago Fire Department cannot be listed as the Security Company or Ambulance/EMS Provider — a licensed private security firm and private EMS provider must be named'),
  ('vf_streets_contact', 'Phase 4 — Streets and Sanitation contact', '(312) 744-1912 — contact at least 1 week before the event to arrange "No Parking" signage around the site, and ensure the named Waste Management Company (trash hauler/dumpster vendor) is entered on the Service Providers step; a generic waste-management description without a named vendor will be rejected'),
  ('vf_phase6_docs', 'Phase 6 — Required documents at submittal', 'Confirmed required for every event: Site Map, Security/Safety Plan, Certificate of Insurance, Emergency Action Plan, and Emergency Medical Services Plan, plus Marketing Materials. A Street Closure Template is required only if requesting a street closure — not expected to apply if the festival footprint stays entirely within the park'),
  ('vf_phase6_mechanics', 'Phase 6 — Application mechanics', 'Online only (no paper applications), submitted via Google Chrome; uploaded documents must be PDF or JPEG. Reference the application number in all DCASE correspondence. General Special Event Permit questions go to SEPermits@cityofchicago.org'),
  ('vf_phase7_policefire', 'Phase 7 — Cannot list Police or Fire as providers', 'Confirmed per DCASE''s Special Event Permit Tutorial: Chicago Police Department and Chicago Fire Department cannot be listed as the application''s Security Company or Ambulance/EMS Provider — a licensed private security firm and private EMS provider must be named instead'),
  ('vf_liquor_coi', 'Countdown — Liquor license COI', 'Confirmed required: must name the event, date(s), and location, and include liquor liability coverage'),
  ('vf_liquor_letter', 'Countdown — Liquor license police and property letter', 'Confirmed required: a letter from the police district commander and from the Park District as the property owner'),
  ('vf_liquor_stateapp', 'Countdown — City vs State liquor applications', 'Confirmed: because Ras Tafari Inc. is a registered not-for-profit, the separate City Liquor Application is not required (for-profit organizers only). A State of Illinois Liquor Application is still required regardless of nonprofit status, processed through the City of Chicago'),
  ('vf_food_deadline', 'Countdown — Food vendor filing deadline', 'Confirmed: each Single Event Food Booth or Food Truck application must be submitted at least 20 days before the event'),
  ('vf_food_docs', 'Countdown — Food vendor required documents', 'A Chicago Business Account number; a restaurant health inspection dated within the last 6 months (date of inspection if based in Chicago, a copy of the inspection if based outside Chicago); a food booth layout; a shared-kitchen affidavit if applicable; and Chicago Summer Sanitation Certification')
on conflict (section_key) do nothing;

-- ─────────────────────────────────────────────────────────────────────────
-- Confirmed the DCASE earliest-submission date (Monday, January 25, 2027)
-- with day-of-week added for calendaring. Expanded the "Start now" gate
-- list from a vague "Permit preparation" line into the specific DCASE
-- documents that can be drafted immediately, and added non-binding vendor
-- permit-readiness outreach. Added a 2027 food-vendor goal (2 -> 15) and,
-- on the Food Vendor Licensing countdown card, task-assignment bullets for
-- recruiting and tracking compliance for both food and non-food vendors —
-- tying the food-vendor task directly back to the 2026 Health Department
-- review's real "incomplete" note (missing inspection documentation).
-- ─────────────────────────────────────────────────────────────────────────
update proposal_2027_sections set content = 'Confirmed: DCASE accepts applications starting 180 days before the event and will not accept them less than 21 days before. For July 24, 2027, the 180-day mark is Monday, January 25, 2027 — the first day the application can be submitted (the tutorial specifies no particular time of day)', updated_at = now()
where section_key = 'vf_phase6_notice';

update proposal_2027_sections set content = 'Legal applicant selection
Site feasibility
Park meeting
Community outreach
Attendance planning
Preliminary budgeting
Preliminary site design
DCASE document drafting — Site Map, Security/Safety Plan, Emergency Action Plan, and Emergency Medical Services Plan can all be drafted now, well ahead of the January 25, 2027 earliest submission date (Certificate of Insurance and Marketing Materials are finalized closer to submission)
Vendor permit-readiness outreach — begin informal, non-binding solicitation of food and non-food vendors now so each has time to line up licenses/inspections before formal space is confirmed (final vendor-space sales still wait for conditional approval, below)
Backup-site research', updated_at = now()
where section_key = 'vf_start_now';

insert into proposal_2027_sections (section_key, label, content)
values
  ('goal_bullet_6', '2027 Goal — Food vendor count', 'Increase food vendors from 2 to 15'),
  ('vf_food_target', 'Countdown — 2027 food vendor target and owner', 'Target: 15 food vendors for 2027 (up from 2 in 2026). Assign a team member from the Vendors, Food, Beverage & Marketplace committee to solicit all 15 and confirm each has completed their Chicago Business Account, health inspection, and Chicago Summer Sanitation Certification well ahead of the 20-day filing deadline — our 2026 permit''s Health Department review was initially marked incomplete for exactly this kind of missing documentation'),
  ('vf_nonfood_vendor', 'Countdown — Non-food vendor recruitment and compliance', 'Assign a team member to solicit merchandise, craft, and wellness/cannabis vendors and confirm each holds whatever licenses, insurance certificates, or BACP registration the application requires before its applicable deadline')
on conflict (section_key) do nothing;

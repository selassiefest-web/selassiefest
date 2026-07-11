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

alter table event_series enable row level security;
alter table event_occurrences enable row level security;

-- Calendar data is public information (unlike the newsletter/Anansi forms
-- above, which are write-only for anon). Anon gets read-only access; there
-- is no insert/update/delete policy, so events are managed from the
-- Supabase Table Editor (or a future authenticated admin tool), never from
-- the public site.
create policy "Allow anon read" on event_series
  for select to anon
  using (true);

create policy "Allow anon read" on event_occurrences
  for select to anon
  using (true);

grant select on event_series to anon;
grant select on event_occurrences to anon;

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
-- small on the free tier's 1GB/50MB-per-file limits). Approved photos are
-- incorporated into the relevant static game page by hand, same as every
-- other manually-curated piece of content on this site.
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

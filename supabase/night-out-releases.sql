-- ============================================================================
-- Documentary appearance releases -- "Anatomy of a Shoreline"
-- ============================================================================
-- Apply to the linked project with:
--     supabase db query --linked -f supabase/night-out-releases.sql
--
-- Do NOT re-run supabase/schema.sql to pick this up. Once applied, paste this
-- block into schema.sql so the hand-maintained full-schema reference stays
-- accurate.
--
-- Same convention as every other public form since the 10/7/2026 lockdown:
-- RLS on, no anon access at all. The page posts to the public-submit edge
-- function (Turnstile, honeypot, per-IP throttle, column allowlist), which
-- inserts with the service role. Because the service role skips RLS, the
-- validation lives in CHECK constraints instead of an insert policy. An AFTER
-- INSERT trigger on the shared notify_submission_webhook() function has the
-- notify-submission Edge Function email a copy. Two notifications are
-- configured for this table in notify-submission/index.ts -- one to staff, and
-- one back to the signer, which is what satisfies the "a copy was provided to
-- the signer" requirement for an electronic signature.
--
-- There is deliberately no storage bucket and no generated PDF here. The row
-- IS the record: it stores the release version that was displayed, the typed
-- signature, the consent flag, the timestamp and the user agent. The versioned
-- release text itself lives in the repo at night-out/release.html, so the
-- release_version column is enough to reconstruct exactly what was agreed to.
-- ============================================================================

create table if not exists public.night_out_appearance_releases (
  id                    uuid primary key default gen_random_uuid(),
  created_at            timestamptz not null default now(),

  -- 'adult'  = the person appearing signs for themselves
  -- 'minor'  = a parent or legal guardian signs for a child
  release_type          text not null check (release_type in ('adult', 'minor')),

  -- the person appearing on camera (for 'minor', the child)
  subject_name          text not null,

  -- the person actually signing (for 'adult', same as subject_name)
  signer_name           text not null,
  signer_relationship   text,                 -- 'minor' only: parent, legal guardian
  signer_email          text not null,
  signer_phone          text,

  filmed_location       text,
  filmed_date           date,

  production_title      text not null default 'Anatomy of a Shoreline',
  release_version       text not null,        -- e.g. 'v1-2026-09'

  -- electronic signature audit trail
  electronic_consent    boolean not null default false,
  signature_typed_name  text not null,
  signed_at             timestamptz not null default now(),
  user_agent            text,
  source_page           text,

  -- set by staff if a signer later asks to be removed from the film
  withdrawn_at          timestamptz,
  notes                 text,

  constraint night_out_release_consent check (electronic_consent = true),
  constraint night_out_release_names check (
    length(btrim(signer_name)) > 1 and length(btrim(subject_name)) > 1 and length(btrim(signature_typed_name)) > 1),
  constraint night_out_release_email check (position('@' in signer_email) > 1),
  constraint night_out_release_guardian check (
    release_type = 'adult' or length(btrim(coalesce(signer_relationship, ''))) > 1)
);

comment on table public.night_out_appearance_releases is
  'Appearance releases for the documentary "Anatomy of a Shoreline". No anon access; rows arrive through the public-submit edge function.';

create index if not exists night_out_appearance_releases_created_at_idx
  on public.night_out_appearance_releases (created_at desc);

create index if not exists night_out_appearance_releases_subject_idx
  on public.night_out_appearance_releases (lower(subject_name));

-- ---------------------------------------------------------------------------
-- Row Level Security on, with no policies: anon and authenticated can neither
-- read nor write. These rows carry names, emails and phone numbers of members
-- of the public.
-- ---------------------------------------------------------------------------
alter table public.night_out_appearance_releases enable row level security;
revoke all on public.night_out_appearance_releases from anon, authenticated;

-- ---------------------------------------------------------------------------
-- Staff notification + signer's copy, via the shared webhook trigger function.
-- notify_submission_webhook() embeds a secret and is intentionally not
-- committed to this repo; it already exists on the live project.
-- ---------------------------------------------------------------------------
drop trigger if exists night_out_appearance_releases_notify
  on public.night_out_appearance_releases;

create trigger night_out_appearance_releases_notify
  after insert on public.night_out_appearance_releases
  for each row execute function public.notify_submission_webhook();

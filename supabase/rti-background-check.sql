-- ===========================================================================
-- Ras Tafari Inc. members' Chicago Park District background checks
-- (/rti/background-check/). Each member fills in the Park District's Long Term
-- Adult Volunteer Application in the browser, and the rti-background-check
-- edge function emails the PDF to volunteers@chicagoparkdistrict.com.
--
-- The application itself (date of birth, SSN last 4 / license number,
-- emergency contacts) is never stored. This table only records WHO sent one
-- and when, so Ras Tafari Inc. can see which members are done.
-- ===========================================================================
create table if not exists public.rti_bgcheck_submissions (
  id               uuid primary key default gen_random_uuid(),
  created_at       timestamptz not null default now(),
  full_name        text not null,
  email            text not null,
  phone            text,
  rti_role         text,
  park             text,
  stewardship_role text,
  test_mode        boolean not null default false,
  resend_id        text
);

comment on table public.rti_bgcheck_submissions is
  'One row per CPD volunteer application sent from /rti/background-check/. Names and contact info only; the application PDF is never stored. Written by the rti-background-check edge function (service role).';

create index if not exists rti_bgcheck_submissions_created_at_idx
  on public.rti_bgcheck_submissions (created_at desc);

-- Row Level Security on, with no policies: anon and authenticated can neither
-- read nor write. Only the edge function (service role) inserts.
alter table public.rti_bgcheck_submissions enable row level security;
revoke all on public.rti_bgcheck_submissions from anon, authenticated;

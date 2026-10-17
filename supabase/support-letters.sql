-- ===========================================================================
-- Letters of support for Ras Tafari Inc. programs (/support-letter/).
-- A partner writes and signs a letter in the browser; the support-letter edge
-- function stores it here and emails Stephen and the signer a private link to
-- the printable, signed letter. Funders get the PDF printed from that link.
--
-- RLS on, no policies: only the edge function (service role) reads or writes.
-- The public page only ever sees a count and the names of organizations that
-- agreed to be listed (public_ok).
-- ===========================================================================
create table if not exists public.support_letters (
  id             uuid primary key default gen_random_uuid(),
  created_at     timestamptz not null default now(),
  org_name       text not null,
  org_about      text,
  signer_name    text not null,
  signer_title   text,
  email          text not null,
  phone          text,
  address        text,
  relationship   text,
  programs       text[] not null default '{}',
  why            text not null,
  commitment     text,
  letter_date    date not null default current_date,
  signature_png  text not null,
  public_ok      boolean not null default false,   -- may list the organization's name publicly
  status         text not null default 'received' check (status in ('received','verified','hidden')),
  token_hash     text unique,                       -- sha256 of the private view-link token
  ip             text,
  user_agent     text
);
comment on table public.support_letters is 'Signed letters of support from partners, written at /support-letter/. Read and written only by the support-letter edge function.';
alter table public.support_letters enable row level security;

-- ===========================================================================
-- Ras Tafari Inc. board e-signing (/rti/board/sign/). A packet is a set of
-- board documents (agenda, minutes, a written consent) that every director
-- reads and signs from a personal emailed link. Once all have signed, any of
-- them can print the signed packet to PDF.
--
-- Packet content is loaded out of band (legal/documents-inbox/, git-ignored),
-- never committed: everything in the repo deploys publicly.
-- The rti-board-sign edge function (service role) is the only reader/writer.
-- ===========================================================================
create table if not exists public.rti_sign_packets (
  id           text primary key,          -- e.g. 'rti-arcs-2026-10-15'
  title        text not null,
  docs         jsonb not null,            -- [{id, title, html}] in reading order
  doc_hash     text not null,             -- sha256 of the docs JSON as loaded; each signature records the hash it saw
  created_at   timestamptz not null default now(),
  completed_at timestamptz
);

create table if not exists public.rti_sign_signers (
  id              bigserial primary key,
  packet_id       text not null references public.rti_sign_packets (id) on delete cascade,
  sort            int not null,           -- matches data-signer="n" in the documents
  full_name       text not null,
  title           text not null,
  email           text not null,
  is_admin        boolean not null default false,  -- can send the other directors their links
  token_hash      text unique,            -- sha256 of the emailed link token; a new invite replaces it
  invited_at      timestamptz,
  viewed_at       timestamptz,
  signed_at       timestamptz,
  typed_name      text,
  signature_png   text,                   -- data:image/png;base64,...
  conflict        text,                   -- 'none' or the director's disclosure
  doc_hash_signed text,
  ip              text,
  user_agent      text,
  unique (packet_id, sort)
);

comment on table public.rti_sign_packets is 'Board document packets for /rti/board/sign/. Content loaded out of band; read only by the rti-board-sign edge function.';
comment on table public.rti_sign_signers is 'One row per director per packet: link token hash, view/sign times, signature image and audit trail.';

-- Row Level Security on, with no policies: anon and authenticated can neither
-- read nor write. Only the edge function (service role) touches these tables.
alter table public.rti_sign_packets enable row level security;
alter table public.rti_sign_signers enable row level security;

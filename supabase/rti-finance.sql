-- ===========================================================================
-- Ras Tafari Inc. board financials (/rti/finance/). The page is public code
-- with no numbers in it; the books live here and are served only to the
-- officers on rti_fin_viewers, by personal emailed link (rti-finance fn).
-- Book data is loaded out of band (legal/documents-inbox/finance/, git-ignored).
-- ===========================================================================
create table if not exists public.rti_fin_books (
  id          text primary key,            -- e.g. 'fy2026'
  data        jsonb not null,              -- ledgers, P&L, balance sheet, open items
  updated_at  timestamptz not null default now()
);

create table if not exists public.rti_fin_viewers (
  id               bigserial primary key,
  full_name        text not null,
  title            text not null,
  email            text not null unique,
  token_hashes     text[] not null default '{}',   -- every link sent stays valid
  last_sent_at     timestamptz,
  last_viewed_at   timestamptz
);

comment on table public.rti_fin_books is 'RTI books for /rti/finance/. Read only by the rti-finance edge function.';
comment on table public.rti_fin_viewers is 'Officers allowed to open /rti/finance/, with hashes of their emailed links.';

alter table public.rti_fin_books enable row level security;
alter table public.rti_fin_viewers enable row level security;

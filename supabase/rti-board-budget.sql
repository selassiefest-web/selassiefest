-- ===========================================================================
-- Ras Tafari Inc. board budget room (/rti/board/budget/). Directors sign in by
-- personal emailed link, then discuss, edit and take a straw vote on the
-- budget of each Friday series (e.g. The Ultimate Friday Lime at ILU Club).
--
-- The page is public code with no numbers or names in it. Members and series
-- budgets are seeded out of band (legal/documents-inbox/rti-board-budget/,
-- git-ignored). The rti-board-budget edge function (service role) is the only
-- reader/writer: RLS is on with no policies.
-- ===========================================================================
create table if not exists public.rti_bb_members (
  id              bigserial primary key,
  full_name       text not null,
  title           text not null,
  email           text not null unique,              -- lower-case
  is_editor       boolean not null default false,    -- unused since 2026-11-13: every director can edit
  token_hashes    text[] not null default '{}',      -- every link sent stays valid (last 20)
  last_sent_at    timestamptz,
  last_viewed_at  timestamptz
);

create table if not exists public.rti_bb_series (
  id                text primary key,                -- e.g. 'friday-lime-ilu'
  title             text not null,
  venue             text not null default '',
  status            text not null default 'discussion'
                    check (status in ('discussion','approved','rejected','tabled')),
  fridays_per_year  int not null default 52 check (fridays_per_year between 1 and 53),
  budget            jsonb not null default '{"income":[],"expense":[],"one_time":[]}',
                    -- each list: [{label, amount (per Friday, or once for one_time; null = not priced yet), note}]
  notes             text not null default '',
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  updated_by        bigint references public.rti_bb_members (id)
);

create table if not exists public.rti_bb_comments (
  id          bigserial primary key,
  series_id   text not null references public.rti_bb_series (id) on delete cascade,
  member_id   bigint not null references public.rti_bb_members (id),
  body        text not null check (char_length(body) between 1 and 4000),
  created_at  timestamptz not null default now()
);
create index if not exists rti_bb_comments_series on public.rti_bb_comments (series_id, created_at);

create table if not exists public.rti_bb_votes (
  series_id   text not null references public.rti_bb_series (id) on delete cascade,
  member_id   bigint not null references public.rti_bb_members (id),
  vote        text not null check (vote in ('approve','reject','abstain')),
  note        text not null default '' check (char_length(note) <= 1000),
  updated_at  timestamptz not null default now(),
  primary key (series_id, member_id)
);

-- Budget edit history, so the board can see what changed and who changed it.
create table if not exists public.rti_bb_history (
  id          bigserial primary key,
  series_id   text not null references public.rti_bb_series (id) on delete cascade,
  member_id   bigint references public.rti_bb_members (id),
  before      jsonb,
  after       jsonb not null,
  created_at  timestamptz not null default now()
);

comment on table public.rti_bb_members  is 'Directors allowed into /rti/board/budget/, with hashes of their emailed links.';
comment on table public.rti_bb_series   is 'Friday series budgets under board discussion. Read/written only by the rti-board-budget edge function.';
comment on table public.rti_bb_comments is 'Board discussion thread per series.';
comment on table public.rti_bb_votes    is 'Straw vote per director per series (formal adoption is by resolution).';
comment on table public.rti_bb_history  is 'Every budget save, before and after.';

alter table public.rti_bb_members  enable row level security;
alter table public.rti_bb_series   enable row level security;
alter table public.rti_bb_comments enable row level security;
alter table public.rti_bb_votes    enable row level security;
alter table public.rti_bb_history  enable row level security;

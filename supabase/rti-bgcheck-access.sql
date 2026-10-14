-- ===========================================================================
-- Members-only access to /rti/background-check/.
--
--   rti_members            the roster. Only these emails can get a code.
--                          Rows are added out of band (never committed):
--                          insert into public.rti_members (email) values ('x@y.com');
--   rti_bgcheck_codes      one pending 6-digit code per email (hashed, 10 min)
--   rti_bgcheck_sessions   a pass issued after a correct code (hashed token,
--                          4 hours, limited sends). rti-background-check
--                          requires one, and sends only to its email.
--
-- All three: RLS on, no policies. Only the edge functions (service role) touch them.
-- ===========================================================================
create table if not exists public.rti_members (
  email      text primary key check (email = lower(btrim(email))),
  full_name  text,
  active     boolean not null default true,
  note       text,
  added_at   timestamptz not null default now()
);

comment on table public.rti_members is
  'Ras Tafari Inc. members and associates allowed to use /rti/background-check/. Set active = false to remove someone.';

create table if not exists public.rti_bgcheck_codes (
  email       text primary key,
  code_hash   text not null,
  attempts    int not null default 0,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null
);

create table if not exists public.rti_bgcheck_sessions (
  token_hash  text primary key,
  email       text not null,
  sends       int not null default 0,
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null
);

create index if not exists rti_bgcheck_sessions_email_idx on public.rti_bgcheck_sessions (email, created_at desc);

alter table public.rti_members enable row level security;
alter table public.rti_bgcheck_codes enable row level security;
alter table public.rti_bgcheck_sessions enable row level security;
revoke all on public.rti_members from anon, authenticated;
revoke all on public.rti_bgcheck_codes from anon, authenticated;
revoke all on public.rti_bgcheck_sessions from anon, authenticated;

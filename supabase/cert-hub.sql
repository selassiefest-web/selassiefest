-- ===========================================================================
-- Certification Hub (/rti/certify/): per-client private files.
--
--   cert_clients    one row per client. The client opens a personal link
--                   (/rti/certify/?k=KEY); only sha256(KEY) is stored.
--   cert_profiles   the client's whole intake as AES-GCM ciphertext (key lives
--                   in the CERT_HUB_KEY edge secret, never in the database).
--                   `summary` holds only non-sensitive progress counts.
--   cert_audit      who did what and when (no content).
--
-- All three: RLS on, no policies. Only the cert-hub edge function (service role)
-- touches them. Safe to re-run.
-- ===========================================================================
begin;

create table if not exists public.cert_clients (
  id            uuid primary key default gen_random_uuid(),
  name          text not null,
  email         text not null check (email = lower(btrim(email))),
  note          text,
  token_hash    text unique,
  active        boolean not null default true,
  created_at    timestamptz not null default now(),
  last_seen_at  timestamptz,
  last_sent_at  timestamptz
);
create unique index if not exists cert_clients_email_idx on public.cert_clients (email);

create table if not exists public.cert_profiles (
  client_id   uuid primary key references public.cert_clients(id) on delete cascade,
  iv          text not null,
  ciphertext  text not null,
  version     int  not null default 1,
  summary     jsonb not null default '{}'::jsonb,
  updated_at  timestamptz not null default now(),
  updated_by  text not null default 'client'
);

create table if not exists public.cert_audit (
  id         bigserial primary key,
  client_id  uuid references public.cert_clients(id) on delete cascade,
  action     text not null,
  actor      text not null default 'client',
  at         timestamptz not null default now()
);
create index if not exists cert_audit_client_idx on public.cert_audit (client_id, at desc);

alter table public.cert_clients  enable row level security;
alter table public.cert_profiles enable row level security;
alter table public.cert_audit    enable row level security;
revoke all on public.cert_clients  from anon, authenticated;
revoke all on public.cert_profiles from anon, authenticated;
revoke all on public.cert_audit    from anon, authenticated;
revoke all on sequence public.cert_audit_id_seq from anon, authenticated;

commit;

select 'cert_clients' t, count(*) from public.cert_clients
union all select 'cert_profiles', count(*) from public.cert_profiles
union all select 'cert_audit', count(*) from public.cert_audit;

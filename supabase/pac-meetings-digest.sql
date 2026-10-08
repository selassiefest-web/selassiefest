-- Weekly "Upcoming PAC meetings" email (send-pac-meetings-digest), added
-- 10/7/2026. Lists meetings of the Park Advisory Councils we belong to, every
-- Sunday at 8 am Chicago, to stephen@selassiefest.com, paksipras@gmail.com and
-- peopleofthesun1@prodigy.net.
--
-- pac_councils: one row per council, with its regular schedule as a rule
-- (rule_nth-th rule_weekday of the month, 0 = Sunday, -1 = last; skip_months
-- for months it doesn't meet). Leave the rule null if there's no regular
-- pattern; the email then lists only its pac_meetings rows.
-- pac_meetings: one-off dates. A row on the same council + date as a
-- regular meeting replaces it (new time/place) or, with status 'canceled',
-- removes it.
-- Both are service-role only (RLS on, no policies); edit them with
-- `supabase db query --linked`.

create table if not exists pac_councils (
  slug text primary key,
  name text not null,
  short_name text not null,
  sort int not null default 100,
  active boolean not null default true,
  schedule_label text,
  rule_weekday int check (rule_weekday between 0 and 6),
  rule_nth int check (rule_nth in (-1, 1, 2, 3, 4, 5)),
  rule_time_label text,
  skip_months int[] not null default '{}',
  location text,
  url text,
  contact text,
  notes text,
  updated_at timestamptz not null default now()
);
alter table pac_councils enable row level security;

create table if not exists pac_meetings (
  id bigserial primary key,
  council_slug text not null references pac_councils(slug) on delete cascade,
  meets_on date not null,
  time_label text,
  title text,
  location text,
  notes text,
  url text,
  status text not null default 'scheduled' check (status in ('scheduled', 'tentative', 'canceled')),
  created_at timestamptz not null default now(),
  unique (council_slug, meets_on)
);
alter table pac_meetings enable row level security;

-- Cron (applied live; the secret lives in Vault as 'pac_digest_secret' and as
-- the function's PAC_DIGEST_SECRET). It fires at 13:00 and 14:00 UTC every
-- Sunday; the function only sends on the run that lands on 8 am Chicago.
--   select cron.schedule('pac-meetings-digest', '0 13,14 * * 0',
--     $$ select net.http_post(url := '<send-pac-meetings-digest URL>', headers :=
--        jsonb_build_object('Content-Type', 'application/json',
--        'x-webhook-secret', (select decrypted_secret from vault.decrypted_secrets
--        where name = 'pac_digest_secret')), body := '{"mode":"scheduled"}'::jsonb) $$);

-- ===========================================================================
-- 2ND CH INC. grant deadlines (the Illinois assumed name of 2nd Chance
-- Housing Inc.). Paul keeps this list current from the members-only AI Lab
-- page (/rti/ai-lab/) after he confirms each date on the funder's own site.
--
--   rti-grant-deadlines Edge Function
--     list / save / delete   needs a pass from rti-bgcheck-access (rti_members)
--     weekly                 Sunday email to Paul (cc Stephen)
--     reminder               daily; emails only when something is 7, 1 or 0 days out
--
-- RLS on, no policies: only the Edge Function (service role) touches it.
-- Apply with: supabase db query --linked -f supabase/ch-grant-deadlines.sql
-- Safe to re-run.
--
-- The cron jobs embed the function URL and CH_GRANT_DIGEST_SECRET, so they are
-- applied directly against the live project and not kept here:
--   select cron.schedule('ch-grant-deadlines-weekly', '0 13 * * 0', $$ select net.http_post(
--     url := 'https://<ref>.supabase.co/functions/v1/rti-grant-deadlines',
--     headers := jsonb_build_object('Content-Type','application/json','x-webhook-secret','<CH_GRANT_DIGEST_SECRET>'),
--     body := '{"action":"weekly"}'::jsonb) $$);
--   select cron.schedule('ch-grant-deadlines-reminder', '0 14 * * *', ... body := '{"action":"reminder"}' ...);
-- 13:00 UTC = 7am Chicago (8am during daylight time).
-- ===========================================================================
create table if not exists public.ch_grant_deadlines (
  id             uuid primary key default gen_random_uuid(),
  funder         text not null,
  program        text,
  url            text,
  opens_date     date,
  deadline_date  date,
  verified       boolean not null default false,  -- date confirmed on the funder's own site
  status         text not null default 'to_research'
                 check (status in ('to_research','preparing','submitted','awarded','declined','skip')),
  notes          text,
  sort           int not null default 100,
  updated_by     text,
  updated_at     timestamptz not null default now(),
  created_at     timestamptz not null default now()
);

alter table public.ch_grant_deadlines enable row level security;
revoke all on public.ch_grant_deadlines from anon, authenticated;

-- The five funders the AI Lab lesson researches. No dates: Paul adds them once confirmed.
insert into public.ch_grant_deadlines (funder, program, sort, notes)
select * from (values
  ('ICJIA', 'R3 (Restore, Reinvest, and Renew) grants', 1, 'Funded by cannabis tax revenue. Find when the next R3 funding notice opens.'),
  ('IDHS', 'Reentry / supportive housing and rapid re-housing (incl. Emergency Solutions Grants)', 2, null),
  ('IHDA', 'Long-Term Operating Support (LTOS) / Home Illinois', 3, null),
  ('IDOC', 'Division of Reentry: transitional and residential reentry bed contracts', 4, null),
  ('HUD Continuum of Care (Chicago)', 'CoC program funding through the Chicago CoC', 5, null)
) as v(funder, program, sort, notes)
where not exists (select 1 from public.ch_grant_deadlines);

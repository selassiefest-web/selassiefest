-- Full Spectrum grant deadline watch-list. Feeds the Sunday
-- send-fs-grant-deadlines Edge Function (emails Stephen, Kirk and Paksipras).
-- Staff-only: RLS on with no policies; only service_role (the Edge Function)
-- and direct SQL can read/write it.
--
-- kind:   'dated'    = has a real closing date (deadline_date)
--         'expected' = recurring window we expect to reopen (deadline_date is
--                      an ESTIMATE from last cycle's pattern; verified=false)
--         'rolling'  = apply any time
--         'paused'   = closed/paused; check back
--         'relationship' = no application; outreach only
-- To add a row: insert into fs_grant_deadlines (...). To retire one:
-- update ... set active = false.
create table if not exists fs_grant_deadlines (
  id uuid primary key default gen_random_uuid(),
  funder text not null,
  program text,
  kind text not null check (kind in ('dated','expected','rolling','paused','relationship')),
  deadline_date date,
  opens_date date,
  amount text,
  verified boolean not null default false,   -- date/status confirmed on funder's own site
  url text,
  notes text,
  verified_on date,
  active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table fs_grant_deadlines enable row level security;

-- The Sunday cron job is applied directly against the live project (it embeds
-- the function URL and FS_GRANT_DIGEST_SECRET, neither of which belongs in
-- git). Recreate with: select cron.schedule('fs-grant-deadlines-weekly',
-- '0 13 * * 0', $$ select net.http_post(url :=
-- 'https://<ref>.supabase.co/functions/v1/send-fs-grant-deadlines', headers :=
-- jsonb_build_object('Content-Type','application/json','x-webhook-secret',
-- '<FS_GRANT_DIGEST_SECRET>'), body := '{}'::jsonb) $$);
-- 13:00 UTC Sunday = 7am Chicago (8am during daylight time).

insert into fs_grant_deadlines (funder, program, kind, deadline_date, opens_date, amount, verified, url, notes, verified_on)
select * from (values
('Walmart / Sam''s Club','Spark Good Local Grants - FY27 Cycle 3','dated','2026-11-30'::date,'2026-08-01'::date,'$250-$5,000',true,'https://www.walmart.org/how-we-give/program-guidelines/spark-good-local-grants-guidelines','Needs Spark Good account + Deed verification. Apply to the store nearest the classroom host. Payment setup due within 21 days of approval.','2026-10-11'::date),
('Walmart / Sam''s Club','Spark Good - next cycle (FY28 Cycle 1)','expected','2027-04-15'::date,'2027-02-01'::date,'$250-$5,000',false,'https://www.walmart.org/how-we-give/program-guidelines/spark-good-local-grants-guidelines','Estimate from this year''s pattern (Feb 1-Apr 15). Confirm when Walmart posts FY28 dates.','2026-10-11'::date),
('Target','GiftCards (local store)','dated','2026-12-31'::date,null,'avg $25-50, max $500/yr',true,'https://corporate.target.com/about/purpose-history/communities/grants-corporate-giving','GiftCards available Feb-Dec as funding permits; stores take up to 30 days to respond. Needs IRS letter. No merchandise donations.','2026-10-11'::date),
('Costco','Warehouse Donation / Benevity grant','rolling',null,null,'cash only',true,'https://www.costco.com/charitable-giving.html','One application per fiscal year (Sep-Aug); FY started Sep 1. Children + education focus.','2026-10-11'::date),
('D''Addario Foundation','Community Music Grants','rolling',null,null,'cash + in-kind',false,'https://www.daddario.com/','Aggregators say rolling; first-time applicants submit a letter of inquiry first; one proposal per year. Confirm on their site.','2026-10-11'::date),
('LPMC Foundation','General Grants Program','rolling',null,null,'up to $30,000/yr',false,'https://lpmcfoundation.org','Email LPMCGrants@LPMCFoundation.org. Listing seemed stale (2025); confirm still accepting.','2026-10-11'::date),
('Field Foundation / MacArthur','A Road Together (ART)','expected','2027-05-15'::date,'2027-04-15'::date,'$10,000-$100,000/yr x3 yrs',false,'https://fieldfoundation.org/how-to-apply/','2026 window closed May 15; pattern is mid-April to mid-May, awards in fall. Chicago arts org, budget $25K-$1M, 501(c)(3), no fiscal sponsors.','2026-10-11'::date),
('ComEd / League of Chicago Theatres','Powering the Arts','expected','2027-03-12'::date,'2027-01-11'::date,'up to $20,000',false,'https://leagueofchicagotheatres.org/comedpoweringthearts/','2026 cycle ran Jan 12-Mar 13; 2025 closed Mar 28. Dates are an estimate. Must be in ComEd territory; recent winners excluded.','2026-10-11'::date),
('Polk Bros. Foundation','Small grants (up to $25,000)','paused',null,null,'up to $25,000',false,'https://www.polkbrosfdn.org/our-grantmaking/','Not accepting unsolicited proposals during a transition that was to end in fall 2026. CHECK NOW for the new guidelines (312-527-4684).','2026-10-11'::date),
('Guitar Center Music Foundation','Instrument grants','paused',null,null,'$1,000-$5,000 in-kind',true,'https://guitarcenterfoundation.org/grants/','Reviews paused. Requires program running 1+ year with weekly instruction. Email info@guitarcenterfoundation.org about a raffle/auction item.','2026-10-11'::date),
('Illinois Arts Council','Creative Projects grant','rolling',null,null,'varies',false,'https://arts.illinois.gov/granting-opportunities/grants-programs.html','Search result says apply at least 8 weeks before project start. Verify eligibility for a new program.','2026-10-11'::date),
('Hearst Foundations','Culture grants (youth-reaching programs)','rolling',null,null,'varies',false,'https://www.hearstfdn.org','Listed as rolling; verify guidelines and whether unsolicited requests are accepted.','2026-10-11'::date),
('City of Chicago DCASE','CityArts Program','expected','2027-06-01'::date,null,'$100,000-$500,000 range seen',false,'https://www.chicago.gov/city/en/depts/dca/supp_info/cityarts.html','2026 deadline was Jun 3. Range seen is large for us; check smaller DCASE opportunities too.','2026-10-11'::date),
('Sweetwater','Philanthropy partners','relationship',null,null,'gear + funding',false,'https://www.sweetwater.com/philanthropy/','No application; they select partners proactively. Outreach only.','2026-10-11'::date)
) as v(funder,program,kind,deadline_date,opens_date,amount,verified,url,notes,verified_on)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and g.program = v.program);

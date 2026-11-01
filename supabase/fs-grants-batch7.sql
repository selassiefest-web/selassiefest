-- Full Spectrum grants: batch 7 (from pasted research notes 2026-11-01; CFW and Wurlitzer re-searched same day, official pages not opened).
-- 2 new funders. The other grant ideas in that research (Field/MacArthur ART, Fry, Guitar Center, DCASE CityArts) are already tracked.
-- Peer and relationship targets (South Shore CDC, Marwen, Chi-Rhythm Radio, South Side churches) belong in fs_partners, which is seeded out of band.
-- Idempotent; safe to re-run. Apply: supabase db query --linked -f supabase/fs-grants-batch7.sql
begin;
select count(*) as before_total from fs_grant_deadlines;

insert into fs_grant_deadlines (funder, program, kind, deadline_date, opens_date, amount, verified, url, notes, verified_on, level, project, priority, eligibility, match_required, status, gates, next_step, next_step_due)
select * from (values
('Chicago Foundation for Women','Young Women''s Giving Council grants','expected',null::date,null::date,'about $2,000-$7,000, 3 to 5 grants a year (undated profile)',false,'https://cfw.org/young-womens-giving-council','Giving circle that funds Chicago-area groups centering BIPOC girls, young women and gender-expansive youth; unrestricted dollars. We found NO 2026-27 cycle dates; CFW accepts NO late applications. Fit only if the DJ Lab deliberately serves girls and gender-expansive youth (e.g. the weekly guest woman DJ plus a girls-forward recruiting push): do not stretch the program to fit. Staff contact was listed as emarsh@cfw.org / 312-577-2825 in an undated profile: confirm before using.','2026-11-01'::date,'foundation','djclass',3,'Chicago-area nonprofit; focus on girls, young women, gender-expansive youth',null,'to_research','{g0,g3}'::text[],'Open cfw.org/young-womens-giving-council and confirm the cycle dates and whether our program qualifies',null),
('DeKalb County Community Foundation','Farny R. Wurlitzer Foundation Fund (music education)','expected','2027-03-01'::date,'2026-07-01'::date,'about $1,000-$2,500 for Chicago-area groups',false,'https://dekalbccf.org/wurlitzer','Music-education grants for nonprofit and public groups in the Chicago area, with PREFERENCE for groups serving DeKalb County residents. Recent cycles closed Sep 1 and Mar 1, 11:59 pm; Mar 1, 2027 is our inference from that pattern, not confirmed. Past Chicago recipients bought instruments. Good for a specific equipment buy (two DJ controllers). Confirm a South Shore group is eligible; questions to grants@dekalbccf.org.','2026-11-01'::date,'foundation','djclass',2,'Music education; Chicago-area nonprofit; DeKalb County preferred',null,'to_research','{g0}'::text[],'Email grants@dekalbccf.org: is a South Shore program eligible, and is the next deadline Mar 1, 2027?','2027-01-15'::date)
) as v(funder,program,kind,deadline_date,opens_date,amount,verified,url,notes,verified_on,level,project,priority,eligibility,match_required,status,gates,next_step,next_step_due)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and g.program = v.program);

select count(*) as after_total from fs_grant_deadlines;
commit;

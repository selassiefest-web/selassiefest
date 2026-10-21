-- Partnership/funder prospects for Rainbow DJ Lab (equipment + teaching) and Full Spectrum.
-- Dates checked on each funder's own page 2026-10-20. Additive except two corrections:
--   Walmart Spark Good Cycle 3 closes Dec 31 (Walmart's page: Aug 1 - Dec 31), not Nov 30.
--   Polk Bros. is NOT paused: Open Application is running (intro deadline Dec 4, 2026).

-- 1. Corrections
update fs_grant_deadlines
   set deadline_date = '2026-12-31', verified = true, verified_on = '2026-10-20',
       notes = 'Cycle 3 window is Aug 1 - Dec 31 per walmart.org. Needs Spark Good account + Deed verification (Deed verified and Walmart affiliation approved Oct 20, 2026; waiting for Spark Good to sync). Must serve the same area as the store.'
 where funder = 'Walmart / Sam''s Club' and program = 'Spark Good Local Grants - FY27 Cycle 3';

update fs_grant_deadlines
   set program = 'Open Application - Introduction (May 2027 board)', kind = 'dated',
       deadline_date = '2026-12-04', verified = true, verified_on = '2026-10-20',
       url = 'https://www.polkbrosfdn.org/our-grantmaking/open-application',
       amount = 'not stated',
       notes = 'Intro due 5 pm CT; answer by email in about a month; full proposals by invitation only (Feb 5 / Apr 30 2027 dates). Requires: 501(c)(3) or fiscal sponsor, serves Chicago, operating 1+ year, Form 990 filed for one of last two fiscal years. Our determination is June 2026, so call 312-527-4684 first to ask whether we qualify. Later intro dates: Mar 5, Jun 4, Aug 20 2027.'
 where funder = 'Polk Bros. Foundation';

update fs_grant_deadlines
   set notes = coalesce(notes,'') || ' Per a Oct 2026 research note (unverified): community grants need 3+ instructional hours per student weekly; in-kind needs 2+. DJ Lab is 2 hours a week, so in-kind may fit and cash likely does not. Confirm on their site.'
 where funder = 'D''Addario Foundation' and notes not like '%3+ instructional hours%';

-- 2. New prospects
insert into fs_grant_deadlines (funder, program, kind, deadline_date, opens_date, amount, verified, url, notes, verified_on, level, project, priority, status, eligibility, next_step)
select * from (values
('NAMM Foundation','Music Program Grants (Round 1)','expected','2027-04-01'::date,null::date,'not stated',false,'https://nammfoundation.org/programs/program-grants/','Published schedule: opens February, Round 1 due April 1, Round 2 invitations June 5, awards Oct 1. 2027 dates not yet posted.','2026-10-20'::date,'foundation','djclass',1,'to_research','Needs 501(c)(3) plus an audit or financial review from the past two years (or a fiscal sponsor that has one). We likely lack this. Must pass their Dependency Test.','Ask Paul whether a financial review exists or can be done; otherwise ask about a fiscal sponsor.'),
('Lloyd A. Fry Foundation','Arts Learning','expected','2027-03-01'::date,null::date,'not stated',false,'https://www.fryfoundation.org/apply/eligibility-for-funding','Deadlines Mar 1 (May board), Jun 1 (Aug), Sep 1 (Nov); year inferred. Start with the eligibility quiz, then a letter of inquiry. Email applications@fryfoundation.org.','2026-10-20'::date,'foundation','djclass',2,'to_research','Chicago-based nonprofit serving Chicago residents. New grantees cannot get general operating support; ask for program support. Years-operating rule not published.','Take the eligibility quiz at the Fry site.'),
('Music for Global Children','Technology Grants (workstations incl. DJ controller)','relationship',null::date,null::date,'equipment package up to 4 workstations',false,'https://www.musicforglobalchildren.org/technology-grants/','Package page is labeled 2023. Confirm a current round and whether Chicago programs qualify.','2026-10-20'::date,'foundation','djclass',2,'to_research','Unknown for 2027.','Email them: current round, Chicago eligibility.'),
('AlphaTheta / Pioneer DJ','Start From Scratch (DJ education access)','relationship',null::date,null::date,'equipment / partnership',false,'https://alphatheta.com/en/landing/start-from-scratch/purpose/','No open equipment application or Chicago availability verified. Approach as education partner for the DJ Lab 12-station goal.','2026-10-20'::date,'corporate','djclass',1,'to_research','No published application.','Send a partnership inquiry with the 12-station equipment list.')
) as v(funder,program,kind,deadline_date,opens_date,amount,verified,url,notes,verified_on,level,project,priority,status,eligibility,next_step)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and g.program = v.program);

-- 3. Reminder emails (deadlines table)
update deadlines
   set due_date = '2026-12-31', description = '$250-$5,000. Window Aug 1 - Dec 31 per walmart.org. Needs Spark Good account and Deed verification first.'
 where title = 'Walmart Spark Good local grants (FY27 Cycle 3) close' and due_date = '2026-11-30'
   and not exists (select 1 from deadlines where title = 'Walmart Spark Good local grants (FY27 Cycle 3) close' and due_date = '2026-12-31');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
select * from (values
('Polk Bros. Foundation Open Application: introduction due 5 pm CT', 'Needs 1+ year operating and a Form 990; call 312-527-4684 first to ask if a June 2026 determination qualifies. Reply by email in about a month.', '2026-12-04'::date, 'filing_deadline', 'https://www.polkbrosfdn.org/our-grantmaking/open-application', true),
('Fry Foundation Arts Learning proposal deadline (year inferred)', 'Mar 1 for May board. Take the eligibility quiz first; letter of inquiry before the application.', '2027-03-01'::date, 'estimated_window', 'https://www.fryfoundation.org/apply/eligibility-for-funding', false),
('NAMM Foundation Music Program Grants Round 1 due (estimated)', 'Published schedule says April 1. Needs an audit or financial review from the past two years or a fiscal sponsor.', '2027-04-01'::date, 'estimated_window', 'https://nammfoundation.org/programs/program-grants/', false)
) as v(title,description,due_date,category,source_url,confirmed)
on conflict (title, due_date) do nothing;

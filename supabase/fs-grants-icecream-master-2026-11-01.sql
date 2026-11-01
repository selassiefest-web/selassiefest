-- Full Spectrum: ice cream master list reconciliation (source: "Rainbow Wednesdays Ice Cream Partner Gap Analysis & Master List.docx", Nov 1 2026, 4 merged research reports + spot checks).
-- Corrects the 8 rows added earlier today and adds the rest of the 23 prospects. Nobody has been contacted. Idempotent.
-- Apply: supabase db query --linked -f supabase/fs-grants-icecream-master-2026-11-01.sql
begin;
select count(*) as before_total from fs_grant_deadlines;

-- 1. Corrections to the rows added earlier
update fs_grant_deadlines set priority=1, kind='rolling', verified=true, verified_on='2026-11-01', url='https://www.jenis.com/',
 amount='in-kind ice cream, gift cards or money; Ice Cream Social fundraiser returns 25% of sales',
 notes='TIER A (master list): donation application for product, fundraising@jenis.com; plan 6+ weeks lead time for in-kind (4 weeks for an Ice Cream Social). Social fundraisers exclude religious organizations (Ras Tafari Inc. is not one). Jeni''s sponsored Center on Halsted''s 2026 Trans Ice Cream Social. The Chicago Public Library Foundation example is unverified.',
 next_step='Submit the Jeni''s donation application (100-serving pilot for one Rainbow Wednesday) with 6+ weeks lead time; needs a fixed 2027 date',
 next_step_due='2027-01-15'
where funder='Jeni''s Splendid Ice Creams';

update fs_grant_deadlines set priority=1, notes='TIER A (master list): the only prospect actually in South Shore: 2911 E 79th St; serves ice cream and hosts open mics and live events (location and events confirmed on a listing). The artist scholarship fund claim is NOT verified. No giving program: visit in person.',
 next_step='Visit in person with the one-page brief; ask for a 100-serving pilot or a dine-and-donate night', next_step_due='2027-01-15'
where funder='Urban Luxe Cafe (South Shore)';

update fs_grant_deadlines set priority=2, url='https://www.rainbowcone.com/',
 notes='TIER A (master list): contact@rainbowcone.com. Published offer: 20% BENEFIT NIGHTS at stores only (trucks excluded), 2 weeks notice, use their form. The 2026 Centennial Summer Surprise Tour made pop-up truck stops; NOTHING announced for 2027: ask whether it returns. Three separate routes: benefit night, truck hire, tour stop.',
 next_step='Book a spring benefit night with their form; ask by email whether a 2027 truck tour will run', next_step_due='2027-03-15'
where funder='The Original Rainbow Cone';

update fs_grant_deadlines set priority=3, amount='unconfirmed; budget $0',
 notes='TIER B: 2353 N California Ave, 773-697-4140. Nonprofit and artist collaborations and benefit pops are real; payout claims conflict ($1 per pop vs about $500 per collab): neither is a published commitment. Budget $0.',
 next_step='Call 773-697-4140 and ask about a collaboration', next_step_due='2027-02-15'
where funder='Pretty Cool Ice Cream';

update fs_grant_deadlines set priority=3,
 notes='TIER B: Started in South Shore in 1931 (E 71st St) but moved to Homewood in the 1970s: 18211 Dixie Hwy, Homewood. 708-799-3835 matches the Homewood shop. The viziamail email from the first research note is UNCONFIRMED; do not use it. Sells pints through grocery chains (possible distribution donation).',
 next_step='Call 708-799-3835; ask for a product donation contact', next_step_due='2027-02-15'
where funder='Mitchell''s Ice Cream';

update fs_grant_deadlines set status='to_research', priority=3,
 notes='HOLD: listing not confirmed. TheShareWay is a real donor directory with a free tier, but Carvel''s listing was not seen. Verify before counting it.',
 next_step='Verify Carvel on TheShareWay (free account) before any request', next_step_due='2027-03-01'
where funder='Carvel';

update fs_grant_deadlines set status='to_research', priority=3,
 notes='HOLD: not verified; location unknown. TheShareWay listing unconfirmed.',
 next_step='Verify location and listing before any request', next_step_due='2027-03-01'
where funder='The Outside Scoop';

update fs_grant_deadlines set status='skip', priority=3,
 notes='SKIP: no Chicago business found; the only same-named shop located is in Girard, Ohio. The Good Humor claim was not confirmed.',
 next_step='Skipped 2026-11-01: not found in Chicago'
where funder='Sweet Memories Ice Cream';

update fs_grant_deadlines set priority=3,
 notes='HOLD: low confidence; the master list found Jeni''s sponsoring Center on Halsted socials, but the Chicago Public Library Foundation example is unverified. Jeni''s is now tracked as its own TIER A row; Kilwins Hyde Park is its own TIER B row.',
 next_step='Folded into the Jeni''s row; no separate action'
where funder='Jeni''s Splendid Ice Creams' and program='Ice cream social sponsorship idea';

-- 2. New rows
insert into fs_grant_deadlines (funder, program, kind, deadline_date, opens_date, amount, verified, url, notes, verified_on, level, project, priority, eligibility, match_required, status, gates, next_step, next_step_due)
select * from (values
('Andy''s Frozen Custard','Product or treat-card donation; Spirit Days','rolling',null::date,null::date,'product; $1 per treat on Spirit Days',false,null,'TIER A: donation form; Burbank store, 8041 S Harlem, 708-598-0535. Program verified; handled locally, lead time unknown. Single-serve portions suit an outdoor crowd.','2026-11-01'::date,'corporate','wednesdays',1,'501(c)(3) likely',null,'to_research','{}'::text[],'Submit their donation form for a 100-serving pilot once a 2027 date is fixed','2027-01-15'::date),
('B&B Ice Cream & Candy','Distributor inquiry (packaged novelties, cold chain)','relationship',null,null,'unknown',false,null,'TIER A: 8238 S Racine, 773-322-4060, support@bbicecreamcandy.com. South Side distributor that invites distribution inquiries; no giving record. Ask about packaged novelties AND freezer or cart logistics (the cold-chain gap).','2026-11-01'::date,'corporate','wednesdays',1,'Unknown',null,'to_research','{}'::text[],'Visit or call; ask about novelties and a freezer or cart for Wednesdays','2027-01-15'),
('Baskin-Robbins (7013 S Stony Island)','Local owner donation or sponsorship','relationship',null,null,'in-kind',false,null,'TIER B: 773-633-0849 (alternate 8753 S Stony Island, 773-375-2426). Corporate FAQ points requests to local owners.','2026-11-01','corporate','wednesdays',3,'Owner discretion',null,'to_research','{}'::text[],'Call and ask for the owner','2027-02-15'),
('Culver''s (3355 S MLK Dr)','Franchisee donations, sponsorships, fundraisers','relationship',null,null,'varies',false,null,'TIER B: 312-808-1100; ask for the owner. Program verified; South Shore may fall outside this store''s giving area.','2026-11-01','corporate','wednesdays',3,'Franchisee giving area',null,'to_research','{}'::text[],'Call; confirm South Shore is in range','2027-02-15'),
('Kilwins Hyde Park','Owner conversation','relationship',null,null,'unknown',false,null,'TIER B: owner Jacqueline Jackson; chicago-hydepark@kilwins.com; 773-675-6731. No published giving program; a $1 per quart Month of Giving is an Arlington Heights model to copy, not a request to make here.','2026-11-01','corporate','wednesdays',3,'Owner discretion',null,'to_research','{}'::text[],'Call the owner; offer the July month-of-giving model','2027-02-15'),
('Shawn Michelle''s Homemade Ice Cream (Bronzeville)','Owner conversation','relationship',null,null,'unknown',false,null,'TIER B: 46 E 47th St, 773-675-4032. Phone verified; no donation email.','2026-11-01','corporate','wednesdays',3,'Unknown',null,'to_research','{}'::text[],'Call or visit','2027-02-15'),
('Dairy Queen (local franchisee)','Owner-level donations (Dilly Bars)','relationship',null,null,'in-kind',false,null,'TIER B: use the store locator, then ask for the owner. No participating Chicago owner identified.','2026-11-01','corporate','wednesdays',4,'Owner discretion',null,'to_research','{}'::text[],'Low priority: find a nearby owner first','2027-03-01'),
('Cold Stone Creamery (local store)','Store-level fundraisers and donations','relationship',null,null,'varies',false,null,'TIER B: each store sets its own fundraisers and donations. Use the store locator.','2026-11-01','corporate','wednesdays',4,'Owner discretion',null,'to_research','{}'::text[],'Low priority: find a nearby store','2027-03-01'),
('Dippin'' Dots Illinois','Sponsor-funded mobile event service','relationship',null,null,'paid service',false,null,'TIER B: dippindotschicago@gmail.com, 773-290-4964. A PAID mobile event service; donations not confirmed. A bank or employer sponsor could cover the cost.','2026-11-01','corporate','wednesdays',4,'n/a',null,'to_research','{}'::text[],'Only if a sponsor funds a paid appearance','2027-03-01'),
('Homer''s Ice Cream','Product or sponsor-funded bulk order','relationship',null,null,'in-kind',false,null,'TIER B: info@homersicecream.com, 847-251-0477 (Wilmette). Contact verified but far from South Shore.','2026-11-01','corporate','wednesdays',4,'Unknown',null,'to_research','{}'::text[],'Low priority; far away','2027-03-01'),
('Chicago Park District: permitted trucks and concessions (UCG Associates)','Concession rules for Rainbow Beach','relationship',null,null,'n/a',false,'https://parkconcessions.com/','BLOCKING GAP: nobody has checked whether concession agreements limit outside ice cream, what a free food giveaway needs, or whether a truck can park on the lawn. Ask Rainbow Beach fieldhouse staff and parkconcessions.com BEFORE promising any truck or giveaway. Truck names not verified.','2026-11-01','city','wednesdays',2,'Park District rules',null,'to_research','{}'::text[],'Ask Rainbow Beach fieldhouse staff about concessions, food giveaways and truck access','2026-12-15'),
('Oberweis Dairy','Fundraiser: 20% of supporter purchases','dated',null,null,'20% of purchases (fundraiser only)',false,null,'TIER C: online booking; 3152 95th St, 708-423-7700. Fundraiser only; no free servings published.','2026-11-01','corporate','djclass',4,'Unknown',null,'to_research','{}'::text[],'Book a spring fundraiser night for refreshment money','2027-03-15'),
('Windy City Sweets','Nonprofit ice cream socials','relationship',null,null,'25 cents per cone (2026 Challenge)',false,null,'TIER C: 3308 N Broadway (Lakeview). Giving confirmed but North Side: weak fit.','2026-11-01','corporate','djclass',4,'Unknown',null,'to_research','{}'::text[],'Low priority; weak geographic fit','2027-03-15'),
('Graeter''s Ice Cream','$20 voucher for approved 501(c)(3) requests','rolling',null,null,'$20 voucher',false,null,'TIER C: online form only; about 2 weeks review. Raffle-sized.','2026-11-01','corporate','djclass',4,'501(c)(3)',null,'to_research','{}'::text[],'Optional: submit for a raffle voucher','2027-03-15'),
('Amy''s Ice Creams','Gift certificates; profit-share nights','rolling',null,null,'gift certificates',false,null,'SKIP: Texas-based chain; no Chicago stores identified (donations@amysicecreams.com).','2026-11-01','corporate','djclass',4,'n/a',null,'skip','{}'::text[],'Skipped: no Chicago store',null),
('Ben & Jerry''s','Donation requests','paused',null,null,'none',true,null,'EXCLUDED: its contact page says it is not accepting donation requests (two reports agree).','2026-11-01','corporate','djclass',4,'Not accepting',null,'not_eligible','{}'::text[],'Excluded: not accepting requests',null)
) as v(funder,program,kind,deadline_date,opens_date,amount,verified,url,notes,verified_on,level,project,priority,eligibility,match_required,status,gates,next_step,next_step_due)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and g.program = v.program);

select count(*) as after_total from fs_grant_deadlines;
commit;

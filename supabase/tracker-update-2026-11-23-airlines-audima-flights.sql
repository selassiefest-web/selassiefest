-- Nov 23, 2026. Audima guest instructor flights (2 Economy round trips SYD-ORD, ceiling $4,000; Tier A: RTI 60%, Audima 40%).
-- Adds airlines to the tracker, closes Air Canada (not eligible), pulls American and United forward (file early rule),
-- flags Southwest for verification. No personal emails. Safe to re-run (keyed on name / note text).
begin;

-- 1. Air Canada: not eligible (agent research Nov 23)
insert into fs_partners (name, category, website, partner_types, stage, ball_with, next_step, next_step_due, source, notes)
select 'Air Canada', 'Travel and lodging', 'https://www.aircanada.com/ca/en/aco/home/about/corporate-responsibility/community.html',
 array['in_kind','financial'], 'not_qualified', 'parked',
 'Closed Nov 23, 2026: not eligible (Canadian CRA-registered charities only; In-Kind needs event in Canada, exclusivity, $30,000 minimum raised, 3 months lead). No outreach. Air Canada stays the preferred airline on the itinerary, not a sponsor.',
 null, 'Research 2026-11-23',
 'Budget line this could offset: Audima guest instructor flights. Read Nov 23, 2026 at the Air Canada community page and In-Kind form https://forms.benevity.org/cf83917f-cd5a-4368-a694-b596fd74a0c2. Aeroplan Donate Points charity apply needs an Air Canada sign-in; eligibility unread.'
where not exists (select 1 from fs_partners where name = 'Air Canada');

-- 2. New airlines: ask for 2 Economy round trips (or equivalent miles) for the Audima visit, Mar 25 to Apr 1, 2027
insert into fs_partners (name, category, website, partner_types, stage, ball_with, next_step, next_step_due, source, notes)
select v.name, 'Travel and lodging', v.website, array['in_kind'], 'not_contacted', 'us', v.next_step, v.due::date, 'Research 2026-11-23', v.notes
from (values
 ('Qantas', 'https://www.qantas.com/au/en/about-us/our-company/in-the-community.html', '2026-11-24',
  'Find the Qantas sponsorship portal form (non-regional causes) and submit one inquiry: 2 Economy round trips Sydney to Chicago (via the US gateway) or equivalent, Mar 25 to Apr 1, 2027. Online only. File the first day possible.',
  'Australian carrier and the guests are Australian: strongest narrative fit. Qantas says organisations must use a form on its site; Regional Grants (cash and flight credits) are for Australian-based not-for-profits only, so use the sponsorship portal. Eligibility of a US 501(c)(3) is UNVERIFIED. Budget line: Audima guest flights.'),
 ('Virgin Australia', 'https://www.virginaustralia.com/au/en/', '2026-11-25',
  'Find the published community or sponsorship request form and submit one inquiry for 2 Economy round trips (or travel credit) for the Audima Labs visit, Mar 25 to Apr 1, 2027. Online only.',
  'Australian carrier; US routing UNVERIFIED (may rely on partner airlines). Eligibility of a US nonprofit unverified.'),
 ('Air New Zealand', 'https://www.airnewzealand.com/', '2026-11-25',
  'Find the published community or sponsorship request form and submit one inquiry. Verify first that Air New Zealand serves a Sydney or Auckland to Chicago routing for the Audima visit, Mar 25 to Apr 1, 2027. Online only.',
  'Routing and eligibility UNVERIFIED.'),
 ('ANA (All Nippon Airways)', 'https://www.ana.co.jp/en/us/', '2026-11-25',
  'Find the published corporate giving or sponsorship contact (ANA USA) and submit one inquiry for 2 Economy round trips Sydney to Tokyo to Chicago, Mar 25 to Apr 1, 2027. Online only.',
  'Option 3 on the flight shortlist (one stop in Tokyo). Eligibility UNVERIFIED; corporate giving for US nonprofits may not exist.'),
 ('Japan Airlines', 'https://www.jal.co.jp/en/', '2026-11-27',
  'Find the published corporate giving or sponsorship contact (JAL Americas) and submit one inquiry for the Audima flights, Mar 25 to Apr 1, 2027. Online only.',
  'Tokyo connection to Chicago; routing and eligibility UNVERIFIED.'),
 ('Korean Air', 'https://www.koreanair.com/', '2026-11-27',
  'Find the published corporate giving or sponsorship contact (Korean Air Americas) and submit one inquiry for the Audima flights via Seoul, Mar 25 to Apr 1, 2027. Online only.',
  'Seoul connection to Chicago; routing and eligibility UNVERIFIED.'),
 ('Cathay Pacific', 'https://www.cathaypacific.com/', '2026-11-27',
  'Find the published corporate giving or sponsorship contact (Cathay Pacific North America) and submit one inquiry for the Audima flights via Hong Kong, Mar 25 to Apr 1, 2027. Online only.',
  'Hong Kong connection to Chicago; routing and eligibility UNVERIFIED.'),
 ('Emirates', 'https://www.emirates.com/', '2026-11-30',
  'Find the published sponsorship or community request form and submit one inquiry for the Audima flights via Dubai, Mar 25 to Apr 1, 2027. Online only.',
  'Dubai connection to Chicago; commercial sponsorship focus likely. Eligibility UNVERIFIED.'),
 ('Qatar Airways', 'https://www.qatarairways.com/', '2026-11-30',
  'Find the published sponsorship or community request form and submit one inquiry for the Audima flights via Doha, Mar 25 to Apr 1, 2027. Online only.',
  'Doha connection to Chicago; commercial sponsorship focus likely. Eligibility UNVERIFIED.'),
 ('Alaska Airlines (Hawaiian Airlines)', 'https://www.alaskaair.com/content/about-us/social-responsibility/corporate-giving', '2026-11-30',
  'Check the corporate giving page: in-kind transportation for 501(c)(3)s registered in and serving listed states, request at least six weeks before the event. If Illinois is not on the list, close the row. Hawaiian now gives through Atmos Giving points.',
  'Likely NOT eligible (state list), UNVERIFIED. Hawaiian Airlines flies Sydney to Honolulu. The Alaska | Hawaiian Foundation lists tickets to events as ineligible.')
) as v(name, website, due, next_step, notes)
where not exists (select 1 from fs_partners p where p.name = v.name);

-- 3. Pull American and United forward (file early rule); sharpen the ask
update fs_partners set next_step_due = '2026-11-24',
 next_step = 'Submit one inquiry through American''s Let Good Take Flight guidelines/request page (eligible 501(c)(3)s; in-kind AAdvantage mileage certificates): 2 Economy round trips (or equivalent certificates) Sydney to Chicago via DFW or LAX with Qantas, Mar 25 to Apr 1, 2027, for the Audima Labs guest class. Online only.',
 notes = notes || E'\nNov 23, 2026: due date moved from Dec 9 to Nov 24 (file early). American says it gives limited support to eligible 501(c)(3)s helping children, communities and military; verify the current request form at aa.com/giving.'
where name = 'American Airlines' and notes not like '%moved from Dec 9 to Nov 24%';
update fs_partners set next_step_due = '2026-11-24',
 next_step = 'Check united.com Miles on a Mission for the current application (28 to 90 day mileage campaign; awards 100,000+ miles) and submit one inquiry for the Audima Labs guest flights, Mar 25 to Apr 1, 2027. Online only. Chicago headquarters.',
 notes = notes || E'\nNov 23, 2026: due date moved from Dec 15 to Nov 24 (file early). Miles on a Mission page did not load for the reader; open it in Chrome.'
where name = 'United Airlines' and notes not like '%moved from Dec 15 to Nov 24%';

-- 4. Southwest: stale row, verify
update fs_partners set next_step_due = '2026-11-24', next_step = 'Verify southwest.com/donations (Oct 31 research said no unsolicited requests, intake closed). If confirmed, close the row as not eligible; Southwest does not serve Australia anyway.',
 notes = notes || E'\nNov 23, 2026: Oct 31 batch-10 research found Southwest not eligible (no unsolicited requests). Row is stale; close after one verification.'
where name = 'Southwest Airlines' and notes not like '%Row is stale; close after one verification%';

-- 5. Activity entries
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note', 'Nov 23, 2026: added to the Audima guest-flight sponsorship list (2 Economy round trips SYD-ORD, Mar 25 to Apr 1, 2027). Ask to file online, first day possible. Eligibility unverified.', p.stage, 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p
where p.name in ('Qantas','Virgin Australia','Air New Zealand','ANA (All Nippon Airways)','Japan Airlines','Korean Air','Cathay Pacific','Emirates','Qatar Airways','Alaska Airlines (Hawaiian Airlines)','American Airlines','United Airlines')
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Nov 23, 2026: added to the Audima guest-flight sponsorship list%');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note', 'Nov 23, 2026 research: Air Canada Foundation grant and In-Kind forms require a CRA-registered Canadian charity; In-Kind also requires an event in Canada, Air Canada exclusivity, a $30,000 minimum raised and 3 months lead time; Community Relations is Canadian only and closed to new requests; Corporate Sponsorships need national reach and exclusivity. Ras Tafari Inc. does not qualify. Closed, no outreach.', p.stage, 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p where p.name = 'Air Canada'
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Nov 23, 2026 research: Air Canada%');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note', 'Nov 23, 2026: Delta (declined Nov 6, CyberGrants 106198997) stays closed. Audima flight asks go to American, United, Qantas and the carriers added today.', p.stage, 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p where p.name = 'Delta Air Lines'
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Nov 23, 2026: Delta (declined Nov 6%');

-- 6. Audima row
update fs_partners set notes = notes || E'\nNov 23, 2026: Air Canada ruled out (Canadian charities only). Flight sponsorship asks go to American and United (due Nov 24), Qantas (Nov 24), Virgin Australia, Air New Zealand, ANA (Nov 25), JAL, Korean Air, Cathay Pacific (Nov 27), Emirates, Qatar, Alaska/Hawaiian (Nov 30). Tier A (RTI 60%, Audima 40%) unchanged; funds go through Wise.'
where id = 'b8d73772-58e8-43bd-9aec-749502f8d76d' and notes not like '%Air Canada ruled out%';

commit;
select name, stage, ball_with, next_step_due from fs_partners
where name in ('Air Canada','Qantas','Virgin Australia','Air New Zealand','ANA (All Nippon Airways)','Japan Airlines','Korean Air','Cathay Pacific','Emirates','Qatar Airways','Alaska Airlines (Hawaiian Airlines)','American Airlines','United Airlines','Southwest Airlines','Delta Air Lines')
order by next_step_due nulls last, name;

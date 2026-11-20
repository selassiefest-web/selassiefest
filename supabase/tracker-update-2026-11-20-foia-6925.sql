-- tracker-update-2026-11-20-foia-6925.sql  (NOT APPLIED; for review)
-- Source .eml: C:\Users\mkepr\Downloads\BOB\FOIA_6925_63rd_Street_Bathing_Pavilion_and_Beach(FOIA_6835).eml
-- Newest message: Fri Nov 20, 2026 22:15:32 UTC = 4:15:32 pm CST, from FOIA@ChicagoParkDistrict.com (signed Kevin Murphy, no title shown; Karen Choudhury is the usual sender),
--   To FOIA@ChicagoParkDistrict.com and rastafari501c3@gmail.com (REQUIRED REPLY ADDRESS = rastafari501c3@gmail.com),
--   Message-ID <DS3PR09MB13125A71ACA8E95716AE5465289782@DS3PR09MB13125.namprd09.prod.outlook.com>
-- Asks written agreement to extend FOIA 6925 to Mon Nov 30, 2026 COB (5 ILCS 140/3(e); boxes: examination by competent personnel, unduly burdensome).
-- Live check Nov 20: Message-ID, "6925" and "6835" absent from fs_partner_activity.summary, fs_grant_deadlines.notes, rti_calendar_events; no FOIA table exists.
-- Home row: shared CPD FOIA row 91fad49d-bff1-4b1f-a611-e6de12145eb5 (6925 filed by Stephen Henry from rastafari501c3@gmail.com, same as 6838).
-- Times: America/Chicago, CDT -05 through Oct 31, CST -06 from Nov 1. Outlook Sent lines taken as CPD local time; Oct 7 11:15 am is Gmail time (Stephen local).
-- Safe to re-run: each activity guarded by (ref ...) marker; row update guarded by the Message-ID marker.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' (ref ' || v.marker || ')', 'in_conversation', v.by_email, v.by_name, v.at::timestamptz
from fs_partners p cross join (values
 ('FOIA6925 evt 2026-10-07 11:15', '2026-10-07 11:15:00-05', 'rastafari501c3@gmail.com', 'Stephen Henry',
  'Oct 7, 2026 11:15 am CT: Stephen (Ras Tafari Inc.) filed FOIA 6925 from rastafari501c3@gmail.com to FOIA@ChicagoParkDistrict.com, a follow-up to FOIA 6835 (CPD response Sep 16, 2026): an existing plain inventory/equipment list (item, category, quantity, general location, condition) of physical items at the 63rd Street Bathing Pavilion (Park No. 19, 6245 S. DuSable Lake Shore Drive) and 63rd Street Beach; Facilities Management and Beaches & Pools/Aquatics; excludes system records (7(1)(o)), plans (7(1)(k)), security equipment (7(1)(v)); existing records only; a statement that no list exists is sufficient; electronic copies preferred. Request signature shows the retired phone a retired number.'),
 ('FOIA6925 evt 2026-10-07 17:24', '2026-10-07 17:24:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 7, 2026 5:24 pm CT: CPD acknowledged and assigned tracking number FOIA 6925; response expected Thu Oct 15 COB.'),
 ('FOIA6925 evt 2026-10-15 18:08', '2026-10-15 18:08:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 15, 2026 6:08 pm CT: CPD took the five-day automatic extension under 5 ILCS 140/3(e)(vi); new due date Oct 22 COB.'),
 ('FOIA6925 evt 2026-10-22 15:44', '2026-10-22 15:44:00-05', 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy',
  'Oct 22, 2026 3:44 pm CT: CPD (Kevin Murphy, Senior Counsel; Cc Alma Estrada) asked written agreement to extend to Oct 29 COB (records not located in routine search). No written agreement from us visible in the thread.'),
 ('FOIA6925 evt 2026-10-29 20:51', '2026-10-29 20:51:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 29, 2026 8:51 pm CT: CPD asked written agreement to extend to Nov 5 COB (not located in routine search; examination by competent personnel; unduly burdensome).'),
 ('FOIA6925 evt 2026-11-05 17:32', '2026-11-05 17:32:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 5, 2026 5:32 pm CT: CPD asked written agreement to extend to Nov 13 COB (examination; unduly burdensome; consultation with another public body); CPD closed Nov 11.'),
 ('FOIA6925 evt 2026-11-13 13:48', '2026-11-13 13:48:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 13, 2026 1:48 pm CT: CPD asked written agreement to extend to Nov 20 COB (examination; unduly burdensome).'),
 ('FOIA6925 evt 2026-11-20 16:15', '2026-11-20 16:15:32-06', 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy',
  'Nov 20, 2026 4:15 pm CST: CPD (Kevin Murphy, DIR 312-742-4604) sent on the Nov 20 due date at 4:15 pm CST: still working on FOIA 6925, asks our written agreement to extend to Mon Nov 30, 2026 COB (minimum five business days; may seek more; boxes checked: examination by competent personnel, unduly burdensome). No records, fee or inspection offered. Message-ID <DS3PR09MB13125A71ACA8E95716AE5465289782@DS3PR09MB13125.namprd09.prod.outlook.com>. To FOIA@ChicagoParkDistrict.com and rastafari501c3@gmail.com. Reply owed from rastafari501c3@gmail.com by Mon Nov 23 (target).')
) as v(marker, at, by_email, by_name, summary)
where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref ' || v.marker || ')%');

update fs_partners
set name = 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws, 6925 63rd St pavilion inventory)', ball_with = 'us',
    next_step = coalesce(next_step,'') || ' FOIA 6925 (63rd St Bathing Pavilion/Beach inventory list; owner Stephen Henry): REPLY IN WRITING from rastafari501c3@gmail.com (the address the Nov 20 .eml was addressed to) to FOIA@ChicagoParkDistrict.com, In-Reply-To DS3PR09MB13125A71ACA8E95716AE5465289782, agreeing to extend to Mon Nov 30, 2026 COB; target Sat Nov 21 or Mon Nov 23. Then if no records or no-list statement by Nov 30 COB, follow up Tue Dec 1 for a firm date.',
    notes = coalesce(notes,'') || E'\n2026-11-20: FOIA 6925 (filed Oct 7, 2026 by Stephen Henry from rastafari501c3@gmail.com; follow-up to FOIA 6835, a separate Sep 2026 request not tracked here) extension notice to Nov 30 COB logged (Message-ID DS3PR09MB13125A71ACA8E95716AE5465289782). Chain of extensions: Oct 22 (auto 3(e)(vi)), Oct 29, Nov 5, Nov 13, Nov 20, Nov 30; no written agreement from us to any of them is visible in the quoted thread (Sent folder not checked). CPD holds retired phone a retired number for this request. Nov 20 notice arrived on the Nov 20 due date at 4:15 pm CST.',
    last_contact_at = greatest(coalesce(last_contact_at, 'epoch'::timestamptz), '2026-11-20 22:15:32+00'::timestamptz)
where id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and notes not like '%DS3PR09MB13125A71ACA8E95716AE5465289782%';

commit;

select p.name, p.ball_with, p.next_step_due, p.last_contact_at,
 (p.notes like '%DS3PR09MB13125A71ACA8E95716AE5465289782%') as noted,
 (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6925 evt%') as foia6925_events
from fs_partners p where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5';

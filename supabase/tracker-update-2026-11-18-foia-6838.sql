-- Nov 18, 2026: Chicago Park District FOIA 6838 (Maggie Daley Park / North Grant Park / Park No. 1303).
-- Source: .eml FOIA_6838_Maggie_Daley_Park___North_Grant_Park___Park_No._1303.eml (Stephen file, not in BOB).
-- Newest message: Mon Nov 16, 2026 18:33:26 UTC = 12:33 pm CST, from FOIA@ChicagoParkDistrict.com (Karen Choudhury, FOIA Counsel),
--   Message-ID <SA1PR09MB1000437189C0BC3DE094F9ED5D27C2@SA1PR09MB10004.namprd09.prod.outlook.com>.
-- No tracker home existed (live check Nov 18: no fs_partners / fs_partner_activity / fs_grant_deadlines / fs_partner_letters row mentions FOIA 6838, 6903 or a Maggie Daley FOIA).
-- Legal-process record, not a partner pitch: no partner-page content. The CPD partner-send hold does not apply.
-- FOIA 6903 (SSCC bylaws) is handled separately by Stephen; no 6903 events are logged here, the row only names it.
-- Times: America/Chicago (CDT UTC-5 through Oct 31, CST UTC-6 from Nov 1). Outlook Sent lines in the quoted chain are taken as CPD local time;
--   Gmail On-wrote lines (Sep 10, Oct 8) are taken as Stephen local time. Only the Nov 16 time is a true header (UTC).
-- Only the Nov 16 Message-ID is in hand; earlier events are keyed by a (ref FOIA6838 evt YYYY-MM-DD hh:mm) marker at the end of the summary.
-- Safe to re-run: partner insert guarded by name, each activity guarded by marker, partner notes update guarded by marker.
begin;

insert into fs_partners (name, category, phone, email, website, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes, last_contact_at)
select 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)', 'Civic/government', '312-742-4789', 'FOIA@ChicagoParkDistrict.com', 'https://www.chicagoparkdistrict.com/departments/administration/communications/foia',
 '[{"name": "Karen Choudhury", "role": "Freedom of Information Act Counsel, Chicago Park District", "email": "FOIA@ChicagoParkDistrict.com", "phone": "312-742-4789"}]'::jsonb, '{}', '{}', 'in_conversation', 'us',
 'Records requests under the Illinois FOIA (5 ILCS 140). FOIA 6838, filed Sep 2, 2026 from rastafari501c3@gmail.com: creation and numbering of Maggie Daley Park / North Grant Park / Park No. 1303, narrowed Oct 1, 2026 to Board public comments (Sep 12 to Oct 31, 2012) plus items A (cost center 1303 creation), B (first position at 1303), C (park boundary GIS/legal description), D (park/location number assignment procedure).',
 'REPLY IN WRITING from rastafari501c3@gmail.com to Karen Choudhury agreeing to extend FOIA 6838 to Mon Nov 23, 2026 close of business (CPD asked Nov 16 under 5 ILCS 140/3(e)), replying to the Nov 16 Message-ID. Then watch for the records by Nov 23 COB.', '2026-11-23',
 'Chicago Park District FOIA email Nov 16, 2026 (extension notices Nov 3, Nov 6, Nov 16 in the thread)',
 'Internal legal-process tracking only. FOIA 6838 requester: Stephen Henry, Ras Tafari Inc., from rastafari501c3@gmail.com. FOIA 6903 (SSCC bylaws) is a separate request handled by Stephen; no tracker events for it yet. Not a partner and not a grant.', '2026-11-16 18:33:26+00'
where not exists (select 1 from fs_partners where name = 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' (ref ' || v.marker || ')', 'in_conversation', v.by_email, v.by_name, v.at::timestamptz
from fs_partners p cross join (values
 ('FOIA6838 evt 2026-09-02 00:13', '2026-09-02 00:13:00-05', 'rastafari501c3@gmail.com', 'Stephen Henry',
  'Sep 2, 2026 (12:13 am CT): Stephen (Ras Tafari Inc., from rastafari501c3@gmail.com) filed the original FOIA request to FOIA@ChicagoParkDistrict.com: records on the creation, naming and administrative establishment of Maggie Daley Park / North Grant Park / Park No. 1303, Sep 1, 2012 to Apr 30, 2013 (10 items).'),
 ('FOIA6838 evt 2026-09-02 11:03', '2026-09-02 11:03:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Sep 2, 2026 (11:03 am CT): CPD (Karen Choudhury) acknowledged and assigned tracking number FOIA 6838.'),
 ('FOIA6838 evt 2026-09-10 18:35', '2026-09-10 18:35:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Sep 10, 2026 (6:35 pm CT, per Gmail attribution): CPD sent the Part 1 production (attachments) and a request to narrow. A quoted notice also cites 5 ILCS 140/3(c): the entirety of an electronic request must appear in the email body.'),
 ('FOIA6838 evt 2026-10-01 10:20', '2026-10-01 10:20:00-05', 'rastafari501c3@gmail.com', 'Stephen Henry',
  'Oct 1, 2026 (10:20 am CT): Stephen narrowed FOIA 6838 under 5 ILCS 140/3(g): withdrew items 1-3 except written public comments to the Board Secretary on naming North Grant Park (Sep 12 to Oct 31, 2012); new items A (cost center 1303 creation, Budget and Finance, Sep 2012 to Dec 2013), B (first position assigned to 1303, HR), C (park boundary GIS/legal description, Planning), D (policy for assigning park/location numbers, 2012 to 2014); items 4-10 withdrawn. Existing records only.'),
 ('FOIA6838 evt 2026-10-01 17:01', '2026-10-01 17:01:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 1, 2026 (5:01 pm CT): CPD accepted the narrowed request and said to expect a response by Oct 8, 2026 close of business.'),
 ('FOIA6838 evt 2026-10-08 23:16', '2026-10-08 23:16:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 8, 2026 (11:16 pm CT, per Gmail attribution): CPD asked to extend under 5 ILCS 140/3(e) to Oct 16, 2026 COB (examination for exemption; undue burden; consultation). Park District closed Oct 12.'),
 ('FOIA6838 evt 2026-10-17 18:39', '2026-10-17 18:39:00-05', 'rastafari501c3@gmail.com', 'Stephen Henry',
  'Oct 17, 2026 (6:39 pm CT): Stephen agreed in writing (signed President, Ras Tafari Inc.) to extend FOIA 6838 to Oct 23, 2026 COB, from rastafari501c3@gmail.com.'),
 ('FOIA6838 evt 2026-10-23 14:04', '2026-10-23 14:04:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 23, 2026 (2:04 pm CT): CPD asked to extend to Oct 30, 2026 COB (same three 3(e) reasons). No written agreement from us appears in the quoted thread.'),
 ('FOIA6838 evt 2026-11-03 11:16', '2026-11-03 11:16:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 3, 2026 (11:16 am CT): CPD asked to extend to Nov 6, 2026 COB (same three 3(e) reasons). No written agreement from us appears in the quoted thread.'),
 ('FOIA6838 evt 2026-11-06 18:54', '2026-11-06 18:54:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 6, 2026 (6:54 pm CT): CPD asked to extend to Nov 16, 2026 COB (same three 3(e) reasons); closed Nov 11 for Veterans Day. No written agreement from us appears in the quoted thread.'),
 ('FOIA6838 evt 2026-11-16 12:33', '2026-11-16 18:33:26+00', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 16, 2026 (12:33 pm CST): CPD (Karen Choudhury, FOIA Counsel) is still working on FOIA 6838 and asks for our written agreement to extend to Nov 23, 2026 COB under 5 ILCS 140/3(e); boxes checked: records need examination/evaluation for exemption, and cannot comply in time without unduly burdening operations (consultation box not checked this time). May seek more time. Not yet answered. Message-ID <SA1PR09MB1000437189C0BC3DE094F9ED5D27C2@SA1PR09MB10004.namprd09.prod.outlook.com>.')
) as v(marker, at, by_email, by_name, summary)
where p.name = 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref ' || v.marker || ')%');

update fs_partners set notes = coalesce(notes,'') || E'
2026-11-18: Nov 16 extension notice (to Nov 23 COB) logged. Of the Oct 8, Oct 23, Nov 3, Nov 6 and Nov 16 notices, only the Oct 17 agreement is visible in the quoted thread.'
where name = 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)'
  and coalesce(notes,'') not like '%2026-11-18: Nov 16 extension notice%'
  and coalesce(notes,'') like '%Internal legal-process tracking only%';

commit;

select id, name, stage, ball_with, next_step_due, last_contact_at from fs_partners where name like 'Chicago Park District FOIA requests%';
select a.created_at, a.by_name, left(a.summary, 70) s from fs_partner_activity a join fs_partners p on p.id = a.partner_id where p.name like 'Chicago Park District FOIA requests%' order by a.created_at;

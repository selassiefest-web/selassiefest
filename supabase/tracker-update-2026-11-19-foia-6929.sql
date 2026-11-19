-- Nov 19, 2026: Chicago Park District FOIA 6929 (Jackson Park, Park No. 19 boundary + 63rd Street Beach GIS). NOT APPLIED; for review.
-- Source: C:\Users\mkepr\Downloads\BOB\FOIA_6929_Jackson_Park_(Park_No._19)_boundary.eml (+ original request FOIA_Request_-_Jackson_Park_(Park_No._19)_boundary_and_GIS_records_for_63rd_Street_Beach.eml).
-- Newest message: Fri Nov 13, 2026 19:46:29 UTC (1:46 pm CST), from FOIA@ChicagoParkDistrict.com (Karen Choudhury, FOIA Counsel),
--   To: 'Jamaican Stevie' <jamaicanstevie87@gmail.com>. Reply address = jamaicanstevie87@gmail.com ONLY.
--   Message-ID <SA1PR09MB1000444116FD0E1179C2EC2CFD27F2@SA1PR09MB10004.namprd09.prod.outlook.com>
-- DESIGN: 6929 is its own self-contained row for now. The unapplied 6838 script (tracker-update-2026-11-18-foia-6838.sql) would create a separate row
--   "Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)"; this script neither depends on nor touches it. Merge later only if Stephen wants one shared row.
-- Legal-process record, not a partner pitch; CPD partner-send hold does not apply.
-- Times: America/Chicago (CDT UTC-5 through Oct 31, CST UTC-6 from Nov 1). Quoted Outlook "Sent" lines taken as CPD local time; the Nov 13 time (UTC) and the Oct 7 16:51 -0500 time are true headers.
-- Safe to re-run: partner insert guarded by name, each activity guarded by (ref FOIA6929 evt ...) marker, notes update guarded by marker.
begin;

insert into fs_partners (name, category, phone, email, website, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes, last_contact_at)
select 'Chicago Park District FOIA 6929 (Jackson Park No. 19 boundary, 63rd St Beach GIS)', 'Civic/government', '312-742-4789', 'FOIA@ChicagoParkDistrict.com', 'https://www.chicagoparkdistrict.com/departments/administration/communications/foia',
 '[{"name": "Karen Choudhury", "role": "Freedom of Information Act Counsel, Chicago Park District", "email": "FOIA@ChicagoParkDistrict.com", "phone": "312-742-4789"}]'::jsonb, '{}'::text[], '{}'::text[], 'in_conversation', 'us',
 'Illinois FOIA (5 ILCS 140) request FOIA 6929, filed Oct 7, 2026 from jamaicanstevie87@gmail.com (requester name on the request: Steven Peters): (1) current official boundary map/property map/legal description of Jackson Park, Park No. 19; (2) existing GIS feature(s) and stored attributes for 63rd Street Beach, 59th to 63rd Street Beach, 63rd Street Bathing Pavilion (6245 S. DuSable Lake Shore Drive), 63rd Street Beach Dunes; (3) any map/GIS feature showing the swimming/beach/natural area as a separate area within Park No. 19; (4) any record that 63rd Street Beach or the Pavilion was ever assigned its own park/property number. Planning & Development (GIS, property records). Existing records only.',
 'REPLY IN WRITING to Karen Choudhury (replying to the Nov 13 Message-ID) agreeing or declining the extension to Fri Nov 20, 2026 close of business (the email cites "104/3(f)" as written). SEND FROM jamaicanstevie87@gmail.com ONLY (the address the FOIA email was addressed to); never from rastafari501c3@gmail.com or stephen@selassiefest.com. Then watch for records by Nov 20 COB; if none, ask for a firm production date.', '2026-11-20'::date,
 'Chicago Park District FOIA email Nov 13, 2026 (extension notices Oct 15, Oct 22, Oct 29, Nov 5, Nov 13 in the thread)',
 'Internal legal-process tracking only. FOIA 6929 filer/owner of record: "Steven Peters" at jamaicanstevie87@gmail.com. UNVERIFIED: who Steven Peters is and who holds this account relative to Ras Tafari Inc.; confirm with Stephen. Not a partner and not a grant. No written agreement from us to any extension appears in the quoted thread (CPD messages only; our Sent folder not checked). No records produced as of the Nov 13 email.', '2026-11-13 19:46:29+00'::timestamptz
where not exists (select 1 from fs_partners where name = 'Chicago Park District FOIA 6929 (Jackson Park No. 19 boundary, 63rd St Beach GIS)');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' (ref ' || v.marker || ')', 'in_conversation', v.by_email, v.by_name, v.at::timestamptz
from fs_partners p cross join (values
 ('FOIA6929 evt 2026-10-07 16:51', '2026-10-07 16:51:00-05', 'jamaicanstevie87@gmail.com', 'Steven Peters (unverified identity)',
  'Oct 7, 2026 (4:51 pm CT): FOIA filed to foia@chicagoparkdistrict.com from jamaicanstevie87@gmail.com (name on request: Steven Peters) for Jackson Park (Park No. 19) boundary/legal description, existing GIS features and attributes for 63rd Street Beach / Bathing Pavilion / Dunes, any separate beach or natural-area map within Park 19, and any record of a separate park/property number (4 items; existing records only). Message-ID <CAMn0-4vSsH3w5cDf=gXaz-jg+BMA5iKmrGaKtfYUkt29QDqSOg@mail.gmail.com>.'),
 ('FOIA6929 evt 2026-10-07 17:48', '2026-10-07 17:48:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 7, 2026 (5:48 pm CT): CPD acknowledged and assigned tracking number FOIA 6929; response expected by Oct 15, 2026 COB (closed Oct 12 for Columbus Day).'),
 ('FOIA6929 evt 2026-10-15 18:08', '2026-10-15 18:08:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 15, 2026 (6:08 pm CT): CPD invoked the five-day automatic extension (cited as 5 ILCS 140/3(e)(vi)); new due date Oct 22, 2026 COB.'),
 ('FOIA6929 evt 2026-10-22 15:40', '2026-10-22 15:40:00-05', 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy (Senior Counsel, CPD)',
  'Oct 22, 2026 (3:40 pm CT): CPD (signed by Kevin Murphy, Senior Counsel; cc Alma Estrada) asked our written agreement to extend to Oct 29, 2026 COB (boxes checked: records not yet located in routine search; examination for exemption). No written agreement from us appears in the quoted thread.'),
 ('FOIA6929 evt 2026-10-29 20:45', '2026-10-29 20:45:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 29, 2026 (8:45 pm CT): CPD asked our written agreement to extend to Nov 5, 2026 COB (examination for exemption; undue burden). No written agreement from us appears in the quoted thread.'),
 ('FOIA6929 evt 2026-11-05 17:31', '2026-11-05 17:31:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 5, 2026 (5:31 pm CT): CPD asked our written agreement to extend to Nov 13, 2026 COB (examination; undue burden; consultation); closed Nov 11 for Veterans Day. No written agreement from us appears in the quoted thread.'),
 ('FOIA6929 evt 2026-11-13 19:46', '2026-11-13 19:46:29+00', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 13, 2026 (19:46:29 UTC, 1:46 pm CST): CPD (Karen Choudhury, FOIA Counsel) still working on FOIA 6929; asks our written agreement to extend a minimum of five business days to Fri Nov 20, 2026 COB (citing "104/3(f)" as written in the email); boxes checked: records stored at other locations, examination/evaluation for exemption, undue burden (consultation not checked); may seek more time. Addressed To: jamaicanstevie87@gmail.com, so any reply must come from that address. Not yet answered. Message-ID <SA1PR09MB1000444116FD0E1179C2EC2CFD27F2@SA1PR09MB10004.namprd09.prod.outlook.com>.')
) as v(marker, at, by_email, by_name, summary)
where p.name = 'Chicago Park District FOIA 6929 (Jackson Park No. 19 boundary, 63rd St Beach GIS)'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref ' || v.marker || ')%');

update fs_partners set notes = coalesce(notes,'') || E'\n2026-11-19: Nov 13 extension notice (to Nov 20 COB) logged. Reply owed from jamaicanstevie87@gmail.com by Nov 20 COB.'
where name = 'Chicago Park District FOIA 6929 (Jackson Park No. 19 boundary, 63rd St Beach GIS)'
  and coalesce(notes,'') not like '%2026-11-19: Nov 13 extension notice%';

commit;

select id, name, stage, ball_with, next_step_due, last_contact_at from fs_partners where name like 'Chicago Park District FOIA 6929%';
select a.created_at, a.by_name, left(a.summary, 70) s from fs_partner_activity a join fs_partners p on p.id = a.partner_id where p.name like 'Chicago Park District FOIA 6929%' order by a.created_at;

-- tracker-update-2026-11-20-foia-6903.sql  (NOT APPLIED; for review)
-- Source .eml: C:\Users\mkepr\Downloads\BOB\RE__FOIA_6903_–__Part_3.eml
-- Newest message: Fri Nov 20, 2026 18:04:33 UTC = 12:04 pm CST, from FOIA@ChicagoParkDistrict.com (Kevin Murphy, Senior Counsel, for Karen Choudhury who is absent),
--   To stephen@selassiefest.com, Cc Alma.Estrada@ChicagoParkDistrict.com and FOIA@ChicagoParkDistrict.com,
--   Message-ID <DS3PR09MB13125672998B29D3DE181F3C989782@DS3PR09MB13125.namprd09.prod.outlook.com>
-- Offers in-person review (HQ, 4830 S. Western) Wed 11/25 9:30-1, Wed 12/2 9:30-4, Fri 12/4 9:30-4. Stephen chose Dec 2 (chat, Nov 20).
-- Live check Nov 20: Message-ID and "6903" absent from fs_partner_activity.summary, fs_grant_deadlines.notes, rti_calendar_events; no FOIA table exists.
-- Times: CDT (-05) through Oct 31, CST (-06) from Nov 1. Outlook Sent lines taken as CPD/requester local time.
-- Safe to re-run: each activity guarded by marker, row update guarded by marker.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' (ref ' || v.marker || ')', 'in_conversation', v.by_email, v.by_name, v.at::timestamptz
from fs_partners p cross join (values
 ('FOIA6903 evt 2026-10-13 21:11', '2026-10-13 21:11:00-05', 'stephen@selassiefest.com', 'Stephen Henry',
  'Oct 13, 2026 9:11 pm CT: Stephen agreed to the 3(g) extensions on FOIA 6903 (Part 1, South Shore Cultural Center Advisory Council bylaws): 21 business days for electronic records, 35 for hardcopy; asked for fee waiver under 5 ILCS 140/6(c) and rolling production.'),
 ('FOIA6903 evt 2026-10-16 17:35', '2026-10-16 17:35:00-05', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Oct 16, 2026 5:35 pm CT: CPD confirmed 21-day (electronic) and 35-day (hardcopy) extensions; hardcopy bylaws to be made available for in-person inspection at CPD Headquarters, 4830 S. Western Ave., Chicago 60609; will schedule when assembled.'),
 ('FOIA6903 evt 2026-10-16 17:49', '2026-10-16 17:49:00-05', 'stephen@selassiefest.com', 'Stephen Henry',
  'Oct 16, 2026 5:49 pm CT: Stephen thanked CPD for confirming the extensions and arranging inspection at HQ; asked to confirm due dates, whether he may photograph pages with his phone, copies beyond the first 50 free pages under the 5 ILCS 140/6(c) fee waiver, electronic records as located, and a short note for any council with no bylaws on file. CPD had not answered the photo question in the thread.'),
 ('FOIA6903 evt 2026-11-06 16:11', '2026-11-06 16:11:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 6, 2026 4:11 pm CT: CPD sent Part 2 documents and proposed in-person review dates; electronic response promised by Fri Nov 13 COB.'),
 ('FOIA6903 evt 2026-11-09 13:56', '2026-11-09 13:56:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 9, 2026 1:56 pm CT: CPD noted no reply yet on scheduling the in-person hardcopy review and offered Wed Nov 18 at 10 am or 1 pm.'),
 ('FOIA6903 evt 2026-11-10 09:30', '2026-11-10 09:30:00-06', 'stephen@selassiefest.com', 'Stephen Henry',
  'Nov 10, 2026 9:30 am CT: Stephen replied he is available Wed Nov 18 at 10 am or 1 pm and asked CPD to schedule the meeting.'),
 ('FOIA6903 evt 2026-11-13 13:22', '2026-11-13 13:22:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 13, 2026 1:22 pm CT: CPD sent Part 3 documents and asked for written agreement to extend to Fri Nov 20 COB (cites "104/3(f)"/140/3(e); boxes checked: examination by competent personnel, unduly burdensome). Review meeting planned Wed Nov 18 10 am.'),
 ('FOIA6903 evt 2026-11-17 11:13', '2026-11-17 11:13:00-06', 'FOIA@ChicagoParkDistrict.com', 'Karen Choudhury',
  'Nov 17, 2026 11:13 am CT: CPD cancelled the Nov 18 review (unforeseen circumstances); asked Stephen''s availability Mon/Wed/Fri of the week of Nov 23 (he may suggest the following week); CPD closed Thanksgiving Nov 26.'),
 ('FOIA6903 evt 2026-11-18 01:40', '2026-11-18 01:40:00-06', 'stephen@selassiefest.com', 'Stephen Henry',
  'Nov 18, 2026 1:40 am CT: Stephen replied that he is available any time Wed or Fri. NOTE: this reply does not state written agreement to the Nov 13 extension to Nov 20 COB.'),
 ('FOIA6903 evt 2026-11-20 12:04', '2026-11-20 12:04:33-06', 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy',
  'Nov 20, 2026 12:04 pm CST: Kevin Murphy (Senior Counsel, DIR 312-742-4604, for Karen Choudhury, absent) offered in-person review at CPD HQ, 4830 S. Western Ave., conference room: Wed 11/25 9:30 am-1 pm, Wed 12/2 9:30 am-4 pm, Fri 12/4 9:30 am-4 pm; asked which date is best. (Stephen''s choice per chat Nov 20: Wed Dec 2, not yet communicated to CPD.) Message-ID <DS3PR09MB13125672998B29D3DE181F3C989782@DS3PR09MB13125.namprd09.prod.outlook.com>. To stephen@selassiefest.com; Cc Alma Estrada, FOIA@.')
) as v(marker, at, by_email, by_name, summary)
where p.name = 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref ' || v.marker || ')%');

update fs_partners
set ball_with = 'us',
    next_step = coalesce(next_step,'') || ' FOIA 6903: REPLY by Mon Nov 23, 2026 (our target; CPD set no deadline) from stephen@selassiefest.com (the address the Nov 20 .eml was addressed to), threaded to Message-ID DS3PR09MB13125672998B29D3DE181F3C989782, choosing Wed Dec 2, 2026 for the in-person review at CPD HQ, 4830 S. Western Ave. (offered 9:30 am-4 pm); also state written agreement to the Nov 13 extension. Then attend Dec 2 (owner Stephen Henry).',
    notes = replace(coalesce(notes,''), 'no tracker events for it yet', 'tracker events for 6903 logged Nov 20, 2026') || E'\n2026-11-20: FOIA 6903 Part 3 review-date offer logged (Message-ID DS3PR09MB13125672998B29D3DE181F3C989782). Owner Stephen Henry. Dec 2 chosen by Stephen Nov 20; reply NOT yet sent; CPD has not confirmed time or room. Written agreement to Nov 13 extension (to Nov 20 COB) not found in thread.',
    last_contact_at = '2026-11-20 12:04:33-06'
where name = 'Chicago Park District FOIA requests (6838 Maggie Daley, 6903 SSCC bylaws)'
  and notes not like '%DS3PR09MB13125672998B29D3DE181F3C989782%';

commit;

select p.name, p.next_step_due, (p.notes like '%DS3PR09MB13125672998B29D3DE181F3C989782%') as noted,
 (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6903 evt%') as foia6903_events
from fs_partners p where p.name like 'Chicago Park District FOIA requests%';

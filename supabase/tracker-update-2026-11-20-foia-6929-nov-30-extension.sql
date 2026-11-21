-- tracker-update-2026-11-20-foia-6929-nov-30-extension.sql
-- BOB: FOIA_6929_Jackson_Park_(Park_No._19)_boundary_.eml (Fri Nov 20, 2026 22:14:39 UTC = 4:14 pm CST), From FOIA@ChicagoParkDistrict.com (Kevin Murphy),
-- To FOIA@ChicagoParkDistrict.com and jamaicanstevie87@gmail.com. Asks written agreement to extend to Mon Nov 30, 2026 COB
-- (boxes: records at other locations; examination/exemption review; undue burden). Safe to re-run (activity guarded by marker).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 20, 2026 (22:14 UTC, 4:14 pm CST): CPD (Kevin Murphy) again asks our written agreement to extend FOIA 6929 to Mon Nov 30, 2026 COB (boxes checked: records at other locations; examination/evaluation for exemption; undue burden). Addressed To jamaicanstevie87@gmail.com, so any reply must come from that address (Steven Peters sends). No sign in BOB that the Nov 13 agreement (to Nov 20) was sent. Message-ID <DS3PR09MB1312582708C88C5B2F901F2A289782@DS3PR09MB13125.namprd09.prod.outlook.com>. (ref FOIA6929 evt 2026-11-20 16:14)',
 p.stage, 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy', '2026-11-20 22:14:39+00'::timestamptz
from fs_partners p
where p.id = 'a0eaeac2-9987-41b3-8206-e465a11a9463'
  and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6929 evt 2026-11-20 16:14%');

update fs_partners
set ball_with = 'us',
    next_step_due = '2026-11-23',
    next_step = 'REPLY IN WRITING to Kevin Murphy and Karen Choudhury (reply to the Nov 20, 4:14 pm CST message) agreeing to extend FOIA 6929 to Mon Nov 30, 2026 close of business. SEND FROM jamaicanstevie87@gmail.com ONLY (the address the FOIA email was addressed to); Steven Peters sends; never from rastafari501c3@gmail.com or stephen@selassiefest.com. DRAFT: C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\foia-6929-reply\reply-extension-nov-30.txt. Then watch for records by Nov 30 COB; if none, ask for a firm production date.',
    last_contact_at = '2026-11-20 22:14:39+00'::timestamptz
where id = 'a0eaeac2-9987-41b3-8206-e465a11a9463';

commit;

select name, ball_with, next_step_due, last_contact_at,
 (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6929 evt 2026-11-20 16:14%') as logged
from fs_partners p where id='a0eaeac2-9987-41b3-8206-e465a11a9463';

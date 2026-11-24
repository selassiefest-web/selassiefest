-- tracker-update-2026-11-23-foia-6838-extension.sql  (reviewed; corrections applied)
-- Source: C:\Users\mkepr\Downloads\BOB\FOIA_6838_Maggie_Daley_Park___North_Grant_Park___Park_No._1303.eml
--   From FOIA@ChicagoParkDistrict.com (signed Kevin Murphy, Senior Counsel), To FOIA@ + rastafari501c3@gmail.com,
--   Mon Nov 23, 2026 22:23:35 UTC = 4:23 pm CST. Message-ID below. Only attachment: image001.png (signature logo); NO records produced.
-- CPD asks WRITTEN agreement to extend FOIA 6838 (min 5 business days) to Tue Dec 1, 2026 COB; boxes ticked: 3(e) exam/evaluation for exemptions;
--   cannot comply without unduly burdening operations. Prior due date was Nov 23 COB (agreement already sent Nov 18).
-- Live check Nov 23: Message-ID and "evt 2026-11-23 16:23" absent from fs_partner_activity.summary. Builds on the foia-6903 file (next_step_due 2026-11-24).
-- Safe to re-run: activity guarded by marker, row update guarded by notes marker. Times CST (-06).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 23, 2026 (4:23 pm CST): CPD (Kevin Murphy, Senior Counsel) asked for WRITTEN agreement to extend FOIA 6838 (Maggie Daley Park / North Grant Park / Park No. 1303) at least 5 business days to Tue Dec 1, 2026 COB, under 5 ILCS 140/3(e) (examination/evaluation for exemptions; cannot comply without undue burden). Sent to FOIA@ChicagoParkDistrict.com and rastafari501c3@gmail.com. No records attached (only a signature logo). Quotes the Nov 16 notice. Written agreement NOT yet given. Reply must come from rastafari501c3@gmail.com. Message-ID <DS3PR09MB131250DAD44A0F432BC07794B89452@DS3PR09MB13125.namprd09.prod.outlook.com>. (ref FOIA6838 evt 2026-11-23 16:23)',
 p.stage, 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy', '2026-11-23 16:23:35-06'::timestamptz
from fs_partners p
where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%FOIA6838 evt 2026-11-23 16:23%');

update fs_partners
set ball_with = 'us',
    next_step = replace(replace(next_step,
      'FOIA 6838: agency due Mon Nov 23, 2026 COB; no production seen in BOB as of Nov 23 evening, status unknown; if nothing arrives, ask for a firm date from rastafari501c3@gmail.com.',
      'FOIA 6838 (owner Stephen Henry): CPD asked (Nov 23 4:23 pm CST, Kevin Murphy) for WRITTEN agreement to extend to Tue Dec 1, 2026 COB. Stephen AGREED in chat Nov 23; written reply NOT yet sent: SEND by Tue Nov 24, 2026 from rastafari501c3@gmail.com (the address CPD wrote to, NOT stephen@), threaded to Message-ID DS3PR09MB131250DAD44A0F432BC07794B89452; ask for a firm production date and rolling production. No records received yet.'),
      'SEND written agree-or-decline on CPD''s Part 4 request to extend the electronic portion to Mon Nov 30, 2026 COB, by Tue Nov 24, 2026',
      'Stephen AGREED in chat Nov 23 to extend the electronic portion to Mon Nov 30, 2026 COB; written reply NOT yet sent: SEND by Tue Nov 24, 2026'),
    next_step_due = '2026-11-24',
    notes = coalesce(notes,'') || E'\n2026-11-23: FOIA 6838 extension request (CPD, Kevin Murphy, Senior Counsel, 4:23 pm CST, Message-ID DS3PR09MB131250DAD44A0F432BC07794B89452@DS3PR09MB13125.namprd09.prod.outlook.com): written agreement requested to extend to Dec 1, 2026 COB (5 business days; 3(e) exam/evaluation and undue burden). No records attached. Stephen decided in chat Nov 23 to AGREE to this (6838, Dec 1) and to the 6903 Nov 30 extension; written replies pending, NOT yet sent. Owner Stephen Henry; 6838 reply from rastafari501c3@gmail.com, 6903 reply from stephen@selassiefest.com, by Nov 24. [src:foia6838-nov23-ext]',
    last_contact_at = greatest(last_contact_at, '2026-11-23 16:23:35-06'::timestamptz)
where id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and next_step like '%FOIA 6838: agency due Mon Nov 23, 2026 COB;%'
  and coalesce(notes,'') not like '%[src:foia6838-nov23-ext]%';

commit;

select p.ball_with, p.next_step_due,
 (p.notes like '%[src:foia6838-nov23-ext]%') as noted,
 (p.next_step like '%FOIA 6838 (owner Stephen Henry)%' and p.next_step like '%FOIA 6903 (owner Stephen Henry)%') as both_items_in_next_step,
 (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6838 evt 2026-11-23 16:23%') as logged
from fs_partners p where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5';

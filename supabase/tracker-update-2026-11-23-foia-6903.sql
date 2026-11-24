-- tracker-update-2026-11-23-foia-6903.sql  (reviewed; fixes applied per reviewer)
-- Sources: C:\Users\mkepr\Downloads\BOB\Re__FOIA_6903_–__Part_4.eml (Stephen's SENT reply, Mon Nov 23, 2026 22:55:45 UTC = 4:55 pm CST,
--   From stephen@selassiefest.com To FOIA@ChicagoParkDistrict.com, Message-ID <CO6P220MB0338FD13E4A68441BAC0292FD7452@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>)
--   which quotes CPD's Part 4 email (Kevin Murphy, Senior Counsel, Mon Nov 23, 2026 3:20 pm CST = 21:20 UTC; Cc Alma Estrada;
--   Message-ID <CY2PR09MB131354CB8D29DD2C81B81EDB389452@CY2PR09MB13135.namprd09.prod.outlook.com>; no standalone .eml of it exists in BOB, attachments unknown).
-- Live check Nov 23: neither Message-ID nor "Part 4" appears in fs_partner_activity.summary or fs_partners.notes.
-- CPD's Part 4 asks for WRITTEN agreement to extend the electronic-records portion 4 business days to Mon Nov 30, 2026. Stephen's Nov 23 reply did NOT give it.
-- Times: CST (-06) from Nov 1. Safe to re-run: activity guarded by marker, row update guarded by marker.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' (ref ' || v.marker || ')', 'in_conversation', v.by_email, v.by_name, v.at::timestamptz
from fs_partners p cross join (values
 ('FOIA6903 evt 2026-11-23 15:20', '2026-11-23 15:20:00-06', 'FOIA@ChicagoParkDistrict.com', 'Kevin Murphy',
  'Nov 23, 2026 3:20 pm CST: Kevin Murphy (Senior Counsel, Cc Alma Estrada) CONFIRMED the in-person review of the FOIA 6903 hardcopy bylaws for Wed Dec 2, 2026 at 10:00 am at CPD HQ, 4830 S. Western Ave.; tell front-desk security you are meeting FOIA officer Karen Choudhury; CPD will answer the phone-photograph request before the meeting. Sent Part 4 of the electronic-copies response (attachments not seen; only quoted in Stephen''s reply) and REQUESTED WRITTEN AGREEMENT to extend the electronic portion 4 business days to Mon Nov 30, 2026. Message-ID <CY2PR09MB131354CB8D29DD2C81B81EDB389452@CY2PR09MB13135.namprd09.prod.outlook.com>. To stephen@selassiefest.com and FOIA@. Time is the Outlook Sent line in the quote.'),
 ('FOIA6903 evt 2026-11-23 16:55', '2026-11-23 16:55:45-06', 'stephen@selassiefest.com', 'Stephen Henry',
  'Nov 23, 2026 4:55 pm CST: Stephen SENT a reply (Re: FOIA 6903 Part 4) to FOIA@ChicagoParkDistrict.com saying Secretary Albert Harris will attend Dec 2, 2026 at 10:00 am and conduct the review on Ras Tafari''s behalf. NOTE: it does NOT agree to the Nov 30 extension CPD asked for in writing, and does not repeat the photograph/6(c) fee-waiver request. Message-ID <CO6P220MB0338FD13E4A68441BAC0292FD7452@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.')
) as v(marker, at, by_email, by_name, summary)
where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref ' || v.marker || ')%');

update fs_partners
set ball_with = 'us',
    next_step = 'FOIA 6903 (owner Stephen Henry): SEND written agree-or-decline on CPD''s Part 4 request to extend the electronic portion to Mon Nov 30, 2026 COB, by Tue Nov 24, 2026, from stephen@selassiefest.com (the address CPD wrote to), threaded to Message-ID CY2PR09MB131354CB8D29DD2C81B81EDB389452. Dec 2, 2026 10:00 am review at CPD HQ CONFIRMED by CPD; Albert Harris attends for Ras Tafari; ask CPD to note his name at security and for the photo answer. Part 4 attachments not yet reviewed. FOIA 6838: agency due Mon Nov 23, 2026 COB; no production seen in BOB as of Nov 23 evening, status unknown; if nothing arrives, ask for a firm date from rastafari501c3@gmail.com. FOIA 6925: due Nov 30, 2026 COB; WAIT for CPD. (ball_with us because of the 6903 reply.)',
    next_step_due = '2026-11-24',
    notes = coalesce(notes,'') || E'
2026-11-23: FOIA 6903 Part 4 (CPD, Kevin Murphy, Message-ID CY2PR09MB131354CB8D29DD2C81B81EDB389452@CY2PR09MB13135.namprd09.prod.outlook.com): Dec 2, 2026 10:00 am review CONFIRMED; CPD asks WRITTEN agreement to extend the electronic portion to Mon Nov 30, 2026 (4 business days). Stephen replied Nov 23 4:55 pm CST (Message-ID CO6P220MB0338FD13E4A68441BAC0292FD7452@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM) naming Albert Harris as attendee but did NOT agree to the extension. Extension agreement OPEN. Photo-permission answer promised by CPD before Dec 2. [src:foia6903-part4]',
    last_contact_at = greatest(last_contact_at, '2026-11-23 16:55:45-06'::timestamptz)
where id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and next_step_due = '2026-11-23'
  and coalesce(notes,'') not like '%[src:foia6903-part4]%';

commit;

select p.name, p.ball_with, p.last_contact_at,
 (p.notes like '%[src:foia6903-part4]%') as noted,
 (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6903 evt 2026-11-23%') as nov23_events
from fs_partners p where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5';

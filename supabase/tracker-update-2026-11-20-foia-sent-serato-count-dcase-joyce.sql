-- 2026-11-20 (evening): safe to re-run (guarded by markers).
--  1 FOIA 6903: Stephen SENT the Dec 2 reply (Nov 20 21:21 UTC = 3:21 pm CST)
--  2 Serato: activation count is settled between Stephen and Serato; removed as an open item (Stephen, Nov 20, 2026)
--  3 DCASE: Stephen registered for the Dec 9 Consult DCASE office hours
--  4 Joyce: Maddie Easton's Nov 20 reply (registration request first; unlikely for Dec cycle; program not youth-focused). Reply to her is due ASAP.
begin;

-- ===== 1 FOIA sent =====
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 20, 2026 (3:21 pm CST): Stephen SENT the reply on FOIA 6903 Part 3 to FOIA@ChicagoParkDistrict.com (Cc Alma Estrada), from stephen@selassiefest.com: chose Wed Dec 2, 2026 for the in-person hardcopy review at CPD HQ, 4830 S. Western Ave. (arrive 10:00 am; asked CPD to confirm date, start time and room); agreed in writing to the Nov 13 extension to Nov 20 COB; agreed the Dec 2 review completes the hardcopy portion; asked again whether he may photograph pages with his phone, else fee waiver under 5 ILCS 140/6(c) beyond the first 50 pages. Message-ID <CO6P220MB03380FB7867D5BBAE76EA105D7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. (ref FOIA6903 evt 2026-11-20 15:21 sent)',
 'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-20 21:21:23+00'::timestamptz
from fs_partners p
where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref FOIA6903 evt 2026-11-20 15:21 sent)%');

update fs_partners set
  ball_with = 'them',
  last_contact_at = '2026-11-20 21:21:23+00',
  next_step = coalesce(next_step,'') || ' FOIA 6903 UPDATE Nov 20, 2026: reply SENT 3:21 pm CST choosing Dec 2. Wait for CPD (Kevin Murphy, FOIA@ChicagoParkDistrict.com, 312-742-4604) to confirm date, start time and room, and answer the photo question; if no confirmation by Mon Nov 30, call/email to confirm Dec 2. Review Wed Dec 2, 2026 at 4830 S. Western Ave. (owner Stephen Henry).',
  notes = replace(coalesce(notes,''), 'reply NOT yet sent;', 'reply SENT Nov 20 3:21 pm CST;') || E'\n2026-11-20: Stephen sent the Dec 2 reply and the written agreement to the Nov 13 extension (Message-ID CO6P220MB03380FB7867D5BBAE76EA105D7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM). Awaiting CPD confirmation of time and room.'
where id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and coalesce(notes,'') not like '%CO6P220MB03380FB7867D5BBAE76EA105D7782%';

-- ===== 2 Serato activation count dropped =====
update fs_partners set
  commitment = replace(commitment, 'Number of activations still not stated. ', 'Activation count is settled between Stephen and Serato (Stephen, Nov 20, 2026); NOT an open item, do not raise it again. '),
  next_step = 'Serato account CREATED Nov 20 (stephen@selassiefest.com; name "Rainbow DJ Lab / DJ VIBGYOR"). Brad asked Nov 18 for a school-name account email (e.g. Music@); stephen@ used. Waiting on Brad D (ticket 1231468) to confirm the account name is acceptable and add the software. Set up the generic student profile the day it arrives. Nudge Wed Nov 25 if silent (he is in New Zealand).'
where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167'
  and commitment like '%Number of activations still not stated.%';

update fs_grant_deadlines set
  next_step = 'Serato account created Nov 20 (stephen@selassiefest.com, "Rainbow DJ Lab / DJ VIBGYOR"); asked Brad D (ticket 1231468) whether the name is OK. Wait for him to add the software; nudge Nov 25. Activation count is settled; not an open item.',
  notes = replace(coalesce(notes,''), 'No activation count or value yet.', 'Activation count settled between Stephen and Serato (Nov 20, 2026; not an open item). No value stated.')
where id = 'aaeff4a3-343e-4210-b538-78e14887d5fc'
  and coalesce(notes,'') like '%No activation count or value yet.%';

-- ===== 3 DCASE registration =====
update fs_grant_deadlines set
  next_step = 'Questions EMAIL SENT Nov 18, 2026 to CulturalGrantMaking@cityofchicago.org (which program fits, when first eligible under the 12-month rule, whether pre-incorporation programming counts). REGISTERED Nov 20, 2026 for "Consult DCASE" office hours Wed Dec 9, 2026, 11:30 am-1 pm CST (3 tickets, order #16161304553, sent to selassiefest@gmail.com): attend and ask the three questions in person; if DCASE has not answered the email by then, that covers the Dec 9 nudge. Likely not eligible until 2028.',
  next_step_due = '2026-12-09',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Stephen registered for the DCASE "Consult DCASE" office hours: Wed Dec 9, 2026, 11:30 am-1 pm CST, Chicago, order #16161304553, 3 tickets sent to selassiefest@gmail.com (confirmed by screenshot; this resolves the date question: Dec 9 is the booked session).'
where id = 'bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'
  and coalesce(notes,'') not like '%order #16161304553%';

-- ===== 4 Joyce: Maddie's reply =====
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 20, 2026 (4:07 pm CST): Maddie (Madeline Haught Easton, Culture and Democracy Program Assistant, 312.795.3834) replied to Stephen: before an LOI, Joyce requires a registration request in its Fluxx system (introductory information about the organization and potential project) so the team can check alignment with current strategy; it takes longer than an LOI up front, and with the holiday it is unlikely to be considered for the upcoming December deadline cycle. The program generally does not focus on youth specifically, but if Stephen thinks the work may still fit he may submit the registration request: https://joycefdn.fluxx.io/lois/new . Message-ID <LV0SPRMB0012A67D28DBD62E79463A80D7782@LV0SPRMB0012.namprd15.prod.outlook.com>.',
 (select stage from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18'), 'MEaston@joycefdn.org', 'Maddie Easton', '2026-11-20 22:07:03+00'::timestamptz
from fs_partners p
where p.id = '670cf826-1b34-49ac-b1f9-a0b582debb18'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%LV0SPRMB0012A67D28DBD62E79463A80D7782%');

update fs_partners set
  ball_with = 'us',
  last_contact_at = '2026-11-20 22:07:03+00',
  next_step = 'REPLY TO MADDIE ASAP (Nov 20, 2026; draft in Claude outputs\joyce\reply-to-maddie-2026-11-20.txt): thank her, say we will submit the Fluxx registration request, ask whether registering now keeps us on track for the Apr 1, 2027 cycle and how long review takes, and offer the all-ages public series (Rainbow Wednesdays) as the project. Then submit the registration request at https://joycefdn.fluxx.io/lois/new (Stephen answers the eligibility questions himself). Dec 1, 2026 is NOT available.',
  next_step_due = '2026-11-20',
  contacts = '[{"name":"Bridget","role":"Applications inbox (applications@joycefdn.org); handed us to Culture Oct 29 and Nov 19, 2026","email":"applications@joycefdn.org"},{"name":"Madeline (Maddie) Haught Easton","role":"Culture and Democracy Program Assistant, Joyce Foundation; replied Nov 20, 2026","email":"MEaston@joycefdn.org","phone":"312.795.3834"}]'::jsonb,
  notes = coalesce(notes,'') || E'\n[2026-11-20] REPLY from Maddie Easton (Nov 20, 4:07 pm CST): registration request in Fluxx comes first; unlikely for the Dec 1 cycle; program does not generally focus on youth, but we may still register. Message-ID <LV0SPRMB0012A67D28DBD62E79463A80D7782@LV0SPRMB0012.namprd15.prod.outlook.com>. [src:msgid-LV0SPRMB0012A67D28DBD62E79463A80D7782]'
where id = '670cf826-1b34-49ac-b1f9-a0b582debb18'
  and coalesce(notes,'') not like '%msgid-LV0SPRMB0012A67D28DBD62E79463A80D7782%';

update fs_grant_deadlines set
  next_step = 'Maddie (Joyce) replied Nov 20: submit a Fluxx registration request first (https://joycefdn.fluxx.io/lois/new); unlikely for the Dec 1 cycle; program generally not youth-focused. Reply to Maddie ASAP, then register; aim for the Apr 1, 2027 proposal cycle (confirm with Maddie).',
  next_step_due = '2026-11-20',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Maddie Easton replied: registration request first, Dec 1 unlikely, program not generally youth-focused. No amount change (still $16,800 requested, drafting). [src:msgid-LV0SPRMB0012A67D28DBD62E79463A80D7782]'
where id = 'dc25d586-f390-4553-964a-01fd8090c8e1'
  and coalesce(notes,'') not like '%msgid-LV0SPRMB0012A67D28DBD62E79463A80D7782%';

commit;

select 'foia ball='||ball_with k, (notes like '%CO6P220MB03380FB7867D5BBAE76EA105D7782%')::text ok from fs_partners where id='91fad49d-bff1-4b1f-a611-e6de12145eb5'
union all select 'serato count dropped', (next_step not like '%activation%' and commitment like '%NOT an open item%')::text from fs_partners where id='85a2975b-ae91-4f6f-b7d7-7dd14181c167'
union all select 'dcase registered', (notes like '%order #16161304553%')::text from fs_grant_deadlines where id='bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'
union all select 'joyce ball='||ball_with, (notes like '%msgid-LV0SPRMB0012A67D28DBD62E79463A80D7782%')::text from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18'
union all select 'joyce grant', (notes like '%msgid-LV0SPRMB0012A67D28DBD62E79463A80D7782%')::text from fs_grant_deadlines where id='dc25d586-f390-4553-964a-01fd8090c8e1';

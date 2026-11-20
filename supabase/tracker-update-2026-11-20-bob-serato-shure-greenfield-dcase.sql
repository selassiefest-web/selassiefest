-- 2026-11-20: BOB .eml batch. Safe to re-run (each insert/update guarded by a Message-ID or marker).
--  Serato: Brad D Nov 19 CT reply (needs account email) + Stephen's Nov 20 reply (account created, asks if name OK; Stephen edited the draft himself)
--  Shure: Cheryl Nov 20 reply (checking with teams, no commitment)
--  Green-Field Foundation: DECLINE Nov 20 (no new start-up programs)
--  DCASE: November Opportunities newsletter received (sign-up works)
--  FOIA 6903 is in tracker-update-2026-11-20-foia-6903.sql
begin;

-- ===== Serato =====
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary, 'in_conversation', v.by_email, v.by_name, v.at::timestamptz
from fs_partners p cross join (values
 ('M69PGZZEJ01_6affb61b5ad4e_ef110435f8f6ce_sprut@zendesk.com', '2026-11-20 02:53:15+00', 'sales@serato.com', 'Brad D',
  'Nov 19, 2026 (8:53 pm CT; Nov 20 NZ): Brad D (Serato Sales) replied on ticket 1231468: he just needs a Serato account set up and the email address used for it, so he can add the software for us. No activation count or value stated. Message-ID <M69PGZZEJ01_6affb61b5ad4e_ef110435f8f6ce_sprut@zendesk.com>.'),
 ('CO6P220MB0338D28AA5791762CA407791D7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM', '2026-11-20 21:48:24+00', 'stephen@selassiefest.com', 'Stephen Henry',
  'Nov 20, 2026 (3:48 pm CT): Stephen replied to Brad D on ticket 1231468: the Serato account is created for the Rainbow DJ Lab (Ras Tafari Inc.), email stephen@selassiefest.com, account name "Rainbow DJ Lab / DJ VIBGYOR" with the Rainbow DJ Lab logo; asked whether that name is acceptable for the education licenses or should be changed (e.g. "Ras Tafari Inc. - Rainbow DJ Lab"). That reply did not repeat the activation-count question (13 needed). Message-ID <CO6P220MB0338D28AA5791762CA407791D7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.')
) as v(mid, at, by_email, by_name, summary)
where p.id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%' || v.mid || '%');

update fs_partners set
  ball_with = 'them',
  last_contact_at = '2026-11-20 21:48:24+00',
  next_step = 'Serato account CREATED Nov 20 (stephen@selassiefest.com; name "Rainbow DJ Lab / DJ VIBGYOR"). Waiting on Brad D (ticket 1231468) to confirm the account name is acceptable, add the software and state the number of activations (we need 13; not asked in the Nov 20 reply, ask again if he does not state it). Set up the generic student profile the day it arrives. Nudge Wed Nov 25 if silent (he is in New Zealand).',
  next_step_due = '2026-11-25',
  commitment = commitment || ' | Nov 20: Brad confirmed he only needs the Serato account email; account created and email given (stephen@selassiefest.com); account-name approval asked.'
where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167'
  and commitment not like '%Nov 20: Brad confirmed he only needs%';

update fs_grant_deadlines set
  next_step = 'Serato account created Nov 20 (stephen@selassiefest.com, "Rainbow DJ Lab / DJ VIBGYOR"); asked Brad D (ticket 1231468) whether the name is OK. Wait for him to add the software and state the activation count (need 13); nudge Nov 25.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Brad D (Nov 19 CT) asked only for the Serato account email; Stephen created the account and replied Nov 20 (3:48 pm CT). No activation count or value yet.'
where id = 'aaeff4a3-343e-4210-b538-78e14887d5fc'
  and coalesce(notes,'') not like '%[2026-11-20] Brad D (Nov 19 CT) asked only%';

-- ===== Shure =====
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 20, 2026 (9:22 am CT): Cheryl Jennison Daproza (Shure) replied to Stephen''s Nov 18 four asks (student orientation session, brand guidelines/assets, learning resources, careers talk): she will check with a couple of teams, resources are stretched with product launches, and she will see if there is availability. No commitment yet. Message-ID <SA1PR01MB8671008C4B63A630E336F6D4BD782@SA1PR01MB8671.prod.exchangelabs.com>.',
 'confirmed', 'daprozc@shure.com', 'Cheryl Jennison Daproza', '2026-11-20 15:22:35+00'::timestamptz
from fs_partners p
where p.id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%SA1PR01MB8671008C4B63A630E336F6D4BD782%');

update fs_partners set
  last_contact_at = '2026-11-20 15:22:35+00',
  ball_with = 'them',
  next_step = 'Cheryl (daprozc@shure.com) replied Nov 20: checking with a couple of teams about the four asks, will see if there is availability; resources stretched. WAIT; follow up once Tue Dec 1 if silent. Recognition on the website only per Shure brand guidelines once received; photos in use after the first class.',
  next_step_due = '2026-12-01'
where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
  and coalesce(next_step,'') not like '%replied Nov 20: checking with a couple of teams%';

update fs_grant_deadlines set
  next_step = 'Received Nov 6, 2026 and acknowledged Nov 18. Cheryl replied Nov 20: checking with teams on Stephen''s four asks, no commitment. Follow up Dec 1 if silent. No value stated. Recognition only after Shure''s brand guidelines.',
  next_step_due = '2026-12-01',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Cheryl (Shure) replied: will check with a couple of teams about orientation/brand/learning/careers asks; no commitment. Message-ID <SA1PR01MB8671008C4B63A630E336F6D4BD782@SA1PR01MB8671.prod.exchangelabs.com>.'
where id = 'e95fcd7b-e7eb-4976-8c07-a3fd7dbdf9d5'
  and coalesce(notes,'') not like '%SA1PR01MB8671008C4B63A630E336F6D4BD782%';

-- ===== Green-Field Foundation: decline =====
update fs_grant_deadlines set
  status = 'declined',
  decision_on = '2026-11-20',
  next_step = 'DECLINED Nov 20, 2026 by Kathy Groenendal (President): cannot fund new start-up programs; board mandate to fund established organizations with a proven record. No application filed. Not final: she invites a new letter of inquiry when "more entrenched." Optional reply asking what track record the board wants; revisit with a new LOI after the Rainbow DJ Lab has run a full year. Dec 2 follow-up and Tinley Park hard-copy letter CANCELLED.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n[2026-11-20] Declined by email from Kathy Groenendal (kathy@greenfieldfoundation.org), Message-ID <aea5674b03e1c1ee5dfa83a7414df31f@greenfieldfoundation.org>, 1:18 pm CT: no new start-up programs; invites a new letter of inquiry when more entrenched. Board review date, memorial wording and request size not answered. $10,000 was only a planned ask, never sent.'
where id = '25f4ac41-f367-4dbc-bf0d-e0f1843679ea'
  and coalesce(notes,'') not like '%aea5674b03e1c1ee5dfa83a7414df31f%';

-- ===== DCASE newsletter =====
update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n[2026-11-20] DCASE November Opportunities newsletter received Nov 19 (Message-ID <26d89441-494b-4fa9-80c0-c4c9cda7245c@dfw1s10mta1718.xt.local>): newsletter sign-up is working. No open organizational grant listed. Relevant: DCASE office hours with Cultural Grants staff Wed Dec 9, 11:30 am-1 pm, Chicago Cultural Center Learning Lab (registration required; not yet registered); NOITP call for artists due Dec 8, 11:59 pm (RTI NOITP row already submitted; check whether DCASE call is a separate form); DCASE Performing Arts/Music programming submissions for 2027 rolling; DCASE.partnerships@cityofchicago.com, 312.744.1047.'
where id = 'bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'
  and coalesce(notes,'') not like '%26d89441-494b-4fa9-80c0-c4c9cda7245c%';

commit;

select 'serato' k, ball_with, next_step_due::text d, (commitment like '%Nov 20: Brad confirmed%') ok from fs_partners where id='85a2975b-ae91-4f6f-b7d7-7dd14181c167'
union all select 'shure', ball_with, next_step_due::text, (next_step like '%replied Nov 20%') from fs_partners where id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
union all select 'greenfield:'||status, null, coalesce(next_step_due::text,'null'), (notes like '%aea5674b03e1c1ee5dfa83a7414df31f%') from fs_grant_deadlines where id='25f4ac41-f367-4dbc-bf0d-e0f1843679ea'
union all select 'dcase', null, next_step_due::text, (notes like '%26d89441-494b-4fa9-80c0-c4c9cda7245c%') from fs_grant_deadlines where id='bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'
union all select 'activities', null, count(*)::text, true from fs_partner_activity where summary like '%M69PGZZEJ01_6affb61b5ad4e_ef110435f8f6ce_sprut%' or summary like '%CO6P220MB0338D28AA5791762CA407791D7782%' or summary like '%SA1PR01MB8671008C4B63A630E336F6D4BD782%';

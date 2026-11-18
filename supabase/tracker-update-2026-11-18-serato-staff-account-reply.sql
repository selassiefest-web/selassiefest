-- Nov 18, 2026: Brad D (Serato Sales, ticket 1231468) asked for 3 other staff + an org-named account; Stephen replied the same night (sent 1:37 am CT) with the account setup page. Safe to re-run.
begin;

update fs_partners set
  stage = 'in_conversation',
  ball_with = 'them',
  last_contact_at = '2026-11-18 07:37:27+00',
  contacts = '[{"name":"Brad D","title":"Serato Sales","email":"sales@serato.com"}]'::jsonb,
  commitment = 'Brad D (Serato Sales, ticket 1231468) said Nov 17 (NZ time): "I will be able to give you software for your classes." Number of activations still not stated. Conditions: signed Student Data Policy (SENT Nov 16); name and email of 3 other staff plus a Serato account under the organization name (SENT Nov 18). He will add the software to that account.',
  next_step = 'Wait for Brad D to add the software to the account (stephen@selassiefest.com, Ras Tafari Inc. (Rainbow DJ Lab)) and state the number of activations (we need 13); set up the generic student profile the same day. Nudge Mon Nov 23 if silent (he is in New Zealand).',
  next_step_due = '2026-11-23',
  notes = coalesce(notes,'') || E'\n2026-11-18 (Brad D, 01:36 UTC = Nov 17 7:36 pm CT, Message-ID <M69PGZZEJ01_6afd0124b0232_b637a436dedfea_sprut@zendesk.com>): thanked us; asked for the name and email of 3 other staff members and for a Serato account he can add the software to, under an organization name, not an individual email. 2026-11-18 (Stephen reply SENT 07:37 UTC = 1:37 am CT, Message-ID <CO6P220MB03383FC060EBBC43DFD4C0DCD77A2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>): short email linking the interactive account-setup page https://selassiefest.com/donors/?k=9sx73e44m8nuyfae (account: Ras Tafari Inc. (Rainbow DJ Lab), stephen@selassiefest.com; team with copy buttons and CSV: instructors Eric Louis and DJ Montanna; officers Stephen Henry, Paul Kelly, Albert Harris, Marlon Reid, Craig Rainford). Earlier private pages (donors/?k=bgedzuehedetpw6r proof page, and three interim pages) stay live.'
where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167'
  and coalesce(notes,'') not like '%CO6P220MB03383FC060EBBC43DFD4C0DCD77A2%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '85a2975b-ae91-4f6f-b7d7-7dd14181c167','email',
 'Nov 17, 2026 (7:36 pm CT; Nov 18 NZ): Brad D (Serato Sales) replied on ticket 1231468: needs the name and email of 3 other staff members and a Serato account (under the organization, e.g. a school-name address, not an individual) that he can add the software to. Message-ID <M69PGZZEJ01_6afd0124b0232_b637a436dedfea_sprut@zendesk.com>.',
 'in_conversation','sales@serato.com','Brad D (Serato Sales)'
where not exists (select 1 from fs_partner_activity where partner_id='85a2975b-ae91-4f6f-b7d7-7dd14181c167' and summary like '%M69PGZZEJ01_6afd0124b0232_b637a436dedfea_sprut%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '85a2975b-ae91-4f6f-b7d7-7dd14181c167','email',
 'Nov 18, 2026 (1:37 am CT): Stephen Henry replied to Brad D with a short email linking an interactive account-setup page (https://selassiefest.com/donors/?k=9sx73e44m8nuyfae): account Ras Tafari Inc. (Rainbow DJ Lab) under stephen@selassiefest.com, seven-person team with a Copy button on every name, email and phone, roster table and CSV; asks for the number of activations (13 needed). Message-ID <CO6P220MB03383FC060EBBC43DFD4C0DCD77A2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='85a2975b-ae91-4f6f-b7d7-7dd14181c167' and summary like '%CO6P220MB03383FC060EBBC43DFD4C0DCD77A2%');

-- an activity insert flips ball_with to us, so set it after
update fs_partners set ball_with = 'them' where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167';

update fs_grant_deadlines set
  status = 'submitted',
  next_step = 'Staff list + organization account SENT Nov 18 (1:37 am CT) on ticket 1231468 via the account-setup page. Wait for Brad D to add the software and state the activation count (need 13); set up the generic profile same day; nudge Mon Nov 23 if silent.',
  next_step_due = '2026-11-23'
where id = 'aaeff4a3-343e-4210-b538-78e14887d5fc';

commit;
select p.stage, p.ball_with, p.next_step_due, p.last_contact_at, (select count(*) from fs_partner_activity where partner_id=p.id) acts from fs_partners p where p.id='85a2975b-ae91-4f6f-b7d7-7dd14181c167';
select status, next_step_due from fs_grant_deadlines where id='aaeff4a3-343e-4210-b538-78e14887d5fc';

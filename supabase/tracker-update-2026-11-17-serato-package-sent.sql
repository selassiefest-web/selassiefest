-- Nov 16, 2026 (9:04 pm CT): Stephen sent Serato the signed Student Data Policy package. Safe to re-run.
begin;

update fs_partners set
  stage = 'in_conversation',
  ball_with = 'them',
  last_contact_at = '2026-11-17 03:04:23+00',
  commitment = 'Brad D (Serato Sales, ticket 1231468) said Nov 17 (NZ time): "I will be able to give you software for your classes." Number of activations not yet stated. Condition: signed Student Data Policy (SENT Nov 16).',
  next_step = 'Wait for Brad D to state the number of activations and confirm; then set up the generic student profile (stephen@selassiefest.com) the same day. Nudge Fri Nov 20 if silent.',
  next_step_due = '2026-11-20',
  notes = coalesce(notes,'') || E'\n2026-11-16 (9:04 pm CT): Sent signed Student Data Policy + private page https://selassiefest.com/donors/?k=bgedzuehedetpw6r (IRS letter, articles, W-9, four set-up steps, signed policy, Form 8283 ready on receipt). To sales@serato.com, threaded on ticket 1231468. Message-ID <CO6P220MB0338014654DD0996AA4F4F7BD77B2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.'
where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167'
  and coalesce(notes,'') not like '%CO6P220MB0338014654DD0996AA4F4F7BD77B2%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '85a2975b-ae91-4f6f-b7d7-7dd14181c167','email',
 'Nov 16, 2026 (9:04 pm CT): Stephen Henry sent Brad D (Serato Sales) the signed Student Data Policy and a private page with IRS letter, certified articles, W-9, how we follow Serato''s four set-up steps with students of every age, and Form 8283 ready on receipt. Earlier in the thread (Nov 17 NZ): Brad D asked for proof of nonprofit status, received it, then said he can provide software and sent the Student Data Policy to sign. Asked how many activations Serato will provide. Message-ID <CO6P220MB0338014654DD0996AA4F4F7BD77B2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='85a2975b-ae91-4f6f-b7d7-7dd14181c167' and summary like '%CO6P220MB0338014654DD0996AA4F4F7BD77B2%');

-- an activity insert flips ball_with to us, so set it after
update fs_partners set ball_with = 'them' where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167';

update fs_grant_deadlines set
  status = 'submitted',
  next_step = 'Signed policy package SENT Nov 16 on ticket 1231468. Wait for Brad D to state the number of activations; set up the generic profile same day; nudge Fri Nov 20 if silent.',
  next_step_due = '2026-11-20'
where id = 'aaeff4a3-343e-4210-b538-78e14887d5fc';

select p.name, p.ball_with, p.next_step_due, (select count(*) from fs_partner_activity where partner_id=p.id) acts from fs_partners p where p.id='85a2975b-ae91-4f6f-b7d7-7dd14181c167';
select funder, status, next_step_due from fs_grant_deadlines where id='aaeff4a3-343e-4210-b538-78e14887d5fc';
commit;

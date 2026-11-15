-- Nov 15, 2026: Stephen reports the reply to Israel Rodriguez (AlphaTheta) is SENT. Safe to re-run.
begin;
update fs_partners set
  ball_with = 'them',
  last_contact_at = now(),
  next_step = 'Reply SENT Nov 15, 2026 to Israel Rodriguez (israel.rodriguez@alphatheta.com) offering Teams times and the plan page. Wait for him to pick a time; if silent by Fri Nov 20, one short nudge.',
  next_step_due = '2026-11-20'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a','email','Nov 15, 2026: Stephen replied to Israel Rodriguez (AlphaTheta) accepting the Teams meeting, offering dates and linking the plan page (https://selassiefest.com/startfromscratch-chicago/?k=d97jdsce). Threaded to his Nov 11 message.','in_conversation','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like 'Nov 15, 2026: Stephen replied to Israel Rodriguez%');
update fs_partners set ball_with = 'them' where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a';
commit;
select stage, ball_with, next_step_due from fs_partners where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a';

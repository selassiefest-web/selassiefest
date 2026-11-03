-- Undo the Nov 2 walk-page TEST (2 activity rows on A Haven for Little Ones 2). The walk has not started.
-- Restores the row to the same state as its child care siblings (not_contacted, due Nov 6, our move).
begin;
delete from fs_partner_activity where id in ('294e0609-f60a-4ba7-8187-5ec65f51e4a1','f28a5b5f-7e51-4466-8106-e3e0ed4c98da') and summary like 'Walk 2026-11-02:%';
update fs_partners set stage='not_contacted', next_step_due=date '2026-11-06', ball_with='us', last_contact_at=null,
  next_step='Deliver the letter on the child care walk (childcare-v2 packet), then follow up by phone'
where name like 'A Haven for Little Ones 2 %';
commit;

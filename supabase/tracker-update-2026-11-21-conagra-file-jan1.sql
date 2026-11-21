-- Conagra LOI: file on the first day the window opens (Jan 1, 2027), not Jan 4. Stephen's rule Nov 21, 2026: never wait for the due date unless we must.
begin;
update fs_grant_deadlines set
  next_step = replace(next_step, 'Jan 4, 2027: Stephen registers', 'Jan 1, 2027 (first day the LOI window is open; Stephen files the day it opens, aim Jan 1-2; Stephen may register his CyberGrants account earlier): Stephen registers'),
  updated_at = now()
where id = 'cbc6cfeb-6afd-40e1-9260-b2b8f1bc7459' and next_step like 'Jan 4, 2027: Stephen registers%';
update fs_partners set next_step_due = '2027-01-01',
  next_step = replace(next_step, 'Stephen files Jan 4, 2027.', 'Stephen files Jan 1, 2027, the day the window opens.'),
  updated_at = now()
where id = '2bbb84b0-98e2-4e18-b567-9c35b331b6d4';
update fs_grant_deadlines set next_step_due = '2027-01-01' where id = 'cbc6cfeb-6afd-40e1-9260-b2b8f1bc7459';
select id, next_step_due, left(next_step,90) as next_step from fs_grant_deadlines where id='cbc6cfeb-6afd-40e1-9260-b2b8f1bc7459';
select next_step_due from fs_partners where id='2bbb84b0-98e2-4e18-b567-9c35b331b6d4';
commit;

-- Vandalay Brands formal online donation form SUBMITTED Nov 22, 2026 (Stephen). Safe to re-run.
begin;
update fs_grant_deadlines set
  status='submitted',
  submitted_on='2026-11-22',
  next_step='Waiting on Vandalay (3-4 weeks; they do not answer phone or email). Check Dec 22, 2026; if silent, mark no response.',
  next_step_due='2026-12-22',
  notes = notes || E'\n2026-11-22: Formal online donation form SUBMITTED by Stephen at vandalaybrands.com/donations: 15 x $20 gift cards ($300) per Tuesday DJ Lab class for the snack; 501(c)(3) letter uploaded. The 11/1 email was not the application.'
where id='7efc9d69-cfd0-4a1f-ae4e-3b06add681ae'
  and notes not like '%2026-11-22: Formal online donation form SUBMITTED%';
commit;
select status, submitted_on, next_step_due, right(notes,160) from fs_grant_deadlines where id='7efc9d69-cfd0-4a1f-ae4e-3b06add681ae';

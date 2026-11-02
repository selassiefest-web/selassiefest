-- Delta application filled to the Supporting Documents step on Nov 2, 2026 (CyberGrants request 106198997). NOT submitted.
update fs_grant_deadlines set
  status = 'ready',
  next_step = 'Delta draft FILLED Nov 2 (CyberGrants request 106198997, all steps saved, NOT submitted). Stephen to check the estimates (audience %, $1,600 ticket value), optionally upload the IRS letter, then click Submit at https://www.cybergrants.com/delta/sponsorship. Submit by Nov 11 to keep 90 days before Feb 9, 2027.',
  next_step_due = date '2026-11-04', updated_at = now()
where id = '7d0f78f9-4739-4bb0-a6ab-3086b7028d9f';

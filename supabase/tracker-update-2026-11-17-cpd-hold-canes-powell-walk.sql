-- Nov 17, 2026 (Stephen): Raising Cane's and Powell tabled until CPD gives the GO; walk reset to Nov 20-22. Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step = 'TABLED until CPD gives the GO for Full Spectrum (Stephen, Nov 17). Dashboard showed "Requested" Nov 16. Drafted follow-up stays unsent (Claude outputs/overdue-2026-11-16/DRAFTS-NOT-SENT.txt). See legal/documents-inbox/CPD-HOLD-RULES.md.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n2026-11-17: tabled until CPD GO (Stephen).'
where id = '53fda21e-a4a8-4797-8b73-d5cd54534456' and coalesce(notes,'') not like '%2026-11-17: tabled until CPD GO%';

update fs_grant_deadlines set
  next_step = 'ON HOLD until CPD gives the GO for Full Spectrum (Stephen, Nov 17). Do not call Principal Barlow yet. Call script stays in Claude outputs/overdue-2026-11-16/DRAFTS-NOT-SENT.txt. FY28 CLGS guidelines Dec 16, 2026. See legal/documents-inbox/CPD-HOLD-RULES.md.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n2026-11-17: on hold until CPD GO (Stephen).'
where id = 'd2ecf4c4-d513-48cd-a7ea-888edfb2cf34' and coalesce(notes,'') not like '%2026-11-17: on hold until CPD GO%';

update fs_partners set ball_with = 'cpd_hold', next_step_due = null,
  next_step = 'ON HOLD until CPD gives the GO (Stephen, Nov 17): wait for Principal Barlow; no call yet.',
  notes = coalesce(notes,'') || E'\n2026-11-17: on hold until CPD GO (Stephen).'
where name ilike 'Powell Elementary%' and coalesce(notes,'') not like '%2026-11-17: on hold until CPD GO%';

select funder, status, next_step_due from fs_grant_deadlines where id in ('53fda21e-a4a8-4797-8b73-d5cd54534456','d2ecf4c4-d513-48cd-a7ea-888edfb2cf34');
select name, ball_with, next_step_due from fs_partners where name ilike 'Powell Elementary%';
commit;

-- Cudahy Fund: prepared Nov 22, submission unconfirmed, do not resubmit (Stephen, Nov 24, 2026). Safe to re-run.
begin;

update fs_grant_deadlines
set next_step = 'DO NOT RESUBMIT. LOI prepared Nov 22, 2026; submission unconfirmed (one LOI per organization per year). If a receipt or reply from the Fund appears, log it as submitted.',
    next_step_due = null,
    notes = coalesce(notes, '') || ' | [cudahy-hold 2026-11-24] Online LOI form and cover letter ($10,000, resident instructor pay) prepared Nov 22, 2026. Submission unconfirmed: no receipt or reply found in Outlook, BOB, the database or past session records on Nov 24. Stephen agreed Nov 24: do not resubmit.',
    updated_at = now()
where id = 'b137ba44-772f-4d82-83a2-e57968ac6466'
  and coalesce(notes, '') not like '%[cudahy-hold 2026-11-24]%';

commit;

select funder, status, submitted_on, next_step, next_step_due, notes
from fs_grant_deadlines
where id = 'b137ba44-772f-4d82-83a2-e57968ac6466';

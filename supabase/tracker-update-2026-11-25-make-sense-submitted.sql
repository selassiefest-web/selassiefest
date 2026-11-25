-- Make Sense Foundation application SUBMITTED Nov 25, 2026 (confirmation page captured). Also ADM amount corrected to the sent ask. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    submitted_on = date '2026-11-25',
    amount_requested = 7800,
    next_step = 'SUBMITTED Nov 25, 2026 via the Formsite grant application (on-screen confirmation, no reference number). $7,800, guest woman DJs. The confirmation says only accepted applicants are notified and acceptances happen annually within a calendar year. Check Jan 4, 2027. Contact: Jordan Ascencio, jascencio@makesensefoundation.org.',
    next_step_due = date '2027-01-04',
    notes = coalesce(notes, '') || ' | [make-sense-submitted 2026-11-25] Application confirmed on screen "The Make Sense Grant Application Received". Attached: board roster, financial statements to Sept 30, 2026, 2027 budget, IRS letter, logo. The application page had said quarterly review; the confirmation says annual acceptances.',
    updated_at = now()
where id = 'ff93c749-e8c7-4e5f-a184-6aa94b39993e'
  and coalesce(notes, '') not like '%[make-sense-submitted 2026-11-25]%';

update fs_grant_deadlines
set amount_requested = 7200,
    notes = coalesce(notes, '') || ' | [adm-amount 2026-11-25] amount_requested corrected from 3600 to 7200: the Oct 31 email as sent asked for all four LED DJ booths, $7,200.',
    updated_at = now()
where funder = 'Archer Daniels Midland' and amount_requested = 3600;

commit;

select funder, status, submitted_on, amount_requested, next_step_due, left(next_step, 120) from fs_grant_deadlines
where id = 'ff93c749-e8c7-4e5f-a184-6aa94b39993e' or funder = 'Archer Daniels Midland';

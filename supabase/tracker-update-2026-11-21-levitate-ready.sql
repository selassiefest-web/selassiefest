-- Levitate Foundation: research done, answers drafted, ready for Stephen to submit. Source: Claude outputs\grants\levitate\levitate-answers.md; form https://form.jotform.com/262735554942162
-- Reviewed by partner-grant-data-quality-reviewer. Safe to re-run (status guard + marker guard).
begin;

update fs_grant_deadlines set
  status = 'ready',
  amount_requested = 10000,
  amount = 'up to $10,000',
  project = 'djclass',
  owner = 'Stephen',
  next_step = 'FILE NOW (Stephen presses Submit; file early, form is live, deadline Jan 1, 2027): https://form.jotform.com/262735554942162 . Ask exactly $10,000 (two resident DJ instructors x $250 x 20 of 39 Tuesdays), category Free Arts or Outdoors Workshops / Classes, amount bracket $8000 - $10000. Paste-ready answers: C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\grants\levitate\levitate-answers.md . After submitting, save the confirmation email and tell Claude so the row moves to submitted (status update due within 4 weeks of Jan 1, 2027).',
  next_step_due = '2026-11-23',
  notes = coalesce(notes,'') || E'\n2026-11-21 [levitate-ready-2026-11-21]: Research complete. The form and the Passion Projects page state no geographic restriction and grants up to $10,000; Chicago is eligible as written. Answers drafted for the Rainbow DJ Lab, instructor line only ($250 x 2 x 20 = $10,000). The Park District wording is limited to the offered Tuesday fieldhouse slot (no claim of approval or review; CPD gate fc21556e still open, permission request not sent). Not yet submitted.',
  verified_on = '2026-11-21',
  updated_at = now()
where id = '6568f74b-8a4b-40f8-857f-87792a476991'
  and status = 'to_research'
  and coalesce(notes,'') not like '%levitate-ready-2026-11-21%';

commit;

select id, status, amount_requested, amount, project, owner, next_step_due, verified_on,
       (length(notes) - length(replace(notes,'levitate-ready-2026-11-21','')))/length('levitate-ready-2026-11-21') as marker_count,
       left(next_step,80) as next_step
from fs_grant_deadlines where id = '6568f74b-8a4b-40f8-857f-87792a476991';

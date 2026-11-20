-- 2026-11-20: Polk Bros. Foundation portal eligibility quiz returned "not eligible". Re-run safe (guarded by notes marker).
begin;
update fs_grant_deadlines set
  status = 'not_eligible',
  program = 'Open Application - Introduction (re-apply Aug 20, 2027 for Feb 2028 board)',
  deadline_date = '2027-08-20',
  next_step = 'May 15, 2027: file FY2026 Form 990. After June 9, 2027 (one year since IRS determination), retake the eligibility quiz at https://polkbrosfdn.fluxx.io/ (answer 1+ year = Yes, 990 = Yes) to get portal login, then submit the Introduction by Aug 20, 2027, 5 pm CT (confirm date on funder page). Answers drafted for Dec 4 are reusable (update Track Record with real 2026-27 results).',
  next_step_due = '2027-05-15',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Stephen applied anyway at https://polkbrosfdn.fluxx.io/ (Request Access eligibility checklist): 501(c)(3) = Yes, serves Chicago = Yes, in operation 1+ year = No. Portal replied immediately: "your answers to the eligibility questions indicate you are not eligible to apply for funding" (lois/1480516). Dec 4, 2026 Introduction is closed to us. Not a final no: gaps are (1) under one year (determination effective June 9, 2026), (2) no Form 990 yet (first due May 15, 2027), (3) no full prior-year itemized revenue/expenses. Other angles: phone 312-527-4684 to ask about early Introduction or to be kept on file; reuse drafted answers (Core Work, Track Record, Population, Approaches) for the Aug 2027 round. Intro deadline reminder email Message-ID <010001a1f90b0386-838495e6-3463-487d-a7c9-0189c6c3c5fe-000000@email.amazonses.com> (hello@selassiefest.com, Nov 20, 2026).'
where id = 'bbb1ebb4-e6e7-4f57-ae42-993b0a276358'
  and coalesce(notes,'') not like '%[2026-11-20] Stephen applied anyway%';
select id, status, program, deadline_date, next_step_due, left(next_step,80) ns, (notes like '%[2026-11-20] Stephen applied anyway%') logged
from fs_grant_deadlines where id = 'bbb1ebb4-e6e7-4f57-ae42-993b0a276358';
commit;

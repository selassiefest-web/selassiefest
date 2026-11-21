-- Nov 21, 2026: Peoples Gas Community Fund moves to drafting. Answers: Claude outputs\grants\peoples-gas\peoples-gas-answers.md. Portal fields NOT yet seen. Guarded; safe to re-run.
-- Reviewed by partner-grant-data-quality-reviewer ($1,000 = typical award; Park District wording corrected).
begin;
update fs_grant_deadlines set
 updated_at = now(),
 status = 'drafting',
 amount_requested = 1000,
 owner = 'Stephen',
 project = 'djclass',
 next_step = 'Stephen: create Blackbaud/YourCause account at https://bbgm-apply.yourcausegrants.com/apply/programs/883d062e-6e31-4afc-b5a6-f7bd5ffdc7b8 (Claude cannot). Then see which form fields and open date exist (not seen yet; sits behind sign-in). Paste answers from Claude outputs\grants\peoples-gas\peoples-gas-answers.md, check character limits, file the first day the form is open; Jan 31 2027 is a Sunday, so never later than Fri Jan 29. Confirm Rainbow Beach / South Shore is in the service area.',
 next_step_due = '2026-11-23',
 notes = notes || ' | 2026-11-21 [peoples-gas-drafting] status to_research -> drafting; amount_requested null -> 1000 (2 instructors x $250 x 2 Tuesdays; typical award is $1,000 or less); owner null -> Stephen; next_step_due 2026-12-10 -> 2026-11-23; prior next_step: INTERNAL research date Dec 10 (open funder page, confirm eligibility). Portal fields not yet seen.'
where id = 'b7d59a35-383e-49b9-bdea-f7a75ce9542f'
 and status = 'to_research' and amount_requested is null and owner is null
 and notes not like '%[peoples-gas-drafting]%';
commit;
select id, status, amount_requested, owner, project, next_step_due::text, left(next_step,60) ns, (notes like '%[peoples-gas-drafting]%') marked from fs_grant_deadlines where id = 'b7d59a35-383e-49b9-bdea-f7a75ce9542f';

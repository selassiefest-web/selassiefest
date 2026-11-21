-- Nov 21, 2026: Stephen submitted the Levitate Foundation Community Grant form (Jotform "Thank You" page seen in Chrome). Guarded; safe to re-run.
begin;
update fs_grant_deadlines set
 status='submitted', submitted_on='2026-11-21', decision_on='2027-01-29', next_step_due='2027-01-29', updated_at=now(),
 next_step='SUBMITTED Nov 21, 2026 via Jotform (thank-you page confirmed; no confirmation email seen yet, check stephen@selassiefest.com). Ask $10,000 (2 instructors x $250 x 20 of 39 Tuesdays). Levitate says status update within 4 weeks after the Jan 1, 2027 deadline: expect about Jan 29, 2027. No nudge before then.',
 notes = coalesce(notes,'') || E'\n2026-11-21 [levitate-submitted-2026-11-21] SUBMITTED by Stephen via https://form.jotform.com/262735554942162 (Thank You page: "We will be in touch shortly with the status of your request"). IRS letter attached; online materials list website, DJ Lab page and four social links. No confirmation email verified yet.'
where id='6568f74b-8a4b-40f8-857f-87792a476991' and status='ready' and coalesce(notes,'') not like '%levitate-submitted-2026-11-21%';
commit;
select status, submitted_on::text, decision_on::text, next_step_due::text, (notes like '%levitate-submitted-2026-11-21%') marked from fs_grant_deadlines where id='6568f74b-8a4b-40f8-857f-87792a476991';

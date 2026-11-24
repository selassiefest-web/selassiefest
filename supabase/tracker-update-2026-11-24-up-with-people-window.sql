-- Up with People Foundation: eligible, spring window opens Jan 1, 2027 (closes Mar 31, decision by May 31). Ask $9,750 (one resident instructor, 39 Tuesdays x $250). Source: upwithpeople.org/apply, checked Nov 24, 2026. Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', opens_date='2027-01-01', deadline_date='2027-03-31',
  amount_requested=9750, next_step_due='2027-01-01',
  next_step='File Jan 1, 2027 (spring window opens; closes Mar 31, decision by May 31) at https://upwithpeople.org/grant-application. Ask $9,750 (one resident instructor, 39 Tuesdays x $250); tiers $5,000 / $3,600 / $210. Needs IRS letter, a recent profit and loss statement and a project budget PDF. Form cannot save progress. Draft: Claude outputs\up-with-people\up-with-people-answers.md.',
  notes=case when coalesce(notes,'') like '%2026-11-24: eligible, window opens Jan 1 (Up with People)%' then notes else coalesce(notes,'')||E'\n2026-11-24: eligible, window opens Jan 1 (Up with People): orgs up to $10,000; not funded: expenses already incurred, politics, religion, general operating or ongoing costs. Spring Jan 1-Mar 31 (decision by May 31); Fall Jul 1-Sep 30 (decision by Nov 30).' end
where id='cd88b385-b5b2-4881-b18e-f368e063a60d';
select funder,status,amount_requested,opens_date,next_step_due from fs_grant_deadlines where id='cd88b385-b5b2-4881-b18e-f368e063a60d';
commit;

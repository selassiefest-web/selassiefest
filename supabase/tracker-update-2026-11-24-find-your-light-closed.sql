-- Find Your Light Foundation: 2027 cycle closed Oct 30, 2026; calls annual in the fall; Sep 1, 2027 is an ESTIMATE, not a deadline. Strong mission fit (K-12 arts incl. music, tuition-free, first grants $2,500-$5,000). Source: fylf.org/apply-for-grants, checked Nov 24, 2026. Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', next_step_due='2027-09-01',
  next_step='2027 cycle CLOSED Oct 30, 2026. Calls are annual in the fall (Sep 1, 2027 is an estimate, not a funder deadline). Check https://fylf.org/apply-for-grants/ for the fall 2027 call and file the first day it opens: instructor pay tier within $2,500-$5,000 (for example 10 sessions x 2 x $250 = $5,000) plus 14 take-home drives at $15. Contacts on their page: grants@fylf.org, info@fylf.org.',
  notes=case when coalesce(notes,'') like '%2026-11-24: cycle closed (Find Your Light)%' then notes else coalesce(notes,'')||E'\n2026-11-24: cycle closed (Find Your Light). Funds K-12 arts education incl. music, tuition-free or subsidized, professional teaching artists, US only; first grants $2,500-$5,000; about 40% funded in 2025; 3-4 month review. 501(c)(3) or fiscal agent; no nonprofit age rule stated.' end
where id='b9398f4c-0b2e-4b2f-a7c6-b6ddc20370b7';
select funder,status,next_step_due from fs_grant_deadlines where id='b9398f4c-0b2e-4b2f-a7c6-b6ddc20370b7';
commit;

-- Chicago Fund for Safe & Peaceful Communities (United Way of Metro Chicago / Partnership for Safe and Peaceful Communities): 2027 round not announced; 2026 RFP released Feb 2, deadline Mar 2. Source: safeandpeacefulchi.com + 2026 RFP, checked Nov 24, 2026. Status left as is. Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', next_step_due='2027-02-01',
  eligibility='501(c)(3) or fiscal sponsor, budget no more than $500,000, programming in 24 priority communities (South Shore listed), Seven Field Principles model; $1,000-$10,000; 1-day events $3,500 max; multi-week $5,000-$10,000; personnel no more than 10%; activities end Oct 31',
  next_step='Recheck https://www.safeandpeacefulchi.com/ for the 2027 RFP on Mon Feb 1, 2027 (2026 RFP came out Feb 2, deadline Mar 2). If a deadline is set, file the first day the portal opens (https://agency.e-cimpact.com/login.aspx?org=15085). Ask only non-personnel lines (personnel cap 10%); confirm the fieldhouse is in South Shore.',
  notes=case when coalesce(notes,'') like '%2026-11-24: 2027 round not announced (Chicago Fund)%' then notes else coalesce(notes,'')||E'\n2026-11-24: 2027 round not announced (Chicago Fund). Partial fit: summer/early-fall season (activities done by Oct 31) and 10% personnel cap; org budget limit $500,000 fits.' end
where id='69e99742-64e5-4fa3-99b8-0fc1d2cb1400';
select funder,status,next_step_due from fs_grant_deadlines where id='69e99742-64e5-4fa3-99b8-0fc1d2cb1400';
commit;

-- SGA Youth & Family Services / Chicago DFSS "My CHI. My Future." Micro-Grants: 2027 round not announced (https://www.sga-youth.org/microgrants checked Nov 24, 2026; 2026 round closed June 2). Amount left unchanged until Stephen approves a re-cut. Safe to re-run.
begin;
update fs_grant_deadlines set next_step_due='2027-01-04',
  next_step='2027 round NOT announced (page checked Nov 24, 2026); no reply to the Oct 31 question. Watch https://www.sga-youth.org/microgrants (2026 round opened May 12, so watch from April 2027) and file the first day it opens at https://sga-youth.submittable.com/submit. Draft answers: Claude outputs\sga-dfss\answers.md. DECISION NEEDED: ask $17,000 (17 Tuesdays x $1,000) or snacks only $5,100; the $10,905 figure does not match program rates.',
  notes=case when coalesce(notes,'') like '%2026-11-24: 2027 round not open (SGA)%' then notes else coalesce(notes,'')||E'\n2026-11-24: 2027 round not open (SGA). Eligibility: youth 6-24, $5,000-$20,000, 501(c)(3) or fiscal sponsor, UEI, reimbursement only. $10,905 not supported by program lines; only snacks ($20 x 15 x 17 = $5,100) matches.' end
where id='5c2eee2e-7230-49e0-951b-b5dc3c49fcec';
select funder,status,amount_requested,next_step_due from fs_grant_deadlines where id='5c2eee2e-7230-49e0-951b-b5dc3c49fcec';
commit;

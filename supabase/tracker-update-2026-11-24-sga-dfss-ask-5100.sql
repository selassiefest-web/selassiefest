-- SGA / Chicago DFSS micro-grant: Stephen decided Nov 24, 2026 to ask $5,100, snacks only ($20 x 15 kids x 17 Tuesdays). Safe to re-run.
begin;
update fs_grant_deadlines set amount_requested=5100,
  next_step='2027 round NOT announced (page checked Nov 24, 2026); no reply to the Oct 31 question. Ask DECIDED by Stephen: $5,100, snacks only ($20 x 15 kids x 17 Tuesdays). Watch https://www.sga-youth.org/microgrants (2026 round opened May 12, so watch from April 2027) and file the first day it opens at https://sga-youth.submittable.com/submit. Draft answers: Claude outputs\sga-dfss\answers.md (re-cut to the snacks-only ask before filing).',
  notes=case when coalesce(notes,'') like '%2026-11-24: Stephen decided $5,100%' then notes else coalesce(notes,'')||E'\n2026-11-24: Stephen decided $5,100 snacks only for SGA/DFSS (17 Tuesdays x 15 kids x $20).' end
where id='5c2eee2e-7230-49e0-951b-b5dc3c49fcec';
select amount_requested,next_step_due from fs_grant_deadlines where id='5c2eee2e-7230-49e0-951b-b5dc3c49fcec';
commit;

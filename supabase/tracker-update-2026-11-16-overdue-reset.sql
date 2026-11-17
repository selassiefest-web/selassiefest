-- Nov 16, 2026: four overdue next steps reset with new dates (nothing was done on them as of Nov 16). Safe to re-run.
begin;

update fs_grant_deadlines set
  next_step = 'OVERDUE, RESET Nov 16. No reply logged since the Nov 1 submission (confirmation promised 5 business days, about Nov 6). Stephen: check https://raisingcanescommunity.com dashboard for the request status. Draft follow-up to community@raisingcanes.com is ready in Claude outputs/overdue-2026-11-16/DRAFTS-NOT-SENT.txt (send only on Stephen''s "send").',
  next_step_due = '2026-11-17',
  notes = coalesce(notes,'') || E'\n2026-11-16: 15 days since submission, no reply; follow-up drafted, dashboard check assigned to Stephen.'
where id = '53fda21e-a4a8-4797-8b73-d5cd54534456';

update fs_grant_deadlines set
  next_step = 'OVERDUE, RESET Nov 16 (the Nov 9 Barlow call was not made). Stephen: call Principal Barlow 773-535-6650 and ask (1) did Powell receive an FY26/FY27 CLGS award (if so ineligible), (2) is Powell still interested; then CPS approved-vendor status is the second blocker (RTI is not approved). Call script and email are in Claude outputs/overdue-2026-11-16/DRAFTS-NOT-SENT.txt. FY28 guidelines Dec 16, 2026; deadline Feb 17, 2027. If Powell is out or the vendor blocker stands, pivot to a non-CPS school.',
  next_step_due = '2026-11-17'
where id = 'd2ecf4c4-d513-48cd-a7ea-888edfb2cf34';

update fs_grant_deadlines set
  next_step = 'OVERDUE, RESET Nov 16. Stephen: sign up for The Muse (IAC weekly newsletter, link in Angelique Grandone''s Nov 6 signature, arts.illinois.gov) with stephen@selassiefest.com. IAC may make RTI eligible for the FY28 Creative Project Grant but is reworking the program; do not draft until guidelines post.',
  next_step_due = '2026-11-17'
where funder ilike 'Illinois Arts Council' and program = 'Creative Projects grant';

update fs_partners set
  next_step = replace(next_step, 'Reply to Jordan Muhammad', 'Reply to Jordan Muhammad (was due Nov 13; HELD for CPD GO, no date until GO)'),
  next_step_due = null
where id = '772038e9-2ede-4575-8f1e-8022274e1581' and next_step not like '%was due Nov 13%';

select funder, program, status, next_step_due from fs_grant_deadlines where id in ('53fda21e-a4a8-4797-8b73-d5cd54534456','d2ecf4c4-d513-48cd-a7ea-888edfb2cf34') or (funder ilike 'Illinois Arts Council' and program = 'Creative Projects grant');
select name, ball_with, next_step_due from fs_partners where id = '772038e9-2ede-4575-8f1e-8022274e1581';
commit;

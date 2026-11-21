-- Old National Bank (Community Sponsorships), application 2026-27849: DECLINED by SmartSimple email Thu Nov 19, 2026 18:20:13 UTC (12:20 pm CT). Safe to re-run: guarded on status and Message-ID fragment.
begin;

update fs_grant_deadlines
set status = 'declined',
    amount_awarded = 0.00,
    decision_on = '2026-11-19',
    next_step_due = null,
    next_step = 'DECLINED Nov 19, 2026 (decision of record) by ONB Grants and Sponsorships via SmartSimple, application 2026-27849. Reason given: more funding requests than ONB can support; no other reason. Nothing awarded. Optional, not yet done, no due date: email grantsandsponsorships@oldnational.com to ask whether the separate Foundation grant channel or a later sponsorship cycle fits Rainbow Wednesdays (our idea; the decline email did not invite reapplication). If reapplying, use the standing 300 a night goal.',
    notes = coalesce(notes,'') || E'\n2026-11-19 DECLINED (Thu 12:20 pm CT; 18:20:13 UTC): noreply@smartsimple.com (ONB Grants and Sponsorships) to stephen@selassiefest.com, subject "Application Status Update", Message-ID <010001a1f509a860-a989a9a3-a9ea-4721-99be-7ba2b49952ba-000000@email.amazonses.com>. Declines our request for "Rainbow Wednesdays: Free Summer Music Nights" because they received far more requests than they can financially support; no other reason stated, no invitation to reapply, no Foundation or later-cycle mention. Request was $5,000 (amount_awarded set to 0.00, nothing awarded). FLAG (ours, not ONB''s stated reason): the Nov 1 application said 325 attendees expected; the standing goal is 300 a night. Use 300 in any future ONB or Foundation application.',
    updated_at = now()
where id = 'aa27f165-42c0-48f7-be4a-815da0aec49f'
  and status = 'submitted'
  and notes not like '%010001a1f509a860-a989a9a3%';

commit;

select id, status, amount_awarded, amount_requested, decision_on, next_step_due, level, gates,
       left(next_step,90) as next_step_head,
       (length(notes) - length(replace(notes,'a989a9a3-a9ea',''))) / length('a989a9a3-a9ea') as msgid_count
from fs_grant_deadlines
where id = 'aa27f165-42c0-48f7-be4a-815da0aec49f';

-- Nov 21, 2026: BOB .eml catch-up proposed by partner-records-steward (reviewed before apply).
-- (C) Mayor's office Oct 27 reply (invite for Nov 25); (D) Roland ball_with; (E) PCs for People submitted_on. Levitate decision_on deliberately NOT changed (reviewer: year not stated; Stephen decides).
-- Costco and Levitate confirmation notes were already applied by tracker-update-2026-11-21-costco-submitted-levitate-confirm-oldrepublic-audit.sql.
-- Safe to re-run (guarded).
begin;

-- C. Mayor's office: evidence that the only invite is Wed Nov 25, 11:00-11:30 am CT
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'email',
 'Oct 27, 2026 (12:40 pm CT; 17:40 UTC): Addison Rao (Executive Assistant, Office of the Mayor) replied to Albert: "Great! I just sent over a calendar invite." This answers Albert''s Oct 26, 5:07 pm CT message (Message-ID <CAKSj72jAeasz_ozmrxf0BJejuX8DFrh63BvV15DuEvYyor0phQ@mail.gmail.com>) that chose Wed Nov 25, 11:00-11:30 am (the other offered slot was Nov 19, 3:00-3:30 pm). So Nov 25 is the invited meeting. No evidence of a Nov 19 invite; Addison''s Oct 27 reply answers Albert''s Nov 25 choice, and the earlier Oct 26 activity row saying Stephen accepted Nov 19 is superseded. Message-ID <SJ0PR09MB11418E7A53CFC10D0D1B618F4E0602@SJ0PR09MB11418.namprd09.prod.outlook.com>. Albert forwarded this email to Stephen Nov 21, 10:12 pm CT (Message-ID <CAKSj72iTdR9on89VhMMwvz6nOXdizoY1KQ_hyGbmLh8XSkfeVQ@mail.gmail.com>); Albert''s Oct 26 signature gave the Mayor''s office a retired cell number. Invitation and acceptance only; no commitment.',
 'meeting_set', 'office-of-the-mayor', 'Addison Rao (Office of the Mayor)', '2026-10-27 17:40:36+00'
from fs_partners p where p.id='b0678615-8298-438c-9cbd-8cdf20c73110'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%SJ0PR09MB11418E7A53CFC10D0D1B618F4E0602%');

update fs_partners set
 next_step='CONFIRMED by the Mayor''s office (Addison Rao, Oct 27 email: calendar invite sent): the meeting is Wed Nov 25, 2026, 11:00-11:30 am Central on Microsoft Teams (join link is in the invite email). No evidence of a Nov 19 invite; the earlier Nov 19 acceptance note is superseded. PREP Tue Nov 24, 9:00 am: print the FRESH walk summary (Claude outputs\walk-flyers\mayor-summary.js). Reminders are handled by the calendar sentinel. Optional, only after Stephen says send: one line to Addison giving (872) 255-9333 because Albert''s Oct 26 reply gave a retired cell number.'
where id='b0678615-8298-438c-9cbd-8cdf20c73110' and next_step like 'Teams invite ACCEPTED by Stephen Nov 18.%';

-- D. Roland: we nudged Nov 18; the move is Jared's
update fs_partners set ball_with='them'
where name like 'Roland (Music Education)%' and ball_with='us' and next_step like 'Nudge SENT Nov 18 to Jared Selter%';

-- E. PCs for People: the pricing email was sent Nov 18
update fs_grant_deadlines set submitted_on='2026-11-18'
where id='d80a476f-ce3c-4afa-b686-30065b45266f' and submitted_on is null and status='submitted';

commit;

select 'mayor' k, p.stage||'/'||p.ball_with v, p.next_step_due::text d, (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%SJ0PR09MB11418E7A53CFC10D0D1B618F4E0602%')::text n from fs_partners p where p.id='b0678615-8298-438c-9cbd-8cdf20c73110'
union all select 'roland', ball_with, next_step_due::text, null from fs_partners where name like 'Roland (Music Education)%'
union all select 'pcs', status, submitted_on::text, null from fs_grant_deadlines where id='d80a476f-ce3c-4afa-b686-30065b45266f'
union all select 'levitate', status, decision_on::text, next_step_due::text from fs_grant_deadlines where id='6568f74b-8a4b-40f8-857f-87792a476991';

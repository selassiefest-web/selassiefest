-- 2026-11-18 (evening CT): Stephen accepted both Teams invites (his word in chat; Mayor also shown 'yes' on his Google Calendar screenshot; AlphaTheta: his word only). Reviewed by partner-grant-data-quality-reviewer: PASS on mechanics.
-- Mayor's Office (b0678615-8298-438c-9cbd-8cdf20c73110), AlphaTheta (a2e09e2e-5916-4e5a-b232-2369cfc8b57a).
-- Safe to re-run: next_step updates guard on the stale text; activities dedupe on a marker.
begin;

-- AlphaTheta
update fs_partners set
  ball_with = 'us',
  next_step = 'Teams invite ACCEPTED by Stephen Nov 18. Prepare a one-page agenda by Mon Nov 23: Start From Scratch in Chicago (DJ equipment and curriculum, "play the beat") and an introduction to the AlphaTheta Yokohama team behind Club YOXO for Rainbow Wednesday. Join the Teams meeting Mon Nov 23, 3:30 pm CT (4:30 pm ET); runs simultaneously with the crew meeting; team alerted Nov 17, reminders Nov 20, 22, 23 and calendar sentinel 48h/24h/2h. After the meeting, record which equipment path (A-D) AlphaTheta chooses. Keep the haptics loan (Fujitsu / Kaga FEI) a separate ask.',
  next_step_due = '2026-11-23'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and next_step like 'ACCEPT the Teams invitation for Mon Nov 23%';

insert into fs_partner_activity (id, partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select gen_random_uuid(), 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'note',
  'Nov 18, 2026 (evening CT): Stephen accepted the Teams invitation from Israel Rodriguez for Mon Nov 23, 3:30 pm CT (4:30 pm ET). Source: Stephen in chat; no email evidence. Ball is ours: one-page agenda by Nov 23. [src:invite-accepted-2026-11-18-alphatheta]',
  stage, 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 00:00:00+00'
from fs_partners where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and not exists (select 1 from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like '%[src:invite-accepted-2026-11-18-alphatheta]%');

-- Mayor's Office
update fs_partners set
  ball_with = 'us',
  next_step = 'Teams invite ACCEPTED by Stephen Nov 18. PREP Tue Nov 24, 9:00 am: print the FRESH walk summary (Claude outputs\walk-flyers\mayor-summary.js). MEETING Wed Nov 25, 2026, 11:00-11:30 am Central on Microsoft Teams (organizer Khari Humphries; join link is in the invite email in stephen@selassiefest.com). Reminders 48h/24h/2h are handled by the calendar sentinel.',
  next_step_due = '2026-11-24'
where id = 'b0678615-8298-438c-9cbd-8cdf20c73110'
  and next_step like 'MEETING Wed Nov 25, 2026%Accept the invite.%';

insert into fs_partner_activity (id, partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select gen_random_uuid(), 'b0678615-8298-438c-9cbd-8cdf20c73110', 'note',
  'Nov 18, 2026 (evening CT): Stephen accepted the Teams invitation (organizer Khari Humphries) for Wed Nov 25, 2026, 11:00-11:30 am CT. Evidence: Stephen''s Google Calendar screenshot (Nov 18, 7:06 pm CT) shows this Teams meeting on Wed Nov 25 11:00-11:30 am with organizer khari.humphries@cityofchicago.org and 2 guests both yes. The Oct 26 note about a Thu Nov 19, 3:00 pm slot with Deputy Mayor Humphries is older; Nov 25 is the meeting on the calendar (Nov 19 not shown in the screenshot; Stephen to say if a Nov 19 meeting is still real). Next: fresh walk-summary print Tue Nov 24, 9:00 am. [src:invite-accepted-2026-11-18-mayor]',
  stage, 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 00:00:00+00'
from fs_partners where id = 'b0678615-8298-438c-9cbd-8cdf20c73110'
  and not exists (select 1 from fs_partner_activity where partner_id = 'b0678615-8298-438c-9cbd-8cdf20c73110' and summary like '%[src:invite-accepted-2026-11-18-mayor]%');

commit;

select left(p.id::text,8) id, p.ball_with, p.next_step_due, left(p.next_step,60) next_step,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and a.summary like '%[src:invite-accepted-2026-11-18-%') marker_rows
from fs_partners p where p.id in ('a2e09e2e-5916-4e5a-b232-2369cfc8b57a','b0678615-8298-438c-9cbd-8cdf20c73110');

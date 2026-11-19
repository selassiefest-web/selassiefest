-- tracker-update-2026-11-19-old-republic-online-route.sql
-- Stephen, Thu 2026-11-19: NO snail mail; every contact must use an online route. Supersedes the "MAIL the printed letter" next step
-- written by tracker-update-2026-11-19-old-republic-not-mailed.sql. Web research same day (pages read Nov 19, 2026):
-- oldrepublic.com/contact lists HQ 307 N. Michigan Ave and phone (312) 346-8100, no email or giving form visible in fetched text;
-- oldrepublictitle.com community page and orsurety.com giving page show no outside-grant process; no named giving contact found.
-- Safe to re-run: guarded on the marker in notes.
begin;

update fs_grant_deadlines
set next_step = 'ONLINE ONLY, NO MAIL (Stephen, Nov 19): no published giving email or form found for Old Republic (pages read Nov 19). Use the Contact Us web form at https://oldrepublic.com/contact: ask who handles community giving/philanthropy for Old Republic in Chicago, attach the letter as a PDF (updated letter has two QR codes: plan/budget and pitch deck). If the form has no attachment option, paste the letter text and the two links. Stephen submits. If no route accepts it, mark the row skip. Phone follow-up stays PARKED, not before Dec 7.',
    next_step_due = '2026-11-20',
    notes = coalesce(notes,'') || E'\n2026-11-19 Stephen: we are not sending snail mail; online routes only. The printed letter will NOT be mailed; the plan is the web form at https://oldrepublic.com/contact (no giving email or named contact found). [src:or-online-route-20261119]'
where id = '6a15168d-fb2e-40c6-80c8-9531166570ca'
  and funder = 'Old Republic International'
  and status = 'ready'
  and submitted_on is null
  and coalesce(notes,'') not like '%[src:or-online-route-20261119]%';

update fs_partners
set next_step = 'Online only, no mail: submit the letter (PDF) through the Contact Us web form at https://oldrepublic.com/contact and ask who handles community giving (see grant row 6a15168d). Stephen submits.',
    next_step_due = '2026-11-20'
where id = 'ea55b1a8-0d0e-4847-b6aa-309d69855b59'
  and name = 'Old Republic International'
  and next_step like 'Mail the printed letter%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'ea55b1a8-0d0e-4847-b6aa-309d69855b59','note',
 'Stephen said in chat Thu 2026-11-19: no snail mail; use online routes only. The printed Old Republic letter will not be mailed; plan is the Contact Us web form at https://oldrepublic.com/contact (no giving email found). [source: chat 2026-11-19; marker or-online-route-20261119]',
 null,'stephen@selassiefest.com','Stephen Henry','2026-11-19 12:00:00-06'
where not exists (select 1 from fs_partner_activity where partner_id='ea55b1a8-0d0e-4847-b6aa-309d69855b59' and summary like '%marker or-online-route-20261119%');

commit;

select id, status, next_step_due, left(next_step, 50) as next_step_head,
       (notes like '%[src:or-online-route-20261119]%') as note_logged
from fs_grant_deadlines where id = '6a15168d-fb2e-40c6-80c8-9531166570ca';
select id, stage, ball_with, next_step_due, left(next_step, 50) as next_step_head from fs_partners where id = 'ea55b1a8-0d0e-4847-b6aa-309d69855b59';
select count(*) as activity_logged from fs_partner_activity where partner_id='ea55b1a8-0d0e-4847-b6aa-309d69855b59' and summary like '%marker or-online-route-20261119%';

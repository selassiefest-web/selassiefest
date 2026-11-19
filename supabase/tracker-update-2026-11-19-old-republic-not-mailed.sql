-- tracker-update-2026-11-19-old-republic-not-mailed.sql
-- Stephen, Thu 2026-11-19: printed Nov 1 Old Republic letter was NOT mailed.
-- Safe to re-run: guarded on the marker text in notes / next_step_due.
begin;

update fs_grant_deadlines
set next_step = 'MAIL the printed letter (printed Nov 1; NOT mailed as of Nov 19) as printed, with the 1401 E. 71st St letterhead, to: Old Republic International Corporation, Attn: Corporate Giving, 307 N. Michigan Ave, Chicago IL 60601. Then log the mail date here and set status to submitted with submitted_on = the mail date. No online or email path is confirmed (none published as of Oct 31; current pages not rechecked). Phone follow-up to the main line stays PARKED, not before Dec 7.',
    next_step_due = '2026-11-20',
    notes = coalesce(notes,'') || E'\n2026-11-19 Stephen: the printed Nov 1 letter was NOT mailed (the Nov 6 mail-by date was missed). Proposed: mail it Fri Nov 20 (fallback Mon Nov 23); log the mail date when done. Amount requested unchanged at $1,800; nothing awarded or received. [source: Stephen in chat, 2026-11-19]'
where id = '6a15168d-fb2e-40c6-80c8-9531166570ca'
  and funder = 'Old Republic International'
  and status = 'ready'
  and submitted_on is null
  and notes not like '%2026-11-19 Stephen: the printed Nov 1 letter was NOT mailed%';

-- Companion partner row: replace the stale Nov 13 date and the call-based next step.
update fs_partners
set next_step = 'Mail the printed letter (see grant row 6a15168d) to Attn: Corporate Giving, 307 N. Michigan Ave, Chicago IL 60601; log the mail date. Decision-maker research is online only (no calls).',
    next_step_due = '2026-11-20'
where id = 'ea55b1a8-0d0e-4847-b6aa-309d69855b59'
  and name = 'Old Republic International'
  and next_step_due = '2026-11-13';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'ea55b1a8-0d0e-4847-b6aa-309d69855b59','note',
 'Stephen said in chat Thu 2026-11-19: the printed Nov 1 Old Republic letter (to 307 N. Michigan Ave, Attn: Corporate Giving) was NOT mailed. Grant row 6a15168d; $1,800 requested, nothing awarded or received. [source: chat 2026-11-19; marker or-notmailed-20261119]',
 null,'stephen@selassiefest.com','Stephen Henry','2026-11-19 12:00:00-06'
where not exists (select 1 from fs_partner_activity where partner_id='ea55b1a8-0d0e-4847-b6aa-309d69855b59' and summary like '%marker or-notmailed-20261119%');

commit;

select (select count(*) from fs_partner_activity where partner_id='ea55b1a8-0d0e-4847-b6aa-309d69855b59' and summary like '%marker or-notmailed-20261119%') as activity_logged;
select id, status, amount_requested, amount_awarded, submitted_on, next_step_due, left(next_step, 60) as next_step_head,
       (notes like '%2026-11-19 Stephen: the printed Nov 1 letter was NOT mailed%') as note_logged
from fs_grant_deadlines where id = '6a15168d-fb2e-40c6-80c8-9531166570ca';
select id, stage, ball_with, next_step_due from fs_partners where id = 'ea55b1a8-0d0e-4847-b6aa-309d69855b59';

-- 2026-11-18: Chicago Community Trust follow-up SENT by Stephen's approval ("send"), from stephen@selassiefest.com via rti-outreach,
-- to sponsorships@cct.org, cc stephen@. Resend id 01a1f136-3652-7d68-a60b-f63110628938. New message (the Oct 31 send, id 01a1947a-1904-70ba-a386-8fadd7e5d406, got no reply).
-- Asked: which cycle covers June-Aug 2027 and its dates; one application for a series of nights; typical range. Safe to re-run (guarded).
begin;

update fs_grant_deadlines
set next_step = 'WAIT for sponsorships@cct.org (follow-up sent Nov 18, Resend 01a1f136-3652-7d68-a60b-f63110628938). If no reply by Mon Nov 30, call 312-616-8000 (sponsorships) and ask the three questions. When they name the cycle, submit the GrantCentral answers in the packet 07-chicago-fdn-relationship\02-chicago-community-trust.md.',
    next_step_due = '2026-11-30',
    notes = coalesce(notes,'') || E'\n[2026-11-18] Follow-up SENT to sponsorships@cct.org (cc stephen@), Resend id 01a1f136-3652-7d68-a60b-f63110628938; repeats the Oct 31 three questions (cycle for Jun-Aug 2027, series vs nights, typical range), adds 300 a night goal and phone (872) 255-9333. No reply to the Oct 31 email. Internal follow-up date Nov 30, not a funder deadline.'
where id::text like 'ae12c710%'
  and coalesce(notes,'') not like '%01a1f136-3652-7d68-a60b-f63110628938%';

commit;

select funder, status, next_step_due from fs_grant_deadlines where id::text like 'ae12c710%';

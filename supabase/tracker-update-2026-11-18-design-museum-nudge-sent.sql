-- 2026-11-18: Design Museum of Chicago nudge SENT by Claude at Stephen's "send" (rti-outreach, Resend id 01a1f1b3-b39b-7a9a-a646-cd22e3aa92e7),
-- From stephen@selassiefest.com to grants@designchicago.org, cc stephen@. New message (Oct 28 Message-ID not on file). No partner row exists. Safe to re-run (guarded).
begin;
update fs_grant_deadlines
set next_step='Nudge SENT Nov 18, 2026 (Resend 01a1f1b3-b39b-7a9a-a646-cd22e3aa92e7) asking when 2027 DBC nominations open; we plan to self-nominate for the Driehaus Built Environment Award (up to $25,000). Wait for grants@designchicago.org. Check designchicago.org/grants/designing-a-better-chicago on Mon Jan 11, 2027 and nominate the week it opens (2026 pattern: nominations due Feb 15). Packet: 06-chicago-fdn-open/04-design-museum-of-chicago.md',
    next_step_due='2027-01-11',
    notes=coalesce(notes,'') || E'\n[2026-11-18] Nudge SENT from stephen@ to grants@designchicago.org (Resend 01a1f1b3-b39b-7a9a-a646-cd22e3aa92e7), cc stephen@, new message. Asks when 2027 nominations open.'
where id='b14b1116-d183-4e84-a758-d8dfb23aa975' and coalesce(notes,'') not like '%01a1f1b3-b39b-7a9a-a646-cd22e3aa92e7%';
commit;
select id, funder, status, next_step_due from fs_grant_deadlines where id='b14b1116-d183-4e84-a758-d8dfb23aa975';

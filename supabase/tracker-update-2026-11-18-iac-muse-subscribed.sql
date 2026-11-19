-- 2026-11-18: Illinois Arts Council: Stephen completed the Muse / Organizations newsletter sign-up AND clicked Confirm Subscription (his word in chat, Nov 18).
-- No confirmation or welcome email arrived; Constant Contact may only show a web page. Guarded; safe to re-run.
begin;
update fs_grant_deadlines
set next_step='Muse + Organizations newsletter subscribed (Stephen confirmed Nov 18; no welcome email arrived, so watch for the first Muse issue). Wait for IAC to post FY28 Creative Project Grant guidelines (Angelique Grandone, Nov 6: may be eligible; program being reworked). Do NOT draft until guidelines post. Internal check of arts.illinois.gov and the first Muse issue: Fri Dec 18, 2026. Note: the only IAC application open now is the One State conference scholarship, individuals only, not for the organization.',
    next_step_due='2026-12-18',
    notes=coalesce(notes,'')||E'\n[2026-11-18] Stephen signed up for The Muse (Muse Bi-Weekly Newsletter + Organizations lists) at stephen@selassiefest.com and clicked Confirm Subscription (IAC Constant Contact confirmation email Nov 18, 9:15 pm CST, Message-ID <1142135452382.1101975251935.-1.0.162215JL.3400@synd.ccsend.com>). No welcome email received. Checked arts.illinois.gov Nov 18: no organization grant open (CPG and GOS closed); One State 2027 conference scholarship (up to $1,500, deadline Dec 16, 2026) is individuals only, not for RTI.'
where id='541f5642-1a02-46b8-8a6f-648a5c1f670f' and coalesce(notes,'') not like '%clicked Confirm Subscription%';
commit;
select status, next_step_due, notes like '%clicked Confirm Subscription%' logged from fs_grant_deadlines where id='541f5642-1a02-46b8-8a6f-648a5c1f670f';

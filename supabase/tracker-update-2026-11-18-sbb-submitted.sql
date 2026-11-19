-- 2026-11-18: SBB Research Group Foundation grant application SUBMITTED by Stephen (online Microsoft Form).
-- Evidence: receipt email "SBBRG Foundation Grant Application Recieved", Meghan Dubs (mdubs@sbbrg.com), Thu Nov 19 2026 02:43:34 UTC (Wed Nov 18, 8:43 pm CST),
-- Message-ID <BN0PR04MB81274DA968928608FB6F5BECBE792@BN0PR04MB8127.namprd04.prod.outlook.com>.
-- No SBB partner row exists, so no activity entry. Safe to re-run (guarded).
begin;
update fs_grant_deadlines
set status='submitted', submitted_on='2026-11-18', amount_requested=5000,
    next_step='Wait: rolling review, monthly winners; if selected as a Nominee or Finalist SBB contacts us directly (brief phone/video call, then a 10-minute video presentation). Do NOT reapply: one application per calendar year, and the receipt says no need to reapply. Internal check-in only: Fri Jan 15, 2027. Have the IRS letter, board contact and short bio ready for a nominee call.',
    next_step_due='2027-01-15',
    notes=coalesce(notes,'') || E'\n[2026-11-18] SUBMITTED online (Microsoft Form on sbbrg.org/grant-application), $5,000 for the first 7 DJ Lab Tuesdays (Jan 12 to Feb 23, 2027: 7 x ($500 instructors + $200 guest) = $4,900 + $100 snacks). Form answers: founded 6/8/2026; budget $75,123 (2027 cash plan); raised last year $0; 0 full-time employees (preference is 5-49, not a bar); fundraising goals much higher. Receipt 02:43 UTC Nov 19, Message-ID <BN0PR04MB81274DA968928608FB6F5BECBE792@BN0PR04MB8127.namprd04.prod.outlook.com>: rolling basis, no need to reapply, priority to Chicago and Boston organizations. Not awarded; nothing owed.'
where id='2303e067-68a9-46bd-a9bb-b7fdadeaf812' and status='to_research'
  and coalesce(notes,'') not like '%SUBMITTED online (Microsoft Form on sbbrg.org%';
commit;
select id, funder, status, submitted_on, amount_requested, next_step_due from fs_grant_deadlines where id='2303e067-68a9-46bd-a9bb-b7fdadeaf812';

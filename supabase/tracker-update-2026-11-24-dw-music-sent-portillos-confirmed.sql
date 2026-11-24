-- 1) DW Music Foundation inquiry SENT by Stephen from stephen@selassiefest.com (Outlook), Tue Nov 24 2026 06:46:56 +0000 (12:46 am CT) to michelea@dwmf.org, cc stephen@. Ask: 13 DJ controllers $22,477 (tiers 6/3/1). No partner row.
-- 2) Portillo's auto-confirmation received Nov 24 2026 06:27:24 +0000 from fundraisers@portillos.com ("Thanks for Your Request"): request received, sent to the team for review, may not be able to fulfill every one. Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-24', amount_requested=22477, verified=true, verified_on='2026-11-24',
  eligibility='Unknown; temporary pause since Jan 1, 2026 unconfirmed (dwmf.org home page)', next_step_due='2026-12-08',
  next_step='Inquiry emailed Nov 24, 2026 (12:46 am CT) to michelea@dwmf.org: 13 DJ controllers $22,477 (tiers 6 / 3 / 1), asks whether the Jan 1, 2026 pause still applies and whether controllers count as instruments. Awaiting reply; one email nudge Dec 8, then close. If paused, close and note the reopening date she gives.',
  notes=case when coalesce(notes,'') like '%CO6P220MB03381FBE0AE4F402439DC0A0D7442%' then notes else coalesce(notes,'')||E'\n2026-11-24: Stephen sent the inquiry from stephen@selassiefest.com to michelea@dwmf.org (cc stephen@), 12:46 am CT. Message-ID <CO6P220MB03381FBE0AE4F402439DC0A0D7442@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. dwmf.org home page: temporary pause from Jan 1, 2026, updates promised summer 2026, none found.' end
where id='fd13c269-be4d-4b67-9cb7-16f36d2f375b';
update fs_grant_deadlines set
  notes=case when coalesce(notes,'') like '%2026-11-24: Portillo%auto-confirmation%' then notes else coalesce(notes,'')||E'\n2026-11-24: Portillo''s auto-confirmation received 06:27 UTC from fundraisers@portillos.com ("Thanks for Your Request"): request received and sent to the team for review; not every request can be fulfilled. Message-ID <D_8fU000000000000000000000000000000000000000000000TOZTXO0038XaVE74TdKf1Px1fT4Gkg@sfdc.net>. No approval yet.' end
where id='fc1eb971-3254-4fb5-b4e5-5a9b1766fd90';
select funder,status,amount_requested,next_step_due from fs_grant_deadlines where id in ('fd13c269-be4d-4b67-9cb7-16f36d2f375b','fc1eb971-3254-4fb5-b4e5-5a9b1766fd90');
commit;

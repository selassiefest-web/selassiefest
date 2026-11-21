-- 2026-11-20: Benevity Causes Portal + Deed (Bonterra) evidence check. PROPOSED, NOT APPLIED. Re-run safe.
-- Finding: no live evidence that the Declaration, the Chase meeting (Nov 5) outcome, the Donation Method, or the Deed/Spark Good Active check was done.
-- Dates below are re-dated, not marked done. Stephen's word in chat beats this file: if he says a step is done, edit the text before applying.
begin;

-- 1. Benevity partner row (expected current due 2026-11-05)
update fs_partners set
  next_step_due = '2026-11-23',
  next_step = $t$Stephen, online only, one sitting Mon Nov 23, 2026: (1) Declaration https://app.causes.benevity.org/attestations/840-423036705 (any time; nothing in the tracker shows it done). (2) Tell us the outcome of the Thu Nov 5 Chase meeting (account verification letter + EFT routing number: got it or not). If yes: Donation Method (EFT) at https://causes.benevity.org/causesapp/payouts/add/840-423036705 using the fill sheet (no save-draft; Stephen enters account and routing numbers). If no letter: ask the Chase banker for it by email/secure message, no branch visit. (3) Change the Benevity two-factor phone first (old SMS number is retired). (4) Then Account Completion to 100% and add a logo.$t$,
  notes = coalesce(notes,'') || E'\n[2026-11-20 evidence check] No Message-ID, activity, email or file shows the Declaration, the Nov 5 Chase meeting result, or the Donation Method as done; due date of Nov 5 had passed with nothing logged. Re-dated to Nov 23. Benevity payout stays "check" until the Donation Method is submitted. No funder deadline; nothing expires, but no EFT payout can arrive until it is set.'
where id = '3fe397bb-f5be-42a3-abc0-3df30b2b862a'
  and next_step_due = '2026-11-05'
  and coalesce(notes,'') not like '%[2026-11-20 evidence check]%';

-- 2. Benevity grant row (same step, expected current due 2026-11-05)
update fs_grant_deadlines set
  next_step_due = '2026-11-23',
  notes = coalesce(notes,'') || E'\n[2026-11-20 evidence check] Declaration, Chase letter outcome and Donation Method still unevidenced; re-dated Nov 5 to Nov 23 (Stephen). Status stays awarded (registration approved Nov 1).'
where id = '82577fd2-f0f2-4187-b5b4-2b5d95e7baec'
  and next_step_due = '2026-11-05'
  and coalesce(notes,'') not like '%[2026-11-20 evidence check]%';

-- 3. Deed partner row (expected current due 2026-11-10)
update fs_partners set
  next_step_due = '2026-11-24',
  next_step = $t$Stephen, online only, by Tue Nov 24, 2026 (the Nov 10 Bonterra move has passed; nothing logged that it was checked): go to admin.joindeed.org/login, click "Log in" (never "Sign up"), Next, password (same email and password; reset link is on the Bonterra screen). Then sign in at walmart.org Spark Good and confirm the account shows Active for Cycle 3 application 92610828 (Facility #5965). Report back; if Spark Good is not Active, email nonprofits@joindeed.com.$t$,
  notes = coalesce(notes,'') || E'\n[2026-11-20 evidence check] No evidence the Bonterra login or Spark Good Active status was confirmed. Walmart application 92610828 was submitted Oct 31, so the check does not block the application; it matters before a decision (payment setup is due within 21 days of notice).'
where id = '8b57e817-5cca-4a62-a4c6-ab03ab25b4c0'
  and next_step_due = '2026-11-10'
  and coalesce(notes,'') not like '%[2026-11-20 evidence check]%';

-- 4. Walmart Spark Good partner row is stale (says create account and apply; application already submitted Oct 31)
update fs_partners set
  stage = 'reached_out',
  next_step_due = '2026-11-30',
  next_step = $t$Application 92610828 (Facility #5965, $5,000) submitted Oct 31, 2026. Nov 30: check Spark Good dashboard (Walmart asks to wait about a month; decisions come before the next cycle opens Feb 1, 2027). If funded, banking must be entered within 21 days of notice. See grant row ebb1afe5.$t$,
  notes = coalesce(notes,'') || E'\n[2026-11-20 evidence check] Step text replaced: account, Deed verification and application were done (grant row ebb1afe5, submitted Oct 31). walmart.org page read Nov 20 says the last day to submit FY27 Cycle 3 is Nov 30 in one sentence and lists Cycle 3 as Aug 1 to Dec 31 in another; our application is already in, so no risk.'
where id = '1b569e6e-d368-4f78-9cc2-915a532a31b9'
  and stage = 'not_contacted'
  and coalesce(notes,'') not like '%[2026-11-20 evidence check]%';

-- 5. One activity note per partner, keyed by marker
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '3fe397bb-f5be-42a3-abc0-3df30b2b862a', 'note',
 '2026-11-20 evidence check: no record in Supabase, BOB or the repo that the Benevity Declaration, the Nov 5 Chase meeting outcome or the Donation Method was completed. Steps stay open with Stephen; re-dated to Nov 23.',
 'confirmed', 'stephen@selassiefest.com', 'Claude (evidence check)'
where not exists (select 1 from fs_partner_activity where partner_id='3fe397bb-f5be-42a3-abc0-3df30b2b862a' and summary like '2026-11-20 evidence check%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '8b57e817-5cca-4a62-a4c6-ab03ab25b4c0', 'note',
 '2026-11-20 evidence check: no record that the Nov 10 Bonterra login or Spark Good Active status for Walmart application 92610828 was confirmed. Re-dated to Nov 24 (Stephen).',
 'confirmed', 'stephen@selassiefest.com', 'Claude (evidence check)'
where not exists (select 1 from fs_partner_activity where partner_id='8b57e817-5cca-4a62-a4c6-ab03ab25b4c0' and summary like '2026-11-20 evidence check%');

commit;

select id, name, stage, ball_with, next_step_due, left(next_step,80) ns from fs_partners where id in ('3fe397bb-f5be-42a3-abc0-3df30b2b862a','8b57e817-5cca-4a62-a4c6-ab03ab25b4c0','1b569e6e-d368-4f78-9cc2-915a532a31b9');
select id, funder, status, next_step_due from fs_grant_deadlines where id = '82577fd2-f0f2-4187-b5b4-2b5d95e7baec';
select partner_id, kind, left(summary,60) from fs_partner_activity where summary like '2026-11-20 evidence check%';

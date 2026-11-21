-- Nov 21, 2026: ALDI decline follow-up. Reapply first day the window may open. Safe to re-run (guarded).
begin;

update fs_grant_deadlines set
  status = 'declined',
  amount_awarded = 0,
  next_step = 'Mon Mar 1, 2027: check https://corporate.aldi.us/corporate-sustainability/community/aldi-community-gift-card-program and, if the 2027 window is open (2026 ran Mar 1 to Oct 31; the 2027 dates are INFERRED, not published), reapply that same day via YourCause GrantsConnect with the same ask: $1,000 as 10 x $100 gift cards for Rainbow DJ Lab snack Tuesdays. Optional, no date: (a) GrantsConnect > View communications for app 2847516 for a reason; (b) one question to grantsconnect-support@yourcause.com about resubmission; (c) after the CPD hold lifts, ask food-depository/school partners for program advice or an ALDI referral (not a way around YourCause).',
  next_step_due = '2027-03-01',
  notes = coalesce(notes,'') || E'\n2026-11-21 REVIEW: ALDI publishes the 2026 window as Mar 1 to Oct 31, 2026; no 2027 window is posted, so Mar 1, 2027 is inferred. ALDI FAQ (corporate.aldi.us/corporate-sustainability/community/aldi-community-support-programs): applications only through the YourCause site (mailed ones not considered); copies to ALDI staff are not needed; allow 4-6 weeks for review; Impact Grants are invitation-only. Local-store and Batavia routes dropped because ALDI publishes none (narrows the Nov 15 step 3). Status stays declined, amount_awarded 0. No new commitment: same $1,000 / 10 x $100 ask.',
  updated_at = now()
where id = '97a26ab7-1c5e-49ab-bcc4-25233f8a7b3f'
  and status = 'declined'
  and next_step_due = '2026-11-18'
  and coalesce(notes,'') not like '%2026-11-21 REVIEW%';

commit;

select status, amount_awarded, decision_on, next_step_due, left(next_step,60) as next_step_start,
       (notes like '%2026-11-21 REVIEW%') as review_logged,
       (length(notes) - length(replace(notes,'2026-11-21 REVIEW','')))/17 as review_count
from fs_grant_deadlines where id = '97a26ab7-1c5e-49ab-bcc4-25233f8a7b3f';

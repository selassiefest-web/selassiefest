-- 2026-11-18: Stephen says the Roots & Shoots $250 work is COMPLETE for today (chat, Nov 18 evening): award handled and the lawn-plan email sent to Ivry Ector.
-- The tracker still said "ACCEPT THE AWARD" (stale). Replace with what is actually left. Safe to re-run (guarded on the stale text).
begin;

update fs_grant_deadlines
set next_step = 'WAIT: (1) Ivry Ector''s "Send my plan" email (lawn-plan page sent Nov 18); log it on the Chicago Park District (Ivry Ector) partner row, then buy art materials with the Tremendous gift card (all $250, project items only). (2) Watch for the Tremendous gift-card email; if no access to funds by Dec 1, write Alex Biswas, abiswas@janegoodall.org. (3) Progress report due Dec 30, 2026; keep the rootsandshoots.org project profile updated.',
    next_step_due = '2026-12-01',
    notes = coalesce(notes,'') || E'\n[2026-11-18] Stephen confirmed in chat that the acceptance and the Ivry lawn-plan work were completed today; the earlier "ACCEPT THE AWARD" next step was stale and is replaced. Remaining: Ivry''s choice, gift card, Dec 1 funds check, Dec 30 report.'
where id::text like '38c4ff8b%'
  and coalesce(next_step,'') like 'ACCEPT THE AWARD%';

commit;

select funder, status, amount_awarded, next_step_due from fs_grant_deadlines where id::text like '38c4ff8b%';

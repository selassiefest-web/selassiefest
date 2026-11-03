-- Tracker update, Nov 2, 2026: Rainbow Cone one-pager sent to Staci Ybarra (Resend id 01a19dd1-8d85-7eeb-bedd-bb37a34e62ba).
-- Apply with: supabase db query --linked -f supabase/tracker-update-2026-11-02-rainbow-cone.sql
-- Safe to re-run.
update fs_grant_deadlines set
  next_step = 'SENT Nov 2, 2026 (reply in Staci Ybarra''s thread, cc stephen@): one-pager answering her 4 questions (Part 1 donation/discount about 1,200 servings across 53 dates; Part 2 a Rainbow Cone stand at Rainbow Wednesdays, we buy) + deck https://selassiefest.com/full-spectrum/rainbow-cone/. WAIT for Staci''s reply; if none by Mon Nov 9, one short nudge.',
  next_step_due = date '2026-11-09', updated_at = now()
where funder = 'The Original Rainbow Cone';

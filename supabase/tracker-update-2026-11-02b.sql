-- Candid Bronze Seal earned Nov 2, 2026 (profile published). Delta is next.
-- Apply with: supabase db query --linked -f supabase/tracker-update-2026-11-02b.sql
update fs_grant_deadlines set
  next_step = 'CANDID BRONZE SEAL EARNED Nov 2, 2026 (profile 16663871 published). NEXT: finish and submit the Delta Air Lines application. If submitting after Nov 11, move the first date past Feb 9, 2027 to keep 90 days.',
  next_step_due = date '2026-11-04', updated_at = now()
where id = '7d0f78f9-4739-4bb0-a6ab-3086b7028d9f';

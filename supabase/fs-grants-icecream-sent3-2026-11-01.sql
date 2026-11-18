-- RETIRED 2026-11-18. This one-time script was already applied and must NEVER be re-run.
-- It was not safe to repeat: it overwrote or re-labelled every Jeni's Splendid Ice Creams row (the declined request a8b28c45-6e95-4bde-977a-19731a044f5b and the separate Ice Cream Social row), destroying decision evidence.
-- The guard below aborts the whole file before any statement runs. Jeni's rows are now managed only by supabase/tracker-update-2026-11-18-jenis-submitted-and-social-row.sql.
-- Kept for the historical record of what was applied on the day.
do $$ begin raise exception 'RETIRED script (already applied; re-running would overwrite Jeni''s rows and other tracker data). Do not re-run.'; end $$;

update fs_grant_deadlines set status='submitted', next_step='Emailed fundraising@jenis.com 11/1; then submit their donation application with a fixed 2027 date', next_step_due='2026-11-15', notes = notes || ' EMAILED 11/1/2026 from stephen@.' where funder='Jeni''s Splendid Ice Creams' and notes not like '%EMAILED 11/1%';

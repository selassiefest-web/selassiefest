-- RETIRED 2026-11-18. This one-time script was already applied and must NEVER be re-run.
-- It was not safe to repeat: it overwrote or re-labelled every Jeni's Splendid Ice Creams row (the declined request a8b28c45-6e95-4bde-977a-19731a044f5b and the separate Ice Cream Social row), destroying decision evidence.
-- The guard below aborts the whole file before any statement runs. Jeni's rows are now managed only by supabase/tracker-update-2026-11-18-jenis-submitted-and-social-row.sql.
-- Kept for the historical record of what was applied on the day.
do $$ begin raise exception 'RETIRED script (already applied; re-running would overwrite Jeni''s rows and other tracker data). Do not re-run.'; end $$;

update fs_grant_deadlines set status='submitted', next_step='Email + online application both in (11/1). Jeni''s answers in about 4 weeks; follow up 12/1 if silent', next_step_due='2026-12-01', notes = notes || ' APPLICATION SUBMITTED 11/1/2026 on givinga.formstack.com (in-kind ice cream, 100 cups pilot; event date 1/12/27).' where funder='Jeni''s Splendid Ice Creams' and notes not like '%APPLICATION SUBMITTED%';

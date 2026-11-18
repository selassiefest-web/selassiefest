-- RETIRED 2026-11-18. This one-time script was already applied and must NEVER be re-run.
-- It was not safe to repeat: it overwrote or re-labelled every Jeni's Splendid Ice Creams row (the declined request a8b28c45-6e95-4bde-977a-19731a044f5b and the separate Ice Cream Social row), destroying decision evidence.
-- The guard below aborts the whole file before any statement runs. Jeni's rows are now managed only by supabase/tracker-update-2026-11-18-jenis-submitted-and-social-row.sql.
-- Kept for the historical record of what was applied on the day.
do $$ begin raise exception 'RETIRED script (already applied; re-running would overwrite Jeni''s rows and other tracker data). Do not re-run.'; end $$;

-- Ice cream emails sent Nov 1 2026 (second batch, 9 recipients, cc Stephen). Log: Claude outputs/ice-cream/rest-2026-11-01-sent.json
begin;
update fs_grant_deadlines set status='submitted', next_step='Emailed 11/1; follow up by phone/in person if no reply', next_step_due='2026-11-15',
 notes = notes || ' EMAILED 11/1/2026 from stephen@ (50 servings/week pilot request).'
where funder in ('Jeni''s Splendid Ice Creams','The Original Rainbow Cone','B&B Ice Cream & Candy','Kilwins Hyde Park','Dippin'' Dots Illinois','Homer''s Ice Cream','Tillamook','Vandalay Brands')
  and not (funder='Jeni''s Splendid Ice Creams' and program='Ice cream social sponsorship idea');
update fs_grant_deadlines set status='submitted', next_step='Emailed 11/1 asking for a Chicago truck-operator introduction', next_step_due='2026-11-15',
 notes = notes || ' EMAILED 11/1/2026 from stephen@.'
where funder='Good Humor / Neighborhood Joy (Magnum Ice Cream Co.)';
commit;

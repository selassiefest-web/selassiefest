-- Nov 21, 2026 (Stephen: "we do not qualify"): Peoples Gas Community Fund marked not eligible. Safe to re-run (keyed on id).
begin;
update fs_grant_deadlines set status = 'not_eligible', next_step = 'None. Stephen determined Nov 21, 2026 that Ras Tafari Inc. does not qualify for the Peoples Gas Community Fund. Do not apply; do not create the Blackbaud/YourCause account.', next_step_due = null,
 notes = notes || E'\n[Nov 21, 2026] Stephen: we do not qualify. Row closed as not eligible.'
where id = 'b7d59a35-383e-49b9-bdea-f7a75ce9542f' and status <> 'not_eligible';
commit;
select funder, status, next_step_due from fs_grant_deadlines where id = 'b7d59a35-383e-49b9-bdea-f7a75ce9542f';

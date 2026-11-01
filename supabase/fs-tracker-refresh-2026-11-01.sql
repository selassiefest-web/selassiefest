-- Tracker refresh 2026-11-01: SAM.gov is now ACTIVE, so earlier "needs SAM.gov / UEI" notes are satisfied.
-- Appends one dated line to affected grant and partner notes. Idempotent (skips rows already updated).
-- Apply: supabase db query --linked -f supabase/fs-tracker-refresh-2026-11-01.sql
begin;
update fs_grant_deadlines
set notes = coalesce(notes,'') || E'\n2026-11-01 UPDATE: SAM.gov registration is ACTIVE (UEI WHJ4JGLKX3F5, activated Oct 30, 2026; renew by Oct 30, 2027). Any earlier line above saying SAM or the UEI is still needed is satisfied. State grants (GATA) also need Illinois AG charitable good standing: the AG filing (#2026124768) is due Nov 17, 2026.'
where (funder ilike 'Illinois Arts Council%'
    or funder ilike 'Illinois Department of Commerce%'
    or funder ilike 'National Endowment for the Arts%'
    or funder ilike 'National Endowment for the Humanities%'
    or funder ilike 'SGA Youth%')
  and coalesce(notes,'') !~ '2026-11-01 UPDATE: SAM.gov';

update fs_partners
set notes = coalesce(notes,'') || E'\n2026-11-01 UPDATE: SAM.gov registration is ACTIVE (UEI WHJ4JGLKX3F5, activated Oct 30, 2026). The UEI requirement is satisfied.'
where name ilike 'My CHI. My Future.%'
  and coalesce(notes,'') !~ '2026-11-01 UPDATE: SAM.gov';

select count(*) as grant_rows_updated from fs_grant_deadlines where notes ~ '2026-11-01 UPDATE: SAM.gov';
select count(*) as partner_rows_updated from fs_partners where notes ~ '2026-11-01 UPDATE: SAM.gov';
commit;

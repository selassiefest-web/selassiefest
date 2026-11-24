-- Friends of the Parks (Chicago): no grant program found on fotp.org (checked Nov 24, 2026). A grant-round inquiry names a Park District fieldhouse program, so it is held until CPD gives its GO. Inquiry draft saved locally. Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', next_step_due=null,
  next_step='HOLD until CPD GO. Then email info@fotp.org (verified at https://www.fotp.org/contact) asking whether any small-grant round for children''s programs in parks exists (draft: Claude outputs\friends-of-the-parks\fotp-inquiry-draft-HOLD.md). No grant or seed program found on fotp.org Nov 24, 2026; not a fit for an application. Optionally drop if Stephen says so.',
  notes=case when coalesce(notes,'') like '%2026-11-24: no program found (Friends of the Parks)%' then notes else coalesce(notes,'')||E'\n2026-11-24: no program found (Friends of the Parks). fotp.org lists advocacy work (Park Roots, Park Advisory Councils, internships, DuSable Park), no grant or seed program. Contact info@fotp.org, (312) 857-2757 from /contact. Inquiry held for the CPD GO because it names a park-based program.' end
where id='5d85459f-4226-46a0-8af3-d07cfa3cdffc';
select funder,status,next_step_due from fs_grant_deadlines where id='5d85459f-4226-46a0-8af3-d07cfa3cdffc';
commit;

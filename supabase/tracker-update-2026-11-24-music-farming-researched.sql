-- Music Farming: strong mission fit (music education in a specific local community, up to $20,000, two cycles). Initial eligibility Typeform was private on Nov 24, 2026. Source: musicfarming.org/apply-for-funding. Status left as is. Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', next_step_due='2027-01-02',
  eligibility='Registered 501(c)(3); music education in a specific local community, any age; lasting foundation for music education there; priority to low-income participants or communities with little access; up to $20,000; no org-age or staff rule published',
  next_step='Initial eligibility Typeform (https://juxzjuo9qnh.typeform.com/to/DPGQGkog) was private on Nov 24, 2026. Recheck https://www.musicfarming.org/apply-for-funding Jan 2, 2027 and file the eligibility form the first day it opens (Spring proposals due beginning of Feb 2027, announced May; Fall due Sept). Inquiry email to tim@musicfarming.org drafted: Claude outputs\music-farming.',
  notes=case when coalesce(notes,'') like '%2026-11-24: site read (Music Farming)%' then notes else coalesce(notes,'')||E'\n2026-11-24: site read (Music Farming). Strong fit. Grants up to $20,000, twice a year (Spring due early Feb, announced May; Fall due Sept, announced Nov). Short initial application first, then next steps. Contact tim@musicfarming.org. Eligibility form closed.' end
where id='ed49e5a0-618d-450b-833e-c7ded43e912a';
select funder,status,next_step_due from fs_grant_deadlines where id='ed49e5a0-618d-450b-833e-c7ded43e912a';
commit;

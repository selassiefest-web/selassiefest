-- Consumers Credit Union sponsorship form SUBMITTED Nov 22, 2026 (thank-you page seen). Safe to re-run.
begin;
update fs_grant_deadlines set
  status='submitted', submitted_on='2026-11-22', amount_requested=1200,
  eligibility='Service Center markets only (Lake County, Rockford, Ogle County; 23 branches, none in Chicago). South Shore likely outside; submitted as a long shot.',
  next_step='Watch for a reply from Consumers Credit Union; if silent, check again about Dec 14 (online only).',
  next_step_due='2026-12-14',
  notes = coalesce(notes,'') || E'\n2026-11-22: Sponsorship request form submitted (confirmation thank-you page seen): $1,200 for one Rainbow Wednesday sound night (14 x $1,200 = $16,800 line). Form asks 30 days lead time; no upload field; W-9/IRS letter only if asked.'
where id='3c6a14f9-435b-4a2b-8342-2b181a0381b3'
  and coalesce(notes,'') not like '%2026-11-22: Sponsorship request form submitted%';
commit;
select status, submitted_on, amount_requested, next_step_due from fs_grant_deadlines where id='3c6a14f9-435b-4a2b-8342-2b181a0381b3';

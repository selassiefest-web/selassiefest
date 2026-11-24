-- First Bank Chicago grant request SUBMITTED by Stephen Nov 24, 2026 via https://firstbankhp.kadince.com (confirmation page: "The entry was submitted"). Ask $3,750 (one instructor, 15 sessions x $250; tiers $1,000 / $500). Priority goes to current bank clients; we answered No. Funder says allow 4-6 weeks. Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-24', amount_requested=3750, verified=true, verified_on='2026-11-24',
  next_step_due='2027-01-05',
  next_step='Submitted Nov 24, 2026 via the First Bank Grant Request form: $3,750 for one instructor, 15 sessions x $250 (tiers $1,000 / $500). Allow 4-6 weeks; the Community Outreach Coordinator follows up after the committee decides. Priority goes to current First Bank clients, so odds are low. If silent by Jan 5, 2027, one email to dbryant@firstbankchicago.com (verified on the grant form page).',
  notes=case when coalesce(notes,'') like '%2026-11-24: First Bank grant form submitted%' then notes else coalesce(notes,'')||E'\n2026-11-24: First Bank grant form submitted by Stephen: $3,750; bank client = No; 90% low/moderate income (Stephen); Development Activity = community services for LMI individuals; Impact area Cook; attachments IRS letter and DJ Lab one-page brief; payee Ras Tafari Inc., check to 1401 E. 71st St. Sponsorship form skipped.' end
where id='1e5002c8-5b07-4685-b001-766672f3f25c';
select funder,status,amount_requested,next_step_due from fs_grant_deadlines where id='1e5002c8-5b07-4685-b001-766672f3f25c';
commit;

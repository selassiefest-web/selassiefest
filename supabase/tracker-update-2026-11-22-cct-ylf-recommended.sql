-- Nov 22, 2026: CCT Young Leaders Fund "Recommend a Nonprofit" Airtable form submitted (thank-you page seen); sponsorship Nov 30 check changed from a call to an email (online only). Safe to re-run (marker-guarded).
begin;
update fs_grant_deadlines set
 status='submitted', submitted_on='2026-11-22', next_step_due='2027-01-04',
 next_step='RECOMMENDATION FILED Nov 22, 2026 through the Young Leaders Fund "Recommend a Nonprofit" form (https://airtable.com/shrDAGYRuj3Oo3izq); thank-you page shown: "Thank you for your recommendation!" It is a self-recommendation: the Fund is invite-only and recommendations feed its invitation list. Nothing requested, no amount. Watch stephen@selassiefest.com for an invitation from ylf@cct.org (Christine Munteanu or Carrie Goodale). Optional upgrade: ask a Trust member or donor to recommend RTI through the same form. Internal check Mon Jan 4, 2027. Online only.',
 notes = notes || E'\n2026-11-22 [cct-ylf-recommended-20261122] Stephen submitted the Young Leaders Fund grant-partner recommendation form: Ras Tafari Inc. (SelassieFest, Rainbow DJ Lab), https://selassiefest.com/, contact Stephen Henry, President, focus areas Youth Development & Education and Arts & Culture. Fund facts from the form: average award about $5,000; operating budget under $250,000 (RTI 2027 budget $134,670); no previous Trust grant (RTI has none); the 2026-27 cycle began Nov 4. Nothing awarded or received.'
where id='894a7bfd-46c3-4cbe-b3da-8970950815bf' and notes not like '%cct-ylf-recommended-20261122%';

update fs_grant_deadlines set
 next_step = replace(next_step, 'call 312-616-8000 (sponsorships)', 'email sponsorships@cct.org again (no calls; online only)'),
 notes = notes || E'\n2026-11-22 [cct-nov30-email-20261122] Nov 30 check-in is by email to sponsorships@cct.org, not a call (online-only rule). Sponsorship windows listed: Oct 2026, Feb 2027, June 2027, Aug 2027; no dates posted; apply via GrantCentral (Stephen''s login).'
where id='ae12c710-6c22-4acf-8bbe-b3c6389cdd52' and notes not like '%cct-nov30-email-20261122%';
commit;
select (select status||' '||submitted_on::text||' '||next_step_due::text from fs_grant_deadlines where id='894a7bfd-46c3-4cbe-b3da-8970950815bf') ylf,
 (select (next_step like '%312-616-8000%') still_has_phone from fs_grant_deadlines where id='ae12c710-6c22-4acf-8bbe-b3c6389cdd52') phone_left;

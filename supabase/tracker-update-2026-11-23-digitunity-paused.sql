-- Digitunity verified in Chrome Nov 23, 2026: new applications are paused (waitlist contact form only). Safe to re-run.
begin;
update fs_grant_deadlines set
  verified_on='2026-11-23',
  next_step='Digitunity applications are PAUSED as of Nov 23, 2026 (page: "new applications are temporarily paused"; a waitlist contact form only). Optional: submit the waitlist form (needs Stephen OK). Recheck https://digitunity.org/get-involved/receive-equipment/ about Dec 21, 2026 and apply the day it reopens (12 Windows laptops; accept partial fulfillment).',
  next_step_due='2026-12-21',
  notes = coalesce(notes,'') || E'\n2026-11-23: Verified in Chrome: Digitunity applications paused; waitlist contact form only (not used). When reopened: 501(c)(3) proof, then Donation Matching Platform account, then Award of Property Agreement.'
where id='9803c760-88e8-44f7-bfc7-083b197a7323'
  and coalesce(notes,'') not like '%2026-11-23: Verified in Chrome: Digitunity applications paused%';
commit;
select verified_on, next_step_due from fs_grant_deadlines where id='9803c760-88e8-44f7-bfc7-083b197a7323';

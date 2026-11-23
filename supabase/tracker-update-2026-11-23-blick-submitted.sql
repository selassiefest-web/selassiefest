-- Blick Art Materials donation request form SUBMITTED Nov 23, 2026 (Thank You page seen). Safe to re-run.
begin;
update fs_grant_deadlines set
  status='submitted', submitted_on='2026-11-23', verified=true, verified_on='2026-11-23',
  next_step='Waiting on Blick (they answer within about 30 days). If no reply by Dec 23, 2026, email donations@dickblick.com. Narrated deck: https://selassiefest.com/full-spectrum/blick/ ; proposal PDF attached to the form.',
  next_step_due='2026-12-23',
  notes = coalesce(notes,'') || E'\n2026-11-23: Blick online donation request form SUBMITTED (Thank You page seen). Asked: gift certificate toward Rainbow Wednesdays visual-art materials (14 weekly artworks); all six recognitions ticked (Print, Digital, Flyering, Logo Recognition, Discount Coupon On-Site, Social Media Shout out); Roots & Shoots $250 to be spent at Blick. Proposal PDF + narrated deck built for Blick.'
where id='07eaeb9e-90d8-4cbd-a59d-1225d04c2c9d'
  and coalesce(notes,'') not like '%2026-11-23: Blick online donation request form SUBMITTED%';
commit;
select status, submitted_on, next_step_due from fs_grant_deadlines where id='07eaeb9e-90d8-4cbd-a59d-1225d04c2c9d';

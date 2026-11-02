-- Benevity Causes progress Nov 2, 2026; Aerie sign-in state.
update fs_grant_deadlines set
  next_step = 'Nov 2: registration ACTIVE, 2-factor ON, Cause Profile saved (publishes within 24 hours), Self-Certification COMPLETED by Stephen (Nov 2, 2026). LEFT: Declaration (https://app.causes.benevity.org/attestations/840-423036705) and Donation Method (bank payout, Stephen only, https://causes.benevity.org/causesapp/payouts/840-423036705). Then check Account Completion reaches 100% and add a logo. Rule: no naming a Benevity corporate donor publicly without that client''s written consent. Renew the Self-Certification yearly (Nov 2027).',
  next_step_due = date '2026-11-04', updated_at = now()
where id = '82577fd2-f0f2-4187-b5b4-2b5d95e7baec';
update fs_partners set
  next_step = 'Self-Certification done Nov 2, 2026. Next: Declaration and Donation Method (Stephen). See the Benevity grant row.',
  next_step_due = date '2026-11-04', updated_at = now()
where id = '3fe397bb-f5be-42a3-abc0-3df30b2b862a';
update fs_grant_deadlines set
  next_step = 'Eligibility email sent Nov 1. Nov 2: Aerie portal (https://webportalapp.com/sp/login/aerierealfoundation) needs Stephen to sign in (stephen@selassiefest.com; do NOT sign up again). Then Claude fills the Applicant Profile from aerie-real-foundation-answers-2026-11-01.md; Paul must supply projected total expenses and program-services %. Next proposal deadline June 1, 2027.',
  next_step_due = date '2026-11-09', updated_at = now()
where id = 'e0777387-4ac8-4a5a-a619-df83eb279387';

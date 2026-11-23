-- Les Paul Foundation grant application (form REV 8/25) EMAILED Nov 23, 2026 by the main session at Stephen's "send". Safe to re-run.
begin;
update fs_grant_deadlines set
  status='submitted', submitted_on='2026-11-23', verified=true, verified_on='2026-11-23',
  amount_requested=2210,
  amount='$1,500-$2,000 typical first grant; requested $2,210',
  eligibility='US 501(c)(3) public charity; no religious, political, labor or business orgs; must describe how Les Paul''s story will be shared; one request per calendar year; please do not contact the Foundation',
  next_step='Waiting on the Les Paul Foundation: Cycle 1 decision Apr 1, 2027. They ask not to be contacted; do not follow up before Apr 1, 2027. Next cycle Sept 15, 2027 (decision Dec 1).',
  next_step_due='2027-04-01',
  notes = coalesce(notes,'') || E'\n2026-11-23: Application EMAILED to info@lespaulfoundation.org from stephen@selassiefest.com (Resend 01a2073f-9313-7f38-bb69-de37145fb611) with the filled PDF (form REV 8/25) and the IRS determination letter. Ask $2,210 (8 instructor sessions x $250 = $2,000 + 14 take-home USB drives x $15 = $210). Project: Rainbow DJ Lab + Rainbow Wednesdays (track-for-track exchange with a veteran DJ); Les Paul story: Les Paul and Mary Ford recording, Serato layers, Audima Sway filter sweep, student-led sound-on-sound demo at Rainbow Wednesdays. People reached 4,200; board donors 40%; 0 employees, 10 volunteers; revenue $250 to date, expenses $75,123 (2027 budget). Files in Claude outputs\les-paul\ (local).'
where id='7c058a30-e59d-43ff-a877-aff415d8acf6'
  and coalesce(notes,'') not like '%2026-11-23: Application EMAILED to info@lespaulfoundation.org%';
commit;
select status, submitted_on, amount_requested, next_step_due from fs_grant_deadlines where id='7c058a30-e59d-43ff-a877-aff415d8acf6';

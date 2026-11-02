-- Tracker cleanup, Nov 1, 2026 (Stephen: "I keep getting emails about ARCS and the
-- submission is done"). Facts come from legal/documents-inbox/CURRENT-STATUS.md.
-- Apply with: supabase db query --linked -f supabase/tracker-cleanup-2026-11-01.sql
-- Safe to re-run.

-- 1. Night Out in the Parks was SUBMITTED Nov 1 (Submittable 55665702, review stage,
--    answers by early March 2027). The 7 unsent noitp_reminders ("Night Out is open:
--    submit today", "One week left", "closes tonight" ...) only stop once
--    noitp_settings.submitted_at is set; the "mark submitted" email link never was.
update noitp_settings set submitted_at = coalesce(submitted_at, now()) where id = 1;

-- 2. Night Out grant row: it still said drafting/paused with a Dec 8 deadline, which
--    keeps feeding the Sunday grant-deadline email.
update fs_grant_deadlines set
  status = 'submitted',
  submitted_on = date '2026-11-01',
  amount_requested = 25000,
  decision_on = date '2027-03-01',
  next_step = 'SUBMITTED Nov 1, 2026 (Submittable ID 55665702; $25,000 on a $42,450 budget; Rainbow Wednesdays at Rainbow Beach Park). In the Review Stage. CPD notifies accepted proposals by early March 2027. Spring 2027 orientation is mandatory (date TBD). Board consent rti-board-2026-11-01 still needs Stephen, Paul, Marlon and Craig (Albert signed).',
  next_step_due = null,
  updated_at = now()
where id = '38b44632-afbe-433e-8fea-4faf7aa379dc';

-- 3. Partner rows whose next step is already done.
update fs_partners set
  next_step = 'Meeting Wed Nov 25, 2026, 11:00 to 11:30 am Central on Teams (organizer Khari Humphries). Stephen must accept the invite. The ARCS proposal is already filed (sent Oct 27; receipt confirmed Oct 30).',
  next_step_due = date '2026-11-04', updated_at = now()
where id = 'b0678615-8298-438c-9cbd-8cdf20c73110';

update fs_partners set stage = 'committed',
  next_step = 'Acceptance of the 13 free djay Pro licenses SENT Oct 31 (ticket 1ZX9W9-XYRWE). Next: install and assign the licenses when Algoriddim sends them.',
  next_step_due = null, last_contact_at = timestamp '2026-10-31 20:00', updated_at = now()
where id = '0891b777-3154-49cd-b714-450f7876f95f';

update fs_partners set stage = 'reached_out',
  next_step = 'Notify-me email SENT Oct 31 to ImpactCouncil@siragusa.org (see the grant tracker). Wait for their reply.',
  next_step_due = null, last_contact_at = timestamp '2026-10-31 20:00', updated_at = now()
where id = '91fc75dc-2373-4e37-a9cf-130ef88200a6';

update fs_partners set stage = 'reached_out',
  next_step = 'Sponsorship request SENT Oct 31 to sponsorships@adm.com (see the grant tracker). Wait for their reply.',
  next_step_due = null, last_contact_at = timestamp '2026-10-31 20:00', updated_at = now()
where id = '358a7095-4056-4000-a2dc-2aaee2ad494f';

update fs_partners set stage = 'reached_out',
  next_step = 'Email SENT Oct 31 to info@socialworkschi.com (see the grant tracker). Wait for their reply.',
  next_step_due = null, last_contact_at = timestamp '2026-10-31 20:00', updated_at = now()
where id = '272826b0-ea13-4994-9390-75d7015b9141';

update fs_partners set stage = 'reached_out',
  next_step = 'Full email application SENT Oct 31 (see the grant tracker). Wait for LPMC''s reply.',
  next_step_due = null, last_contact_at = timestamp '2026-10-31 20:00', updated_at = now()
where id = 'ff3deba3-0579-486f-964f-de1c07b05d75';

update fs_partners set stage = 'reached_out',
  next_step = '2027 round question SENT Oct 31 to youthmicrogrants@sga-youth.org (see the grant tracker). Wait for the reply.',
  next_step_due = null, last_contact_at = timestamp '2026-10-31 20:00', updated_at = now()
where id = 'ae2963a6-136c-4167-a2af-ae418c84b23e';

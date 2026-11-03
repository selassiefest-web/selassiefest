-- Tracker update, Nov 2, 2026: Clayco + Eames inquiries sent (Resend ids 01a19eca-ec8e-7e03-b0a3-cdc7b17091f3, 01a19ecb-0114-7709-bf0d-086904f2bee8).
-- Apply with: supabase db query --linked -f supabase/tracker-update-2026-11-02-clayco-eames.sql
update fs_grant_deadlines set
  status = 'submitted', submitted_on = date '2026-11-02', updated_at = now(),
  next_step = 'Routing email SENT Nov 2, 2026 to Melissa Mazrim (MazrimM@RealCRG.com): who considers Chicago community orgs, is a Juneteenth Fund round planned for 2027; asked to be considered for $25,000 unrestricted. Wait for reply; one polite nudge Nov 17, 2026. Mid-April 2027 ask again before the June selection. No Rebuild mention.',
  next_step_due = date '2026-11-17'
where id = 'f1a22e77-6f67-4401-81c2-8eb318c207dd';
update fs_grant_deadlines set
  status = 'submitted', submitted_on = date '2026-11-02', updated_at = now(),
  next_step = 'Inquiry SENT Nov 2, 2026 to info@eamesinstitute.org: asked to be considered for $10,000 general support for the Rainbow DJ Lab first year. Wait for reply; one nudge Nov 18, 2026, then skip until there is an introduction. No Rebuild mention.',
  next_step_due = date '2026-11-18'
where id = '926f48bd-5ad6-46fa-89ac-4d5bb59e237f';

-- Delta Air Lines request 106198997 SUBMITTED by Stephen Nov 2, 2026 (IRS determination letter attached).
update fs_grant_deadlines set
  status = 'submitted', submitted_on = date '2026-11-02', decision_on = date '2026-11-30',
  next_step = 'SUBMITTED Nov 2, 2026 (CyberGrants request 106198997, IRS determination letter attached). Delta answers within 4 weeks (about Nov 30). Do NOT call or email Delta about status.',
  next_step_due = null, updated_at = now()
where id = '7d0f78f9-4739-4bb0-a6ab-3086b7028d9f';

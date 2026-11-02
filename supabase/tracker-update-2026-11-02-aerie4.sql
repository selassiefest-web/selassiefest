-- Aerie Real Foundation Community Grant SUBMITTED Nov 2, 2026 by Stephen's go (portal confirmation seen: "This has been submitted").
update fs_grant_deadlines set status = 'submitted', submitted_on = date '2026-11-02', amount_requested = 7800,
  next_step = 'SUBMITTED Nov 2, 2026 via the Aerie portal (stephen@selassiefest.com): "Women at the Decks: the Rainbow DJ Lab Guest Woman DJ Series", $7,800, Jan 12 to Dec 28, 2027. Portal says it is under review and they will contact us if more is needed. Reviews for the June 1, 2027 deadline cycle come by end of June 2027. Program Services % was entered as about 95% planned (Paul to confirm the split if Aerie asks). If selected, the application grants Aerie a license to use our name, logo and submitted materials. Check the portal and stephen@ for questions; no nudge before March 2027.',
  next_step_due = date '2027-03-01', updated_at = now()
where funder ilike '%aerie%';

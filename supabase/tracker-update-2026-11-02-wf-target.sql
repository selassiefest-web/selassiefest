-- Reports from Stephen, Nov 2, 2026: Whole Foods (missed deadline), Target Hyde Park and Target 71st & Cicero (paperwork delivered).
update fs_grant_deadlines set status = 'declined', decision_on = date '2026-11-02',
  next_step = 'Whole Foods Hyde Park store manager said we MISSED their deadline and should try next year (reported Nov 2, 2026). Next: when next in the store, ask the manager for the exact 2027 deadline and the best person to send the packet to; calendar it. Letter and IRS letter/W-9 already printed, reuse next year.',
  next_step_due = null, updated_at = now()
where id = '28e78f9f-a1ef-4c62-a81d-600fe527279b';

update fs_grant_deadlines set status = 'submitted', submitted_on = date '2026-11-02',
  next_step = 'DELIVERED paperwork (request + IRS letter): (1) Target HYDE PARK: they took it; their HR department handles donations; contact person SHERESE, who sounded positive. (2) Target 71st & CICERO: left with a store clerk to forward to their HR department (no named contact yet). Allow up to 30 days. Follow up: call or stop by Hyde Park and ask for Sherese about Mon Nov 16; at 71st & Cicero ask for the store HR/manager name then.',
  next_step_due = date '2026-11-16', updated_at = now()
where id = '1142310f-bfa5-44cd-a948-6f2032ec49e7';

update fs_partners set stage = 'reached_out',
  next_step = 'Paperwork delivered Nov 2: Hyde Park Target (HR took it; contact Sherese, positive) and 71st & Cicero Target (left with a clerk to forward to HR). Follow up about Nov 16. See the Target GiftCards grant row.',
  next_step_due = date '2026-11-16', last_contact_at = timestamp '2026-11-02 18:00', updated_at = now()
where id = '7d576c3f-067d-4157-a334-70e3a8e2d4d1';

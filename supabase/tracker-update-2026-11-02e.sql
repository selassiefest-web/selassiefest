-- Hilton Global Foundation declined Nov 2, 2026; Delta confirmation received Nov 2.
update fs_grant_deadlines set status='declined', decision_on=date '2026-11-02',
  next_step = 'DECLINED Nov 2 by Hilton Global Foundation ("unable to support requests of this nature"). Cause: we asked a nomination-based, cash-grant foundation for in-kind room nights. HGF funds Destination Stewardship, Career Development and Community Resilience, mainly Action Grants to orgs nominated by Hilton Team Members. Do not re-ask HGF for rooms. New route: Chicago Hilton Team Member nomination under Career Development (hospitality and live-events skills), then a property-level room-nights ask. Plan: Claude outputs/grants/applications-2026-10-31/10-travel-hospitality/07-hilton-reframe-2026-11-02.md',
  next_step_due = date '2026-11-16', updated_at = now()
where id = '8df83cd3-7f31-4789-8d2d-114efae29760';
update fs_partners set stage='reached_out',
  next_step = 'HGF declined Nov 2 (in-kind rooms not their model). Next: call a downtown Chicago Hilton for the community-partnerships / Team Member volunteer contact; pitch Career Development and an Action Grant nomination, rooms later. See 07-hilton-reframe-2026-11-02.md.',
  next_step_due = date '2026-11-16', last_contact_at = timestamp '2026-11-02 11:31', updated_at = now()
where id = 'adf13817-6b5b-45c6-a950-cc871d0051b0';
update fs_grant_deadlines set
  next_step = 'SUBMITTED Nov 2, 2026; Delta confirmation email received Nov 2 (CyberGrants request 106198997; answer within 4 weeks, about Nov 30). Do NOT call or email Delta about status.',
  updated_at = now()
where id = '7d0f78f9-4739-4bb0-a6ab-3086b7028d9f';

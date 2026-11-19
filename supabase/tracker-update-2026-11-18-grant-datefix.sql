-- Grant date-fix, decisions by Stephen, Wed 2026-11-18 (America/Chicago).
-- Scope: fs_grant_deadlines only. No partner rows. Status is not changed on any row.
-- Safe to re-run: every update is guarded on id AND the expected current value AND
-- the absence of that row's unique notes marker, so a second run changes 0 rows.
-- Owner column is free text (live values: Stephen, Albert Harris, null); no constraint.
-- Status check (live): to_research, drafting, ready, submitted, awarded, declined, not_eligible, skip.
begin;

-- (1a) Joyce Foundation: owner = Stephen; next_step and due unchanged.
update fs_grant_deadlines set
  owner = 'Stephen',
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-owner] Owner set to Stephen (was empty). Next step and due date (2026-11-20) unchanged.',
  updated_at = now()
where id = 'dc25d586-f390-4553-964a-01fd8090c8e1'
  and funder = 'Joyce Foundation'
  and next_step_due = date '2026-11-20'
  and owner is null
  and coalesce(notes,'') not like '%[datefix-owner]%';

-- (1b) Springboard Foundation: owner = Stephen; next_step and due unchanged.
update fs_grant_deadlines set
  owner = 'Stephen',
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-owner] Owner set to Stephen (was empty). Next step and due date (2026-12-11 guidelines call) unchanged.',
  updated_at = now()
where id = 'df858e07-5613-4d46-8f2d-4bbb63507ff1'
  and funder = 'Springboard Foundation'
  and next_step_due = date '2026-12-11'
  and owner is null
  and coalesce(notes,'') not like '%[datefix-owner]%';

-- (2) NAMM Foundation: owner Paul Kelly, new next step, estimated due 2026-11-25.
update fs_grant_deadlines set
  owner = 'Paul Kelly',
  next_step = 'Paul to decide a CPA financial review of FY2026 or a fiscal sponsor and confirm the 2027 org budget (ask capped at 15% by the Dependency Test). Packet: 01-gear-dj\07-namm-foundation.md',
  next_step_due = date '2026-11-25',
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-namm] Owner Paul Kelly. Prior due 2026-11-16 passed with no decision logged. New due 2026-11-25 is an ESTIMATE, not a funder deadline. NAMM round 1 is due Apr 1, 2027.',
  updated_at = now()
where id = '27809596-c036-4007-8aa1-bc1239138800'
  and funder = 'NAMM Foundation'
  and next_step_due = date '2026-11-16'
  and coalesce(notes,'') not like '%[datefix-namm]%';

-- (3a) Eleven board intro-ask rows (all Amazon-excluded): same next step, due 2026-11-20, owner Stephen.
update fs_grant_deadlines set
  owner = 'Stephen',
  next_step = 'No intro replies logged by Nov 13 (only Douglas Allen answered Nov 1: no contact). One reminder to the board Fri Nov 20, then park.',
  next_step_due = date '2026-11-20',
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-intro] Intro-ask replies were due Nov 13; none logged except Douglas Allen (Nov 1, no contact). One board reminder Fri Nov 20, then park. Status unchanged.',
  updated_at = now()
where next_step_due = date '2026-11-13'
  and coalesce(notes,'') not like '%[datefix-intro]%'
  and (id, funder) in (
    ('31207ffd-3086-46e9-9b3c-6bbc97b5dd99','Candace Parker Foundation'),
    ('4e51335f-e11b-426d-bf10-aa24f0b6f476','Chicago Beyond'),
    ('8ad13eb7-121c-4e0e-b638-a5a86311df5b','Crown Family Philanthropies'),
    ('96209d1e-2adf-4567-ab3e-9ba952d61df1','Derrick Rose (foundation to confirm)'),
    ('a8ecc1a3-2b49-47b8-a6b5-ecd11ecbc5b3','HARMAN / JBL'),
    ('e9c68126-5767-46b2-88f4-032cfd2e671c','Jennifer Hudson (foundation to confirm)'),
    ('182dccc7-b741-4e77-b2b0-9a47e63454ff','JLL'),
    ('2dc71648-cb3a-4977-833b-96932730d292','Oprah Winfrey Charitable Foundation'),
    ('fd59cd64-fe36-4492-974d-3cae50322011','Robert R. McCormick Foundation'),
    ('b64c37dc-82b2-4cd7-9e27-0fab79ae5423','Uber'),
    ('8fc24504-5407-4454-acbe-c1f91ddf1dd9','Wade Family Foundation (Dwyane Wade)')
  );

-- (3b) Amazon: same, plus parking rule.
update fs_grant_deadlines set
  owner = 'Stephen',
  next_step = 'No intro replies logged by Nov 13 (only Douglas Allen answered Nov 1: no contact). One reminder to the board Fri Nov 20, then park. If nobody has an Amazon Chicago community contact, it parks to 2027-03-01.',
  next_step_due = date '2026-11-20',
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-intro] Intro-ask replies were due Nov 13; none logged except Douglas Allen (Nov 1, no contact). One board reminder Fri Nov 20, then park; parks to 2027-03-01 if nobody has a contact. Status unchanged.',
  updated_at = now()
where id = 'd5d14632-e295-4331-a244-39d74dae2b70'
  and funder like 'Amazon%'
  and next_step_due = date '2026-11-13'
  and coalesce(notes,'') not like '%[datefix-intro]%';

-- (4) Reimagining the Civic Commons: notes only. Status, next_step, due untouched.
update fs_grant_deadlines set
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-civic] Chicago is not a current Civic Commons site and the program makes no grants. Consider parking to 2027-03-01 (not changed; status and Nov 11 due date left as is).',
  updated_at = now()
where id = '35c653bc-83a9-4427-9b43-a698d44c4382'
  and funder = 'Reimagining the Civic Commons'
  and coalesce(notes,'') not like '%[datefix-civic]%';

-- (5) CHAUVET DJ.
update fs_grant_deadlines set
  owner = 'Stephen',
  next_step = 'Joyce ask is now sound-only ($16,800), so the booth-swap question is moot; submit the Marketing Support form text for the LED booth ask or park',
  next_step_due = date '2026-11-23',
  notes = coalesce(notes,'') || chr(10) || '[2026-11-18] [datefix-chauvet] Booth-swap decision moot: Joyce ask is sound-only ($16,800). Prior due 2026-11-04. Packet: 02-gear-audio\02-chauvet-dj.md. Overlap with other asks is not a conflict.',
  updated_at = now()
where id = 'ad4a1484-d980-4972-87a3-5712f388acfd'
  and funder = 'CHAUVET DJ'
  and next_step_due = date '2026-11-04'
  and coalesce(notes,'') not like '%[datefix-chauvet]%';

-- Verify: expect 17 rows (Joyce, Springboard, NAMM, 11 intro rows, Amazon, Civic Commons, CHAUVET), all has_note = true.
select left(id::text,8) id8, funder, status, owner, next_step_due, left(next_step,70) next_step,
       (notes like '%[2026-11-18]%') has_note
from fs_grant_deadlines
where notes like '%[datefix-%'
order by next_step_due, funder;

commit;

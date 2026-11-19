-- 2026-11-18 (CT): two .eml files saved by Stephen (Re__... and Fw__... Following_up__Start_From_Scratch_in_Chicago.eml).
-- Re__ = Israel Rodriguez Nov 16 21:23 UTC (3:23 pm CST): ALREADY logged (activity 303315b2, tracker-update-2026-11-16-alphatheta-teams-invite.sql). No new Re activity here.
-- Fw__ = Stephen's forward Nov 16 23:09:56 UTC (5:09 pm CST) to Marlon, Kirk (Prestige Sound), Paul Kelly: "PIONEER meeting date below". NEW activity.
-- Neither email contains evidence that Stephen accepted the Teams invite; this script makes the next_step honest about that.
-- Partner a2e09e2e-5916-4e5a-b232-2369cfc8b57a; grant f575d085-f8ee-4f12-a90d-bcf7e2a4d28e. Safe to re-run (guards on stale text and markers).
begin;

update fs_partners set
  ball_with = 'us',
  next_step = 'Israel Rodriguez SENT a Teams invitation (his Nov 16 email) for Mon Nov 23, 2026, 3:30 pm CT (4:30 pm ET). Stephen says he accepted it Nov 18 (his word; no acceptance email or calendar evidence on file). Prepare a one-page agenda by Mon Nov 23: Start From Scratch in Chicago (DJ equipment and curriculum, "play the beat") and an introduction to the AlphaTheta Yokohama team behind Club YOXO for Rainbow Wednesday. Join the Teams meeting; it runs simultaneously with the crew meeting; crew alerted (Stephen forwarded Israel''s note to Marlon, Kirk and Paul Nov 16, 5:09 pm CT; alert Nov 17), reminders Nov 20, 22, 23 and calendar sentinel 48h/24h/2h. After the meeting, record which equipment path (A-D) AlphaTheta chooses. Keep the haptics loan (Fujitsu / Kaga FEI) a separate ask.',
  next_step_due = '2026-11-23',
  notes = notes || E'\n2026-11-16 23:09 UTC (5:09 pm CT): Stephen forwarded Israel''s "I sent you an invitation for 11/23 at 4:30pm EST" message to Marlon, Kirk (Prestige Sound) and Paul Kelly with the line "PIONEER meeting date below" (internal crew notice; no partner send). Message-ID <CO6P220MB0338118754E59B4B2C03DE19D77C2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. The invite itself (Teams link, organizer, attendees, agenda) is NOT in either .eml. Israel gave only 4:30 pm EST (read as 4:30 pm ET); no equipment paths or haptics were discussed in the emails. [src:fw-2026-11-16-pioneer]'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and next_step like 'Teams invite ACCEPTED by Stephen Nov 18.%'
  and notes not like '%[src:fw-2026-11-16-pioneer]%';

insert into fs_partner_activity (id, partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select gen_random_uuid(), 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'email',
  'Nov 16, 2026 (5:09 pm CT): Stephen forwarded Israel Rodriguez''s Nov 16 note ("I sent you an invitation for 11/23 at 4:30pm EST") to Marlon, Kirk (Prestige Sound) and Paul Kelly, subject "Fw: Following up: Start From Scratch in Chicago", with the line "PIONEER meeting date below". Internal crew notice only; nothing sent to AlphaTheta. Meeting: Mon Nov 23, 3:30 pm CT (4:30 pm ET), Microsoft Teams. Message-ID <CO6P220MB0338118754E59B4B2C03DE19D77C2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. [src:fw-2026-11-16-pioneer]',
  stage, 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-16 23:09:56+00'
from fs_partners where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and not exists (select 1 from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like '%[src:fw-2026-11-16-pioneer]%');

-- Companion grant row: replace the stale Nov 2/3 next step.
update fs_grant_deadlines set
  next_step = 'Teams meeting with Israel Rodriguez (Education & Training Manager, AlphaTheta Music Americas) Mon Nov 23, 2026, 3:30 pm CT (4:30 pm ET). Prepare a one-page agenda first (Start From Scratch in Chicago; equipment paths A-D; Club YOXO / Yokohama intro for Rainbow Wednesday). Afterward record which path AlphaTheta chooses and any dollar value they state. The Nov 2 and Nov 6 marketing.us emails and the Nov 3 call are superseded by Israel''s Nov 11 reply. Full thread is on the partner row.',
  next_step_due = '2026-11-23',
  notes = notes || E'\n2026-11-18 (.eml review): the Nov 2/3 next step (send Option A, call 1-844-784-0000) is DONE/superseded. Israel Rodriguez replied Nov 11 and Nov 16 (Teams invite for Nov 23, 4:30 pm ET); Stephen forwarded it to the crew Nov 16. No amount requested, offered or awarded in any email; amount stays equipment / partnership. [src:fw-2026-11-16-pioneer]'
where id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e'
  and next_step like 'Proposal page FIXED and pushed%'
  and notes not like '%[src:fw-2026-11-16-pioneer]%';

commit;

select left(p.id::text,8) id, p.stage, p.ball_with, p.next_step_due, left(p.next_step,50) next_step, p.last_contact_at,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and a.summary like '%[src:fw-2026-11-16-pioneer]%') fw_activity_rows,
  (select count(*) from fs_partner_activity a where a.summary like '%TY7P286MB688210491C93E10DBF50BE3CEC7C2%' and a.partner_id=p.id) re_activity_rows,
  position('[src:fw-2026-11-16-pioneer]' in p.notes) > 0 partner_note_ok
from fs_partners p where p.id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a';
select left(id::text,8) id, status, next_step_due, left(next_step,50) next_step, position('[src:fw-2026-11-16-pioneer]' in notes) > 0 grant_note_ok
from fs_grant_deadlines where id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e';

-- tracker-update-2026-11-24-partner-eml.sql  (reviewed Nov 24, 2026)
-- Partner-side BOB .eml intake, Nov 18-24, 2026. Re-runnable: activity keyed by partner + Message-ID,
-- updates guarded by expected-current values and [src:] markers.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select v.pid::uuid, v.kind, v.summary || ' Message-ID <' || v.mid || '>.', v.stage_after, v.by_email, v.by_name, v.at::timestamptz
from (values
 ('85a2975b-ae91-4f6f-b7d7-7dd14181c167','email','KHaM3qS4SXyT_QlzqeGDeg@geopod-ismtpd-40','2026-11-24 00:39:32+00','in_conversation','no-reply@serato.com','Serato (automated)',
  'Nov 23, 2026 (6:39 pm CT): "Welcome to Serato DJ Pro": an NFR license has been applied to stephen@selassiefest.com, with install and activation steps. Activation inside the app is not yet verified. No value stated.'),
 ('85a2975b-ae91-4f6f-b7d7-7dd14181c167','email','M69PGZZEJ01_6b04dd383d227_6bc4c79e94df4f_sprut@zendesk.com','2026-11-24 00:41:28+00','confirmed','sales@serato.com','Brad D',
  'Nov 23, 2026 (6:41 pm CT; Nov 24 NZ), ticket 1231468: Brad D (Serato Sales) wrote that he added the software to our account and allowed it to be activated on 14 computers, and wished the classes well. No value, term or conditions stated; he did not comment on the account name.'),
 ('2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2','email','20261123182439.fda1a666b6e582c1@charitymiles.mileageplus.com','2026-11-23 18:24:40+00','reached_out','milesonamission@mileageplus.com','Miles on a Mission (automated)',
  'Nov 23, 2026 (12:24 pm CT): Miles on a Mission confirmed receipt of the application; a charity MileagePlus account email is to follow (password to be created; used only if approved). It states the application window is paused until August and that acceptance or denial will be notified in August (no year stated). Acknowledgment only.'),
 ('5197811a-4835-4feb-861e-0c589d9ee669','email','yY7cG-UQS7iLW4pxKY1PDw@geopod-ismtpd-108','2026-11-23 18:34:08+00','reached_out','noreply+de49edcdfc426340@formstack.com','KORE / Qantas form (automated)',
  'Nov 23, 2026 (12:34 pm CT): automated form acknowledgment: a Qantas representative will be in contact as soon as possible. No timeline or decision.'),
 ('067c50fb-8562-410d-80cc-c23ea735bc3a','email','20261123184558.4abc2ca1b953ba96@airnz.co.nz','2026-11-23 18:45:58+00','reached_out','noreply@airnz.co.nz','Air New Zealand (automated)',
  'Nov 23, 2026 (12:46 pm CT): automated acknowledgment: Air New Zealand will email within four weeks if it can support; if no word in that time, assume it cannot. Unmonitored inbox. No decision.'),
 ('b8d73772-58e8-43bd-9aec-749502f8d76d','note','K3sjvKJBT9m8pT-J6Nxgsg@geopod-ismtpd-25','2026-11-22 01:35:35+00',null,'contactus@Audima.com.au','Audima Labs (automated)',
  'Nov 21, 2026 (7:35 pm CT): automated notice that an Audima Labs customer account was created (companion to the Sway reservation order). No action from Audima staff.'),
 ('d8211717-4fab-4c5d-86ab-ff62b95010e2','email','M996GPPMJ4K_6b05b4c3d3e06_2a4681438cac7d_sprut@zendesk.com','2026-11-24 16:01:08+00','reached_out','info@gatorcases.com','Gator Cases Support (automated)',
  'Nov 24, 2026 (10:01 am CT), ticket 533641: automated satisfaction survey quoting the Nov 23 reply, signed Chris Kemker (forwarded to relations and marketing). No new information, approval or value.'),
 ('d576fc5a-8554-4209-9fa3-1495327d4ec5','email','010001a1f1363742-65157673-30d3-483f-8d63-27404c7f7914-000000@email.amazonses.com','2026-11-19 00:30:24+00','reached_out','stephen@selassiefest.com','Stephen Henry',
  'Nov 18, 2026 (6:30 pm CT): follow-up SENT to sponsorships@cct.org, cc stephen@, on the Oct 31 question: which 2027 sponsorship cycle covers June-August events, whether one application can cover a series, and the typical range; goal 300 a night. No reply on file. Grant row ae12c710.'),
 ('0fa79d13-4dc5-4558-bd49-01b63c6a6c4c','email','010001a1f1ead2cf-9f22c79d-2a48-4a7e-b82a-0140eb71439f-000000@email.amazonses.com','2026-11-19 03:47:40+00','reached_out','stephen@selassiefest.com','Stephen Henry',
  'Nov 18, 2026 (9:47 pm CT): follow-up SENT to info@chicagoplays.com (League of Chicago Theatres, Powering the Arts) on the Oct 31 question: when the 2027 application opens and whether a first-year nonprofit may apply. No reply on file. Grant row acf259fe.')
) as v(pid, kind, mid, at, stage_after, by_email, by_name, summary)
where not exists (select 1 from fs_partner_activity a where a.partner_id = v.pid::uuid and position(v.mid in a.summary) > 0);

-- Serato: software granted
update fs_partners set
  stage = 'confirmed', ball_with = 'us',
  last_contact_at = greatest(last_contact_at, '2026-11-24 00:41:28+00'::timestamptz),
  commitment = 'GRANTED: Serato added Serato DJ Pro (NFR license) to our account stephen@selassiefest.com, activation allowed on 14 computers (Brad D, Serato Sales, ticket 1231468, Nov 23, 2026 CT). No value or license term stated. Activation in the app not yet verified. Our signed Student Data Policy (sent Nov 16) applies. History: ' || coalesce(commitment,''),
  next_step = 'Wed Nov 25, 9:00 am CT: send Brad D a thank-you on ticket 1231468 that also asks for the right Odyssey contact (draft only; send after Stephen says send). Then activate Serato DJ Pro, confirm License Active, and set up the generic student profile per the signed Student Data Policy. Do not nudge about the software or the account name.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes,'') || E'\n[2026-11-23] Software added to our account, 14 computers. [src:serato-granted-20261123] Previous next step: ' || coalesce(next_step,'')
where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167' and stage = 'in_conversation' and ball_with = 'them'
  and next_step_due = '2026-11-25' and coalesce(notes,'') not like '%src:serato-granted-20261123%';

-- Odyssey: the Nov 25 email is now a thank-you
update fs_partners set
  next_step = 'Wed Nov 25: add one sentence to the Serato thank-you (ticket 1231468) asking Brad D for the right Odyssey contact; send only after Stephen says send. Then send the booth request to that contact. Online only. Packet 02-gear-audio/06-odyssey.md. Booth line depends on the Joyce swap decision.',
  notes = coalesce(notes,'') || E'\n[2026-11-23] Serato granted the software; the carrier email for the Odyssey question is now the thank-you. [src:odyssey-via-thankyou-20261123]'
where id = '43075ae7-1438-49c8-80e5-d6319b69ae31' and stage = 'not_contacted' and next_step_due = '2026-11-25'
  and coalesce(notes,'') not like '%src:odyssey-via-thankyou-20261123%';

update fs_partners set
  next_step = 'Waiting on United Miles on a Mission (applied Nov 23, 2026). Its receipt email says the window is paused until August and the decision is notified in August (year not stated; read as 2027), which is after the Mar 25 to Apr 1, 2027 guest trip, so do not count on it for those flights. The application page had said 2 to 4 weeks. Check by Mon Nov 30, 2026 for the MileagePlus account email and create the password; then recheck Aug 31, 2027.',
  next_step_due = '2026-11-30',
  notes = coalesce(notes,'') || E'\n[2026-11-23] Conflict kept: page said review takes 2 to 4 weeks (check date was Dec 21); receipt email says paused until August, notice in August. [src:united-august-20261123]'
where id = '2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2' and stage = 'reached_out' and ball_with = 'them'
  and next_step_due = '2026-12-21' and coalesce(notes,'') not like '%src:united-august-20261123%';

update fs_partners set
  next_step = 'Waiting on Air New Zealand (form submitted Nov 23, 2026: two Economy round trips for the Audima guests, Mar 25 to Apr 1, 2027). Its automatic reply says it emails within four weeks if it can help. If nothing by Mon Dec 21, 2026, close as no response. No follow-up send (unmonitored inbox).',
  notes = coalesce(notes,'') || E'\n[2026-11-23] Auto-acknowledgment: four-week response window. [src:airnz-ack-20261123]'
where id = '067c50fb-8562-410d-80cc-c23ea735bc3a' and stage = 'reached_out' and ball_with = 'them'
  and next_step_due = '2026-12-21' and coalesce(notes,'') not like '%src:airnz-ack-20261123%';

update fs_partners set
  contacts = coalesce(contacts,'[]'::jsonb) || '[{"name":"Chris Kemker","title":"Support, Gator Cases","email":"info@gatorcases.com"}]'::jsonb,
  notes = coalesce(notes,'') || E'\n[2026-11-24] Ticket 533641 reply was signed Chris Kemker (quoted in the survey email). [src:gator-kemker-20261124]'
where id = 'd8211717-4fab-4c5d-86ab-ff62b95010e2' and coalesce(contacts,'[]'::jsonb)::text not like '%Kemker%'
  and coalesce(notes,'') not like '%src:gator-kemker-20261124%';

update fs_partners set
  stage = 'reached_out', ball_with = 'them', email = coalesce(email,'sponsorships@cct.org'),
  last_contact_at = '2026-11-19 00:30:24+00',
  next_step = 'Waiting on sponsorships@cct.org (follow-up sent Nov 18). If no reply by Mon Nov 30, email the three sponsorship questions again; send only after Stephen says send. Online only. (The separate grants@cct.org officer question is not logged as sent.)',
  next_step_due = '2026-11-30',
  notes = coalesce(notes,'') || E'\n[2026-11-18] Row aligned with grant row ae12c710. Earlier step: email grants@cct.org about the Community Impact officer (due Dec 7). [src:cct-aligned-20261118]'
where id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5' and stage = 'not_contacted' and ball_with = 'us'
  and next_step_due = '2026-12-07' and last_contact_at is null and coalesce(notes,'') not like '%src:cct-aligned-20261118%';

update fs_partners set
  stage = 'reached_out', ball_with = 'them', email = coalesce(email,'info@chicagoplays.com'),
  last_contact_at = '2026-11-19 03:47:40+00',
  next_step = 'Waiting on info@chicagoplays.com (follow-up sent Nov 18) for the 2027 Powering the Arts opening date and first-year eligibility. If silent, check Wed Dec 2; apply when the 2027 form opens.',
  next_step_due = '2026-12-02',
  notes = coalesce(notes,'') || E'\n[2026-11-18] Row aligned with grant row acf259fe. [src:comed-aligned-20261118]'
where id = '0fa79d13-4dc5-4558-bd49-01b63c6a6c4c' and stage = 'not_contacted' and ball_with = 'us'
  and next_step_due = '2026-11-30' and last_contact_at is null and coalesce(notes,'') not like '%src:comed-aligned-20261118%';

-- AlphaTheta: no outcome evidence; replace the stale pre-meeting step only
update fs_partners set
  next_step = 'The Teams meeting was set for Mon Nov 23, 3:30 pm CT. No outcome is on file. Stephen: say whether it was held, who attended, which equipment path (A-D) was discussed and who owes the next move; log it, then draft any thank-you (send only after Stephen says send). Keep the haptics loan a separate ask.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes,'') || E'\n[2026-11-24] Nov 23 meeting outcome not yet recorded. [src:alphatheta-outcome-pending-20261124] Previous next step: ' || coalesce(next_step,'')
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and stage = 'in_conversation' and ball_with = 'us'
  and next_step_due = '2026-11-23' and coalesce(notes,'') not like '%src:alphatheta-outcome-pending-20261124%';

-- roll everything back if any expected change did not land (current values moved)
do $$
declare n int;
begin
  select count(*) into n from fs_partners p join (values
    ('85a2975b-ae91-4f6f-b7d7-7dd14181c167','serato-granted-20261123'),
    ('43075ae7-1438-49c8-80e5-d6319b69ae31','odyssey-via-thankyou-20261123'),
    ('2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2','united-august-20261123'),
    ('067c50fb-8562-410d-80cc-c23ea735bc3a','airnz-ack-20261123'),
    ('d8211717-4fab-4c5d-86ab-ff62b95010e2','gator-kemker-20261124'),
    ('d576fc5a-8554-4209-9fa3-1495327d4ec5','cct-aligned-20261118'),
    ('0fa79d13-4dc5-4558-bd49-01b63c6a6c4c','comed-aligned-20261118'),
    ('a2e09e2e-5916-4e5a-b232-2369cfc8b57a','alphatheta-outcome-pending-20261124')
  ) v(id,m) on p.id = v.id::uuid and position(v.m in coalesce(p.notes,'')) > 0;
  if n <> 8 then raise exception 'expected 8 partner updates present, found %', n; end if;
end $$;

commit;

select p.name, p.stage, p.ball_with, p.next_step_due, p.last_contact_at,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and a.summary ~ '(KHaM3qS4|6b04dd383d227|fda1a666b6e582c1|yY7cG-UQS7|4abc2ca1b953ba96|K3sjvKJBT9|6b05b4c3d3e06|010001a1f1363742|010001a1f1ead2cf)') as new_activity
from fs_partners p
where p.id in ('85a2975b-ae91-4f6f-b7d7-7dd14181c167','43075ae7-1438-49c8-80e5-d6319b69ae31','2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2',
 '5197811a-4835-4feb-861e-0c589d9ee669','067c50fb-8562-410d-80cc-c23ea735bc3a','b8d73772-58e8-43bd-9aec-749502f8d76d',
 'd8211717-4fab-4c5d-86ab-ff62b95010e2','d576fc5a-8554-4209-9fa3-1495327d4ec5','0fa79d13-4dc5-4558-bd49-01b63c6a6c4c','a2e09e2e-5916-4e5a-b232-2369cfc8b57a')
order by p.name;

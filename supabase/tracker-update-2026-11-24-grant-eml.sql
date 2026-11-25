-- Grant-side catch-up for BOB mail Nov 18-24, 2026. Safe to re-run.
begin;

-- A. Field changes, guarded by expected current values
update fs_grant_deadlines set 
  next_step = $q$(1) By Mon Nov 30: Stephen decides on the Dec 12 Youth Showcase (10 am-1 pm, Griffin MSI) and, if presenting, replies to Alex Biswas, abiswas@janegoodall.org, with the project link or a 1-2 sentence description and the interactive display idea. (2) Redeem the $250 Tremendous Visa card, read its expiry date, keep card data out of the tracker. (3) Buy materials after the teens choose the theme; Ivry's input waits on CPD approval. (4) Final report by Dec 30, 2026: progress so far and anticipated activities and impact; keep the project profile updated.$q$,
  next_step_due = '2026-11-30',
  notes = concat_ws(E'\n', notes, $q$[2026-11-24] Alex Biswas 9:22 am CT answered four questions: (1) card expiry: she believes October 2031 and says it should be on the card; (2) December is the final report date (award email: by Dec 30); the project will not be complete until 2027, so share progress so far and anticipated activities and impact; (3) Visa gift card, usable at any business that accepts Visa; (4) buying now is not required; she recommends the teens choose the theme first. INVITATION: Youth Showcase Sat Dec 12, 2026, 10 am-1 pm, Griffin Museum of Science and Industry; to present, reply by Mon Nov 30 with the R&S project link or a 1-2 sentence description and how the display will be interactive; presenters 13+ unless an adult leader or parent/guardian assists. [src:msgid-BY3PR13MB4978DAAA226F1229D5A6A7D9B0442@BY3PR13MB4978.namprd13.prod.outlook.com]$q$),
  updated_at = now()
where id = '38c4ff8b-f15a-4c28-9182-8093fb370263' and status = 'awarded' and next_step_due = '2026-12-01'
  and position($q$BY3PR13MB4978DAAA226F1229D5A6A7D9B0442@BY3PR13MB4978.namprd13.prod.outlook.com$q$ in coalesce(notes,'')) = 0;

update fs_grant_deadlines set 
  next_step = $q$Fluxx registration SUBMITTED Nov 20, 2026. Wait for Joyce's review email (approval opens an LOI). April 2027 cycle is possible, not confirmed (Maddie Easton, Nov 20); an LOI should show how artists and the community take part. Follow up with Maddie Tue Dec 1 if silent.$q$,
  next_step_due = '2026-12-01',
  notes = concat_ws(E'\n', notes, $q$[2026-11-20] Maddie Easton 4:31 pm CT: RTI could potentially be on track for the April cycle, but she cannot say which cycle; the Culture program director decides. She said it would help to understand how the program engages artists and the community. No amount or status change. [src:msgid-LV0SPRMB001221199874F49FBD31FF67D7782@LV0SPRMB0012.namprd15.prod.outlook.com]$q$),
  updated_at = now()
where id = 'dc25d586-f390-4553-964a-01fd8090c8e1' and status = 'drafting' and next_step_due = '2026-12-01'
  and position($q$LV0SPRMB001221199874F49FBD31FF67D7782@LV0SPRMB0012.namprd15.prod.outlook.com$q$ in coalesce(notes,'')) = 0;

update fs_grant_deadlines set 
  next_step = $q$Check by Mon Nov 30 for the MileagePlus charity account email and create the password. United's receipt says decisions come in August (year not stated). Do not count on United for the Mar 25-Apr 1, 2027 flights unless United says otherwise. Recheck in Aug 2027.$q$,
  next_step_due = '2026-11-30',
  notes = concat_ws(E'\n', notes, $q$[2026-11-23] Miles on a Mission receipt 12:24 pm CT: team will contact us if it has questions; a MileagePlus charity account email is coming (create a password); APPLICATION WINDOW PAUSED UNTIL AUGUST, acceptance or denial notice in August (year not stated). Conflicts with the 2-4 week review shown at submission; an August 2027 answer would fall after the Mar 25-Apr 1, 2027 flights. [src:msgid-20261123182439.fda1a666b6e582c1@charitymiles.mileageplus.com]$q$),
  updated_at = now()
where id = 'e621a665-f5d3-41a6-b067-cb90b1104afa' and status = 'submitted' and next_step_due = '2026-12-21'
  and position($q$20261123182439.fda1a666b6e582c1@charitymiles.mileageplus.com$q$ in coalesce(notes,'')) = 0;

update fs_grant_deadlines set status = 'awarded', decision_on = '2026-11-23', 
  next_step = $q$GRANTED: Serato software, activation on 14 computers. Thank Brad D on ticket 1231468 and ask for the right Odyssey contact (draft first; send only after Stephen says send), confirm License Active at first install, follow the Student Data Policy terms. The planned Nov 25 nudge is no longer needed.$q$,
  next_step_due = '2026-11-25',
  notes = concat_ws(E'\n', notes, $q$[2026-11-23] IN-KIND AWARD: Brad D, Serato Sales (ticket 1231468), 6:41 pm CT: added the software to the account and allowed activation on 14 computers. No cash, no value, term or expiry stated. Activation on our computers not yet verified. [src:msgid-M69PGZZEJ01_6b04dd383d227_6bc4c79e94df4f_sprut@zendesk.com]$q$),
  updated_at = now()
where id = 'aaeff4a3-343e-4210-b538-78e14887d5fc' and status = 'submitted' and next_step_due = '2026-11-25'
  and position($q$M69PGZZEJ01_6b04dd383d227_6bc4c79e94df4f_sprut@zendesk.com$q$ in coalesce(notes,'')) = 0;

update fs_grant_deadlines set decision_on = '2026-11-24', 
  next_step = $q$APPROVED for Tue Jan 19, 2027, 5-8 pm, 520 W. Taylor St. (ref PG-40918). By Tue Dec 1: add Jan 19 and Jan 12 prep to the calendar; promote with the Portillo's flyer (never on their premises). Prep Jan 12; after the night, record the results email and watch for the check (30-45 days).$q$,
  next_step_due = '2026-12-01',
  notes = concat_ws(E'\n', notes, $q$[2026-11-24] APPROVED: Portillo's For Good (Laura) 8:40 am CT, ref PG-40918: fundraiser Tue Jan 19, 2027, 5-8 pm, 520 W. Taylor St.; 20% of attributed sales (flyer, mention, or pickup order with our code, kept in the email only); $200 minimum sales; gift cards, delivery and third-party orders excluded; no promotion or displays on premises; FAQ: results email the next afternoon, check within 30-45 days. No money earned or received yet. [src:msgid--NaTP000000000000000000000000000000000000000000000TP0GRP006sVoln8NTM6XPS44mMQmoA@sfdc.net]$q$),
  updated_at = now()
where id = 'fc1eb971-3254-4fb5-b4e5-5a9b1766fd90' and status = 'submitted' and next_step_due = '2026-12-08'
  and position($q$-NaTP000000000000000000000000000000000000000000000TP0GRP006sVoln8NTM6XPS44mMQmoA@sfdc.net$q$ in coalesce(notes,'')) = 0;

update fs_grant_deadlines set next_step = $q$Third-touch follow-up SENT Nov 23, 2026 to Hyatt naming the ask (2 donated rooms in 2027). Wait for a reply; if silent, check again Dec 7. Online only.$q$,
  notes = concat_ws(E'
', notes, '[2026-11-24] Previous next step (superseded): ' || coalesce(next_step,'') || ' [src:hyatt-next-20261123]'),
  next_step_due = '2026-12-07', updated_at = now()
where id = '6c050a1a-ae09-4877-9563-9aefb85b1ec7' and status = 'ready' and next_step_due = '2026-12-02' and position('src:hyatt-next-20261123' in coalesce(notes,'')) = 0;

update fs_grant_deadlines set next_step = $q$Third-touch follow-up SENT Nov 23, 2026 to IHG naming the ask (2 donated rooms in 2027). Wait for a reply; if silent, check again Dec 7. Online only.$q$,
  notes = concat_ws(E'
', notes, '[2026-11-24] Previous next step (superseded): ' || coalesce(next_step,'') || ' [src:ihg-next-20261123]'),
  next_step_due = '2026-12-07', updated_at = now()
where id = '5cbce63b-2bb4-48d4-8422-7f6f141af380' and status = 'ready' and next_step_due = '2026-12-02' and position('src:ihg-next-20261123' in coalesce(notes,'')) = 0;

update fs_grant_deadlines set next_step = $q$Hilton Global Foundation DECLINED Nov 2 (stands). Property-level inquiry SENT Nov 23 to TWP@hilton.com; wait, and if silent check Dec 9 for a published Hilton Chicago community contact. Online only.$q$,
  notes = concat_ws(E'
', notes, '[2026-11-24] Previous next step (superseded): ' || coalesce(next_step,'') || ' [src:hilton-next-20261123]'),
  next_step_due = '2026-12-09', updated_at = now()
where id = '8df83cd3-7f31-4789-8d2d-114efae29760' and status = 'declined' and next_step_due = '2026-11-16' and position('src:hilton-next-20261123' in coalesce(notes,'')) = 0;

update fs_grant_deadlines set
  next_step = $q$Wed Nov 25: add one sentence to the Serato thank-you (ticket 1231468) asking Brad D for the right Odyssey contact; send only after Stephen says send. Then send the booth request to that contact. Online only. Packet 02-gear-audio/06-odyssey.md. Booth line depends on the Joyce swap decision.$q$,
  notes = concat_ws(E'
', notes, $q$[2026-11-23] Serato granted the software; the carrier email for the Odyssey question is now the thank-you. Fallback if no name by 2026-12-08 stands. [src:odyssey-via-thankyou-20261123]$q$),
  updated_at = now()
where id = '95fcca73-11d4-4d8d-afdd-0420c2382c7a' and status = 'drafting' and next_step_due = '2026-11-25'
  and position('src:odyssey-via-thankyou-20261123' in coalesce(notes,'')) = 0;

update fs_grant_deadlines set
  notes = concat_ws(E'
', notes, '[2026-11-24] Nov 23 meeting outcome not yet recorded. Previous next step: ' || coalesce(next_step,'') || ' [src:alphatheta-outcome-pending-20261124]'),
  next_step = $q$The Teams meeting was set for Mon Nov 23, 3:30 pm CT. No outcome is on file. Stephen: say whether it was held, who attended, which equipment path (A-D) was discussed and who owes the next move; log it, then draft any thank-you (send only after Stephen says send).$q$,
  next_step_due = '2026-11-25', updated_at = now()
where id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e' and status = 'submitted' and next_step_due = '2026-11-23'
  and position('src:alphatheta-outcome-pending-20261124' in coalesce(notes,'')) = 0;

-- B. Note-only appends, keyed by Message-ID
do $do$
declare r record;
begin
  for r in select * from (values
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$010001a1f0ac15b3-d6b53332-49be-4f1e-adc6-c37ca6613679-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the Ivry Ector lawn-plan email on file.$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$SA0PR09MB6315A11AFD0304684DF6580386792@SA0PR09MB6315.namprd09.prod.outlook.com$q$, $q$[2026-11-19] Ivry Ector replied 1:48 pm CT: partnership not yet approved, so she cannot give any suggestion; her input starts after approval.$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$SA0PR09MB6315F1B86EF7572EFD19C2B686782@SA0PR09MB6315.namprd09.prod.outlook.com$q$, $q$[2026-11-20] Ivry Ector 9:24 am CT: courtesy acknowledgment only; no choice or approval.$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$6b05a640adea8_11b62899722@core-sidekiq-68cdff956d-rdf55.mail$q$, $q$[2026-11-24] AWARD DELIVERED: Tremendous reward email 8:59 am CT, $250.00 Visa gift card from the CHI Basecamp. Delivery only; redemption not verified. No card data or redemption link stored here.$q$),
('aaeff4a3-343e-4210-b538-78e14887d5fc'::uuid, $q$KHaM3qS4SXyT_QlzqeGDeg@geopod-ismtpd-40$q$, $q$[2026-11-23] Serato automated email 6:39 pm CT: NFR license for Serato DJ Pro applied to the account email.$q$),
('6c050a1a-ae09-4877-9563-9aefb85b1ec7'::uuid, $q$010001a20a0f5083-39a7180d-ffdb-4c63-8eb9-e8e29c5b520d-000000@email.amazonses.com$q$, $q$[2026-11-23] Follow-up sent 2:18 pm CT to risehy@hyatt.com naming the ask (2 donated rooms in 2027). No reply on file.$q$),
('5cbce63b-2bb4-48d4-8422-7f6f141af380'::uuid, $q$010001a20a0f50e6-4499e190-b181-44b1-ac04-80952287c57a-000000@email.amazonses.com$q$, $q$[2026-11-23] Follow-up sent 2:18 pm CT to community@ihg.com naming the ask (2 donated rooms in 2027). No reply on file.$q$),
('8df83cd3-7f31-4789-8d2d-114efae29760'::uuid, $q$010001a20a0c13f4-fc6401c1-18cc-44ab-9062-0c3434ebac83-000000@email.amazonses.com$q$, $q$[2026-11-23] Separate later route: inquiry sent 2:14 pm CT to TWP@hilton.com (property connection, 2 donated rooms in 2027). The Nov 2 Hilton Global Foundation decline stands.$q$),
('94726569-7987-4945-97fa-47e4bf31559c'::uuid, $q$010001a20a0839d0-8a8cc12c-93cf-4381-b384-705a11cd2272-000000@email.amazonses.com$q$, $q$[2026-11-23] Sent copy of the Marriott@maritz.com inquiry on file.$q$),
('7c058a30-e59d-43ff-a877-aff415d8acf6'::uuid, $q$010001a2073f945d-ee5ba789-8978-48ca-a650-785aac6b8824-000000@email.amazonses.com$q$, $q$[2026-11-23] Sent copy on file (1:12 am CT) with two attachments: application PDF and IRS determination letter. No acknowledgment on file.$q$),
('6568f74b-8a4b-40f8-857f-87792a476991'::uuid, $q$v6vuPfro8AdiazCwGpPOMO1I5vPFPvHd2TNtCSaU@go-workers-8367$q$, $q$[2026-11-21] Jotform response copy received 3:23 am CT (submitted answers; $10,000 instructor line).$q$),
('6766027b-2bf6-4aa7-a9d2-974879c8ec93'::uuid, $q$4b938a654fcfbcb93fd8cb676.be6578f029.20261118202041.fc80a40bba.9929bc8d@mail175.suw161.rsgsv.net$q$, $q$[2026-11-18] Levitt deadline reminder (due Nov 20); no action, already submitted Nov 18. Correction: the Nov 3 note figure of 150 a night for Rainbow Wednesdays is superseded; the goal is 300 a night (Stephen, Nov 18).$q$),
('ae12c710-6c22-4acf-8bbe-b3c6389cdd52'::uuid, $q$010001a1f1363742-65157673-30d3-483f-8d63-27404c7f7914-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the sponsorships@cct.org follow-up on file.$q$),
('06db1d00-db13-42da-81ba-bf16b308e00b'::uuid, $q$010001a1f150f4ce-e26ca3e3-213d-4dcb-8680-9dfadde5541f-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the December dates email on file.$q$),
('25f4ac41-f367-4dbc-bf0d-e0f1843679ea'::uuid, $q$010001a1f1e0dd40-c7d73a3d-43ed-4a9c-8ecf-0387f621c284-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the inquiry on file.$q$),
('e797da22-4502-4169-ae2c-1bc1ba732244'::uuid, $q$010001a1f2071ac6-0e9f772f-7b7c-4bbd-9e3d-aa6446548400-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the Jared Selter nudge on file.$q$),
('e797da22-4502-4169-ae2c-1bc1ba732244'::uuid, $q$b97a053625044f00affa77cd3d571876@AMDPR04MB11584.eurprd04.prod.outlook.com$q$, $q$[2026-11-18] Automatic reply from Jared Selter: out of office 11/17 to 11/27. Dec 2 nudge stands.$q$),
('f1a22e77-6f67-4401-81c2-8eb318c207dd'::uuid, $q$010001a1f21379a5-c1c985c0-5738-4baa-9180-9bdc4f0b3200-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the nudge on file.$q$),
('926f48bd-5ad6-46fa-89ac-4d5bb59e237f'::uuid, $q$010001a1f2137917-0f9ec0e5-3b03-4afa-8eb4-38e5ace76759-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the nudge on file.$q$),
('d80a476f-ce3c-4afa-b686-30065b45266f'::uuid, $q$010001a1f2473a80-b758d746-be1d-4aec-acea-6634c5354b55-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the pricing inquiry on file.$q$),
('bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'::uuid, $q$010001a1f2572c22-39325903-2e94-4258-93fa-4b482d0a6b84-000000@email.amazonses.com$q$, $q$[2026-11-18] Sent copy of the DCASE follow-up on file.$q$),
('a4287c9e-7de0-4540-83df-cfa63c3850bc'::uuid, $q$010001a202118816-5a83b2c0-a992-4c92-bd94-2ae763d54028-000000@email.amazonses.com$q$, $q$[2026-11-22] Sent copy of the email on file.$q$),
('ed49e5a0-618d-450b-833e-c7ded43e912a'::uuid, $q$CO6P220MB033861D3D6374E339B3EA869D7442@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM$q$, $q$[2026-11-24] Sent copy of the bounced inquiry on file (12:51 am CT).$q$),
('ed49e5a0-618d-450b-833e-c7ded43e912a'::uuid, $q$6b053408.5239df90.1a6839.7145.GMR@mx.google.com$q$, $q$[2026-11-24] Gmail delivery failure on file (12:51 am CT): address not found.$q$),
('1bb6960b-2be0-4e7e-9967-944922c080d3'::uuid, $q$010001a2021e7dba-78f14a4b-d135-48aa-83b1-6586fdc6c0bc-000000@email.amazonses.com$q$, $q$[2026-11-22] Human-I-T account verification email on file (link not stored).$q$),
('1bb6960b-2be0-4e7e-9967-944922c080d3'::uuid, $q$010001a2021e7ef9-af371b61-f2a1-44bb-9794-5383ca578505-000000@email.amazonses.com$q$, $q$[2026-11-22] Human-I-T registration email: invites Gold Member documents (household assistance or low-income proof).$q$),
('1bb6960b-2be0-4e7e-9967-944922c080d3'::uuid, $q$010001a2021e7ff1-4fd5ef16-68d9-48b2-b4b2-cd837180c0fc-000000@email.amazonses.com$q$, $q$[2026-11-22] Human-I-T says documents received for Gold Membership review. Conflicts with the earlier line "Nothing submitted for approval"; both kept. Row stays not_eligible.$q$),
('de947322-dbc9-4af0-80b9-713f47fb844a'::uuid, $q$M996GPPMJ4K_6b05b4c3d3e06_2a4681438cac7d_sprut@zendesk.com$q$, $q$[2026-11-24] Gator support satisfaction survey on ticket 533641; no change.$q$)
  ) as t(gid, mid, note)
  loop
    update fs_grant_deadlines
       set notes = concat_ws(E'\n', notes, r.note || ' [src:msgid-' || r.mid || ']'), updated_at = now()
     where id = r.gid and position(r.mid in coalesce(notes,'')) = 0;
    if not exists (select 1 from fs_grant_deadlines where id = r.gid and position(r.mid in coalesce(notes,'')) > 0) then
      raise exception 'note not stored for %', r.mid;
    end if;
  end loop;
end
$do$;

do $chk$
declare n int;
begin
  select count(*) into n from fs_grant_deadlines g join (values
   ('38c4ff8b-f15a-4c28-9182-8093fb370263','BY3PR13MB4978DAAA226F1229D5A6A7D9B0442'),
   ('dc25d586-f390-4553-964a-01fd8090c8e1','LV0SPRMB001221199874F49FBD31FF67D7782'),
   ('e621a665-f5d3-41a6-b067-cb90b1104afa','20261123182439.fda1a666b6e582c1'),
   ('aaeff4a3-343e-4210-b538-78e14887d5fc','M69PGZZEJ01_6b04dd383d227'),
   ('fc1eb971-3254-4fb5-b4e5-5a9b1766fd90','TP0GRP006sVoln8NTM6XPS44mMQmoA'),
   ('6c050a1a-ae09-4877-9563-9aefb85b1ec7','src:hyatt-next-20261123'),
   ('5cbce63b-2bb4-48d4-8422-7f6f141af380','src:ihg-next-20261123'),
   ('8df83cd3-7f31-4789-8d2d-114efae29760','src:hilton-next-20261123'),
   ('95fcca73-11d4-4d8d-afdd-0420c2382c7a','src:odyssey-via-thankyou-20261123'),
   ('f575d085-f8ee-4f12-a90d-bcf7e2a4d28e','src:alphatheta-outcome-pending-20261124')
  ) v(id,m) on g.id = v.id::uuid and position(v.m in coalesce(g.notes,'')) > 0;
  if n <> 10 then raise exception 'expected 10 grant updates present, found %', n; end if;
end $chk$;

commit;

-- C. Verify
select funder, status, amount_awarded, submitted_on, decision_on, next_step_due, next_step
from fs_grant_deadlines where id in ('38c4ff8b-f15a-4c28-9182-8093fb370263','dc25d586-f390-4553-964a-01fd8090c8e1','e621a665-f5d3-41a6-b067-cb90b1104afa','aaeff4a3-343e-4210-b538-78e14887d5fc','fc1eb971-3254-4fb5-b4e5-5a9b1766fd90','6c050a1a-ae09-4877-9563-9aefb85b1ec7','5cbce63b-2bb4-48d4-8422-7f6f141af380','8df83cd3-7f31-4789-8d2d-114efae29760','95fcca73-11d4-4d8d-afdd-0420c2382c7a','f575d085-f8ee-4f12-a90d-bcf7e2a4d28e') order by funder;

with v(gid, mid) as (values
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$010001a1f0ac15b3-d6b53332-49be-4f1e-adc6-c37ca6613679-000000@email.amazonses.com$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$SA0PR09MB6315A11AFD0304684DF6580386792@SA0PR09MB6315.namprd09.prod.outlook.com$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$SA0PR09MB6315F1B86EF7572EFD19C2B686782@SA0PR09MB6315.namprd09.prod.outlook.com$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$6b05a640adea8_11b62899722@core-sidekiq-68cdff956d-rdf55.mail$q$),
('aaeff4a3-343e-4210-b538-78e14887d5fc'::uuid, $q$KHaM3qS4SXyT_QlzqeGDeg@geopod-ismtpd-40$q$),
('6c050a1a-ae09-4877-9563-9aefb85b1ec7'::uuid, $q$010001a20a0f5083-39a7180d-ffdb-4c63-8eb9-e8e29c5b520d-000000@email.amazonses.com$q$),
('5cbce63b-2bb4-48d4-8422-7f6f141af380'::uuid, $q$010001a20a0f50e6-4499e190-b181-44b1-ac04-80952287c57a-000000@email.amazonses.com$q$),
('8df83cd3-7f31-4789-8d2d-114efae29760'::uuid, $q$010001a20a0c13f4-fc6401c1-18cc-44ab-9062-0c3434ebac83-000000@email.amazonses.com$q$),
('94726569-7987-4945-97fa-47e4bf31559c'::uuid, $q$010001a20a0839d0-8a8cc12c-93cf-4381-b384-705a11cd2272-000000@email.amazonses.com$q$),
('7c058a30-e59d-43ff-a877-aff415d8acf6'::uuid, $q$010001a2073f945d-ee5ba789-8978-48ca-a650-785aac6b8824-000000@email.amazonses.com$q$),
('6568f74b-8a4b-40f8-857f-87792a476991'::uuid, $q$v6vuPfro8AdiazCwGpPOMO1I5vPFPvHd2TNtCSaU@go-workers-8367$q$),
('6766027b-2bf6-4aa7-a9d2-974879c8ec93'::uuid, $q$4b938a654fcfbcb93fd8cb676.be6578f029.20261118202041.fc80a40bba.9929bc8d@mail175.suw161.rsgsv.net$q$),
('ae12c710-6c22-4acf-8bbe-b3c6389cdd52'::uuid, $q$010001a1f1363742-65157673-30d3-483f-8d63-27404c7f7914-000000@email.amazonses.com$q$),
('06db1d00-db13-42da-81ba-bf16b308e00b'::uuid, $q$010001a1f150f4ce-e26ca3e3-213d-4dcb-8680-9dfadde5541f-000000@email.amazonses.com$q$),
('25f4ac41-f367-4dbc-bf0d-e0f1843679ea'::uuid, $q$010001a1f1e0dd40-c7d73a3d-43ed-4a9c-8ecf-0387f621c284-000000@email.amazonses.com$q$),
('e797da22-4502-4169-ae2c-1bc1ba732244'::uuid, $q$010001a1f2071ac6-0e9f772f-7b7c-4bbd-9e3d-aa6446548400-000000@email.amazonses.com$q$),
('e797da22-4502-4169-ae2c-1bc1ba732244'::uuid, $q$b97a053625044f00affa77cd3d571876@AMDPR04MB11584.eurprd04.prod.outlook.com$q$),
('f1a22e77-6f67-4401-81c2-8eb318c207dd'::uuid, $q$010001a1f21379a5-c1c985c0-5738-4baa-9180-9bdc4f0b3200-000000@email.amazonses.com$q$),
('926f48bd-5ad6-46fa-89ac-4d5bb59e237f'::uuid, $q$010001a1f2137917-0f9ec0e5-3b03-4afa-8eb4-38e5ace76759-000000@email.amazonses.com$q$),
('d80a476f-ce3c-4afa-b686-30065b45266f'::uuid, $q$010001a1f2473a80-b758d746-be1d-4aec-acea-6634c5354b55-000000@email.amazonses.com$q$),
('bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'::uuid, $q$010001a1f2572c22-39325903-2e94-4258-93fa-4b482d0a6b84-000000@email.amazonses.com$q$),
('a4287c9e-7de0-4540-83df-cfa63c3850bc'::uuid, $q$010001a202118816-5a83b2c0-a992-4c92-bd94-2ae763d54028-000000@email.amazonses.com$q$),
('ed49e5a0-618d-450b-833e-c7ded43e912a'::uuid, $q$CO6P220MB033861D3D6374E339B3EA869D7442@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM$q$),
('ed49e5a0-618d-450b-833e-c7ded43e912a'::uuid, $q$6b053408.5239df90.1a6839.7145.GMR@mx.google.com$q$),
('1bb6960b-2be0-4e7e-9967-944922c080d3'::uuid, $q$010001a2021e7dba-78f14a4b-d135-48aa-83b1-6586fdc6c0bc-000000@email.amazonses.com$q$),
('1bb6960b-2be0-4e7e-9967-944922c080d3'::uuid, $q$010001a2021e7ef9-af371b61-f2a1-44bb-9794-5383ca578505-000000@email.amazonses.com$q$),
('1bb6960b-2be0-4e7e-9967-944922c080d3'::uuid, $q$010001a2021e7ff1-4fd5ef16-68d9-48b2-b4b2-cd837180c0fc-000000@email.amazonses.com$q$),
('de947322-dbc9-4af0-80b9-713f47fb844a'::uuid, $q$M996GPPMJ4K_6b05b4c3d3e06_2a4681438cac7d_sprut@zendesk.com$q$),
('38c4ff8b-f15a-4c28-9182-8093fb370263'::uuid, $q$BY3PR13MB4978DAAA226F1229D5A6A7D9B0442@BY3PR13MB4978.namprd13.prod.outlook.com$q$),
('dc25d586-f390-4553-964a-01fd8090c8e1'::uuid, $q$LV0SPRMB001221199874F49FBD31FF67D7782@LV0SPRMB0012.namprd15.prod.outlook.com$q$),
('e621a665-f5d3-41a6-b067-cb90b1104afa'::uuid, $q$20261123182439.fda1a666b6e582c1@charitymiles.mileageplus.com$q$),
('aaeff4a3-343e-4210-b538-78e14887d5fc'::uuid, $q$M69PGZZEJ01_6b04dd383d227_6bc4c79e94df4f_sprut@zendesk.com$q$),
('fc1eb971-3254-4fb5-b4e5-5a9b1766fd90'::uuid, $q$-NaTP000000000000000000000000000000000000000000000TP0GRP006sVoln8NTM6XPS44mMQmoA@sfdc.net$q$)
)
select count(*) as sources_expected,
       count(g.id) as sources_logged,
       string_agg(v.mid, ', ') filter (where g.id is null) as missing
from v left join fs_grant_deadlines g
  on g.id = v.gid and position(v.mid in coalesce(g.notes,'')) > 0;

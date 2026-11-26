-- Grant rows from BOB emails, processed Nov 26, 2026. Safe to re-run (keyed on Message-ID tags).
-- Covers the grant-row sections of tracker-update-2026-11-25-bob-emails.sql, which was not applied to live.
begin;

update fs_grant_deadlines set
  status = 'awarded',
  decision_on = date '2026-11-25',
  next_step = 'OFFERED Nov 25, 2026 (Lindsey Auz, Marketing Manager): donation of 50 mini custard cups, in kind, no value stated. Not yet accepted or received. Her email says "your event on March 9th"; our record says the May 18, 2027 Spring Showcase: confirm the date. Pickup the day of or the day before, after 11 am, with the Chicago team on Archer Avenue (can also be arranged closer to the date). Draft the reply; send only after Stephen says send.',
  next_step_due = date '2026-11-27',
  notes = coalesce(notes,'') || ' | 2026-11-25 10:14 am CT: written in-kind offer from Lindsey Auz: 50 mini custard cups, event date given as March 9. Conflicts with the May 18, 2027 date and the pickup location recorded at submission (Nov 25); unresolved. Prior status submitted, next step due 2026-12-10. [src:msgid-DS2PR17MB2950417E6113D80AA4DD1F868D84432@DS2PR17MB295041.namprd17.prod.outlook.com]' || ' Previous next_step: ' || coalesce(next_step,''),
  updated_at = now()
where id = '8c21a12a-bf69-4a3d-abc4-728d916f34ee'
  and status = 'submitted'
  and coalesce(notes,'') not like '%DS2PR17MB2950417E6113D80AA4DD1F868D84432%';

update fs_grant_deadlines set
  status = 'declined',
  decision_on = date '2026-11-25',
  next_step = 'DECLINED Nov 25, 2026 (request 5225976): cannot accommodate at this time; asked us to reapply with the address on the 501(c)(3) determination letter. Nothing awarded or received. The reapplication is tracked on its own row.',
  next_step_due = null,
  notes = coalesce(notes,'') || ' | 2026-11-25 3:59 am CT: receipt email [src:msgid-6b06b1681931b_1011aae0831569@ip-10-134-5-254.us-east-2.compute.internal.mail]. 2026-11-25 9:18 am CT: decline email, high request volume; "Please reapply with the address on your organizations 501(c)(3) form. We will be glad to reconsider at that time." Reply-to corporategiving@oriental.com. Prior status submitted, next step due 2026-12-28. [src:msgid-6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail]' || ' Previous next_step: ' || coalesce(next_step,''),
  updated_at = now()
where id = 'd14f32bd-d2e1-483f-b2cc-ef800b3e7ac8'
  and status = 'submitted'
  and coalesce(notes,'') not like '%6b06fc39533f2_1011aae08420a5%';

insert into fs_grant_deadlines
  (funder, program, kind, status, level, project, priority, amount, url, verified, verified_on, next_step, next_step_due, notes)
select 'Oriental Trading', 'Corporate giving donation request: reapplication with determination-letter address', 'rolling', 'drafting',
  'corporate', 'djclass', 3, 'package not published', 'https://orientaltrading.requestitem.com/', true, date '2026-11-26',
  'Reapply in their online system with the address on the IRS determination letter (765 E 154th St, South Holland, IL 60473) and attach the letter. Youth craft and decoration supplies for the DJ Lab Spring Showcase, May 18, 2027. Allow 4 weeks for processing. Stephen presses Submit.',
  date '2026-11-27',
  '[oriental-reapply 2026-11-26] Follow-up to request 5225976 (row d14f32bd-d2e1-483f-b2cc-ef800b3e7ac8), declined Nov 25, 2026 with an invitation to reapply. Not submitted, not awarded.'
where exists (select 1 from fs_grant_deadlines where id = 'd14f32bd-d2e1-483f-b2cc-ef800b3e7ac8' and status = 'declined')
  and not exists (select 1 from fs_grant_deadlines where coalesce(notes,'') like '%[oriental-reapply 2026-11-26]%');

update fs_grant_deadlines set
  status = 'not_eligible',
  decision_on = date '2026-11-25',
  next_step = 'NOT ELIGIBLE (George Buck, Nov 25, 2026): the advisory board decided not to accept new requests from outside DeKalb County. No application filed. Do not send the Dec 2 nudge or file for the Mar 1, 2027 cycle.',
  next_step_due = null,
  notes = coalesce(notes,'') || ' | 2026-11-25 6:52 am CT: George Buck replied to our Nov 24 inquiry from george@dekalbcountyfoundation.org: they still support a few long-standing Chicago organizations but are not accepting new requests from outside DeKalb County. The public program page (read Nov 26) still says greater Chicagoland with DeKalb priority; his written answer governs for us. Prior status drafting, next step due 2026-12-02, planned filing from 2027-01-01. [src:msgid-165FE057-4F28-447D-8B18-DC362DBC70F4@dekalbcountyfoundation.org]' || ' Previous next_step: ' || coalesce(next_step,''),
  updated_at = now()
where id = '013d3944-c420-4534-b9af-7f3a604c0235'
  and status = 'drafting'
  and coalesce(notes,'') not like '%165FE057-4F28-447D-8B18-DC362DBC70F4%';

update fs_grant_deadlines set
  decision_on = null,
  verified_on = date '2026-11-26',
  notes = coalesce(notes,'') || ' | 2026-11-25 4:13 am CT: Google Forms receipt for the Preliminary Grant Inquiry ($10,000, 20 Tuesdays). Funder page (read Nov 26): invitations by Mar 1, applications Apr 1, awards May 1. decision_on 2027-03-01 cleared: it was an expected invitation date, not a decision. [src:msgid-autogen-java-688be7ce-93c9-49ab-8bd2-00be3bc18ee8@google.com]',
  updated_at = now()
where id = '4b24678c-8233-4cea-b4be-c029151e24e2'
  and status = 'submitted'
  and decision_on = date '2027-03-01'
  and coalesce(notes,'') not like '%autogen-java-688be7ce-93c9-49ab-8bd2-00be3bc18ee8%';

update fs_grant_deadlines g set
  notes = coalesce(g.notes,'') || v.line || ' [src:msgid-' || v.mid || ']',
  updated_at = now()
from (values
  ('688e871d-3045-4895-a84b-1b67536a5fa2'::uuid, ' | 2026-11-25 3:42 am CT: confirmation email from onebyone@4imprint.com: application received, up to six weeks to process.', '712f6175-d9c3-4a40-aac7-e7ab77a35b38@us-exch-01.4imprint.com'),
  ('b364981d-28c3-4ecc-b735-3c95df21145c'::uuid, ' | 2026-11-25 3:55 am CT: sent copy of the request on file.', 'CO6P220MB0338865EEDFDA651A3305FABD7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM'),
  ('845df475-8d46-4800-bfec-55eb54cae276'::uuid, ' | 2026-11-24 2:08 am CT: non-delivery report on file.', 'fb8614cc-03b6-4ae3-af9f-f52ff605d539@LV3P220MB1756.NAMP220.PROD.OUTLOOK.COM'),
  ('dc89e16f-2331-437b-b4dd-66a54ca834c5'::uuid, ' | 2026-11-04 1:13 pm CT: Stephen forwarded John Floeter''s Nov 4 reply and the MPTF restrictions attachment to the team. No status change.', 'PH0P220MB0586F3B360877DE7E11D2428D7682@PH0P220MB0586.NAMP220.PROD.OUTLOOK.COM'),
  ('aaeff4a3-343e-4210-b538-78e14887d5fc'::uuid, ' | 2026-11-25 7:01 pm CT: Serato support satisfaction survey on ticket 1231468; no change.', 'M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com'),
  ('8af59eda-9283-44b1-b1e3-a3c6cc0516c1'::uuid, ' | 2026-11-23 2:25 am CT: Taproot Plus address-confirmation email; no change.', '8sbnuW02QPqRhG63jn9i4w@geopod-ismtpd-22'),
  ('de947322-dbc9-4af0-80b9-713f47fb844a'::uuid, ' | 2026-11-22 12:52 am CT: Gator mailing-list welcome email (marketing); no change to the request.', 'ae01541236e9e234619a4d804.4bdfae8d3d.20261122065205.7f3eb5284e.2eabfc80@mail36.suw11.mcdlv.net')
) as v(id, line, mid)
where g.id = v.id
  and position(v.mid in coalesce(g.notes,'')) = 0;

-- Introduction-only rows (parked Nov 18): history note only. Status, next step and dates unchanged.
update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n[2026-11-26] History: a second contact also replied to the intro-ask email (Oct 31, 10:43 pm CT): did not think they knew anyone off the top and would check with a couple of people; no later reply on file. The earlier note naming only Douglas Allen''s reply was incomplete. Row stays parked. [src:msgid-85B93916-72F0-4FA4-8B74-00B53C338EF9@icloud.com]',
  updated_at = now()
where left(id::text,8) in ('d5d14632','31207ffd','4e51335f','8ad13eb7','96209d1e','a8ecc1a3','e9c68126','182dccc7','2dc71648','fd59cd64','b64c37dc','8fc24504')
  and coalesce(notes,'') like '%[parked-intro-2026-11-18]%'
  and coalesce(notes,'') not like '%85B93916-72F0-4FA4-8B74-00B53C338EF9%';

update fs_grant_deadlines set
  next_step_due = date '2026-11-30',
  notes = coalesce(notes,'') || ' | 2026-11-26: thank-you due Nov 25 not evidenced as sent; moved to Nov 30 to match the partner row. [serato-due-2026-11-26]',
  updated_at = now()
where id = 'aaeff4a3-343e-4210-b538-78e14887d5fc' and status = 'awarded' and next_step_due = date '2026-11-25';

do $$
declare missing int;
begin
  select count(*) into missing
  from unnest(array[
    'DS2PR17MB2950417E6113D80AA4DD1F868D84432','6b06b1681931b_1011aae0831569','6b06fc39533f2_1011aae08420a5',
    '165FE057-4F28-447D-8B18-DC362DBC70F4','autogen-java-688be7ce-93c9-49ab-8bd2-00be3bc18ee8','712f6175-d9c3-4a40-aac7-e7ab77a35b38',
    'CO6P220MB0338865EEDFDA651A3305FABD7432','fb8614cc-03b6-4ae3-af9f-f52ff605d539','PH0P220MB0586F3B360877DE7E11D2428D7682',
    'M69PGZZEJ01_6b0784f139386','8sbnuW02QPqRhG63jn9i4w','ae01541236e9e234619a4d804.4bdfae8d3d'
  ]) as m(k)
  where not exists (select 1 from fs_grant_deadlines g where position(m.k in coalesce(g.notes,'')) > 0);
  if missing > 0 then raise exception 'grant email update incomplete: % Message-IDs missing', missing; end if;
  if (select count(*) from fs_grant_deadlines where coalesce(notes,'') like '%[oriental-reapply 2026-11-26]%') <> 1 then
    raise exception 'expected exactly one Oriental reapply row';
  end if;
  if (select count(*) from fs_grant_deadlines where coalesce(notes,'') like '%85B93916-72F0-4FA4-8B74-00B53C338EF9%') <> 12 then
    raise exception 'expected the Pearson history note on 12 intro rows';
  end if;
end $$;

commit;

select id, funder, program, status, decision_on, submitted_on, next_step_due, amount_requested, amount_awarded, right(notes, 160) as notes_tail
from fs_grant_deadlines
where id in ('8c21a12a-bf69-4a3d-abc4-728d916f34ee','d14f32bd-d2e1-483f-b2cc-ef800b3e7ac8','013d3944-c420-4534-b9af-7f3a604c0235',
  '4b24678c-8233-4cea-b4be-c029151e24e2','688e871d-3045-4895-a84b-1b67536a5fa2','b364981d-28c3-4ecc-b735-3c95df21145c',
  '845df475-8d46-4800-bfec-55eb54cae276','dc89e16f-2331-437b-b4dd-66a54ca834c5','aaeff4a3-343e-4210-b538-78e14887d5fc',
  '8af59eda-9283-44b1-b1e3-a3c6cc0516c1','de947322-dbc9-4af0-80b9-713f47fb844a')
   or coalesce(notes,'') like '%[oriental-reapply 2026-11-26]%'
   or coalesce(notes,'') like '%85B93916-72F0-4FA4-8B74-00B53C338EF9%'
order by funder;

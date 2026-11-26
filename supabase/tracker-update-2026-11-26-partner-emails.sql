-- Partner-side logging of BOB .eml files (manifests of Nov 26, 2026). Safe to re-run.
-- Grant rows are NOT touched here (grants-awards-steward). Replaces the partner part of the unapplied
-- supabase/tracker-update-2026-11-25-bob-emails.sql . New vendor/contact rows are kept in a private local script. Do not apply that older file afterwards.
begin;

-- 0. Expected-current-value check: each existing row is already updated by this script or still unchanged.
do $$
begin
  if not exists (select 1 from fs_partners where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and (position('TY7P286MB68828676494BB49D209CFA04EC422@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM' in coalesce(notes,''))>0 or (stage='in_conversation' and ball_with='them' and next_step_due='2026-12-07' and last_contact_at='2026-11-25 05:46:00+00'))) then
    raise exception 'AlphaTheta row changed since review; stop';
  end if;
  if not exists (select 1 from fs_partners where id='85a2975b-ae91-4f6f-b7d7-7dd14181c167' and (position('M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com' in coalesce(notes,''))>0 or (stage='confirmed' and ball_with='us' and next_step_due='2026-11-25' and date_trunc('second',last_contact_at)='2026-11-24 00:41:28+00'))) then
    raise exception 'Serato row changed since review; stop';
  end if;
  if not exists (select 1 from fs_partners where id='965d7d84-5464-4632-bac0-c97920af6468' and (position('6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail' in coalesce(notes,''))>0 or (stage='reached_out' and ball_with='them' and next_step_due='2026-12-28' and date_trunc('second',last_contact_at)='2026-11-25 10:00:00+00'))) then
    raise exception 'Oriental row changed since review; stop';
  end if;
end $$;

-- 1. AlphaTheta (private; no terms recorded)
update fs_partners set
  ball_with = 'us',
  last_contact_at = '2026-11-26 11:57:32+00',
  next_step = 'Private arrangement; see Stephen''s mailbox. We owe the next move on Israel Rodriguez''s Nov 26, 2026 reply. Proposed: short acknowledgment, draft only, threaded; send after Stephen says send. Owner proposed: Stephen Henry / Albert Harris.',
  next_step_due = '2026-11-30',
  notes = coalesce(notes,'') || E'\n' || '[2026-11-26] Private arrangement; see Stephen''s mailbox. Reply from Israel Rodriguez 5:57 am CT; we owe the next move. Our Nov 24 11:46 pm CT sent reply (already in activity) has Message-ID <CO6P220MB0338E7EABB9151F24D7874D5D7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. Previous next_step_due 2026-12-07. [src:msgid-CO6P220MB0338E7EABB9151F24D7874D5D7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM] [src:msgid-TY7P286MB68828676494BB49D209CFA04EC422@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM]' || ' Previous next_step: ' || coalesce(next_step,''),
  updated_at = now()
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and position('TY7P286MB68828676494BB49D209CFA04EC422@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM' in coalesce(notes,''))=0;

-- 2. Serato
update fs_partners set
  next_step = 'Check Outlook Sent Items for a thank-you to Brad D on ticket 1231468 (none found in the files reviewed). If not sent: draft the thank-you that also asks for the right Odyssey contact; send only after Stephen says send. Then activate Serato DJ Pro, confirm License Active, and set up the generic student profile per the signed Student Data Policy. Do not nudge about the software or the account name.',
  next_step_due = '2026-11-30',
  notes = coalesce(notes,'') || E'\n' || '[2026-11-25] Automated satisfaction survey on ticket 1231468 (7:01 pm CT). Previous next_step_due 2026-11-25. [src:msgid-M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com]' || ' Previous next_step: ' || coalesce(next_step,''),
  updated_at = now()
where id = '85a2975b-ae91-4f6f-b7d7-7dd14181c167' and position('M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com' in coalesce(notes,''))=0;

-- 3. Oriental Trading: not accommodated now, invited to reapply
update fs_partners set
  ball_with = 'us',
  last_contact_at = '2026-11-25 15:18:17+00',
  next_step = 'First check it has not already been refiled. Reapply at https://orientaltrading.requestitem.com/ with the address on the IRS determination letter (765 E 154th St, South Holland, IL 60473), same ask: craft materials for the May 18, 2027 DJ Lab Spring Showcase. Their system only; Stephen presses Submit.',
  next_step_due = '2026-11-27',
  notes = coalesce(notes,'') || E'\n' || '[2026-11-25] Request 5225976 not accommodated at this time (volume); they ask us to reapply with the 501(c)(3) address and say they will reconsider. Grant row d14f32bd-d2e1-483f-b2cc-ef800b3e7ac8. Receipt notice 3:59 am CT Message-ID <6b06b1681931b_1011aae0831569@ip-10-134-5-254.us-east-2.compute.internal.mail>. Previous next_step_due 2026-12-28. [src:msgid-6b06b1681931b_1011aae0831569@ip-10-134-5-254.us-east-2.compute.internal.mail] [src:msgid-6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail]' || ' Previous next_step: ' || coalesce(next_step,''),
  updated_at = now()
where id = '965d7d84-5464-4632-bac0-c97920af6468' and position('6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail' in coalesce(notes,''))=0;

-- 4. Message-IDs for events already in activity (no duplicate activity)
update fs_partners set email = 'info@creativechirx.org' where id = '52c3d068-9a72-4d8f-8aca-aa2dcc8d8616' and email is null;

update fs_partners set
  notes = coalesce(notes,'') || E'\n' || '[2026-11-25] Message-ID of our request email already in activity (3:55 am CT, to info@creativechirx.org). [src:msgid-CO6P220MB0338865EEDFDA651A3305FABD7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM]',
  updated_at = now()
where id = '52c3d068-9a72-4d8f-8aca-aa2dcc8d8616' and position('CO6P220MB0338865EEDFDA651A3305FABD7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM' in coalesce(notes,''))=0;

update fs_partners set
  notes = coalesce(notes,'') || E'\n' || '[2026-11-25] 4imprint confirmation email (3:42 am CT): application received, up to six weeks to process; they will email the applicant. Same event as the logged submission. [src:msgid-712f6175-d9c3-4a40-aac7-e7ab77a35b38@us-exch-01.4imprint.com]',
  updated_at = now()
where id = '6e38015f-cccf-4c25-bc91-34afaa27b5c3' and position('712f6175-d9c3-4a40-aac7-e7ab77a35b38@us-exch-01.4imprint.com' in coalesce(notes,''))=0;

update fs_partners set
  notes = coalesce(notes,'') || E'\n' || '[2026-11-21] Email Message-ID for the 11:29 pm CT reply to Isaac Jack already in activity (05:29 UTC Nov 22). [src:msgid-010001a201bafe2e-784b1082-d91f-4520-bace-9fa7ab1a5937-000000@email.amazonses.com]',
  updated_at = now()
where id = 'b8d73772-58e8-43bd-9aec-749502f8d76d' and position('010001a201bafe2e-784b1082-d91f-4520-bace-9fa7ab1a5937-000000@email.amazonses.com' in coalesce(notes,''))=0;

update fs_partner_activity set summary = summary || ' [src:msgid-010001a201bafe2e-784b1082-d91f-4520-bace-9fa7ab1a5937-000000@email.amazonses.com]'
where id = (select id from fs_partner_activity where partner_id = 'b8d73772-58e8-43bd-9aec-749502f8d76d' and date_trunc('minute', created_at) = '2026-11-22 05:29+00' order by created_at limit 1)
  and not exists (select 1 from fs_partner_activity where position('010001a201bafe2e-784b1082-d91f-4520-bace-9fa7ab1a5937-000000@email.amazonses.com' in summary) > 0);
update fs_partner_activity set summary = summary || ' [src:msgid-CO6P220MB0338E7EABB9151F24D7874D5D7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM]'
where id = (select id from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and date_trunc('minute', created_at) = '2026-11-25 05:46+00' order by created_at limit 1)
  and not exists (select 1 from fs_partner_activity where position('CO6P220MB0338E7EABB9151F24D7874D5D7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM' in summary) > 0);

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select v.pid::uuid, 'email', v.summary || ' Message-ID <' || v.mid || '>. [src:msgid-' || v.mid || ']', v.stage_after, 'stephen@selassiefest.com', 'Claude', v.at::timestamptz
from (values
 ('a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'in_conversation', '2026-11-26 11:57:32+00', 'TY7P286MB68828676494BB49D209CFA04EC422@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM', 'Nov 26, 2026 5:57 am CT: email from Israel Rodriguez (AlphaTheta). Private arrangement; see Stephen''s mailbox. We owe the next move.'),
 ('85a2975b-ae91-4f6f-b7d7-7dd14181c167', 'confirmed', '2026-11-26 01:01:37+00', 'M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com', 'Nov 25, 2026 7:01 pm CT: automated Serato satisfaction survey on ticket 1231468. No new decision, value or term.'),
 ('965d7d84-5464-4632-bac0-c97920af6468', 'reached_out', '2026-11-25 15:18:17+00', '6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail', 'Nov 25, 2026 9:18 am CT: Oriental Trading answered request 5225976: cannot accommodate at this time (volume); asks us to reapply with the address on our 501(c)(3) form and will reconsider.')
) as v(pid, stage_after, at, mid, summary)
where exists (select 1 from fs_partners p where p.id = v.pid::uuid)
  and not exists (select 1 from fs_partner_activity a where position(v.mid in coalesce(a.summary,'')) > 0);

do $$
begin
  if exists (select 1 from unnest(array['TY7P286MB68828676494BB49D209CFA04EC422@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM','M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com','6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail']) m where (select count(*) from fs_partner_activity a where position(m in a.summary) > 0) <> 1) then
    raise exception 'each Message-ID must have exactly one activity';
  end if;
end $$;

commit;

select p.name, p.stage, p.ball_with, p.next_step_due, p.last_contact_at, count(*) as logged
from unnest(array['TY7P286MB68828676494BB49D209CFA04EC422@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM','M69PGZZEJ01_6b0784f139386_dd7e572ebcfe18_sprut@zendesk.com','6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail']) m join fs_partner_activity a on position(m in a.summary) > 0 join fs_partners p on p.id = a.partner_id
group by 1,2,3,4,5 order by 1;

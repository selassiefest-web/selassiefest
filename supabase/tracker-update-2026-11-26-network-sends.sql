-- Five sends Thu Nov 26, 2026 (America/Chicago) from stephen@selassiefest.com, seen in Outlook Sent Items,
-- plus two skipped contacts (Giving Others Dreams, Pep Rally Takeover). Safe to re-run.
-- action_kind is generated and is never set. fs_grant_deadlines is not touched.
begin;
do $$
declare n int;
begin
  perform 1 from fs_partners where id in ('e70c5296-b1d8-4fa3-a495-623da08c1f45','04e100af-72c7-43a7-9222-c7bd72a36aa7','1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701','3d4e5f60-7182-4c93-adb4-c5e6f7a8b923','5f607182-93a4-4eb5-8cd6-e7a8b9cadb45','2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812','4e5f6071-8293-4da4-bec5-d6f7a8b9ca34') for update;

  -- umn
  if not exists (select 1 from fs_partners where id = 'e70c5296-b1d8-4fa3-a495-623da08c1f45' and position('[sent-umn 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      email = 'info@urbanmalenetwork.org',
      contacts = '[{"name": "Urban Male Network public inbox", "role": "Verified Nov 25, 2026 on https://www.urbanmalenetwork.org/contact (the page also has a web form)", "email": "info@urbanmalenetwork.org"}]'::jsonb,
      website = 'https://www.urbanmalenetwork.org/',
      last_contact_at = timestamptz '2026-11-26 13:45:00-06',
      next_step = 'Intro SENT Thu Nov 26, 2026 1:45 PM CT to info@urbanmalenetwork.org (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-umn 2026-11-26] Intro sent Nov 26, 2026 1:45 PM CT to info@urbanmalenetwork.org (seen in Outlook Sent Items). Delivery not confirmed; no reply logged. This supersedes the earlier "no contact or site found / do not contact until verified" text: site and public inbox verified Nov 25, 2026 at https://www.urbanmalenetwork.org/contact. The claimed 2025 Safe Spaces role and any 2027 role remain UNVERIFIED (not mentioned in the email). Corey Turner (research) is not on that page.',
      updated_at = now()
    where id = 'e70c5296-b1d8-4fa3-a495-623da08c1f45'
      and stage = 'not_contacted'
      and ball_with = 'us'
      and email is null
      and contacts = '[]'::jsonb
      and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = 'f24fe0106a5ba4835ce6d8c8cb20659b'
      and website is null;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'umn row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select 'e70c5296-b1d8-4fa3-a495-623da08c1f45', 'email', 'Nov 26, 2026 1:45 PM CT: Stephen sent from stephen@selassiefest.com to info@urbanmalenetwork.org, subject "A free DJ class for South Side youth: 15 minutes by video?". Introduced Ras Tafari Inc. and the free Rainbow DJ Lab opening Jan 12, 2027, and asked for a 15-minute video call to learn how Urban Male Network reaches young people in South Shore and Greater Grand Crossing and whether an introduction makes sense. No funding asked. Seen in Outlook Sent Items; Message-ID not captured. [src:sent-umn-2026-11-26]',
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:45:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = 'e70c5296-b1d8-4fa3-a495-623da08c1f45' and position('[src:sent-umn-2026-11-26]' in coalesce(summary,'')) > 0);

  -- claretian
  if not exists (select 1 from fs_partners where id = '04e100af-72c7-43a7-9222-c7bd72a36aa7' and position('[sent-claretian 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      email = 'angelah@claretianassociates.org',
      contacts = '[{"name": "Angela Hurlock", "role": "Executive Director / CEO", "email": "angelah@claretianassociates.org"}, {"name": "Tiarra Owens", "role": "Program Manager, ext. 2030. Address listed on https://www.claretianassociates.org/claretian-staff.html (read Nov 25, 2026); not emailed Nov 26; backup if the CEO address bounces", "email": "tiarrao@claretianassociates.org"}]'::jsonb,
      last_contact_at = timestamptz '2026-11-26 13:50:00-06',
      next_step = 'Intro SENT Thu Nov 26, 2026 1:50 PM CT to angelah@claretianassociates.org (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-claretian 2026-11-26] Intro sent Nov 26, 2026 1:50 PM CT to angelah@claretianassociates.org (seen in Outlook Sent Items). Delivery not confirmed; no reply logged. Unparked: a verified email was found on https://www.claretianassociates.org/claretian-staff.html, which meets the Nov 19 reactivation condition. The Oct 11 "Emailed" activity is preserved.',
      updated_at = now()
    where id = '04e100af-72c7-43a7-9222-c7bd72a36aa7'
      and stage = 'reached_out'
      and ball_with = 'parked'
      and email is null
      and md5(contacts::text) = 'c083fd1a4a032a053d6c5f71ca742578'
      and last_contact_at = timestamptz '2026-10-11 17:48:24.502179+00'
      and next_step_due is null
      and md5(next_step) = '81ef03347312b74a79077ce33ced69bd';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'claretian row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select '04e100af-72c7-43a7-9222-c7bd72a36aa7', 'email', 'Nov 26, 2026 1:50 PM CT: Stephen sent from stephen@selassiefest.com to angelah@claretianassociates.org, subject "A free DJ class for South Chicago youth: 15 minutes by video?". Greeting "Dear Angela Hurlock". Introduced the free Rainbow DJ Lab opening Jan 12, 2027, and asked for a 15-minute video call (with Angela Hurlock or someone Angela Hurlock names) on how South Chicago youth reach programs like this and possible introductions to families and partners. The draft line about an October email was removed before sending. No funding asked. Seen in Outlook Sent Items; Message-ID not captured. [src:sent-claretian-2026-11-26]',
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:50:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = '04e100af-72c7-43a7-9222-c7bd72a36aa7' and position('[src:sent-claretian-2026-11-26]' in coalesce(summary,'')) > 0);

  -- phalanx
  if not exists (select 1 from fs_partners where id = '1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701' and position('[sent-phalanx 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      email = 'info@phalanxgrpservices.org',
      contacts = '[{"name": "Phalanx Family Services public inbox", "role": "Taken from the mailto target of the contact form on https://www.phalanxgrpservices.org/#contact; delivery not confirmed", "email": "info@phalanxgrpservices.org", "phone": "(773) 291-1086 (shown on the site; record only, online outreach)"}]'::jsonb,
      last_contact_at = timestamptz '2026-11-26 13:53:00-06',
      next_step = 'Intro SENT Thu Nov 26, 2026 1:53 PM CT to info@phalanxgrpservices.org (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-phalanx 2026-11-26] Intro sent Nov 26, 2026 1:53 PM CT to info@phalanxgrpservices.org (seen in Outlook Sent Items). Delivery not confirmed; no reply logged. This supersedes the earlier "no email could be read" text: address taken from the mailto target of their own site contact form. Any role in our work remains unverified.',
      updated_at = now()
    where id = '1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701'
      and stage = 'not_contacted'
      and ball_with = 'us'
      and email is null
      and contacts = '[]'::jsonb
      and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = '6abb2363b4d2dbe0d558b8ac37d7065e';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'phalanx row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select '1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701', 'email', 'Nov 26, 2026 1:53 PM CT: Stephen sent from stephen@selassiefest.com to info@phalanxgrpservices.org, subject "A free DJ class for Far South Side youth: 15 minutes by video?". Introduced the free Rainbow DJ Lab opening Jan 12, 2027, and asked for a 15-minute video call to learn how the families Phalanx serves could join. Sent as email to the address behind their web form. No funding asked. Seen in Outlook Sent Items; Message-ID not captured. [src:sent-phalanx-2026-11-26]',
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:53:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = '1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701' and position('[src:sent-phalanx-2026-11-26]' in coalesce(summary,'')) > 0);

  -- shineon
  if not exists (select 1 from fs_partners where id = '3d4e5f60-7182-4c93-adb4-c5e6f7a8b923' and position('[sent-shineon 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      email = 'jim@shineonchicago.com',
      contacts = '[{"name": "Jim Kropp", "role": "Program Director; verified Nov 25, 2026 on https://www.shineonchicago.com/index.html", "email": "jim@shineonchicago.com"}]'::jsonb,
      website = 'https://www.shineonchicago.com/',
      last_contact_at = timestamptz '2026-11-26 13:56:00-06',
      next_step = 'Intro SENT Thu Nov 26, 2026 1:56 PM CT to jim@shineonchicago.com (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-shineon 2026-11-26] Intro sent Nov 26, 2026 1:56 PM CT to jim@shineonchicago.com (seen in Outlook Sent Items). Delivery not confirmed; no reply logged. This supersedes the earlier "no site or contact found" text: the site is shineonchicago.com (the .org checked before is wrong). Any 2027 role remains unverified.',
      updated_at = now()
    where id = '3d4e5f60-7182-4c93-adb4-c5e6f7a8b923'
      and stage = 'not_contacted'
      and ball_with = 'us'
      and email is null
      and contacts = '[]'::jsonb
      and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = 'f5f9034db41c3f1ea3764437ad27958f'
      and website is null;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'shineon row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select '3d4e5f60-7182-4c93-adb4-c5e6f7a8b923', 'email', 'Nov 26, 2026 1:56 PM CT: Stephen sent from stephen@selassiefest.com to jim@shineonchicago.com, subject "Teen media makers and a free summer music series: 15 minutes by video?". Greeting "Dear Jim Kropp". Introduced the free Rainbow DJ Lab opening Jan 12, 2027, and asked for a 15-minute video call on how the program works with teens and whether its students might one day photograph and film the Rainbow Wednesdays summer nights. No pay, funding or commitment offered or asked. Seen in Outlook Sent Items; Message-ID not captured. [src:sent-shineon-2026-11-26]',
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:56:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = '3d4e5f60-7182-4c93-adb4-c5e6f7a8b923' and position('[src:sent-shineon-2026-11-26]' in coalesce(summary,'')) > 0);

  -- johnwalt
  if not exists (select 1 from fs_partners where id = '5f607182-93a4-4eb5-8cd6-e7a8b9cadb45' and position('[sent-johnwalt 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      email = 'nachellep@johnwaltfoundation.org',
      contacts = '[{"name": "John Walt Foundation contact email (no person named on the page)", "role": "Verified Nov 25, 2026: email link on https://www.johnwaltfoundation.org/contact", "email": "nachellep@johnwaltfoundation.org"}]'::jsonb,
      website = 'https://www.johnwaltfoundation.org/',
      last_contact_at = timestamptz '2026-11-26 13:58:00-06',
      next_step = 'Intro SENT Thu Nov 26, 2026 1:58 PM CT to nachellep@johnwaltfoundation.org (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen. Also on Dec 2, check the foundation page for a 2027 scholarship opening (grant row stays not_eligible).',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-johnwalt 2026-11-26] Intro sent Nov 26, 2026 1:58 PM CT to nachellep@johnwaltfoundation.org (seen in Outlook Sent Items). Delivery not confirmed; no reply logged. This supersedes "no contact on file" and "no outreach" for this relationship contact only. Grant row 02aef656-e5dd-4292-9305-53f85e0af9a7 stays not_eligible and is unchanged.',
      updated_at = now()
    where id = '5f607182-93a4-4eb5-8cd6-e7a8b9cadb45'
      and stage = 'not_contacted'
      and ball_with = 'us'
      and email is null
      and contacts = '[]'::jsonb
      and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = '8bd2d1d6ac68dc564949d8371c5bdd19'
      and website is null;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'johnwalt row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select '5f607182-93a4-4eb5-8cd6-e7a8b9cadb45', 'email', 'Nov 26, 2026 1:58 PM CT: Stephen sent from stephen@selassiefest.com to nachellep@johnwaltfoundation.org, subject "Young musicians on the South Side: 15 minutes by video?". Greeted the foundation team, introduced the free Rainbow DJ Lab opening Jan 12, 2027, and asked whether someone has 15 minutes for a video call to share lessons from running workshops and apprenticeships for young musicians. No funding asked. Seen in Outlook Sent Items; Message-ID not captured. [src:sent-johnwalt-2026-11-26]',
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:58:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = '5f607182-93a4-4eb5-8cd6-e7a8b9cadb45' and position('[src:sent-johnwalt-2026-11-26]' in coalesce(summary,'')) > 0);

  -- god (skipped)
  if not exists (select 1 from fs_partners where id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812' and position('[skip-god 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      website = 'https://www.givingothersdreams.online/',
      next_step = 'Not contacted Nov 26, 2026: Stephen skipped the Instagram message (no Instagram login in Chrome). No message went out. On Wed Dec 2, 2026, check for a usable online route. Owner: Stephen.',
      notes = coalesce(notes,'') || E'
' || '[skip-god 2026-11-26] Not contacted. No email found; the drafted Instagram message was skipped because there is no Instagram login in Chrome (Stephen: skip) (Nov 26, 2026). Found Nov 25, 2026: official site https://www.givingothersdreams.online/ (the .org checked before is wrong), Instagram https://www.instagram.com/g.o.d.givingothersdreams/ linked from https://www.givingothersdreams.online/partner, also X @Giving_Dreams and Facebook; no email on the page; phone 773.437.4157 and 8920 S. Commercial Ave. shown (record only). This supersedes the earlier "no site found" text; what the organization does and any 2027 role remain unverified.',
      updated_at = now()
    where id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812'
      and stage = 'not_contacted'
      and ball_with = 'us'
      and email is null
      and website is null
      and contacts = '[]'::jsonb
      and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = 'd5c8a55673940d7876a6af36635cbe68';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'god row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  select '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812', 'note', 'Nov 26, 2026: not contacted. Instagram message skipped (no Instagram login in Chrome); Stephen said skip. No message was sent. [src:skip-god-2026-11-26]', 'not_contacted', 'stephen@selassiefest.com', 'Claude'
  where not exists (select 1 from fs_partner_activity where partner_id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812' and position('[src:skip-god-2026-11-26]' in coalesce(summary,'')) > 0);

  -- peprally (skipped)
  if not exists (select 1 from fs_partners where id = '4e5f6071-8293-4da4-bec5-d6f7a8b9ca34' and position('[skip-peprally 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      website = 'https://peprallytakeover.org/',
      next_step = 'Not contacted Nov 26, 2026: Stephen skipped the Instagram message (no Instagram login in Chrome). No message went out. On Wed Dec 2, 2026, check for a usable online route. Owner: Stephen.',
      notes = coalesce(notes,'') || E'
' || '[skip-peprally 2026-11-26] Not contacted. No email found; the drafted Instagram message was skipped because there is no Instagram login in Chrome (Stephen: skip) (Nov 26, 2026). Found Nov 25, 2026: official site https://peprallytakeover.org/ (the spelling checked before was wrong), Instagram https://www.instagram.com/peprallytakeover/ linked from it; no email on the page. This supersedes the earlier "no site found" text; what the organization does and any 2027 role remain unverified.',
      updated_at = now()
    where id = '4e5f6071-8293-4da4-bec5-d6f7a8b9ca34'
      and stage = 'not_contacted'
      and ball_with = 'us'
      and email is null
      and website is null
      and contacts = '[]'::jsonb
      and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = 'df4b9c3a4bdf84ff8315069bf37c5f09';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'peprally row changed since review (updated % rows); nothing applied', n; end if;
  end if;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  select '4e5f6071-8293-4da4-bec5-d6f7a8b9ca34', 'note', 'Nov 26, 2026: not contacted. Instagram message skipped (no Instagram login in Chrome); Stephen said skip. No message was sent. [src:skip-peprally-2026-11-26]', 'not_contacted', 'stephen@selassiefest.com', 'Claude'
  where not exists (select 1 from fs_partner_activity where partner_id = '4e5f6071-8293-4da4-bec5-d6f7a8b9ca34' and position('[src:skip-peprally-2026-11-26]' in coalesce(summary,'')) > 0);

  select count(*) into n from fs_partner_activity a
  join (values ('e70c5296-b1d8-4fa3-a495-623da08c1f45'::uuid, '[src:sent-umn-2026-11-26]'),
  ('04e100af-72c7-43a7-9222-c7bd72a36aa7'::uuid, '[src:sent-claretian-2026-11-26]'),
  ('1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701'::uuid, '[src:sent-phalanx-2026-11-26]'),
  ('3d4e5f60-7182-4c93-adb4-c5e6f7a8b923'::uuid, '[src:sent-shineon-2026-11-26]'),
  ('5f607182-93a4-4eb5-8cd6-e7a8b9cadb45'::uuid, '[src:sent-johnwalt-2026-11-26]'),
  ('2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812'::uuid, '[src:skip-god-2026-11-26]'),
  ('4e5f6071-8293-4da4-bec5-d6f7a8b9ca34'::uuid, '[src:skip-peprally-2026-11-26]')) v(id, tag)
    on a.partner_id = v.id and position(v.tag in coalesce(a.summary,'')) > 0;
  if n <> 7 then raise exception 'expected 7 activity rows, found %', n; end if;
end $$;
commit;

select p.name, p.id, p.stage, p.ball_with, p.email, p.website, p.last_contact_at, p.next_step_due, p.next_step, p.contacts,
  a.kind, a.created_at as activity_at,
  (select count(*) from fs_partner_activity x where x.partner_id = v.id and position(v.tag in coalesce(x.summary,'')) > 0) as tagged_activity_rows
from (values ('e70c5296-b1d8-4fa3-a495-623da08c1f45'::uuid, '[src:sent-umn-2026-11-26]'),
  ('04e100af-72c7-43a7-9222-c7bd72a36aa7'::uuid, '[src:sent-claretian-2026-11-26]'),
  ('1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701'::uuid, '[src:sent-phalanx-2026-11-26]'),
  ('3d4e5f60-7182-4c93-adb4-c5e6f7a8b923'::uuid, '[src:sent-shineon-2026-11-26]'),
  ('5f607182-93a4-4eb5-8cd6-e7a8b9cadb45'::uuid, '[src:sent-johnwalt-2026-11-26]'),
  ('2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812'::uuid, '[src:skip-god-2026-11-26]'),
  ('4e5f6071-8293-4da4-bec5-d6f7a8b9ca34'::uuid, '[src:skip-peprally-2026-11-26]')) v(id, tag)
join fs_partners p on p.id = v.id
left join fs_partner_activity a on a.partner_id = v.id and position(v.tag in coalesce(a.summary,'')) > 0
order by a.kind, a.created_at, p.name;

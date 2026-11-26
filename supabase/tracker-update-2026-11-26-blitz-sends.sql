-- Blitz entries Thu Nov 26, 2026 (America/Chicago): SENT-LOG rows 5, 19, 24, 25, 26, 27, 28, 30, 34, 36b, 37.
-- Prepared by partner-records-steward; reviewer first, then main session applies. Safe to re-run
-- (keyed on [sent-...] note markers and [src:...-2026-11-26-r] activity tags). No Message-IDs captured.
-- action_kind is generated and is never set.
begin;
do $$
declare n int;
begin
  perform 1 from fs_partners where id in ('2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812', '13beae8d-e799-4e25-8a3a-6b8c920e3856', '79667949-af89-40e9-afaf-7cd1bc6e4152', '6cb8eeb2-3293-4b4a-85c6-b70ca7781eef', 'd6490169-57b0-48c8-a796-cc00f963507d', 'baaca774-111c-40d5-a0cb-0af242c6018b', 'e78be2ab-7724-46e8-8828-48f72e20be6b', 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34') for update;
  perform 1 from fs_grant_deadlines where id in ('a094cf08-e53d-4f91-bb3a-317a182408fd', '84dbf68e-238e-4553-b27a-942e0add164d', 'b9fef37b-1920-43bd-a18a-048e2841cf50', 'e51fa940-be24-47ba-9b5c-e1304830f8b8') for update;

  -- row 19 Giving Others Dreams: stop if another session already logged this send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812' and position('reachus@givingothersdreams.info' in lower(coalesce(summary,''))) > 0
      and position('Nov 26, 2026' in summary) > 0 and position('-2026-11-26-r]' in summary) = 0) then
    raise exception 'row 19 Giving Others Dreams: a Nov 26 activity naming this address already exists; nothing applied';
  end if;
  -- row 19 Giving Others Dreams
  if not exists (select 1 from fs_partners where id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812' and position('[sent-god 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:12:00-06',
      next_step = 'Intro SENT Thu Nov 26, 2026 2:12 PM CT to reachus@givingothersdreams.info (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      email = 'reachus@givingothersdreams.info',
      contacts = '[{"name": "Ms. Colón (as greeted; first name and role not recorded)", "email": "reachus@givingothersdreams.info", "role": "Inbox used for the Nov 26, 2026 send; labeled their own Linktree contact in the outreach preview file; not independently re-checked, delivery not confirmed"}, {"name": "Backup address (not used)", "email": "[unverified backup address withheld]", "role": "Unverified backup listed in the outreach preview file; not emailed"}]'::jsonb,
      notes = coalesce(notes,'') || E'
' || '[sent-god 2026-11-26] Email to reachus@givingothersdreams.info (cc stephen@selassiefest.com) seen in Outlook Sent Items, Nov 26, 2026 2:12 PM CT. This supersedes the [skip-god 2026-11-26] note and its "Not contacted" next step, and the earlier "no email found" text. The send was not set up by the session that kept the send log. The address is on a .info domain; the website on file is .online; the outreach preview file email-19-giving-others-dreams-PREVIEW.html labels it their own Linktree contact (not independently re-checked); backup [unverified backup address withheld] is unverified and was not emailed. No reply logged.',
      updated_at = now()
    where id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812' and updated_at = timestamptz '2026-11-26T20:10:51.518403+00:00'
      and stage is not distinct from 'not_contacted'
      and ball_with is not distinct from 'us'
      and next_step is not distinct from 'Not contacted Nov 26, 2026: Stephen skipped the Instagram message (no Instagram login in Chrome). No message went out. On Wed Dec 2, 2026, check for a usable online route. Owner: Stephen.'
      and next_step_due is not distinct from '2026-12-02';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 19 Giving Others Dreams changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812' and position('[src:sent-god-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812', 'email', 'Nov 26, 2026 2:12 PM CT: email from stephen@selassiefest.com to reachus@givingothersdreams.info (cc stephen@selassiefest.com), greeting "Dear Ms. Colón", subject "A free DJ class for South Side youth: 15 minutes by video?", asking for a 15-minute video call. Seen in Outlook Sent Items. Supersedes the earlier Nov 26 "not contacted" note. Message-ID not captured. [src:sent-god-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:12:00-06');
  end if;
  -- row 24 James R. Jordan Club (proposed new row)
  if exists (select 1 from fs_partners where id <> '6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24' and (lower(name) = lower('Boys & Girls Clubs of Chicago: James R. Jordan Club') or lower(coalesce(email,'')) = 'wedmondson@bgcc.org' or position('wedmondson@bgcc.org' in lower(contacts::text)) > 0)) then
    raise exception 'row 24 James R. Jordan Club: a matching partner row already exists under another id; nothing applied';
  end if;
  if not exists (select 1 from fs_partners where id = '6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24') then
    insert into fs_partners (id, name, category, address, phone, email, website, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, last_contact_at, source, notes)
    values ('6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24', 'Boys & Girls Clubs of Chicago: James R. Jordan Club', 'Youth program', '2102 W. Monroe St., Chicago, IL 60612', '312-226-2323', 'wedmondson@bgcc.org', 'https://bgcc.org/jordan-club/', '[{"name": "Will Edmondson", "role": "Club Director (outreach drafting check of https://bgcc.org/jordan-club/, Nov 25, 2026)", "email": "wedmondson@bgcc.org"}]'::jsonb,
      array['programming'], array['classes'], 'reached_out', 'them', 'A short video conversation about their teens and a free DJ class.', 'Intro SENT Thu Nov 26, 2026 2:00 PM CT to wedmondson@bgcc.org. WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.', date '2026-12-02', timestamptz '2026-11-26 14:00:00-06', 'Stephen hyperfocus list item 10 (Boys & Girls Club), Nov 25, 2026', '[sent-jrjordan 2026-11-26] West Side club behind the Keystone Teen Party video Khari Humphries shared; not in South Shore. Phone is record only (online outreach). Sent Nov 26, 2026 2:00 PM CT; unverified 2003 / 2027-event lines and the pilot-workshop offer were removed before sending. No reply logged.');
  elsif not exists (select 1 from fs_partners where id = '6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24' and position('[sent-jrjordan 2026-11-26]' in coalesce(notes,'')) > 0) then
    raise exception 'row 24 James R. Jordan Club: proposed id is in use by an unexpected row; nothing applied';
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = '6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24' and position('[src:sent-jrjordan-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24', 'email', 'Nov 26, 2026 2:00 PM CT: Stephen sent from stephen@selassiefest.com to wedmondson@bgcc.org, subject "A free DJ class for teens, after your club''s Keystone Teen Party video". Per the send log, the unverified 2003 / 2027-event lines and the pilot-workshop offer were removed. Recorded as sent in the send log. Message-ID not captured. [src:sent-jrjordan-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:00:00-06');
  end if;
  -- row 25 BGCC central (proposed new row)
  if exists (select 1 from fs_partners where id <> '7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025' and (lower(name) = lower('Boys & Girls Clubs of Chicago (central office)') or lower(coalesce(email,'')) = 'info@bgcc.org' or position('info@bgcc.org' in lower(contacts::text)) > 0)) then
    raise exception 'row 25 BGCC central: a matching partner row already exists under another id; nothing applied';
  end if;
  if not exists (select 1 from fs_partners where id = '7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025') then
    insert into fs_partners (id, name, category, address, phone, email, website, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, last_contact_at, source, notes)
    values ('7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025', 'Boys & Girls Clubs of Chicago (central office)', 'Youth program', null, null, 'info@bgcc.org', 'https://bgcc.org/contact-us/', '[{"name": "Boys & Girls Clubs of Chicago public inbox", "role": "Outreach drafting check of https://bgcc.org/contact-us/, Nov 25, 2026", "email": "info@bgcc.org"}]'::jsonb,
      array['programming'], array['classes'], 'reached_out', 'them', 'Is any club or school-based site serving South Shore or South Chicago, and who should we speak with?', 'Question SENT Thu Nov 26, 2026 2:02 PM CT to info@bgcc.org (is a club serving South Shore?). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.', date '2026-12-02', timestamptz '2026-11-26 14:02:00-06', 'Stephen hyperfocus list item 10 (Boys & Girls Club), Nov 25, 2026', '[sent-bgcc 2026-11-26] On Nov 25, 2026 https://bgcc.org/clubs/ listed nine clubs, none in South Shore. Related rows: James R. Jordan Club 6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24; LEARN South Chicago Club 13beae8d-e799-4e25-8a3a-6b8c920e3856. Sent Nov 26, 2026 2:02 PM CT (send log says it appears Stephen sent it); pilot-workshop offer removed. No reply logged.');
  elsif not exists (select 1 from fs_partners where id = '7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025' and position('[sent-bgcc 2026-11-26]' in coalesce(notes,'')) > 0) then
    raise exception 'row 25 BGCC central: proposed id is in use by an unexpected row; nothing applied';
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = '7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025' and position('[src:sent-bgcc-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025', 'email', 'Nov 26, 2026 2:02 PM CT: email from stephen@selassiefest.com to info@bgcc.org, subject "Is a Boys & Girls Club serving South Shore? A free DJ class nearby". Pilot-workshop offer removed. The send log says it appears to have been sent by Stephen. Message-ID not captured. [src:sent-bgcc-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:02:00-06');
  end if;
  -- row 26 LEARN South Chicago: stop if another session already logged this send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = '13beae8d-e799-4e25-8a3a-6b8c920e3856' and position('contactus@learncharter.org' in lower(coalesce(summary,''))) > 0
      and position('Nov 26, 2026' in summary) > 0 and position('-2026-11-26-r]' in summary) = 0) then
    raise exception 'row 26 LEARN South Chicago: a Nov 26 activity naming this address already exists; nothing applied';
  end if;
  -- row 26 LEARN South Chicago
  if not exists (select 1 from fs_partners where id = '13beae8d-e799-4e25-8a3a-6b8c920e3856' and position('[sent-learn 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:03:00-06',
      next_step = 'Email SENT Thu Nov 26, 2026 2:03 PM CT to contactus@learncharter.org, attention Cheron McMath (LEARN South Chicago). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      email = 'contactus@learncharter.org',
      contacts = '[{"name": "Cheron McMath (attention line)", "role": "Office Manager, LEARN South Chicago campus (Nov 25, 2026 research); address is the LEARN network inbox, not a personal one", "email": "contactus@learncharter.org"}]'::jsonb,
      notes = coalesce(notes,'') || E'
' || '[sent-learn 2026-11-26] Sent Nov 26, 2026 2:03 PM CT to the LEARN network inbox, attention Cheron McMath; pilot-workshop offer removed. The recipient is LEARN Charter (the school), not Boys & Girls Clubs; whether the school-based club still operates is unconfirmed. Central BGCC question tracked on row 7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025. No reply logged.',
      updated_at = now()
    where id = '13beae8d-e799-4e25-8a3a-6b8c920e3856' and updated_at = timestamptz '2026-10-12T19:45:50.570611+00:00'
      and stage is not distinct from 'not_contacted'
      and ball_with is not distinct from 'us'
      and next_step is not distinct from null
      and next_step_due is not distinct from null;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 26 LEARN South Chicago changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = '13beae8d-e799-4e25-8a3a-6b8c920e3856' and position('[src:sent-learn-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('13beae8d-e799-4e25-8a3a-6b8c920e3856', 'email', 'Nov 26, 2026 2:03 PM CT: Stephen sent from stephen@selassiefest.com to contactus@learncharter.org (attn Cheron McMath), subject "Attn Cheron McMath: a free DJ class for LEARN South Chicago students". Pilot-workshop offer removed. Recorded as sent in the send log. Message-ID not captured. [src:sent-learn-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:03:00-06');
  end if;
  -- row 27 Crown Center: stop if another session already logged this send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = '79667949-af89-40e9-afaf-7cd1bc6e4152' and position('thomasina.bolling@chicagoyouthcenters.org' in lower(coalesce(summary,''))) > 0
      and position('Nov 26, 2026' in summary) > 0 and position('-2026-11-26-r]' in summary) = 0) then
    raise exception 'row 27 Crown Center: a Nov 26 activity naming this address already exists; nothing applied';
  end if;
  -- row 27 Crown Center
  if not exists (select 1 from fs_partners where id = '79667949-af89-40e9-afaf-7cd1bc6e4152' and position('[sent-crown 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:05:00-06',
      next_step = 'Direct follow-up SENT Thu Nov 26, 2026 2:05 PM CT to thomasina.bolling@chicagoyouthcenters.org, cc lanise.reed@chicagoyouthcenters.org. WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-crown 2026-11-26] Sent Nov 26, 2026 2:05 PM CT to Thomasina Bolling, cc Lanise Reed; pilot-workshop offer removed. This is the nudge on the Oct 26 email to the general inbox. No reply logged.',
      updated_at = now()
    where id = '79667949-af89-40e9-afaf-7cd1bc6e4152' and updated_at = timestamptz '2026-11-20T23:57:18.579696+00:00'
      and stage is not distinct from 'reached_out'
      and ball_with is not distinct from 'them'
      and next_step is not distinct from 'Send one more short email nudge to info@chicagoyouthcenters.org (follow-up emailed Oct 26, no reply logged). Online only; the call step is parked.'
      and next_step_due is not distinct from '2026-11-30';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 27 Crown Center changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = '79667949-af89-40e9-afaf-7cd1bc6e4152' and position('[src:sent-crown-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('79667949-af89-40e9-afaf-7cd1bc6e4152', 'email', 'Nov 26, 2026 2:05 PM CT: Stephen sent from stephen@selassiefest.com to thomasina.bolling@chicagoyouthcenters.org, cc lanise.reed@chicagoyouthcenters.org, subject "A free DJ class for South Shore children, and your recording studio". Pilot-workshop offer removed. Recorded as sent in the send log. Message-ID not captured. [src:sent-crown-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:05:00-06');
  end if;
  -- row 28 Field Foundation: stop if another session already logged this send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = '6cb8eeb2-3293-4b4a-85c6-b70ca7781eef' and position('arts@fieldfoundation.org' in lower(coalesce(summary,''))) > 0
      and position('Nov 26, 2026' in summary) > 0 and position('-2026-11-26-r]' in summary) = 0) then
    raise exception 'row 28 Field Foundation: a Nov 26 activity naming this address already exists; nothing applied';
  end if;
  -- row 28 Field Foundation
  if not exists (select 1 from fs_partners where id = '6cb8eeb2-3293-4b4a-85c6-b70ca7781eef' and position('[sent-field 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:07:00-06',
      next_step = 'Follow-up SENT Thu Nov 26, 2026 2:07 PM CT to arts@fieldfoundation.org (spring 2027 A Road Together round; short video introduction). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-field 2026-11-26] Follow-up sent Nov 26, 2026 2:07 PM CT to arts@fieldfoundation.org. No reply logged.',
      updated_at = now()
    where id = '6cb8eeb2-3293-4b4a-85c6-b70ca7781eef' and updated_at = timestamptz '2026-11-20T23:57:18.579696+00:00'
      and stage is not distinct from 'reached_out'
      and ball_with is not distinct from 'them'
      and next_step is not distinct from 'Send one more short email nudge to arts@fieldfoundation.org (follow-up emailed Oct 26, no reply logged). Online only; the call step is parked.'
      and next_step_due is not distinct from '2026-11-24';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 28 Field Foundation changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = '6cb8eeb2-3293-4b4a-85c6-b70ca7781eef' and position('[src:sent-field-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('6cb8eeb2-3293-4b4a-85c6-b70ca7781eef', 'email', 'Nov 26, 2026 2:07 PM CT: Stephen sent from stephen@selassiefest.com to arts@fieldfoundation.org, subject "A Road Together: spring 2027 round and a short video introduction". Recorded as sent in the send log. Message-ID not captured. [src:sent-field-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:07:00-06');
  end if;
  -- row 28 Field grant note
  if not exists (select 1 from fs_grant_deadlines where id = 'a094cf08-e53d-4f91-bb3a-317a182408fd' and position('[sent-field 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      notes = coalesce(notes,'') || ' | ' || '[sent-field 2026-11-26] Nov 26, 2026 2:07 PM CT: follow-up sent to arts@fieldfoundation.org about the spring 2027 round and a short video introduction (partner row 6cb8eeb2-3293-4b4a-85c6-b70ca7781eef). No reply logged. Status and dates unchanged.',
      updated_at = now()
    where id = 'a094cf08-e53d-4f91-bb3a-317a182408fd' and updated_at = timestamptz '2026-10-31T18:59:37.401297+00:00'
      and status is not distinct from 'drafting'
      and next_step is not distinct from 'Paul sets the 2027 org budget (ART needs $25K-$1M); check Field for 2027 dates; core narrative in 06-chicago-fdn-open/05-field-foundation-art.md.'
      and next_step_due is not distinct from '2027-03-15';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 28 Field grant note changed since review (updated % rows); nothing applied', n; end if;
  end if;
  -- row 36b McCormick: stop if another session already logged this send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = 'd6490169-57b0-48c8-a796-cc00f963507d' and position('info@rrmf.org' in lower(coalesce(summary,''))) > 0
      and position('Nov 26, 2026' in summary) > 0 and position('-2026-11-26-r]' in summary) = 0) then
    raise exception 'row 36b McCormick: a Nov 26 activity naming this address already exists; nothing applied';
  end if;
  -- row 36b McCormick partner
  if not exists (select 1 from fs_partners where id = 'd6490169-57b0-48c8-a796-cc00f963507d' and position('[sent-rrmf 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:12:00-06',
      next_step = 'Bulls Community Assist Fund process question SENT Thu Nov 26, 2026 2:12 PM CT to info@rrmf.org. WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen. Thriving Communities stays invitation only and parked.',
      next_step_due = date '2026-12-02',
      email = 'info@rrmf.org',
      contacts = '[{"name": "McCormick Foundation public inbox", "role": "Marked verified in the Nov 25 outreach index; used for the Bulls Community Assist Fund question", "email": "info@rrmf.org"}]'::jsonb,
      notes = coalesce(notes,'') || E'
' || '[sent-rrmf 2026-11-26] First send 2:10 PM CT bounced (typo, info@rrmf.orgne); resent 2:12 PM CT to info@rrmf.org. This is a process question about the Chicago Bulls Community Assist Fund (grant row 84dbf68e-238e-4553-b27a-942e0add164d), not an application or a Thriving Communities inquiry. No reply logged.',
      updated_at = now()
    where id = 'd6490169-57b0-48c8-a796-cc00f963507d' and updated_at = timestamptz '2026-11-20T23:57:18.579696+00:00'
      and stage is not distinct from 'not_contacted'
      and ball_with is not distinct from 'us'
      and next_step is not distinct from 'Online research only: read the current Robert R. McCormick Foundation guidelines, find who runs arts or youth grants, and email the published program contact or use the inquiry form. No calls.'
      and next_step_due is not distinct from '2026-12-16';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 36b McCormick partner changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = 'd6490169-57b0-48c8-a796-cc00f963507d' and position('[src:bounce-rrmf-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('d6490169-57b0-48c8-a796-cc00f963507d', 'email', 'Nov 26, 2026 2:10 PM CT: send to info@rrmf.orgne (typo in address) bounced; not delivered. Bulls Community Assist Fund question. Message-ID not captured. [src:bounce-rrmf-2026-11-26-r]', 'not_contacted', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:10:00-06');
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = 'd6490169-57b0-48c8-a796-cc00f963507d' and position('[src:sent-rrmf-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('d6490169-57b0-48c8-a796-cc00f963507d', 'email', 'Nov 26, 2026 2:12 PM CT: resent from stephen@selassiefest.com to info@rrmf.org after the bounce: Chicago Bulls Community Assist Fund process question. Recorded as sent in the send log; subject not recorded there. Message-ID not captured. [src:sent-rrmf-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:12:00-06');
  end if;
  -- row 36b Bulls fund grant
  if not exists (select 1 from fs_grant_deadlines where id = '84dbf68e-238e-4553-b27a-942e0add164d' and position('[sent-rrmf 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      next_step = 'Process question SENT Thu Nov 26, 2026 2:12 PM CT to info@rrmf.org. WAIT for a reply; no application drafted. On Wed Dec 2, 2026, check the fund page for an application link and, if silent, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      owner = coalesce(owner,'Stephen'),
      notes = coalesce(notes,'') || ' | ' || '[sent-rrmf 2026-11-26] Nov 26, 2026: 2:10 PM CT send to info@rrmf.orgne bounced (typo); resent 2:12 PM CT to info@rrmf.org asking how an organization is considered. No application and no dollar request. Partner row d6490169-57b0-48c8-a796-cc00f963507d.',
      updated_at = now()
    where id = '84dbf68e-238e-4553-b27a-942e0add164d' and updated_at = timestamptz '2026-11-25T18:52:51.69293+00:00'
      and status is not distinct from 'to_research'
      and next_step is not distinct from 'Do not draft. Fit is a stretch (no basketball; social-emotional and career angle only). The page does not say it takes unsolicited proposals or is invitation only; we will not claim either. Check the page again for an application link by Dec 2.'
      and next_step_due is not distinct from '2026-12-02';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 36b Bulls fund grant changed since review (updated % rows); nothing applied', n; end if;
  end if;
  -- row 37 LISC: stop if another session already logged this send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = 'baaca774-111c-40d5-a0cb-0af242c6018b' and position('jarteaga@lisc.org' in lower(coalesce(summary,''))) > 0
      and position('Nov 26, 2026' in summary) > 0 and position('-2026-11-26-r]' in summary) = 0) then
    raise exception 'row 37 LISC: a Nov 26 activity naming this address already exists; nothing applied';
  end if;
  -- row 37 LISC
  if not exists (select 1 from fs_partners where id = 'baaca774-111c-40d5-a0cb-0af242c6018b' and position('[sent-lisc 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:15:00-06',
      next_step = 'Follow-up SENT Thu Nov 26, 2026 2:15 PM CT to JArteaga@lisc.org. WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'
' || '[sent-lisc 2026-11-26] Follow-up sent Nov 26, 2026 2:15 PM CT to JArteaga@lisc.org. The saved row 37 draft was addressed to LISC-Chicago@lisc.org with a different subject, so the draft text is not evidence of what was sent. LISC-Chicago@lisc.org is the published public inbox (verified Nov 25; not emailed). No reply logged.',
      updated_at = now()
    where id = 'baaca774-111c-40d5-a0cb-0af242c6018b' and updated_at = timestamptz '2026-11-20T23:57:18.579696+00:00'
      and stage is not distinct from 'reached_out'
      and ball_with is not distinct from 'them'
      and next_step is not distinct from 'Email Jaime Arteaga (JArteaga@lisc.org) one nudge; he was out until Nov 4 and no reply is logged. No call.'
      and next_step_due is not distinct from '2026-11-23';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 37 LISC changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = 'baaca774-111c-40d5-a0cb-0af242c6018b' and position('[src:sent-lisc-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('baaca774-111c-40d5-a0cb-0af242c6018b', 'email', 'Nov 26, 2026 2:15 PM CT: Stephen sent from stephen@selassiefest.com to JArteaga@lisc.org, subject "Following up: a free DJ class for South Shore children". Short follow-up to Jaime Arteaga citing the October email and asking for 15 minutes by video. Recorded as sent in the send log. Message-ID not captured. [src:sent-lisc-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:15:00-06');
  end if;
  -- row 5 MCMF partner account
  if not exists (select 1 from fs_partners where id = 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34' and position('[mcmf-account 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      next_step = 'Partner account request SUBMITTED Thu Nov 26, 2026 at https://partners.mychimyfuture.org. WATCH stephen@selassiefest.com for the My CHI. My Future. account email (check Tue Dec 1, 2026); also join the email list at https://cloud.citynews.chicago.gov/MCMF_email. Separately, WAIT for a reply to the 1:33 PM CT inbox email; if it bounces or is silent on Wed Dec 2, 2026, send the same question to dfss@cityofchicago.org (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-01',
      notes = coalesce(notes,'') || E'
' || '[mcmf-account 2026-11-26] Partner account request submitted Nov 26, 2026 (time not recorded) through the Airtable form (shrm4ReMH7s2u536o) behind https://partners.mychimyfuture.org: Stephen Henry, stephen@selassiefest.com, Ras Tafari Inc., selassiefest.com/full-spectrum/. Page said: "Thank you for submitting your organization! We will be in touch soon!" No account or email received yet. Calendar item mcmf-partner-account-2026-12-01 (Dec 1) now tracks the watch. No separate registration record exists.',
      updated_at = now()
    where id = 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34' and updated_at = timestamptz '2026-11-26T19:41:58.812531+00:00'
      and stage is not distinct from 'reached_out'
      and ball_with is not distinct from 'them'
      and next_step is not distinct from 'SENT Thu Nov 26, 2026 1:33 PM CT from stephen@selassiefest.com. WAIT for a reply from MyCHIMyFuture@cityofchicago.org. If it bounces, or is silent on Wed Dec 2, 2026, send the same question to dfss@cityofchicago.org (draft only; Stephen says send). Owner: Stephen.'
      and next_step_due is not distinct from '2026-12-02';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 5 MCMF partner account changed since review (updated % rows); nothing applied', n; end if;
  end if;
  if not exists (select 1 from fs_partner_activity where partner_id = 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34' and position('[src:mcmf-account-2026-11-26-r]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('d6fb4185-a0c7-4e92-9384-512c9f7b0e34', 'note', 'Nov 26, 2026 (time not recorded): My CHI. My Future. partner account request submitted at https://partners.mychimyfuture.org (Airtable form shrm4ReMH7s2u536o) with Stephen Henry, stephen@selassiefest.com, Ras Tafari Inc., selassiefest.com/full-spectrum/. Page confirmed: "Thank you for submitting your organization! We will be in touch soon!" Request only; no account granted yet. [src:mcmf-account-2026-11-26-r]', 'reached_out', 'stephen@selassiefest.com', 'Claude', now());
  end if;
  update rti_calendar_events set title = 'Watch for the My CHI. My Future. account email and join the MCMF email list',
      notes = coalesce(notes,'') || ' [account request submitted 2026-11-26; page confirmed]'
    where key = 'mcmf-partner-account-2026-12-01' and title = 'Request a My CHI. My Future. partner platform account and join the MCMF email list';
  -- row 34 PSPC grant
  if not exists (select 1 from fs_grant_deadlines where id = 'b9fef37b-1920-43bd-a18a-048e2841cf50' and position('[pspc-signup 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      next_step = 'News sign-up submitted Thu Nov 26, 2026 with stephen@selassiefest.com (page confirmed sent). Watch for the 2027 RFP; re-read https://safeandpeaceful.org/the-chicago-fund/ on Tue Dec 1, 2026. Do not draft an application until a 2027 RFP is posted. Owner: Stephen.',
      next_step_due = date '2026-12-01',
      owner = coalesce(owner,'Stephen'),
      notes = coalesce(notes,'') || ' | ' || '[pspc-signup 2026-11-26] Nov 26, 2026: news sign-up submitted with stephen@selassiefest.com; the page confirmed "sent" (time not recorded). Not an application. No 2027 round on file.',
      updated_at = now()
    where id = 'b9fef37b-1920-43bd-a18a-048e2841cf50' and updated_at = timestamptz '2026-11-25T18:52:51.69293+00:00'
      and status is not distinct from 'to_research'
      and next_step is not distinct from 'Watch for the 2027 RFP. Dec 1, 2026: sign up for the PSPC news list on https://safeandpeaceful.org/ (the page has a sign-up form) and re-read the Chicago Fund page. Do not draft an application until a 2027 RFP is posted. 2026 round for reference: RFP deadline Mar 2, 2026, awards May 1, checks May 14, activities by Oct 31, 2026, applications through the funder e-CImpact portal.'
      and next_step_due is not distinct from '2026-12-01';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'row 34 PSPC grant changed since review (updated % rows); nothing applied', n; end if;
  end if;
  update rti_calendar_events set notes = coalesce(notes,'') || ' [2026-11-26: Crown Center 79667949 already followed up Nov 26; next check Dec 2; do not resend from this alert]'
    where key = 'triage-followups-2026-11-30' and position('[2026-11-26: Crown Center' in coalesce(notes,'')) = 0;
  update rti_calendar_events set notes = coalesce(notes,'') || ' [2026-11-26: McCormick d6490169 emailed Nov 26; next check Dec 2; do not resend from this alert]'
    where key = 'triage-followups-2026-12-16' and position('[2026-11-26: McCormick' in coalesce(notes,'')) = 0;
  insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
  values ('blitz-followups-2026-12-02', 'Check replies to the Nov 26 outreach sends', timestamptz '2026-12-02 11:30:00-06', timestamptz '2026-12-02 11:45:00-06', 'Online (email)',
    'If silent, draft one nudge (draft only; Stephen says send). Partner rows 2c3d4e5f, 6a1f2c84, 7b2e3d95, 13beae8d, 79667949, 6cb8eeb2, d6490169, baaca774, e70c5296, 04e100af, 1b2c3d4e, 3d4e5f60, 5f607182, c5ea3074, ae2963a6.')
  on conflict (key) do nothing;
  update fs_grant_deadlines set notes = coalesce(notes,'') || ' | [pspc-signup 2026-11-26] Possible duplicate of grant row b9fef37b-1920-43bd-a18a-048e2841cf50; PSPC news sign-up submitted Nov 26 from that row (safeandpeaceful.org). Status, next step and date here unchanged.', updated_at = now()
    where id = '69e99742-64e5-4fa3-99b8-0fc1d2cb1400' and position('[pspc-signup 2026-11-26]' in coalesce(notes,'')) = 0;
  update rti_calendar_events set title = 'PSPC: re-check the Chicago Fund page for a 2027 RFP', notes = coalesce(notes,'') || ' [news sign-up done 2026-11-26]'
    where key = 'pspc-signup-2026-12-01' and title = 'PSPC: sign up for news and re-check the Chicago Fund page for a 2027 RFP';
  select count(*) into n from fs_partner_activity a
  join (values ('2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812'::uuid, '[src:sent-god-2026-11-26-r]'),
    ('6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24'::uuid, '[src:sent-jrjordan-2026-11-26-r]'),
    ('7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025'::uuid, '[src:sent-bgcc-2026-11-26-r]'),
    ('13beae8d-e799-4e25-8a3a-6b8c920e3856'::uuid, '[src:sent-learn-2026-11-26-r]'),
    ('79667949-af89-40e9-afaf-7cd1bc6e4152'::uuid, '[src:sent-crown-2026-11-26-r]'),
    ('6cb8eeb2-3293-4b4a-85c6-b70ca7781eef'::uuid, '[src:sent-field-2026-11-26-r]'),
    ('d6490169-57b0-48c8-a796-cc00f963507d'::uuid, '[src:bounce-rrmf-2026-11-26-r]'),
    ('d6490169-57b0-48c8-a796-cc00f963507d'::uuid, '[src:sent-rrmf-2026-11-26-r]'),
    ('baaca774-111c-40d5-a0cb-0af242c6018b'::uuid, '[src:sent-lisc-2026-11-26-r]'),
    ('d6fb4185-a0c7-4e92-9384-512c9f7b0e34'::uuid, '[src:mcmf-account-2026-11-26-r]')) v(id, tag) on a.partner_id = v.id and position(v.tag in coalesce(a.summary,'')) > 0;
  if n <> 10 then raise exception 'expected 10 activity rows, found %', n; end if;
end $$;
commit;

select 'partner' as record, p.id::text as id, p.name, p.stage as stage_or_status, p.ball_with, p.email, p.last_contact_at, p.next_step_due, p.next_step,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('-2026-11-26-r]' in coalesce(a.summary,'')) > 0) as new_activity_rows
from fs_partners p where p.id in ('13beae8d-e799-4e25-8a3a-6b8c920e3856', '2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812', '6a1f2c84-9d3b-4e57-8a20-5b7c1e9d4f24', '6cb8eeb2-3293-4b4a-85c6-b70ca7781eef', '79667949-af89-40e9-afaf-7cd1bc6e4152', '7b2e3d95-ae4c-4f68-9b31-6c8d2fae5025', 'baaca774-111c-40d5-a0cb-0af242c6018b', 'd6490169-57b0-48c8-a796-cc00f963507d', 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34', 'e78be2ab-7724-46e8-8828-48f72e20be6b')
union all
select 'grant', g.id::text, g.funder, g.status, null, null, null, g.next_step_due, g.next_step, null
from fs_grant_deadlines g where g.id in ('a094cf08-e53d-4f91-bb3a-317a182408fd', '84dbf68e-238e-4553-b27a-942e0add164d', 'b9fef37b-1920-43bd-a18a-048e2841cf50', 'e51fa940-be24-47ba-9b5c-e1304830f8b8')
union all
select 'calendar', c.id::text, c.title, case when c.active then 'active' else 'inactive' end, null, null, c.starts_at, null, c.key, null
from rti_calendar_events c where c.key in ('dadd-quiz-2026-12-02','jan11-followups-2027-01-11','pspc-signup-2026-12-01','mcmf-partner-account-2026-12-01','blitz-followups-2026-12-02','triage-followups-2026-11-30','triage-followups-2026-12-16')
order by 1, 3;

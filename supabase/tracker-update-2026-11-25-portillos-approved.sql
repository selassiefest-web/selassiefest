-- Portillo's For Good: fundraiser night APPROVED (email Nov 24, 2026 8:40 am CT). New partner row (none existed) plus companion grant row fc1eb971. Safe to re-run.
-- Source: C:\Users\mkepr\Downloads\BOB\__Your_Portillo's_fundraiser_night_was_approved!__.eml (Message-ID fragment TP0GRP006sVoln8NTM6XPS44mMQmoA, request reference PG -40918)
-- Calendar events portillos-night-2027-01-19 and portillos-prep-2027-01-12 already exist (grant row fc1eb971); this script does not touch rti_calendar_events.
begin;

insert into fs_partners (id, name, category, website, email, contacts, partner_types, program_parts, stage, ball_with, ask, commitment, next_step, next_step_due, source, notes, last_contact_at)
select 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37', 'Portillo''s (Portillo''s For Good fundraiser night)', 'Restaurant & food', 'https://www.portillos.com', 'fundraisers@portillos.com',
  '[{"name":"Laura","title":"Portillos Fundraising Team","email":"fundraisers@portillos.com"}]'::jsonb,
  array['financial'], array['classes'], 'committed', 'us',
  'A Portillo''s fundraiser night for Ras Tafari Inc.',
  'APPROVED Nov 24, 2026 (request reference PG -40918): fundraiser night Tue Jan 19, 2027, 5:00 to 8:00 PM at Portillo''s, 520 W. Taylor St., Chicago. Ras Tafari Inc. receives 20% back on orders from everyone who brings the flyer, shows it on a phone, mentions the organization before checkout, or places a pickup order with the digital code on the flyer. Rules: pickup orders only from that restaurant during the hours; gift cards, delivery and third-party apps excluded; catering counts; $200 minimum fundraising sales or no donation; cannot combine with other offer codes; no promotion or displays on the premises. Results email the next afternoon; check expected 30 to 45 days after the night. Dollar value unknown (earned proceeds, depends on turnout). Grant tracker row fc1eb971-3254-4fb5-b4e5-5a9b1766fd90 holds the same approval.',
  'Owner: not assigned. By Tue Dec 1, 2026: promote the night with the approved flyer (English; Spanish on request), never on Portillo''s premises. Flyer and FAQs saved at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\portillos\. Stephen decides who is invited and when; partner sends stay subject to the CPD hold unless he orders them. Note: the 5 to 8 pm night overlaps the 4 to 6 pm Tuesday DJ Lab class from 5 to 6 pm; decide who staffs which. After Jan 19, record the results email (arrives the next afternoon), send photos to fundraisers@portillos.com (get permission from people pictured), and watch for the check 30 to 45 days later.',
  '2026-12-01',
  'Portillo''s For Good fundraiser request; approval email Nov 24, 2026',
  'Attachments in the approval email: "Stephen Henry Ras Tafari Inc. 520 W. Taylor St., Chicago, IL.pdf" (the flyer with the digital code) and "Fundraiser FAQs 5-8pm 10.2024 3.pdf". Grant tracker companion row: fc1eb971-3254-4fb5-b4e5-5a9b1766fd90 (status set to awarded below; amount_awarded left null). Calendar events portillos-night-2027-01-19 and portillos-prep-2027-01-12 already exist. Public credit: none stated; no brand permission. [src:msgid-TP0GRP006sVoln8NTM6XPS44mMQmoA]',
  '2026-11-24 14:40:37+00'
where not exists (select 1 from fs_partners where id = 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37' or name ilike '%portillo%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37'::uuid, 'email',
  'Nov 24, 2026 8:40 am CT (14:40 UTC): Portillo''s For Good (fundraisers@portillos.com, Laura, Portillos Fundraising Team) APPROVED our fundraiser night, request reference PG -40918: Tue Jan 19, 2027, 5:00 to 8:00 PM, 520 W. Taylor St., Chicago. 20% back on orders using the flyer or digital pickup code; $200 minimum sales; pickup only; gift cards, delivery and third-party apps excluded. Flyer and FAQ PDFs attached. Approval of the event, not money received. Message-ID <-NaTP000000000000000000000000000000000000000000000TP0GRP006sVoln8NTM6XPS44mMQmoA@sfdc.net> [src:msgid-TP0GRP006sVoln8NTM6XPS44mMQmoA]',
  'committed', 'stephen@selassiefest.com', 'Claude', '2026-11-24 14:40:37+00'::timestamptz
where exists (select 1 from fs_partners where id = 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37')
  and not exists (select 1 from fs_partner_activity where summary like '%TP0GRP006sVoln8NTM6XPS44mMQmoA%');

-- Companion grant row: approval of the fundraiser night = awarded. Earned proceeds, so amount_awarded stays null (value unknown until after Jan 19, 2027).
update fs_grant_deadlines set
  status = 'awarded',
  decision_on = coalesce(decision_on, '2026-11-24'),
  notes = coalesce(notes,'') || E'\n[2026-11-25] Companion partner row d4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37 created. Status set to awarded on the Nov 24 approval; amount_awarded left null (earned proceeds, value unknown until after Jan 19, 2027). The 5-8 pm night overlaps the 4-6 pm Tuesday DJ Lab class from 5 to 6 pm. [src:partner-d4b7c9e1]',
  updated_at = now()
where id = 'fc1eb971-3254-4fb5-b4e5-5a9b1766fd90'
  and status = 'submitted'
  and coalesce(notes,'') not like '%[src:partner-d4b7c9e1]%';

commit;

select 'partner' as t, name as k, stage as s, next_step_due::text as d from fs_partners where id = 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37'
union all select 'activity (expect 1)', left(summary, 60), stage_after, created_at::text from fs_partner_activity where summary like '%TP0GRP006sVoln8NTM6XPS44mMQmoA%'
union all select 'grant (expect awarded, amount null)', status, amount_awarded::text, next_step_due::text from fs_grant_deadlines where id = 'fc1eb971-3254-4fb5-b4e5-5a9b1766fd90';

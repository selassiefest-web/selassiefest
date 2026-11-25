-- Portillo's For Good: fundraiser night APPROVED (email Nov 24, 2026 8:40 am CT). New partner row; none existed. Safe to re-run.
-- Source: C:\Users\mkepr\Downloads\BOB\__Your_Portillo's_fundraiser_night_was_approved!__.eml (Message-ID fragment TP0GRP006sVoln8NTM6XPS44mMQmoA, request reference PG -40918)
begin;

insert into fs_partners (id, name, category, website, email, contacts, partner_types, program_parts, stage, ball_with, ask, commitment, next_step, next_step_due, source, notes, last_contact_at)
select 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37', 'Portillo''s (Portillo''s For Good fundraiser night)', 'Restaurant & food', 'https://www.portillos.com', 'fundraisers@portillos.com',
  '[{"name":"Laura","title":"Portillos Fundraising Team","email":"fundraisers@portillos.com"}]'::jsonb,
  array['financial'], array['classes'], 'committed', 'us',
  'A Portillo''s fundraiser night for Ras Tafari Inc.',
  'APPROVED Nov 24, 2026 (request reference PG -40918): fundraiser night Tue Jan 19, 2027, 5:00 to 8:00 PM at Portillo''s, 520 W. Taylor St., Chicago. Ras Tafari Inc. receives 20% back on orders from everyone who brings the flyer, shows it on a phone, mentions the organization before checkout, or places a pickup order with the digital code on the flyer. Rules: pickup orders only from that restaurant during the hours; gift cards, delivery and third-party apps excluded; catering counts; $200 minimum fundraising sales or no donation; cannot combine with other offer codes. Dollar value unknown until after the night.',
  'Promote the night with the approved flyer (English; Spanish on request). Flyer and FAQs saved at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\portillos\. Stephen decides who is invited and when; no partner sends until the CPD GO. After Jan 19, send photos to fundraisers@portillos.com (they may use them; get permission from people pictured) and record the amount received.',
  '2026-12-15',
  'Portillo''s For Good fundraiser request; approval email Nov 24, 2026',
  'Attachments in the approval email: "Stephen Henry Ras Tafari Inc. 520 W. Taylor St., Chicago, IL.pdf" (the flyer with the digital code) and "Fundraiser FAQs 5-8pm 10.2024 3.pdf". Public credit: none stated; no brand permission. [src:msgid-TP0GRP006sVoln8NTM6XPS44mMQmoA]',
  '2026-11-24 14:40:37+00'
where not exists (select 1 from fs_partners where id = 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37' or name ilike '%portillo%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37'::uuid, 'email',
  'Nov 24, 2026 8:40 am CT (14:40 UTC): Portillo''s For Good (fundraisers@portillos.com, Laura, Portillos Fundraising Team) APPROVED our fundraiser night, request reference PG -40918: Tue Jan 19, 2027, 5:00 to 8:00 PM, 520 W. Taylor St., Chicago. 20% back on orders using the flyer or digital pickup code; $200 minimum sales; pickup only; gift cards, delivery and third-party apps excluded. Flyer and FAQ PDFs attached. Approval of the event, not money received. Message-ID <-NaTP000000000000000000000000000000000000000000000TP0GRP006sVoln8NTM6XPS44mMQmoA@sfdc.net> [src:msgid-TP0GRP006sVoln8NTM6XPS44mMQmoA]',
  'committed', 'stephen@selassiefest.com', 'Claude', '2026-11-24 14:40:37+00'::timestamptz
where exists (select 1 from fs_partners where id = 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37')
  and not exists (select 1 from fs_partner_activity where summary like '%TP0GRP006sVoln8NTM6XPS44mMQmoA%');

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('portillos-fundraiser-2027-01-19', 'Portillo''s fundraiser night for Ras Tafari Inc. (20% back)',
  timestamptz '2027-01-19 17:00-06', timestamptz '2027-01-19 20:00-06', 'Portillo''s, 520 W. Taylor St., Chicago',
  'Approved Nov 24, 2026, reference PG -40918. Orders must use the flyer or the digital pickup code; $200 minimum sales. After the night send photos to fundraisers@portillos.com and record the amount received.')
on conflict (key) do nothing;

commit;

select 'partner' as t, name as k, stage as s, next_step_due::text as d from fs_partners where id = 'd4b7c9e1-3a52-4f68-8e0d-6c1f2a9b5d37'
union all select 'activity', left(summary, 60), stage_after, created_at::text from fs_partner_activity where summary like '%TP0GRP006sVoln8NTM6XPS44mMQmoA%'
union all select 'event', key, null, starts_at::text from rti_calendar_events where key = 'portillos-fundraiser-2027-01-19';

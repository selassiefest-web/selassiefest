-- Nov 18, 2026: Shure thread (CQ-1076) after receipt. Six .eml files in C:\Users\mkepr\Downloads\BOB\ (the unnumbered copy and "(4)" are byte-identical; "(6)" does not exist; files (1)..(5) + unnumbered = 5 distinct messages plus quoted history).
-- Events (America/Chicago = UTC-6 after Nov 1):
--   Nov 3 1:09 pm  Cheryl: mics ship later that week, headphones on slight backorder until the 9th (quoted history; Stephen replied 1:32 pm)
--   Nov 16 6:39 pm Stephen: donor page link (letter, W-9, photos)
--   Nov 17 9:45 am Cheryl: security protocols block downloads from the link; asks for attachments
--   Nov 18 3:51 am Stephen: attachments (Donation Acknowledgment CQ-1076, W-9, Form 8283 Part V, 6 photos)
--   Nov 18 10:03 am Cheryl: "Thank you so much!!"
--   Nov 18 12:03 pm Stephen: four follow-up asks (orientation, brand guidelines, learning resources, career talk)
-- Safe to re-run (activity keyed on Message-ID / date text; partner update guarded).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 3, 2026 (1:09 pm CT): Cheryl Jennison Daproza (Shure) said the SM58 mics should ship later that week and the headphones were on slight backorder until the 9th. Stephen replied 1:32 pm CT (excited, thanked her). Quoted in the Nov 16-18 threads; no separate Message-ID in hand.',
 'committed', 'daprozc@shure.com', 'Cheryl Jennison Daproza', '2026-11-03 19:09:00+00'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like 'Nov 3, 2026 (1:09 pm CT): Cheryl%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 16, 2026 (6:39 pm CT): Stephen told Cheryl everything arrived and sent a private donor page (acknowledgment letter, W-9, photos, question box). Message-ID <CO6P220MB033806105419DCBBB00B59E0D77B2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 'confirmed', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-17 00:39:09+00'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like '%CO6P220MB033806105419DCBBB00B59E0D77B2%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 17, 2026 (9:45 am CT): Cheryl said Shure security protocols do not let her download files from the link and asked for attachments. Message-ID <SA1PR01MB8671B435AF0FEEF7E9304620BD7B2@SA1PR01MB8671.prod.exchangelabs.com>.',
 'confirmed', 'daprozc@shure.com', 'Cheryl Jennison Daproza', '2026-11-17 15:45:39+00'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like '%SA1PR01MB8671B435AF0FEEF7E9304620BD7B2%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 18, 2026 (3:51 am CT): Stephen emailed Cheryl the 9 attachments she needed: Ras-Tafari-Inc-Donation-Acknowledgment-CQ-1076.pdf, Ras-Tafari-Inc-Form-W-9.pdf, Ras-Tafari-Inc-Form-8283-Part-V.pdf (donee acknowledgment, states no value), photo-1 to photo-6.jpg. This fulfils Shure''s Nov 10 request (letter, W-9, photos). Message-ID <CO6P220MB0338B782E79AE0D3C424B341D77A2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 'confirmed', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-18 09:51:48+00'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like '%CO6P220MB0338B782E79AE0D3C424B341D77A2%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 18, 2026 (10:03 am CT): Cheryl replied "Thank you so much!!" to the attachments. Message-ID <SA1PR01MB8671D311C6E538104E43DAF0BD7A2@SA1PR01MB8671.prod.exchangelabs.com>.',
 'confirmed', 'daprozc@shure.com', 'Cheryl Jennison Daproza', '2026-11-18 16:03:46+00'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like '%SA1PR01MB8671D311C6E538104E43DAF0BD7A2%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 18, 2026 (12:03 pm CT): Stephen thanked Shure again and asked four things: (1) a Shure person to run an equipment orientation/stewardship session for students (use, care, transport, cleaning, storage); (2) Shure brand-recognition guidelines and assets; (3) any Shure educational resources, videos or guides for the curriculum; (4) a Shure person to talk to students about audio careers, even virtually. No answer yet. Message-ID <CO6P220MB03384D4AB9C79F5AAB7C62F8D77A2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 'confirmed', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-18 18:03:50+00'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like '%CO6P220MB03384D4AB9C79F5AAB7C62F8D77A2%');

update fs_partners set
  stage = 'confirmed',
  ball_with = 'them',
  last_contact_at = '2026-11-18 18:03:50+00',
  commitment = 'DELIVERED and ACKNOWLEDGED: 2 SM58-LC microphones and 12 pairs of SRH440A headphones from Shure (request CQ-1076, approved Oct 29, 2026), received at 1401 E. 71st St. Acknowledgment letter, W-9, Form 8283 Part V (states no value) and 6 photos emailed to Shure Nov 18; Cheryl thanked us. No dollar value stated by Shure.',
  next_step = 'WAIT for Cheryl (daprozc@shure.com) to answer Stephen''s Nov 18 four asks (student orientation session, brand guidelines/assets, learning resources, careers talk). If silent, one polite follow-up. Then: recognition on the website only per Shure brand guidelines once received; photos in use after the Jan 12, 2027 first class; impact report after the first term.',
  next_step_due = '2026-11-25',
  contacts = '[{"name": "Cheryl Jennison Daproza", "role": "Shure donations; approved request CQ-1076 Oct 29", "email": "daprozc@shure.com"}]'::jsonb,
  notes = coalesce(notes,'') || E'\n2026-11-16 to 2026-11-18 THREAD: Stephen sent a private donor page Nov 16 (6:39 pm CT); Cheryl said Nov 17 Shure security blocks link downloads and asked for attachments; Stephen sent 9 attachments Nov 18 (acknowledgment letter, W-9, Form 8283 Part V, 6 photos); Cheryl: "Thank you so much!!" Nov 18 10:03 am CT; Stephen then asked four things (orientation session, brand guidelines, learning resources, careers talk) Nov 18 12:03 pm CT. Ball with Shure. Donor page row in rti_donor_pages (request CQ-1076, created Nov 17).'
where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
  and coalesce(notes,'') not like '%2026-11-16 to 2026-11-18 THREAD%';

commit;

select stage, ball_with, next_step_due, last_contact_at, left(next_step,60) ns from fs_partners where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d';
select created_at, left(summary,60) s from fs_partner_activity where partner_id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' order by created_at;

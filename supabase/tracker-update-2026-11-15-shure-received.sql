-- Nov 15, 2026: Shure CQ-1076 shipment received; Cheryl's Nov 10 email asks for confirmation letter + W-9 + photos. Safe to re-run.
begin;

update fs_partners set
  stage = 'confirmed',
  ball_with = 'us',
  last_contact_at = now(),
  commitment = 'DELIVERED: 2 SM58-LC microphones and 12 pairs of SRH440A headphones from Shure (request CQ-1076, approved Oct 29, 2026), received at 1401 E. 71st St. Shure asks for a confirmation letter on letterhead (products received, no goods or services in exchange), a W-9 copy, and photos for internal use.',
  next_step = 'SEND Cheryl (daprozc@shure.com) the signed confirmation letter, W-9 and photos (email drafted Nov 15, Stephen sends it himself). Then the thank-you and recognition on the website; photos in use after the Jan 12, 2027 first class; impact report after the first term.',
  next_step_due = '2026-11-16',
  notes = coalesce(notes,'') || E'\n2026-11-10 EMAIL from Cheryl Jennison Daproza (daprozc@shure.com), Message-ID <SA1PR01MB867102105F19993167A43FE9BD722@SA1PR01MB8671.prod.exchangelabs.com>: mics and headphones shipped (she gave headphone UPS tracking 1Z6100650395998284). Asks after receipt for (1) confirmation letter on letterhead: products received (2 SM58-LC, 12 pairs SRH440A), no goods or services received in exchange; (2) a copy of our W-9; (3) photos of the products in use, internal use only.\n2026-11-15 RECEIVED per Stephen: photos of the cartons. Labels: UPS Ground 1Z 610 065 03 9575 9694 (14 lbs, "2 of 2", headphones) and 1Z 610 065 03 9567 0743 (4 lbs, "1 of 1", SM58 mics); neither equals the tracking number Cheryl gave. Letter, W-9 and photos in Claude outputs/equipment-outreach/shure-received/.'
where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'email',
 'Nov 10, 2026 (2:59 pm CT): Cheryl Jennison Daproza (Shure, daprozc@shure.com) said the 2 SM58-LC mics and 12 pairs of SRH440A headphones have shipped (headphone tracking 1Z6100650395998284) and asked for a confirmation letter on letterhead (no goods or services received in exchange), a W-9, and photos. Message-ID <SA1PR01MB867102105F19993167A43FE9BD722@SA1PR01MB8671.prod.exchangelabs.com>.',
 'committed', 'daprozc@shure.com', 'Cheryl Jennison Daproza'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like '%SA1PR01MB867102105F19993167A43FE9BD722%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'note',
 'Nov 15, 2026: Shure shipment RECEIVED at 1401 E. 71st St. (2 SM58-LC mics, 12 pairs SRH440A headphones; photos taken). Confirmation letter, W-9 and photos prepared for Stephen to email to Cheryl.',
 'confirmed', 'stephen@selassiefest.com', 'Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like 'Nov 15, 2026: Shure shipment RECEIVED%');

update fs_partners set ball_with='us' where id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d';
commit;
select stage, ball_with, next_step_due from fs_partners where id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d';
select count(*) as shure_activity_rows from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and (summary like '%SA1PR01MB867102105F19993167A43FE9BD722%' or summary like 'Nov 15, 2026: Shure shipment RECEIVED%');

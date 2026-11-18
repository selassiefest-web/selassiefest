-- Nov 18, 2026: Shure CQ-1076. Stephen confirmed the receipt date on the signed Form 8283 Part V, 11/06/2026, is CORRECT.
-- Date of record for receipt of the equipment = Nov 6, 2026. Earlier tracker text that said Nov 15 is superseded (history kept; new entry added).
-- Also refreshes the stale companion grant row. Safe to re-run (guarded).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d', 'note',
 'Nov 18, 2026: Stephen confirmed the receipt date on the signed Form 8283 Part V, 11/06/2026, is correct. Date of record for receipt of the Shure equipment (2 SM58-LC microphones, 12 pairs SRH440A headphones): Nov 6, 2026. Earlier entries dated Nov 15 are superseded on this point.',
 'confirmed', 'stephen@selassiefest.com', 'Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like 'Nov 18, 2026: Stephen confirmed the receipt date%');

update fs_partners set
  commitment = 'DELIVERED and ACKNOWLEDGED: 2 SM58-LC microphones and 12 pairs of SRH440A headphones from Shure (request CQ-1076, approved Oct 29, 2026), received Nov 6, 2026 at 1401 E. 71st St. (date on the signed Form 8283 Part V, confirmed by Stephen). Signed acknowledgment letter, W-9, Form 8283 Part V (states no value) and 6 photos emailed to Shure Nov 18; Cheryl thanked us. No dollar value stated by Shure.',
  notes = coalesce(notes,'') || E'\n2026-11-18 RECEIPT DATE OF RECORD = Nov 6, 2026 (Stephen confirmed; it is the date on the signed Form 8283 Part V). Earlier notes that say Nov 15 are superseded. Signed package as sent Nov 18 saved in Claude outputs/shure-thank-you/sent-2026-11-18-signed/ (letter dated Nov 16, W-9 and 8283 signed 11/16/2026).'
where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
  and coalesce(notes,'') not like '%RECEIPT DATE OF RECORD = Nov 6, 2026%';

-- companion grant row e95fcd7b: stale next step (expected-current-value guard)
update fs_grant_deadlines set
  next_step = 'Received Nov 6, 2026 and acknowledged Nov 18 (signed letter, W-9, Form 8283 Part V sent). Waiting on Shure''s reply to Stephen''s Nov 18 asks; follow up Nov 25 if silent. No value stated. Recognition only after Shure''s brand guidelines.',
  next_step_due = '2026-11-25',
  updated_at = now()
where id = 'e95fcd7b-e7eb-4976-8c07-a3fd7dbdf9d5'
  and next_step = 'Confirm the shipment arrives; then the thank-you note. Impact report after the first term.';

commit;

select left(commitment,120) c, ball_with, stage from fs_partners where id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d';
select count(*) as receipt_note_rows from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' and summary like 'Nov 18, 2026: Stephen confirmed the receipt date%';
select status, next_step_due, left(next_step,70) ns from fs_grant_deadlines where id='e95fcd7b-e7eb-4976-8c07-a3fd7dbdf9d5';

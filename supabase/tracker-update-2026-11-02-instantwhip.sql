-- Instantwhip-Chicago: backup ice cream distributor (Fox Valley Farms declined Nov 2 and referred us to GlacierPoint).
-- Contact verified on the company's own Chicago page https://www.instantwhip.com/instantwhip-chicago .
-- The email is DRAFTED and NOT YET SENT (send: Claude outputs/ice-cream/send-instantwhip.js --send). Safe to re-run.
insert into fs_partners (name, category, address, phone, email, website, stage, ask, next_step, next_step_due, source, notes)
select 'Instantwhip-Chicago, Inc.', 'Restaurant & food', '1535 N. Cicero Ave., Chicago, IL 60651', '(773) 235-5588 (toll-free 800-214-1413)',
  'info@instantwhipfoods.com', 'https://www.instantwhip.com/instantwhip-chicago', 'not_contacted',
  'Small weekly orders of individually wrapped novelties for the Rainbow DJ Lab and Rainbow Wednesdays (about 20 servings every Tuesday, 30 on each of 14 Wednesdays; about 1,200 in 2027): donated cases or nonprofit pricing, South Side delivery, combined orders, loaner freezer.',
  'Email DRAFTED, not sent: Claude outputs/ice-cream/instantwhip-email.html (send with send-instantwhip.js --send after Stephen says send). If silent 5 days after sending, call (773) 235-5588 or 800-214-1413.',
  date '2026-11-03', 'Referral research Nov 2, 2026',
  'Contact verified on Instantwhip''s own Chicago page (serves greater Chicago; office fax 773-235-0578; inquiry form and credit application on the page). An earlier "possibly closed" note came from an underground-tank database and is not evidence the business closed. Whether they sell novelties in orders this small is unconfirmed. Fox Valley Farms declined Nov 2 (no small cups/bars); GlacierPoint form submitted Nov 2; Prairie Farms emailed Nov 1, no reply.'
where not exists (select 1 from fs_partners where name ilike 'Instantwhip%');
select name, stage, next_step_due from fs_partners where name ilike 'Instantwhip%';

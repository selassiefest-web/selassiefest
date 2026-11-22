-- Nov 22, 2026: Gator contact request submitted via the Typeform (thank-you page seen). Safe to re-run (marker-guarded).
begin;
update fs_grant_deadlines set
 status='submitted', submitted_on='2026-11-22', next_step_due='2026-12-07',
 next_step='SUBMITTED Nov 22, 2026 via the Gator Typeform (https://gatorbiz.typeform.com/to/MSvbqK); thank-you page shown. Ask: 13 laptop stands (about $455) and who handles community donations. If Gator replies with a contact, send the full email from the packet (02-gear-audio/03-gator.md, edit the greeting). If silent, one short email follow-up about Mon Dec 7 (internal date). Online only.',
 notes = notes || E'\n2026-11-22 [gator-submitted-20261122] Stephen submitted the Gator Typeform contact request (general inquiry; 248-character message asking for 13 laptop stands about $455 and the right donations contact; Chicago address 1401 E. 71st St.). The thank-you page URL echoed the answers. The marketing-opt-in answer in the echoed URL reads "Yeah- Let''s do this!!" (the preparer selected No thanks, so Stephen or the form changed it): Gator marketing emails may start; unsubscribe if unwanted. No confirmation .eml yet. Nothing awarded or received.'
where id='de947322-dbc9-4af0-80b9-713f47fb844a' and notes not like '%gator-submitted-20261122%';

update fs_partners set stage='reached_out', ball_with='them', next_step_due='2026-12-07', last_contact_at='2026-11-22 12:00-06',
 next_step='Waiting on Gator (Typeform request submitted Nov 22, 2026; grant row de947322). If they name a contact, send the full packet email. If silent, one short email about Mon Dec 7. Online only.',
 notes = coalesce(notes,'') || E'\n[gator-submitted-20261122] Typeform contact request submitted Nov 22, 2026: 13 laptop stands (about $455) and who handles community donations.'
where id='d8211717-4fab-4c5d-86ab-ff62b95010e2' and stage='not_contacted' and coalesce(notes,'') not like '%gator-submitted-20261122%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'note','Stephen submitted the Gator Typeform contact request Nov 22, 2026 (thank-you page shown): general inquiry asking for 13 laptop stands (about $455) and the right community-donations contact. No reply yet. Grant row de947322. (marker gator-submitted-20261122)','reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-22 12:00-06'
from fs_partners p where p.id='d8211717-4fab-4c5d-86ab-ff62b95010e2'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%gator-submitted-20261122%');
commit;
select (select status||' '||submitted_on::text||' '||next_step_due::text from fs_grant_deadlines where id='de947322-dbc9-4af0-80b9-713f47fb844a') g,
 (select stage||'/'||ball_with from fs_partners where id='d8211717-4fab-4c5d-86ab-ff62b95010e2') p,
 (select count(*) from fs_partner_activity where summary like '%gator-submitted-20261122%') acts;

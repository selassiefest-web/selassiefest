-- Nov 22, 2026: Reloop / American Music & Sound support request form SUBMITTED (Zoho thank-you page seen). Safe to re-run (marker-guarded).
begin;
update fs_grant_deadlines set
 status='submitted', submitted_on='2026-11-22', next_step_due='2026-12-04',
 next_step='SUBMITTED Nov 22, 2026 via the American Music & Sound (JAM Industries) Customer Support Request Form, as Reloop Support asked on Nov 19; thank-you page: "We will get back to you ASAP." Ask: whatever Reloop can offer, welcoming their best (13 education-ready DJ controllers, turntable demo setup, mixers, 13 DJ headphones, anything that suits a youth class), in kind, demo/loan or education pricing, plus routing to the education/community/artist-support contact. Watch stephen@selassiefest.com for a ticket reply. If silent, one status email on Fri Dec 4 (internal date). Online only.',
 notes = notes || E'\n2026-11-22 [reloop-ams-submitted-20261122] Stephen submitted the AM&S Customer Support Request Form (Contact Request Type Marketing; Customer Type End-user; Inquiry Type Presales Question; Brand Reloop; Subject "Reloop education support for a free youth DJ class, Chicago (Ras Tafari Inc.)"). Description widened that night to "whatever Reloop can offer ... we would welcome your best" with the deck link and an offer to work with their marketing team; Chicago address 1401 E. 71st St. Thank-you page seen; no confirmation .eml yet. Nothing awarded or received.'
where id='383b51a1-d28a-4fff-b8c2-0dfbb808925b' and notes not like '%reloop-ams-submitted-20261122%';

update fs_partners set stage='reached_out', ball_with='them', next_step_due='2026-12-04', last_contact_at='2026-11-22 12:00-06',
 next_step='Waiting on Reloop USA / American Music & Sound (support form submitted Nov 22, 2026; grant row 383b51a1). Watch for a ticket reply; if silent, one status email Fri Dec 4. Online only.',
 notes = coalesce(notes,'') || E'\n[reloop-ams-submitted-20261122] AM&S support request form submitted Nov 22, 2026 (thank-you page seen).'
where id='aad5ab14-8354-47f0-ac24-a09f195f03a2' and coalesce(notes,'') not like '%reloop-ams-submitted-20261122%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'note','Stephen submitted the American Music & Sound / JAM Industries Customer Support Request Form for Reloop on Nov 22, 2026 (thank-you page: "We will get back to you ASAP."), following Reloop Support''s Nov 19 redirect. Wide ask: whatever Reloop can offer, welcoming their best (education-ready DJ controllers, turntable demo setup, mixers, DJ headphones), plus routing to the education/community contact. No ticket reply yet. Grant row 383b51a1. (marker reloop-ams-submitted-20261122)','reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-22 12:00-06'
from fs_partners p where p.id='aad5ab14-8354-47f0-ac24-a09f195f03a2'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%reloop-ams-submitted-20261122%');
commit;
select (select status||' '||submitted_on::text||' '||next_step_due::text from fs_grant_deadlines where id='383b51a1-d28a-4fff-b8c2-0dfbb808925b') g,
 (select stage||'/'||ball_with||' '||next_step_due::text from fs_partners where id='aad5ab14-8354-47f0-ac24-a09f195f03a2') p,
 (select count(*) from fs_partner_activity where summary like '%reloop-ams-submitted-20261122%') acts;

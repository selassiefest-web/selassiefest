-- PROPOSED (not applied). Re-runnable: every write is guarded by a [src:...] marker.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'b8d73772-58e8-43bd-9aec-749502f8d76d','email',
 'Nov 22, 2026 06:46 UTC (Nov 22, 12:46 am CT): Isaac Jack (Audima Labs) replied to our Nov 21 note (Message-ID <B7FCEFC1-5207-2148-B506-FBAF0F882EB7@hxcore.ol>): Tue Mar 30, 2027 works, or any time in April if CPD approval slips; they will review the lesson outline and prepare in advance. ASKS what our budget can cover for Jeremy and Isaac travelling from Australia (accommodation, flights, or a contribution toward travel); they would cover the rest. No dollar figure stated by Audima. Ball with us. [src:msgid-B7FCEFC1-5207-2148-B506-FBAF0F882EB7]',
 'in_conversation','contactus@audima.com.au','Isaac Jack (Audima Labs)','2026-11-22 06:46:04+00'
where not exists (select 1 from fs_partner_activity where summary like '%[src:msgid-B7FCEFC1-5207-2148-B506-FBAF0F882EB7]%');

update fs_partners set ball_with='us', last_contact_at='2026-11-22 06:46:04+00',
 next_step='Reply to Isaac Jack (thread the Nov 22 06:46 UTC email, In-Reply-To <B7FCEFC1-5207-2148-B506-FBAF0F882EB7@hxcore.ol>): answer what Ras Tafari can cover toward Jeremy and Isaac travel (accommodation, flights, contribution). Stephen must set the budget; no figure is on file. Mar 30, 2027 (Mission 9) or any April date works for them; still waiting on Chicago Park District confirmation. Send only after Stephen says send.',
 next_step_due='2026-11-24',
 notes=coalesce(notes,'')||E'\n2026-11-23 [audima-isaac-reply-20261122] Isaac replied Nov 22 06:46 UTC: Mar 30 or any April date works; asks what budget covers travel. Ball with us. Due Nov 24 is a proposed internal date. [src:msgid-B7FCEFC1-5207-2148-B506-FBAF0F882EB7]'
where id='b8d73772-58e8-43bd-9aec-749502f8d76d' and coalesce(notes,'') not like '%[audima-isaac-reply-20261122]%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'b8d73772-58e8-43bd-9aec-749502f8d76d','note',
 'Audima Labs order receipt Nov 22, 2026 01:35 UTC (Message-ID <su89_urXTGqhseBpW3kSug@geopod-ismtpd-73>): order #32779, Sway MIDI Controller (Reservation) x4, total $100, card via Stripe. Earlier log line says a $25 reservation; the receipt shows quantity 4 = $100. Not reconciled; Stephen to confirm quantity. [src:msgid-su89_urXTGqhseBpW3kSug]',
 null,'contactus@audima.com.au','Audima Labs','2026-11-22 01:35:39+00'
where not exists (select 1 from fs_partner_activity where summary like '%[src:msgid-su89_urXTGqhseBpW3kSug]%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'f4d63a82-b3b3-494a-a72d-1edcd71cf92a','email',
 'Contact form on the Parkside website submitted by Stephen Henry; confirmation email "Mail from Parkside S.T.E.A.M. Community Academy" Nov 23, 2026 03:20:39 UTC (Nov 22, 9:20 pm CT), Message-ID <506313022.13921795404039108.JavaMail.edunet@w9.c.edunet-websites.internal>, from noreply@educationalnetworks.net (school web platform; proves the message was sent, not read). Text: intro, about 273 at the 2026 festival, free Rainbow DJ Lab (Tuesdays 4-6 pm, from Jan 12, 2027), free alcohol-free Rainbow Wednesdays (14 Wednesdays, 4-8 pm, from June 2, 2027, goal 300 people a night), invites sharing with families, deck link, Stephen email and (872) 255-9333. No ask for money. No reply yet. [src:msgid-506313022.13921795404039108]',
 'reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-23 03:20:39+00'
where not exists (select 1 from fs_partner_activity where summary like '%[src:msgid-506313022.13921795404039108]%');

update fs_partners set stage='reached_out', ball_with='them', last_contact_at='2026-11-23 03:20:39+00',
 next_step='Waiting on Parkside (web contact form submitted Nov 22, 2026, confirmation received). If silent, one more online contact-form nudge about Mon Dec 7, 2026 (internal date, not a school commitment). Online only.',
 next_step_due='2026-12-07',
 notes=coalesce(notes,'')||E'\n2026-11-23 [parkside-form-20261122] Contact form submitted Nov 22 (9:20 pm CT), confirmation Nov 23 03:20 UTC. Supersedes the plan to submit on Nov 23. No reply yet. [src:msgid-506313022.13921795404039108]'
where id='f4d63a82-b3b3-494a-a72d-1edcd71cf92a' and stage='not_contacted' and coalesce(notes,'') not like '%[parkside-form-20261122]%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'd8211717-4fab-4c5d-86ab-ff62b95010e2','email',
 'Gator support autoreply Nov 22, 2026 06:51 UTC (Message-ID <M996GPPMJ4K_6b0290f59c0a0_f1d132c3dddefd_sprut@zendesk.com>): "Your request (533641) has been received", subject "Contact Us - Stephen Henry"; next available agent will be in touch (Mon-Fri 9am-6pm EST). Acknowledgment only: no person, gear or value. Treated as the confirmation of the Nov 22 contact-form submission (timing match; the email does not say which form). A Gator Fan Club mailing-list signup email followed at 06:52 UTC. [src:msgid-M996GPPMJ4K_6b0290f59c0a0_f1d132c3dddefd_sprut]',
 'reached_out','info@gatorcases.com','Gator support (autoreply)','2026-11-22 06:51:33+00'
where not exists (select 1 from fs_partner_activity where summary like '%[src:msgid-M996GPPMJ4K_6b0290f59c0a0_f1d132c3dddefd_sprut]%');

update fs_partners set notes=coalesce(notes,'')||E'\n2026-11-23 [gator-ticket-533641] Gator Zendesk request 533641 acknowledged Nov 22 06:51 UTC. Awaiting an agent reply; ball with them.'
where id='d8211717-4fab-4c5d-86ab-ff62b95010e2' and coalesce(notes,'') not like '%[gator-ticket-533641]%';
update fs_grant_deadlines set notes=coalesce(notes,'')||E'\n2026-11-23 [gator-ticket-533641] Confirmation .eml received: Gator request 533641 acknowledged Nov 22 06:51 UTC (autoreply, no contact named). Nothing awarded or received.'
where id='de947322-dbc9-4af0-80b9-713f47fb844a' and coalesce(notes,'') not like '%[gator-ticket-533641]%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'aad5ab14-8354-47f0-ac24-a09f195f03a2','email',
 'JAM USA Tech Support autoreply "Your ticket has been created", ticket ID 376910, dated Sat Nov 21, 2026 23:03:20 -0800 (= Nov 22 07:03 UTC), Message-ID <edbsn43a713d37403f1e08087a77042945b123af535d16a65f7271846d87cc346fb5af4325381efb5efcdce55a5100ad99135_kczhs_1a202110261@desk-mailer.zohodesk.com>. Subject quoted: "Reloop education support for a free youth DJ class, Chicago (Ras Tafari Inc.)"; Marketing team to review and respond. One image attachment. Confirms the AM&S/JAM support-form submission. No gear, value or contact named. [src:msgid-edbsn43a713d37403f1e08087a77042945b123af535d16a65f7271846d87cc346fb5af4325381efb5efcdce55a5100ad99135]',
 'reached_out','techsupport@jamindustriesusa.com','JAM USA Tech Support (autoreply)','2026-11-22 07:03:20+00'
where not exists (select 1 from fs_partner_activity where summary like '%[src:msgid-edbsn43a713d37403f1e08087a77042945b123af535d16a65f7271846d87cc346fb5af4325381efb5efcdce55a5100ad99135]%');
update fs_partners set notes=coalesce(notes,'')||E'\n2026-11-23 [reloop-ticket-376910] JAM USA ticket 376910 created Nov 22 07:03 UTC (autoreply; Marketing team to respond). Ball with them.'
where id='aad5ab14-8354-47f0-ac24-a09f195f03a2' and coalesce(notes,'') not like '%[reloop-ticket-376910]%';
update fs_grant_deadlines set notes=coalesce(notes,'')||E'\n2026-11-23 [reloop-ticket-376910] Confirmation .eml received: JAM USA ticket 376910 created Nov 22 (autoreply). Replaces "no confirmation .eml yet". Nothing awarded or received.'
where id='383b51a1-d28a-4fff-b8c2-0dfbb808925b' and coalesce(notes,'') not like '%[reloop-ticket-376910]%';

update fs_grant_deadlines set
 next_step='Waiting on Blick. Receipt email (Nov 23, 2026) says: if no response within 30 business days, contact donations@dickblick.com. 30 business days from Nov 23, excluding Thanksgiving, Dec 25 and Jan 1, ends Thu Jan 7, 2027; follow up Fri Jan 8, 2027 (internal date). Narrated deck: https://selassiefest.com/full-spectrum/blick/ ; proposal PDF attached to the form.',
 next_step_due='2027-01-08',
 notes=coalesce(notes,'')||E'\n2026-11-23 [blick-receipt-20261123] Jotform receipt "We have received your response for Blick Donation Request", Message-ID <jLTneXjjg9QXQn4JRZY6U5qLK1E3ya9J5T1YuTANAw@go-workers-29jt>, Nov 23 06:31 UTC: forwarded to the appropriate team; no response in 30 business days then email donations@dickblick.com. Receipt only, not a decision. Supersedes the earlier about-30-days / Dec 23 check date. [src:msgid-jLTneXjjg9QXQn4JRZY6U5qLK1E3ya9J5T1YuTANAw]'
where id='07eaeb9e-90d8-4cbd-a59d-1225d04c2c9d' and coalesce(notes,'') not like '%[blick-receipt-20261123]%';

select 'activity' k, count(*) from fs_partner_activity where summary ~ '\[src:msgid-(B7FCEFC1-5207|su89_urX|506313022\.139|M996GPPMJ4K_6b02|edbsn43a713d)'
union all select 'partners', count(*) from fs_partners where notes ~ '\[(audima-isaac-reply-20261122|parkside-form-20261122|gator-ticket-533641|reloop-ticket-376910)\]'
union all select 'grants', count(*) from fs_grant_deadlines where notes ~ '\[(gator-ticket-533641|reloop-ticket-376910|blick-receipt-20261123)\]';
-- expected after apply: activity 5, partners 4, grants 3
commit;

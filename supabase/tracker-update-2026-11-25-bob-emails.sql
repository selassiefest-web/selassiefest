-- BOB .eml batch, files modified Nov 25, 2026. Safe to re-run: every write is guarded by a Message-ID fragment or an expected current value.
-- Not changed (already in Supabase): CCRx send (ccrx-sent), AlphaTheta Nov 24 reply, Wisdom submission row, Oriental/4imprint submission rows, Musician's Friend bounce status.
-- Douglas L. Allen (douglas.allen@afccchicago.com) is an RTI officer (Stephen, Nov 25, 2026): NO external partner row and NO activity row for him. His Nov 1 reply is not logged here (no related 'Who do we know?' row exists to hold a note).
-- Ignored on purpose: Nov 25 [Calendar] reminders; TRC Events comp-request notifications (Jul 2026, site-form tests); Bongo Beach PAC contact form (Sep 2026, not a partner).
begin;

-- ===== 1. Oriental Trading: Received (Nov 25 03:59 CST) and Answer = decline, reapply with the 501(c)(3) address (Nov 25 09:18 CST) =====
update fs_grant_deadlines set
  status = 'declined',
  decision_on = '2026-11-25',
  next_step = 'DECLINED Nov 25, 2026 9:18 am CT (request 5225976): high request volume, cannot accommodate now. They ask us to REAPPLY with the address on our 501(c)(3) form and say they will gladly reconsider. Reapply today through https://orientaltrading.requestitem.com/ (their form only; they ask not to be contacted outside it) with the IRS determination letter address, 765 E 154th St, South Holland, IL 60473, same craft-supplies ask for the May 18, 2027 DJ Lab Spring Showcase. Owner: not assigned (Stephen presses Submit).',
  next_step_due = '2026-11-25',
  notes = coalesce(notes,'') || E'\n[2026-11-25] Oriental Trading (orientaltrading@approveforgood.com) Received notice 3:59 am CT, Message-ID <6b06b1681931b_1011aae0831569@ip-10-134-5-254.us-east-2.compute.internal.mail>; Answer 9:18 am CT, Message-ID <6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail>: not accommodated at this time due to request volume; reapply with the address on the 501(c)(3) form. Prior status submitted, prior next_step_due 2026-12-28. [src:msgid-6b06fc39533f2]',
  updated_at = now()
where id = 'd14f32bd-d2e1-483f-b2cc-ef800b3e7ac8'
  and status = 'submitted'
  and coalesce(notes,'') not like '%6b06fc39533f2%';

update fs_partners set
  stage = 'declined',
  ball_with = 'us',
  last_contact_at = '2026-11-25 15:18:17+00',
  next_step = 'Reapply today at https://orientaltrading.requestitem.com/ with the address on the IRS determination letter (765 E 154th St, South Holland, IL 60473); same ask: craft materials for the May 18, 2027 DJ Lab Spring Showcase. Online form only.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes,'') || ' | 2026-11-25: declined for now (volume); invited reapplication with the 501(c)(3) address. Grant row d14f32bd-d2e1-483f-b2cc-ef800b3e7ac8. [src:msgid-6b06fc39533f2]',
  updated_at = now()
where id = '965d7d84-5464-4632-bac0-c97920af6468'
  and stage = 'reached_out' and ball_with = 'them'
  and coalesce(notes,'') not like '%6b06fc39533f2%';

-- ===== 2. DeKalb County Community Foundation (Wurlitzer Fund): George Buck declines new requests from outside DeKalb County =====
update fs_grant_deadlines set
  status = 'declined',
  decision_on = '2026-11-25',
  next_step = 'DECLINED Nov 25, 2026 6:52 am CT by George Buck: their advisory board will not accept NEW requests from outside DeKalb County (limited funds; they still support a few Chicago groups that already depend on them). Do not file the Mar 1, 2027 application and do not nudge. No other angle identified; revisit only if the fund''s policy changes. Owner: not assigned.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n[2026-11-25] REPLY George Buck, Nov 25 2026 12:52 UTC (6:52 am CT), from george@dekalbcountyfoundation.org (our inquiry went to george@dekalbccf.org; same person, new domain on the reply), Message-ID <165FE057-4F28-447D-8B18-DC362DBC70F4@dekalbcountyfoundation.org>, in reply to <CO6P220MB0338730DAB3A1C089499BD0ED7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>: still supports a few long-time Chicago organizations; advisory board decided not to accept new requests from outside DeKalb County; wishes us well. This contradicts the guidelines page (Chicago-area groups with a DeKalb preference). Supersedes the Dec 2 nudge and the Jan 1 filing plan. Our inquiry to him cited $12,103 (7 controllers x $1,729); the planned filing was $11,990. Prior next_step_due 2026-12-02. [src:msgid-165FE057-4F28-447D-8B18-DC362DBC70F4]',
  updated_at = now()
where id = '013d3944-c420-4534-b9af-7f3a604c0235'
  and status = 'drafting'
  and coalesce(notes,'') not like '%165FE057-4F28-447D-8B18-DC362DBC70F4%';

-- ===== 3. Andy's Frozen Custard: Lindsey Auz offers 50 mini custard cups (Nov 25 10:14 am CT). New partner row (grant row 8c21a12a exists) =====
insert into fs_partners (id, name, category, website, email, contacts, partner_types, program_parts, stage, ball_with, ask, commitment, next_step, next_step_due, source, notes, last_contact_at)
select 'a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11', 'Andy''s Frozen Custard', 'Restaurant & food', 'https://eatandys.com', 'lindsey.auz@eatandys.com',
  '[{"name":"Lindsey Auz","title":"Marketing Manager","email":"lindsey.auz@eatandys.com"}]'::jsonb,
  array['in_kind'], array['classes'], 'committed', 'us',
  '50 mini custard cups for the DJ Lab Spring Showcase (our Nov 25, 2026 donation form said May 18, 2027).',
  'OFFER by email Nov 25, 2026 (approval, not delivery): 50 mini custard cups. Pickup the day of or the day before the event, any time after 11 AM; Lindsey will share with the Chicago team on Archer Avenue and can coordinate pickup closer to the date. No dollar value stated. Her email names the event as March 9 (our form said May 18, 2027): date to be confirmed.',
  'Reply to Lindsey Auz (draft only, threaded to her Message-ID): thank her, confirm the event date (our request: May 18, 2027 DJ Lab Spring Showcase; she wrote March 9), ask which Archer Avenue store and exact pickup window, and who keeps the cups frozen. Stephen says send. Do not plan a pickup until the date is confirmed.',
  '2026-11-25',
  'Donation request form Nov 25, 2026; reply Nov 25, 2026',
  'Also on the grant tracker (8c21a12a-bf69-4a3d-abc4-728d916f34ee). Delivery and receipt of the cups: not yet. Public credit: none confirmed; no brand or permission evidence. [src:msgid-DS2PR17MB2950417E6113D80AA4DD1F868D84432]',
  '2026-11-25 16:14:56+00'
where not exists (select 1 from fs_partners where id = 'a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11' or name = 'Andy''s Frozen Custard');

update fs_grant_deadlines set
  status = 'awarded',
  decision_on = '2026-11-25',
  next_step = 'APPROVED by email Nov 25, 2026 (in-kind offer, no dollar value stated): 50 mini custard cups. Not yet delivered or received. Reply to Lindsey Auz to confirm the event date (she wrote March 9; our request said May 18, 2027) and pickup store/window (Chicago team, Archer Avenue; after 11 AM, day of or day prior). Partner row a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes,'') || E'\n[2026-11-25] REPLY Lindsey Auz, Marketing Manager (lindsey.auz@eatandys.com), Nov 25 2026 16:14:56 UTC (10:14 am CT), subject "Donation Request - Ras Tafari Inc.", Message-ID <DS2PR17MB2950417E6113D80AA4DD1F868D84432@DS2PR17MB295041.namprd17.prod.outlook.com>: would love to donate 50 mini custard cups for the event on March 9th; pickup the day of or day prior, any time after 11 AM; will share with the Chicago team on Archer Avenue. Date conflicts with our May 18, 2027 request. Prior status submitted, next_step_due 2026-12-10. [src:msgid-DS2PR17MB2950417E6113D80AA4DD1F868D84432]',
  updated_at = now()
where id = '8c21a12a-bf69-4a3d-abc4-728d916f34ee'
  and status = 'submitted'
  and coalesce(notes,'') not like '%DS2PR17MB2950417E6113D80AA4DD1F868D84432%';

-- ===== 4. 4imprint one by one: confirmation email (Nov 25 3:42 am CT) =====
update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n[2026-11-25] Confirmation email from onebyone@4imprint.com, 3:42 am CT, Message-ID <712f6175-d9c3-4a40-aac7-e7ab77a35b38@us-exch-01.4imprint.com>: application received; up to SIX WEEKS to process (about Jan 6, 2027); they will email the applicant; use the same email when writing. No reference number. [src:msgid-712f6175-d9c3-4a40-aac7-e7ab77a35b38]',
  updated_at = now()
where id = '688e871d-3045-4895-a84b-1b67536a5fa2'
  and coalesce(notes,'') not like '%712f6175-d9c3-4a40-aac7-e7ab77a35b38%';

-- ===== 5. Wisdom Family Foundation: Google Forms receipt (Nov 25 4:13 am CT) =====
update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n[2026-11-25] Google Forms receipt (owner Wisdom Collective), 10:13:55 UTC (4:13 am CT), Message-ID <autogen-java-688be7ce-93c9-49ab-8bd2-00be3bc18ee8@google.com>: copy of answers confirms program area Youth enrichment, $10,000 for 20 Tuesdays of instructor pay ($5,000 funds 10), contact Stephen Henry. [src:msgid-autogen-java-688be7ce-93c9-49ab-8bd2-00be3bc18ee8]',
  updated_at = now()
where id = '4b24678c-8233-4cea-b4be-c029151e24e2'
  and coalesce(notes,'') not like '%autogen-java-688be7ce-93c9-49ab-8bd2-00be3bc18ee8%';

-- ===== 6. MPTF / Chicago Federation of Musicians: Nov 4 forward of John Floeter's reply to Paul Kelly and Marlon (his reply itself is already logged) =====
update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n[2026-11-04] Stephen forwarded John Floeter''s Nov 4 reply (with the MPTF restrictions list, attachment "Projects for MPTF performances of the following types NOT FUNDED.docx") to Paul Kelly and Marlon at 19:13 UTC (1:13 pm CT), Message-ID <PH0P220MB0586F3B360877DE7E11D2428D7682@PH0P220MB0586.NAMP220.PROD.OUTLOOK.COM>. Logged Nov 25. [src:msgid-PH0P220MB0586F3B360877DE7E11D2428D7682]',
  updated_at = now()
where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
  and coalesce(notes,'') not like '%PH0P220MB0586F3B360877DE7E11D2428D7682%';

-- ===== 7. Musician's Friend: the bounce notice's own Message-ID (status already to_research) =====
update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n[2026-11-25] Bounce notice Message-ID <fb8614cc-03b6-4ae3-af9f-f52ff605d539@LV3P220MB1756.NAMP220.PROD.OUTLOOK.COM>, dated Nov 24 2026 08:08:26 UTC (2:08 am CT): 550 5.4.1, charitablegiving was not found at musiciansfriend.com. The undelivered letter was "Request on letterhead: free youth DJ and music-education program in Chicago (Ras Tafari Inc., EIN 42-3036705)" with RTI-Musicians-Friend-Request-Letter.pdf and the IRS determination letter. [src:msgid-fb8614cc-03b6-4ae3-af9f-f52ff605d539]',
  updated_at = now()
where id = '845df475-8d46-4800-bfec-55eb54cae276'
  and coalesce(notes,'') not like '%fb8614cc-03b6-4ae3-af9f-f52ff605d539%';

-- ===== 8. OLD THREADS (logged Nov 25, 2026; events are Jul to Nov 2026). New rows; no matching partner or grant row existed =====
-- 8a. Silent Events (silent-disco headphones): Jul 2026 quote thread
insert into fs_partners (id, name, category, website, email, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes, last_contact_at)
select 'b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'Silent Events (Discglow wireless headphones)', 'Headphones', 'https://silentevents.com', 'jackie@silentevents.com',
  '[{"name":"Jackie Zondlo","title":"Event Logistics & Operations Manager","email":"jackie@silentevents.com"},{"name":"Emily Kennedy-Taber","title":"Account & Sponsorship Coordinator","email":"emily@silentevents.com"}]'::jsonb,
  array[]::text[], array['festivals'], 'on_hold', 'us',
  'Quote only (a purchase, not a donation). Albert asked for a 1,000-headphone new-purchase estimate for the Jul 10, 2026 organizational meeting.',
  'Open question for Stephen/Albert: is Silent Events still wanted for 2027? Jackie asked (Jul 9, 2026) to be told of any update; none is logged since. Estimate of Jul 9, 2026 is $49,599 (prices may have changed). Owner: Albert Harris (contact on thread); due date unknown.',
  null::date,
  'Phone inquiry Jul 2, 2026; thread Jul 2 to Jul 9, 2026',
  'OLD THREAD logged Nov 25, 2026. Quote facts: Jul 7 like-new purchase about $36,000 (this year only if paid within the week) or rental about $7,000, 90-day warranty on like-new; Jul 9 estimate for 1,000 NEW Discglow three-channel headphones, 4 multi-listener systems, transmitters, 25 cabling bags, charging docs, one-way shipping: $49,599 total, 60-day lead time after payment, +4% if paid by credit card. Not a partner commitment; no value recorded in commitment_value. Outcome of the Jul 10 meeting unknown.',
  '2026-07-09 20:27:10+00'
where not exists (select 1 from fs_partners where id = 'b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22' or name like 'Silent Events%');

-- 8b. S. Wolf & Associates (insurance broker for the Lio general liability policy)
insert into fs_partners (id, name, category, email, contacts, partner_types, stage, ball_with, commitment, next_step, next_step_due, source, notes, last_contact_at)
select 'c3f702e4-7d9c-4051-9e83-2f4bad6c9a33', 'S. Wolf & Associates (Lio Insurance broker): general liability policy', 'Other', 'trey@swolfways.com',
  '[{"name":"Charlie Kosyla","email":"charlie@swolfways.com","title":"S. Wolf & Associates (placed the policy)"},{"name":"Trey Elder","email":"trey@swolfways.com","title":"Director of Account Management and Retention (issues COIs)"},{"name":"Oskar Nasman","title":"Lio Insurance underwriter","email":"oskar.nasman@lioinsurance.com"}]'::jsonb,
  array[]::text[], 'confirmed', 'us',
  'Vendor, not a donor. Policy LIO1100198319-00 (Lio Insurance, Nonprofit and Social Services) bound Oct 22, 2026, effective Oct 22, 2026 to Oct 22, 2027; premium $650, direct bill, fixed annual.',
  'Stephen to confirm from his mailbox, three items still open on the Confirmation of Coverage (LIO1100198319-00): (1) the "Comments and Subjectivities" items are cleared, (2) the Signed TRIA Rejection Form is returned, (3) the Signed LIO Application is returned; plus (4) the $650 premium is paid through the LIO payment portal (guide attached to the Oct 23 email). The Chicago Park District certificate EXISTS: Trey Elder sent "2627 COI - Chicago Park District.pdf" and the endorsement page Oct 27, 2026 12:01:19 CDT. Whether items 1 to 3 were ever closed is not answerable from the emails; owner Stephen; due date unknown.',
  null::date,
  'Emails Oct 23, 2026',
  'OLD THREAD logged Nov 25, 2026. Oct 27, 2026: Stephen asked Charlie to reissue the COI naming the Chicago Park District as additional insured (15:24:29 UTC, BOB 20261027-152433Z); Charlie answered 15:26:34 UTC that Trey would provide it; Trey sent "2627 COI - Chicago Park District.pdf" and "Endorsement page (1).pdf" at 17:01:19 UTC (BOB 20261027-170143Z). Oct 23 COI (certificate holder DCASE, waiver of subrogation, additional insured City of Chicago DCASE) describes the festival 07/24-07/25/2027 "with 150 attendees": 150 is the festival figure on the COI and is NOT the Rainbow Wednesdays goal (300 a night); flag if it is ever copied into a Rainbow Wednesdays packet. Vendor row; Stephen may prefer notes only.',
  '2026-10-23 18:06:18+00'
where not exists (select 1 from fs_partners where id = 'c3f702e4-7d9c-4051-9e83-2f4bad6c9a33' or name like 'S. Wolf%');

-- 8c. John Pearson: "Who do we know?" reply
insert into fs_partners (id, name, category, email, contacts, partner_types, stage, ball_with, ask, next_step, next_step_due, source, notes, last_contact_at)
select 'd40813f5-8ead-4162-8f94-305cbe7dab44', 'John Pearson (Field Marshall): network introductions for invitation-only funders', 'Other', 'chicagotacticalmedic@icloud.com',
  '[{"name":"John Pearson","email":"chicagotacticalmedic@icloud.com","title":"addressed as Field Marshall"}]'::jsonb,
  array['marketing'], 'reached_out', 'them',
  'Warm introductions to the 12 invitation-only funders in Stephen''s Oct 31, 2026 "Who do we know?" email.',
  'John said Oct 31 he would check with a couple of people and get back; nothing logged since, and our Nov 13 reply-by date has passed. One short email nudge (proposed by us, not agreed with John): Mon Nov 30, 2026, subject to the CPD hold; Stephen decides. Owner: Stephen. Online only.',
  '2026-11-30',
  'Reply Oct 31, 2026 to our "Who do we know?" email',
  'OLD THREAD logged Nov 25, 2026. Organization he represents: unknown. Our email asked for introductions only, no money.',
  '2026-11-01 03:43:09+00'
where not exists (select 1 from fs_partners where id = 'd40813f5-8ead-4162-8f94-305cbe7dab44' or email = 'chicagotacticalmedic@icloud.com');

-- ===== 9. One activity entry per source email. created_at = the real send time. Guard = Message-ID fragment (frag) already in any summary. =====
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select v.pid::uuid, 'email', v.summary || ' [src:msgid-' || v.frag || ']', v.stage_after, 'stephen@selassiefest.com', 'Claude', v.at::timestamptz
from (values
 ('965d7d84-5464-4632-bac0-c97920af6468', '6b06b1681931b_1011aae0831569', 'reached_out', '2026-11-25 09:59:04+00',
  'Nov 25, 2026 3:59 am CT: Oriental Trading (orientaltrading@approveforgood.com) confirmed our donation request was RECEIVED (reviewed in order, reply by email, do not contact outside their system). Receipt only; no decision. Message-ID <6b06b1681931b_1011aae0831569@ip-10-134-5-254.us-east-2.compute.internal.mail>.'),
 ('965d7d84-5464-4632-bac0-c97920af6468', '6b06fc39533f2_1011aae08420a5', 'declined', '2026-11-25 15:18:17+00',
  'Nov 25, 2026 9:18 am CT: Oriental Trading ANSWER: cannot accommodate the request at this time (high volume); asks us to reapply with the address on our 501(c)(3) form and says they will gladly reconsider. Not a final no. Reapply with the IRS-letter address. Message-ID <6b06fc39533f2_1011aae08420a5@ip-10-134-5-254.us-east-2.compute.internal.mail>.'),
 ('a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11', 'DS2PR17MB2950417E6113D80AA4DD1F868D84432', 'committed', '2026-11-25 16:14:56+00',
  'Nov 25, 2026 10:14 am CT: Lindsey Auz, Marketing Manager, Andy''s Frozen Custard (lindsey.auz@eatandys.com), "Donation Request - Ras Tafari Inc.": would love to donate 50 mini custard cups for the event on March 9th; pickup the day of or day prior, any time after 11 AM; will share with the Chicago team on Archer Avenue. APPROVAL/offer only; nothing delivered or received. No dollar value. Event date conflicts with our May 18, 2027 request. Message-ID <DS2PR17MB2950417E6113D80AA4DD1F868D84432@DS2PR17MB295041.namprd17.prod.outlook.com>.'),
 ('6e38015f-cccf-4c25-bc91-34afaa27b5c3', '712f6175-d9c3-4a40-aac7-e7ab77a35b38', 'reached_out', '2026-11-25 09:42:30+00',
  'Nov 25, 2026 3:42 am CT: 4imprint One By One confirmation (onebyone@4imprint.com): application received, up to six weeks to process, they will email the applicant. Receipt only; no decision. Message-ID <712f6175-d9c3-4a40-aac7-e7ab77a35b38@us-exch-01.4imprint.com>.'),
 ('b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'CA+PaOCugVKPLPFkYPxPRH12rr0VDS9QRtJb2n+XLDj=LbPMDMQ', 'on_hold', '2026-07-02 19:35:39+00',
  'Jul 2, 2026 2:35 pm CT: Emily Kennedy-Taber (Silent Events) thanked Albert for his phone inquiry; estimate to follow in a few business days; flyer attached. Message-ID <CA+PaOCugVKPLPFkYPxPRH12rr0VDS9QRtJb2n+XLDj=LbPMDMQ@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'CAL9n7VBKCbCdSN4p+JS2uLaZs9nEXqxmNrMDSBdcDpjDuJPeeg', 'on_hold', '2026-07-07 21:09:07+00',
  'Jul 7, 2026 4:09 pm CT: Jackie Zondlo (Silent Events): 2026 timing unlikely; like-new headphones about $36,000 if paperwork and payment by end of week, or rental about $7,000; 90-day warranty on like-new; interested in 2027. Message-ID <CAL9n7VBKCbCdSN4p+JS2uLaZs9nEXqxmNrMDSBdcDpjDuJPeeg@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'CAKSj72grjAv4YNqpcBguj+7Gq7_camf_NxYf5kSF77JN-ptYGg', 'on_hold', '2026-07-07 22:09:26+00',
  'Jul 7, 2026 5:09 pm CT: Albert (from selassiefest@gmail.com) asked Jackie for an itemized estimate for the NEW purchase only, for the Jul 10, 2026 10 am organizational meeting. Message-ID <CAKSj72grjAv4YNqpcBguj+7Gq7_camf_NxYf5kSF77JN-ptYGg@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'CAL9n7VAa9VohuJ4kFFismh5Fd5GjxqRa2kcmRwFeanb77jL+kQ', 'on_hold', '2026-07-09 19:15:29+00',
  'Jul 9, 2026 2:15 pm CT: Jackie Zondlo sent the estimate (PDF attached): 1,000 new Discglow three-channel headphones at $45, 4 multi-listener systems, transmitters, 25 cabling bags, charging docs, shipping; TOTAL $49,599; 60-day lead time after payment; +4% for credit card; prices may change. Offered to start paperwork on approval. Message-ID <CAL9n7VAa9VohuJ4kFFismh5Fd5GjxqRa2kcmRwFeanb77jL+kQ@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'CAKSj72hnQcXUVgdSSXW_3mFE8JTrC01CB+8nD=keOziH10oYYA', 'on_hold', '2026-07-09 19:47:16+00',
  'Jul 9, 2026 2:47 pm CT: Albert acknowledged the estimate, ready for his Friday meeting. No approval. Message-ID <CAKSj72hnQcXUVgdSSXW_3mFE8JTrC01CB+8nD=keOziH10oYYA@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22', 'CAL9n7VAn820wzMUukfRVFC85XsTbfnhh047epe_ufuFBQLDYAQ', 'on_hold', '2026-07-09 20:27:10+00',
  'Jul 9, 2026 3:27 pm CT: Jackie replied that she would wait for our update. Last contact; nothing later logged. Message-ID <CAL9n7VAn820wzMUukfRVFC85XsTbfnhh047epe_ufuFBQLDYAQ@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('c3f702e4-7d9c-4051-9e83-2f4bad6c9a33', 'CAH9Z7cfe-FOuEQiu9_R+GTGAyz1kv8aE+cOS1ofXAnfVnKkhsQ', 'confirmed', '2026-10-23 16:43:21+00',
  'Oct 23, 2026 11:43 am CT: Charlie Kosyla (S. Wolf & Associates) to Stephen, cc Trey Elder: general liability policy LIO1100198319-00 bound; attached Confirmation of Coverage (effective Oct 22, 2026 to Oct 22, 2027, premium $650, direct bill; still waiting on "Comments and Subjectivities"), policy, application, and our 2026 COI, 2027 quote request and CPD ARCS application. Asked Trey for an immediate COI with waiver of subrogation per the park district contact. Message-ID <CAH9Z7cfe-FOuEQiu9_R+GTGAyz1kv8aE+cOS1ofXAnfVnKkhsQ@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('c3f702e4-7d9c-4051-9e83-2f4bad6c9a33', 'CAPb8-9so4E_DMxMmnx0qtF+WOar=0K8iJsA0q67ha-St7+_=xw', 'confirmed', '2026-10-23 18:06:18+00',
  'Oct 23, 2026 1:06 pm CT: Trey Elder (S. Wolf) sent the COI for the 2027 fest (certificate holder City of Chicago Dept of Cultural Affairs & Special Events; additional insured and waiver of subrogation; states 150 attendees for the 07/24-25/2027 festival) and the LIO payment-portal guide for direct payment. COI delivered to us; our acknowledgment not logged. A second COI naming the Chicago Park District followed Oct 27 (see the three Oct 27 entries). Message-ID <CAPb8-9so4E_DMxMmnx0qtF+WOar=0K8iJsA0q67ha-St7+_=xw@mail.gmail.com>. Logged Nov 25, 2026.'),
 ('c3f702e4-7d9c-4051-9e83-2f4bad6c9a33', '010001a17df67fe3-75c263ce-814a-484f-8235-1b5ac8ac1636-000000', 'confirmed', '2026-10-27 15:24:29+00',
  'Oct 27, 2026 10:24 am CT (15:24:29 UTC): Stephen (stephen@selassiefest.com) asked Charlie Kosyla (contactus@swolfways.com), subject "URGENT: Policy LIO1100198319-00: Chicago Park District must be ADDITIONAL INSURED", to reissue the certificate with the Chicago Park District (4830 S. Western Ave.) as certificate holder and additional insured, primary and non-contributory (CG 20 26 or equivalent), description naming the Rainbow DJ Lab and Full Spectrum programs at Rainbow Beach Park under a CPD ARCS partnership; attached Ras-Tafari-Inc-Park-District-COI-request.pdf. Message-ID <010001a17df67fe3-75c263ce-814a-484f-8235-1b5ac8ac1636-000000@email.amazonses.com>. BOB 20261027-152433Z. Logged Nov 25, 2026.'),
 ('c3f702e4-7d9c-4051-9e83-2f4bad6c9a33', 'src-charlie-reply-2026-10-27T152634Z', 'confirmed', '2026-10-27 15:26:34+00',
  'Oct 27, 2026 10:26 am CT (15:26:34 UTC): Charlie Kosyla (S. Wolf & Associates) replied to Stephen that Trey would provide the Park District certificate if he had not already. Evidence is the quoted text inside Trey''s 17:01 UTC email; Charlie''s own Message-ID was not captured (no separate BOB file). Logged Nov 25, 2026.'),
 ('c3f702e4-7d9c-4051-9e83-2f4bad6c9a33', 'CAPb8-9uPPKEjHSNj0-yRzs5+cXL-1KjRCHw1JFDoy=NWQHxvYw', 'confirmed', '2026-10-27 17:01:19+00',
  'Oct 27, 2026 12:01:19 pm CT (17:01:19 UTC): Trey Elder (S. Wolf) sent the COI naming the Chicago Park District ("2627 COI - Chicago Park District.pdf") and "Endorsement page (1).pdf", apologizing for the delay (out sick the prior week). COI for the Park District DELIVERED to us; our acknowledgment not logged. Still open on the Confirmation of Coverage: Comments and Subjectivities, Signed TRIA Rejection Form, Signed LIO Application. Message-ID <CAPb8-9uPPKEjHSNj0-yRzs5+cXL-1KjRCHw1JFDoy=NWQHxvYw@mail.gmail.com>. BOB 20261027-170143Z. Logged Nov 25, 2026.'),
 ('d40813f5-8ead-4162-8f94-305cbe7dab44', '85B93916-72F0-4FA4-8B74-00B53C338EF9', 'reached_out', '2026-11-01 03:43:09+00',
  'Oct 31, 2026 10:43 pm CT: John Pearson replied to "Who do we know? Twelve names that could open doors for the DJ Lab": off the top he knows no one with relationships to any of the 12; will check with a couple of people and get back. Message-ID <85B93916-72F0-4FA4-8B74-00B53C338EF9@icloud.com>. Logged Nov 25, 2026.')
) as v(pid, frag, stage_after, at, summary)
where exists (select 1 from fs_partners p where p.id = v.pid::uuid)
  and not exists (select 1 from fs_partner_activity a where a.summary like '%' || v.frag || '%');

-- ===== 10. Calendar =====
update rti_calendar_events set active = false, notes = coalesce(notes,'') || ' SUPERSEDED Nov 25: Andy''s approved by email; see andys-confirm-2026-11-25.'
where key = 'andys-check-2026-12-10' and active = true;
update rti_calendar_events set active = false, notes = coalesce(notes,'') || ' SUPERSEDED Nov 25: Oriental declined, reapply today (oriental-reapply-2026-11-25).'
where key = 'oriental-check-2026-12-28' and active = true;
update rti_calendar_events set active = false, notes = coalesce(notes,'') || ' CANCELLED Nov 25: DeKalb CCF declined (no new requests from outside DeKalb County).'
where key in ('wurlitzer-nudge-2026-12-02','wurlitzer-file-2027-01-01') and active = true;
update rti_calendar_events set notes = replace(notes, 'G 013d3944 DeKalb CCF', 'G 013d3944 DeKalb CCF (DECLINED Nov 25: skip)')
where key = 'jan15-deadlines-2027-01-15' and notes like '%G 013d3944 DeKalb CCF%' and notes not like '%DECLINED Nov 25%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes) values
 ('andys-confirm-2026-11-25', 'Andy''s Frozen Custard: reply to Lindsey Auz (confirm event date, Archer Ave pickup)', timestamptz '2026-11-25 16:00-06', timestamptz '2026-11-25 16:15-06', 'Email: lindsey.auz@eatandys.com',
  'Draft only; send after Stephen says send; thread to her Message-ID DS2PR17MB2950417E6113D80AA4DD1F868D84432@DS2PR17MB295041.namprd17.prod.outlook.com. She wrote March 9; our request said May 18, 2027. Partner a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11, grant 8c21a12a.'),
 ('oriental-reapply-2026-11-25', 'Oriental Trading: reapply with the 501(c)(3) address (765 E 154th St, South Holland)', timestamptz '2026-11-25 17:00-06', timestamptz '2026-11-25 17:15-06', 'https://orientaltrading.requestitem.com/',
  'Their Nov 25 answer invites reapplication with the address on the IRS letter. Grant d14f32bd, partner 965d7d84. Form only; Stephen presses Submit.'),
 ('pearson-nudge-2026-11-30', 'John Pearson: one short email nudge on the 12-funder introductions', timestamptz '2026-11-30 09:30-06', timestamptz '2026-11-30 09:45-06', 'Email: chicagotacticalmedic@icloud.com',
  'Proposed by us, not agreed with John. Subject to the CPD hold; Stephen decides. Partner d40813f5-8ead-4162-8f94-305cbe7dab44. Send only after Stephen says send.')
on conflict (key) do nothing;

commit;

-- ===== Verify =====
select 'oriental grant' as t, status as s, next_step_due::text as d from fs_grant_deadlines where id = 'd14f32bd-d2e1-483f-b2cc-ef800b3e7ac8'
union all select 'oriental partner', stage || '/' || ball_with, next_step_due::text from fs_partners where id = '965d7d84-5464-4632-bac0-c97920af6468'
union all select 'dekalb grant', status, next_step_due::text from fs_grant_deadlines where id = '013d3944-c420-4534-b9af-7f3a604c0235'
union all select 'andys grant', status, next_step_due::text from fs_grant_deadlines where id = '8c21a12a-bf69-4a3d-abc4-728d916f34ee'
union all select 'new partner ' || left(name, 24), stage || '/' || ball_with, next_step_due::text from fs_partners where id in ('a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11','b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22','c3f702e4-7d9c-4051-9e83-2f4bad6c9a33','d40813f5-8ead-4162-8f94-305cbe7dab44')
union all select 'activity rows from this batch (expect 16 on first run)', count(*)::text, null from fs_partner_activity where summary like '%[src:msgid-%' and partner_id in ('965d7d84-5464-4632-bac0-c97920af6468','a1d5e0c2-5b7a-4e3f-9c61-0d2f8b4a7e11','6e38015f-cccf-4c25-bc91-34afaa27b5c3','b2e6f1d3-6c8b-4f40-8d72-1e3a9c5b8f22','c3f702e4-7d9c-4051-9e83-2f4bad6c9a33','d40813f5-8ead-4162-8f94-305cbe7dab44')
union all select 'event ' || key, active::text, starts_at::text from rti_calendar_events where key in ('andys-check-2026-12-10','oriental-check-2026-12-28','wurlitzer-nudge-2026-12-02','wurlitzer-file-2027-01-01','andys-confirm-2026-11-25','oriental-reapply-2026-11-25','pearson-nudge-2026-11-30');

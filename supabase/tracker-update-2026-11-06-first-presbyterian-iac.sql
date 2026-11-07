-- Nov 6, 2026: First Presbyterian (Jordan Muhammad reply) + Illinois Arts Council (Angelique Grandone, two replies). Safe to re-run.
begin;

-- 1. First Presbyterian Church of Chicago
update fs_partners set
  last_contact_at = '2026-11-06T17:49:12Z',
  commitment = 'Church can share the invite and consider recommending congregation students; can display a Rainbow Wednesday flyer or poster. Cannot sponsor a DJ booth or host an event free. Jordan Muhammad (paid by commission only) offers a discounted rate on a hosted event if we want a quote.',
  next_step = 'Reply to Jordan Muhammad (cc pastor@chicagofirstchurch.org): thank him; accept the invite share, student recommendations and flyer/poster (send a flyer PDF); decide whether to ask for the discounted holiday-party quote (Stephen: yes or no); drop the DJ-booth sponsorship ask. HELD for CPD GO. Our Nov 4 4:51 PM reply (signed Albert Harris) WAS sent, so the Claude outputs/first-presbyterian draft is superseded. Ball is ours.',
  next_step_due = '2026-11-13',
  ball_with = 'cpd_hold',
  notes = coalesce(notes,'') || E'\n[11/06] Jordan Muhammad replied (Fri Nov 6, 11:49 AM CT, cc Rev. Black; Message-ID <CAGJUqjXvYki8ck+s=CVCfm=vrt19r0EPyAU40E4e8nAFiLNwtQ@mail.gmail.com>, in reply to our Nov 4 4:51 PM message <PH0P220MB058692CA2FE817B873842A7FD7682@PH0P220MB0586.NAMP220.PROD.OUTLOOK.COM>): no capacity now to sponsor a DJ booth or host an event at no cost. WILL: share the invite, consider congregation students to recommend, display a Rainbow Wednesday flyer/poster. OFFER: significantly reduced commission (he is paid only by commission) for a discounted hosted event; quote on request. NOTE: our Nov 4 reply (Albert Harris, 262-344-7075) asked for a Gospel DJ Booth sponsor and a free Christmas celebration; both are declined.'
where id = '772038e9-2ede-4575-8f1e-8022274e1581'
  and notes not like '%[11/06] Jordan Muhammad replied%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '772038e9-2ede-4575-8f1e-8022274e1581','email',
 'Email IN Nov 6 2026 11:49 AM CT from Jordan Muhammad (jordangm1537@gmail.com), cc pastor@chicagofirstchurch.org: no capacity to sponsor a DJ booth or host free; will share the invite, consider congregation students, display flyer/poster; offers discounted commission rate on a hosted event if we want a quote. Msg-ID <CAGJUqjXvYki8ck+s=CVCfm=vrt19r0EPyAU40E4e8nAFiLNwtQ@mail.gmail.com>.',
 'in_conversation','jordangm1537@gmail.com','Jordan Muhammad'
where not exists (select 1 from fs_partner_activity where partner_id='772038e9-2ede-4575-8f1e-8022274e1581' and summary like '%CAGJUqjXvYki8ck%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '772038e9-2ede-4575-8f1e-8022274e1581','email',
 'Email OUT Nov 4 2026 4:51 PM CT from stephen@selassiefest.com (signed Albert Harris, Course Designer) to Jordan Muhammad, cc Rev. Black: answered his questions (hand-picked youth, Gospel DJ Booth sponsor, Christmas family celebration at the church); offered a call. Message-ID <PH0P220MB058692CA2FE817B873842A7FD7682@PH0P220MB0586.NAMP220.PROD.OUTLOOK.COM>. Found sent when Jordan quoted it Nov 6; earlier tracker line said NOT SENT.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='772038e9-2ede-4575-8f1e-8022274e1581' and summary like '%PH0P220MB058692CA2FE817B873842A7FD7682%');

-- 2. Illinois Arts Council: General Operating Support (answers FY28 question)
update fs_grant_deadlines set
  next_step = 'IAC confirmed Nov 6: not eligible for FY28 GOS (March 2027 deadline needs 12 months of programming plus a full year of closed-book financials). FY29 not explicitly confirmed by her. Keep a 2027 activity log; join The Muse newsletter. Recheck when FY29 guidelines post.',
  notes = coalesce(notes,'') || E'\n2026-11-06 Angelique Grandone (Program Director, Angelique.Grandone@illinois.gov, 312-814-4991) replied to our Oct 31 intro (Message-ID <DS5PR09MB1350561FD71EFC9A6859DF1E4EC762@DS5PR09MB13505.namprd09.prod.outlook.com>): RTI cannot meet FY28 GOS (no full 12 months of programming or a full year of closed-book financials by the March deadline). She did not answer whether FY29 is the first cycle.'
where id = '9b0cb0a3-4e22-469f-8ae6-3b6d44db4968'
  and notes not like '%2026-11-06 Angelique Grandone%';

-- 3. Illinois Arts Council: Creative Projects
update fs_grant_deadlines set
  next_step = 'Grandone Nov 6: RTI MAY be eligible for FY28 Creative Project Grant, but IAC is reworking the program and expects significant changes to the application and requirements. She did not give the July 1 date. Stephen: sign up for the weekly newsletter The Muse (link in her signature; arts.illinois.gov) so we see guidelines, timelines and deadlines. Do not draft until guidelines post.',
  next_step_due = '2026-11-13',
  notes = coalesce(notes,'') || E'\n2026-11-06 Grandone reply (Msg-ID <DS5PR09MB1350561FD71EFC9A6859DF1E4EC762@DS5PR09MB13505.namprd09.prod.outlook.com>): may be eligible for FY28 Creative Project Grant; program is being re-worked with significant changes; best way to be notified is The Muse newsletter. Our earlier FY28-opens-about-July-1 assumption is unconfirmed.'
where id = '541f5642-1a02-46b8-8a6f-648a5c1f670f'
  and notes not like '%2026-11-06 Grandone reply%';

-- 4. Illinois Arts Council: Creative Learning Grants for Schools
update fs_grant_deadlines set
  deadline_date = '2027-02-17', opens_date = '2026-12-16',
  next_step = 'Grandone Nov 6: FY28 CLGS guidelines release Dec 16, 2026; deadline Feb 17, 2027. TWO BLOCKERS to check with Powell (Principal Barlow, 773-535-6650, call Nov 9): (1) schools that won an FY26 or FY27 CLGS award cannot apply, so ask if Powell did; (2) CPS partnerships need the arts partner to be an APPROVED CPS VENDOR before applying, and RTI is not (RFQ 26-1355 was NO GO Oct 31). Decide whether a CPS-school route is still viable or pivot to a non-CPS school.',
  next_step_due = '2026-11-09',
  notes = coalesce(notes,'') || E'\n2026-11-06 Grandone reply (Msg-ID <DS5PR09MB135051854A7A54C3ECAA1897DEC762@DS5PR09MB13505.namprd09.prod.outlook.com>): FY28 CLGS guidelines Dec 16, 2026; deadline Feb 17, 2027; schools awarded in FY26 or FY27 are ineligible; CPS partnerships require arts partners to be approved vendors before applying. RTI is not a CPS-approved vendor (see Ingenuity/CPS row, RFQ 26-1355 NO GO).'
where id = 'd2ecf4c4-d513-48cd-a7ea-888edfb2cf34'
  and notes not like '%2026-11-06 Grandone reply%';

commit;
select name, stage, ball_with, next_step_due, last_contact_at from fs_partners where id='772038e9-2ede-4575-8f1e-8022274e1581';
select count(*) acts_today from fs_partner_activity where partner_id='772038e9-2ede-4575-8f1e-8022274e1581' and (summary like '%CAGJUqjXvYki8ck%' or summary like '%PH0P220MB058692CA2FE817B873842A7FD7682%');
select program, status, deadline_date, next_step_due from fs_grant_deadlines where id in ('9b0cb0a3-4e22-469f-8ae6-3b6d44db4968','541f5642-1a02-46b8-8a6f-648a5c1f670f','d2ecf4c4-d513-48cd-a7ea-888edfb2cf34');

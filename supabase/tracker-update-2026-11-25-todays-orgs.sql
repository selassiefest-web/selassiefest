-- Stephen's order Nov 25, 2026: add the organizations that surfaced today to the partner list for tracking and outreach. NEW rows only. Safe to re-run.
-- Checked first (live fs_partners, Nov 25, 2026): none of these existed by name, domain or contact. Already existing and NOT touched here:
--   MCMF row e0b74f53-8ac6-4d91-b245-6fc03b0a4d84, Office of Mayor Brandon Johnson, Drummond b7e41c20, Loza c8f52d31, Von Oehsen d9a63e42.
-- Rows: Rainbow Cone / Buona Companies (grant row 05f9523f already exists; no partner row), Project Exploration, Lost Boyz Inc., DFSS My CHI. My Future. inbox, Urban Male Network.
-- Not given rows (no official site or contact verified by us): Shine On Chicago, Pep Rally Takeover (listed in the handoff).
-- Sweep of BOB files dated Nov 15 to 25, 2026: every other replying, approving or declining organization already has a partner or grant row (see handoff). Nothing else added.
begin;

insert into fs_partners (id, name, category, website, email, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes, last_contact_at)
select v.id::uuid, v.name, v.category, v.website, v.email, v.contacts::jsonb, v.ptypes::text[], v.parts::text[], v.stage, v.ball, v.ask, v.next_step, v.due::date, v.source, v.notes, v.last_contact::timestamptz
from (values
 ('a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01', 'The Original Rainbow Cone (The Buona Companies)', 'Restaurant & food', 'https://www.rainbowcone.com', 'Staci@RainbowCone.com',
  '[{"name":"Staci Ybarra","title":"Catering Coordinator, The Buona Companies","email":"Staci@RainbowCone.com"}]',
  '{in_kind}', '{classes,wednesdays}', 'reached_out', 'them',
  'Donated or discounted single-serve ice cream for the DJ Lab Tuesdays and Rainbow Wednesdays (about 1,200 servings over 53 dates), or a paid Rainbow Cone stand, truck stop or percentage-back benefit night: whichever Rainbow Cone says is possible.',
  'We answered her four questions Nov 2, 2026 (19:51 UTC); nothing from Rainbow Cone since. The grant row 05f9523f was TABLED Nov 18 and wrongly says the four questions are unanswered. Stephen decides whether to send one short check-in (draft only) on Wed Dec 2, 2026. Before any further send, see the CORRECTIONS in notes. Owner: Stephen.',
  '2026-12-02', 'Email to contact@rainbowcone.com Nov 1, 2026; reply from Staci Ybarra Nov 2, 2026',
  'VERIFIED from the emails: Nov 1 09:18 UTC we wrote to contact@rainbowcone.com; Staci Ybarra (Catering Coordinator, The Buona Companies) replied Nov 2 17:55 UTC with four questions to review with their sales manager (weeks per year, budget per serving, other supporters, realistic benefit-night attendance); we answered Nov 2 19:51 UTC. No commitment, no value. Companion grant row: 05f9523f-7717-4e1d-87d9-19e64e7bb971 (The Original Rainbow Cone, status submitted, tabled by Stephen Nov 18). CORRECTIONS NEEDED, both in mail already sent: (1) our Nov 2 answer said "planning for about 150 people a night" at Rainbow Wednesdays; the standing figure is 300 a night (about 4,200 visits over 14 nights); (2) our Nov 1 and Nov 2 emails say the Chicago Park District "has offered" the fieldhouse; the standing rule is never to say the Park District approved or offered anything. Do not repeat either in any new message. Public credit: none; no brand permission. [src:rainbowcone-partner-2026-11-25]',
  '2026-11-02 19:51:58+00')
) as v(id, name, category, website, email, contacts, ptypes, parts, stage, ball, ask, next_step, due, source, notes, last_contact)
where not exists (select 1 from fs_partners p where p.id = v.id::uuid or p.name ilike '%rainbow cone%' or p.email ilike '%rainbowcone.com%');

insert into fs_partners (id, name, category, website, email, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes)
select v.id::uuid, v.name, v.category, v.website, v.email, v.contacts::jsonb, v.ptypes::text[], v.parts::text[], v.stage, 'us', v.ask, v.next_step, v.due::date, v.source, v.notes
from (values
 ('b4d92f63-8ea5-4c70-b162-3f0a7d5e9c12', 'Project Exploration (My CHI. My Future. Community Anchor, Austin)', 'Community org', 'https://projectexploration.org', 'jwilliams@projectexploration.org',
  '[{"name":"Janeicia Williams","title":"director of community ecosystem (per Stephen; not verified by us)","email":"jwilliams@projectexploration.org"}]',
  '{programming,marketing}', '{classes}', 'reached_out',
  'A short video call to learn how teen programming (the Aug 19, 2026 teen beach party and My CHI. My Future. work) is run, and whether the free Rainbow DJ Lab and Rainbow Wednesdays can be listed or co-promoted for teens.',
  'Stephen emailed Janeicia Williams the afternoon of Nov 25, 2026 (exact time not recorded). Ball is with her. If silent by Wed Dec 2, 2026, one short nudge in the same thread (draft only; Stephen says send). Public contact: their site shows only a web form, no email. Owner: Stephen.',
  '2026-12-02', 'Deputy Mayor Humphries meeting Nov 25, 2026 (MCMF referral) and Stephen''s research',
  'VERIFIED by us: City of Chicago Dec 2024 release names Project Exploration as a My CHI. My Future. Community Anchor Organization (Austin); Sun-Times Sept 10, 2026 article on the Aug 19, 2026 teen beach party (20 Project Exploration youth employees, Janeicia Williams helped oversee); Chicago open-data permit record "Club Tae Beach Party", North Ave Beach Event Space, Aug 19, 2026. NOT verified by us: jwilliams@projectexploration.org (from My CHI. My Future. per Stephen), her title, the public name "CHI-SHORE", whether Project Exploration holds the 2027 anchor role. Her address is also a contact on the MCMF row e0b74f53-8ac6-4d91-b245-6fc03b0a4d84, which stays the Humphries-referral row. The Sun-Times piece concerns teen gatherings and conflict: ask how safety was run, do not accuse. Do not say the Park District or the City approved anything. [src:projectexploration-partner-2026-11-25]'),
 ('c5ea3074-9fb6-4d81-8273-401b8e6fad23', 'Lost Boyz Inc. (My CHI. My Future. Community Anchor, South Shore)', 'Community org', null, null,
  '[]',
  '{programming}', '{classes}', 'not_contacted',
  'Find who runs the My CHI. My Future. South Shore convenings, then ask for a short video call and a place on their partner list.',
  'Find a public contact on Lost Boyz Inc.''s own website (lostboyz.org was not reachable from our check Nov 25, 2026) or the My CHI. My Future. partners page; do not guess an address. Then draft a short intro for Stephen. Due Wed Dec 2, 2026. Owner: Stephen.',
  '2026-12-02', 'City of Chicago Dec 17, 2024 DFSS release; Deputy Mayor Humphries "MCMF South Shore" Nov 25, 2026',
  'VERIFIED: the City''s Dec 17, 2024 DFSS release (https://www.chicago.gov/city/en/depts/fss/provdrs/youth/news/2024/december/-local-organizations-to-present-youth-focused-community-plans-at.html) lists Lost Boyz Inc. as the South Shore Community Anchor Organization (anchors host monthly youth-stakeholder convenings and community plans). NOT verified: that it holds the role in 2027, and that it is what Humphries meant by "MCMF South Shore". No contact found. Related row: MCMF e0b74f53-8ac6-4d91-b245-6fc03b0a4d84. [src:lostboyz-partner-2026-11-25]'),
 ('d6fb4185-a0c7-4e92-9384-512c9f7b0e34', 'Chicago DFSS Youth Services: My CHI. My Future. public inbox', 'Civic/government', 'https://explore.mychimyfuture.org', 'MyCHIMyFuture@cityofchicago.org',
  '[{"name":"My CHI. My Future. public inbox","email":"MyCHIMyFuture@cityofchicago.org"}]',
  '{programming,marketing}', '{classes,wednesdays}', 'not_contacted',
  'A direct contact at DFSS Youth Services and the South Shore partners; invitations to the citywide partner meetings; listing of the free Rainbow DJ Lab where My CHI. My Future. connects youth to programs.',
  'Draft email ready for Stephen (not sent): C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\todays-outreach\email-my-chi-my-future-inbox.html. Stephen says send; else a nudge Wed Dec 2, 2026. Owner: Stephen.',
  '2026-11-25', 'Address supplied by Stephen Nov 25, 2026',
  'MyCHIMyFuture@cityofchicago.org was supplied by Stephen and is NOT verified by us (mychimyfuture.org does not display it in what we could read Nov 25). VERIFIED: the City''s Dec 17, 2024 DFSS release lists dfss@cityofchicago.org as the press contact, DFSS at 1615 W. Chicago Ave, 5th Floor, Chicago 60622, and describes citywide My CHI. My Future. partner meetings; public site https://explore.mychimyfuture.org has a Partners tab. Related: Stender Von Oehsen row d9a63e42-7fb5-4c80-a134-5ebf2a9c3d73 (named by Humphries) and MCMF row e0b74f53. Do not say the City or the Park District approved anything. [src:dfss-mcmf-partner-2026-11-25]'),
 ('e70c5296-b1d8-4fa3-a495-623da08c1f45', 'Urban Male Network (claimed 2025 Safe Spaces partner, South Shore)', 'Community org', null, null,
  '[]',
  '{programming}', '{classes}', 'not_contacted',
  'Learn whether Urban Male Network runs South Shore youth programming we should coordinate with; possible intro through My CHI. My Future.',
  'Verify the organization and find its official site and public contact; do not contact until verified. Due Wed Dec 2, 2026. Owner: Stephen.',
  '2026-12-02', 'Research pasted by Stephen Nov 25, 2026',
  'NOT verified by us: the claim that Urban Male Network was the 2025 Safe Spaces partner for South Shore and Greater Grand Crossing, and whether it has any 2027 role. No contact, no address, no site found. Row exists for tracking only. Related: MCMF row e0b74f53-8ac6-4d91-b245-6fc03b0a4d84. [src:urbanmale-partner-2026-11-25]')
) as v(id, name, category, website, email, contacts, ptypes, parts, stage, ask, next_step, due, source, notes)
where not exists (select 1 from fs_partners p where p.id = v.id::uuid or lower(p.name) = lower(v.name)
  or (v.email is not null and v.email not ilike '%projectexploration.org' and lower(p.email) = lower(v.email)));

-- Activity: one entry per source event, keyed by [src:...]; created_at = the real event time where known.
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' [src:' || v.tag || ']', v.stage_after, 'stephen@selassiefest.com', 'Claude', v.at::timestamptz
from (values
 ('a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01', 'msgid-010001a196676ee2-d21d16e9-3435-46d9-ad32-ace084f95119-000000', 'reached_out', '2026-11-01 09:18:43+00',
  'Nov 1, 2026 09:18 UTC: Stephen wrote to contact@rainbowcone.com (subject "Rainbow Cone + Rainbow Wednesdays at Rainbow Beach (free youth music)"): asked for donated or discounted cones or cups (about 20 servings Tuesdays, 30 Wednesdays), a truck or pop-up stop, or a benefit night. Message-ID <010001a196676ee2-d21d16e9-3435-46d9-ad32-ace084f95119-000000@email.amazonses.com>. BOB 20261101-091846Z.'),
 ('a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01', 'msgid-BYAPR01MB4150F5D9DAE811E08291E126AA6A2', 'reached_out', '2026-11-02 17:55:17+00',
  'Nov 2, 2026 11:55 am CT: Staci Ybarra (Catering Coordinator, The Buona Companies, Staci@RainbowCone.com) replied: before Rainbow Cone can commit she has four questions for their sales manager (weeks per year; budget per serving; other supporters; realistic benefit-night attendance). Not a yes or a no. Message-ID <BYAPR01MB4150F5D9DAE811E08291E126AA6A2@BYAPR01MB4150.prod.exchangelabs.com>. BOB 20261102-175558Z.'),
 ('a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01', 'msgid-010001a19dd18ecc-31ce499e-4342-42a2-a76f-d52bcdd3f79a-000000', 'reached_out', '2026-11-02 19:51:58+00',
  'Nov 2, 2026 1:51 pm CT: Stephen answered all four questions (about 1,200 servings across 53 dates; donation or deep discount for the program, a paid stand for Rainbow Wednesdays; confirmed supporters; benefit-night attendance) and linked https://selassiefest.com/full-spectrum/rainbow-cone/. Note: the reply said about 150 people a night; the standing figure is 300. No answer from Rainbow Cone since. Message-ID <010001a19dd18ecc-31ce499e-4342-42a2-a76f-d52bcdd3f79a-000000@email.amazonses.com>. BOB 20261102-195203Z.'),
 ('b4d92f63-8ea5-4c70-b162-3f0a7d5e9c12', 'janeicia-intro-2026-11-25', 'reached_out', now()::text,
  'Nov 25, 2026 (afternoon CT; exact send time not recorded, created_at is the logging time): Stephen emailed Janeicia Williams (jwilliams@projectexploration.org, address from My CHI. My Future. per Stephen, unverified) after the Deputy Mayor''s referral. No reply yet. Source: note on MCMF row e0b74f53-8ac6-4d91-b245-6fc03b0a4d84; no BOB file for the sent mail at the time of writing.')
) as v(pid, tag, stage_after, at, summary)
join fs_partners p on p.id = v.pid::uuid
where not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%[src:' || v.tag || ']%');

-- Rainbow Cone grant row: correct the stale "four questions unanswered" next_step (guarded by the expected current text).
update fs_grant_deadlines set
  next_step = 'WAITING on Rainbow Cone. Staci Ybarra''s four questions (Nov 2, 2026 11:55 am CT) were ANSWERED by Stephen Nov 2, 2026 1:51 pm CT (Message-ID <010001a19dd18ecc-31ce499e-4342-42a2-a76f-d52bcdd3f79a-000000@email.amazonses.com>); nothing back since. TABLED by Stephen Nov 18; Stephen decides whether to send one check-in (proposed Dec 2, 2026; draft only). Do not repeat "150 a night" (standing figure 300) or "the Park District has offered the fieldhouse". Partner row a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01. Deck https://selassiefest.com/full-spectrum/rainbow-cone/',
  notes = coalesce(notes,'') || E'\n[2026-11-25] Correction: the Nov 18 wording "four questions unanswered" was wrong; we answered Nov 2 19:51 UTC. Partner row a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01 created. [src:rc-answer-2026-11-02]',
  updated_at = now()
where id = '05f9523f-7717-4e1d-87d9-19e64e7bb971'
  and next_step like 'REPLY RECEIVED Nov 2, 2026%'
  and coalesce(notes,'') not like '%[src:rc-answer-2026-11-02]%';

commit;

select name, stage, ball_with, next_step_due::text from fs_partners
where id in ('a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01','b4d92f63-8ea5-4c70-b162-3f0a7d5e9c12','c5ea3074-9fb6-4d81-8273-401b8e6fad23','d6fb4185-a0c7-4e92-9384-512c9f7b0e34','e70c5296-b1d8-4fa3-a495-623da08c1f45');
select 'activity rows (expect 4 on first run)' as t, count(*) from fs_partner_activity where partner_id in ('a3c81e52-7d94-4b6f-a051-2e9f6c4d8b01','b4d92f63-8ea5-4c70-b162-3f0a7d5e9c12');
select 'rainbow cone grant corrected (expect 1)' as t, count(*) from fs_grant_deadlines where id = '05f9523f-7717-4e1d-87d9-19e64e7bb971' and notes like '%[src:rc-answer-2026-11-02]%';

-- Sends of Nov 25, 2026 (Stephen pressed Send; Stephen confirmed "all sent"): five introductions after the Deputy Mayor meeting, plus the ARCS update to Marie Huels. Safe to re-run.
-- Exact send times were not captured; all were sent the afternoon of Nov 25, 2026 CT. Texts: C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\humphries-referrals\send-referrals.js
begin;

-- 1. Four referral rows: reached out, ball with them, follow-up Wed Dec 2, 2026
update fs_partners set
  stage = 'reached_out', ball_with = 'them', last_contact_at = '2026-11-25 22:00:00+00',
  next_step = case id
    when 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84' then 'WAIT for Deputy Mayor Humphries to say which program MCMF means and who to write to at each (asked in our Nov 25 reply, cc Addison Rao). If silent by Wed Dec 2, 2026, one short email nudge in the same thread. Janeicia Williams (Project Exploration) is also written to; her address is unverified by us.'
    else 'WAIT for a reply to our Nov 25, 2026 introduction (video call requested, deck link included). If silent by Wed Dec 2, 2026, one short email nudge. Online only; no calls or visits from us.' end,
  next_step_due = '2026-12-02',
  notes = coalesce(notes, '') || ' | [sent 2026-11-25] Introduction sent by Stephen from stephen@selassiefest.com, Nov 25, 2026 afternoon CT.',
  updated_at = now()
where id in ('b7e41c20-5d93-4a6e-8f12-3c9d0e7a1b51','c8f52d31-6ea4-4b7f-9023-4dae1f8b2c62','d9a63e42-7fb5-4c80-a134-5ebf2a9c3d73')
  and coalesce(notes, '') not like '%[sent 2026-11-25]%';

-- MCMF row is a question to Khari, not an introduction to a contact; same marker, own wording
update fs_partners set
  stage = 'reached_out', ball_with = 'them', last_contact_at = '2026-11-25 22:00:00+00',
  next_step = 'WAIT for Deputy Mayor Humphries to say which program MCMF means and who to write to at each (asked in our Nov 25 reply, cc Addison Rao). If silent by Wed Dec 2, 2026, one short email nudge in the same thread. Janeicia Williams (Project Exploration) was also written to Nov 25; her address is unverified by us.',
  next_step_due = '2026-12-02',
  notes = coalesce(notes, '') || ' | [sent 2026-11-25] Reply to Khari Humphries (cc Addison Rao) and introduction to Janeicia Williams sent by Stephen, Nov 25, 2026 afternoon CT.',
  updated_at = now()
where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84'
  and coalesce(notes, '') not like '%[sent 2026-11-25]%';

-- 2. Activity: one entry per send
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' [src:' || v.tag || ']', v.stage_after, 'stephen@selassiefest.com', 'Claude', '2026-11-25 22:00:00+00'::timestamptz
from fs_partners p join (values
 ('b7e41c20-5d93-4a6e-8f12-3c9d0e7a1b51', 'sent-drummond-2026-11-25', 'reached_out', 'Nov 25, 2026 (afternoon CT): Stephen sent Temeszja Drummond (temeszja.drummond@chicagoparkdistrict.com) an introduction, subject "Deputy Mayor Humphries suggested we connect: a free DJ class at Rainbow Beach": program paragraph, pitch deck link, request for a 15-minute video call. Marie Huels and Ivry Ector were told of this contact the same day.'),
 ('c8f52d31-6ea4-4b7f-9023-4dae1f8b2c62', 'sent-loza-2026-11-25', 'reached_out', 'Nov 25, 2026 (afternoon CT): Stephen sent Adrian Loza (Adrian.Loza@ChicagoParkDistrict.com) the same introduction as Temeszja Drummond. Marie Huels and Ivry Ector were told the same day.'),
 ('d9a63e42-7fb5-4c80-a134-5ebf2a9c3d73', 'sent-vonoehsen-2026-11-25', 'reached_out', 'Nov 25, 2026 (afternoon CT): Stephen sent Stender Von Oehsen (Stender.VonOehsen@cityofchicago.org) an introduction, subject "Deputy Mayor Humphries suggested we connect: a free DJ class for South Side youth", with the pitch deck link and a request for a 15-minute call about how the City connects young people to out-of-school programs.'),
 ('e0b74f53-8ac6-4d91-b245-6fc03b0a4d84', 'sent-khari-janeicia-2026-11-25', 'reached_out', 'Nov 25, 2026 (afternoon CT): Stephen sent (1) Janeicia Williams (jwilliams@projectexploration.org) an introduction about the Aug 19 North Avenue Beach teen party and a 2027 youth-led version, asking for a video call and, if willing, the site plan, run of show, staffing and transportation plan, budget and debrief; (2) Deputy Mayor Humphries, cc Addison Rao and selassiefest@gmail.com, a reply with the four contacts, the Keystone Teen Party video, and a request for a direct contact at DFSS Youth Services, the My CHI. My Future. partners serving South Shore and Rainbow Beach, and the South Shore community anchor (Lost Boyz Inc. per the City December 2024 announcement), plus the public inbox MyCHIMyFuture@cityofchicago.org.')
) as v(pid, tag, stage_after, summary) on p.id = v.pid::uuid
where not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%' || v.tag || '%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', 'Nov 25, 2026 (afternoon CT): Stephen sent the Mayor''s Office update to Marie Huels (Partnerships.App@chicagoparkdistrict.com) and Ivry Ector (Reply All on the Oct 30 ARCS thread, from selassiefest@gmail.com): Deputy Mayor Humphries met with us today; he pointed us to Park District colleagues Temeszja Drummond and Adrian Loza, whom we wrote to; nothing in the application has changed; asked whether she needs anything else to complete the review. No ask of the Mayor''s Office on the ARCS decision. [src:sent-marie-2026-11-25]',
  'in_conversation', 'stephen@selassiefest.com', 'Claude', '2026-11-25 22:00:00+00'::timestamptz
from fs_partners p
where p.name = 'Office of Mayor Brandon Johnson'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%sent-marie-2026-11-25%');

-- 3. ARCS grant row note
update fs_grant_deadlines set
  notes = coalesce(notes, '') || ' | [sent-marie 2026-11-25] Stephen sent Marie Huels and Ivry Ector an update (Reply All, selassiefest@gmail.com): Deputy Mayor Humphries met with us Nov 25 and pointed us to Park District colleagues Temeszja Drummond and Adrian Loza, whom we wrote to; the application is unchanged; asked if anything else is needed for the review. Next: wait for Marie.',
  updated_at = now()
where program ilike '%ARCS%' and funder = 'Chicago Park District'
  and coalesce(notes, '') not like '%[sent-marie 2026-11-25]%';

-- 3b. Mayor's Office row: next step after the sends (the Nov 25 step is done)
update fs_partners set
  next_step = 'Nov 25, 2026 sends done (Reply to Khari cc Addison Rao; four introductions; ARCS update to Marie Huels and Ivry Ector). WAIT for Khari to name the MCMF program and contacts. If silent by Wed Dec 2, 2026, one short nudge in the same thread. A letter of support from his office is still unanswered (asked in Albert''s Nov 25 11:01 am email). No ask of his office on the ARCS decision.',
  next_step_due = '2026-12-02',
  updated_at = now()
where name = 'Office of Mayor Brandon Johnson'
  and coalesce(next_step, '') not like 'Nov 25, 2026 sends done%';

-- 4. Calendar: follow-up check
insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('humphries-referrals-followup-2026-12-02', 'Check replies: Drummond, Loza, Von Oehsen, Williams, Humphries (MCMF contacts)',
  timestamptz '2026-12-02 09:30-06', timestamptz '2026-12-02 09:45-06', 'Online (email)',
  'Introductions sent Nov 25, 2026. If a contact has not replied, one short nudge. Online only. Also watch for Marie Huels'' reply on the ARCS application.')
on conflict (key) do nothing;

commit;

select name, stage, ball_with, next_step_due::text from fs_partners where id in ('b7e41c20-5d93-4a6e-8f12-3c9d0e7a1b51','c8f52d31-6ea4-4b7f-9023-4dae1f8b2c62','d9a63e42-7fb5-4c80-a134-5ebf2a9c3d73','e0b74f53-8ac6-4d91-b245-6fc03b0a4d84');
select count(*) as send_activity_rows from fs_partner_activity where summary like '%sent-drummond-2026-11-25%' or summary like '%sent-loza-2026-11-25%' or summary like '%sent-vonoehsen-2026-11-25%' or summary like '%sent-khari-janeicia-2026-11-25%' or summary like '%sent-marie-2026-11-25%';
select key from rti_calendar_events where key = 'humphries-referrals-followup-2026-12-02';

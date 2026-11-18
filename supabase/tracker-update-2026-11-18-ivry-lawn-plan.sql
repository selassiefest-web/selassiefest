-- Nov 18, 2026: Roots & Shoots $250 lawn-plan email SENT to Ivry Ector (CPD, Rainbow Beach). Safe to re-run (keyed on name).
begin;
insert into fs_partners (name, category, email, contacts, partner_types, program_parts, stage, ask, next_step, next_step_due, source, notes, last_contact_at, ball_with)
select 'Chicago Park District (Ivry Ector): Rainbow Wednesday lawn plan, Roots & Shoots $250 art',
 'Civic/government', 'ivry.ector@chicagoparkdistrict.com',
 '[{"name":"Ivry Ector","role":"Chicago Park District, Rainbow Beach Park"}]'::jsonb,
 array['programming'], array['wednesdays'], 'reached_out',
 'Choose one idea for the full $250 or two ideas at $125 each (or her own idea, typed or spoken) for the Roots & Shoots art budget.',
 'Wait for Ivry''s plan: the page''s "Send my plan" button emails it to Stephen. Log it when it arrives. No deadline was set.',
 null, 'Stephen outreach Nov 18, 2026',
 E'Companion row: "Chicago Park District: Rainbow Legacy approval" (separate matter, id fc21556e). This row is only the Rainbow Wednesday lawn plan.\nPrivate page: https://selassiefest.com/donors/?k=yef5fwsf95zjwbgt (circle lawn west of the fieldhouse, 9 ideas: 1 to 7 on the map, 8 The Park Art Hour and 9 The Check Out Wall indoors). Grant: Jane Goodall''s Roots & Shoots Chicago Basecamp Project Grant, $250 awarded Nov 17 (fs_grant_deadlines 38c4ff8b). Idea 8 asks which art teacher or artist already uses the Park''s facilities; nobody is to be contacted about a role in the park without Ivry''s OK. Nothing goes up in the park without her say-so.',
 '2026-11-18 12:00-06', 'them'
where not exists (select 1 from fs_partners where name like 'Chicago Park District (Ivry Ector): Rainbow Wednesday lawn plan%');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Emailed Ivry Ector from stephen@selassiefest.com (cc Stephen), Nov 18, 2026, subject "Rainbow Wednesday: a $250 art grant, and your choice for the lawn" (Resend id 01a1f0ac-1494-7693-a7d1-4d7d028aca09): the $250 Roots & Shoots Project Grant, link to the private lawn-plan page, choose 1 idea ($250) or 2 ($125 each) or her own by typing or speaking, map may be off, nothing goes up without her say-so. No deadline set. Ball is with Ivry.',
 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-18 12:00-06'
from fs_partners p where p.name like 'Chicago Park District (Ivry Ector): Rainbow Wednesday lawn plan%'
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%01a1f0ac-1494-7693-a7d1-4d7d028aca09%');
commit;
select p.name, p.stage, p.ball_with, p.last_contact_at, (select count(*) from fs_partner_activity a where a.partner_id = p.id) activities from fs_partners p where p.name like 'Chicago Park District (Ivry Ector)%';

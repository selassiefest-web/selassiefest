-- Research on the Aug 19, 2026 teen beach party (Project Exploration), pasted by Stephen Nov 25, 2026. Notes only; safe to re-run.
-- VERIFIED by us Nov 25, 2026: (1) Chicago open data permit record https://data.cityofchicago.org/resource/pk66-w54g.json?event_description=Club%20Tae%20Beach%20Party :
-- "Club Tae Beach Party", North Ave Beach Event Space, S Courts, Aug 19, 2026, Approved (requestor named in the record). (2) Chicago Sun-Times, Sept 10, 2026,
-- https://chicago.suntimes.com/moment-of-youth/2026/09/10/teen-beach-gathering-conflict : Project Exploration worked with the Mayor's Office of Education, Youth and Human Services;
-- more than 160 teens; 20 Project Exploration youth employees helped organize; Janeicia Williams (director of community ecosystem, Project Exploration) helped oversee it;
-- the mayor's office invested more than $10,000 (food, transportation, game truck, handwashing station, portable toilet, tables, chairs); "80% planned by young people".
-- NOT verified by us: the public name "CHI-SHORE", the Instagram recap, any 2024 or 2025 edition, and the Park District's 2023 Teen Beach Bash at Rainbow Beach (claimed from a Park District budget PDF).
begin;

update fs_partners set
  next_step = 'Write Janeicia Williams (jwilliams@projectexploration.org, address per My CHI. My Future., unverified by us; Sun-Times: director of community ecosystem, Project Exploration, helped oversee the Aug 19, 2026 teen beach party at North Avenue Beach). Draft ready, Stephen says send: 15-minute video call, and if she is willing the site plan, run of show, staffing and transportation plan, budget and debrief. Also ask Deputy Mayor Humphries which program "MCMF South Shore and MCMF Citywide" means. Our reading of MCMF as My CHI. My Future. is UNCONFIRMED.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes, '') || ' | [chi-shore-research 2026-11-25] Aug 19, 2026 teen beach party, North Avenue Beach: permit record filed as "Club Tae Beach Party" (verified); Sun-Times (verified) says more than 160 teens, 20 Project Exploration youth employees, mayor''s office invested more than $10,000, Janeicia Williams helped oversee. Pasted research also says the public name was CHI-SHORE (Instagram recap, not verified by us), and that a 2024/2025 predecessor and a 2023 Park District Teen Beach Bash at Rainbow Beach (budget PDF) may exist: unverified. The Sun-Times piece is about teen gatherings and conflict, so ask how safety and security were run.',
  updated_at = now()
where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84'
  and coalesce(notes, '') not like '%[chi-shore-research 2026-11-25]%';

commit;

select name, next_step_due::text, (notes like '%[chi-shore-research 2026-11-25]%') as marked from fs_partners where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84';

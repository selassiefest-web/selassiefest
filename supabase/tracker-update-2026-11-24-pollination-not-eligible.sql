-- The Pollination Project: not eligible (org budget must be under $50,000, ours $134,670; project must be volunteer-led with no paid staff; project must already be underway). Sources: thepollinationproject.org/apply and /faq, checked Nov 24, 2026. Safe to re-run.
begin;
update fs_grant_deadlines set status='not_eligible', verified=true, verified_on='2026-11-24', next_step_due=null,
  next_step='Closed Nov 24, 2026: ineligible. Org budget must be under $50,000 (ours $134,670) and the project must be volunteer-led with no paid staff (DJ Lab pays instructors $250 a session). Do not apply.',
  notes=case when coalesce(notes,'') like '%2026-11-24: not eligible (Pollination)%' then notes else coalesce(notes,'')||E'\n2026-11-24: not eligible (Pollination): project budget under $10,000, org budget under $50,000, volunteer-led no paid staff, project already underway, first-time grantees. Daily Grants close Nov 30, reopen Jan 1, 2027.' end
where id='1cefbdf0-fb94-4350-bfb8-ea3f6c2a6883';
select funder,status,next_step_due from fs_grant_deadlines where id='1cefbdf0-fb94-4350-bfb8-ea3f6c2a6883';
commit;

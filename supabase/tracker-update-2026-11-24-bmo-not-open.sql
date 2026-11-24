-- BMO Community Giving: 2027 cycle "coming soon", no portal or contact published. Source: bmo.com BMO Gives page, checked Nov 24, 2026. Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', next_step_due='2027-01-04',
  next_step='BMO Gives page (checked Nov 24, 2026): 2027 Community Giving cycle info "coming soon", no portal or contact email published. Recheck https://www.bmo.com/en-us/main/about-bmo/our-impact/communities/bmo-gives/ on Jan 4, 2027, read the FAQ PDF then, and file the first day the portal opens. Fit is the economic mobility / financial education angle only.',
  notes=case when coalesce(notes,'') like '%2026-11-24: no open round (BMO)%' then notes else coalesce(notes,'')||E'\n2026-11-24: no open round (BMO). "2027 Community Giving grant cycle information will be available soon." Priorities: financial education, economic mobility, strong communities, sustainability. FAQ PDF unread. No contact email on BMO pages. Corporate sponsorships are a separate BMO program (festivals, cultural events).' end
where id='05257d7b-2388-4b77-8380-b641bf2b6214';
select funder,status,next_step_due from fs_grant_deadlines where id='05257d7b-2388-4b77-8380-b641bf2b6214';
commit;

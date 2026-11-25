-- New lead: Dr. Scholl Foundation, LOI window Jan 1-31, 2027 (verified on the portal logon page Nov 25, 2026). Safe to re-run.
begin;

insert into fs_grant_deadlines (funder, program, kind, status, level, project, priority, opens_date, deadline_date, url,
  verified, verified_on, next_step, next_step_due, notes)
select 'Dr. Scholl Foundation', '2027 grant cycle: letter of inquiry', 'dated', 'to_research', 'foundation', 'djclass', 2,
  date '2027-01-01', date '2027-01-31', 'https://www.grantinterface.com/Home/Logon?urlkey=drschollfoundation',
  true, date '2026-11-25',
  'File the LOI Jan 1, 2027 (first day of the window); create the account and read the guidelines before then. Stephen creates the portal account (password is Stephen''s); read the eligibility and guidelines inside the portal before drafting. If approved, application due Mar 31, 2027.',
  date '2027-01-01',
  '[scholl-lead 2026-11-25] Portal logon page: LOIs accepted Jan 1 to Jan 31, 2027 11:59 pm CT; approved applications due Mar 31, 2027 11:59 pm CT. Eligibility, focus and amounts not yet verified on a funder page. drschollfoundation.org did not load on Nov 25.'
where not exists (select 1 from fs_grant_deadlines where funder ilike '%scholl foundation%');

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('scholl-loi-2027-01-01', 'Dr. Scholl Foundation: file the letter of inquiry (window opens today)',
  timestamptz '2027-01-01 10:00-06', timestamptz '2027-01-01 11:00-06', 'https://www.grantinterface.com/Home/Logon?urlkey=drschollfoundation',
  'Window Jan 1-31, 2027.')
on conflict (key) do nothing;

commit;

select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines where funder ilike '%scholl foundation%'
union all select 'event', key, null, starts_at::text from rti_calendar_events where key = 'scholl-loi-2027-01-01';

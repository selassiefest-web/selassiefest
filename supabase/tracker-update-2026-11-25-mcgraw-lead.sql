-- New lead: McGraw Foundation 2027 grant year LOI by email, Dec 15, 2026 (read on funder page Nov 25, 2026). Safe to re-run.
begin;

insert into fs_grant_deadlines (funder, program, kind, status, level, project, priority, opens_date, deadline_date, amount, url,
  eligibility, verified, verified_on, next_step, next_step_due, notes)
select 'McGraw Foundation', '2027 grant year: letter of inquiry', 'dated', 'ready', 'foundation', 'djclass', 1,
  date '2026-12-02', date '2026-12-15', '$2,000-$10,000', 'https://maxmcgrawfoundation.org/2017-grant-year/',
  '501(c)(3) with 509(a)(1) or (a)(2) (ours is 509(a)(2)); generally greater Chicago area; invitation only, except organizations not invited by Dec 1 may email an LOI by Dec 15',
  true, date '2026-11-25',
  'Email the letter of inquiry Wed Dec 2, 2026 (their rule: only if no invitation arrived by Dec 1) to info@maxmcgrawfoundation.org: $10,000 resident instructor pay. PDF ready (two pages or fewer required). They notify by Jan 15, 2027 if a full proposal is requested.',
  date '2026-12-02',
  '[mcgraw-lead 2026-11-25] Pages https://maxmcgrawfoundation.org/guidelines/ and /2017-grant-year/. LOI contents: name, tax ID, address, phone, website, contact; mission and history; programs/focus areas; need and amount.'
where not exists (select 1 from fs_grant_deadlines where funder ilike '%mcgraw foundation%');

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('mcgraw-loi-2026-12-02', 'McGraw Foundation: email the letter of inquiry (due Dec 15)',
  timestamptz '2026-12-02 09:45-06', timestamptz '2026-12-02 10:00-06', 'Email: info@maxmcgrawfoundation.org',
  'Send only if no invitation arrived by Dec 1. $10,000 request; attach the one-page LOI PDF.')
on conflict (key) do nothing;

commit;

select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines where funder ilike '%mcgraw foundation%'
union all select 'event', key, null, starts_at::text from rti_calendar_events where key = 'mcgraw-loi-2026-12-02';

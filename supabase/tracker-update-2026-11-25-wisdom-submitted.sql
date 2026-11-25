-- Wisdom Family Foundation preliminary grant inquiry submitted Nov 25, 2026 (new lead). Safe to re-run.
begin;

insert into fs_grant_deadlines (funder, program, kind, status, level, project, priority, deadline_date, amount, amount_requested,
  submitted_on, decision_on, url, eligibility, verified, verified_on, next_step, next_step_due, notes)
select 'Wisdom Family Foundation', 'Preliminary Grant Inquiry', 'dated', 'submitted', 'foundation', 'djclass', 3,
  date '2027-02-01', 'operating grants typically $5,000-$20,000', 10000,
  date '2026-11-25', date '2027-03-01', 'https://www.wisdomfamilyfoundation.org/grants',
  'By invitation after the preliminary inquiry; grantees primarily in Minneapolis and St. Paul', true, date '2026-11-25',
  'SUBMITTED Nov 25, 2026 (confirmation page; a copy of answers is emailed). $10,000 for 20 Tuesdays of resident instructor pay. Invitations by Mar 1; if invited, application due Apr 1, awards May 1. Status email: info@wisdomfamilyfoundation.org. Check Mar 1.',
  date '2027-03-01',
  '[wisdom-submitted 2026-11-25] Google form https://forms.gle/6TKedxHXcaNPgsbv6, program area Youth enrichment, sent from the SelassieFest Google account with stephen@selassiefest.com as contact. Form said submissions after Feb 1, 2026 count for the 2027 cycle. Fit risk: mainly Twin Cities grantees.'
where not exists (select 1 from fs_grant_deadlines where funder ilike 'wisdom family%');

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('wisdom-check-2027-03-01', 'Wisdom Family Foundation: check for an invitation to apply',
  timestamptz '2027-03-01 09:30-06', timestamptz '2027-03-01 09:45-06', 'Online (email)',
  'Inquiry sent Nov 25, 2026. Invitations by Mar 1; application due Apr 1 if invited.')
on conflict (key) do nothing;

commit;

select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines where funder ilike 'wisdom family%'
union all select 'event', key, null, starts_at::text from rti_calendar_events where key = 'wisdom-check-2027-03-01';

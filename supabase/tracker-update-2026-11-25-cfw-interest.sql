-- Chicago Foundation for Women: GCC Funding Interest Form submitted Nov 25, 2026. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    submitted_on = date '2026-11-25',
    amount_requested = 7800,
    next_step = 'Funding Interest Form SUBMITTED Nov 25, 2026 (Google Forms "Your response has been recorded"; no reference number). Covers CFW Giving Councils and Circles; we asked for a nomination by the Young Women''s Giving Council or the South Side Giving Circle; $7,800 mentioned for guest women DJs. Member-nominated process: a reply is not promised; grants made in June. Check Mar 1, 2027.',
    next_step_due = date '2027-03-01',
    notes = coalesce(notes, '') || ' | [cfw-interest 2026-11-25] Form https://forms.gle/5VgE5KQoJgEzhf5v8 sent from the SelassieFest Google account with stephen@selassiefest.com as contact. Interest form, not a formal application. Prior status to_research; prior next step: confirm YWGC cycle dates and eligibility on cfw.org.',
    updated_at = now()
where id = '9e9aa5b3-dd0f-450f-af5b-0b69f589c718'
  and coalesce(notes, '') not like '%[cfw-interest 2026-11-25]%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('cfw-check-2027-03-01', 'Chicago Foundation for Women: check for a Giving Council contact',
  timestamptz '2027-03-01 09:00-06', timestamptz '2027-03-01 09:15-06', 'Online (email)',
  'Interest form sent Nov 25, 2026. Grants made in June; a reply is not promised.')
on conflict (key) do nothing;

commit;

select funder, status, submitted_on, amount_requested, next_step_due from fs_grant_deadlines
where id = '9e9aa5b3-dd0f-450f-af5b-0b69f589c718';

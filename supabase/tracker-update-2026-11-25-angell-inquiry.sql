-- Paul M. Angell Family Foundation: Performing Arts grant inquiry submitted Nov 25, 2026. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    eligibility = 'Grant inquiry form first; application by invitation only. Budget priority $200K to $5M.',
    project = 'djclass',
    verified_on = date '2026-11-25',
    submitted_on = date '2026-11-25',
    deadline_date = date '2026-11-30',
    decision_on = date '2026-12-07',
    next_step = 'Grant inquiry SUBMITTED Nov 25, 2026 (on-screen "Thank you! Your submission has been received!"). Community Learning and Healing / Arts Learning; no amount asked. For the April cycle (inquiries by Nov 30) the foundation says it will reach out by Dec 7 if it can invite an application. Check Dec 7.',
    next_step_due = date '2026-12-07',
    notes = coalesce(notes, '') || ' | [angell-inquiry 2026-11-25] Form https://paulangell.org/inquiry-form-performing-arts. Program prioritizes organizations with budgets $200K to $5M (ours $75,123): fit risk. Inquiry only; application is by invitation. Replaces the older email-expression-of-interest route and the earlier performance-project fit note. Prior status to_research.',
    updated_at = now()
where id = 'b75a3cdc-bd1c-49c0-840f-c1eb561f2d2c'
  and status = 'to_research'
  and coalesce(notes, '') not like '%[angell-inquiry 2026-11-25]%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('angell-check-2026-12-07', 'Paul Angell Foundation: check for an invitation to apply',
  timestamptz '2026-12-07 09:00-06', timestamptz '2026-12-07 09:15-06', 'Online (email)',
  'Inquiry sent Nov 25, 2026; invitations by Dec 7 for the April cycle.')
on conflict (key) do nothing;

commit;

select funder, status, submitted_on, deadline_date, decision_on, next_step_due from fs_grant_deadlines
where id = 'b75a3cdc-bd1c-49c0-840f-c1eb561f2d2c';

select key, starts_at, active from rti_calendar_events where key = 'angell-check-2026-12-07';

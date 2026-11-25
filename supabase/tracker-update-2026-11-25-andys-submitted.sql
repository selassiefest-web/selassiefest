-- Andy's Frozen Custard donation request submitted Nov 25, 2026. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    project = 'djclass',
    submitted_on = date '2026-11-25',
    verified = true,
    verified_on = date '2026-11-25',
    url = 'https://hookcreative.wufoo.com/forms/m5z2ho51i87kkq/',
    next_step = 'SUBMITTED Nov 25, 2026 (confirmation page: reply within 5-7 business days): 50 mini custard cups for the DJ Lab Spring Showcase, May 18, 2027; pickup at 5446 S. Mulligan Ave, Chicago. Their form says no response within 10 business days means not approved. Check Dec 10; if approved, assign someone to pick up and keep the cups frozen.',
    next_step_due = date '2026-12-10',
    notes = coalesce(notes, '') || ' | [andys-submitted 2026-11-25] Donation Request Form - All Locations. Their criteria: educational programs serving children K-8 (our students are about grades 6-12; said so). Use changed from a weekly Rainbow Wednesdays pilot to one DJ Lab Showcase. Prior status to_research.',
    updated_at = now()
where id = '8c21a12a-bf69-4a3d-abc4-728d916f34ee'
  and status = 'to_research'
  and coalesce(notes, '') not like '%[andys-submitted 2026-11-25]%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('andys-check-2026-12-10', 'Andy''s Frozen Custard: check for an approval email',
  timestamptz '2026-12-10 09:00-06', timestamptz '2026-12-10 09:15-06', 'Online (email)',
  'Submitted Nov 25, 2026. No reply within 10 business days means not approved. Do not call.')
on conflict (key) do nothing;

update rti_calendar_events
set title = replace(title, ' Andy''s,', ''),
    notes = replace(notes, ' G 8c21a12a Andy''s;', '')
where key = 'jan15-deadlines-2027-01-15';

commit;

select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines where id = '8c21a12a-bf69-4a3d-abc4-728d916f34ee'
union all select 'event', key, null, starts_at::text from rti_calendar_events where key = 'andys-check-2026-12-10'
union all select 'old event', title, null, null from rti_calendar_events where key = 'jan15-deadlines-2027-01-15';

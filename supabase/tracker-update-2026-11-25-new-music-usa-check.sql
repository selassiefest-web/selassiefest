-- New Music USA program check, Nov 25, 2026: nothing open to RTI now. Safe to re-run.
begin;

update fs_grant_deadlines
set deadline_date = null,
    verified_on = date '2026-11-25',
    next_step = 'Nothing to file now. Creator Fund (applications Dec 7, 2026 to Jan 7, 2027; details published Dec 7) is a music-creator program, tracked here as individual artists only. For organizations, recheck the New Music Organization Fund Feb 1, 2027: next cycle opens spring 2027 (2026 deadline was Mar 19; average award $7,000, maximum $10,000): https://newmusicusa.org/program/organization-fund/',
    next_step_due = date '2027-02-01',
    notes = coalesce(notes, '') || ' | [nmusa-check 2026-11-25] Pages read Nov 25. Organization Fund is for organizations that work regularly with and support music creators; fit for RTI not established. Small Grant Fund page shows the Portland pilot (awards announced 2023). Prior deadline_date 2026-11-15, next step "Check details in mid-November."',
    updated_at = now()
where id = 'c8eeb938-40f0-447c-a518-bc6fc723d577'
  and coalesce(notes, '') not like '%[nmusa-check 2026-11-25]%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('nmusa-recheck-2027-02-01', 'New Music USA: check the Organization Fund spring cycle',
  timestamptz '2027-02-01 09:00-06', timestamptz '2027-02-01 09:15-06', 'Online',
  'https://newmusicusa.org/program/organization-fund/ . Confirm fit before drafting.')
on conflict (key) do nothing;

commit;

select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines where id = 'c8eeb938-40f0-447c-a518-bc6fc723d577'
union all select 'event', title, null, starts_at::text from rti_calendar_events where key = 'nmusa-recheck-2027-02-01'
union all select 'other events', key, title, starts_at::text from rti_calendar_events where key <> 'nmusa-recheck-2027-02-01' and active and (title ilike '%new music%' or notes ilike '%c8eeb938%');

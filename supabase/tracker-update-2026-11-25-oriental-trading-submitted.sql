-- Oriental Trading donation request 5225976 submitted Nov 25, 2026. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    project = 'djclass',
    submitted_on = date '2026-11-25',
    verified = true,
    verified_on = date '2026-11-25',
    next_step = 'SUBMITTED Nov 25, 2026 (request 5225976, thank-you page): youth craft and decoration supplies for the DJ Lab Spring Showcase, May 18, 2027. They usually reply within 4 weeks, by email, and ask not to be contacted outside their system. Check Dec 28.',
    next_step_due = date '2026-12-28',
    notes = coalesce(notes, '') || ' | [oriental-submitted 2026-11-25] Form https://orientaltrading.requestitem.com/ with IRS letter. Event type Other; not a fundraiser. Use changed from Rainbow Wednesdays to the DJ Lab Showcase. Prior status to_research.',
    updated_at = now()
where id = 'd14f32bd-d2e1-483f-b2cc-ef800b3e7ac8'
  and status = 'to_research'
  and coalesce(notes, '') not like '%[oriental-submitted 2026-11-25]%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '965d7d84-5464-4632-bac0-c97920af6468', 'note',
  '2026-11-25: donation request 5225976 submitted online for the May 18, 2027 DJ Lab Spring Showcase (craft and decoration supplies). [src:oriental-submitted-2026-11-25]',
  'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', timestamptz '2026-11-25 04:00:00-06'
where not exists (select 1 from fs_partner_activity where partner_id = '965d7d84-5464-4632-bac0-c97920af6468' and summary like '%[src:oriental-submitted-2026-11-25]%');

update fs_partners
set stage = 'reached_out', ball_with = 'them',
    program_parts = array['classes'],
    last_contact_at = timestamptz '2026-11-25 04:00:00-06',
    next_step = 'Request 5225976 submitted Nov 25, 2026; they usually reply within 4 weeks. Do not contact them outside their system.',
    next_step_due = date '2026-12-28',
    notes = coalesce(notes, '') || ' [src:oriental-submitted-2026-11-25]',
    updated_at = now()
where id = '965d7d84-5464-4632-bac0-c97920af6468'
  and stage = 'not_contacted'
  and coalesce(notes, '') not like '%src:oriental-submitted-2026-11-25%';

update rti_calendar_events
set title = replace(title, ' Oriental Trading form,', ''),
    notes = replace(notes, ' P 965d7d84 Oriental Trading;', '')
where key = 'mar01-checks-2027-03-01';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('oriental-check-2026-12-28', 'Oriental Trading: check for a reply on request 5225976',
  timestamptz '2026-12-28 09:00-06', timestamptz '2026-12-28 09:15-06', 'Online (email)',
  'Submitted Nov 25, 2026. Email only; do not contact them outside their system.')
on conflict (key) do nothing;

commit;

select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines where id = 'd14f32bd-d2e1-483f-b2cc-ef800b3e7ac8'
union all select 'partner', name, stage, next_step_due::text from fs_partners where id = '965d7d84-5464-4632-bac0-c97920af6468'
union all select 'activity', '', count(*)::text, null from fs_partner_activity where summary like '%oriental-submitted-2026-11-25%'
union all select 'old event', title, null, null from rti_calendar_events where key = 'mar01-checks-2027-03-01'
union all select 'new event', key, null, starts_at::text from rti_calendar_events where key = 'oriental-check-2026-12-28';

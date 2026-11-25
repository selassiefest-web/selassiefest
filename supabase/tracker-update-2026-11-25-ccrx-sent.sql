-- Creative Chicago Reuse Exchange request SENT Nov 25, 2026 3:55 am CT (Outlook, stephen@). Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    project = 'djclass',
    submitted_on = date '2026-11-25',
    verified_on = date '2026-11-25',
    next_step = 'Request emailed Nov 25, 2026 (3:55 am CT) to info@creativechirx.org: a donated box of art materials (or a nonprofit rate) for the DJ Lab Spring Showcase, May 18, 2027. Wait for a reply; one email nudge Dec 7 if silent. Pickup, if any, is at 2124 W. 82nd Place by appointment (Wed, Thu, Sat).',
    next_step_due = date '2026-12-07',
    notes = coalesce(notes, '') || ' | [ccrx-sent 2026-11-25] Sent from stephen@selassiefest.com (Cc Stephen) with the pitch deck link, subject "Showcase art materials for a free youth DJ class in Chicago (Ras Tafari Inc.)". Warehouse page: $20 a box for basics; binders, books and fabric scraps free. Use changed from Rainbow Wednesdays to the DJ Lab Showcase. Prior status to_research.',
    updated_at = now()
where id = 'b364981d-28c3-4ecc-b735-3c95df21145c'
  and status = 'to_research'
  and coalesce(notes, '') not like '%[ccrx-sent 2026-11-25]%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '52c3d068-9a72-4d8f-8aca-aa2dcc8d8616', 'email',
  '2026-11-25 3:55 am CT: Stephen emailed info@creativechirx.org asking for a donated box of art materials or a nonprofit rate for the May 18, 2027 DJ Lab Spring Showcase. [src:ccrx-sent-2026-11-25]',
  'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', timestamptz '2026-11-25 03:55:00-06'
where not exists (select 1 from fs_partner_activity where partner_id = '52c3d068-9a72-4d8f-8aca-aa2dcc8d8616' and summary like '%[src:ccrx-sent-2026-11-25]%');

update fs_partners
set stage = 'reached_out', ball_with = 'them',
    last_contact_at = timestamptz '2026-11-25 03:55:00-06',
    next_step = 'Request emailed Nov 25, 2026; wait for a reply, one email nudge Dec 7 if silent.',
    next_step_due = date '2026-12-07',
    notes = coalesce(notes, '') || ' [src:ccrx-sent-2026-11-25]',
    updated_at = now()
where id = '52c3d068-9a72-4d8f-8aca-aa2dcc8d8616'
  and stage = 'not_contacted'
  and coalesce(notes, '') not like '%src:ccrx-sent-2026-11-25%';

commit;

select 'grant' as t, funder as k, status as s, next_step_due from fs_grant_deadlines where id = 'b364981d-28c3-4ecc-b735-3c95df21145c'
union all select 'partner', name, stage, next_step_due from fs_partners where id = '52c3d068-9a72-4d8f-8aca-aa2dcc8d8616';

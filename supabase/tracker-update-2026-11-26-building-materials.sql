-- Lowe's, Menards, The Home Depot: building materials for youth DJ stages (added by Stephen Thu Nov 26, 2026).
-- Source: Claude outputs/blitz-drafts/SENT-LOG.md. Safe to re-run: fixed row ids, name guard, tagged activity.
-- Existing rows are never overwritten on re-run. No amounts. action_kind is generated and is never set.
begin;
do $$
declare
  lw constant uuid := 'ed4765b5-1d33-4f7f-9ab1-df97ce01cad1';
  mn constant uuid := 'e06a44fd-cfe8-4802-9e78-5176807514c1';
  hd constant uuid := 'c15e5226-7742-4de3-a49c-11ee305d4562';
  n int;
begin
  perform pg_advisory_xact_lock(hashtext('building-materials-2026-11-26'));

  -- stop if another session created any of these under a different id
  if exists (select 1 from fs_partners where id not in (lw, mn, hd)
             and (name ~* '(\mlowe''?s\M|menards|home ?depot)' or website ~* '(lowes\.com|menards\.com|homedepot\.com)')) then
    raise exception 'a Lowe''s, Menards or Home Depot partner row already exists under another id; nothing applied';
  end if;

  insert into fs_partners (id, name, category, partner_types, program_parts, stage, ball_with, ask, website, contacts,
                           next_step, next_step_due, last_contact_at, source, notes)
  values
  (lw, 'Lowe''s', 'Corporate giving - in-kind', array['in_kind'], array['classes'], 'not_contacted', 'us',
   'Building materials for youth DJ stages that Ras Tafari Inc. will build.',
   'https://corporate.lowes.com/our-responsibilities/community-bucket-list',
   '[{"name": "Lowe''s corporate community pages", "role": "Program pages only; no open online store donation request found Nov 26, 2026", "url": "https://corporate.lowes.com/our-responsibilities/community-bucket-list"}]'::jsonb,
   'On Mon Feb 1, 2027, re-check https://corporate.lowes.com/our-responsibilities/community-bucket-list for an announced 2027 round or another online request route. Nothing has been sent. Owner: Stephen.',
   date '2027-02-01', null, 'Added by Stephen 2026-11-26',
   '[src:lowes-check-2026-11-26] Corporate pages read Nov 26, 2026: Community Impact Grants nominations ran Feb 18 to Mar 20, 2026 (https://corporate.lowes.com/our-responsibilities/community-impact/faqs). The FAQ describes the program for 2022-2026, so no 2027 round is announced. No open online store donation request found. Nothing sent.'),
  (mn, 'Menards', 'Corporate giving - in-kind', array['in_kind'], array['classes'], 'reached_out', 'them',
   'Building materials for youth DJ stages that Ras Tafari Inc. will build: lumber, plywood, hardware, paint or a store gift card.',
   'https://www.menards.com/forms/contact-us/form.html',
   '[{"name": "Menards contact form", "role": "Contact route used Nov 26, 2026 (online form)", "url": "https://www.menards.com/forms/contact-us/form.html"}]'::jsonb,
   'Check for a reply on Wed Dec 9, 2026 (online only: https://www.menards.com/forms/contact-us/form.html). If silent, draft one nudge (draft only; send only after Stephen says send). Owner: Stephen.',
   date '2026-12-09', timestamptz '2026-11-26 15:36:00-06', 'Added by Stephen 2026-11-26',
   '[src:menards-form-2026-11-26] Contact form submitted Thu Nov 26, 2026 (exact time not captured; the stored 3:36 PM CT is when the receipt was written to SENT-LOG.md, an upper bound). Page confirmed the email was sent. No reply logged. Which store to write to is unknown (asked).'),
  (hd, 'The Home Depot', 'Corporate giving - in-kind', array['in_kind'], array['classes'], 'reached_out', 'them',
   'Building materials for youth DJ stages that Ras Tafari Inc. will build: lumber, plywood, hardware, paint or a store gift card.',
   'https://corporate.homedepot.com/contact',
   '[{"name": "The Home Depot corporate contact form", "role": "Contact route used Nov 26, 2026 (online form)", "url": "https://corporate.homedepot.com/contact"}]'::jsonb,
   'Check for a reply on Wed Dec 9, 2026 (online only: https://corporate.homedepot.com/contact). If silent, draft one nudge (draft only; send only after Stephen says send). Owner: Stephen.',
   date '2026-12-09', timestamptz '2026-11-26 15:43:00-06', 'Added by Stephen 2026-11-26',
   '[src:homedepot-form-2026-11-26] Contact form submitted Thu Nov 26, 2026 (exact time not captured; the stored 3:43 PM CT is when the confirmation page was read, an upper bound). Page status: message sent. No reply logged. The grants page lists only Veteran Housing, Retool Your School and Path to Pro.')
  on conflict (id) do nothing;

  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select v.pid, 'note', v.summary, v.stage_after, 'stephen@selassiefest.com', 'Claude', v.event_at
  from (values
    (lw, 'Nov 26, 2026: Lowe''s added by Stephen for building materials for youth DJ stages. Corporate pages read: Community Impact Grants nominations ran Feb 18 to Mar 20, 2026; no 2027 round announced and no open online store donation request found. Nothing sent. [src:lowes-check-2026-11-26]',
       'not_contacted', '[src:lowes-check-2026-11-26]', timestamptz '2026-11-26 15:30:00-06'),
    (mn, 'Nov 26, 2026 (exact time not captured): contact form submitted at https://www.menards.com/forms/contact-us/form.html. Asked Menards to donate lumber, plywood, hardware, paint or a store gift card for youth DJ stages, and which store to write to. Page confirmation: "Your email has been sent! We will review and get back to you as quickly as possible." No reference number or Message-ID. [src:menards-form-2026-11-26]',
       'reached_out', '[src:menards-form-2026-11-26]', timestamptz '2026-11-26 15:36:00-06'),
    (hd, 'Nov 26, 2026 (exact time not captured): contact form submitted at https://corporate.homedepot.com/contact. Asked The Home Depot to donate lumber, plywood, hardware, paint or a store gift card for youth DJ stages, and which store to write to. Status message: "Your message has been sent." No reference number or Message-ID. [src:homedepot-form-2026-11-26]',
       'reached_out', '[src:homedepot-form-2026-11-26]', timestamptz '2026-11-26 15:43:00-06')
  ) v(pid, summary, stage_after, tag, event_at)
  where not exists (select 1 from fs_partner_activity a where a.partner_id = v.pid and position(v.tag in coalesce(a.summary,'')) > 0);

  -- Dec 9 follow-up alert: append each once
  perform 1 from rti_calendar_events where key = 'triage-followups-2026-12-09' for update;
  update rti_calendar_events set
    notes = coalesce(notes,'') || ' | Menards [' || mn || '] (contact form sent Nov 26; check for a reply; only if no reply: prepare one nudge draft; send only after Stephen says send)'
  where key = 'triage-followups-2026-12-09' and active and position(mn::text in coalesce(notes,'')) = 0;
  update rti_calendar_events set
    notes = coalesce(notes,'') || ' | The Home Depot [' || hd || '] (contact form sent Nov 26; check for a reply; only if no reply: prepare one nudge draft; send only after Stephen says send)'
  where key = 'triage-followups-2026-12-09' and active and position(hd::text in coalesce(notes,'')) = 0;

  -- checks
  select count(*) into n from fs_partners where id in (lw, mn, hd);
  if n <> 3 then raise exception 'expected 3 partner rows, found %', n; end if;
  select count(*) into n from fs_partner_activity a
    join (values (lw, '[src:lowes-check-2026-11-26]'), (mn, '[src:menards-form-2026-11-26]'), (hd, '[src:homedepot-form-2026-11-26]')) v(pid, tag)
      on a.partner_id = v.pid and position(v.tag in coalesce(a.summary,'')) > 0;
  if n <> 3 then raise exception 'expected 3 activity rows, found %', n; end if;
  if not exists (select 1 from rti_calendar_events where key = 'triage-followups-2026-12-09' and active
                 and position(mn::text in notes) > 0 and position(hd::text in notes) > 0) then
    raise exception 'Dec 9 calendar check failed; nothing applied';
  end if;
end $$;
commit;

select p.name, p.id, p.stage, p.ball_with, p.next_step_due, p.last_contact_at, p.commitment_value, p.website, p.next_step,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id) as activity_rows,
  exists (select 1 from rti_calendar_events c where c.key = 'triage-followups-2026-12-09' and position(p.id::text in coalesce(c.notes,'')) > 0) as on_dec9_alert
from fs_partners p
where p.id in ('ed4765b5-1d33-4f7f-9ab1-df97ce01cad1','e06a44fd-cfe8-4802-9e78-5176807514c1','c15e5226-7742-4de3-a49c-11ee305d4562')
order by p.name;

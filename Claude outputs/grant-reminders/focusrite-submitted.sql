-- Focusrite / Novation collaboration form submitted by Stephen on 2026-10-20.
-- Marks the partner row reached out, logs it, sets a two-week follow-up (Nov 3, 2026) and adds a reminder email.
update fs_partners
   set stage = 'reached_out',
       last_contact_at = now(),
       next_step = 'Follow up: no reply yet; email or call Focusrite Novation, ask for the education or artist relations contact',
       next_step_due = '2026-11-03',
       notes = coalesce(notes,'') || ' SUBMITTED 2026-10-20 by Stephen via the artist-enquiries form (inquiry type Other, all genres ticked, collaboration and education framing).'
 where name = 'Focusrite / Novation / ADAM Audio' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Submitted the Focusrite artist-enquiries collaboration form (Stephen). Follow-up set for Nov 3, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Focusrite / Novation / ADAM Audio'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Submitted the Focusrite%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Focusrite / Novation collaboration form', 'Submitted Oct 20, 2026. No reply expected on a set date; follow up by email or phone and ask for the education or artist relations contact.', '2026-11-03', 'event', 'https://us.focusrite.com/contact-us/artist-enquiries', true)
on conflict (title, due_date) do nothing;

-- Reloop inquiry emailed by Stephen to info@reloop.com on 2026-10-21 at 11:52 PM (controllers, demo turntable setup or headphones; asked them to forward to the US education or marketing rep). Follow-up Nov 4, 2026.
update fs_partners
   set stage = 'reached_out', last_contact_at = now(),
       next_step = 'Follow up by email if no reply; ask again for the US education or marketing representative',
       next_step_due = '2026-11-04',
       notes = coalesce(notes,'') || ' EMAILED 2026-10-21 11:52 PM by Stephen to info@reloop.com (controllers, demo turntable setup or headphones; DJ Lab link). Asked them to forward to the US education or marketing rep. Watch for a bounce-back.'
 where name = 'Reloop' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed Reloop (info@reloop.com): controllers, demo turntable setup or headphones; asked them to forward to the US education or marketing rep. Follow-up Nov 4, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Reloop'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Emailed Reloop (info@reloop.com)%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Reloop inquiry', 'Emailed Oct 21, 2026 to info@reloop.com asking for the US education or marketing rep.', '2026-11-04', 'event', 'https://www.reloop.com/imprint', true)
on conflict (title, due_date) do nothing;

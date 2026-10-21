-- Sennheiser sponsorship inquiry emailed by Stephen to sponsoring@sennheiser.com on 2026-10-20 at 11:29 PM. Follow-up Nov 3, 2026.
update fs_partners
   set stage = 'reached_out', last_contact_at = now(),
       next_step = 'Follow up by email if no reply; ask what documents or a proposal they need',
       next_step_due = '2026-11-03',
       notes = coalesce(notes,'') || ' EMAILED 2026-10-20 11:29 PM by Stephen to sponsoring@sennheiser.com (headphones, spare pads, mics; DJ Lab link). Watch for a bounce-back.'
 where name = 'Sennheiser' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed the sponsorship inquiry to sponsoring@sennheiser.com (12 headphones, spare pads, mics). Follow-up Nov 3, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Sennheiser'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Emailed the sponsorship inquiry%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Sennheiser sponsorship inquiry', 'Emailed Oct 20, 2026 to sponsoring@sennheiser.com. No response time published.', '2026-11-03', 'event', 'https://www.sennheiser.com/en-us/about-us/our-responsibility/partnerships/partnerships--sponsorings-categories', true)
on conflict (title, due_date) do nothing;

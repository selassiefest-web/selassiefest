-- inMusic support ticket #880933 created by Stephen on 2026-10-20 (filed as Denon DJ Legacy; subject asks to route to education / brand partnerships).
-- inMusic aims to respond by Oct 23, 2026 4 pm EDT; they warn it may run longer. Follow-up set for Oct 27.
update fs_partners
   set stage = 'reached_out', last_contact_at = now(),
       next_step = 'Watch for a reply to ticket #880933 (target Oct 23); if none by Oct 27, reply on the ticket and ask for the Numark and Denon DJ education or brand-partnership contact',
       next_step_due = '2026-10-27',
       notes = coalesce(notes,'') || ' SUBMITTED 2026-10-20: support ticket #880933 (tracking: https://inmusicsupport.freshdesk.com/helpdesk/tickets/880933), filed under Denon DJ Legacy. Their chat bot said it has no verified education or partnership contact and pointed to the ticket portal.'
 where name like 'inMusic Brands%' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Submitted inMusic support ticket #880933 asking to route to education / brand partnerships (Numark, Denon DJ, RANE, Akai, Alto). Response target Oct 23. Follow-up Oct 27, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name like 'inMusic Brands%'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Submitted inMusic support ticket%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: inMusic ticket #880933', 'Ticket asks for routing to education / brand partnerships. Their target reply was Oct 23, 4 pm EDT. If nothing, reply on the ticket.', '2026-10-27', 'event', 'https://inmusicsupport.freshdesk.com/helpdesk/tickets/880933', true)
on conflict (title, due_date) do nothing;

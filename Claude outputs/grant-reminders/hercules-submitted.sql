-- Hercules support-portal request (category Marketing Contact) submitted by Stephen on 2026-10-20 at 11:42 PM.
-- Confirmation page: "We have received your request... do not submit another request." Follow-up Nov 3, 2026.
update fs_partners
   set stage = 'reached_out', last_contact_at = now(),
       next_step = 'Wait for the Hercules reply (do not resubmit); if none by Nov 3, use live chat and ask for the education or marketing partnership contact',
       next_step_due = '2026-11-03',
       notes = coalesce(notes,'') || ' SUBMITTED 2026-10-20 11:42 PM via support.hercules.com New Request, category Marketing Contact. Survey answers: products = none yet (plan Inpulse 300 MK2), software DJUCED, social links and DJ Lab page given, last box asked for the education/marketing partnership contact. Portal says do not resubmit.'
 where name = 'Hercules DJ' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Submitted the Hercules Marketing Contact request (12 matching beginner controllers and headphones; asked for the education / marketing partnership contact). Follow-up Nov 3, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Hercules DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Submitted the Hercules Marketing%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Hercules Marketing Contact request', 'Submitted Oct 20, 2026. The portal says do not resubmit; if no reply, try live chat and ask for the education / marketing partnership contact.', '2026-11-03', 'event', 'https://support.hercules.com/en/contact-en/', true)
on conflict (title, due_date) do nothing;

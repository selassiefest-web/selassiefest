-- Records equipment asks sent on 2026-10-20. Re-runnable: each update only fires while the row is still not_contacted.
-- Shure: product-donation form submitted (confirmation page: "Received!"). Tax ID left blank on the form (optional).
update fs_partners
   set stage = 'reached_out', last_contact_at = now(),
       next_step = 'Follow up with Shure if no reply; the form gave no response time. Have the IRS letter and Tax ID ready.',
       next_step_due = '2026-11-10',
       notes = coalesce(notes,'') || ' SUBMITTED 2026-10-20 via the Shure donation form: Product, 12 headphones + 2 mics, need-by Jan 5, 2027. Tax ID not entered (optional).'
 where name = 'Shure' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Submitted the Shure product-donation form (12 headphones, 2 mics, need-by Jan 5, 2027). Follow-up Nov 10, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Shure'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Submitted the Shure%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Shure donation request', 'Submitted Oct 20, 2026 (12 headphones, 2 mics, need-by Jan 5, 2027). No response time was published.', '2026-11-10', 'event', 'https://shure.formstack.com/forms/donation_request_en', true)
on conflict (title, due_date) do nothing;

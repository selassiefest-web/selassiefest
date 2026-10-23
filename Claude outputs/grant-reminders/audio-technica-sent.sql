-- Run AFTER the Audio-Technica email is sent to artistrelations@atus.com (address printed on https://www.audio-technica.com/en-us/contact). Follow-up Nov 5, 2026.
update fs_partners
   set stage = 'reached_out', last_contact_at = now(), email = 'artistrelations@atus.com',
       next_step = 'Follow up by email if no reply; then call 330-686-2600 (Audio Solutions x5000) and ask who handles education or community requests',
       next_step_due = '2026-11-05',
       notes = coalesce(notes,'') || ' EMAILED 2026-10-22 to artistrelations@atus.com (Artist Relations, printed on the contact page): one station, 12 headphones, or listening partner (headphones, ear pads, mics). Asked them to forward if another team handles it.'
 where name = 'Audio-Technica' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed Audio-Technica Artist Relations (artistrelations@atus.com): one station, headphones for 12, or listening partner. Follow-up Nov 5, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Audio-Technica'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Emailed Audio-Technica Artist Relations%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Audio-Technica inquiry', 'Emailed Oct 22, 2026 to artistrelations@atus.com (headphones and microphones for the 12 DJ Lab stations).', '2026-11-05', 'event', 'https://www.audio-technica.com/en-us/contact', true)
on conflict (title, due_date) do nothing;

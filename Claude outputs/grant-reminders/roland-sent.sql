-- Roland Music Education inquiry emailed by Stephen to rolandmusiced@rolandus.com on 2026-10-21 at 11:46 PM (beat-making equipment + instructional support; DJ Lab link). Follow-up Nov 4, 2026.
update fs_partners
   set stage = 'reached_out', last_contact_at = now(),
       next_step = 'Follow up by email if no reply; if silent, call Roland Music Education 323-890-3700 and ask who handles requests like this',
       next_step_due = '2026-11-04',
       notes = coalesce(notes,'') || ' EMAILED 2026-10-21 11:46 PM by Stephen to rolandmusiced@rolandus.com (beat-making equipment for any portion of 12 stations, guest session or teaching materials; DJ Lab link). Asked whether Roland considers such requests. Watch for a bounce-back.'
 where name = 'Roland (Music Education)' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed Roland Music Education (rolandmusiced@rolandus.com): beat-making equipment and instructional support, asked whether they consider such requests. Follow-up Nov 4, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners
 where name = 'Roland (Music Education)'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Emailed Roland Music Education%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Follow up: Roland Music Education inquiry', 'Emailed Oct 21, 2026 to rolandmusiced@rolandus.com. If silent, call 323-890-3700.', '2026-11-04', 'event', 'https://www.rolandmusiced.com/company/', true)
on conflict (title, due_date) do nothing;

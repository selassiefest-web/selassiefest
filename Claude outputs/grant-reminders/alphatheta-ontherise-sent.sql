-- 2026-10-21: Stephen sent the On The Rise DJ Academy (London, featured Start From Scratch school) contact form (confirmation: "Your message was sent successfully").
-- Their number +44 790 4567 838 is a UK mobile; plan a WhatsApp call during London business hours.
update fs_partners
   set last_contact_at = now(),
       next_step = 'WhatsApp On The Rise DJ Academy +44 790 4567838 during London business hours (3-5 pm London = 9-11 am Chicago). Oct 26: views check. Oct 27: call Powell / Americas line if silent. Oct 28: follow up Ellie Donovan and Samantha Togni.',
       next_step_due = '2026-10-21',
       notes = coalesce(notes,'') || ' CONTACT FORM 2026-10-21: sent to On The Rise DJ Academy (London, Wembley branch), asking who runs Start From Scratch at AlphaTheta. Phone +44 790 4567838.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%sent to On The Rise DJ Academy%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Sent the On The Rise DJ Academy (London) contact form with the tracked link, asking who runs Start From Scratch at AlphaTheta. Next: WhatsApp call +44 790 4567838.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Sent the On The Rise DJ Academy%');

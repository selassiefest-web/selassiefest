-- 2026-10-21: WhatsApp message sent and a voicemail left for On The Rise DJ Academy (London), +44 790 4567838.
update fs_partners
   set last_contact_at = now(),
       next_step = 'Today 11 am-1 pm Chicago (9-11 am Pacific): call AlphaTheta Music Americas 1-844-784-0000 and ask for community / education partnerships. Oct 23: WhatsApp On The Rise again if no reply. Oct 26: views check. Oct 27: call Powell 424-488-0480 if silent. Oct 28: follow up Ellie Donovan and Samantha Togni.',
       next_step_due = '2026-10-21',
       notes = coalesce(notes,'') || ' WHATSAPP 2026-10-21: message sent and voicemail left for On The Rise DJ Academy (+44 790 4567838). Follow up Oct 23 if no reply.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%voicemail left for On The Rise%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'call', 'WhatsApp message sent and voicemail left for On The Rise DJ Academy (London) asking who runs Start From Scratch at AlphaTheta. Follow up Oct 23.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'WhatsApp message sent and voicemail left%');

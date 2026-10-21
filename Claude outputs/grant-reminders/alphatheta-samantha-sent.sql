-- 2026-10-21: Stephen sent a message with the tracked link to Samantha Togni (Boudica founder, a Start From Scratch host partner in Europe). Channel not stated when logged.
-- Her Linktree (https://linktr.ee/samanthatogni) lists: promo/artist email artist@samanthatogni.net; bookings via an agency; no Instagram link on the page. She has a published Novation interview (relevant to the Focusrite / Novation ask).
update fs_partners
   set last_contact_at = now(),
       next_step = 'Oct 26: check views; if Grace Ladoja has not replied, DM @ourhomecoming. Next one person: On The Rise DJ Academy (London). Oct 27: call Powell / Americas line if silent. Oct 28: follow up Ellie Donovan and Samantha Togni.',
       next_step_due = '2026-10-26',
       notes = coalesce(notes,'') || ' SENT 2026-10-21: message to Samantha Togni (Boudica; Start From Scratch host partner). Channel not recorded. Her Linktree lists artist@samanthatogni.net (promo). She gave Novation an interview (novationmusic.com/en/news/radical-power-sticking-your-guts-conversation-samantha-togni).'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%message to Samantha Togni%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Sent a message with the tracked link to Samantha Togni (Boudica) asking for an introduction to whoever runs Start From Scratch at AlphaTheta. Channel not recorded. Follow up Oct 28.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Sent a message with the tracked link to Samantha Togni%');

-- 2026-10-21 11:04 PM Chicago: Stephen emailed marketing.us@alphatheta.com (subject "Partnership proposal: Start From Scratch in Chicago") with the tracked link, asking who runs Start From Scratch / US community partnerships and whether it has operated in the US.
update fs_partners
   set last_contact_at = now(),
       next_step = 'Oct 23: WhatsApp On The Rise again if no reply. Oct 26: views and bounce-back check; Instagram follow-ups. Oct 27: Email 2 to marketing.us@alphatheta.com if silent, call Powell 424-488-0480. Oct 28: follow up Ellie, Chris and Samantha.',
       next_step_due = '2026-10-23',
       notes = coalesce(notes,'') || ' EMAIL 2026-10-21: sent to marketing.us@alphatheta.com (Marketing Division, routed by the Americas line text) with the tracked link. Follow up Oct 27.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%EMAIL 2026-10-21: sent to marketing.us%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed the AlphaTheta Marketing Division (marketing.us@alphatheta.com) with the tracked link, asking who runs Start From Scratch or US community partnerships and to forward it. Follow up Oct 27.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Emailed the AlphaTheta Marketing Division%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('AlphaTheta: follow up marketing.us@alphatheta.com', 'Emailed the Marketing Division Oct 21. If no reply, send Email 2 (equipment-outreach/alphatheta-campaign.md) and call Powell 424-488-0480.', '2026-10-27', 'event', 'https://selassiefest.com/startfromscratch-chicago/', true)
on conflict (title, due_date) do nothing;

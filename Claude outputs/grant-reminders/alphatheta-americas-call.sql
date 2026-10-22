-- 2026-10-21: Stephen called AlphaTheta Music Americas (1-844-784-0000). An automatic text came back: "For customers interested in contacting our Marketing Division please send your inquiry to marketing.us@alphatheta.com". That is a published address they gave us, so Email 1 goes there.
update fs_partners
   set last_contact_at = now(),
       next_step = 'Send Email 1 to marketing.us@alphatheta.com today (draft in equipment-outreach/alphatheta-campaign.md, "Marketing Division"). Oct 23: WhatsApp On The Rise again if no reply. Oct 26: views and bounce-back check. Oct 27: email 2 to marketing.us if silent, call Powell 424-488-0480. Oct 28: follow up Ellie, Chris and Samantha.',
       next_step_due = '2026-10-21',
       notes = coalesce(notes,'') || ' CALL 2026-10-21: called 1-844-784-0000; got an automatic text routing marketing inquiries to marketing.us@alphatheta.com (published by AlphaTheta).'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%CALL 2026-10-21: called 1-844-784-0000%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'call', 'Called AlphaTheta Music Americas (1-844-784-0000). An automatic text routed marketing inquiries to marketing.us@alphatheta.com. Next: send Email 1 there today.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Called AlphaTheta Music Americas (1-844-784-0000)%');

-- 2026-10-21: Stephen sent a LinkedIn invitation with note and the tracked link to Chris Shapiro (Director of Sales, US & Canada, AlphaTheta Music Americas, Los Angeles). That used the last personalized invitation this month.
update fs_partners
   set last_contact_at = now(),
       next_step = 'Today 11 am-1 pm Chicago: call AlphaTheta Music Americas 1-844-784-0000. Oct 26: views check. Oct 27: call Powell 424-488-0480 if silent. Oct 28: follow up Ellie Donovan, Samantha Togni and Chris Shapiro. LinkedIn personalized invitations reset next month; plain invitations remain available.',
       next_step_due = '2026-10-21',
       notes = coalesce(notes,'') || ' LINKEDIN 2026-10-21: invitation with note sent to Chris Shapiro (Director of Sales, US & Canada, AlphaTheta Music Americas). No personalized LinkedIn invitations left this month.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%invitation with note sent to Chris Shapiro%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Sent a LinkedIn invitation with a note and the tracked link to Chris Shapiro (Director of Sales, US & Canada, AlphaTheta Music Americas). Follow up Oct 28 if not accepted.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Sent a LinkedIn invitation with a note and the tracked link to Chris Shapiro%');

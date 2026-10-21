-- 2026-10-21: Stephen sent a LinkedIn invitation with note and the tracked link to Ellie Donovan (AlphaTheta marketing executive).
update fs_partners
   set last_contact_at = now(),
       next_step = 'Next one person: HOMECOMING (Lagos). Oct 26: check views and bounce-back; Oct 28: follow up Ellie Donovan if the invitation is not accepted.',
       next_step_due = '2026-10-26',
       notes = coalesce(notes,'') || ' LINKEDIN 2026-10-21: invitation with note sent to Ellie Donovan (marketing executive, quoted in Mixmag MENA Start From Scratch story). One LinkedIn personalized invitation left this month.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%invitation with note sent to Ellie Donovan%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Sent a LinkedIn invitation with a note and the tracked link to Ellie Donovan (AlphaTheta marketing). Follow up Oct 28 if not accepted.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Sent a LinkedIn invitation with a note and the tracked link to Ellie%');

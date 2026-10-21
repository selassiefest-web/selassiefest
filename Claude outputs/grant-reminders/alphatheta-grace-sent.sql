-- 2026-10-21: Stephen sent an Instagram DM with the tracked link to Grace Ladoja (@graceladoja, HOMECOMING founder, verified, 96.9K followers) asking for an introduction to whoever runs Start From Scratch at AlphaTheta.
update fs_partners
   set last_contact_at = now(),
       next_step = 'Oct 26: check views and bounce-back; if Grace has not replied by Oct 26, DM @ourhomecoming (festival account) with the same text. Next one person: Samantha Togni (Boudica). Oct 27: call Powell / Americas line if silent. Oct 28: follow up Ellie Donovan.',
       next_step_due = '2026-10-26',
       notes = coalesce(notes,'') || ' INSTAGRAM 2026-10-21: DM to @graceladoja (HOMECOMING founder) asking who runs Start From Scratch at AlphaTheta. @homecominglagos is a different, unrelated small account; do not use it. Official festival account is @ourhomecoming.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%DM to @graceladoja%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Sent an Instagram DM with the tracked link to Grace Ladoja (@graceladoja, HOMECOMING founder) asking for an introduction to whoever runs Start From Scratch at AlphaTheta. Follow up Oct 26 via @ourhomecoming.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Sent an Instagram DM with the tracked link to Grace Ladoja%');

-- 2026-10-21: Stephen sent the email to john.powell@pioneerdj.com and an Instagram DM to @alphathetausa (both with the tracked link).
update fs_partners
   set last_contact_at = now(), stage = 'reached_out',
       next_step = 'Next one person: Ellie Donovan (LinkedIn). Oct 26: check views and bounce-back. Oct 27: call 424-488-0480 / Americas line 1-844-784-0000 if no reply from Powell. Oct 26: Instagram follow-up if no DM reply.',
       next_step_due = '2026-10-26',
       notes = coalesce(notes,'') || ' SENT 2026-10-21: concise email to john.powell@pioneerdj.com and Instagram DM to @alphathetausa. Watch for a bounce-back (2020 address).'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%SENT 2026-10-21: concise email%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed John Powell (john.powell@pioneerdj.com) and sent an Instagram DM to @alphathetausa, both with the tracked link. Check views and bounce-back Oct 26; call Oct 27 if silent.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Emailed John Powell%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('AlphaTheta: check views and bounce-back; follow up John Powell and Instagram', 'Emailed and DMed Oct 21. Check the view count and any bounce-back; if silent, call 424-488-0480 or 1-844-784-0000 on Oct 27.', '2026-10-26', 'event', 'https://selassiefest.com/startfromscratch-chicago/', true)
on conflict (title, due_date) do nothing;

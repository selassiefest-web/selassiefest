-- LinkedIn invitation with note sent to John Powell (President, AlphaTheta Music Americas) by Stephen on 2026-10-21, with the tracked link. Follow-up Oct 29.
update fs_partners
   set last_contact_at = now(), stage = 'reached_out',
       next_step = 'Oct 22: call 1-844-784-0000, intro emails to HOMECOMING / Boudica / On The Rise, LinkedIn to Ellie Donovan. Oct 29: follow up with John Powell if the invitation is not accepted.',
       next_step_due = '2026-10-22',
       notes = coalesce(notes,'') || ' LINKEDIN 2026-10-21: Stephen sent a connection invitation with note to John Powell (President, AlphaTheta Music Americas; profile confirmed current). Site wording softened: no claim of being the first US host city until AlphaTheta confirms; ask them directly.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%LINKEDIN 2026-10-21%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'note', 'Sent a LinkedIn connection invitation with a note and the tracked link to John Powell, President, AlphaTheta Music Americas. Follow up Oct 29, 2026.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from fs_partners where name = 'AlphaTheta / Pioneer DJ'
   and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like 'Sent a LinkedIn connection invitation%');

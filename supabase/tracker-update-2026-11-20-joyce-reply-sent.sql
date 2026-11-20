-- 2026-11-20 4:21 pm CST: Stephen SENT his reply to Maddie Easton (Joyce). Re-run safe.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 20, 2026 (4:21 pm CST): Stephen SENT his reply to Maddie Easton (Joyce) from stephen@selassiefest.com: thanked her, said he will submit the Fluxx registration request, asked (1) whether registering now keeps RTI on track for the April 1, 2027 proposal cycle and (2) whether to describe the all-ages Rainbow Wednesdays public series (14 free evenings with neighborhood artists, families and elders) as the project instead of the youth class. Message-ID <CO6P220MB03387DFB3A1D45AD1EDB8B23D7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 (select stage from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18'), 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-20 22:21:25+00'::timestamptz
from fs_partners p
where p.id = '670cf826-1b34-49ac-b1f9-a0b582debb18'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%CO6P220MB03387DFB3A1D45AD1EDB8B23D7782%');

update fs_partners set
  ball_with = 'them',
  last_contact_at = '2026-11-20 22:21:25+00',
  next_step = 'Reply SENT Nov 20 (4:21 pm CST). Submit the Joyce Fluxx registration request Mon Nov 23 (https://joycefdn.fluxx.io/lois/new; Stephen answers the eligibility questions himself; describe the all-ages Rainbow Wednesdays series if Maddie agrees). Wait for Maddie''s answer on the Apr 1, 2027 cycle; if silent by Mon Dec 1, one short follow-up in the same thread. Dec 1, 2026 cycle is NOT available.',
  next_step_due = '2026-11-23',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Stephen sent his reply to Maddie at 4:21 pm CST (Message-ID CO6P220MB03387DFB3A1D45AD1EDB8B23D7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM). [src:msgid-CO6P220MB03387DFB3A1D45AD1EDB8B23D7782]'
where id = '670cf826-1b34-49ac-b1f9-a0b582debb18'
  and coalesce(notes,'') not like '%msgid-CO6P220MB03387DFB3A1D45AD1EDB8B23D7782%';

update fs_grant_deadlines set
  next_step = 'Reply to Maddie SENT Nov 20. Submit the Fluxx registration request Mon Nov 23 (https://joycefdn.fluxx.io/lois/new). Wait for her answer on the Apr 1, 2027 cycle; follow up Dec 1 if silent.',
  next_step_due = '2026-11-23',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Stephen sent the reply to Maddie at 4:21 pm CST. [src:msgid-CO6P220MB03387DFB3A1D45AD1EDB8B23D7782]'
where id = 'dc25d586-f390-4553-964a-01fd8090c8e1'
  and coalesce(notes,'') not like '%msgid-CO6P220MB03387DFB3A1D45AD1EDB8B23D7782%';
commit;
select ball_with, next_step_due::text, (notes like '%msgid-CO6P220MB03387DFB3A1D45AD1EDB8B23D7782%')::text ok from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18';

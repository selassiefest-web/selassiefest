-- ETHOS: fully reflect the Nov 2, 2026 exchange (Meeting_Request.eml / (1) = ETHOS reply 1:40 pm CT; (2) = our reply 2:13 pm CT).
-- Safe to re-run (activity inserts are guarded by Message-ID).
begin;
update fs_partners set
  email = 'ethosblockclubsouthshore@gmail.com',
  phone = '312-857-4822',
  contacts = '[{"name":"A Anne Holcomb","role":"Co-chair, ETHOS","email":"ethosblockclubsouthshore@gmail.com","phone":"312-857-4822"},{"name":"Linda Young","role":"Co-chair, ETHOS","email":"ethosblockclubsouthshore@gmail.com","phone":"312-857-4822"}]'::jsonb,
  last_contact_at = '2026-11-02 14:13:34-06',
  ball_with = 'them',
  updated_at = now()
where name like 'ETHOS (Environment%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
  'REPLY FROM ETHOS (co-chairs A Anne Holcomb and Linda Young), Msg-ID <CAOYerSwBDZtxr8QFnTbcaDmADokoZ4Xj1zVxdB6D2nJ1TVb+sw@mail.gmail.com>, cc the Rainbow Beach PAC president. To Albert re his Oct 11 request: "not clear if you are trying to connect with ETHOS or Rainbow Beach PAC?" ETHOS is a SE Side environmental justice org (lakefront park advocacy, parking gates and fees, Steelworkers Park framework plan, beach clean-ups). Rainbow Beach Park programming falls under the PAC, not ETHOS. Contact: ethosblockclubsouthshore@gmail.com, call or text 312-857-4822.',
  p.stage, 'ethosblockclubsouthshore@gmail.com', 'ETHOS (inbound)', '2026-11-02 13:40:49-06'
from fs_partners p where p.name like 'ETHOS (Environment%'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%CAOYerSwBDZtxr8QFnTbcaDmADokoZ4Xj1zVxdB6D2nJ1TVb%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
  'Our reply SENT by Albert Harris from selassiefest@gmail.com to ETHOS only (not the PAC), Msg-ID <CAKSj72iU56Mm2+SwHQG7O6O+mt0O1fGZ1yVkhMmhDk9UxG5F2A@mail.gmail.com>: we meant ETHOS; asked for a 15-minute call, "call Albert Harris at 262 344 7075 or reply with a day and time". Described Full Spectrum as free (Rainbow DJ Lab Tuesdays 4-6 pm from Jan 12, 2027; 14 free Rainbow Wednesdays); said we are not asking ETHOS to speak for the Park District. Follow up Mon Nov 9.',
  p.stage, 'selassiefest@gmail.com', 'Albert Harris', '2026-11-02 14:13:34-06'
from fs_partners p where p.name like 'ETHOS (Environment%'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%CAKSj72iU56Mm2+SwHQG7O6O+mt0O1fGZ1yVkhMmhDk9UxG5F2A%');
commit;

select p.name, p.email, p.phone, p.ball_with, p.last_contact_at, jsonb_array_length(p.contacts) contacts,
       (select count(*) from fs_partner_activity a where a.partner_id = p.id) activity_rows
from fs_partners p where p.name like 'ETHOS (Environment%';

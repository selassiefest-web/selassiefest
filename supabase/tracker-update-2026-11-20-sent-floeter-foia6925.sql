-- 2026-11-20: Stephen SENT (1) his reply to John Floeter (CFM/MPTF) 4:39 pm CST, (2) the FOIA 6925 extension agreement 4:44 pm CST. Re-run safe.
begin;
-- Floeter: partner row is the CFM row if one exists; log on the grant row notes always.
update fs_grant_deadlines set
  next_step = 'Stephen SENT thanks + honorary-member question to John Floeter Nov 20 (4:39 pm CST). Wait for John (details come later; he reserved funds until Jun 6, 2027 = his internal deadline; MPTF external deadline is 30 days after a complete application). Follow up once Mon Dec 14, 2026 if silent. Then: musician lineup + W-9 by about May 3, 2027 (our target), all application info to John by Jun 4-6, 2027.',
  next_step_due = '2026-12-14',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Stephen SENT reply to John Floeter at 4:39 pm CST (Message-ID CO6P220MB0338C66A0C690E8C0B61D19BD7782@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM): thanked him, kept the Jun 6 deadline, said none of our musicians are Federation members, asked whether a Federation member could join the band as an honorary member for the gig and how to accomplish that; said details can wait. [src:msgid-CO6P220MB0338C66A0C690E8C0B61D19BD7782]'
where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
  and coalesce(notes,'') not like '%msgid-CO6P220MB0338C66A0C690E8C0B61D19BD7782%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 20, 2026 (4:44 pm CST): Stephen SENT the FOIA 6925 written agreement from rastafari501c3@gmail.com to FOIA@ChicagoParkDistrict.com: agreed to extend the response date to Mon Nov 30, 2026 COB; asked for records as located or a written statement if no list exists, electronic copies preferred; asked CPD to update the file with (872) 255-9333. Gmail Message-ID <CAG0kn=Vn_ieG0MMkuqFfgwS=zRRrJx1nKhQTDjHpvqox3OAqHg@mail.gmail.com>. (ref FOIA6925 evt 2026-11-20 16:44 sent)',
 'in_conversation', 'rastafari501c3@gmail.com', 'Stephen Henry', '2026-11-20 22:44:36+00'::timestamptz
from fs_partners p
where p.id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref FOIA6925 evt 2026-11-20 16:44 sent)%');

update fs_partners set
  last_contact_at = '2026-11-20 22:44:36+00',
  next_step = coalesce(next_step,'') || ' FOIA 6925 UPDATE Nov 20, 2026 4:44 pm CST: written agreement to Nov 30 COB SENT. Wait for CPD; follow up Dec 1 if nothing by Nov 30 COB. STILL OWED: FOIA 6838 written agreement to extend to Mon Nov 23 COB from rastafari501c3@gmail.com (unless already sent).',
  notes = coalesce(notes,'') || E'\n2026-11-20: Stephen sent the FOIA 6925 extension agreement (Gmail Message-ID CAG0kn=Vn_ieG0MMkuqFfgwS=zRRrJx1nKhQTDjHpvqox3OAqHg@mail.gmail.com). [src:sent-6925-agree]'
where id = '91fad49d-bff1-4b1f-a611-e6de12145eb5'
  and coalesce(notes,'') not like '%src:sent-6925-agree%';
commit;
select (select next_step_due::text from fs_grant_deadlines where id='dc89e16f-2331-437b-b4dd-66a54ca834c5') mptf_due,
       (select count(*) from fs_partner_activity where summary like '%FOIA6925 evt%')::text foia6925_events;

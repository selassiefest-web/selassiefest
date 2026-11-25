-- Deputy Mayor Humphries' Nov 25, 2026 follow-up: four referrals. Safe to re-run.
-- Source: C:\Users\mkepr\Downloads\BOB\Meeting_Today.eml (Khari Humphries to selassiefest@gmail.com, cc Addison Rao, Nov 25 17:26:31 UTC = 11:26 am CST,
-- subject "RE: Meeting Today", Message-ID fragment AT6PR09MB13092348DFD563D79CEBF98CBFA432). He replied to Albert's 11:01 am follow-up and listed:
-- Temeszja Drummond, Adrian Loza (Park District), "MCMF South Shore and MCMF Citywide", Stender Von Oehsen (City of Chicago), and a Boys and Girls Club parties video.
begin;

insert into fs_partners (id, name, category, email, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes)
select v.id::uuid, v.name, (select category from fs_partners where name = 'Office of Mayor Brandon Johnson' limit 1), v.email, v.contacts::jsonb,
  array['programming'], array['classes'], 'not_contacted', 'us', v.ask, v.next_step, '2026-11-25', 'Deputy Mayor Humphries email Nov 25, 2026', v.notes
from (values
 ('b7e41c20-5d93-4a6e-8f12-3c9d0e7a1b51', 'Chicago Park District: Temeszja Drummond (named by Deputy Mayor Humphries)', 'temeszja.drummond@chicagoparkdistrict.com',
  '[{"name":"Temeszja Drummond","email":"temeszja.drummond@chicagoparkdistrict.com","role":"Chicago Park District (title unverified; public listings say teen engagement)"}]',
  'A short video call to ask how the Rainbow DJ Lab and Rainbow Wednesdays can work with Park District youth programs.',
  'Introduce ourselves (draft, Stephen says send): name the Deputy Mayor''s Nov 25 follow-up, one-paragraph program, ask for a 15-minute video call. Ivry Ector should hear about this from us first (she asked us to be careful about outside groups).',
  'Named in Khari Humphries'' Nov 25, 2026 follow-up email (no reason or role stated). Title not confirmed by us. [src:msgid-AT6PR09MB13092348DFD563D79CEBF98CBFA432]'),
 ('c8f52d31-6ea4-4b7f-9023-4dae1f8b2c62', 'Chicago Park District: Adrian Loza (named by Deputy Mayor Humphries)', 'Adrian.Loza@ChicagoParkDistrict.com',
  '[{"name":"Adrian Loza","email":"Adrian.Loza@ChicagoParkDistrict.com","role":"Chicago Park District (title unverified)"}]',
  'A short video call to ask how the Rainbow DJ Lab and Rainbow Wednesdays can work with Park District programs.',
  'Introduce ourselves (draft, Stephen says send), same approach as Temeszja Drummond. Ivry Ector should hear first.',
  'Named in Khari Humphries'' Nov 25, 2026 follow-up email (no reason or role stated). Title not confirmed by us. [src:msgid-AT6PR09MB13092348DFD563D79CEBF98CBFA432]'),
 ('d9a63e42-7fb5-4c80-a134-5ebf2a9c3d73', 'City of Chicago: Stender Von Oehsen (named by Deputy Mayor Humphries)', 'Stender.VonOehsen@cityofchicago.org',
  '[{"name":"Stender Von Oehsen","email":"Stender.VonOehsen@cityofchicago.org","role":"City of Chicago (public listings: youth programs, DFSS and the My CHI. My Future. data contact; unverified)"}]',
  'A short video call about listing the free Rainbow DJ Lab where the City connects youth to out-of-school programs.',
  'Introduce ourselves (draft, Stephen says send): the Deputy Mayor''s Nov 25 follow-up, one-paragraph program, ask for a 15-minute call.',
  'Named in Khari Humphries'' Nov 25, 2026 follow-up email. [src:msgid-AT6PR09MB13092348DFD563D79CEBF98CBFA432]'),
 ('e0b74f53-8ac6-4d91-b245-6fc03b0a4d84', 'MCMF South Shore and MCMF Citywide (named by Deputy Mayor Humphries)', null,
  '[]',
  'Find the right contact for each, then ask for a short call.',
  'NO CONTACT GIVEN. Khari wrote only "MCMF South Shore and MCMF Citywide". Our reading: My CHI. My Future. (the City''s out-of-school youth program network), UNCONFIRMED. Ask Khari or Addison Rao which program and who to write to, or find the contact on the program''s own site.',
  'Written by Khari Humphries in his Nov 25, 2026 email with no name or address. Do not guess the program. [src:msgid-AT6PR09MB13092348DFD563D79CEBF98CBFA432]')
) as v(id, name, email, contacts, ask, next_step, notes)
where not exists (select 1 from fs_partners p where p.id = v.id::uuid);

update fs_partners set
  stage = 'in_conversation', ball_with = 'us', last_contact_at = '2026-11-25 17:26:31+00',
  next_step = 'Meeting HELD Nov 25, 2026 (Stephen and Albert Harris). Khari Humphries replied 11:26 am CT with four referrals (Temeszja Drummond, Adrian Loza, MCMF South Shore and Citywide, Stender Von Oehsen) and a Boys and Girls Club parties video: https://youtu.be/w3sW0sldplg?si=Ub1yj-cV3-RZLNZL . Next: contact each referral (their own rows), then thank Khari and Addison Rao in the same thread. No letter of support from the office confirmed yet.',
  next_step_due = '2026-11-25',
  notes = coalesce(notes, '') || ' | [humphries-reply 2026-11-25] Albert sent the follow-up at 11:01 am CT from selassiefest@gmail.com (the earlier text: ask for a letter of support, program paragraph, deck link). Khari replied 11:26 am CT, cc Addison Rao, with referrals only; no answer on the letter of support in that email. Clean status page for him, not yet sent: https://selassiefest.com/full-spectrum/mayor/where-we-are-k7q2x9/',
  updated_at = now()
where name = 'Office of Mayor Brandon Johnson'
  and coalesce(notes, '') not like '%[humphries-reply 2026-11-25]%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary, 'in_conversation', 'stephen@selassiefest.com', 'Claude', v.at::timestamptz
from fs_partners p, (values
 ('2026-11-25 17:01:00+00', 'Nov 25, 2026 11:01 am CT: after the 11:00 meeting with Deputy Mayor Humphries (Stephen and Albert Harris attended), Albert emailed Humphries and Addison Rao from selassiefest@gmail.com, subject "Meeting Today": thanks, the one ask (a letter of support from the Office of Education and Youth, or a staff contact funders can call), the program paragraph and the deck link. [src:albert-followup-2026-11-25]', 'albert-followup-2026-11-25'),
 ('2026-11-25 17:26:31+00', 'Nov 25, 2026 11:26 am CT: Khari Humphries replied (cc Addison Rao), subject "RE: Meeting Today": "Follow-up" with names to contact: Temeszja Drummond and Adrian Loza (Chicago Park District), "MCMF South Shore and MCMF Citywide", Stender Von Oehsen (City of Chicago), and a link to a video about Boys and Girls Club parties (https://youtu.be/w3sW0sldplg). No answer on the letter of support. Message-ID <AT6PR09MB13092348DFD563D79CEBF98CBFA432@AT6PR09MB13092.namprd09.prod.outlook.com> [src:msgid-AT6PR09MB13092348DFD563D79CEBF98CBFA432]', 'AT6PR09MB13092348DFD563D79CEBF98CBFA432')
) as v(at, summary, frag)
where p.name = 'Office of Mayor Brandon Johnson'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%' || v.frag || '%');

commit;

select name, stage, ball_with, next_step_due::text from fs_partners
where id in ('b7e41c20-5d93-4a6e-8f12-3c9d0e7a1b51','c8f52d31-6ea4-4b7f-9023-4dae1f8b2c62','d9a63e42-7fb5-4c80-a134-5ebf2a9c3d73','e0b74f53-8ac6-4d91-b245-6fc03b0a4d84') or name = 'Office of Mayor Brandon Johnson';
select count(*) as mayor_activity_rows_from_today from fs_partner_activity a join fs_partners p on p.id = a.partner_id
where p.name = 'Office of Mayor Brandon Johnson' and (a.summary like '%albert-followup-2026-11-25%' or a.summary like '%AT6PR09MB13092348DFD563D79CEBF98CBFA432%');

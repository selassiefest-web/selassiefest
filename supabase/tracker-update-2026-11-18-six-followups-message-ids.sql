-- 2026-11-18: add sent-copy Message-IDs and the real send time (Nov 19 03:47 UTC = Nov 18 9:47 pm CST) to the six follow-ups. Guarded; safe to re-run.
begin;
update fs_grant_deadlines set notes=notes||E'
[2026-11-18] Sent copy Message-ID <010001a1f1ead2cf-9f22c79d-2a48-4a7e-b82a-0140eb71439f-000000@email.amazonses.com> (Nov 18 9:47 pm CST).' where id='acf259fe-568c-407d-a2f9-b4b61ef2ed46' and notes not like '%010001a1f1ead2cf-9f22c79%';
update fs_partner_activity set created_at='2026-11-19 03:47:40+00', summary=summary||' Message-ID <010001a1f1ead30b-837f3e99-79ef-4745-8cc3-b6775f4d48a3-000000@email.amazonses.com>; sent 2026-11-18 9:47 pm CST.' where partner_id='02010f0d-fa59-47a7-afe8-0bbccd1f4130' and summary like '%01a1f1ea-d1b6-727a-a14b-bdc819c714a6%' and summary not like '%010001a1f1ead30b-837f3e9%';
update fs_partners set last_contact_at='2026-11-19 03:47:40+00' where id='02010f0d-fa59-47a7-afe8-0bbccd1f4130' and last_contact_at > '2026-11-19 03:47:40+00' and last_contact_at < '2026-11-19 05:30:00+00';
update fs_grant_deadlines set notes=notes||E'
[2026-11-18] Sent copy Message-ID <010001a1f1ead30b-837f3e99-79ef-4745-8cc3-b6775f4d48a3-000000@email.amazonses.com> (Nov 18 9:47 pm CST).' where id='fb277887-9f0d-441f-9967-37fa7f6c58bf' and notes not like '%010001a1f1ead30b-837f3e9%';
update fs_grant_deadlines set notes=notes||E'
[2026-11-18] Sent copy Message-ID <010001a1f1ead30f-fbcb8e1c-b0ff-498d-9842-87069da8e060-000000@email.amazonses.com> (Nov 18 9:47 pm CST).' where id='35c653bc-83a9-4427-9b43-a698d44c4382' and notes not like '%010001a1f1ead30f-fbcb8e1%';
update fs_partner_activity set created_at='2026-11-19 03:47:41+00', summary=summary||' Message-ID <010001a1f1ead381-c81f1fe7-25a6-48d1-8cdb-e3055b46e155-000000@email.amazonses.com>; sent 2026-11-18 9:47 pm CST.' where partner_id='6e6c31a2-a474-48b6-aedc-ad3e8d39e022' and summary like '%01a1f1ea-d2b5-77f3-bef4-5c7b7e0b91ec%' and summary not like '%010001a1f1ead381-c81f1fe%';
update fs_partners set last_contact_at='2026-11-19 03:47:41+00' where id='6e6c31a2-a474-48b6-aedc-ad3e8d39e022' and last_contact_at > '2026-11-19 03:47:41+00' and last_contact_at < '2026-11-19 05:30:00+00';
update fs_grant_deadlines set notes=notes||E'
[2026-11-18] Sent copy Message-ID <010001a1f1ead381-c81f1fe7-25a6-48d1-8cdb-e3055b46e155-000000@email.amazonses.com> (Nov 18 9:47 pm CST).' where id='5cbce63b-2bb4-48d4-8422-7f6f141af380' and notes not like '%010001a1f1ead381-c81f1fe%';
update fs_partner_activity set created_at='2026-11-19 03:47:41+00', summary=summary||' Message-ID <010001a1f1ead442-4acfb281-a051-4c48-8222-a89b140e7916-000000@email.amazonses.com>; sent 2026-11-18 9:47 pm CST.' where partner_id='ae44d885-832f-4de2-8322-e8321175edc8' and summary like '%01a1f1ea-d338-7404-bb1b-659c3422b745%' and summary not like '%010001a1f1ead442-4acfb28%';
update fs_partners set last_contact_at='2026-11-19 03:47:41+00' where id='ae44d885-832f-4de2-8322-e8321175edc8' and last_contact_at > '2026-11-19 03:47:41+00' and last_contact_at < '2026-11-19 05:30:00+00';
update fs_grant_deadlines set notes=notes||E'
[2026-11-18] Sent copy Message-ID <010001a1f1ead442-4acfb281-a051-4c48-8222-a89b140e7916-000000@email.amazonses.com> (Nov 18 9:47 pm CST).' where id='6c050a1a-ae09-4877-9563-9aefb85b1ec7' and notes not like '%010001a1f1ead442-4acfb28%';
update fs_partner_activity set created_at='2026-11-19 03:47:41+00', summary=summary||' Message-ID <010001a1f1ead495-235286a6-78ba-4178-a16b-057d810354b9-000000@email.amazonses.com>; sent 2026-11-18 9:47 pm CST.' where partner_id='aad5ab14-8354-47f0-ac24-a09f195f03a2' and summary like '%01a1f1ea-d3b7-7c01-ac92-5ed76511531d%' and summary not like '%010001a1f1ead495-235286a%';
update fs_partners set last_contact_at='2026-11-19 03:47:41+00' where id='aad5ab14-8354-47f0-ac24-a09f195f03a2' and last_contact_at > '2026-11-19 03:47:41+00' and last_contact_at < '2026-11-19 05:30:00+00';
update fs_grant_deadlines set notes=notes||E'
[2026-11-18] Sent copy Message-ID <010001a1f1ead495-235286a6-78ba-4178-a16b-057d810354b9-000000@email.amazonses.com> (Nov 18 9:47 pm CST).' where id='383b51a1-d28a-4fff-b8c2-0dfbb808925b' and notes not like '%010001a1f1ead495-235286a%';
commit;
select (select count(*) from fs_partner_activity where summary like '%010001a1f1ead%') acts,(select count(*) from fs_grant_deadlines where notes like '%010001a1f1ead%') grants;

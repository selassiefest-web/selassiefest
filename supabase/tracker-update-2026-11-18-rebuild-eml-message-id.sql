-- 2026-11-18: add the sent-copy Message-ID and real send time (Nov 19 03:23:27 UTC = Nov 18 9:23 pm CST) to the Rebuild intro-ask records. Guarded; safe to re-run.
begin;
update fs_partner_activity
set created_at='2026-11-19 03:23:27+00',
    summary = summary || ' Message-ID <010001a1f1d4a71b-fa097765-d423-405e-ba84-d426bf7fde37-000000@email.amazonses.com>; sent 2026-11-18 9:23 pm CST.'
where partner_id='df05922a-d53a-43a1-b074-ea1949c266e1' and summary like '%01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d%' and summary not like '%010001a1f1d4a71b%';
update fs_partners set last_contact_at='2026-11-19 03:23:27+00'
where id='df05922a-d53a-43a1-b074-ea1949c266e1' and last_contact_at > '2026-11-19 03:23:27+00' and last_contact_at < '2026-11-19 04:30:00+00';
commit;
select created_at, right(summary,130) tail from fs_partner_activity where partner_id='df05922a-d53a-43a1-b074-ea1949c266e1' and summary like '%010001a1f1d4a71b%';

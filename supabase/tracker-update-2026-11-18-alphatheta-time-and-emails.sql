-- 2026-11-18 (Stephen: "FIX THE TIME" and "keep both addresses").
-- 1) Activity 303315b2 (Israel Rodriguez, Message-ID <TY7P286MB688210491C93E10DBF50BE3CEC7C2@...>) summary said "4:23 pm CT"; the email was sent
--    Mon Nov 16 21:23:14 UTC = 3:23 pm CST (created_at was already correct). Fix the text only.
-- 2) AlphaTheta partner row a2e09e2e: keep the old john.powell@pioneerdj.com address AND add Israel's live address (israel.rodriguez@alphatheta.com, from the email From header).
-- Safe to re-run (guarded on the old text / old value).
begin;

update fs_partner_activity
set summary = replace(summary, 'Nov 16, 2026 (4:23 pm CT)', 'Nov 16, 2026 (3:23 pm CT)')
where id::text like '303315b2%'
  and summary like 'Nov 16, 2026 (4:23 pm CT)%';

update fs_partners
set email = 'israel.rodriguez@alphatheta.com; john.powell@pioneerdj.com'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and email = 'john.powell@pioneerdj.com';

commit;

select left((select summary from fs_partner_activity where id::text like '303315b2%'), 40) as activity_start,
       (select email from fs_partners where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a') as partner_email;

-- Email audit batch F (Nov 2, 2026): Seabury last_contact_at said Oct 16, but Yaza replied and Stephen answered on Oct 28 (5:36 PM CT, activity already logged).
begin;
update fs_partners set last_contact_at = timestamptz '2026-10-28 17:36-05', updated_at = now()
where name = 'The Seabury Foundation - Community Grants' and last_contact_at < timestamptz '2026-10-28 00:00-05';
select name, last_contact_at::date lc from fs_partners where name = 'The Seabury Foundation - Community Grants';
commit;

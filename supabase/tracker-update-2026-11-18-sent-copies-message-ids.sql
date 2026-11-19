-- 2026-11-18: record the Message-IDs of the two sent copies saved in BOB (Design Museum nudge, NAMM pre-inquiry). Guarded; safe to re-run.
begin;
update fs_grant_deadlines set notes=coalesce(notes,'')||E'\n[2026-11-18] Sent copy saved in BOB; Message-ID <010001a1f1b3b48b-32a84c62-00ec-4efa-a9d2-1f36f106aadf-000000@email.amazonses.com> (Nov 19 02:47 UTC).'
where id='b14b1116-d183-4e84-a758-d8dfb23aa975' and coalesce(notes,'') not like '%010001a1f1b3b48b%';
update fs_grant_deadlines set notes=coalesce(notes,'')||E'\n[2026-11-18] Sent copy saved in BOB; Message-ID <010001a1f1b4833e-b40130ab-c8f5-42cb-81c5-82db4163f6b4-000000@email.amazonses.com> (Nov 19 02:48 UTC).'
where id='27809596-c036-4007-8aa1-bc1239138800' and coalesce(notes,'') not like '%010001a1f1b4833e%';
commit;
select (select count(*) from fs_grant_deadlines where notes like '%010001a1f1b3b48b%') dm,(select count(*) from fs_grant_deadlines where notes like '%010001a1f1b4833e%') namm;

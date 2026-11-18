-- Nov 18, 2026: Shure activity row efe5737b was logged with processing time (Nov 15 20:18:13Z) instead of the event time.
-- Event: Cheryl Jennison Daproza's Nov 10, 2026 2:59 pm CST email = 20:59:00 UTC (CST is UTC-6 after Nov 1). Message-ID <SA1PR01MB867102105F19993167A43FE9BD722@SA1PR01MB8671.prod.exchangelabs.com>.
-- Only created_at changes; summary and stage_after are untouched. Safe to re-run (guarded on the old timestamp).
begin;
update fs_partner_activity set created_at = '2026-11-10 20:59:00+00'
where id = 'efe5737b-da7a-44d4-a752-d5cecdc33fbc'
  and partner_id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
  and created_at = '2026-11-15 20:18:13.476729+00'
  and summary like '%SA1PR01MB867102105F19993167A43FE9BD722%';
commit;
select created_at, left(summary,50) s from fs_partner_activity where partner_id='bf4f3ad5-727f-467b-8f88-de2ad65d9c4d' order by created_at;

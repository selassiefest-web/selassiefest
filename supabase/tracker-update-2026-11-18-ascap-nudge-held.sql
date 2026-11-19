-- 2026-11-18: Stephen said HOLD the ASCAP nudge (his word in chat). Grant e15c8f2e and partner 1249b12b: nudge held, due date cleared so it is not reported overdue. Guarded; safe to re-run.
begin;
update fs_grant_deadlines set next_step='HELD by Stephen Nov 18, 2026: do NOT send the ASCAP nudge until Stephen says so. Proposal sent Nov 2 ($5,000 My Song Project, with IRS letter; Ariya Sonethavy invited it); no reply logged. Status stays submitted.',
 next_step_due=null,
 notes=coalesce(notes,'')||E'\n[2026-11-18] ASCAP nudge HELD by Stephen (his word in chat); date cleared.'
where id::text like 'e15c8f2e%' and coalesce(notes,'') not like '%ASCAP nudge HELD by Stephen%';
update fs_partners set next_step='HELD by Stephen Nov 18, 2026: do NOT send the ASCAP nudge until Stephen says so. Proposal sent Nov 2; no reply logged.',
 next_step_due=null,
 notes=coalesce(notes,'')||E'\n[2026-11-18] ASCAP nudge HELD by Stephen (his word in chat); date cleared.'
where id='1249b12b-d550-4117-b1d3-e494be5df008' and coalesce(notes,'') not like '%ASCAP nudge HELD by Stephen%';
commit;
select (select next_step_due from fs_grant_deadlines where id::text like 'e15c8f2e%') g,(select next_step_due from fs_partners where id='1249b12b-d550-4117-b1d3-e494be5df008') p,(select count(*) from fs_grant_deadlines where notes like '%ASCAP nudge HELD%') n;

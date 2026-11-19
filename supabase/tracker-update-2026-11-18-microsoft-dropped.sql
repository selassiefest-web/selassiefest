-- 2026-11-18: Stephen said "we are dropping Microsoft": Microsoft for Nonprofits (Goodstack validation submitted Oct 28) set to skip; date cleared. Guarded; safe to re-run.
begin;
update fs_grant_deadlines set status='skip',
 next_step='DROPPED by Stephen Nov 18, 2026: no further action on Microsoft. Goodstack validation had been submitted Oct 28 (no result seen). Nothing to do.',
 next_step_due=null,
 notes=coalesce(notes,'')||E'\n[2026-11-18] DROPPED by Stephen (his word in chat); status set to skip; date cleared.'
where id='b20acff8-1390-43ff-a3af-0d35a4fd5060' and status='submitted' and coalesce(notes,'') not like '%DROPPED by Stephen (his word in chat)%';
commit;
select status, next_step_due from fs_grant_deadlines where id='b20acff8-1390-43ff-a3af-0d35a4fd5060';

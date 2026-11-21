-- Nov 21, 2026 (Stephen: "tabled"): NEH Exhibitions Planning and DCASE Taste of Chicago follow-up are TABLED. Rainbow Cone was already tabled and stays so.
-- Guarded; safe to re-run.
begin;

update fs_grant_deadlines set updated_at=now(), next_step_due=null,
 next_step='TABLED by Stephen Nov 21, 2026: no decision and no action on NEH Exhibitions Planning (2027 cycle, deadline anticipated late fall or December 2027, not published) until Stephen reopens it. '||next_step
where id='a75ac9d3-114c-4435-ac20-b3b7e4f27eb7' and next_step not like 'TABLED by Stephen Nov 21, 2026%';

update fs_partners set updated_at=now(), next_step_due=null, ball_with='parked',
 next_step='TABLED by Stephen Nov 21, 2026: no follow-up to DCASE on Taste of Chicago until Stephen reopens it. (Prior next step: '||coalesce(next_step,'')||')'
where id='6bd82768-613c-496f-bb39-a2f8a0238a78' and coalesce(next_step,'') not like 'TABLED by Stephen Nov 21, 2026%';

commit;

select 'neh' k, next_step_due::text v, left(next_step,40) n from fs_grant_deadlines where id='a75ac9d3-114c-4435-ac20-b3b7e4f27eb7'
union all select 'taste', next_step_due::text||' '||ball_with, left(next_step,40) from fs_partners where id='6bd82768-613c-496f-bb39-a2f8a0238a78';

-- Align ADM partner follow-up date with the grant row (reviewer finding, Nov 25, 2026). No follow-up logged. Safe to re-run.
begin;
update fs_partners set next_step_due = date '2026-12-03'
where id = '358a7095-4056-4000-a2dc-2aaee2ad494f' and next_step_due = date '2026-11-23';
commit;
select name, next_step_due, next_step from fs_partners where id = '358a7095-4056-4000-a2dc-2aaee2ad494f';

-- 2026-11-20: Eventbrite order confirmation for Consult DCASE (Order #16161304553): 3 free tickets, all in ALBERT HARRIS's name:
-- Meet with Cultural Resources, Meet with Exhibitions, Meet with Cultural Grants. Wed Dec 9, 2026 11:30 am-1:00 pm CT,
-- Chicago Cultural Center, 78 E. Washington St., Chicago 60602. Sent to selassiefest@gmail.com Nov 20, 2026 22:01 UTC. Re-run safe.
begin;
update fs_grant_deadlines set
  next_step = replace(next_step, 'REGISTERED Nov 20, 2026 for "Consult DCASE" office hours Wed Dec 9, 2026, 11:30 am-1 pm CST (3 tickets, order #16161304553, sent to selassiefest@gmail.com)', 'REGISTERED Nov 20, 2026 (in Albert Harris''s name) for "Consult DCASE" Wed Dec 9, 2026, 11:30 am-1 pm CT, Chicago Cultural Center, 78 E. Washington St. (3 free tickets: Cultural Resources, Exhibitions, Cultural Grants; order #16161304553; confirmation went to selassiefest@gmail.com)'),
  notes = coalesce(notes,'') || E'\n[2026-11-20] Eventbrite confirmation: all 3 tickets are in ALBERT HARRIS''s name (Meet with Cultural Resources / Exhibitions / Cultural Grants), Wed Dec 9, 2026 11:30 am-1:00 pm CT, Chicago Cultural Center, 78 E. Washington St., Chicago 60602, free, offline payment. Confirm with Albert who attends and which of the three meetings is for Cultural Grants. [src:order-16161304553-albert]'
where id = 'bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed'
  and coalesce(notes,'') not like '%src:order-16161304553-albert%';
commit;
select (notes like '%src:order-16161304553-albert%') ok, (next_step like '%Albert Harris%') step_ok from fs_grant_deadlines where id='bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed';

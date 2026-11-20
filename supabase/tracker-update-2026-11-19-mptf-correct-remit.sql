-- 2026-11-19: correct MPTF row: Stephen did NOT commit to remit dues/pension; asking John whether a union member can join and the cost. Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step = replace(next_step, 'none of the players are CFM members, so Stephen is John''s contact and remits dues/pension.', 'none of the current players are CFM members; Stephen is asking John whether a CFM member can lead/join the band on this grant and what dues/pension would cost (no commitment to remit made).'),
  notes = coalesce(notes,'') || E'\n[2026-11-19] CORRECTION: do not read the earlier line as a commitment to remit dues/pension; John said details later. Stephen is asking John about a union-member leader and costs.'
where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
  and coalesce(notes,'') not like '%CORRECTION: do not read the earlier line%';
commit;
select (notes like '%CORRECTION: do not read%')::text marker, (next_step like '%no commitment to remit made%')::text in_step from fs_grant_deadlines where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5';

-- 2026-11-19: Stephen confirmed none of the players are CFM Local 10-208 members. Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step = replace(next_step, 'Our plan, not John''s request: confirm musician lineup, union status and any W-9,', 'Stephen confirmed Nov 19, 2026: none of the players are CFM members, so Stephen is John''s contact and remits dues/pension. Our plan, not John''s request: confirm musician lineup and any W-9,'),
  notes = coalesce(notes,'') || E'\n[2026-11-19] Stephen (chat): none of the musicians are CFM Local 10-208 members; Stephen is contact and remits work dues and pension.'
where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
  and coalesce(notes,'') not like '%none of the musicians are CFM Local 10-208 members%';
commit;
select next_step_due::text, (notes like '%none of the musicians are CFM%')::text marker, (next_step like '%none of the players are CFM members%')::text in_step from fs_grant_deadlines where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5';

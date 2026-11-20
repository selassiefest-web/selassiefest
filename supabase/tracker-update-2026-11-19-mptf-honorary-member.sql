-- 2026-11-19: Stephen's wording: a CFM member would JOIN the band as an honorary member for the gig (not lead it). Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step = replace(next_step, 'whether a CFM member can lead/join the band on this grant', 'whether a CFM member can join the band as an honorary member for the gig on this grant'),
  notes = coalesce(notes,'') || E'\n[2026-11-19] Stephen clarified: the idea is a CFM member joining the band as an honorary member for the gig, not leading it.'
where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
  and coalesce(notes,'') not like '%joining the band as an honorary member for the gig%';
commit;
select (notes like '%honorary member for the gig%')::text marker, (next_step like '%as an honorary member for the gig%')::text in_step from fs_grant_deadlines where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5';

-- Driehaus Foundation: by invitation only; Arts and Culture excludes arts education/learning and pilot programs; Category C festivals are $30,000+. Not a fit for the DJ Lab. Sources: driehausfoundation.org/funding and /funding/arts-and-culture (checked Nov 23, 2026). Safe to re-run.
begin;
update fs_grant_deadlines set status='not_eligible', next_step_due=null,
  next_step='Closed Nov 23, 2026: not a fit for the DJ Lab (invitation only; arts education and learning and pilot programs excluded). Revisit only if Stephen wants a Category C Chicago-rooted festival-platform inquiry ($30,000+ project budget) for SelassieFest 2027.',
  notes=case when coalesce(notes,'') like '%2026-11-23: not eligible (Driehaus)%' then notes else coalesce(notes,'')||E'\n2026-11-23: not eligible (Driehaus): invitation only, arts education/learning and pilot programs excluded, Category C festivals $30,000 to $1M.' end
where id='c128e0dd-73e4-4cb5-968a-6628a4cad185';
select funder,status,next_step_due from fs_grant_deadlines where id='c128e0dd-73e4-4cb5-968a-6628a4cad185';
commit;

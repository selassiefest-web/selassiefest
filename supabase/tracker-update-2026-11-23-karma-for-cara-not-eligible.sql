-- Karma for Cara Microgrants: students 18 and under only; Ras Tafari Inc. is adult-run. Source: https://karmaforcara.org/microgrant-application (checked Nov 23, 2026). Safe to re-run.
begin;
update fs_grant_deadlines set status='not_eligible', next_step_due=null,
  next_step='Closed Nov 23, 2026: funder accepts applications only from students 18 and under; Ras Tafari Inc. is an adult-run organization. Revisit only if a DJ Lab student volunteers to lead (next window Jan 1, 2027).',
  notes=case when coalesce(notes,'') like '%2026-11-23: not eligible%' then notes else coalesce(notes,'')||E'\n2026-11-23: not eligible (students 18 and under only; stipends and facility rentals excluded).' end
where id='1da1f71a-c66b-4a22-a007-68cfdbec4f68';
select funder,status,next_step_due from fs_grant_deadlines where id='1da1f71a-c66b-4a22-a007-68cfdbec4f68';
commit;

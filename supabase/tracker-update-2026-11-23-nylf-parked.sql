-- New York Life Foundation: no public application. Community Impact Grants ($5,000-$25,000) need a NY Life agent to champion the nonprofit; Coaching the Future RFP expected 2027. Sources: newyorklife.com/foundation/grant-opportunities (+ /workplace-grants, /local-grants), checked Nov 23, 2026. Safe to re-run.
begin;
update fs_grant_deadlines set next_step_due='2027-01-04',
  next_step='Parked Nov 23, 2026: no public application. Community Impact needs a NY Life agent to champion us; recheck https://www.newyorklife.com/foundation/grant-opportunities/local-grants on Jan 4, 2027 for the Coaching the Future RFP (expected 2027). Champion note drafted if an agent turns up.',
  notes=case when coalesce(notes,'') like '%2026-11-23: no public application (NYLF)%' then notes else coalesce(notes,'')||E'\n2026-11-23: no public application (NYLF): Community Impact $5,000-$25,000 via employee/agent champion; Grief Reach is bereavement only; Coaching the Future expected 2027.' end
where id='d3f65537-f31b-47ed-a7b4-dc681cf4d557';
select funder,status,next_step_due from fs_grant_deadlines where id='d3f65537-f31b-47ed-a7b4-dc681cf4d557';
commit;

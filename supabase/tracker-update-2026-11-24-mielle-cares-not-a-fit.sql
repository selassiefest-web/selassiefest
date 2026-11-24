-- Mielle Cares: weak fit. Summer Fund backs youth-led events by ages 14-24 with a local 501(c)(3) partner, is closed at capacity, and the mission is teen mental health. No email published (contact web form only). Source: miellecares.org/summerfund, checked Nov 24, 2026. Safe to re-run.
begin;
update fs_grant_deadlines set status='not_eligible', verified=true, verified_on='2026-11-24', next_step_due=null,
  next_step='Closed Nov 24, 2026: weak fit. Summer Fund backs youth-led events (ages 14-24) and is closed at capacity; mission is teen mental health. No action. Revisit only if youth aged 14-24 plan a Rainbow Wednesday night.',
  notes=case when coalesce(notes,'') like '%2026-11-24: not a fit (Mielle Cares)%' then notes else coalesce(notes,'')||E'\n2026-11-24: not a fit (Mielle Cares). Verified at miellecares.org/summerfund: youth-led events, ages 14-24, apply with a local 501(c)(3) partner, closed at capacity; no amounts, no email listed (contact form only); MiSpace Grant page not found.' end
where id='4ebcc442-49c2-43b4-86c5-3af0f3e24c6e';
select funder,status,next_step_due from fs_grant_deadlines where id='4ebcc442-49c2-43b4-86c5-3af0f3e24c6e';
commit;

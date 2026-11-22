-- Nov 22, 2026 (Stephen): the LUMA8 / Sharene route for Barry Callebaut is dead: LUMA8 solicits sponsorship FROM companies, so it cannot introduce us. Safe to re-run (marker-guarded).
begin;
update fs_grant_deadlines set
 next_step_due='2026-11-23',
 next_step='LUMA8 / Sharene route DROPPED (Stephen, Nov 22): LUMA8 solicits sponsorship from companies like Barry Callebaut, so it cannot introduce us; no email goes to LUMA8. Remaining online route: the Barry Callebaut head-office contact form https://www.callebaut.com/en-US/contact-us?department=2448 (Subject "Other requests"; fields and character limit not yet checked). Stephen decides whether to use it; the row stays to_research. Online only.',
 notes = notes || E'\n2026-11-22 [bc-luma8-dropped-20261122] Stephen: "We cannot go through Sharene as she solicits sponsorship FROM them." The LUMA8 referral email (draft only, never sent) is abandoned; Barry Callebaut was never contacted. Do not email LUMA8 or Arts in the Dark about Barry Callebaut. Fallback is the head-office form only. Nothing sent, awarded or received.'
where id='e562dd73-084f-45fa-be5f-5c8e8bca8910' and notes not like '%bc-luma8-dropped-20261122%';
commit;
select status, next_step_due::text, (notes like '%bc-luma8-dropped-20261122%') noted from fs_grant_deadlines where id='e562dd73-084f-45fa-be5f-5c8e8bca8910';

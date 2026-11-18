-- Nov 18, 2026: Jane Goodall's Roots & Shoots Chicago Basecamp Project Grant AWARDED $250 (email Nov 17). Safe to re-run.
begin;
update fs_grant_deadlines set
  status = 'awarded',
  amount_awarded = 250,
  decision_on = '2026-11-17',
  next_step = 'ACCEPT THE AWARD: click https://manager.submittable.com/user/confirm/55655939 (submission 55655939; Stephen or Albert, whoever holds the Submittable login) and put any mailing-address change in the acceptance text box. Then watch for the Tremendous email ($250 digital or physical gift card); if no access to funds within two weeks of the Nov 17 award (by Dec 1) write Alex Biswas, abiswas@janegoodall.org. Terms: spend the entire $250 before it expires, only on items for the Roots & Shoots project; Project Grant Report or Progress Report due Dec 30, 2026 (send a progress report if the project is not finished); create AND update the project profile on rootsandshoots.org (membership registration was pending); take the program surveys; use the grantee badge and logos (Google folder in the email) on project materials and tag @rootsandshoots.',
  next_step_due = '2026-11-18',
  notes = coalesce(notes,'') || E'\n2026-11-17 AWARDED $250: email "Congratulations, Stephen! Roots & Shoots Project Grant" from Alex Biswas (she/her), Roots & Shoots Basecamp Coordinator, Chicago, on behalf of the Jane Goodall Institute, via Submittable, 16:42 UTC (10:42 am CT), Message-ID <20261117164223.61a6ce79822c7c86@email.submittable.com>. $250 digital or physical gift card from partner Tremendous. Conditions: accept via the confirm link; spend all $250 before it expires on project items; report by Dec 30; create and update the rootsandshoots.org project profile; program surveys. Contact abiswas@janegoodall.org if funds are not accessible within two weeks. Grantee badge and logos folder linked in the email (a Google folder; link kept in the .eml).'
where id = '38c4ff8b-f15a-4c28-9182-8093fb370263';
commit;
select status, amount_awarded, decision_on, next_step_due from fs_grant_deadlines where id = '38c4ff8b-f15a-4c28-9182-8093fb370263';

-- Nov 6, 2026: Delta Air Lines DECLINED (CyberGrants 106198997); Deed (Bonterra) login-change notice. Safe to re-run.
begin;

update fs_grant_deadlines set
  status = 'declined',
  decision_on = '2026-11-06',
  next_step = 'DECLINED Nov 6, 2026 (CyberGrants 106198997): "does not meet our current marketing or philanthropic objectives given our limited cash and barter resources." Delta treated it as a Sponsorship request (corporate partner), not Charitable Giving. Closed; do not contact or reapply. Guest DJ flights stay unfunded: invite local guests first or ask another airline with a different offer.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n2026-11-06 DECLINED by The Delta Marketing Team (do-not-reply@cybergrants.com, 1:42 AM CT, Message-ID <606200213.94298.1793947335214.JavaMail.ias@cg-jmail-prod>). Reason is resources, not fit. Their wording says "Sponsorship Grants ... corporate partner": the form we submitted was read as a sponsorship (marketing) proposal, but our file called for the Charitable Giving route. LESSON: confirm which request type the funder actually received before asking.'
where id = '7d0f78f9-4739-4bb0-a6ab-3086b7028d9f'
  and notes not like '%2026-11-06 DECLINED%';

update fs_partners set
  stage = 'declined', ball_with = 'parked',
  last_contact_at = '2026-11-06T06:42:15Z',
  commitment = null,
  next_step = 'Closed Nov 6, 2026. Delta declined (limited cash and barter resources). No follow-up. Guest DJ flights remain unfunded.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n2026-11-06 DECLINED, CyberGrants request 106198997 (submitted Nov 2; Delta says Oct 31 on the decline). Reason: not meeting current marketing or philanthropic objectives given limited cash and barter resources. It was handled as a Sponsorship request.'
where id = '2548d873-1d76-45c4-806f-48232fd54f05'
  and notes not like '%2026-11-06 DECLINED%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '2548d873-1d76-45c4-806f-48232fd54f05','email',
 'Nov 6, 2026 email from The Delta Marketing Team (do-not-reply@cybergrants.com) to stephen@selassiefest.com, "Regarding your sponsorship proposal to Delta": declining; "does not meet our current marketing or philanthropic objectives given our limited cash and barter resources." Request ID 106198997, Message-ID <606200213.94298.1793947335214.JavaMail.ias@cg-jmail-prod>.',
 'declined','do-not-reply@cybergrants.com','Delta (CyberGrants)'
where not exists (select 1 from fs_partner_activity where partner_id='2548d873-1d76-45c4-806f-48232fd54f05' and summary like '%606200213.94298%');

update fs_grant_deadlines set
  notes = coalesce(notes,'') || E'\n2026-11-06 Deed (Bonterra) notice (nonprofits@joindeed.com, Message-ID <3fc941e5-ece7-42c3-96af-ac1d0b3bfb73@gsemail.gainsightapp.com>): starting Tue Nov 10, 2026 Deed login goes through Bonterra (auth.bonterra.network). Same email and password; start at admin.joindeed.org/login, click "Log in" (never "Sign up", it makes a new account), then Next, password. Reset link is on the Bonterra screen. Whoever holds the Deed login (Stephen) should expect the new screen; allow bonterra.network in email filters. Our Oct 20 Deed verification is unaffected.'
where id = 'ebb1afe5-1d4b-4dd4-a7b2-5bcdb6e9aa8c'
  and notes not like '%2026-11-06 Deed (Bonterra)%';

commit;
select funder,status,decision_on,left(next_step,70) from fs_grant_deadlines where id='7d0f78f9-4739-4bb0-a6ab-3086b7028d9f';
select name,stage,ball_with,last_contact_at from fs_partners where id='2548d873-1d76-45c4-806f-48232fd54f05';
select count(*) acts from fs_partner_activity where partner_id='2548d873-1d76-45c4-806f-48232fd54f05';
select (notes like '%2026-11-06 Deed (Bonterra)%') deed_noted from fs_grant_deadlines where id='ebb1afe5-1d4b-4dd4-a7b2-5bcdb6e9aa8c';

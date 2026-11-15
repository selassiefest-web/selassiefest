-- Nov 15, 2026: Springboard (Sejal Shah-Myers) invited us to apply and to book a guidelines conversation (email Nov 9). Safe to re-run.
begin;

update fs_partners set
  stage = 'in_conversation',
  ball_with = 'us',
  last_contact_at = now(),
  commitment = 'No commitment yet. Springboard Foundation Fund invited us (Nov 9, 2026) to apply for the 2026-27 Springboard grant and to book a guidelines conversation with Executive Director Sejal Shah-Myers. Range $5,000-$20,000; we plan to request $10,000.',
  next_step = 'BOOK the guidelines call with Sejal now: https://calendly.com/springboardfdn/springboard-fdn-fund-guidelines-conversation (she is out Nov 23-27 and Dec 21-Jan 4, so book for Nov 16-20 or Nov 30-Dec 18). Bring: Tuesday 4-6 pm weekday after-school class, budget $75,123 operating + $59,547 in-kind equipment, ask her which year counts toward the $100K cap and whether donated equipment counts. New-grantee application due early Feb 2027.',
  next_step_due = '2026-11-18',
  contacts = '[{"name":"Sejal Shah-Myers","title":"Executive Director, Springboard Foundation Fund","email":"sejal@springboardfoundation.org","phone":"312.748.8770"}]'::jsonb,
  address = '33 S. State Street, Ste 750, Chicago, IL 60603',
  phone = '312.748.8770',
  notes = coalesce(notes,'') || E'\n2026-11-09 EMAIL from Sejal Shah-Myers (sejal@springboardfoundation.org), 4:42 pm CT, subject "The Springboard Grant Cycle is OPEN--survey results and next steps", Message-ID <IA4PR11MB925279E58DDD2E8A83281375BF732@IA4PR11MB9252.namprd11.prod.outlook.com> (sent to herself, recipients bcc, so a standard survey-respondent invite): thanks us for the survey, invites us to apply for the 2026 Springboard Foundation Fund grant, asks us to book time on her calendar via Calendly to discuss the organization and check alignment with the guidelines (https://springboardfoundation.org/apply-grant). Out of office 11/23-11/27 and 12/21-1/4/2027. Does not answer our Nov 2 questions yet; ask them on the call.'
where id = '037b7ff5-4aab-4a89-b95d-a70e6fab66e1';

update fs_grant_deadlines set
  status = 'drafting',
  next_step = 'Springboard INVITED us to apply (Nov 9 email from Sejal Shah-Myers). BOOK the guidelines call (Calendly: https://calendly.com/springboardfdn/springboard-fdn-fund-guidelines-conversation) by Nov 18; she is out Nov 23-27 and Dec 21-Jan 4. Ask the $100K-cap year and in-kind equipment questions. New-grantee application due early Feb 2027 (date not yet posted); open the application and start drafting after the call.',
  next_step_due = '2026-11-18',
  notes = coalesce(notes,'') || E'\n2026-11-09 INVITATION RECEIVED: Sejal invites us to apply for the 2026 grant and to book a guidelines conversation (survey results email, Message-ID <IA4PR11MB925279E58DDD2E8A83281375BF732@IA4PR11MB9252.namprd11.prod.outlook.com>).'
where id = 'df858e07-5613-4d46-8f2d-4bbb63507ff1';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '037b7ff5-4aab-4a89-b95d-a70e6fab66e1','email','Nov 9, 2026 (4:42 pm CT): Sejal Shah-Myers (Springboard Foundation Fund) emailed survey respondents: invites us to apply for the 2026 grant and asks us to book a guidelines conversation on her Calendly. Out of office Nov 23-27 and Dec 21-Jan 4. Message-ID <IA4PR11MB925279E58DDD2E8A83281375BF732@IA4PR11MB9252.namprd11.prod.outlook.com>.','in_conversation','sejal@springboardfoundation.org','Sejal Shah-Myers'
where not exists (select 1 from fs_partner_activity where partner_id='037b7ff5-4aab-4a89-b95d-a70e6fab66e1' and summary like '%IA4PR11MB925279E58DDD2E8A83281375BF732%');

update fs_partners set ball_with = 'us' where id = '037b7ff5-4aab-4a89-b95d-a70e6fab66e1';
commit;
select stage, ball_with, next_step_due from fs_partners where id='037b7ff5-4aab-4a89-b95d-a70e6fab66e1';
select status, next_step_due from fs_grant_deadlines where id='df858e07-5613-4d46-8f2d-4bbb63507ff1';

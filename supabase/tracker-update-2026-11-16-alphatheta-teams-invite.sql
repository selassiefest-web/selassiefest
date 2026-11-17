-- Nov 16, 2026: Israel Rodriguez (AlphaTheta Music Americas) sent a Teams invitation for Mon Nov 23, 4:30 pm ET (3:30 pm CT). Safe to re-run.
begin;

update fs_partners set
  stage = 'in_conversation',
  ball_with = 'us',
  last_contact_at = '2026-11-16 21:23:14+00',
  commitment = 'No commitment yet. Israel Rodriguez (Education & Training Manager, AlphaTheta Music Americas) is our main contact and sent a Microsoft Teams invitation for Mon Nov 23, 2026, 4:30 pm ET / 3:30 pm CT.',
  next_step = 'ACCEPT the Teams invitation for Mon Nov 23, 4:30 pm ET (3:30 pm CT) and put it on the calendar; check it does not clash with the Nov 23 crew meeting. Prepare a one-page agenda: Start From Scratch in Chicago (DJ equipment and curriculum, "play the beat") and an introduction to the AlphaTheta Yokohama team behind Club YOXO for Rainbow Wednesday. Keep the haptics loan (Fujitsu / Kaga FEI) a separate ask.',
  next_step_due = '2026-11-23',
  notes = coalesce(notes,'') || E'\n2026-11-16 21:23 UTC: Israel Rodriguez replied "I sent you an invitation for 11/23 at 4:30pm EST." Message-ID <TY7P286MB688210491C93E10DBF50BE3CEC7C2@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM>, in reply to our Nov 15 message offering times.'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and coalesce(notes,'') not like '%TY7P286MB688210491C93E10DBF50BE3CEC7C2%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a','email',
 'Nov 16, 2026 (4:23 pm CT): Israel Rodriguez, Education & Training Manager, AlphaTheta Music Americas, replied to our Nov 15 message: "I sent you an invitation for 11/23 at 4:30pm EST." Teams meeting Mon Nov 23, 4:30 pm ET / 3:30 pm CT. Message-ID <TY7P286MB688210491C93E10DBF50BE3CEC7C2@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM>. Ball is ours: accept the invite and prepare the agenda.',
 'in_conversation','israel.rodriguez@alphatheta.com','Israel Rodriguez'
where not exists (select 1 from fs_partner_activity where partner_id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like '%TY7P286MB688210491C93E10DBF50BE3CEC7C2%');

select name, ball_with, next_step_due, left(next_step,70) n from fs_partners where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a';
commit;

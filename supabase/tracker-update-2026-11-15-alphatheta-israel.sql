-- Nov 15, 2026: Israel Rodriguez (AlphaTheta Music Americas) replied Nov 11 offering a Teams meeting. Safe to re-run.
begin;

update fs_partners set
  stage = 'in_conversation',
  ball_with = 'us',
  contacts = '[{"name":"Israel Rodriguez","title":"Education & Training Manager, AlphaTheta Music Americas, Inc.","email":"israel.rodriguez@alphatheta.com"}]'::jsonb,
  commitment = 'No commitment yet. Israel Rodriguez will be our main AlphaTheta contact for education and training and offers a Microsoft Teams meeting to discuss Start From Scratch in Chicago.',
  next_step = 'REPLY to Israel Rodriguez (israel.rodriguez@alphatheta.com) with 2 or 3 Teams meeting dates; his Nov 11 email is waiting. Thread it with his Message-ID <TY7P286MB6882A88CC725B9794BDCFE23EC712@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM>.',
  next_step_due = '2026-11-15',
  notes = coalesce(notes,'') || E'\n2026-11-11 REPLY RECEIVED (.eml processed Nov 15): Israel Rodriguez, Education & Training Manager, AlphaTheta Music Americas, answered our Nov 2 email (5:46 pm CT). Building relationships with DJ schools and education orgs; will be our main contact for education and training; offers a Teams meeting and asks for a couple of dates. Supersedes the marketing.us auto-text path; no need to call 1-844-784-0000 or chase Chris Shapiro.'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'email',
 'Nov 11, 2026 (5:46 pm CT): reply from Israel Rodriguez, Education & Training Manager, AlphaTheta Music Americas (israel.rodriguez@alphatheta.com), to our Nov 2 follow-up. He will be our main contact for education and training and offers a Microsoft Teams meeting; asks for a couple of dates. Message-ID <TY7P286MB6882A88CC725B9794BDCFE23EC712@TY7P286MB6882.JPNP286.PROD.OUTLOOK.COM>.',
 'in_conversation', 'israel.rodriguez@alphatheta.com', 'Israel Rodriguez'
where not exists (select 1 from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like '%TY7P286MB6882A88CC725B9794BDCFE23EC712%');

update fs_partners set ball_with='us' where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a';
commit;

select stage, ball_with, next_step_due, contacts->0->>'name' as contact from fs_partners where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a';
select count(*) as activity_rows from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like '%TY7P286MB6882A88CC725B9794BDCFE23EC712%';

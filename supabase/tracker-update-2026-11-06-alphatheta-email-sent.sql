-- Nov 6, 2026: third email to AlphaTheta marketing.us sent (Resend 01a1b1c3-2e2b-7a41-ab4f-f73b8d033789). Safe to re-run.
begin;

update fs_partners set
  ball_with = 'them',
  last_contact_at = now(),
  next_step = 'Email SENT Nov 6, 2026 to marketing.us@alphatheta.com (id 01a1b1c3-2e2b-7a41-ab4f-f73b8d033789): one question, who handles Start From Scratch / community partnerships in the Americas. Wait for a name. If silent by Fri Nov 13, call 1-844-784-0000 and ask for marketing.us by name, or try Chris Shapiro (Director of Sales, US & Canada; LinkedIn invite sent Oct 21). No more email to marketing.us before then.',
  next_step_due = '2026-11-13',
  notes = coalesce(notes,'') || E'\n2026-11-06 EMAIL SENT (3rd to marketing.us after Oct 22 and Nov 2), subject "Start From Scratch Chicago: who should I send our plan to?", cc stephen@selassiefest.com, Resend id 01a1b1c3-2e2b-7a41-ab4f-f73b8d033789. Recaps Oct 22, Nov 2 and the Nov 3 call (answered by the same auto-text that came Oct 22). Asks one question for a name or email; links the tracked plan page; offers a call at (872) 255-9333. Does not call Chicago the first US host. Files: Claude outputs/alphatheta/alphatheta-email.html and send-alphatheta-email.js.'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and notes not like '%01a1b1c3-2e2b-7a41-ab4f-f73b8d033789%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'email',
 'Nov 6, 2026: emailed marketing.us@alphatheta.com (cc stephen@selassiefest.com), "Start From Scratch Chicago: who should I send our plan to?". Asks who handles Start From Scratch or community education partnerships in the Americas; links the tracked plan page. Resend id 01a1b1c3-2e2b-7a41-ab4f-f73b8d033789.',
 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like '%01a1b1c3-2e2b-7a41-ab4f-f73b8d033789%');

commit;

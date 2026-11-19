-- tracker-update-2026-11-19-old-republic-online-route-wording-fix.sql
-- Reviewer fix (Nov 19, 2026) to the text applied by tracker-update-2026-11-19-old-republic-online-route.sql:
-- the research did NOT confirm that https://oldrepublic.com/contact has a web form, so say "Contact page ... if it has a form".
-- Also supersedes the earlier "Proposed: mail it" note and sources the updated-letter claim. Safe to re-run (guarded on 'Contact Us web form').
begin;

update fs_grant_deadlines
set next_step = 'ONLINE ONLY, NO MAIL (Stephen, Nov 19): no published giving email or form found for Old Republic (pages read Nov 19). Use the Contact page at https://oldrepublic.com/contact (HQ and phone were visible; no web form or email was confirmed). If it offers a form, ask who handles community giving/philanthropy for Old Republic in Chicago and attach the letter as a PDF (the updated letter, with two QR codes for the plan/budget and the pitch deck, is the file Claude outputs\grants\applications-2026-10-31\09-corporate-chicago\old-republic-letter-print.html; print it to PDF). If the form has no attachment option, paste the letter text and the two links. Stephen submits. If no route accepts it, mark the row skip. Phone follow-up stays PARKED, not before Dec 7.',
    notes = replace(replace(notes,
      'the plan is the web form at https://oldrepublic.com/contact (no giving email or named contact found).',
      'the plan is to try the Contact page at https://oldrepublic.com/contact, if it has a form (none confirmed; no giving email or named contact found). SUPERSEDES the Nov 19 mail plan above.'),
      '2026-11-19 Stephen: we are not sending snail mail; online routes only.', '2026-11-19 Stephen: we are not sending snail mail; online routes only (this replaces the "mail it Fri Nov 20" plan).')
where id = '6a15168d-fb2e-40c6-80c8-9531166570ca'
  and funder = 'Old Republic International'
  and next_step like '%Contact Us web form%';

update fs_partners
set next_step = 'Online only, no mail: try the Contact page at https://oldrepublic.com/contact (no form or giving email confirmed); if it has a form, submit the letter (PDF) and ask who handles community giving (see grant row 6a15168d). Stephen submits.'
where id = 'ea55b1a8-0d0e-4847-b6aa-309d69855b59'
  and name = 'Old Republic International'
  and next_step like '%Contact Us web form%';

update fs_partner_activity
set summary = replace(summary,
      'plan is the Contact Us web form at https://oldrepublic.com/contact (no giving email found).',
      'plan is to try the Contact page at https://oldrepublic.com/contact if it has a form (none confirmed; no giving email found).')
where partner_id = 'ea55b1a8-0d0e-4847-b6aa-309d69855b59'
  and summary like '%marker or-online-route-20261119%'
  and summary like '%Contact Us web form%';

commit;

select (select count(*) from fs_grant_deadlines where id='6a15168d-fb2e-40c6-80c8-9531166570ca' and next_step like '%Contact Us web form%') as grant_old_wording_left,
       (select count(*) from fs_partners where id='ea55b1a8-0d0e-4847-b6aa-309d69855b59' and next_step like '%Contact Us web form%') as partner_old_wording_left,
       (select count(*) from fs_partner_activity where partner_id='ea55b1a8-0d0e-4847-b6aa-309d69855b59' and summary like '%Contact Us web form%') as activity_old_wording_left;

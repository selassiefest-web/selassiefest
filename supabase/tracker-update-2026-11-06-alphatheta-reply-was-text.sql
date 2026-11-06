-- Nov 6, 2026 correction: the AlphaTheta reply was a TEXT MESSAGE, not an email. Safe to re-run.
begin;

update fs_partner_activity set
  kind = 'text',
  by_email = 'text message (number not captured)',
  by_name = 'AlphaTheta (text message)',
  summary = 'Nov 6, 2026 (approximate): TEXT MESSAGE from AlphaTheta, as pasted by Stephen: "Thank you for contacting Alpha Theta. For customers interested in contacting our Marketing Division please send your inquiry to marketing.us@alphatheta.com." Generic redirect to the address we already emailed Nov 2 (Resend id 01a19e9e-d07e-7657-b85e-8fa729c9d575). Sending number and exact time not captured.'
where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and summary like 'Nov 6, 2026 (date approximate; pasted without headers): AlphaTheta reply%';

update fs_partners set
  next_step = 'AlphaTheta texted back (Nov 6): send inquiries to marketing.us@alphatheta.com. We already emailed that address Nov 2 (Resend id 01a19e9e-d07e-7657-b85e-8fa729c9d575), so no new send is needed. Wait for the Marketing Division to answer that email. Check back Fri Nov 13; if still silent, call 1-844-784-0000 and ask for marketing.us by name.',
  notes = replace(notes,
    '2026-11-06 REPLY RECEIVED (text pasted by Stephen, no headers, so sender, date and the message it answered are NOT yet known):',
    '2026-11-06 REPLY RECEIVED BY TEXT MESSAGE (pasted by Stephen; sending number, exact time and which of our contacts it answered are not captured):')
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a';

commit;

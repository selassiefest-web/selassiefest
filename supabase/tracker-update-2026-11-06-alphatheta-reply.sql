-- Nov 6, 2026: AlphaTheta auto-style reply redirecting to marketing.us@alphatheta.com (pasted by Stephen, no headers). Safe to re-run.
begin;

update fs_partners set
  ball_with = 'them',
  last_contact_at = now(),
  next_step = 'AlphaTheta replied (pasted Nov 6): "For customers interested in contacting our Marketing Division please send your inquiry to marketing.us@alphatheta.com." We already emailed marketing.us@alphatheta.com on Nov 2 (Resend id 01a19e9e-d07e-7657-b85e-8fa729c9d575), so no new send is needed. Wait for the Marketing Division to answer that Nov 2 email. Check back Fri Nov 13; if still silent, call 1-844-784-0000 and ask for marketing.us by name. Stephen to save the original reply as .eml in Downloads/BOB so the sender, date and which message it answered can be logged.',
  next_step_due = '2026-11-13',
  notes = coalesce(notes,'') || E'\n2026-11-06 REPLY RECEIVED (text pasted by Stephen, no headers, so sender, date and the message it answered are NOT yet known): "Thank you for contacting Alpha Theta. For customers interested in contacting our Marketing Division please send your inquiry to marketing.us@alphatheta.com". Reads as a generic redirect, not a decision. Confirms marketing.us@alphatheta.com is the correct route; our Nov 2 follow-up already went there. No commitment, no decline.'
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and notes not like '%2026-11-06 REPLY RECEIVED%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'email',
 'Nov 6, 2026 (date approximate; pasted without headers): AlphaTheta reply, "Thank you for contacting Alpha Theta. For customers interested in contacting our Marketing Division please send your inquiry to marketing.us@alphatheta.com." Generic redirect to the address we already emailed Nov 2. Sender and Message-ID unknown until the .eml is saved.',
 'reached_out', 'unknown (AlphaTheta)', 'AlphaTheta'
where not exists (select 1 from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and summary like 'Nov 6, 2026 (date approximate; pasted without headers): AlphaTheta reply%');

commit;

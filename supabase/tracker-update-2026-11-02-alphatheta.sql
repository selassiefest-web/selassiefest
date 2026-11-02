-- Tracker update, Nov 2, 2026: AlphaTheta follow-up sent (Resend id 01a19e9e-d07e-7657-b85e-8fa729c9d575).
-- Apply with: supabase db query --linked -f supabase/tracker-update-2026-11-02-alphatheta.sql
update fs_partners set
  last_contact_at = now(), updated_at = now(),
  next_step = 'Follow-up email SENT Nov 2, 2026 (id 01a19e9e-d07e-7657-b85e-8fa729c9d575). Call 1-844-784-0000 Tue Nov 3, 11 am to 1 pm CT (script in Claude outputs\grants\EMAILS-TO-SEND-NOV-2-2026.txt section 3). Check proposal page views on the row. Wait for a reply; no further email unless they answer.',
  next_step_due = date '2026-11-03'
where name = 'AlphaTheta / Pioneer DJ';

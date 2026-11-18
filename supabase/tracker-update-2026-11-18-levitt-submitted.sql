-- Levitt Foundation 2027 Festival Grants: SUBMITTED. Receipt email Wed Nov 18, 2026 22:34:05 UTC (4:34 pm CT), no decision and no award.
-- Evidence: C:\Users\mkepr\Downloads\BOB\Thank_You_for_Submitting_Your_Festival_Grants_Application.eml and the submitted PDF C:\Users\mkepr\Downloads\BOB\Ras_Tafari_Inc._-_2027_Festival_Application.pdf.
-- Drafted by grants-awards-steward; adjusted (application copy already saved; submitted contents added). Safe to re-run: guarded on id + status 'drafting' + submitted_on is null + notes marker.
-- NOT done on purpose: no award wording, deadline_date stays Nov 20 (history), amount_requested stays 5000, owner stays NULL, the private view link is not stored.
begin;

update fs_grant_deadlines set
  status = 'submitted',
  submitted_on = date '2026-11-18',
  decision_on = date '2027-02-01',
  next_step = 'Nothing owed to Levitt before the announcement. Waiting: Levitt says recipients are announced Mon Feb 1, 2027, with notification then (an announcement date, not a guarantee). A copy of the submitted application is saved in the BOB folder as Ras_Tafari_Inc._-_2027_Festival_Application.pdf. Questions: festivals@levitt.org. If funded, record the award in writing before treating it as awarded.',
  next_step_due = date '2027-02-01',
  notes = coalesce(notes,'') || E'\n[2026-11-18] SUBMITTED. Levitt Family Foundation (festivals@levitt.org) confirmation "Thank You for Submitting Your Festival Grants Application", sent Wed 18 Nov 2026 22:34:05 +0000 (4:34 pm CST), Message-ID <STvdN000000000000000000000000000000000000000000000TOPYOT00ai3L7DsnTtS7A1D81kY0ag@sfdc.net>, no attachments. Receipt only: no decision, nothing awarded; requested $5,000 (unchanged). Levitt states: applications after 3:00 PM ET / 12:00 PM PT Fri Nov 20 2026 are not considered; recipients announced Mon Feb 1 2027 with notification then (decision_on holds that announcement date); the confirmation email carries a view/download link that expires in 90 days (about Feb 16 2027; link not stored here). SUBMITTED CONTENTS (from the saved PDF): festival name "Selassie Fest"; single-day festival 07/24/2027, 7:00 AM to 10:00 PM, Rainbow Beach, 3111 E. 77th St., Chicago 60649; existing festival; free admission; paid musicians "Yes, all"; attendance 400; projected expenses $35,000; projected income $20,000; operating budget under $500K; no prior Levitt grants; uploads: IRS determination letter and three images (IMG_3565.PNG, screenshot.png, Screenshot 2026-11-18 162617.png). Notes for the file: the Nov 3 plan said to replace the placeholder dates 7/24-25/2027 and enter Full Spectrum Festival at Rainbow Beach; the submitted form still shows "Selassie Fest" and 07/24/2027. The attendance answer says "48 days of planning" and the history answer says "47 days".',
  updated_at = now()
where id = '6766027b-2bf6-4aa7-a9d2-974879c8ec93'
  and status = 'drafting'
  and submitted_on is null
  and coalesce(notes,'') not like '%Thank You for Submitting Your Festival Grants Application%';

commit;

select id, funder, program, status, amount_requested, amount_awarded, deadline_date, submitted_on, decision_on, next_step_due, owner, left(next_step,90) as next_step_start, right(notes,160) as notes_tail
from fs_grant_deadlines where id = '6766027b-2bf6-4aa7-a9d2-974879c8ec93';

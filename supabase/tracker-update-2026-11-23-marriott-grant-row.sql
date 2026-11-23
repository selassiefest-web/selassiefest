-- Align Marriott grant row with the Nov 23 inquiry sent to Marriott@maritz.com. Safe to re-run.
begin;
update fs_grant_deadlines set
 next_step='Inquiry SENT Nov 23, 2026 to Marriott@maritz.com (only published address) asking which Chicago hotel has a community contact; ask is 2 donated rooms in 2027 for instructors Isaac and Jeremy. Wait for reply; if silent, check giving.marriott.com for a restored request form Dec 7. No calls (online only).',
 next_step_due='2026-12-07',
 notes = case when notes like '%2026-11-23 Marriott verified%' then notes else notes || ' | 2026-11-23 Marriott verified: giving guidelines are from 2017, state "does not consider unsolicited requests for financial support" and send room nights to individual hotels; proposal system and Wufoo form are dead; no published hotel email. Inquiry emailed to Marriott@maritz.com (Resend 01a20a08-38a7-7eaf-a12f-a94ce84882b5).' end
where id='94726569-7987-4945-97fa-47e4bf31559c';
commit;
select funder,status,next_step_due,left(next_step,60) from fs_grant_deadlines where id='94726569-7987-4945-97fa-47e4bf31559c';

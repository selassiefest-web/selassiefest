-- Nov 15, 2026: Seabury (Yaza Sarieh) replied Nov 9: our Oct 20 LOI stays in review. Safe to re-run.
begin;

update fs_grant_deadlines set
  status = 'submitted',
  next_step = 'LOI STAYS IN REVIEW (Yaza Sarieh, Nov 9: "since the change of address has been submitted to the IRS, we will still be able to review your letter of intent"). Wait for the invitation decision on or before Dec 11, 2026; forward the IRS 8822-B confirmation when it arrives (early to mid Dec). Full proposal due Feb 5, 2027 if invited; decisions May 14, 2027. One LOI per year, so no resubmitting.',
  next_step_due = '2026-12-11',
  notes = coalesce(notes,'') || E'\n2026-11-09 REPLY from Yaza Sarieh, MPH, Program Partner (yaza@seaburyfoundation.org, (312) 587-7146), cc grants@seaburyfoundation.org, 12:01 pm CT, Message-ID <DM6PR01MB409048B394883763D4A4CE1FCD732@DM6PR01MB4090.prod.exchangelabs.com>: answers our Oct 28 question. Because the address change was submitted to the IRS, the Oct 20 LOI will still be reviewed for the upcoming cycle. She did not say the LOI is approved or invited; she looks forward to learning more about programs in the coming months. Our withdraw-vs-stay and counts-as-LOI questions are moot.'
where id = 'f9b02a2f-aca4-4047-bb4f-8b2d627f691d';

update fs_partners set
  stage = 'in_conversation',
  ball_with = 'them',
  last_contact_at = now(),
  contacts = '[{"name":"Yaza Sarieh, MPH","title":"Program Partner, The Seabury Foundation","email":"yaza@seaburyfoundation.org","phone":"(312) 587-7146"}]'::jsonb,
  phone = '(312) 587-7146',
  address = '1111 N. Wells Street, Suite 302, Chicago, IL 60610',
  commitment = 'No commitment. Oct 20 LOI for the Spring 2027 Community Grant stays in review (Yaza Sarieh, Nov 9). Invitation decision by Dec 11, 2026; proposal Feb 5, 2027 if invited.',
  next_step = 'Wait for the Dec 11 invitation decision. Forward the IRS 8822-B confirmation to Yaza (yaza@seaburyfoundation.org, cc grants@seaburyfoundation.org) when it arrives, early to mid Dec. If invited, proposal due Feb 5, 2027.',
  next_step_due = '2026-12-11',
  notes = coalesce(notes,'') || E'\n2026-11-09 Yaza Sarieh replied (Message-ID <DM6PR01MB409048B394883763D4A4CE1FCD732@DM6PR01MB4090.prod.exchangelabs.com>): LOI will still be reviewed since the IRS address change was submitted.'
where id = '81f33fb4-1a9b-4d71-b1d0-114c388c7286';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '81f33fb4-1a9b-4d71-b1d0-114c388c7286','email','Nov 9, 2026 (12:01 pm CT): Yaza Sarieh (Seabury Program Partner) replied to our Oct 28 note: since the address change was submitted to the IRS, the Oct 20 LOI will still be reviewed for the upcoming cycle. No invitation yet. Message-ID <DM6PR01MB409048B394883763D4A4CE1FCD732@DM6PR01MB4090.prod.exchangelabs.com>.','in_conversation','yaza@seaburyfoundation.org','Yaza Sarieh'
where not exists (select 1 from fs_partner_activity where partner_id='81f33fb4-1a9b-4d71-b1d0-114c388c7286' and summary like '%DM6PR01MB409048B394883763D4A4CE1FCD732%');

update fs_partners set ball_with = 'them' where id = '81f33fb4-1a9b-4d71-b1d0-114c388c7286';
commit;

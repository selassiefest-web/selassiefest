-- Nov 15, 2026: ALDI Community Gift Card Program declined (email Nov 10). STANDING ORDER: a no is not final; keep trying other angles. Safe to re-run.
begin;

update fs_grant_deadlines set
  status = 'declined',
  amount_awarded = 0,
  decision_on = '2026-11-10',
  next_step = 'NOT FINAL. Persist (Stephen, Nov 15, 2026): (1) log in to YourCause GrantsConnect > View communications for app 2847516 and look for a reason; (2) ask ALDI why, and whether we can update, correct or re-submit the application; (3) try other ALDI routes: the local store manager / ALDI division (Batavia, IL) for a local donation or gift-card request, and any ALDI corporate giving or food-donation program; (4) re-apply at the next cycle; (5) ask partners (food depositories, schools) whether they have an ALDI contact. Verify every route on ALDI''s own pages before using it.',
  next_step_due = '2026-11-18',
  notes = coalesce(notes,'') || E'\n2026-11-10 DECLINED: automated email from GrantsConnect Support (noreply@yourcause.com), 7:38 am CT, subject "Your Application is Declined - ID:2847516", Message-ID <010001a1c5ae8220-a6b86276-4f50-495e-b29b-b6d42d87176a-000000@email.amazonses.com>. Text: "unable to provide support for your organization at this time." No reason given. Stephen (Nov 15): no is not the answer we settle on; keep looking for ways to update, renew or approach ALDI differently.'
where id = '97a26ab7-1c5e-49ab-bcc4-25233f8a7b3f';

commit;
select status, amount_awarded, decision_on, next_step_due from fs_grant_deadlines where id = '97a26ab7-1c5e-49ab-bcc4-25233f8a7b3f';

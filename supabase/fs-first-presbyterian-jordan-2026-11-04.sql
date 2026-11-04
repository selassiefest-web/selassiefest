begin;
update fs_partners set
  ball_with='cpd_hold',
  stage='in_conversation',
  last_contact_at='2026-11-04 19:21:26+00',
  contacts = contacts || '[{"name":"Jordan Muhammad","email":"jordangm1537@gmail.com","phone":"973-738-4638","role":"Space-sharing coordinator for the church (named by Rev. Black Oct 19)"}]'::jsonb,
  next_step='Jordan Muhammad (Nov 4) asked 3 clarifying questions: (1) rent vs free space, (2) what "review and share one DJ-learning invitation" means, (3) why winter practice. Reply drafted (Claude outputs\first-presbyterian\reply-jordan-email.html), NOT SENT: CPD hold. Send only after Stephen says send / CPD GO. Ball is ours.',
  next_step_due='2026-11-26',
  notes = notes || E'\n[11/04] Jordan Muhammad (church space-sharing coordinator, 973-738-4638, jordangm1537@gmail.com; cc stephen@) replied to the Oct 19 thread: thanks Stephen for work and patience; asks rent-or-free-donation for "fall or holiday family party" space, what "review and share one DJ-learning invitation" means, and details on winter practice; offers a phone call. Message-ID <CAGJUqjVgth8PXPJWrqeSvbipFZjD207nAzGpcuTPQ27+JSfQiA@mail.gmail.com>. Earlier: Oct 19 Stephen gave Albert 262-344-7075 + Rainbow Beach Park Supervisor as coordinators; Rev. Black cc''d Eric Nix (facility manager, artist, interested in teaching kids to DJ).'
where notes not like '%[11/04] Jordan%' and id='772038e9-2ede-4575-8f1e-8022274e1581';
insert into fs_partner_activity(partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select '772038e9-2ede-4575-8f1e-8022274e1581','email','Email IN Nov 4 2026 from Jordan Muhammad (jordangm1537@gmail.com, church space-sharing coordinator): asks rent vs free space, meaning of the DJ-learning invitation ask, and why winter practice; offers a call (973-738-4638). Reply drafted, held for CPD GO. Msg-ID <CAGJUqjVgth8PXPJWrqeSvbipFZjD207nAzGpcuTPQ27+JSfQiA@mail.gmail.com>','in_conversation','jordangm1537@gmail.com','Jordan Muhammad','2026-11-04 19:21:26+00'
where not exists (select 1 from fs_partner_activity where partner_id='772038e9-2ede-4575-8f1e-8022274e1581' and summary like '%CAGJUqjVgth8PXPJWrqeSvbipFZjD207nAzGpcuTPQ27%');
select name,ball_with,next_step_due,last_contact_at from fs_partners where id='772038e9-2ede-4575-8f1e-8022274e1581';
commit;

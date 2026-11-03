-- Outlook email audit batch D (Nov 2, 2026): Partnered folder. Nubian Marketplace was behind the mailbox:
--  Thu Oct 29, 2026 4:07 PM CT: David Pruitt (info@nubianmarketplace.com) sent his logo and said the 4 x 6 size works best for his store.
--  Fri Oct 30, 2026 12:35 AM CT: Stephen sent David the DRAFT 11 x 17 poster with his logo (review only, do not print or post); 4 x 6 counter cards to follow in the same design;
--  Stephen will print and hand-deliver after the Chicago Park District green light.
-- The tracker still said "Wait for David's logo + sizes". Quantities were not stated, so flyer.sizes is left empty.
begin;
update fs_partners set
  last_contact_at = timestamptz '2026-10-30 00:35-05',
  next_step = 'David sent his logo (Oct 29) and prefers 4 x 6 counter cards. Draft 11 x 17 poster sent Oct 30 for review. Build the 4 x 6 card in the same design and send for his OK. Print and hand-deliver only after Park District approval.',
  next_step_due = date '2026-11-06',
  ball_with = 'us',
  flyer = jsonb_set(coalesce(flyer,'{}'::jsonb), '{steps}', coalesce(flyer->'steps','{}'::jsonb) || jsonb_build_object('logo', '2026-10-29T21:07:00+00:00', 'proof', '2026-10-30T05:35:00+00:00')) || jsonb_build_object('note', 'David prefers 4 x 6 counter cards. Draft 11 x 17 poster (with his logo) sent Oct 30 for review only.'),
  updated_at = now()
where name = 'Nubian Marketplace' and next_step like 'Wait for David%';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary, p.stage, 'stephen@selassiefest.com', 'Stephen Henry', v.at::timestamptz
from fs_partners p, (values
  ('David Pruitt replied: attached Nubian Marketplace logo for the flyer; the 4 x 6 size would work best for his store; looks forward to supporting once the Park District gives the green light.', '2026-10-29 16:07-05'),
  ('Sent David the DRAFT 11 x 17 poster with his logo (review only, do not print or post); 4 x 6 counter cards will follow in the same design; Stephen will print and drop off after the Park District green light.', '2026-10-30 00:35-05')
) as v(summary, at)
where p.name = 'Nubian Marketplace' and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary = v.summary);
select p.name, p.ball_with, p.next_step_due, p.flyer->'steps' steps, (select count(*) from fs_partner_activity a where a.partner_id = p.id) acts from fs_partners p where p.name = 'Nubian Marketplace';
commit;

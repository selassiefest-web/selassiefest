-- 2026-11-18, 7:07 pm CST (2026-11-19 01:07:20 UTC): Stephen asked for a one-sentence confirmation; SENT from stephen@selassiefest.com via rti-outreach,
-- to khari.humphries@ and addison.rao@cityofchicago.org, cc stephen@. Resend id 01a1f157-fc2d-78f5-b63d-67a9236b1720. New message (invite Message-ID not saved).
-- Text: Ras Tafari Inc. has accepted and is on the calendar for Wed Nov 25, 11:00 am Central on Teams. Safe to re-run (activity deduped on the Resend id).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 18, 2026 (7:07 pm CT): Stephen sent a one-sentence confirmation to Khari Humphries and Addison Rao (Mayor''s office), cc Stephen: Ras Tafari Inc. has accepted and is on the calendar for Wed Nov 25, 11:00 am Central on Teams. New message (invite Message-ID not saved). Resend id 01a1f157-fc2d-78f5-b63d-67a9236b1720.',
 p.stage, 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 01:07:20+00'
from fs_partners p
where p.id = 'b0678615-8298-438c-9cbd-8cdf20c73110'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%01a1f157-fc2d-78f5-b63d-67a9236b1720%');

update fs_partners
set last_contact_at = '2026-11-19 01:07:20+00'
where id = 'b0678615-8298-438c-9cbd-8cdf20c73110'
  and (last_contact_at is null or last_contact_at < '2026-11-19 01:07:20+00');

commit;

select left(id::text,8) as id, stage, ball_with, next_step_due, last_contact_at from fs_partners where id = 'b0678615-8298-438c-9cbd-8cdf20c73110';

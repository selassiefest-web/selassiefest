-- 2026-11-18: Frankie Knuckles Foundation meeting-date nudge SENT (Stephen said "send"), 6:59 pm CST (2026-11-19 00:59 UTC),
-- from stephen@selassiefest.com via rti-outreach, Resend id 01a1f150-f3da-7d69-8f9b-9807dbaad63d.
-- To Frederick Dunson, cc Alan King, Carla Agostinelli, stephen@. New message (Oct 29 Message-ID not recoverable).
-- Drafted by partner-records-steward. Meeting-date nudge only; no pitch, no money ask (CPD hold honored). Safe to re-run (guarded).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 18, 2026 (6:59 pm CT): Stephen sent a NEW message (Oct 29 Message-ID not recoverable, so not threaded) to Frederick Dunson, cc Alan King and Carla Agostinelli, subject "A December Thursday morning to meet? (Rainbow DJ Lab and house music heritage)". The Nov 5, 12 and 19 offers lapsed with nothing booked (the drafted Nov 3 nudge was never sent). Offered Thu Dec 3, 10 or 17 mornings, 30 min in person or by phone. Named the Rainbow DJ Lab (free Tue 4-6 pm, 12 K-12 students, opens Jan 12, 2027) and house-music heritage in Rainbow Wednesdays (14 free nights, goal 300 a night). No pitch or money ask. Resend id 01a1f150-f3da-7d69-8f9b-9807dbaad63d.',
 'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 00:59:39+00'
from fs_partners p
where p.id = '3771b865-51c0-4042-bdda-034316d9d7e3'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%01a1f150-f3da-7d69-8f9b-9807dbaad63d%');

update fs_partners
set next_step = 'WAIT for Frederick Dunson to pick Thu Dec 3, 10 or 17 morning (30 min, in person at their place or by phone). If no reply by Mon Nov 30, one more nudge. Bring 14 Missions, a printed House Minute and the 2027 calendar. Deck: https://selassiefest.com/full-spectrum/frankie/',
    next_step_due = '2026-11-30',
    ball_with = 'them',
    last_contact_at = '2026-11-19 00:59:39+00'
where id = '3771b865-51c0-4042-bdda-034316d9d7e3'
  and coalesce(next_step,'') like 'Wait for FKF to pick a Thursday%';

commit;

select name, stage, ball_with, next_step_due, last_contact_at from fs_partners where id = '3771b865-51c0-4042-bdda-034316d9d7e3';

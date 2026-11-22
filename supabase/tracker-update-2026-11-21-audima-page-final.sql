-- Nov 21, 2026: Audima invitation page final state; ball is with us (nothing sent). Safe to re-run.
begin;
update fs_partners set ball_with = 'us',
 notes = notes || E'\nPage final Nov 21, 2026: Sway render with animated title colors (only the words move; controller still), Batch 5 VIP banner at top, tighter header spacing. Reviewed live by Stephen.'
where name like 'Audima Labs (Jeremy Buckley and Isaac Jack)%' and notes not like '%Page final Nov 21, 2026%';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note',
 'Invitation page finished Nov 21, 2026 and approved by Stephen on the live site: https://selassiefest.com/full-spectrum/audima/ (Sway render, animated title colors, Batch 5 VIP banner, spacing fix). Not sent to Audima. Ball with us.',
 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p where p.name like 'Audima Labs (Jeremy Buckley and Isaac Jack)%'
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Invitation page finished Nov 21, 2026%');
commit;
select p.stage, p.ball_with, (select count(*) from fs_partner_activity a where a.partner_id = p.id) activities from fs_partners p where p.name like 'Audima Labs%';

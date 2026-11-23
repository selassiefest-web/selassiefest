-- Nov 23, 2026. Audima visit: two sponsored Jamaican dinners. Stephen confirmed Nov 23 that the second restaurant is Tropic Island Jerk Chicken.
-- Jerky Jerk sponsors Fri Mar 26; Tropic Island Jerk Chicken sponsors Wed Mar 31. 5 people each (2 guests + 3 hosts). Safe to re-run.
begin;
insert into fs_partners (name, category, address, partner_types, stage, ball_with, next_step, next_step_due, source, notes)
select 'Jerky Jerk', 'Restaurant & food', '7300 N Western Ave, Unit L, Chicago (Rogers Park); also Tri-Taylor and Rolling Meadows', array['in_kind'], 'not_contacted', 'us',
 'Ask online (their contact form or published email) to sponsor Jamaican dinner night 1 for the Audima Labs visit, Fri Mar 26, 2027, for 5 (2 guests + 3 hosts): location or catering. Credit in the press kit and on the Audima page.',
 '2026-11-27', 'Stephen 2026-11-23',
 'Confirmed 2026 SelassieFest food vendor (credited on sponsors/index.html). Food Network Sandwich Kings feature. Dinner is in-kind; part of Audima visit plan https://selassiefest.com/full-spectrum/audima/travel-planner.html.'
where not exists (select 1 from fs_partners where name = 'Jerky Jerk');
update fs_partners set next_step = 'Ask online (published email or contact form) to sponsor Jamaican dinner night 2 for the Audima Labs visit, Wed Mar 31, 2027, for 5 (2 guests + 3 hosts): location or catering. Credit in the press kit and on the Audima page.',
 next_step_due = '2026-11-27',
 notes = coalesce(notes,'') || E'\nNov 23, 2026: Stephen confirmed Tropic Island Jerk Chicken Restaurant as the second affiliated restaurant; sponsors Jamaican dinner night 2 (Wed Mar 31, 2027). Licensed address of record 553 E 79th St (BACP account 471726).'
where name = 'Tropic Island Jerk Chicken' and coalesce(notes,'') not like '%second affiliated restaurant; sponsors Jamaican dinner night 2%';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note', 'Nov 23, 2026: assigned to sponsor a Jamaican dinner for the Audima Labs visit (' || case p.name when 'Jerky Jerk' then 'Fri Mar 26' else 'Wed Mar 31' end || ', 2027, 5 people). Ask not yet sent.', p.stage, 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p where p.name in ('Jerky Jerk','Tropic Island Jerk Chicken')
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Nov 23, 2026: assigned to sponsor a Jamaican dinner%');
commit;
select name, stage, ball_with, next_step_due from fs_partners where name in ('Jerky Jerk','Tropic Island Jerk Chicken');

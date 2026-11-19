-- 2026-11-18: Springboard guidelines call BOOKED on Sejal Shah-Myers' Calendly (Stephen).
-- Event: Fri Dec 11, 2026, 1:00-1:45 pm CT, phone call to (312) 296-9816. Calendar invite emailed 6:02 pm CT Nov 18
-- (organizer Sejal Shah-Myers; invite went to selassiefest@gmail.com under the name Albert Harris).
-- Call notes: Claude outputs\grants\springboard-call-notes-2026-11-18.md. Safe to re-run (guarded).
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note',
 'Nov 18, 2026 (about 6:00 pm CT): Stephen booked the Springboard guidelines conversation on Sejal Shah-Myers'' Calendly: Fri Dec 11, 2026, 1:00-1:45 pm CT, phone call to (312) 296-9816 (calendar invite sent 6:02 pm CT; booked name Albert Harris, selassiefest@gmail.com). Added prep note: Rainbow DJ Lab as the after-school program; asks about which year''s budget counts toward the $100,000 limit, donated equipment, timeline/form, realistic first-year request. Call notes: Claude outputs\grants\springboard-call-notes-2026-11-18.md. Sejal is out Nov 23-27.',
 'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 00:02:00+00'
from fs_partners p
where p.id::text like '037b7ff5%'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Nov 18, 2026 (about 6:00 pm CT): Stephen booked the Springboard%');

update fs_partners
set next_step = 'CALL with Sejal Shah-Myers (Springboard) Fri Dec 11, 2026, 1:00-1:45 pm CT (booked Nov 18). Bring the call notes (Claude outputs\grants\springboard-call-notes-2026-11-18.md). Ask: which year counts toward the $100K cap, donated equipment, application form/date, realistic first-year size. New-grantee application due early Feb 2027.',
    next_step_due = '2026-12-11',
    last_contact_at = greatest(coalesce(last_contact_at, '2026-11-19 00:02:00+00'), '2026-11-19 00:02:00+00')
where id::text like '037b7ff5%'
  and coalesce(next_step,'') not like 'CALL with Sejal Shah-Myers (Springboard) Fri Dec 11%';

update fs_grant_deadlines
set next_step = 'Springboard guidelines call Fri Dec 11, 2026, 1:00-1:45 pm CT (booked Nov 18). Then draft the application (target submit by Jan 25, 2027; new-grantee due early Feb 2027). Ask $10,000 = instructor pay, 20 Tuesdays x 2 x $250; pitch only the Tuesday DJ Lab.',
    next_step_due = '2026-12-11',
    notes = coalesce(notes,'') || E'\n[2026-11-18] Guidelines call booked: Fri Dec 11 2026 1:00-1:45 pm CT with Sejal Shah-Myers. Prep: Claude outputs\\grants\\springboard-call-notes-2026-11-18.md.'
where id = 'df858e07-5613-4d46-8f2d-4bbb63507ff1'
  and coalesce(notes,'') not like '%Guidelines call booked: Fri Dec 11 2026%';

commit;

select 'partner' as t, name, next_step_due::text, stage from fs_partners where id::text like '037b7ff5%'
union all
select 'grant', funder, next_step_due::text, status from fs_grant_deadlines where id = 'df858e07-5613-4d46-8f2d-4bbb63507ff1';

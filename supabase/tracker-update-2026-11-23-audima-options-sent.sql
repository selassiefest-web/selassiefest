-- Logs Stephen's Nov 23, 2026 send to Isaac Jack (Audima Labs): travel options, tentative itinerary, press kit.
-- Source: C:\Users\mkepr\Downloads\BOB\Audima_visit_to_Chicago__travel_options,_tentative_itinerary_and_press_kit.eml
-- Date: Tue 24 Nov 2026 00:45:42 +0000 = Mon Nov 23, 2026 6:45 pm CST. No third-party email addresses in this public file.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Nov 23, 2026 6:45 pm CST: Stephen SENT Isaac Jack (Audima Labs) the three draft pages: travel options A, B and C (cost sharing, no preferred option) https://selassiefest.com/full-spectrum/audima/travel-options.html; tentative itinerary Mar 25 to Apr 1, 2027 https://selassiefest.com/full-spectrum/audima/itinerary.html; draft press kit https://selassiefest.com/full-spectrum/audima/press-kit.html (nothing sent to any outlet). Asked: which option suits Isaac and Jeremy, does the itinerary look right, and which controller from the DJ Lab builder works best with Sway. Message-ID <CO6P220MB0338212BB0DD145221028EF6D7452@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. (ref AUDIMA evt 2026-11-23 18:45)',
 'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-23 18:45:42-06'
from fs_partners p
where p.id = 'b8d73772-58e8-43bd-9aec-749502f8d76d'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref AUDIMA evt 2026-11-23 18:45)%');

update fs_partners
set ball_with = 'them',
    next_step = 'WAIT for Isaac Jack and Jeremy Buckley: their pick of travel option A, B or C, whether the Mar 25 to Apr 1, 2027 itinerary looks right, and which controller works best with Sway (sent Nov 23, 2026). Mar 30, 2027 (Mission 9) still awaits Chicago Park District confirmation. Nudge Fri Dec 4, 2026 if silent.',
    next_step_due = '2026-12-04',
    notes = coalesce(notes,'') || E'\n2026-11-23: Sent travel options, tentative itinerary and press kit (Message-ID CO6P220MB0338212BB0DD145221028EF6D7452@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM). Ball with Audima. [src:audima-options-sent]',
    last_contact_at = greatest(last_contact_at, '2026-11-23 18:45:42-06'::timestamptz)
where id = 'b8d73772-58e8-43bd-9aec-749502f8d76d'
  and coalesce(notes,'') not like '%[src:audima-options-sent]%';

commit;

select p.ball_with, p.next_step_due, p.last_contact_at, (p.notes like '%[src:audima-options-sent]%') as noted,
 (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%AUDIMA evt 2026-11-23 18:45%') as events
from fs_partners p where p.id = 'b8d73772-58e8-43bd-9aec-749502f8d76d';

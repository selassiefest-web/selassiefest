-- Stephen, Nov 20, 2026: "hold purple turtle until we have a go from CPD". Check-in to Tonia Evans NOT sent; row goes to cpd_hold. Safe to re-run.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'note','Nov 20, 2026: Stephen put Purple Turtle (Tamera Fair / Tonia Evans) on HOLD until CPD gives a GO. The approved check-in draft to Tonia is NOT sent and will not be sent until CPD GO. (ref PT-hold 2026-11-20)',
 p.stage,'stephen@selassiefest.com','Stephen Henry', now()
from fs_partners p where p.id='edbc5d31-127a-4bc6-9182-f1b5fb4ef005'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%PT-hold 2026-11-20%');
update fs_partners set ball_with='cpd_hold', next_step_due=null,
 next_step='HOLD until CPD gives a GO (Stephen, Nov 20, 2026). Then send the check-in to Tonia Evans (toniaevans2002@icloud.com) after Stephen says "send": draft at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\purple-turtle\checkin-tonia-2026-11-20.txt. No park role or date; anything in the park only if the Park District approves.'
where id='edbc5d31-127a-4bc6-9182-f1b5fb4ef005';
commit;
select stage,ball_with,next_step_due from fs_partners where id='edbc5d31-127a-4bc6-9182-f1b5fb4ef005';

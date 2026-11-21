-- Nov 21, 2026 (Stephen's decisions): (1) Ivry Ector row stage -> in_conversation, ball stays cpd_hold;
-- (2) correct three Serato activity rows whose created_at was the processing time, not the email/event time (CST = UTC-6).
-- Keyed by id with expected-current-value guards; safe to re-run (second run updates 0 rows).
begin;

update fs_partners set stage='in_conversation', ball_with='cpd_hold', updated_at=now()
where id='381db08e-a28a-4466-b74b-261cd248a4a1' and stage='reached_out';

-- the fs_partners_ball_auto trigger resets ball_with when stage changes (even if the same statement sets it), so restore the hold in a separate statement
update fs_partners set ball_with='cpd_hold', updated_at=now()
where id='381db08e-a28a-4466-b74b-261cd248a4a1' and stage='in_conversation' and ball_with<>'cpd_hold';

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name)
select p.id,'note','Nov 21, 2026: stage moved reached_out -> in_conversation (Ivry replied Nov 19 and Nov 20). Ball stays cpd_hold: no nudges or new asks until CPD gives a GO. (ref ivry-stage-2026-11-21)','in_conversation','stephen@selassiefest.com','Stephen Henry'
from fs_partners p where p.id='381db08e-a28a-4466-b74b-261cd248a4a1'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%ivry-stage-2026-11-21%');

-- Serato: "Nov 16 9:04 pm CT" = Nov 17 03:04 UTC
update fs_partner_activity set created_at='2026-11-17 03:04:00+00'
where id='4a21292e-ca13-4c68-98a7-e0be14489118' and created_at='2026-11-18 04:14:53.451831+00';
-- Serato: "Nov 17 7:36 pm CT" = Nov 18 01:36:43 UTC (from the .eml filename)
update fs_partner_activity set created_at='2026-11-18 01:36:43+00'
where id='8c4ffe40-481a-4449-93d9-17caa8c50202' and created_at='2026-11-18 07:41:05.619319+00';
-- Serato: "Nov 18 1:37 am CT" = Nov 18 07:37 UTC
update fs_partner_activity set created_at='2026-11-18 07:37:00+00'
where id='0481248b-e320-405b-a090-b827e515e05f' and created_at='2026-11-18 07:41:05.619319+00';

commit;

select 'ivry' k, stage||' | '||ball_with||' | '||coalesce(next_step_due::text,'null')||' | '||left(next_step,30) v from fs_partners where id='381db08e-a28a-4466-b74b-261cd248a4a1'
union all select 'serato_order', string_agg(to_char(created_at at time zone 'UTC','MM-DD HH24:MI')||' '||left(summary,22), ' || ' order by created_at)
 from fs_partner_activity where partner_id='85a2975b-ae91-4f6f-b7d7-7dd14181c167';

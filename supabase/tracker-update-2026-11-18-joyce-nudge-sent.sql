-- Joyce nudge A SENT Nov 18 2026 8:08 pm CST (Nov 19 02:08 UTC) by Stephen from Outlook, reply in Oct 29 thread.
-- Message-ID <CO6P220MB03382FFE7E7D5E4CA3C02F21D7792@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>
-- Safe to re-run: guarded by the Message-ID text.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '670cf826-1b34-49ac-b1f9-a0b582debb18','email',
 'Nudge A SENT Nov 18, 2026 8:08 pm CST by Stephen (Outlook reply in the Oct 29 thread) to applications@joycefdn.org (To only; the Culture Program Assistant was NOT on the To/Cc line this time, only Bridget). Asked whether Joyce would consider an LOI for the $16,800 sound/technical contractor line (14 x $1,200) of Rainbow Wednesdays and whether the Dec 1 cycle is open for a new LOI or we should aim for the next one; linked https://selassiefest.com/full-spectrum/joyce/?k=x5my7cn7. Message-ID <CO6P220MB03382FFE7E7D5E4CA3C02F21D7792@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-19 02:08:03+00'
where not exists (select 1 from fs_partner_activity where partner_id='670cf826-1b34-49ac-b1f9-a0b582debb18' and summary like '%CO6P220MB03382FFE7E7D5E4CA3C02F21D7792%');

update fs_partners set ball_with='them', last_contact_at='2026-11-19 02:08:03+00',
 next_step='Nudge A sent Nov 18. Wait for Joyce (Bridget / Culture) to say which cycle. If silent, follow up Mon Dec 1 (call 312-782-2464 or reply in the thread, adding the Culture Program Assistant). Next proposal deadline Apr 1, 2027 (LOI about early-mid Feb 2027).',
 next_step_due='2026-12-01'
where id='670cf826-1b34-49ac-b1f9-a0b582debb18' and ball_with='us';

update fs_grant_deadlines set
 next_step='Nudge A sent Nov 18, 2026 (Message-ID CO6P220MB03382FFE7E7D5E4CA3C02F21D7792). Waiting for Joyce to say which cycle (Dec 1 proposal deadline vs Apr 1, 2027, LOI early-mid Feb). If silent, follow up Dec 1. Public letter already rebuilt at $16,800.',
 next_step_due='2026-12-01',
 notes = notes || E'\n[2026-11-18] Nudge A SENT 8:08 pm CST by Stephen (Outlook, Oct 29 thread, to applications@ only). Public letter full-spectrum/joyce already rebuilt at $16,800 (commit f09cc40); earlier note saying it still shows $50,000 is stale.'
where id='dc25d586-f390-4553-964a-01fd8090c8e1' and notes not like '%Nudge A SENT 8:08 pm CST%';
commit;
select (select count(*) from fs_partner_activity where summary like '%CO6P220MB03382FFE7E7D5E4CA3C02F21D7792%') acts,
 (select ball_with||' '||next_step_due from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18') partner,
 (select next_step_due from fs_grant_deadlines where id='dc25d586-f390-4553-964a-01fd8090c8e1') grant_due;

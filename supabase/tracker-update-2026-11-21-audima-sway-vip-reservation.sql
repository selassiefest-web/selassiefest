-- Nov 21, 2026: Audima Sway Batch 5 VIP reservation confirmation (.eml). Safe to re-run.
begin;
update fs_partners set email = 'contactus@Audima.com.au',
 stage = 'reached_out', ball_with = 'us', last_contact_at = '2026-11-21 19:36-06',
 next_step = 'Stephen decides when to send the invitation page https://selassiefest.com/full-spectrum/audima/ to Jeremy and Isaac (reply to contactus@Audima.com.au or the Sway reservation email). Audima asked for a one-word reply on what music Sway will make; not sent. Batch 5 launch is in March 2027 (VIP link by email and SMS). CPD hold still applies to partner sends.',
 notes = notes || E'\nSway reservation: Albert (account of Ras Tafari Inc.) reserved a Sway for $25 and is a Batch 5 VIP ($615 instead of $830, free carry case and preset banks, unit held 30 days from launch). Audima confirmation from Audima Labs <contactus@Audima.com.au>, sent Sun Nov 22, 2026 01:36 UTC, Message-ID <4gT5dLx4TWCsodsYAR2clQ@geopod-ismtpd-43>. The invitation page now says Ras Tafari Inc. is a Batch 5 VIP.'
where name like 'Audima Labs (Jeremy Buckley and Isaac Jack)%' and notes not like '%4gT5dLx4TWCsodsYAR2clQ%';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
 'Email from Audima Labs <contactus@Audima.com.au> to stephen@selassiefest.com, Sun Nov 22, 2026 01:36 UTC (Nov 21, 7:36 pm CT), subject "ALBERT, your Sway reservation is confirmed", Message-ID <4gT5dLx4TWCsodsYAR2clQ@geopod-ismtpd-43>: $25 reservation confirmed, Batch 5 VIP ($615 vs $830, free carry case and preset banks, unit held 30 days from launch); Batch 5 launch in March 2027, VIP link by email and SMS; signed Jeremy and Isaac, Co-Founders. Asked for a one-word reply on what music we will make (not sent). No amount owed now.',
 'reached_out', 'contactus@audima.com.au', 'Audima Labs', '2026-11-21 19:36-06'
from fs_partners p where p.name like 'Audima Labs (Jeremy Buckley and Isaac Jack)%'
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%4gT5dLx4TWCsodsYAR2clQ%');
commit;
select p.stage, p.ball_with, p.email, (select count(*) from fs_partner_activity a where a.partner_id = p.id) activities from fs_partners p where p.name like 'Audima Labs%';

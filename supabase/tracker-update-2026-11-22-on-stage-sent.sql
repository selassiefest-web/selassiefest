-- Nov 22, 2026: On-Stage email SENT to Alman Nusrat (Marketing Manager). Safe to re-run (marker-guarded).
begin;
update fs_grant_deadlines set
 status='submitted', submitted_on='2026-11-22', next_step_due='2026-12-07',
 next_step='EMAIL SENT Nov 22, 2026 (Resend 01a20211-86a2-7806-8311-9f6698ed59f3) to Alman Nusrat (Marketing Manager), cc Stephen: whatever On-Stage can give, welcoming their best: 13 laptop stands, DJ tables or stands, accessories, open-box welcome; offer to work with their team on recognition; deck link. Fallback contact per the tracker is Jeremy Payne. If silent, one short follow-up about Mon Dec 7 (internal date). Online only.',
 notes = notes || E'\n2026-11-22 [onstage-sent-20261122] Email sent from stephen@selassiefest.com via rti-outreach (Resend 01a20211-86a2-7806-8311-9f6698ed59f3), subject "Gear for a free youth DJ class in Chicago (Ras Tafari Inc.)". Wide ask (no dollar figures). Same stands line also went to Gator; overlap is fine. No reply yet. Nothing awarded or received.'
where id='a4287c9e-7de0-4540-83df-cfa63c3850bc' and notes not like '%onstage-sent-20261122%';

update fs_partners set stage='reached_out', ball_with='them', next_step_due='2026-12-07', last_contact_at='2026-11-22 12:00-06',
 next_step='Waiting on On-Stage (email sent Nov 22, 2026 to Alman Nusrat; grant row a4287c9e). If silent, one short follow-up about Mon Dec 7; fallback contact Jeremy Payne. Online only.',
 notes = coalesce(notes,'') || E'\n[onstage-sent-20261122] Email sent Nov 22, 2026 (Resend 01a20211-86a2-7806-8311-9f6698ed59f3).'
where id='414dde79-6b11-4c98-ae44-dcdc579bcb64' and stage='not_contacted' and coalesce(notes,'') not like '%onstage-sent-20261122%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'email','Emailed Alman Nusrat (Marketing Manager, On-Stage / The Music People) from stephen@selassiefest.com, cc Stephen, Nov 22, 2026 (Resend id 01a20211-86a2-7806-8311-9f6698ed59f3), subject "Gear for a free youth DJ class in Chicago (Ras Tafari Inc.)": free year-round Tuesday DJ class opening Jan 12, 2027 with 12 student stations; asked for whatever On-Stage can give and welcomed their best (13 laptop stands, DJ tables or stands, accessories, open-box welcome); offered to work with their team on recognition; deck link. No reply yet. Ball with them. (marker onstage-sent-20261122)','reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-22 12:00-06'
from fs_partners p where p.id='414dde79-6b11-4c98-ae44-dcdc579bcb64'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%onstage-sent-20261122%');
commit;
select (select status||' '||submitted_on::text||' '||next_step_due::text from fs_grant_deadlines where id='a4287c9e-7de0-4540-83df-cfa63c3850bc') g,
 (select stage||'/'||ball_with from fs_partners where id='414dde79-6b11-4c98-ae44-dcdc579bcb64') p,
 (select count(*) from fs_partner_activity where summary like '%onstage-sent-20261122%') acts;

-- tracker-update-2026-11-23-gator-reply-taproot-approved.sql
-- Sources: Gator Zendesk reply Nov 23 15:44:04 UTC (9:44 am CST) Message-ID
--   <M996GPPMJ4K_6b045f44a4848_befa2ce2c598cc_sprut@zendesk.com>;
--   Taproot Plus approval Nov 23 08:57:44 UTC (2:57 am CST) Message-ID <uLbwgQI8TJaF9sX9GKhq_g@geopod-ismtpd-2>.
-- Re-runnable: activity guarded by ref markers, updates guarded by expected-current values and src markers.
begin;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', v.summary || ' (ref ' || v.marker || ')', v.stage_after, v.by_email, v.by_name, v.at::timestamptz
from fs_partners p
join (values
 ('d8211717-4fab-4c5d-86ab-ff62b95010e2'::uuid, 'GATOR533641 evt 2026-11-23 09:44', '2026-11-23 09:44:04-06', 'reached_out', 'info@gatorcases.com', 'Gator Cases Support',
  'Nov 23, 2026 (9:44 am CST; 15:44 UTC), ticket 533641: Gator Cases Support replied to Stephen''s Nov 22 contact-form request for 13 laptop stands (about $455) and the community-donations contact. He said he forwarded the correspondence to Gator''s relations and marketing teams and they will reach back out only if they want to move forward. ACKNOWLEDGMENT ONLY: no donation approved, no contact person or email named, no value. Message-ID <M996GPPMJ4K_6b045f44a4848_befa2ce2c598cc_sprut@zendesk.com>.'),
 ('09162a36-1045-4edb-9f70-ba7c9086845b'::uuid, 'TAPROOT-PLUS evt 2026-11-23 02:57', '2026-11-23 02:57:44-06', 'reached_out', 'help@taprootplus.org', 'Taproot Plus (automated)',
  'Nov 23, 2026 (2:57 am CST; 08:57 UTC): Taproot Plus emailed stephen@ "You''re in! Welcome to Taproot Plus": Ras Tafari Inc. approved to participate (free pro bono platform; not a grant, no value). Next: submit the first request (a multi-week Project or a one-hour Session) from the dashboard. Message-ID <uLbwgQI8TJaF9sX9GKhq_g@geopod-ismtpd-2>. Companion welcome emails: <qBSl8v_9Qwun9QJNyuZDhg@geopod-ismtpd-15> (08:26 UTC) and <gpTfsf6PT5KkPcAPP9fMiA@geopod-ismtpd-111> (09:58 UTC, newsletter list).')
) as v(pid, marker, at, stage_after, by_email, by_name, summary) on v.pid = p.id
where not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref ' || v.marker || ')%');

update fs_partners
set last_contact_at = '2026-11-23 15:44:04+00',
    next_step = 'Waiting on Gator relations and marketing (Gator Support, ticket 533641, said Nov 23 it forwarded our request to those teams; they reach out only if they want to move forward; no contact, gear or value named). Ball with Gator. No new send. If silent, one short email follow-up Mon Dec 7, 2026 (our own date, not a Gator commitment). Online only.',
    notes = coalesce(notes,'') || E'\n[2026-11-23] Gator Support acknowledged ticket 533641 (forwarded to relations and marketing); no commitment. [src:gator-533641-reply-20261123]'
where id = 'd8211717-4fab-4c5d-86ab-ff62b95010e2'
  and stage = 'reached_out' and ball_with = 'them' and next_step_due = '2026-12-07'
  and last_contact_at = '2026-11-22 18:00:00+00'
  and coalesce(notes,'') not like '%src:gator-533641-reply-20261123%';

update fs_grant_deadlines
set notes = coalesce(notes,'') || E'\n[2026-11-23] Gator Support replied on ticket 533641: forwarded to relations and marketing, they contact us only if moving forward. No approval, contact or value. Status stays submitted; Dec 7 follow-up unchanged. [src:gator-533641-reply-20261123]'
where id = 'de947322-dbc9-4af0-80b9-713f47fb844a' and status = 'submitted'
  and coalesce(notes,'') not like '%src:gator-533641-reply-20261123%';

update fs_partners
set stage = 'reached_out', ball_with = 'us',
    last_contact_at = '2026-11-23 08:57:44+00',
    next_step = 'Taproot Plus account APPROVED Nov 23, 2026. Submit our first request (Project or one-hour Session) for a scoped budget-and-sponsorship review from the Taproot Plus dashboard, by Tue Nov 24, 2026 (our own date; owner proposed: Stephen Henry). No cost, no value stated. Online only.',
    next_step_due = '2026-11-24',
    notes = coalesce(notes,'') || E'\n[2026-11-23] Taproot Plus approval email received (free platform, not a grant). Next due 2026-11-24 is our own date. [src:taproot-plus-approved-20261123]'
where id = '09162a36-1045-4edb-9f70-ba7c9086845b'
  and stage = 'not_contacted' and next_step_due = '2026-12-09' and last_contact_at is null
  and coalesce(notes,'') not like '%src:taproot-plus-approved-20261123%';

update fs_grant_deadlines
set next_step = 'Taproot Plus account approved Nov 23, 2026. Submit first request (Project or Session) for a focused budget-and-sponsorship review.',
    next_step_due = '2026-11-24',
    notes = coalesce(notes,'') || E'\n[2026-11-23] Taproot Plus approval email received. Pro bono services, not cash; no value stated. [src:taproot-plus-approved-20261123]'
where id = '8af59eda-9283-44b1-b1e3-a3c6cc0516c1' and status = 'to_research'
  and coalesce(notes,'') not like '%src:taproot-plus-approved-20261123%';

commit;

select p.name, p.stage, p.ball_with, p.last_contact_at, p.next_step_due,
       (select count(*) from fs_partner_activity a where a.partner_id = p.id and (a.summary like '%GATOR533641 evt%' or a.summary like '%TAPROOT-PLUS evt%')) as new_activity
from fs_partners p where p.id in ('d8211717-4fab-4c5d-86ab-ff62b95010e2','09162a36-1045-4edb-9f70-ba7c9086845b');

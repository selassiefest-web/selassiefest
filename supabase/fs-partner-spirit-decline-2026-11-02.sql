-- SPIRIT PRO AUDIO: Cindy Li answered our Nov 1 WhatsApp "No, sorry" (Nov 1, 7:07 PM CT, per Stephen's WhatsApp screenshot Nov 2).
-- Stephen replied "Much appreciated" Nov 2, 5:50 AM CT. Safe to re-run. Kept local (vendor phone numbers).
begin;
update fs_partners set stage = 'declined', ball_with = 'parked',
  next_step = 'DECLINED by Cindy Li (WhatsApp, Nov 1 7:07 PM CT: "No, sorry"). Do not chase. Still unanswered: Eric Yuan (WhatsApp) and the Nov 1 emails to sales@ and info@spirit-proaudio.com. Reopen only if one of them says yes.',
  next_step_due = null, updated_at = now()
where name like 'Guangzhou Power and Grace%';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'text', 'Cindy Li (SPIRIT PRO AUDIO, +86 135 7049 1713) replied on WhatsApp Nov 1, 7:07 PM CT: "No, sorry". Declines the donation/sponsorship ask. No reply yet from Eric Yuan or from the two emails.', 'declined', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-01 19:07:00-06'
from fs_partners p where p.name like 'Guangzhou Power and Grace%' and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like 'Cindy Li (SPIRIT PRO AUDIO%');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'text', 'Stephen answered Cindy Li on WhatsApp: "Much appreciated" (Nov 2, 5:50 AM CT).', 'declined', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-02 05:50:00-06'
from fs_partners p where p.name like 'Guangzhou Power and Grace%' and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like 'Stephen answered Cindy Li%');
commit;
select name, stage, ball_with, next_step_due, (select count(*) from fs_partner_activity a where a.partner_id=p.id) acts from fs_partners p where name like 'Guangzhou Power and Grace%';

-- Eric Yuan check (Stephen's WhatsApp screenshot, Nov 2): our 1:58 AM message shows two grey ticks (delivered, not read), no reply.
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select p.id, 'note', 'Nov 2 WhatsApp check: Eric Yuan (+86 137 1048 1589) has not replied; our Nov 1 1:58 AM message shows delivered, not read. Only Cindy Li has answered (declined).', p.stage, 'stephen@selassiefest.com', 'Stephen Henry'
from fs_partners p where p.name like 'Guangzhou Power and Grace%' and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like 'Nov 2 WhatsApp check: Eric Yuan%');

-- Fill the structured contact fields for SPIRIT (they were empty). Eric Yuan's title and the office line came from a pasted
-- answer (source not verified by us); the emails and the US office number were verified on spirit-proaudio.com Nov 1.
update fs_partners set
  email = 'sales@spirit-proaudio.com',
  phone = '+1 209 542 2998',
  website = coalesce(website, 'www.spirit-proaudio.com'),
  contacts = '[{"name":"Cindy Li","role":"SPIRIT PRO AUDIO (declined by WhatsApp Nov 1)","phone":"+86 135 7049 1713"},{"name":"Eric Yuan","role":"International Sales Manager (title UNVERIFIED, from a pasted answer Nov 2); no reply yet","phone":"+86 137 1048 1589"},{"name":"SPIRIT US office (Foster City, CA)","email":"sales@spirit-proaudio.com","phone":"+1 209 542 2998"},{"name":"SPIRIT China office","email":"info@spirit-proaudio.com","phone":"+86 20 31000189 (UNVERIFIED)"}]'::jsonb,
  updated_at = now()
where name like 'Guangzhou Power and Grace%';

-- Verified on https://spirit-proaudio.com/ Nov 2 (page fetched): info@ and sales@spirit-proaudio.com, US +1 209 542 2998,
-- China +86-20-31561562. The pasted +86 20 31000189 is NOT on the site; replaced by the verified number.
update fs_partners set contacts = (select jsonb_agg(case when c->>'name' = 'SPIRIT China office'
    then jsonb_build_object('name','SPIRIT China office','email','info@spirit-proaudio.com','phone','+86-20-31561562','role','verified on spirit-proaudio.com Nov 2')
    else c end) from jsonb_array_elements(contacts) c), updated_at = now()
where name like 'Guangzhou Power and Grace%';

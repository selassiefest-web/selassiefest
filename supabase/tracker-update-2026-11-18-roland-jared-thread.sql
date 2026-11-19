-- 2026-11-18: Roland / Jared Selter: log the Oct 23 reply and Oct 24 deck reply (from the two .eml files in BOB), store Jared as a contact,
-- and log tonight's one-line threaded nudge (Resend 01a1f207-19d1-7c08-a267-25a27d0fd419). Guarded by Message-IDs / Resend id; safe to re-run.
begin;
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select 'f34194d7-0ce8-4a67-81e8-722eda18b9cf','email',
 'Reply from Jared Selter (Director of Education, Roland Global, Jared.Selter@roland.com) Oct 23 2026 22:10 UTC: asked Stephen to send a deck of the program. Message-ID <GVXPR04MB1158812CDF084757DC1F27031E0642@GVXPR04MB11588.eurprd04.prod.outlook.com>',
 'in_conversation','Jared.Selter@roland.com','Jared Selter','2026-10-23 22:10:56+00'
where not exists (select 1 from fs_partner_activity where summary like '%GVXPR04MB1158812CDF084757DC1F27031E0642%');
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select 'f34194d7-0ce8-4a67-81e8-722eda18b9cf','email',
 'Stephen replied to Jared Selter Oct 24 2026 11:03 UTC with the deck https://selassiefest.com/full-spectrum/roland/ (In-Reply-To his Oct 23 message). Message-ID <SJ0P220MB05900B24290B6E709CA3DFAFD7632@SJ0P220MB0590.NAMP220.PROD.OUTLOOK.COM>.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry','2026-10-24 11:03:19+00'
where not exists (select 1 from fs_partner_activity where summary like '%SJ0P220MB05900B24290B6E709CA3DFAFD7632%');
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select 'f34194d7-0ce8-4a67-81e8-722eda18b9cf','email',
 'Nudge SENT Nov 18, 2026 (Resend 01a1f207-19d1-7c08-a267-25a27d0fd419) to Jared.Selter@roland.com, cc stephen@, threaded on the Oct 23/24 emails (In-Reply-To Stephen''s Oct 24 reply): one sentence asking whether Roland would consider supporting the Rainbow DJ Lab and who to send a request to; links the deck https://selassiefest.com/full-spectrum/roland/.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry', now()
where not exists (select 1 from fs_partner_activity where summary like '%01a1f207-19d1-7c08-a267-25a27d0fd419%');
update fs_partners set stage='in_conversation', ball_with='them', last_contact_at=now(),
 contacts='[{"name":"Jared Selter","role":"Director of Education, Roland Global","email":"Jared.Selter@roland.com"}]'::jsonb,
 next_step='Nudge SENT Nov 18 to Jared Selter (Jared.Selter@roland.com), threaded on the Oct 24 deck reply. Wait for Jared; if silent, one more email nudge Wed Dec 2 (internal). No call (phone parked). Record which equipment path A-D Roland picks.',
 next_step_due='2026-12-02',
 notes=coalesce(notes,'')||E'\n2026-11-18: Jared Selter (Director of Education, Roland Global) replied Oct 23 asking for a deck; Stephen sent it Oct 24 11:03 UTC; no reply from Jared since; one-line nudge sent Nov 18 (Resend 01a1f207-19d1-7c08-a267-25a27d0fd419). The Nov 4 hold ended; ignore earlier bounce-watch and hold lines. Oct 28 follow-up went to the generic rolandmusiced@ address after Jared had replied: use Jared''s address from now on.'
where id='f34194d7-0ce8-4a67-81e8-722eda18b9cf' and coalesce(notes,'') not like '%one-line nudge sent Nov 18%';
update fs_grant_deadlines set next_step='Nudge SENT Nov 18, 2026 (Resend 01a1f207-19d1-7c08-a267-25a27d0fd419) to Jared Selter, threaded on the Oct 24 deck reply. Wait for Jared; if silent, one more email nudge Dec 2 (internal). No call (phone parked).',
 next_step_due='2026-12-02',
 notes=coalesce(notes,'')||E'\n[2026-11-18] Jared Selter wrote Oct 23 (Message-ID GVXPR04MB1158812CDF084757DC1F27031E0642@GVXPR04MB11588.eurprd04.prod.outlook.com) asking for a deck; Stephen sent it Oct 24 11:03 UTC (Message-ID SJ0P220MB05900B24290B6E709CA3DFAFD7632@SJ0P220MB0590.NAMP220.PROD.OUTLOOK.COM); no reply since; one-line nudge sent Nov 18 (Resend 01a1f207-19d1-7c08-a267-25a27d0fd419).'
where id='e797da22-4502-4169-ae2c-1bc1ba732244' and coalesce(notes,'') not like '%01a1f207-19d1-7c08%';
commit;
select (select count(*) from fs_partner_activity where partner_id='f34194d7-0ce8-4a67-81e8-722eda18b9cf') acts,
 (select stage||' '||next_step_due from fs_partners where id='f34194d7-0ce8-4a67-81e8-722eda18b9cf') p,
 (select next_step_due from fs_grant_deadlines where id='e797da22-4502-4169-ae2c-1bc1ba732244') g;

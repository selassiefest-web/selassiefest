-- Marriott inquiry sent Nov 23, 2026 to Marriott@maritz.com (only published address). Safe to re-run.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '7e7b3f6e-fb74-449f-97dd-d111815fedc0','email',
'Inquiry SENT Nov 23, 2026 (Resend 01a20a08-38a7-7eaf-a12f-a94ce84882b5) to Marriott@maritz.com, cc stephen@: Marriott has no published sponsorship form (2017 giving guidelines; proposal system and Wufoo form dead; no unsolicited financial requests; room nights decided hotel by hotel). Asked which Chicago hotel (e.g. Marriott Marquis, 2121 S. Prairie) has a community/donations contact; ask is 2 donated rooms in 2027, one each for out-of-town instructors Isaac and Jeremy, tied to Empower (youth, women). No cash ask. Maritz is the Bonvoy points desk, so may only auto-reply.',
'reached_out','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where summary like '%01a20a08-38a7-7eaf-a12f-a94ce84882b5%');
update fs_partners set stage='reached_out', ball_with='them', last_contact_at='2026-11-23', email='Marriott@maritz.com',
commitment=null,
next_step='Inquiry SENT Nov 23, 2026 to Marriott@maritz.com asking for a Chicago hotel community contact (ask: 2 donated rooms in 2027 for instructors Isaac and Jeremy). Wait for a reply; if silent, check giving.marriott.com for a restored request form on Dec 7. No calls (online only).',
next_step_due='2026-12-07'
where id='7e7b3f6e-fb74-449f-97dd-d111815fedc0';
commit;
select name,stage,ball_with,next_step_due,last_contact_at from fs_partners where id='7e7b3f6e-fb74-449f-97dd-d111815fedc0';

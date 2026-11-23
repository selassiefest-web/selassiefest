-- Hilton Travel with Purpose inquiry sent Nov 23, 2026. Safe to re-run.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'adf13817-6b5b-45c6-a950-cc871d0051b0','email',
'Inquiry SENT Nov 23, 2026 (Resend 01a20a0c-1308-7ab2-bded-791648730eb3) to TWP@hilton.com (Travel with Purpose team, the only published Hilton address besides the HGF inbox), cc stephen@. HGF declined Nov 2 (in-kind rooms not their model; nomination based; HGF funds destination stewardship, career development, community resilience). Asked how a South Side nonprofit can be connected to a Chicago-area Hilton property (Team Member nomination or property partnership); small ask of 2 donated rooms in 2027 for instructors Isaac and Jeremy; invited Team Members to visit a Tuesday class. No cash ask. Long shot: TWP may not answer nonprofit requests.',
'reached_out','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where summary like '%01a20a0c-1308-7ab2-bded-791648730eb3%');
update fs_partners set ball_with='them', last_contact_at='2026-11-23',
next_step='Inquiry SENT Nov 23, 2026 to TWP@hilton.com asking for a Chicago Hilton property connection (2 donated rooms, instructors Isaac and Jeremy). Wait for a reply; if silent, check Dec 9 and try the Hilton Chicago (720 S. Michigan) page in Chrome for a published community or sales contact. Online only.',
next_step_due='2026-12-09'
where id='adf13817-6b5b-45c6-a950-cc871d0051b0';
commit;
select name,stage,ball_with,next_step_due from fs_partners where id='adf13817-6b5b-45c6-a950-cc871d0051b0';

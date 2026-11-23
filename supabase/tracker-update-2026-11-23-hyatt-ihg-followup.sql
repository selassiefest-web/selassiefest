-- Hyatt and IHG third-touch follow-ups sent Nov 23, 2026. Safe to re-run.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select 'ae44d885-832f-4de2-8322-e8321175edc8','email','Follow-up SENT Nov 23, 2026 (Resend 01a20a0f-4f86-7852-8e78-b61cd5017989) to risehy@hyatt.com, cc stephen@, threaded to the Nov 18 follow-up: short note naming the ask (2 donated rooms in 2027 for two out-of-town instructors) and asking for the right Chicago property community contact. Plan link included.','reached_out','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where summary like '%01a20a0f-4f86-7852-8e78-b61cd5017989%');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '6e6c31a2-a474-48b6-aedc-ad3e8d39e022','email','Follow-up SENT Nov 23, 2026 (Resend 01a20a0f-5001-70cf-a762-179352ff98e9) to community@ihg.com, cc stephen@, threaded to the Nov 18 follow-up: short note naming the ask (2 donated rooms in 2027 for two out-of-town instructors) and asking for the right Chicago property community contact. Plan link included.','reached_out','stephen@selassiefest.com','Stephen Henry'
where not exists (select 1 from fs_partner_activity where summary like '%01a20a0f-5001-70cf-a762-179352ff98e9%');
update fs_partners set last_contact_at='2026-11-23', ball_with='them', next_step_due='2026-12-07',
 next_step='Third-touch follow-up SENT Nov 23, 2026 naming the ask (2 donated rooms in 2027). Wait for a reply; if silent, check again Dec 7. Send the property request once a contact is named. Online only.'
where id in ('ae44d885-832f-4de2-8322-e8321175edc8','6e6c31a2-a474-48b6-aedc-ad3e8d39e022');
commit;
select name,ball_with,next_step_due from fs_partners where id in ('ae44d885-832f-4de2-8322-e8321175edc8','6e6c31a2-a474-48b6-aedc-ad3e8d39e022');

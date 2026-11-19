-- 2026-11-18: After School Matters status nudge SENT at Stephen's "send" (rti-outreach, Resend 01a1f1ba-139b-7325-b984-9fc1fdbd1f35),
-- stephen@ to rfp@afterschoolmatters.org, cc stephen@. New message. Safe to re-run (guarded by Resend id).
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'ffa174aa-db33-4f38-b21c-af00273717f2','email',
 'Status nudge SENT Nov 18, 2026 (Resend 01a1f1ba-139b-7325-b984-9fc1fdbd1f35) to rfp@afterschoolmatters.org (Khaliyah Cannon, RFP Team), cc stephen@: one sentence asking whether the Programs team needs anything more on our Oct 19 Rolling Interest Form (CBO) and roughly when we might hear about an interview.',
 'in_conversation','stephen@selassiefest.com','Stephen Henry', now()
where not exists (select 1 from fs_partner_activity where partner_id='ffa174aa-db33-4f38-b21c-af00273717f2' and summary like '%01a1f1ba-139b-7325-b984-9fc1fdbd1f35%');
update fs_partners set ball_with='them', last_contact_at=now(),
 next_step='Status nudge sent Nov 18 to rfp@afterschoolmatters.org. Wait for ASM reply / interview invitation; if silent, follow up Fri Dec 4. Still to add: workers comp, umbrella, auto insurance.',
 next_step_due='2026-12-04'
where id='ffa174aa-db33-4f38-b21c-af00273717f2' and next_step not like 'Status nudge sent Nov 18%';
update fs_grant_deadlines set next_step='Status nudge SENT Nov 18, 2026 (Resend 01a1f1ba-139b-7325-b984-9fc1fdbd1f35) to rfp@afterschoolmatters.org. Wait for interview invitation; follow up Dec 4 if silent. Prep fit questions (teen count, 75 hrs/session, space, insurance).',
 next_step_due='2026-12-04',
 notes=coalesce(notes,'')||E'\n[2026-11-18] Status nudge sent (Resend 01a1f1ba-139b-7325-b984-9fc1fdbd1f35).'
where id='d52c3cbd-d864-4e9e-a09d-718e08c07460' and coalesce(notes,'') not like '%01a1f1ba-139b-7325%';
commit;
select (select count(*) from fs_partner_activity where summary like '%01a1f1ba-139b%') acts,(select next_step_due from fs_partners where id='ffa174aa-db33-4f38-b21c-af00273717f2') p,(select next_step_due from fs_grant_deadlines where id='d52c3cbd-d864-4e9e-a09d-718e08c07460') g;

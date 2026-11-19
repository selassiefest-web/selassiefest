-- 2026-11-18: NAMM Foundation pre-inquiry SENT at Stephen's "send" via rti-outreach (Resend 01a1f1b4-8253-7c09-89ea-c193b5989ee0),
-- From stephen@selassiefest.com to info@nammfoundation.org, cc stephen@. Safe to re-run (guarded by the Resend id).
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '17b3c2bc-3071-4d7f-bf1a-78a0b1cfb05a','email',
 'Pre-inquiry SENT Nov 18, 2026 (Resend 01a1f1b4-8253-7c09-89ea-c193b5989ee0) to info@nammfoundation.org, cc stephen@: asks (1) whether a CPA financial review of FY2026 finished before Apr 1, 2027 satisfies the audit/review requirement and (2) whether the 15% Dependency Test uses total or cash-only operating budget. Portal opens Feb 2027, Round 1 due Apr 1, 2027.',
 'reached_out','stephen@selassiefest.com','Stephen Henry', now()
where not exists (select 1 from fs_partner_activity where partner_id='17b3c2bc-3071-4d7f-bf1a-78a0b1cfb05a' and summary like '%01a1f1b4-8253-7c09-89ea-c193b5989ee0%');
update fs_partners set stage='reached_out', ball_with='them', last_contact_at=now(),
 next_step='Pre-inquiry sent Nov 18. Wait for NAMM (info@nammfoundation.org, 760-438-8001). If silent, follow up Dec 2. Real blocker: audit/financial review or fiscal sponsor for FY2026; get a CPA quote. Portal opens Feb 2027; Round 1 due Apr 1, 2027.',
 next_step_due='2026-12-02'
where id='17b3c2bc-3071-4d7f-bf1a-78a0b1cfb05a' and stage='not_contacted';
update fs_grant_deadlines set next_step='Pre-inquiry SENT Nov 18, 2026 (Resend 01a1f1b4-8253-7c09-89ea-c193b5989ee0) asking if a CPA financial review of FY2026 done before Apr 1 satisfies NAMM and whether the 15% test uses total or cash budget. Portal opens Feb 2027, Round 1 due Apr 1, 2027. Follow up Dec 2. Blocker: financial review or fiscal sponsor (get a CPA quote).',
 next_step_due='2026-12-02',
 notes=coalesce(notes,'') || E'\n[2026-11-18] Pre-inquiry sent (Resend 01a1f1b4-8253-7c09-89ea-c193b5989ee0). Preparer check: portal not open until Feb 2027; max award $25,000; $19,500 passes 15% test vs $134,670 total budget ($20,200) but not vs $75,123 cash ($11,268). Ask = 2 instructors x $250 x 39 Tuesdays.'
where id='27809596-c036-4007-8aa1-bc1239138800' and coalesce(notes,'') not like '%01a1f1b4-8253-7c09-89ea-c193b5989ee0%';
commit;
select (select count(*) from fs_partner_activity where summary like '%01a1f1b4-8253%') acts,(select stage||' '||next_step_due from fs_partners where id='17b3c2bc-3071-4d7f-bf1a-78a0b1cfb05a') p,(select next_step_due from fs_grant_deadlines where id='27809596-c036-4007-8aa1-bc1239138800') g;

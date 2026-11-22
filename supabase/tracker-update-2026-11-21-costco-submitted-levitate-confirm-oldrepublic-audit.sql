-- Nov 21, 2026 evening. Costco Benevity application submitted (confirmation Ref#2026110535 received Nov 21 10:34 pm CT);
-- Levitate confirmation email logged; Old Republic letter-not-mailed audit. Safe to re-run (marker-guarded).
begin;

-- Costco grant row
update fs_grant_deadlines set
 status='submitted', submitted_on='2026-11-21', amount_requested=1000, owner='Stephen',
 program='Grant Application (Benevity online form)',
 url='https://forms.benevity.org/eb5f89d4-4631-4c20-8681-0186712671a0',
 next_step_due='2027-01-04',
 next_step='SUBMITTED Nov 21, 2026 via the Benevity form; Costco confirmation Ref#2026110535 received Nov 21 10:34 pm CT. Costco review is 4-6 weeks (contact by email or letter). Check for a decision about Mon Jan 4, 2027; no nudge before then. One application per fiscal year (Sep-Aug): do not file another this year. No public recognition before Costco agrees.',
 notes=notes || E'\n2026-11-21 [costco-submitted-20261121] Stephen completed pages 1-6 of the Benevity form (about 10:14-10:24 pm CT) and pressed Submit; the page showed a "may have been already submitted" error, but Benevity/Costco confirmation Ref#2026110535 arrived Sat Nov 21 10:34 pm CT (Sun Nov 22 04:34:36 UTC), Message-ID <010001a20188dc18-f3797469-f138-42b6-a324-d9cbcb4ad6dc-000000@email.amazonses.com>. Ask $1,000 cash for DJ Lab supplies and printing; org budget $75,123; overhead 8%. Attached cover letter: Claude outputs\\costco\\Ras Tafari Inc - Costco Cover Letter.pdf; W-9 South Holland version. Decision window 4-6 weeks (about Dec 19 to Jan 2). Nothing awarded or received. Route changed from warehouse form to Benevity online (Nov 19, online-only rule); row program/url updated to match.'
where id='94f4ffa2-ecf9-4a08-ad80-453c6becb9a5' and notes not like '%costco-submitted-20261121%';

-- Costco partner row (companion)
update fs_partners set stage='reached_out', ball_with='them', last_contact_at='2026-11-22 04:34:36+00', next_step_due='2027-01-04',
 next_step='Waiting on Costco Community Relations (application submitted Nov 21, 2026, Ref#2026110535; 4-6 week review). Check about Mon Jan 4, 2027. No visit or call; online only.',
 notes=coalesce(notes,'') || E'\n[costco-submitted-20261121] Benevity Grant Application submitted Nov 21, 2026; confirmation Ref#2026110535. See grant row 94f4ffa2. The warehouse route is not used.'
where id='efc8c36e-7d83-414d-996b-75d96a50475f' and coalesce(notes,'') not like '%costco-submitted-20261121%';

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Email from noreply.grants@benevity.com to the Ras Tafari inbox, Sun Nov 22 2026 04:34:36 UTC (Sat Nov 21, 10:34 pm CT), subject "Costco has received your request (Ref#2026110535)", Message-ID <010001a20188dc18-f3797469-f138-42b6-a324-d9cbcb4ad6dc-000000@email.amazonses.com>: Costco Community Relations confirms receipt of the Grant Application (Re: Rainbow DJ Lab; $1,000 ask) and will contact us in 4-6 weeks. Grant row 94f4ffa2. (marker costco-submitted-20261121)','reached_out','noreply.grants@benevity.com','Costco Wholesale Community Relations (Benevity)','2026-11-22 04:34:36+00'
from fs_partners p where p.id='efc8c36e-7d83-414d-996b-75d96a50475f'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%costco-submitted-20261121%');

-- Levitate: log confirmation and the May 15 outside date
update fs_grant_deadlines set
 next_step='SUBMITTED Nov 21, 2026 via Jotform; Levitate confirmation email received (Nov 21, 3:25 am CT). Ask $10,000 (2 instructors x $250 x 20 of 39 Tuesdays). Conflicting funder timing: the form says a status update within 4 weeks after the Jan 1, 2027 deadline (about Jan 29, 2027), but the confirmation email says final decisions come after the grant period, by May 15, 2027. Check Jan 29; outside decision date May 15. No nudge before Jan 29.',
 notes=notes || E'\n2026-11-21 [levitate-confirm-20261121] Confirmation email logged: From The Levitate Foundation (Jotform), Sat Nov 21 2026 04:25:13 -0500, Message-ID <13HTM81AKO6REuj6ZgkSvZxeFFMsPmvqs27wmjQXv0@go-workers-29jt>: they will reach out periodically during the grant period and notify final decisions after the grant period by May 15 (2027). Conflicts with the form text of a status update about Jan 29; both kept. Nothing awarded.'
where id='6568f74b-8a4b-40f8-857f-87792a476991' and notes not like '%levitate-confirm-20261121%';

-- Old Republic: audit note only; status ready, due Nov 23 and next_step unchanged
update fs_grant_deadlines set
 notes=notes || E'\n2026-11-21 [or-audit-20261121] Audit of all sources: the printed Nov 1 letter was never mailed (Stephen, Nov 19; no mail evidence in Supabase, BOB, Claude outputs or git since); online only. Live HubSpot form re-checked Nov 21: fields Company*, First*, Last*, Job Title, Email*, Phone, State, Industry, "Which company"* (operating companies only, no giving option; recommend Old Republic Title), message; no attachment; promises reply in 1-2 business days. Status stays ready; Stephen submits Mon Nov 23 after saying send. Not submitted, nothing awarded or received.'
where id='6a15168d-fb2e-40c6-80c8-9531166570ca' and notes not like '%or-audit-20261121%';

commit;

select 'costco_grant' k, status, submitted_on::text, next_step_due::text from fs_grant_deadlines where id='94f4ffa2-ecf9-4a08-ad80-453c6becb9a5'
union all select 'costco_partner', stage||'/'||ball_with, last_contact_at::text, next_step_due::text from fs_partners where id='efc8c36e-7d83-414d-996b-75d96a50475f'
union all select 'costco_activity', 'rows', count(*)::text, null from fs_partner_activity where summary like '%costco-submitted-20261121%'
union all select 'levitate', status, submitted_on::text, next_step_due::text from fs_grant_deadlines where id='6568f74b-8a4b-40f8-857f-87792a476991' and notes like '%levitate-confirm-20261121%'
union all select 'old_republic', status, submitted_on::text, next_step_due::text from fs_grant_deadlines where id='6a15168d-fb2e-40c6-80c8-9531166570ca' and notes like '%or-audit-20261121%';

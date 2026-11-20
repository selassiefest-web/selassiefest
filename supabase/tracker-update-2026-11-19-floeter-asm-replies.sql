-- 2026-11-19: log two incoming replies (John Floeter / MPTF via CFM; After School Matters).
-- Safe to re-run: each block is guarded by status/date and a Message-ID marker in notes.
begin;

-- A. MPTF grant (grant-only: no fs_partners row exists for CFM/MPTF)
update fs_grant_deadlines set
  next_step = $t$John Floeter replied Nov 19, 2026: he will set aside MPTF funds from CFM's allotment for the Jul 21, 2027 Rainbow Wednesday and reserves them until Jun 6, 2027. Ball with us. Jun 6, 2027 is John's INTERNAL deadline for all application info; MPTF's external deadline is a complete and correct application within 30 days (his term). Musicians need not be union; if any is a union member, that person is leader and John's contact, otherwise Stephen is contact and remits work dues and pension to CFM. Details later. NEXT: Stephen sends a short thanks (due Fri Nov 20, 2026) and keeps Jun 6, 2027 (John's internal deadline) in view; John said details come later. Our plan, not John's request: confirm musician lineup, union status and any W-9, targeting about May 3, 2027 (our internal target).$t$,
  next_step_due = '2026-11-20',
  notes = coalesce(notes,'') || E'\n[2026-11-19] REPLY John Floeter (VP CFM Local 10-208) Nov 19 2026 16:45 UTC, Message-ID <CH2PR22MB20089490D0554E1CE0B4EE9AF4792@CH2PR22MB2008.namprd22.prod.outlook.com>, in reply to our Nov 18 Resend 01a1f225-d671-7187-a372-a952173a9c92 (SES <010001a1f225d771-5260404e-396e-4ff7-8fb0-24d0310523b5-000000@email.amazonses.com>). Reserves funds until Jun 6; internal deadline Jun 6; MPTF external 30 days from complete application; non-union OK; union leader or Stephen as contact; dues/pension remitted by leader or us; details later.'
where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
  and status = 'drafting' and next_step_due = '2026-12-02'
  and coalesce(notes,'') not like '%CH2PR22MB20089490D0554E1CE0B4EE9AF4792%';

-- B. After School Matters partner row + activity (activity only if the update fired)
with u as (
  update fs_partners set
    last_contact_at = '2026-11-19 16:02:25+00',
    next_step = $t$ASM replied Nov 19, 2026: nothing more needed from us; Programs reviewing Rolling Interest Forms until end of December for Spring 2027 and will contact for an interview if interested. Ball with ASM. If silent, our follow-up: status email Mon Jan 4, 2027. Meanwhile still to add: workers comp, umbrella, auto insurance; keep interview prep (teen count, space).$t$,
    next_step_due = '2027-01-04',
    notes = coalesce(notes,'') || E'\n[2026-11-19] REPLY Khaliyah Cannon (ASM RFP Team) Nov 19 16:02 UTC, Message-ID <CH3PR17MB71488E09FD10A7B9711DE612D2792@CH3PR17MB7148.namprd17.prod.outlook.com>: nothing more needed; Programs reviewing forms until end of Dec for Spring 2027; interview if interested.'
  where id = 'ffa174aa-db33-4f38-b21c-af00273717f2'
    and stage = 'in_conversation' and ball_with = 'them' and next_step_due = '2026-12-04'
    and coalesce(notes,'') not like '%CH3PR17MB71488E09FD10A7B9711DE612D2792%'
  returning id)
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select u.id, 'email',
  $t$Nov 19, 2026 (10:02 am CT; 16:02 UTC) REPLY from Khaliyah Cannon (ASM RFP Team, rfp@afterschoolmatters.org), subject "Re: [EXTERNAL]Ras Tafari Inc. Rolling Interest Form (CBO): status check", answering our Nov 18 nudge (In-Reply-To <010001a1f1ba148f-f127c32c-eaf4-4e7e-b374-778594f05e57-000000@email.amazonses.com>), Message-ID <CH3PR17MB71488E09FD10A7B9711DE612D2792@CH3PR17MB7148.namprd17.prod.outlook.com>. Nothing more needed; Programs reviewing Rolling Interest Forms until end of December for Spring 2027; interview contact only if interested. No decision, no interview yet.$t$,
  'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 16:02:25+00'
from u;

-- C. ASM grant row
update fs_grant_deadlines set
  next_step = $t$ASM replied Nov 19, 2026: nothing more needed from us; Programs reviewing Rolling Interest Forms until end of December for Spring 2027 and will contact for an interview if interested. Ball with ASM. If silent, our follow-up: status email Mon Jan 4, 2027.$t$,
  next_step_due = '2027-01-04',
  notes = coalesce(notes,'') || E'\n[2026-11-19] ASM reply Message-ID <CH3PR17MB71488E09FD10A7B9711DE612D2792@CH3PR17MB7148.namprd17.prod.outlook.com>: nothing more needed; reviewing through end of Dec for Spring 2027.'
where id = 'd52c3cbd-d864-4e9e-a09d-718e08c07460'
  and status = 'submitted' and next_step_due = '2026-12-04'
  and coalesce(notes,'') not like '%CH3PR17MB71488E09FD10A7B9711DE612D2792%';

commit;

-- verify
select 'mptf' k, next_step_due::text, coalesce(deadline_date::text,'null'), (notes like '%CH2PR22MB20089490D0554E1CE0B4EE9AF4792%')::text marker from fs_grant_deadlines where id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5'
union all select 'asm_partner', next_step_due::text, last_contact_at::text, (notes like '%CH3PR17MB71488E09FD10A7B9711DE612D2792%')::text from fs_partners where id = 'ffa174aa-db33-4f38-b21c-af00273717f2'
union all select 'asm_grant', next_step_due::text, status, (notes like '%CH3PR17MB71488E09FD10A7B9711DE612D2792%')::text from fs_grant_deadlines where id = 'd52c3cbd-d864-4e9e-a09d-718e08c07460'
union all select 'asm_activity', count(*)::text, '', '' from fs_partner_activity where summary like '%CH3PR17MB71488E09FD10A7B9711DE612D2792%';

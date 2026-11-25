-- Equipment final (Stephen, Nov 25, 2026): 13 XDJ-AN decks ($1,199) and one laptop. Update open plans only. Safe to re-run.
begin;

update fs_grant_deadlines
set next_step = replace(next_step, 'planned request $12,103 (7 DJ controllers x $1,729).', 'planned request $11,990 (10 AlphaTheta XDJ-AN decks x $1,199); the Nov 24 email quoted $12,103 on the earlier equipment, so say the figure changed.'),
    updated_at = now()
where funder = 'DeKalb County Community Foundation' and next_step like '%7 DJ controllers x $1,729%';

update fs_grant_deadlines
set next_step = replace(next_step, '13 controllers $22,477, 13 headphones, 14 take-home drives at $15', '13 XDJ-AN decks $15,587, 14 take-home drives at $15'),
    updated_at = now()
where funder = 'Reverb Gives' and next_step like '%13 controllers $22,477%';

update fs_grant_deadlines
set next_step = replace(next_step, '(12 Windows laptops; accept partial fulfillment)', '(1 Windows laptop for the Lab)'),
    notes = regexp_replace(notes, 'Ask for 12 Windows laptops for the 12 stations', 'Ask for 1 Windows laptop for the Lab'),
    updated_at = now()
where funder = 'Digitunity' and (next_step like '%12 Windows laptops%' or notes like '%Ask for 12 Windows laptops for the 12 stations%');

update rti_calendar_events
set notes = 'Planned request $11,990, 10 XDJ-AN decks x $1,199'
where key = 'wurlitzer-file-2027-01-01' and notes like '%1,729%';

update fs_grant_deadlines
set notes = replace(notes, 'two-controller idea (now seven planned).', 'two-controller idea (now 10 XDJ-AN decks planned, Nov 25, 2026).'), updated_at = now()
where id = '013d3944-c420-4534-b9af-7f3a604c0235' and notes like '%(now seven planned)%';

update fs_grant_deadlines
set notes = notes || ' | Sent email Message-ID <CO6P220MB0338730DAB3A1C089499BD0ED7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>', updated_at = now()
where id = '013d3944-c420-4534-b9af-7f3a604c0235' and notes not like '%CO6P220MB0338730DAB3A1C089499BD0ED7432%';

update fs_grant_deadlines
set next_step = next_step || ' Need is now 1 Windows laptop (Nov 25, 2026); say so in the reply or nudge.', updated_at = now()
where id = 'd80a476f-ce3c-4afa-b686-30065b45266f' and next_step like '%13 refurbished Windows laptops%' and next_step not like '%Need is now 1 Windows laptop%';

update fs_grant_deadlines
set next_step = next_step || ' In any follow-up, say the figure changed: 13 XDJ-AN decks x $1,199 = $15,587 (Nov 25, 2026).', updated_at = now()
where id in ('845df475-8d46-4800-bfec-55eb54cae276', 'fd13c269-be4d-4b67-9cb7-16f36d2f375b')
  and next_step like '%$22,477%' and next_step not like '%13 XDJ-AN decks x $1,199%';

update fs_partners
set next_step = replace(next_step, 'Likely drop: we use Apple laptops only.', 'The Lab now plans one Windows laptop, a Lenovo ThinkPad E14 (Nov 25, 2026).')
where id = '5705d5ef-a564-4532-93c9-b3ded41240fa' and next_step like '%Apple laptops only%';

commit;

select 'grant' as t, funder as k, next_step, right(notes, 200) as notes from fs_grant_deadlines
where id in ('013d3944-c420-4534-b9af-7f3a604c0235','84c13f12-570b-4ef2-9858-1c6b68cefcb2','9803c760-88e8-44f7-bfc7-083b197a7323','d80a476f-ce3c-4afa-b686-30065b45266f','845df475-8d46-4800-bfec-55eb54cae276','fd13c269-be4d-4b67-9cb7-16f36d2f375b')
union all select 'calendar', key, null, notes from rti_calendar_events where key = 'wurlitzer-file-2027-01-01'
union all select 'partner', name, next_step, null from fs_partners where id = '5705d5ef-a564-4532-93c9-b3ded41240fa';

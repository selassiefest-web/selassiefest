-- 2026-11-18: re-cut the Mellon and Joyce asks to match each funder's stated priorities
-- and the Rainbow Wednesdays program budget ($42,450; CPD $25,000 + RTI cash $17,450).
-- Safe to re-run: each update is guarded by the old amount and a notes marker.
begin;

-- Mellon Humanities in Place: $28,400 -> $12,300 (visual-art commissions 14x$400 + design sessions 14x$300 + documentation/evaluation $2,500)
update fs_grant_deadlines
set amount_requested = 12300,
    next_step = 'Capture real Fluxx quiz wording and field limits (Chrome, read only), then Stephen creates the Fluxx account, answers the quiz and submits: 08-national-fdn\09-mellon-foundation.md (rebuilt Nov 18). Ask = 3 lines only; withdraw if Park District funds them.',
    next_step_due = '2026-11-20',
    notes = coalesce(notes,'') || E'\n[2026-11-18] ASK RE-CUT after studying Mellon (mellon.org/grant-programs/humanities-in-place, /mission, /resources): $12,300 = weekly visual-art commissions 14 x $400 ($5,600) + community design sessions 14 x $300 ($4,200) + documentation and evaluation ($2,500). Old $28,400 (signature commissions, $500 rate) retired. Attendance goal 300 a night. Lines overlap the Park District Night Out request ($25,000, decision early Mar 2027): withdraw or re-scope if CPD funds them. Mellon does not fund youth programming/K-12: lead with elders, heritage, public places.'
where id = 'f8a0dd78-6d76-4ac8-864e-c32b44ae2ec5'
  and amount_requested = 28400
  and coalesce(notes,'') not like '%[2026-11-18] ASK RE-CUT%';

-- Joyce Culture: $50,000 -> $16,800 (sound and technical contractor, 14 x $1,200)
update fs_grant_deadlines
set amount_requested = 16800,
    next_step = 'Send nudge A (no letter link) as Reply All in the Oct 29 thread asking which cycle to aim for (Dec 1 is the PROPOSAL deadline; LOIs are due 6-8 weeks earlier; next cycle Apr 1, 2027, LOI about early-mid Feb). Packet rebuilt Nov 18: 07-chicago-fdn-relationship\01-joyce-foundation.md',
    next_step_due = '2026-11-20',
    notes = coalesce(notes,'') || E'\n[2026-11-18] ASK RE-CUT after studying Joyce Culture guidelines (production is an eligible cost; artist/design/fabrication lines are in the Park District request): $16,800 = sound and technical contractor 14 x $1,200 only. Old $50,000 letter retired (exceeded the $42,450 program). Public letter full-spectrum/joyce still shows $50,000: rebuild before sharing its link. Attendance goal 300 a night.'
where id = 'dc25d586-f390-4553-964a-01fd8090c8e1'
  and amount_requested = 50000
  and coalesce(notes,'') not like '%[2026-11-18] ASK RE-CUT%';

commit;

select id, funder, amount_requested, next_step_due, status
from fs_grant_deadlines
where id in ('f8a0dd78-6d76-4ac8-864e-c32b44ae2ec5','dc25d586-f390-4553-964a-01fd8090c8e1')
order by funder;

-- 2026-11-18: Mellon Foundation Humanities in Place inquiry SUBMITTED by Stephen.
-- Evidence: Fluxx receipt email "Mellon Foundation Inquiry", Wed Nov 18 2026 23:50:01 UTC (5:50 pm CST),
-- Message-ID <010001a1f1113f81-ed1e1692-b89e-4520-97c8-982eee7f8b81-000000@email.amazonses.com>.
-- Inquiry id 123482. No Mellon partner row exists, so no activity entry. Safe to re-run (guarded).
begin;

update fs_grant_deadlines
set status = 'submitted',
    submitted_on = '2026-11-18',
    decision_on = null,
    amount_requested = 12300,
    next_step = 'Wait: Mellon reviews inquiries within three months of submission (about Feb 18, 2027) and contacts us if the work fits. Internal follow-up only: if silent after Feb 18, 2027, one polite status question to inquiries@mellon.org. After the Park District decides (early Mar 2027), tell Mellon which lines it funded (withdraw/re-scope rule).',
    next_step_due = '2027-02-18',
    notes = coalesce(notes,'') || E'\n[2026-11-18] SUBMITTED via Fluxx (inquiry 123482), $12,300 request on a $42,450 program; receipt email 23:50 UTC Nov 18, Message-ID <010001a1f1113f81-ed1e1692-b89e-4520-97c8-982eee7f8b81-000000@email.amazonses.com>. Receipt says: three-month review; if the request fits their priorities and resources they will be in touch. Not awarded; nothing owed. Support questions: fluxxusers@mellon.org.'
where id = 'f8a0dd78-6d76-4ac8-864e-c32b44ae2ec5'
  and status = 'drafting'
  and coalesce(notes,'') not like '%SUBMITTED via Fluxx (inquiry 123482)%';

commit;

select id, funder, status, submitted_on, amount_requested, next_step_due
from fs_grant_deadlines where id = 'f8a0dd78-6d76-4ac8-864e-c32b44ae2ec5';

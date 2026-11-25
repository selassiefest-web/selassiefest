-- DeKalb CCF / Wurlitzer: eligibility inquiry SENT Nov 24, 2026 11:18 pm (Outlook, stephen@). Safe to re-run.
-- Source: Stephen's Sent Items screenshot; guidelines FRWFF-Grant-Guidelines-Fall-2026.pdf (revised 06/26/26).
begin;

update fs_grant_deadlines
set status = 'drafting',
    deadline_date = date '2027-03-01',
    opens_date = date '2027-01-01',
    amount = '$1,500-$12,500 average range',
    next_step = 'Inquiry SENT Nov 24, 2026 to george@dekalbccf.org (George Buck). If silent, one email nudge Dec 2. File online Jan 1, 2027 (portal opens two months before the Mar 1 deadline) at https://www.grantinterface.com/Home/Logon; planned request $12,103 (7 DJ controllers x $1,729).',
    next_step_due = date '2026-12-02',
    notes = coalesce(notes, '') || ' | [wurlitzer-inquiry 2026-11-24] Eligibility inquiry sent from stephen@selassiefest.com (Cc Stephen) at 11:18 pm CT, subject "March 1 cycle question: DJ controllers for a free youth music class in Chicago". Guidelines (rev. 06/26/26): contact george@dekalbccf.org (replaces grants@); Mar 1 and Sep 1 deadlines confirmed; DeKalb County preference; one funded grant per two consecutive cycles; spring decisions near May 25; report due within 10 months; paid by ACH. Supersedes older note items: prior amount about $1,000-$2,500, two-controller idea (now seven planned).',
    updated_at = now()
where funder = 'DeKalb County Community Foundation'
  and coalesce(notes, '') not like '%[wurlitzer-inquiry 2026-11-24]%';

commit;

select funder, program, status, submitted_on, deadline_date, opens_date, amount, next_step_due, next_step
from fs_grant_deadlines
where funder = 'DeKalb County Community Foundation';

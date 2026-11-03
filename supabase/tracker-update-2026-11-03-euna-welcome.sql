-- Euna Supplier Network (Bonfire) welcome email, Tue Nov 3 2026 04:23 UTC (Mon Nov 2, 11:23 PM CT)
-- From support@gobonfire.com, Message-ID <1fb9b08d-58a4-4fc1-b645-5b18fffcb1c6@mtasv.net>. Automated; no attachments; no partner row exists for Euna/Bonfire or CPS (so no fs_partner_activity row).
-- Only matching tracker record: the "Ingenuity / CPS" grant row (skip, NO GO on RFQ 26-1355). Safe to re-run.
begin;

update fs_grant_deadlines
set next_step = next_step || ' | Nov 2: Euna Supplier Network (Bonfire) vendor account is live (welcome email Nov 2, 11:23 PM CT), so set the cps.bonfirehub.com alert there to catch the next Arts Education Vendor Pool RFQ.'
where id = 'e0fa07ae-c881-4c15-b8a5-a5e22602a8c8'
  and next_step not like '%Euna Supplier Network (Bonfire) vendor account is live%';

commit;

select id, funder, status, right(next_step, 200) as next_step_tail
from fs_grant_deadlines
where id = 'e0fa07ae-c881-4c15-b8a5-a5e22602a8c8';

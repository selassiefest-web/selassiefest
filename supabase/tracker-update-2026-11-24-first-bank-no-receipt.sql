-- First Bank Chicago: NO RECEIPT captured. The Kadince confirmation page ("The entry was submitted", with Send Receipt button) was seen Nov 24, 2026 but closed before a receipt was sent; re-opening the confirmation URL redirects to a blank form, so it cannot be recovered. Proof of receipt must come from First Bank. Safe to re-run.
begin;
update fs_grant_deadlines set next_step_due='2026-12-08',
  next_step='NO RECEIPT KEPT (Nov 24, 2026): the Kadince confirmation page was seen but closed before Send Receipt; it cannot be reopened. Do NOT start a new entry (would duplicate). Email dbryant@firstbankchicago.com (verified on the grant form) to confirm the request was received (title: Rainbow DJ Lab: a DJ station of their own for Chicago kids, $3,750, submitted Nov 24, 2026) and ask for a receipt; if silent, again Jan 5, 2027. Funder says allow 4-6 weeks for a decision.',
  notes=case when coalesce(notes,'') like '%2026-11-24: no receipt (First Bank)%' then notes else coalesce(notes,'')||E'\n2026-11-24: no receipt (First Bank): confirmation page seen ("The entry was submitted") but closed before Send Receipt; URL now redirects to a blank form. Confirm receipt with Denise Bryant by email.' end
where id='1e5002c8-5b07-4685-b001-766672f3f25c';
select funder,status,next_step_due from fs_grant_deadlines where id='1e5002c8-5b07-4685-b001-766672f3f25c';
commit;

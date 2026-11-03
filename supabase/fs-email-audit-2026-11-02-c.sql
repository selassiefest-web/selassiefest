-- Outlook email audit batch C (Nov 2, 2026). Douglas Allen (douglas.allen@afccchicago.com) replied Sun Nov 1, 2026 9:39 AM CT to the
-- Oct 31 "Who do we know? Twelve names" ask: "I know of the organizations, but no one personally." Record it on all 12 intro-ask funder rows.
-- Other recipients (board, Field Marshall, Jah Syll) have not replied in the mailbox as of Nov 2; replies are due Nov 13.
begin;
update fs_grant_deadlines set
  next_step = next_step || ' Douglas Allen replied Nov 1: he knows the organizations but no one personally (no intro from him). Still waiting on the others.',
  updated_at = now()
where next_step like 'Intro-ask SENT Oct 31%' and next_step not like '%Douglas Allen replied%';
select 'funder rows with Douglas Allen reply' as check, count(*)::text as n from fs_grant_deadlines where next_step like '%Douglas Allen replied Nov 1%';
commit;

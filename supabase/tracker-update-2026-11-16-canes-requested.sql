-- Nov 16, 2026: Raising Cane's dashboard checked by Stephen: status still "Requested". Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step = 'Dashboard checked Nov 16: status "Requested" (pending, restaurant #C0288 Evergreen Park, Tea/Lemonade). Stephen: send the short note with the portal''s "Message Raising Cane''s" link (text in Claude outputs/overdue-2026-11-16/DRAFTS-NOT-SENT.txt, section 1b) asking if they need our IRS letter, W-9 or a pickup contact. If no reply by Nov 23, call or visit the restaurant (9570 S Western Ave).',
  next_step_due = '2026-11-17',
  notes = coalesce(notes,'') || E'\n2026-11-16: Stephen checked raisingcanescommunity.com/events/donation-org (screenshot): status Requested, no decision, no message from the restaurant.'
where id = '53fda21e-a4a8-4797-8b73-d5cd54534456' and coalesce(notes,'') not like '%2026-11-16: Stephen checked raisingcanescommunity%';
select funder, status, next_step_due from fs_grant_deadlines where id = '53fda21e-a4a8-4797-8b73-d5cd54534456';
commit;

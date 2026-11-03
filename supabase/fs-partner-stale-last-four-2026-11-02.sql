-- Removes the last 4 stale October dates from next_step (tracker item 3). Applied Nov 2, 2026. Safe to re-run.
begin;
update fs_partners set next_step = 'Letter still to hand-deliver or mail. No contact yet.', updated_at = now()
  where next_step = 'Letter to hand-deliver or mail; follow up 10/26' and name in ('WHPK 88.5 FM','Park Manor 75');
update fs_partners set next_step = replace(next_step, 'Follow-up emailed 10/28; call if no reply.', 'Follow-up emailed Oct 28. No reply logged. Call.'), updated_at = now()
  where name = 'Rebuild Foundation / Stony Island Arts Bank' and next_step like 'Follow-up emailed 10/28; call if no reply.%';
update fs_partners set next_step = 'Follow-up emailed Oct 28. No reply logged. Hold until Wed Nov 4, then call.', updated_at = now()
  where name = 'Roland (Music Education)' and next_step = 'Follow-up emailed 10/28; call if no reply';
select 'stale rows left (should be 0)' as check, count(*)::text as n from fs_partners where next_step ~* 'follow up (by phone )?10/2[0-9]|emailed 10/2[0-9]|to hand-deliver or mail; follow up';
commit;

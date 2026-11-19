-- 2026-11-18: Stephen said PARK the big-name/celebrity foundation rows that only waited on a board intro reminder (his word: we know no one to make those introductions).
-- Targets: rows still due 2026-11-20 AND carrying the '[datefix-intro]' note. next_step set to PARKED, due date cleared (not overdue), status unchanged. Guarded; safe to re-run.
begin;
update fs_grant_deadlines
set next_step='PARKED by Stephen Nov 18, 2026: we know no one in our network to make this introduction, so the Nov 20 board reminder is dropped. No date; not overdue. Status unchanged. Revisit only if someone offers a real contact.',
    next_step_due=null,
    notes=coalesce(notes,'')||E'\n[2026-11-18] PARKED by Stephen (his word in chat): no network contact for an introduction; board reminder dropped; date cleared. [parked-intro-2026-11-18]'
where next_step_due='2026-11-20' and coalesce(notes,'') like '%[datefix-intro]%' and coalesce(notes,'') not like '%[parked-intro-2026-11-18]%';
commit;
select (select count(*) from fs_grant_deadlines where notes like '%[parked-intro-2026-11-18]%') parked,(select count(*) from fs_grant_deadlines where next_step_due='2026-11-20') still_nov20;

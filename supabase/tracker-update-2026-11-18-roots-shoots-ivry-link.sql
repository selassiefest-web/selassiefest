-- Nov 18, 2026: link the Roots & Shoots $250 award to the Ivry lawn-plan email. Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step = case when next_step like '%IVRY:%' then next_step else coalesce(next_step,'') || E'\nIVRY: lawn-plan email sent to Ivry Ector Nov 18 (private page https://selassiefest.com/donors/?k=yef5fwsf95zjwbgt, 9 ideas, she picks 1 for $250 or 2 for $125 each, no deadline). When her "Send my plan" email arrives, log it on the Chicago Park District (Ivry Ector) partner row, then buy the art materials for her choice with the gift card (all $250, project items only) and use it for the Dec 30 progress report.' end,
  notes = case when notes like '%2026-11-18 IVRY:%' then notes else coalesce(notes,'') || E'\n2026-11-18 IVRY: project plan sent to Ivry Ector (CPD, Rainbow Beach), Resend id 01a1f0ac-1494-7693-a7d1-4d7d028aca09. Nine options (1-7 on the lawn map, 8 The Park Art Hour and 9 The Check Out Wall indoors). The Check Out Wall gives neighbor quotes and counts for the Dec 30 report. Partner row: "Chicago Park District (Ivry Ector): Rainbow Wednesday lawn plan, Roots & Shoots $250 art".' end
where id = '38c4ff8b-f15a-4c28-9182-8093fb370263';
commit;
select status, next_step like '%IVRY:%' as linked_next, notes like '%2026-11-18 IVRY:%' as linked_notes from fs_grant_deadlines where id = '38c4ff8b-f15a-4c28-9182-8093fb370263';

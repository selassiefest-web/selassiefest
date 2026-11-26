-- A Better Chicago: follow-up sent Thu Nov 26, 2026 2:31 PM CT. Grant-only record (no fs_partners row, so no
-- fs_partner_activity). No Message-ID captured; stable key is [src:abc-sent-2026-11-26-1431CT]. Safe to re-run.
begin;
do $$
declare n int;
begin
  -- grant row
  perform 1 from fs_grant_deadlines where id = '9d279d3a-a048-4c95-ac29-af9df6c8a77f' for update;
  if not exists (select 1 from fs_grant_deadlines where id = '9d279d3a-a048-4c95-ac29-af9df6c8a77f'
                 and position('[src:abc-sent-2026-11-26-1431CT]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      next_step = 'Follow-up SENT Nov 26 2:31 PM CT to grants@abetterchicago.org (after the Oct 31 note). Wait for a reply; do not resend. If none, prepare ONE nudge draft Wed Dec 9 (send only after Stephen says send).',
      next_step_due = date '2026-12-09',
      verified_on = date '2026-11-26',
      notes = coalesce(notes,'') || E'\n[prior next_step, replaced 2026-11-26] ' || coalesce(next_step,'') || E'\n[2026-11-26] Follow-up SENT by Stephen from stephen@ to grants@abetterchicago.org at 2:31 PM CT (seen in Outlook Sent Items; Message-ID not captured). Subject: "Following up: Ras Tafari Inc. interest, free DJ classes for South Side youth". Short follow-up to the Oct 31 note; asks a 15-minute video call; includes deck link. Same day check of the grantee-application page: no link to an interest form shown, only a newsletter signup. [src:abc-sent-2026-11-26-1431CT]',
      updated_at = now()
    where id = '9d279d3a-a048-4c95-ac29-af9df6c8a77f'
      and funder = 'A Better Chicago' and status = 'submitted' and next_step_due = date '2026-11-30';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'ABC grant guard failed (rows=%)', n; end if;
  end if;

  -- shared Nov 30 alert: remove only A Better Chicago, keep the other follow-ups
  perform 1 from rti_calendar_events where id = 'cd8ea2b9-2613-41a9-8990-5c4e6192069c' for update;
  if exists (select 1 from rti_calendar_events where id = 'cd8ea2b9-2613-41a9-8990-5c4e6192069c'
             and (title like '%A Better Chicago%' or notes like '%9d279d3a%')) then
    update rti_calendar_events set
      title = replace(title, ' A Better Chicago,', ''),
      notes = replace(notes, ' G 9d279d3a A Better Chicago;', '')
    where id = 'cd8ea2b9-2613-41a9-8990-5c4e6192069c' and key = 'nov30-followups-2026-11-30'
      and title like '%, A Better Chicago,%' and notes like '% G 9d279d3a A Better Chicago;%';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'Nov 30 calendar guard failed (rows=%)', n; end if;
  end if;
  if not exists (select 1 from rti_calendar_events where key = 'triage-followups-2026-12-09' and position('9d279d3a' in coalesce(notes,'')) > 0) then
    update rti_calendar_events set
      notes = coalesce(notes,'') || ' | A Better Chicago [9d279d3a-a048-4c95-ac29-af9df6c8a77f] (only if no reply: prepare one nudge draft; send only after Stephen says send)'
    where key = 'triage-followups-2026-12-09' and active;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'Dec 9 calendar guard failed (rows=%)', n; end if;
  end if;
end $$;
commit;

select 'grant' as rec, funder as label, status, next_step_due::text as due, verified_on::text as extra, next_step as detail,
       (length(notes) - length(replace(notes, '[src:abc-sent-2026-11-26-1431CT]', ''))) / length('[src:abc-sent-2026-11-26-1431CT]') as marker_count
from fs_grant_deadlines where id = '9d279d3a-a048-4c95-ac29-af9df6c8a77f'
union all
select 'calendar', title, active::text, starts_at::text, null, notes, null
from rti_calendar_events where id = 'cd8ea2b9-2613-41a9-8990-5c4e6192069c';

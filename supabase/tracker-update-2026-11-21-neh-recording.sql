-- NEH grant row: log Teams recording-available email (Message-ID EventRecording-94a83ab8). Informational only.
-- Re-run safe: guarded by notes not like '%94a83ab8%'. First run = 1 row, rerun = 0 rows.
begin;

update fs_grant_deadlines
set notes = notes || E'\n' || '2026-11-13 NEH Q&A recording email (sender Microsoft Teams no-reply@teams.mail.microsoft; Fri Nov 13 2026 17:45:58 UTC = 11:45 am CT; to stephen@selassiefest.com), Message-ID <EventRecording-94a83ab8-e080-40fe-8e31-5c26998f30e4.rcid_417b6537-aac0-4fce-8e0d-a6aedcd20b8f-r33-ioe_0-tid_93b06459-c77d-44b6-af7f-e813cddcdcc3-rh_usga_notifyp-aid_417b6537-aac0-4fce-8e0d-a6aedcd20b8f@odspnotify>: recording of the Q&A Session for Public Humanities Projects is available (link in the .eml; no expiry stated; email text thanks attendees, whether Stephen attended is not stated). Informational only: no decision, deadline or amount. Does not change the Oct 31 inquiry reply wait or the Dec 4 nudge. [src:msgid-EventRecording-94a83ab8]',
    updated_at = now()
where id = 'a75ac9d3-114c-4435-ac20-b3b7e4f27eb7'
  and funder = 'National Endowment for the Humanities'
  and status = 'submitted'
  and notes not like '%94a83ab8%';

commit;

select id, funder, status, next_step_due,
       (length(notes) - length(replace(notes, '94a83ab8', ''))) / length('94a83ab8') as marker_count,
       right(notes, 120) as notes_tail
from fs_grant_deadlines
where id = 'a75ac9d3-114c-4435-ac20-b3b7e4f27eb7';

-- Fry Foundation Arts Learning LOI 2026-5494: decline letter, Mon Nov 23, 2026 (21:25 UTC, 3:25 pm America/Chicago)
-- Source: Message-ID <010001a20a4c9087-3faa8d5e-cc47-4f03-bb5e-e5a8cc4574ea-000000@email.amazonses.com> (SmartSimple), attachment Ras_Tafari_Inc__Application_Response.pdf
-- Re-runnable: guarded by Message-ID fragment 3faa8d5e. Expected current grant status = submitted.
begin;

update fs_grant_deadlines set
  status = 'declined',
  decision_on = '2026-11-23',
  next_step = 'DECLINED Nov 23, 2026 (LOI 2026-5494, $27,300 Arts Learning ask). Not awarded, nothing received. Fry invites reconnecting as the Rainbow DJ Lab builds a track record and student-learning data. No resubmission for the Mar 1, 2027 cycle. Optional thank-you to Joe Panganiban via applications@fryfoundation.org. Owner: not assigned.',
  next_step_due = null,
  notes = notes || ' | 2026-11-23: DECLINE letter from Joe Panganiban, Arts Learning Program Officer (Message-ID <010001a20a4c9087-3faa8d5e-cc47-4f03-bb5e-e5a8cc4574ea-000000@email.amazonses.com>, attachment Application_Response.pdf, dated Nov 23, 2026). Reason: Arts Learning prioritizes programs with a stronger track record of effective arts instruction supported by student learning data; focus is arts education especially in Chicago public schools. Welcomed reconnecting as the program evolves. Supersedes the earlier next step (30-day reply about Dec 1 and full proposal Mar 1, 2027). Original submission facts above kept.',
  updated_at = now()
where id = 'b9040174-4762-46a0-9d35-0cff54574aa2'
  and status = 'submitted'
  and notes not like '%3faa8d5e%';

update fs_partners set
  stage = 'declined',
  ball_with = 'parked',
  last_contact_at = '2026-11-23 21:25:19+00',
  next_step = 'Declined Nov 23, 2026 (Arts Learning LOI 2026-5494). Fry welcomes reconnecting once the Rainbow DJ Lab has a track record and student-learning data. Revisit after the first DJ Lab semester; no date set.',
  next_step_due = null,
  notes = coalesce(notes,'') || ' | 2026-11-23: Fry declined the Rainbow DJ Lab LOI (2026-5494); see grant row b9040174-4762-46a0-9d35-0cff54574aa2.'
where id = '5be10ce3-36a0-4789-bed9-c18d01c2fd28'
  and stage = 'not_contacted'
  and coalesce(notes,'') not like '%2026-5494%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '5be10ce3-36a0-4789-bed9-c18d01c2fd28','email',
 'Nov 23, 2026: Fry Foundation (Joe Panganiban, Arts Learning Program Officer, via SmartSimple noreply to stephen@selassiefest.com) declined the Rainbow DJ Lab teaching-artists LOI 2026-5494 ($27,300 requested). Reason: prefers programs with a track record and student learning data; welcomes reconnecting as the program develops. No award, no cash. Message-ID <010001a20a4c9087-3faa8d5e-cc47-4f03-bb5e-e5a8cc4574ea-000000@email.amazonses.com>.',
 'declined','stephen@selassiefest.com','Claude','2026-11-23 21:25:19+00'
where not exists (select 1 from fs_partner_activity where summary like '%3faa8d5e%');

select g.status, g.decision_on, g.next_step_due, g.amount_awarded, p.stage, p.ball_with,
       (select count(*) from fs_partner_activity where summary like '%3faa8d5e%') as activity_rows
from fs_grant_deadlines g, fs_partners p
where g.id='b9040174-4762-46a0-9d35-0cff54574aa2' and p.id='5be10ce3-36a0-4789-bed9-c18d01c2fd28';
commit;

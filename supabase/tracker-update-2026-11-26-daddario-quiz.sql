-- D'Addario Foundation eligibility quiz submitted Thu Nov 26, 2026 (SENT-LOG.md, last "Row 30" line).
-- An eligibility inquiry, not an application. Safe to re-run (keyed on [dadd-sub 2026-11-26] and
-- [src:dadd-quiz-sub-2026-11-26]). Check date Thu Dec 17, 2026 = 15th business day after Nov 26
-- (counts Fri Nov 27; skips weekends; no US federal holiday falls from Nov 27 through Dec 17).
begin;
do $$
declare n int;
begin
  -- partner
  if not exists (select 1 from fs_partners where id = 'e78be2ab-7724-46e8-8828-48f72e20be6b' and position('[dadd-sub 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 12:00:00-06', -- date only; submit time not recorded
      notes = coalesce(notes,'') || E'\n' || '[dadd-sub 2026-11-26] Stephen submitted the D''Addario Foundation online eligibility quiz Thu Nov 26, 2026 (time not recorded; noon CT on last_contact_at is a date placeholder). Eligibility inquiry only, not an application; eligibility not confirmed. Supersedes any earlier not-eligible or not-submitted idea about the quiz. Replaced next_step (was due ' || coalesce(next_step_due::text,'none') || '): ' || coalesce(next_step,'(none)'),
      next_step = 'Eligibility quiz SUBMITTED Thu Nov 26, 2026. WAIT for the foundation to follow up with next steps (their page: within 15 business days, if all eligibility requirements are met). On Thu Dec 17, 2026, check stephen@selassiefest.com (inbox and junk); if nothing, draft one status question (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-17',
      updated_at = now()
    where id = 'e78be2ab-7724-46e8-8828-48f72e20be6b' and updated_at = timestamptz '2026-11-03T02:02:50.403182+00:00'
      and stage is not distinct from 'not_contacted'
      and ball_with is not distinct from 'us'
      and last_contact_at is null
      and next_step is not distinct from 'Check foundation site for the next Community Music Grants window and eligibility'
      and next_step_due is not distinct from date '2027-01-11';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'D''Addario partner changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- grant: status submitted is also used for inquiries in this tracker; amount_requested stays null
  if not exists (select 1 from fs_grant_deadlines where id = 'e51fa940-be24-47ba-9b5c-e1304830f8b8' and position('[dadd-sub 2026-11-26]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      status = 'submitted',
      submitted_on = date '2026-11-26',
      owner = 'Stephen',
      notes = coalesce(notes,'') || ' | [dadd-sub 2026-11-26] ELIGIBILITY INQUIRY (online quiz) submitted Thu Nov 26, 2026; NOT an application, no amount or product requested, eligibility not yet confirmed. Status "submitted" refers to the quiz only. Answers: 501(c)(3); none of the excluded categories; hands-on instruction yes; set weekly schedule (corrects an earlier drop-in pick); 2 hours; no fees; 3 years: No; referred: No; contact Stephen Henry, stephen@selassiefest.com. The page showed "You may be eligible to apply" before submit. Confirmation: "Thank you for your submission. If you meet all of the eligibility requirements, someone from the D''Addario Foundation team will follow-up with next steps within 15 business days." Supersedes any earlier not-eligible or not-submitted idea about the quiz. Replaced next_step (was due ' || coalesce(next_step_due::text,'none') || '): ' || coalesce(next_step,'(none)'),
      next_step = 'Eligibility quiz (not an application) SUBMITTED Thu Nov 26, 2026. WAIT for the foundation''s next steps. On Thu Dec 17, 2026 (15th business day), check stephen@selassiefest.com (inbox and junk); if nothing, draft one status question (draft only; Stephen says send). Do not draft an application until invited. Owner: Stephen.',
      next_step_due = date '2026-12-17',
      updated_at = now()
    where id = 'e51fa940-be24-47ba-9b5c-e1304830f8b8' and updated_at = timestamptz '2026-10-31T19:03:50.43989+00:00'
      and status is not distinct from 'drafting'
      and submitted_on is null
      and owner is null
      and next_step_due is not distinct from date '2026-12-02'
      and position('Take the online eligibility quiz' in coalesce(next_step,'')) = 1;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'D''Addario grant changed since review (updated % rows); nothing applied', n; end if;
  end if;
end $$;

-- activity and calendar (same transaction)
do $$
begin
  if not exists (select 1 from fs_partner_activity where partner_id = 'e78be2ab-7724-46e8-8828-48f72e20be6b' and position('[src:dadd-quiz-sub-2026-11-26]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('e78be2ab-7724-46e8-8828-48f72e20be6b', 'note', 'Thu Nov 26, 2026 (time not recorded): Stephen submitted the D''Addario Foundation online eligibility quiz (https://www.daddariofoundation.org/pages/eligibility). Eligibility inquiry, not an application. Answers: 501(c)(3); none of excluded; hands-on yes; set weekly schedule; 2 hours; no fees; 3 years: No; referred: No; contact Stephen Henry, stephen@selassiefest.com. Page showed "You may be eligible to apply" before submit. Confirmation: "Thank you for your submission. If you meet all of the eligibility requirements, someone from the D''Addario Foundation team will follow-up with next steps within 15 business days." Check date Dec 17, 2026. Grant row e51fa940-be24-47ba-9b5c-e1304830f8b8. [src:dadd-quiz-sub-2026-11-26]', 'reached_out', 'stephen@selassiefest.com', 'Claude', now());
  end if;

  -- retire the Dec 2 quiz alert
  update rti_calendar_events set
      active = false,
      title = 'DONE Nov 26: D''Addario Foundation eligibility quiz submitted',
      notes = coalesce(notes,'') || ' [dadd-sub 2026-11-26: submitted Nov 26; alert retired; next check Dec 17 (dadd-check-2026-12-17)]'
    where key = 'dadd-quiz-2026-12-02' and active
      and title = 'D''Addario Foundation: take the in-kind eligibility quiz';
  if not exists (select 1 from rti_calendar_events where key = 'dadd-quiz-2026-12-02' and not active and position('[dadd-sub 2026-11-26' in coalesce(notes,'')) > 0) then
    raise exception 'calendar dadd-quiz-2026-12-02 changed since review; nothing applied';
  end if;

  -- take D'Addario out of the Jan 11 combined alert (time unchanged)
  update rti_calendar_events set
      title = 'DFSS 2027 worksite form, Design Museum nudge',
      notes = 'G 2f2e4844 DFSS; G b14b1116 Design Museum of Chicago. [dadd-sub 2026-11-26: D''Addario quiz item (G e51fa940 / P e78be2ab) removed; submitted Nov 26]'
    where key = 'jan11-followups-2027-01-11'
      and title = 'DFSS 2027 worksite form, D''Addario in-kind quiz, Design Museum nudge'
      and notes = 'G 2f2e4844 DFSS; G e51fa940 / P e78be2ab D''Addario; G b14b1116 Design Museum of Chicago.';
  if not exists (select 1 from rti_calendar_events where key = 'jan11-followups-2027-01-11' and position('[dadd-sub 2026-11-26' in coalesce(notes,'')) > 0) then
    raise exception 'calendar jan11-followups-2027-01-11 changed since review; nothing applied';
  end if;

  -- check-date reminder
  insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
  values ('dadd-check-2026-12-17', 'D''Addario Foundation: check for a reply to the eligibility quiz', timestamptz '2026-12-17 09:30:00-06', timestamptz '2026-12-17 09:45:00-06', 'Online (email)',
    '15th business day after the Nov 26 submission. Check stephen@selassiefest.com inbox and junk; if nothing, draft one status question (draft only; Stephen says send). G e51fa940 / P e78be2ab. Owner: Stephen.')
  on conflict (key) do nothing;
  if not exists (select 1 from rti_calendar_events where key = 'dadd-check-2026-12-17' and active and starts_at = timestamptz '2026-12-17 09:30:00-06') then
    raise exception 'calendar dadd-check-2026-12-17 exists with unexpected values; nothing applied';
  end if;
end $$;
commit;

select 'partner' as record, p.id::text as id, p.name, p.stage as stage_or_status, p.ball_with as ball_or_owner, p.next_step_due::text as due_or_start, p.next_step as detail,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('[src:dadd-quiz-sub-2026-11-26]' in coalesce(a.summary,'')) > 0) as activity_rows
from fs_partners p where p.id = 'e78be2ab-7724-46e8-8828-48f72e20be6b'
union all
select 'grant', g.id::text, g.funder, g.status, g.owner, g.next_step_due::text, g.next_step, null
from fs_grant_deadlines g where g.id = 'e51fa940-be24-47ba-9b5c-e1304830f8b8'
union all
select 'calendar', c.key, c.title, case when c.active then 'active' else 'inactive' end, null, c.starts_at::text, c.notes, null
from rti_calendar_events c where c.key in ('dadd-quiz-2026-12-02','jan11-followups-2027-01-11','dadd-check-2026-12-17')
order by 1, 2;

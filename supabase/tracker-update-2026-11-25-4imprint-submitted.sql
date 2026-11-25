-- 4imprint one by one application submitted Nov 25, 2026. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'submitted',
    submitted_on = date '2026-11-25',
    amount_requested = 500,
    verified_on = date '2026-11-25',
    next_step = 'SUBMITTED Nov 25, 2026 (on-screen "We have received your application"; no reference number). $500 in T-shirts for the young DJs, event date May 18, 2027. 4imprint says processing takes about 6 weeks and all applicants are then contacted; mail from onebyone@4imprint.com. If awarded, order within 30 days. Check Jan 8, 2027.',
    next_step_due = date '2027-01-08',
    notes = coalesce(notes, '') || ' | [4imprint-submitted 2026-11-25] Form https://onebyone.4imprint.com/application. Ship-to 1401 E. 71st St. Prior status to_research. One award per 12 months.',
    updated_at = now()
where id = '688e871d-3045-4895-a84b-1b67536a5fa2'
  and status = 'to_research'
  and coalesce(notes, '') not like '%[4imprint-submitted 2026-11-25]%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('4imprint-check-2027-01-08', '4imprint one by one: check for a decision',
  timestamptz '2027-01-08 09:00-06', timestamptz '2027-01-08 09:15-06', 'Online (email)',
  'Submitted Nov 25, 2026. Watch for onebyone@4imprint.com; if awarded, order within 30 days.')
on conflict (key) do nothing;

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '6e38015f-cccf-4c25-bc91-34afaa27b5c3', 'note',
 '2026-11-25 4imprint one by one application submitted online ($500 T-shirts, event May 18, 2027); on-screen receipt, no reference number. [src:4imprint-submitted-2026-11-25]',
 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', timestamptz '2026-11-25 09:42:49+00'
where not exists (select 1 from fs_partner_activity where partner_id='6e38015f-cccf-4c25-bc91-34afaa27b5c3' and summary like '%[src:4imprint-submitted-2026-11-25]%');

update fs_partners set stage='reached_out', ball_with='them',
 last_contact_at='2026-11-25 09:42:49+00',
 next_step='Application submitted Nov 25, 2026; check for 4imprint decision. If awarded, order within 30 days.',
 next_step_due=date '2027-01-08',
 notes=coalesce(notes,'')||' [src:4imprint-submitted-2026-11-25]', updated_at=now()
where id='6e38015f-cccf-4c25-bc91-34afaa27b5c3' and stage='not_contacted'
 and coalesce(notes,'') not like '%src:4imprint-submitted-2026-11-25%';

update rti_calendar_events set
 title=replace(title,' 4imprint quote under $500;',''),
 notes=replace(notes,'; P 6e38015f 4imprint.','.')
where key='asm-4imprint-2027-01-04';

do $chk$ begin
 if not exists (select 1 from fs_grant_deadlines where id='688e871d-3045-4895-a84b-1b67536a5fa2' and status='submitted' and notes like '%[4imprint-submitted 2026-11-25]%')
 or not exists (select 1 from fs_partners where id='6e38015f-cccf-4c25-bc91-34afaa27b5c3' and stage='reached_out' and notes like '%src:4imprint-submitted-2026-11-25%')
 or exists (select 1 from rti_calendar_events where key='asm-4imprint-2027-01-04' and (title||coalesce(notes,'')) ilike '%4imprint%')
 then raise exception '4imprint verification failed'; end if;
end $chk$;

commit;

select funder, status, submitted_on, amount_requested, next_step_due from fs_grant_deadlines
where id = '688e871d-3045-4895-a84b-1b67536a5fa2';

select key, starts_at, active from rti_calendar_events where key = '4imprint-check-2027-01-08';

select name, stage, ball_with, next_step_due from fs_partners where id = '6e38015f-cccf-4c25-bc91-34afaa27b5c3';

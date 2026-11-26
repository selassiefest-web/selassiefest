-- Thu Nov 26, 2026 (America/Chicago) sends from stephen@, seen in Outlook Sent Items (SENT-LOG rows 33 and 35).
-- No Message-IDs captured. Safe to re-run (keyed on the [src:...] tags below). Reviewer first, then main session applies.
-- United Way is a grant-only record (no fs_partners row), so it gets no fs_partner_activity entry.
begin;
do $$
declare n int;
begin
  perform 1 from fs_partners where id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5' for update;
  perform 1 from fs_grant_deadlines where id in ('ae12c710-6c22-4acf-8bbe-b3c6389cdd52','85bff1e5-1cc5-430b-888b-e26890c808af') for update;
  perform 1 from rti_calendar_events where key in ('nov30-followups-2026-11-30','triage-followups-2026-12-09') for update;

  -- stop if another session already logged the CCT send under a different tag
  if exists (select 1 from fs_partner_activity where partner_id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5' and kind = 'email'
      and (created_at at time zone 'America/Chicago')::date = date '2026-11-26'
      and position('[src:cct-sent-2026-11-26-1439CT]' in coalesce(summary,'')) = 0) then
    raise exception 'CCT: another Nov 26 email activity already exists; nothing applied';
  end if;

  -- CCT partner
  if not exists (select 1 from fs_partners where id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5'
                 and position('[src:cct-sent-2026-11-26-1439CT]' in coalesce(notes,'')) > 0) then
    update fs_partners set
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 14:39:00-06',
      next_step = 'Follow-up SENT Thu Nov 26, 2026 2:39 PM CT to sponsorships@cct.org (replaces the Nov 30 re-ask). WAIT for a reply; do not resend on Nov 30. If silent on Wed Dec 9, 2026, draft one nudge (draft only; Stephen says send). Online only. Owner: Stephen. (The separate grants@cct.org officer question is not logged as sent.)',
      next_step_due = date '2026-12-09',
      notes = coalesce(notes,'') || E'\n[prior next_step, replaced 2026-11-26; was due ' || coalesce(next_step_due::text,'none') || '] ' || coalesce(next_step,'')
        || E'\n[2026-11-26] Follow-up sent 2:39 PM CT to sponsorships@cct.org; no reply logged. [src:cct-sent-2026-11-26-1439CT]',
      updated_at = now()
    where id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5'
      and updated_at = timestamptz '2026-11-20T23:57:18.579696+00:00'
      and stage = 'reached_out' and ball_with = 'them' and next_step_due = date '2026-11-30';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'CCT partner changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- CCT activity
  if not exists (select 1 from fs_partner_activity where partner_id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5'
                 and position('[src:cct-sent-2026-11-26-1439CT]' in coalesce(summary,'')) > 0) then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
    values ('d576fc5a-8554-4209-9fa3-1495327d4ec5', 'email',
      'Nov 26, 2026 2:39 PM CT: email from stephen@selassiefest.com to sponsorships@cct.org, subject "Following up: 2027 sponsorship cycle for 14 free summer nights". Three questions: which 2027 cycle covers June-August, whether one application can cover a series, and the typical range; goal 300 a night. Replaces the planned Nov 30 re-ask. Seen in Outlook Sent Items. Message-ID not captured. Grant row ae12c710. [src:cct-sent-2026-11-26-1439CT]',
      'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 14:39:00-06');
  end if;

  -- CCT grant
  if not exists (select 1 from fs_grant_deadlines where id = 'ae12c710-6c22-4acf-8bbe-b3c6389cdd52'
                 and position('[src:cct-sent-2026-11-26-1439CT]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      next_step = 'Follow-up SENT Thu Nov 26, 2026 2:39 PM CT to sponsorships@cct.org (replaces the Nov 30 re-ask). WAIT for a reply; do not resend on Nov 30. If silent on Wed Dec 9, 2026, draft one nudge (draft only; Stephen says send). Online only. When they name the cycle, submit the GrantCentral answers in the packet 07-chicago-fdn-relationship\02-chicago-community-trust.md.',
      next_step_due = date '2026-12-09',
      owner = coalesce(owner,'Stephen'),
      notes = coalesce(notes,'') || E'\n[prior next_step, replaced 2026-11-26; was due ' || coalesce(next_step_due::text,'none') || '] ' || coalesce(next_step,'')
        || E'\n[2026-11-26] Follow-up SENT from stephen@ to sponsorships@cct.org at 2:39 PM CT (seen in Outlook Sent Items; Message-ID not captured). Subject: "Following up: 2027 sponsorship cycle for 14 free summer nights". Three questions: which 2027 cycle covers June-August, one application for a series, typical range; goal 300 a night. Partner row d576fc5a-8554-4209-9fa3-1495327d4ec5. No reply logged. [src:cct-sent-2026-11-26-1439CT]',
      updated_at = now()
    where id = 'ae12c710-6c22-4acf-8bbe-b3c6389cdd52'
      and updated_at = timestamptz '2026-11-25T04:56:45.144198+00:00'
      and status = 'ready' and next_step_due = date '2026-11-30';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'CCT grant changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- United Way grant (status, amount and verified flag unchanged)
  if not exists (select 1 from fs_grant_deadlines where id = '85bff1e5-1cc5-430b-888b-e26890c808af'
                 and position('[src:uw-bridgebuilders-sent-2026-11-26-1434CT]' in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      program = 'Chicago BridgeBuilders Fund (next cohort date not known)',
      url = 'https://unitedwaychicago.org/what-we-do/neighborhood-transformation/chicago-bridgebuilders-fund/application/',
      eligibility = 'Not fully verified. A page summary (outreach check, Nov 2026) reports South and West Side nonprofits with budgets under $1M; cohort 5 (2026-2027) application is closed. Confirm the rules when the next cohort is posted.',
      next_step = 'Question SENT Thu Nov 26, 2026 2:34 PM CT to CommunityImpact@uwchicago.org (next cohort date and notice list). WAIT for a reply; do not resend. If silent on Wed Dec 9, 2026, draft one nudge (draft only; Stephen says send). Online only. Do not use agencyhelp@uwchicago.org (existing agency and donation questions). Owner: Stephen.',
      next_step_due = date '2026-12-09',
      owner = coalesce(owner,'Stephen'),
      verified_on = date '2026-11-26',
      notes = coalesce(notes,'')
        || E'\n[prior next_step, replaced 2026-11-26; was due ' || coalesce(next_step_due::text,'none') || '] ' || coalesce(next_step,'')
        || E'\n[prior program, replaced 2026-11-26] ' || coalesce(program,'')
        || E'\n[prior eligibility, replaced 2026-11-26] ' || coalesce(eligibility,'')
        || E'\n[2026-11-26] Correct domain is unitedwaychicago.org (uwmetrochicago.org does not resolve); this replaces the earlier "domain did not resolve" note. The page summary reports up to $50,000 over two years and cohort 5 closed; nothing requested. Question SENT from stephen@ at 2:34 PM CT to CommunityImpact@uwchicago.org, the "Email for Questions" mailto on the fund application page, viewed Nov 26 (seen in Outlook Sent Items; Message-ID not captured). Subject: "Chicago BridgeBuilders Fund: when does the next cohort open?" Asks the next cohort date and a notice list. No reply logged. [src:uw-bridgebuilders-sent-2026-11-26-1434CT]',
      updated_at = now()
    where id = '85bff1e5-1cc5-430b-888b-e26890c808af'
      and updated_at = timestamptz '2026-11-25T18:52:51.69293+00:00'
      and status = 'to_research' and url is null and next_step_due = date '2026-12-02';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'United Way grant changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- Nov 30 alert: take CCT out so it cannot prompt a resend (other items stay)
  update rti_calendar_events set
    title = replace(title, ', CCT sponsorships', ''),
    notes = replace(coalesce(notes,''), ' G ae12c710 CCT;', '')
      || ' [2026-11-26 cct-moved: Chicago Community Trust follow-up already sent Nov 26 2:39 PM CT; moved to the Dec 9 alert; do not resend from this alert]'
  where key = 'nov30-followups-2026-11-30' and position('[2026-11-26 cct-moved:' in coalesce(notes,'')) = 0;
  if not exists (select 1 from rti_calendar_events where key = 'nov30-followups-2026-11-30'
                 and position('[2026-11-26 cct-moved:' in notes) > 0
                 and position('CCT' in title) = 0 and position('G ae12c710 CCT;' in notes) = 0) then
    raise exception 'Nov 30 calendar check failed; nothing applied';
  end if;

  -- Dec 9 alert: add both
  update rti_calendar_events set
    notes = coalesce(notes,'') || ' | Chicago Community Trust [partner d576fc5a-8554-4209-9fa3-1495327d4ec5; grant ae12c710-6c22-4acf-8bbe-b3c6389cdd52] (sent Nov 26 to sponsorships@cct.org; only if no reply: prepare one nudge draft; send only after Stephen says send)'
  where key = 'triage-followups-2026-12-09' and active and position('ae12c710-6c22-4acf-8bbe-b3c6389cdd52' in coalesce(notes,'')) = 0;
  update rti_calendar_events set
    notes = coalesce(notes,'') || ' | United Way BridgeBuilders [grant 85bff1e5-1cc5-430b-888b-e26890c808af] (sent Nov 26 to CommunityImpact@uwchicago.org; only if no reply: prepare one nudge draft; send only after Stephen says send)'
  where key = 'triage-followups-2026-12-09' and active and position('85bff1e5-1cc5-430b-888b-e26890c808af' in coalesce(notes,'')) = 0;
  if not exists (select 1 from rti_calendar_events where key = 'triage-followups-2026-12-09' and active
                 and position('ae12c710-6c22-4acf-8bbe-b3c6389cdd52' in notes) > 0
                 and position('85bff1e5-1cc5-430b-888b-e26890c808af' in notes) > 0) then
    raise exception 'Dec 9 calendar check failed; nothing applied';
  end if;

  select count(*) into n from fs_partner_activity where partner_id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5'
    and position('[src:cct-sent-2026-11-26-1439CT]' in coalesce(summary,'')) > 0;
  if n <> 1 then raise exception 'expected 1 CCT activity row, found %', n; end if;
end $$;
commit;

select 'partner' as record, p.id::text as id, p.name, p.stage as stage_or_status, p.ball_with, p.next_step_due::text as due, p.next_step as next_step_or_title,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('[src:cct-sent-2026-11-26-1439CT]' in coalesce(a.summary,'')) > 0)::text as extra
from fs_partners p where p.id = 'd576fc5a-8554-4209-9fa3-1495327d4ec5'
union all
select 'grant', g.id::text, g.funder, g.status, null, g.next_step_due::text, g.next_step, g.url
from fs_grant_deadlines g where g.id in ('ae12c710-6c22-4acf-8bbe-b3c6389cdd52','85bff1e5-1cc5-430b-888b-e26890c808af')
union all
select 'calendar', c.id::text, c.key, case when c.active then 'active' else 'inactive' end, null, (c.starts_at at time zone 'America/Chicago')::date::text, c.title, c.notes
from rti_calendar_events c where c.key in ('nov30-followups-2026-11-30','triage-followups-2026-12-09')
order by 1, 3;

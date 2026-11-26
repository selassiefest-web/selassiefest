-- Verified send, Thu Nov 26, 2026 3:04 PM CT (seen in Outlook Sent Items): stephen@selassiefest.com to dfss@cityofchicago.org.
-- Sent early as the planned fallback (Stephen's choice). Message-ID not captured; stable key [src:sent-dfss-fallback-2026-11-26-1504CT].
-- Safe to re-run.
begin;
do $$
declare
  pid  constant uuid := 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34';
  tag  constant text := '[src:sent-dfss-fallback-2026-11-26-1504CT]';
  mark constant text := '[sent-dfss-fallback 2026-11-26]';
  old_step constant text := 'Partner account request SUBMITTED Thu Nov 26, 2026 at https://partners.mychimyfuture.org. WATCH stephen@selassiefest.com for the My CHI. My Future. account email (check Tue Dec 1, 2026); also join the email list at https://cloud.citynews.chicago.gov/MCMF_email. Separately, WAIT for a reply to the 1:33 PM CT inbox email; if it bounces or is silent on Wed Dec 2, 2026, send the same question to dfss@cityofchicago.org (draft only; Stephen says send). Owner: Stephen.';
  n int;
begin
  perform 1 from fs_partners where id = pid for update;
  if not found then raise exception 'partner row not found; nothing applied'; end if;

  if not exists (select 1 from fs_partners where id = pid and position(mark in coalesce(notes,'')) > 0) then
    update fs_partners set
      next_step = 'dfss@cityofchicago.org fallback SENT Thu Nov 26, 2026 3:04 PM CT; do not resend it. Tue Dec 1, 2026: WATCH stephen@selassiefest.com for the My CHI. My Future. account email (request submitted Nov 26 at https://partners.mychimyfuture.org) and join the email list at https://cloud.citynews.chicago.gov/MCMF_email. Wed Dec 2, 2026: check for replies to BOTH inbox emails (MyCHIMyFuture@cityofchicago.org, 1:33 PM CT; dfss@cityofchicago.org, 3:04 PM CT). Owner: Stephen.',
      next_step_due = date '2026-12-01',
      last_contact_at = timestamptz '2026-11-26 15:04:00-06',
      notes = coalesce(notes,'') || E'\n[prior next_step, replaced 2026-11-26 after the dfss@ send] ' || next_step
        || E'\n' || mark || ' Fallback email to dfss@cityofchicago.org sent Nov 26, 2026 3:04 PM CT (seen in Outlook Sent Items), earlier than the planned Dec 2 condition, by Stephen''s choice. Do not resend. The send does not show delivery or receipt; no reply logged.',
      updated_at = now()
    where id = pid
      and stage = 'reached_out' and ball_with = 'them'
      and last_contact_at = timestamptz '2026-11-26 13:33:00-06'
      and next_step_due = date '2026-12-01'
      and next_step = old_step
      and updated_at = timestamptz '2026-11-26T20:31:58.819591+00:00';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'partner row changed since review (updated % rows); nothing applied', n; end if;
  end if;

  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select pid, 'email',
    'Nov 26, 2026 3:04 PM CT: Stephen sent from stephen@selassiefest.com to dfss@cityofchicago.org, subject "DFSS Youth Services: who covers 2027 Safe Spaces near Rainbow Beach?". Asked that it be passed to DFSS Youth Services; asked who the 2027 Safe Spaces delegate is near Rainbow Beach and for a direct contact; asked for a 15-minute video call. Sent early as the planned fallback to the 1:33 PM CT MCMF inbox email (Stephen''s choice). Seen in Outlook Sent Items; Message-ID not captured. ' || tag,
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 15:04:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = pid and position(tag in coalesce(summary,'')) > 0);

  select count(*) into n from fs_partner_activity where partner_id = pid and position(tag in coalesce(summary,'')) > 0;
  if n <> 1 then raise exception 'expected 1 activity row, found %', n; end if;

  -- Dec 1 watch alert: stays on Dec 1; note that the fallback is already sent
  perform 1 from rti_calendar_events where key = 'mcmf-partner-account-2026-12-01' for update;
  if not exists (select 1 from rti_calendar_events where key = 'mcmf-partner-account-2026-12-01' and position(mark in coalesce(notes,'')) > 0) then
    update rti_calendar_events set
      notes = coalesce(notes,'') || ' ' || mark || ' dfss@cityofchicago.org fallback already sent Nov 26 3:04 PM CT; do not send it again.'
    where id = '85b6cd6d-7d0f-499e-a8d0-88604ce90c54' and key = 'mcmf-partner-account-2026-12-01' and active
      and starts_at = timestamptz '2026-12-01T15:30:00+00:00';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'Dec 1 calendar guard failed (rows=%); nothing applied', n; end if;
  end if;

  -- Dec 2 reply-check alert: add both inbox emails, with the no-resend limit
  perform 1 from rti_calendar_events where key = 'blitz-followups-2026-12-02' for update;
  if not exists (select 1 from rti_calendar_events where key = 'blitz-followups-2026-12-02' and position(mark in coalesce(notes,'')) > 0) then
    update rti_calendar_events set
      notes = coalesce(notes,'') || ' ' || mark || ' Also check replies to both inbox emails on partner d6fb4185 (MyCHIMyFuture@ 1:33 PM CT; dfss@cityofchicago.org 3:04 PM CT, Nov 26). Check only: do not resend the dfss@ fallback and no dfss@ nudge from this alert.'
    where id = '40d1c4a2-691b-41c9-ac08-c8362fd3a47d' and key = 'blitz-followups-2026-12-02' and active
      and starts_at = timestamptz '2026-12-02T17:30:00+00:00';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'Dec 2 calendar guard failed (rows=%); nothing applied', n; end if;
  end if;
end $$;
commit;

select 'partner' as rec, p.name as label, p.stage || ' / ' || p.ball_with as state, p.next_step_due::text as due,
  p.last_contact_at::text as at, p.next_step as detail,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('[src:sent-dfss-fallback-2026-11-26-1504CT]' in coalesce(a.summary,'')) > 0) as activity_rows,
  position('[sent-dfss-fallback 2026-11-26]' in coalesce(p.notes,'')) > 0 as marked,
  position('[prior next_step, replaced 2026-11-26 after the dfss@ send]' in coalesce(p.notes,'')) > 0 as prior_step_kept
from fs_partners p where p.id = 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34'
union all
select 'calendar', e.key, e.active::text, e.starts_at::text, null, e.notes, null,
  position('[sent-dfss-fallback 2026-11-26]' in coalesce(e.notes,'')) > 0, null
from rti_calendar_events e where e.key in ('mcmf-partner-account-2026-12-01', 'blitz-followups-2026-12-02');

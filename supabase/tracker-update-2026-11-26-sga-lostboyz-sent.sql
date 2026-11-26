-- Two sends, Thu Nov 26, 2026 (America/Chicago), from stephen@selassiefest.com, seen in Outlook Sent Items:
--   1:36 PM to youthmicrogrants@sga-youth.org; 1:41 PM to info@lostboyzinc.org. Safe to re-run.
begin;
do $$
declare
  sga   constant uuid := 'ae2963a6-136c-4167-a2af-ae418c84b23e';
  lb    constant uuid := 'c5ea3074-9fb6-4d81-8273-401b8e6fad23';
  gr    constant uuid := '5c2eee2e-7230-49e0-951b-b5dc3c49fcec';
  stag  constant text := '[src:sent-sga-followup-2026-11-26]';
  smark constant text := '[sent-sga-followup 2026-11-26]';
  ltag  constant text := '[src:sent-lostboyz-2026-11-26]';
  lmark constant text := '[sent-lostboyz 2026-11-26]';
  n int;
begin
  perform 1 from fs_partners where id in (sga, lb) for update;
  perform 1 from fs_grant_deadlines where id = gr for update;

  -- SGA partner row
  if not exists (select 1 from fs_partners where id = sga and position(smark in coalesce(notes,'')) > 0) then
    update fs_partners set
      last_contact_at = timestamptz '2026-11-26 13:36:00-06',
      next_step = 'Follow-up on the Oct 31 question SENT Thu Nov 26, 2026 1:36 PM CT to youthmicrogrants@sga-youth.org (asks for the 2027 round notice list or a 15-minute video call). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'\n' || smark || ' Follow-up on the Oct 31 question sent Nov 26, 2026 1:36 PM CT to youthmicrogrants@sga-youth.org as a new email (seen in Outlook Sent Items). No reply logged.',
      updated_at = now()
    where id = sga
      and stage = 'reached_out' and ball_with = 'them'
      and email = 'youthmicrogrants@sga-youth.org'
      and last_contact_at = timestamptz '2026-10-31 20:00:00+00'
      and next_step_due = date '2026-11-30'
      and md5(next_step) = 'c5f16d358ffc4b55ee197db5e3e79064';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'SGA partner row changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- SGA grant row: note only (status, next_step, next_step_due 2027-01-04, amounts and decision text untouched)
  if not exists (select 1 from fs_grant_deadlines where id = gr and position(smark in coalesce(notes,'')) > 0) then
    update fs_grant_deadlines set
      notes = coalesce(notes,'') || ' | ' || smark || ' Nov 26, 2026 1:36 PM CT: Stephen sent a follow-up on the Oct 31 question to youthmicrogrants@sga-youth.org, asking to be on the notice list for a 2027 round or for a 15-minute video call. No reply logged. One nudge draft Wed Dec 2, 2026 if silent (partner row ae2963a6-136c-4167-a2af-ae418c84b23e). The watch date and ask decision on this row are unchanged.',
      updated_at = now()
    where id = gr
      and status = 'ready'
      and next_step_due = date '2027-01-04'
      and md5(next_step) = '90c0447c1169cf3fbd3f0ec83d4308ea';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'SGA grant row changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- Lost Boyz partner row
  if not exists (select 1 from fs_partners where id = lb and position(lmark in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      email = 'info@lostboyzinc.org',
      contacts = jsonb_build_array(jsonb_build_object(
        'name', 'Lost Boyz Inc. public inbox',
        'email', 'info@lostboyzinc.org',
        'role', 'Published under "Contact us" on https://www.lostboyzinc.org/gallery (checked Nov 25, 2026)')),
      last_contact_at = timestamptz '2026-11-26 13:41:00-06',
      next_step = 'Introduction SENT Thu Nov 26, 2026 1:41 PM CT to info@lostboyzinc.org (15-minute video call asked). WAIT for a reply. If silent on Wed Dec 2, 2026, draft one nudge (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || E'\n' || lmark || ' Contact found after the Nov 25 note above: info@lostboyzinc.org, published on https://www.lostboyzinc.org/gallery (site is lostboyzinc.org). Introduction sent Nov 26, 2026 1:41 PM CT (seen in Outlook Sent Items). The send does not show delivery; no reply logged. 2027 anchor role still unconfirmed.',
      updated_at = now()
    where id = lb
      and stage = 'not_contacted' and ball_with = 'us'
      and email is null and contacts = '[]'::jsonb and last_contact_at is null
      and next_step_due = date '2026-12-02'
      and md5(next_step) = '8ef8a13c68906aab6ffd23287e1f264c';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'Lost Boyz row changed since review (updated % rows); nothing applied', n; end if;
  end if;

  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select sga, 'email',
    'Nov 26, 2026 1:36 PM CT: Stephen sent from stephen@selassiefest.com to youthmicrogrants@sga-youth.org, subject "Following up: 2027 My CHI. My Future. micro-grant round". Followed up on the Oct 31 question about the micro-grants; asked to be added to the notice list for a 2027 round, with a short reply giving the expected opening window or a 15-minute video call. Sent as a new email. Seen in Outlook Sent Items; Message-ID not captured. ' || stag,
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:36:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = sga and position(stag in coalesce(summary,'')) > 0);

  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select lb, 'email',
    'Nov 26, 2026 1:41 PM CT: Stephen sent from stephen@selassiefest.com to info@lostboyzinc.org, subject "A free DJ class on the South Side: 15 minutes by video?". Introduced Ras Tafari Inc. and the free Rainbow DJ Lab opening Jan 12, 2027, and asked for a 15-minute video call to learn how young people reach Lost Boyz and whether the Lab could be one more place for them. Seen in Outlook Sent Items; Message-ID not captured. ' || ltag,
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:41:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = lb and position(ltag in coalesce(summary,'')) > 0);

  select count(*) into n from fs_partner_activity
  where (partner_id = sga and position(stag in coalesce(summary,'')) > 0)
     or (partner_id = lb and position(ltag in coalesce(summary,'')) > 0);
  if n <> 2 then raise exception 'expected 2 activity rows, found %', n; end if;
end $$;
commit;

select 'partner' as record, p.id, p.name, p.stage as stage_or_status, p.ball_with, p.email, p.last_contact_at,
  p.next_step_due, p.next_step,
  position(case p.id when 'ae2963a6-136c-4167-a2af-ae418c84b23e' then '[sent-sga-followup 2026-11-26]' else '[sent-lostboyz 2026-11-26]' end in coalesce(p.notes,'')) > 0 as note_marked,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id
     and (position('[src:sent-sga-followup-2026-11-26]' in coalesce(a.summary,'')) > 0
       or position('[src:sent-lostboyz-2026-11-26]' in coalesce(a.summary,'')) > 0)) as send_activity_rows
from fs_partners p
where p.id in ('ae2963a6-136c-4167-a2af-ae418c84b23e','c5ea3074-9fb6-4d81-8273-401b8e6fad23')
union all
select 'grant', g.id, g.funder, g.status, null, null, null, g.next_step_due, g.next_step,
  position('[sent-sga-followup 2026-11-26]' in coalesce(g.notes,'')) > 0, null
from fs_grant_deadlines g
where g.id = '5c2eee2e-7230-49e0-951b-b5dc3c49fcec'
order by 1, 2;

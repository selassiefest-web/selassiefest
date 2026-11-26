-- Verified send, Thu Nov 26, 2026 1:33 PM CT (seen in Outlook Sent Items): stephen@selassiefest.com to MyCHIMyFuture@cityofchicago.org. Safe to re-run.
begin;
do $$
declare
  dfss constant uuid := 'd6fb4185-a0c7-4e92-9384-512c9f7b0e34';
  mcmf constant uuid := 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84';
  tag  constant text := '[src:sent-mcmf-inbox-2026-11-26]';
  mark constant text := '[sent-mcmf-inbox 2026-11-26]';
  n int;
begin
  perform 1 from fs_partners where id in (dfss, mcmf) for update;

  -- DFSS public inbox row: only from the expected current state
  if not exists (select 1 from fs_partners where id = dfss and position(mark in coalesce(notes,'')) > 0) then
    update fs_partners set
      stage = 'reached_out',
      ball_with = 'them',
      last_contact_at = timestamptz '2026-11-26 13:33:00-06',
      next_step = 'SENT Thu Nov 26, 2026 1:33 PM CT from stephen@selassiefest.com. WAIT for a reply from MyCHIMyFuture@cityofchicago.org. If it bounces, or is silent on Wed Dec 2, 2026, send the same question to dfss@cityofchicago.org (draft only; Stephen says send). Owner: Stephen.',
      next_step_due = date '2026-12-02',
      notes = coalesce(notes,'') || ' | ' || mark || ' Email sent to this inbox Nov 26, 2026 1:33 PM CT (seen in Outlook Sent Items). The send does not verify the address or show delivery; no reply logged.',
      updated_at = now()
    where id = dfss
      and stage = 'not_contacted' and ball_with = 'us' and last_contact_at is null
      and next_step_due = date '2026-11-25'
      and md5(next_step) = '29d41f37c7a939e0a5647b0f8624a7fe';
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'DFSS inbox row changed since review (updated % rows); nothing applied', n; end if;
  end if;

  -- Companion MCMF referral row: note only (stage, next step, due date, last contact unchanged)
  if not exists (select 1 from fs_partners where id = mcmf and position(mark in coalesce(notes,'')) > 0) then
    update fs_partners set
      notes = coalesce(notes,'') || ' | ' || mark || ' Stephen also asked the My CHI. My Future. public inbox (row d6fb4185-a0c7-4e92-9384-512c9f7b0e34) on Nov 26, 2026 1:33 PM CT who the 2027 Safe Spaces delegate serving Rainbow Beach is, and for a DFSS Youth Services contact and citywide partner meeting invitations. No reply logged.',
      updated_at = now()
    where id = mcmf;
    get diagnostics n = row_count;
    if n <> 1 then raise exception 'MCMF row not found (updated % rows); nothing applied', n; end if;
  end if;

  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
  select dfss, 'email',
    'Nov 26, 2026 1:33 PM CT: Stephen sent from stephen@selassiefest.com to MyCHIMyFuture@cityofchicago.org (no cc), subject "Rainbow DJ Lab: who is the 2027 Safe Spaces delegate for Rainbow Beach?". Said Deputy Mayor Humphries pointed us to the team after the Nov 25 meeting; described the free Rainbow DJ Lab opening Jan 12, 2027, with deck https://selassiefest.com/full-spectrum/mayor/. Asked who the 2027 Safe Spaces delegate serving Rainbow Beach is, and for a direct DFSS Youth Services contact, citywide partner meeting invitations and a 15-minute video call. Seen in Outlook Sent Items; Message-ID not captured. ' || tag,
    'reached_out', 'stephen@selassiefest.com', 'Claude', timestamptz '2026-11-26 13:33:00-06'
  where not exists (select 1 from fs_partner_activity where partner_id = dfss and position(tag in coalesce(summary,'')) > 0);

  select count(*) into n from fs_partner_activity where partner_id = dfss and position(tag in coalesce(summary,'')) > 0;
  if n <> 1 then raise exception 'expected 1 activity row, found %', n; end if;
end $$;
commit;

select p.id, p.name, p.stage, p.ball_with, p.last_contact_at, p.next_step_due, p.next_step,
  position('[sent-mcmf-inbox 2026-11-26]' in coalesce(p.notes,'')) > 0 as note_marked,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('[src:sent-mcmf-inbox-2026-11-26]' in coalesce(a.summary,'')) > 0) as send_activity_rows
from fs_partners p
where p.id in ('d6fb4185-a0c7-4e92-9384-512c9f7b0e34','e0b74f53-8ac6-4d91-b245-6fc03b0a4d84')
order by p.id;

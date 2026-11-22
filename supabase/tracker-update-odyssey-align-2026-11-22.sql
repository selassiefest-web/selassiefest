-- Nov 22, 2026: align the Odyssey grant row and partner row (steward proposal; reviewed before apply). Safe to re-run (guarded on the old due dates).
begin;

-- Grant row 95fcca73
update fs_grant_deadlines
set next_step = 'Add one sentence to our next Serato email (the Nov 25 nudge, or the reply when the account is set up) asking Brad D for the right Odyssey contact (Odyssey is the exclusive US Serato distributor); then send the booth request to that contact. Online only. Packet 02-gear-audio/06-odyssey.md. Booth line depends on the Joyce swap decision.',
    next_step_due = '2026-11-25',
    notes = notes || E'\n2026-11-22 [aligned with partner row 43075ae7] odysseygear.com has no contact form (/general/, /contact, /support all 404; footer "General" is unlinked text). Route is the Serato thread, ball with us to add the intro sentence; Serato''s open item is unchanged (Brad D to confirm the account name and add the software; ball with Serato). Due 2026-11-25 is our own follow-up date (the Serato nudge), not an Odyssey commitment. Fallback if no name by 2026-12-08: DM @odysseygear on Instagram.'
where id = '95fcca73-11d4-4d8d-afdd-0420c2382c7a'
  and next_step_due = '2026-11-24'
  and notes not like '%[aligned with partner row 43075ae7]%';

-- Partner row 43075ae7
update fs_partners
set next_step = 'Add one sentence to our next Serato email (the Nov 25 nudge, or the reply when the account is set up) asking Brad D for the right Odyssey contact (Odyssey is the exclusive US Serato distributor); then send the booth request to that contact. Online only. Packet 02-gear-audio/06-odyssey.md. Booth line depends on the Joyce swap decision.',
    next_step_due = '2026-11-25',
    ball_with = 'us',
    website = 'https://www.odysseygear.com/',
    notes = notes || E'\n[2026-11-22 aligned with grant row 95fcca73] The old step ("use the Odyssey general contact form") is wrong: https://www.odysseygear.com/general/ is a 404 and the site shows no contact, sponsorship or donation route. Route is the Serato thread. Due 2026-11-25 is our own follow-up date, not a partner commitment. Fallback if no Odyssey name by 2026-12-08: DM @odysseygear on Instagram. No outreach to Odyssey has happened yet.'
where id = '43075ae7-1438-49c8-80e5-d6319b69ae31'
  and next_step_due = '2026-12-08'
  and notes not like '%[2026-11-22 aligned with grant row 95fcca73]%';

commit;

select 'grant' as src, id::text, status, next_step_due::text, left(next_step, 70) as next_step, (notes like '%aligned with partner row 43075ae7%') as noted
  from fs_grant_deadlines where id = '95fcca73-11d4-4d8d-afdd-0420c2382c7a'
union all
select 'partner', id::text, stage, next_step_due::text, left(next_step, 70), (notes like '%aligned with grant row 95fcca73%')
  from fs_partners where id = '43075ae7-1438-49c8-80e5-d6319b69ae31';

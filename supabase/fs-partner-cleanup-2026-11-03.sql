-- Full Spectrum partner tracker cleanup, built Nov 3, 2026 from a read-only audit of all 516 fs_partners rows.
-- REVIEW FIRST. Nothing here has been applied. Apply with:
--   supabase db query --linked -f supabase/fs-partner-cleanup-2026-11-03.sql
-- Apply supabase/fs-partner-ball-with.sql FIRST (it adds ball_with and the stage trigger this file relies on). Safe to re-run.
-- Deliberately NOT touched: the 10 overseas gear vendors (CURRENT-STATUS.md item 8 says nothing was sent,
-- the tracker says reached_out Nov 1; Stephen must say which is true), Shure/Benevity commitment text,
-- Purple Turtle stage, South Shore Chamber CDC vs Chamber of Commerce, "empress" tags.

begin;

-- A. (Item 1, ball_with field + backfill) lives in supabase/fs-partner-ball-with.sql. APPLY THAT FILE FIRST.

-- ============================================================================
-- B. Item 2: 87 rows still say not_contacted but their own next step says a letter
--    was hand-delivered / emailed ("Wave 2 letter 10/19", "corridor walk", "79th Street walk").
--    The activity log has only 'note' entries for them, so the stage is the thing that is wrong.
--    last_contact_at is left empty (the real delivery date is not recorded).
--    Skips any row already moved. Each change writes a 'stage' activity row for the audit trail.
-- ============================================================================
create temp table _b2 on commit drop as
  select id from fs_partners
  where stage = 'not_contacted'
    and next_step ~* '(hand-delivered|emailed|Wave 2 letter)'
    and next_step !~* '^deliver';
update fs_partners set stage = 'reached_out', updated_at = now() where id in (select id from _b2);
-- the stage trigger from the ball-with file set these to "them"; a follow-up already due is our move
update fs_partners set ball_with = 'us' where id in (select id from _b2) and next_step_due is not null and next_step_due <= current_date;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  select id, 'stage', 'Stage corrected to reached_out in the Nov 3 cleanup: next step already recorded a delivered or emailed letter.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
  from _b2;

-- ============================================================================
-- C. Item 3: rewrite stale next-step text that still quotes Oct dates ("follow up 10/26").
--    Due dates are NOT changed (they were re-dated Nov 2). Roland is skipped (silent until Wed Nov 4).
-- ============================================================================
update fs_partners set next_step = 'Letter hand-delivered on the Oct walk. No reply logged yet. Follow up on the Nov 6 to 8 walk.', updated_at = now()
  where next_step in ('Letter hand-delivered on the corridor walk; follow up 10/26',
                      '79th Street walk: letter hand-delivered; follow up 10/26')
    and name !~* 'roland';
update fs_partners set next_step = 'Wave 2 letter sent Oct 19. No reply logged yet. Follow up by phone.', updated_at = now()
  where next_step = 'Wave 2 letter 10/19; follow up by phone 10/26';
update fs_partners set next_step = 'Letter hand-delivered or emailed Oct 19. No reply logged yet. Follow up by phone.', updated_at = now()
  where next_step = 'Letter hand-delivered or emailed 10/19; follow up by phone 10/26';
update fs_partners set next_step = 'Letter hand-delivered to CPD HQ Oct 19. No reply logged yet. Follow up by phone.', updated_at = now()
  where next_step = 'Letter hand-delivered to CPD HQ 10/19; follow up by phone 10/26';
update fs_partners set next_step = 'Follow-up emailed Oct 26. No reply logged. Call.', updated_at = now()
  where next_step = 'Follow-up emailed 10/26; call if no reply' and name !~* 'roland';
update fs_partners set next_step = 'Follow-up emailed Oct 28. No reply logged. Call.', updated_at = now()
  where next_step = 'Follow-up emailed 10/28; call if no reply' and name !~* 'roland';

-- ============================================================================
-- D. Item 5: log the Oct 31 / Nov 2 touches that never reached the activity log.
--    Source: legal/documents-inbox/CURRENT-STATUS.md. Skips a partner that already has the marker.
-- ============================================================================
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, v.kind, v.summary || ' (logged retroactively in the Nov 3 cleanup)', p.stage, 'stephen@selassiefest.com', 'Stephen Henry', v.at::timestamptz
from (values
  ('Archer Daniels Midland%',          'email', 'Sponsorship request sent to sponsorships@adm.com', '2026-10-31 12:00-05'),
  ('LPMC Foundation%',                 'email', '$15,000 request emailed',                           '2026-10-31 12:00-05'),
  ('My CHI. My Future. Micro-Grants%', 'email', 'Inquiry emailed to SGA Youth & Family Services',    '2026-10-31 12:00-05'),
  ('Siragusa Family Foundation%',      'email', 'Inquiry emailed',                                   '2026-10-31 12:00-05'),
  ('SocialWorks%',                     'email', 'Inquiry emailed',                                   '2026-10-31 12:00-05'),
  ('Target - GiftCards%',              'visit', 'Paperwork delivered to Hyde Park Target (HR took it, contact Sherese) and 71st & Cicero Target (left with a clerk for HR)', '2026-11-02 12:00-06')
) as v(pat, kind, summary, at)
join fs_partners p on p.name ilike v.pat
where not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%logged retroactively in the Nov 3 cleanup%');

-- ============================================================================
-- E. Item 7: the one clear duplicate. Field Foundation is two rows; the reached_out row is the live one.
--    Nothing is deleted. Obama x2 stay as they are (on_hold, dropped) and are marked parked below.
-- ============================================================================
update fs_partners set stage = 'on_hold',
       next_step = 'DUPLICATE: use the row "Field Foundation of Illinois (A Road Together)". Do not work this one.',
       next_step_due = null, updated_at = now()
  where name = 'Field Foundation / MacArthur - A Road Together' and stage = 'not_contacted';

-- ============================================================================
-- G. Checks (read these after applying; they print as the last result)
-- ============================================================================
select 'ball_with counts' as check, coalesce(ball_with,'(unset)') as k, count(*)::text as n from fs_partners group by ball_with
union all select 'stage counts', stage, count(*)::text from fs_partners group by stage
union all select 'still-stale October text', 'rows', count(*)::text from fs_partners where next_step ~* 'follow up (by phone )?10/2[0-9]|emailed 10/2[0-9]'
union all select 'reached_out with no activity', 'rows', count(*)::text from fs_partners p where stage = 'reached_out' and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id)
union all select 'ball_with null (should be 0 except confirmed)', 'rows', count(*)::text from fs_partners where ball_with is null and stage <> 'confirmed'
order by 1, 2;


commit;

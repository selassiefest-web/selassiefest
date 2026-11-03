-- Full Spectrum partner tracker cleanup, built Nov 3, 2026 from a read-only audit of all 516 fs_partners rows.
-- REVIEW FIRST. Nothing here has been applied. Apply with:
--   supabase db query --linked -f supabase/fs-partner-cleanup-2026-11-03.sql
-- Run ONCE. Sections A-E are safe to repeat, but section F re-derives ball_with from scratch and would overwrite hand-set values.
-- Deliberately NOT touched: the 10 overseas gear vendors (CURRENT-STATUS.md item 8 says nothing was sent,
-- the tracker says reached_out Nov 1; Stephen must say which is true), Shure/Benevity commitment text,
-- Purple Turtle stage, South Shore Chamber CDC vs Chamber of Commerce, "empress" tags.

begin;

-- ============================================================================
-- A. NEW FIELD: ball_with = who owns the next move (item 1)
--    us        our move (not yet contacted, or follow-up is due now)
--    them      we reached out, waiting for their answer
--    cpd_hold  parked until CPD gives the GO for Full Spectrum (Stephen, Nov 2)
--    parked    dropped / do not contact / duplicate / unverified / revisit much later
--    null      not set (committed and confirmed rows, set by hand)
-- ============================================================================
alter table fs_partners add column if not exists ball_with text;
alter table fs_partners drop constraint if exists fs_partners_ball_with_check;
alter table fs_partners add constraint fs_partners_ball_with_check
  check (ball_with is null or ball_with in ('us','them','cpd_hold','parked'));

-- Staff save: same as fs-partner-asks.sql plus ball_with.
create or replace function fs_partner_save(p_session uuid, p_id uuid, p jsonb)
returns fs_partners language plpgsql security definer set search_path = public as $$
declare u record; r fs_partners; v_old_stage text;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_id is null then
    insert into fs_partners (name, category, source) values (coalesce(nullif(trim(p->>'name'),''),'Untitled partner'), coalesce(nullif(p->>'category',''),'Other'), coalesce(p->>'source','Added by '||u.v_name))
    returning * into r;
    p_id := r.id;
  end if;
  select stage into v_old_stage from fs_partners where id = p_id;
  update fs_partners set
    name            = case when p ? 'name' then coalesce(nullif(trim(p->>'name'),''), name) else name end,
    category        = case when p ? 'category' then coalesce(nullif(p->>'category',''), category) else category end,
    address         = case when p ? 'address' then nullif(trim(p->>'address'),'') else address end,
    phone           = case when p ? 'phone' then nullif(trim(p->>'phone'),'') else phone end,
    email           = case when p ? 'email' then nullif(trim(p->>'email'),'') else email end,
    website         = case when p ? 'website' then nullif(trim(p->>'website'),'') else website end,
    contacts        = case when p ? 'contacts' then coalesce(p->'contacts','[]'::jsonb) else contacts end,
    partner_types   = case when p ? 'partner_types' then array(select jsonb_array_elements_text(p->'partner_types')) else partner_types end,
    program_parts   = case when p ? 'program_parts' then array(select jsonb_array_elements_text(p->'program_parts')) else program_parts end,
    stage           = case when p ? 'stage' then p->>'stage' else stage end,
    ball_with       = case when p ? 'ball_with' then nullif(p->>'ball_with','') else ball_with end,
    ask             = case when p ? 'ask' then nullif(trim(p->>'ask'),'') else ask end,
    ask_items       = case when p ? 'ask_items' then coalesce(p->'ask_items','[]'::jsonb) else ask_items end,
    ask_intro       = case when p ? 'ask_intro' then nullif(trim(p->>'ask_intro'),'') else ask_intro end,
    pitch           = case when p ? 'pitch' then nullif(trim(p->>'pitch'),'') else pitch end,
    commitment      = case when p ? 'commitment' then nullif(trim(p->>'commitment'),'') else commitment end,
    commitment_value= case when p ? 'commitment_value' then nullif(p->>'commitment_value','')::numeric else commitment_value end,
    next_step       = case when p ? 'next_step' then nullif(trim(p->>'next_step'),'') else next_step end,
    next_step_due   = case when p ? 'next_step_due' then nullif(p->>'next_step_due','')::date else next_step_due end,
    hours_note      = case when p ? 'hours_note' then nullif(trim(p->>'hours_note'),'') else hours_note end,
    notes           = case when p ? 'notes' then nullif(trim(p->>'notes'),'') else notes end,
    updated_at      = now()
  where id = p_id
  returning * into r;
  if p ? 'stage' and v_old_stage is distinct from r.stage then
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
    values (r.id, 'stage', 'Stage changed to ' || r.stage, r.stage, u.v_email, u.v_name);
  end if;
  return r;
end;
$$;
grant execute on function fs_partner_save(uuid, uuid, jsonb) to anon, authenticated;

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
-- F. Backfill ball_with (rules run in order; later rules override earlier ones)
-- ============================================================================
-- 1) by stage
update fs_partners set ball_with = 'us' where stage = 'not_contacted';
update fs_partners set ball_with = case when next_step_due is not null and next_step_due <= date '2026-11-03' then 'us' else 'them' end
  where stage in ('reached_out','in_conversation','meeting_set');
update fs_partners set ball_with = 'parked' where stage in ('declined','not_qualified');
-- 2) on_hold: site-visit / find-a-contact rows are our move; the rest are parked
update fs_partners set ball_with = 'parked' where stage = 'on_hold';
update fs_partners set ball_with = 'us' where stage = 'on_hold'
  and name in ('Barry Technologies','Faith Chapel Deliverance Center','M&R Prescription','South Chicago Chamber of Commerce','South Shore Works (South Shore Planning and Preservation Coalition)','Taste of Chicago 2');
-- 3) CPD hold: no sends to these until CPD gives the GO (CURRENT-STATUS.md, Nov 2)
update fs_partners set ball_with = 'cpd_hold'
  where name ilike 'First Presbyterian Church of Chicago%'
     or name ilike 'Mile Square Health Center%'
     or name ilike 'Avalon Regal Theater%'
     or name ilike 'Chicago Park District Community Stewardship Program%';
-- 4) Purple Turtle: Tamera has the deck; check back Wed Nov 4, nothing beyond the meeting request
update fs_partners set ball_with = 'them' where name ilike 'The Purple Turtle%';
-- 5) dropped / do not contact
update fs_partners set ball_with = 'parked'
  where name in ('Obama Foundation','Obama Foundation / Obama Presidential Center','Rainbow Beach Park Advisory Council');

create index if not exists fs_partners_ball_idx on fs_partners (ball_with);

commit;

-- ============================================================================
-- G. Checks (read these after applying; they print as the last result)
-- ============================================================================
select 'ball_with counts' as check, coalesce(ball_with,'(unset)') as k, count(*)::text as n from fs_partners group by ball_with
union all select 'stage counts', stage, count(*)::text from fs_partners group by stage
union all select 'still-stale October text', 'rows', count(*)::text from fs_partners where next_step ~* 'follow up (by phone )?10/2[0-9]|emailed 10/2[0-9]'
union all select 'reached_out with no activity', 'rows', count(*)::text from fs_partners p where stage = 'reached_out' and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id)
union all select 'ball_with null on non-committed', 'rows', count(*)::text from fs_partners where ball_with is null and stage not in ('committed','confirmed')
order by 1, 2;


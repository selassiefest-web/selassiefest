-- Tracker item 1 (Nov 2, 2026): "who has the ball". Adds fs_partners.ball_with so the tracker can show held / waiting.
--   us        our move (not yet contacted, a reply to answer, or a follow-up is due)
--   them      we reached out, waiting on their answer
--   cpd_hold  nothing goes out until CPD gives the GO for Full Spectrum (Stephen, Nov 2)
--   parked    dropped / do not contact / duplicate / not qualified / revisit much later
--   null      not set (confirmed rows)
-- Apply FIRST, before supabase/fs-partner-cleanup-2026-11-03.sql:
--   supabase db query --linked -f supabase/fs-partner-ball-with.sql
-- Run it once: the backfill in step 5 re-derives every ball_with and would overwrite values set by hand afterwards.
-- The page (full-spectrum/partners.html) already reads and writes the field; it fails to save
-- until this runs because fs_partner_save does not know ball_with yet.

begin;

-- 1) Column + allowed values
alter table fs_partners add column if not exists ball_with text;
alter table fs_partners drop constraint if exists fs_partners_ball_with_check;
alter table fs_partners add constraint fs_partners_ball_with_check
  check (ball_with is null or ball_with in ('us','them','cpd_hold','parked'));
create index if not exists fs_partners_ball_idx on fs_partners (ball_with);

-- 2) Staff save: identical to the live function plus ball_with (and a note in the activity log when staff change it by hand)
create or replace function fs_partner_save(p_session uuid, p_id uuid, p jsonb)
returns fs_partners language plpgsql security definer set search_path = public as $$
declare u record; r fs_partners; v_old_stage text; v_old_ball text;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_id is null then
    insert into fs_partners (name, category, source) values (coalesce(nullif(trim(p->>'name'),''),'Untitled partner'), coalesce(nullif(p->>'category',''),'Other'), coalesce(p->>'source','Added by '||u.v_name))
    returning * into r;
    p_id := r.id;
  end if;
  select stage, ball_with into v_old_stage, v_old_ball from fs_partners where id = p_id;
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
  if v_old_ball is distinct from r.ball_with and v_old_stage is not distinct from r.stage then
    insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
    values (r.id, 'note', 'Ball with: ' || coalesce(r.ball_with, 'not set'), u.v_email, u.v_name);
  end if;
  return r;
end;
$$;
grant execute on function fs_partner_save(uuid, uuid, jsonb) to anon, authenticated;

-- 3) Keep it current automatically. Whenever a stage changes (Log button, edit form, a partner's pitch-page answer,
--    a signed support letter) and nobody set ball_with in the same update, move the ball to match the new stage.
--    A CPD hold survives stage changes back to not_contacted / on_hold, so the hold is never lost by accident.
create or replace function fs_partners_ball_auto() returns trigger language plpgsql as $$
begin
  if tg_op = 'UPDATE' and (new.stage is not distinct from old.stage or new.ball_with is distinct from old.ball_with) then
    return new;
  end if;
  if tg_op = 'INSERT' and new.ball_with is not null then return new; end if;
  if tg_op = 'UPDATE' and old.ball_with = 'cpd_hold' and new.stage in ('not_contacted','on_hold') then return new; end if;
  new.ball_with := case new.stage
    when 'not_contacted'   then 'us'
    when 'reached_out'     then 'them'
    when 'in_conversation' then 'us'
    when 'meeting_set'     then 'them'
    when 'committed'       then 'us'
    when 'confirmed'       then null
    else 'parked'            -- declined, on_hold, not_qualified
  end;
  return new;
end;
$$;
drop trigger if exists fs_partners_ball_auto_trg on fs_partners;
create trigger fs_partners_ball_auto_trg before insert or update of stage on fs_partners
  for each row execute function fs_partners_ball_auto();

-- 4) Unverified businesses leave on_hold: they are our move (go and confirm they exist / are open), not parked.
--    Their next steps already say "visit / confirm / find a contact before any outreach". Stage becomes not_contacted;
--    the trigger above sets ball_with = us. Obama x2, Rainbow Beach PAC, HAMOC, NNA, SEBCA, SSA #42 stay on hold.
update fs_partners set stage = 'not_contacted', updated_at = now()
where stage = 'on_hold' and name in ('Barry Technologies','Faith Chapel Deliverance Center','M&R Prescription',
      'South Chicago Chamber of Commerce','Taste of Chicago 2','South Shore Works (South Shore Planning and Preservation Coalition)');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select p.id, 'stage', 'Moved out of on hold to not contacted: unverified, so the next move is ours (confirm it exists before any outreach). Tracker item 1.', 'not_contacted', 'stephen@selassiefest.com', 'Stephen Henry'
from fs_partners p
where p.name in ('Barry Technologies','Faith Chapel Deliverance Center','M&R Prescription','South Chicago Chamber of Commerce','Taste of Chicago 2','South Shore Works (South Shore Planning and Preservation Coalition)')
  and p.stage = 'not_contacted'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Moved out of on hold to not contacted:%');

-- 5) Backfill every row (rules run in order, later ones override earlier ones)
update fs_partners set ball_with = 'us'     where stage = 'not_contacted';
update fs_partners set ball_with = case when next_step_due is not null and next_step_due <= current_date then 'us' else 'them' end
  where stage in ('reached_out','meeting_set');
update fs_partners set ball_with = 'us'     where stage in ('in_conversation','committed');
update fs_partners set ball_with = null     where stage = 'confirmed';
update fs_partners set ball_with = 'parked' where stage in ('declined','not_qualified','on_hold');
-- CPD hold: no sends until CPD gives the GO
update fs_partners set ball_with = 'cpd_hold'
  where name ilike 'First Presbyterian Church of Chicago%'
     or name ilike 'Mile Square Health Center%'
     or name ilike 'Avalon Regal Theater%'
     or name ilike 'Chicago Park District Community Stewardship Program%';
-- Purple Turtle: the deck is with them, check back Wed Nov 4
update fs_partners set ball_with = 'them' where name ilike 'The Purple Turtle%';
-- Do not contact / dropped
update fs_partners set ball_with = 'parked'
  where name in ('Obama Foundation','Obama Foundation / Obama Presidential Center','Rainbow Beach Park Advisory Council');

-- 6) Checks (printed last): every row has a value except confirmed; the six businesses are now "us"
select 'ball_with by stage' as check, stage || ' / ' || coalesce(ball_with,'(unset)') as k, count(*)::text as n from fs_partners group by stage, ball_with
union all select 'rows with no ball (should be confirmed only)', stage, count(*)::text from fs_partners where ball_with is null group by stage
union all select 'still on hold', name || ' / ' || coalesce(ball_with,'(unset)'), '1' from fs_partners where stage = 'on_hold'
union all select 'cpd_hold rows', name, '1' from fs_partners where ball_with = 'cpd_hold'
order by 1, 2;

commit;

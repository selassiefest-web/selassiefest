-- ─────────────────────────────────────────────────────────────────────────
-- Itemized asks for each partner's personal page (/partner/?k=<pitch_key>).
-- Each partner can carry a short menu of specific things to give (13 meals
-- for Lesson 1, a beginner DJ controller, a pair of turntables, ...). The
-- partner ticks what they will provide, adjusts quantities, and sends it
-- with their yes / call-me / not-now answer. Selections ride along on
-- fs_partner_responses; the apply trigger logs them on the partner's
-- activity and, for a "yes", fills in the commitment and its value.
--
-- ask_items: [{"id":"food-01","label":"Sponsor Lesson 1 meals",
--              "detail":"13 student meals for one lesson","qty":13,
--              "unit":"meals","value":0}, ...]
-- (value = estimated dollar value per unit, optional.)
--
-- Apply with: supabase db query --linked -f supabase/fs-partner-asks.sql
-- Safe to re-run. fs_partner_save below supersedes the copy in
-- full-spectrum-partners.sql (which has the same ask_items clause).
-- ─────────────────────────────────────────────────────────────────────────
alter table fs_partners add column if not exists ask_items jsonb not null default '[]'::jsonb;
alter table fs_partners add column if not exists ask_intro text;   -- optional one-line welcome above the menu
alter table fs_partner_responses add column if not exists selections jsonb;

-- Public read: now includes the item menu. Return type changed, so drop first.
drop function if exists fs_pitch_view(text);
create or replace function fs_pitch_view(p_key text)
returns table (name text, pitch text, ask text, program_parts text[], ask_items jsonb, ask_intro text)
language plpgsql security definer set search_path = public as $$
begin
  update fs_partners p set pitch_views = p.pitch_views + 1, pitch_last_viewed = now()
  where p.pitch_key = p_key;
  return query select p.name, p.pitch, p.ask, p.program_parts, p.ask_items, p.ask_intro from fs_partners p where p.pitch_key = p_key;
end;
$$;
grant execute on function fs_pitch_view(text) to anon, authenticated;

-- Staff save: same as before plus ask_items / ask_intro.
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

-- Answer trigger: same behavior as before, plus the ticked items. Quantities
-- and values come from the public form, so they are clamped and the
-- commitment text is plain text built here, never trusted markup.
create or replace function fs_partner_response_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare p fs_partners; v_stage text; v_label text; v_sel text := ''; v_total numeric := 0; s jsonb; v_qty numeric; v_val numeric;
begin
  select * into p from fs_partners where pitch_key = new.pitch_key;
  if p.id is null then return new; end if;

  if jsonb_typeof(new.selections) = 'array' then
    for s in select * from jsonb_array_elements(new.selections) loop
      v_qty := least(greatest(coalesce(nullif(s->>'qty','')::numeric, 1), 0), 100000);
      -- value is looked up from the partner's own menu, not trusted from the form
      v_val := coalesce((select nullif(i->>'value','')::numeric from jsonb_array_elements(p.ask_items) i where i->>'id' = s->>'id' limit 1), 0);
      v_total := v_total + v_qty * v_val;
      v_sel := v_sel || case when v_sel = '' then '' else '; ' end ||
               left(coalesce(s->>'label', s->>'id', 'item'), 120) || ' x' || trim(to_char(v_qty, 'FM999999990.##'));
    end loop;
  end if;

  v_label := case new.decision when 'yes' then 'YES, count us in' when 'call_me' then 'Call me, I have questions' else 'Not right now' end;
  v_stage := case
    when new.decision = 'yes' and p.stage in ('not_contacted','reached_out','in_conversation','meeting_set','on_hold') then 'committed'
    when new.decision = 'call_me' and p.stage in ('not_contacted','reached_out','on_hold') then 'in_conversation'
    when new.decision = 'not_now' and p.stage in ('not_contacted','reached_out') then 'on_hold'
    else null end;
  update fs_partners set
    stage = coalesce(v_stage, stage),
    last_contact_at = now(),
    next_step = case when new.decision in ('yes','call_me') then 'Call ' || coalesce(nullif(new.contact_name,''), 'them') || ' back (answered the pitch page)' else next_step end,
    next_step_due = case when new.decision in ('yes','call_me') then current_date + 2 else next_step_due end,
    commitment = case when new.decision = 'yes' and v_sel <> '' then v_sel else commitment end,
    commitment_value = case when new.decision = 'yes' and v_sel <> '' and v_total > 0 then v_total else commitment_value end,
    contacts = case when coalesce(nullif(new.contact_name,''), nullif(new.phone,''), nullif(new.email,'')) is null then contacts
                    else contacts || jsonb_build_array(jsonb_strip_nulls(jsonb_build_object('name', nullif(new.contact_name,''), 'role', nullif(new.contact_title,''),
                                                                                         'email', nullif(new.email,''), 'phone', nullif(new.phone,'')))) end,
    updated_at = now()
  where id = p.id;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  values (p.id, 'note', 'Pitch page answer: ' || v_label ||
            coalesce(' from ' || nullif(new.contact_name,''), '') || coalesce(' (' || nullif(new.contact_title,'') || ')', '') ||
            coalesce('. Phone ' || nullif(new.phone,''), '') || coalesce('. Email ' || nullif(new.email,''), '') ||
            case when v_sel <> '' then '. Chose: ' || v_sel else '' end ||
            coalesce('. "' || nullif(new.message,'') || '"', ''),
          v_stage, 'pitch-page', 'Pitch page');
  return new;
end;
$$;

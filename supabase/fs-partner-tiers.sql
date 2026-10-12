-- ─────────────────────────────────────────────────────────────────────────
-- Tiered in-kind items on partner pages: an ask_items entry with
-- "tiers": true lets the partner choose, per item,
--   sponsor  = 100% sponsorship (they provide it at no cost)
--   rw       = Rainbow Wednesday price (below their regular price)
--   regular  = regular price (so staff can budget)
-- and type their regular price and RW price per unit. Selections carry
-- {tier, regular, rw}; this replaces the answer trigger from
-- fs-partner-asks.sql so the activity log and commitment value reflect them:
--   sponsor value = qty x regular      (the gift)
--   rw value      = qty x (regular - rw)  (the community discount)
-- Prices come from the public form, so every number is clamped; they are
-- the partner's own declaration and only inform the commitment note.
-- Apply with: supabase db query --linked -f supabase/fs-partner-tiers.sql
-- Safe to re-run. Requires fs-partner-asks.sql.
-- ─────────────────────────────────────────────────────────────────────────
create or replace function fs_partner_response_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare p fs_partners; v_stage text; v_label text; v_sel text := ''; v_total numeric := 0; s jsonb;
        v_qty numeric; v_val numeric; v_reg numeric; v_rw numeric; v_tier text; v_part text;
begin
  select * into p from fs_partners where pitch_key = new.pitch_key;
  if p.id is null then return new; end if;

  if jsonb_typeof(new.selections) = 'array' then
    for s in select * from jsonb_array_elements(new.selections) loop
      v_qty := least(greatest(coalesce(nullif(s->>'qty','')::numeric, 1), 0), 100000);
      v_tier := s->>'tier';
      v_part := left(coalesce(s->>'label', s->>'id', 'item'), 120) || ' x' || trim(to_char(v_qty, 'FM999999990.##'));
      if v_tier in ('sponsor','rw','regular') then
        v_reg := least(greatest(coalesce(nullif(s->>'regular','')::numeric, 0), 0), 100000);
        v_rw  := least(greatest(coalesce(nullif(s->>'rw','')::numeric, 0), 0), 100000);
        if v_tier = 'sponsor' then
          v_total := v_total + v_qty * v_reg;
          v_part := v_part || ' [100% sponsored' || case when v_reg > 0 then ', regular $' || trim(to_char(v_reg, 'FM999999990.##')) || ' each' else '' end || ']';
        elsif v_tier = 'rw' then
          v_total := v_total + v_qty * greatest(v_reg - v_rw, 0);
          v_part := v_part || ' [Rainbow Wednesday price' || case when v_rw > 0 then ' $' || trim(to_char(v_rw, 'FM999999990.##')) || ' each' else '' end ||
                    case when v_reg > 0 then ' vs regular $' || trim(to_char(v_reg, 'FM999999990.##')) else '' end || ']';
        else
          v_part := v_part || ' [regular price' || case when v_reg > 0 then ' $' || trim(to_char(v_reg, 'FM999999990.##')) || ' each' else '' end || ']';
        end if;
      else
        -- value is looked up from the partner's own menu, not trusted from the form
        v_val := coalesce((select nullif(i->>'value','')::numeric from jsonb_array_elements(p.ask_items) i where i->>'id' = s->>'id' limit 1), 0);
        v_total := v_total + v_qty * v_val;
      end if;
      v_sel := v_sel || case when v_sel = '' then '' else '; ' end || v_part;
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

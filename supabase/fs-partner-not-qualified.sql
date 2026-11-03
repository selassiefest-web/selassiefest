-- Full Spectrum partners: a "Not qualified yet" stage (not_qualified) for funders whose
-- rules we don't meet yet (e.g. a program must have run a year). Not a decline, not a pause:
-- revisit when we qualify. Like on_hold, a pitch-page "yes"/"call me" or a signed letter of
-- support still advances it. The digest's due list now also shows on_hold rows that carry a
-- due date (e.g. site visits to confirm a closure). Apply: supabase db query --linked -f this file.
alter table fs_partners drop constraint if exists fs_partners_stage_check;
alter table fs_partners add constraint fs_partners_stage_check
  check (stage in ('not_contacted','reached_out','in_conversation','meeting_set','committed','confirmed','declined','on_hold','not_qualified'));

CREATE OR REPLACE FUNCTION public.fs_partner_response_apply()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    when new.decision = 'yes' and p.stage in ('not_contacted','reached_out','in_conversation','meeting_set','on_hold','not_qualified') then 'committed'
    when new.decision = 'call_me' and p.stage in ('not_contacted','reached_out','on_hold','not_qualified') then 'in_conversation'
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
$function$
;

CREATE OR REPLACE FUNCTION public.fs_support_letter_apply()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
declare p fs_partners;
begin
  if new.pitch_key is null then return new; end if;
  select * into p from fs_partners where pitch_key = new.pitch_key;
  if p.id is null then return new; end if;
  update fs_partners set
    stage = case when stage in ('not_contacted','reached_out','in_conversation','meeting_set','on_hold','not_qualified') then 'committed' else stage end,
    commitment = case when coalesce(commitment,'') ilike '%letter of support%' then commitment
                      else concat_ws('; ', nullif(commitment,''), 'Letter of support signed') end,
    last_contact_at = now(),
    next_step = 'Thank ' || new.signer_name || ' for the letter of support',
    next_step_due = current_date + 2,
    updated_at = now()
  where id = p.id;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  values (p.id, 'note', 'Letter of support signed by ' || new.signer_name || coalesce(', ' || nullif(new.signer_title,''), '') ||
          ' (' || new.org_name || '). See the Letters tab for the signed copy.', 'committed', 'support-letter', 'Support letter');
  return new;
end;
$function$
;

CREATE OR REPLACE FUNCTION public.fs_partners_digest()
 RETURNS jsonb
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
  select jsonb_build_object(
    'due', coalesce((select jsonb_agg(jsonb_build_object('name',name,'stage',stage,'next_step',next_step,'due',next_step_due) order by next_step_due)
                     from fs_partners where next_step_due is not null and next_step_due <= current_date + 7
                       and stage not in ('confirmed','declined','not_qualified')), '[]'::jsonb),
    'stale', coalesce((select jsonb_agg(jsonb_build_object('name',name,'stage',stage,'last',last_contact_at) order by last_contact_at)
                     from fs_partners where stage in ('reached_out','in_conversation','meeting_set','committed')
                       and (last_contact_at is null or last_contact_at < now() - interval '14 days')), '[]'::jsonb),
    'counts', coalesce((select jsonb_object_agg(stage, n) from (select stage, count(*) n from fs_partners group by stage) s), '{}'::jsonb),
    'total', (select count(*) from fs_partners)
  );
$function$
;

update fs_partners set stage = 'not_qualified', updated_at = now()
where name = 'Guitar Center Music Foundation' and stage = 'on_hold';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'stage', 'Moved from on hold to the new "Not qualified yet" stage: grants need a program running 1+ year with weekly instruction 8+ months a year. Revisit after the DJ Lab''s first year (Jan 2028).', 'not_qualified', 'stephen@selassiefest.com', 'Stephen Henry'
from fs_partners where name = 'Guitar Center Music Foundation';

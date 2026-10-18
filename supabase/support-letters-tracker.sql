-- ===========================================================================
-- Letters of support <-> Full Spectrum partner tracker (2026-10-18).
-- A letter written from a partner's page (/support-letter/?k=<pitch_key>)
-- carries that key. On insert, the letter is logged on the partner's record
-- and the partner moves to "committed". The tracker's Letters tab lists every
-- letter with a staff link to the printable signed copy.
-- ===========================================================================
alter table public.support_letters add column if not exists pitch_key text;
alter table public.support_letters add column if not exists staff_token text;   -- raw view token, read only through fs_support_letters_load

create or replace function fs_support_letter_apply() returns trigger
language plpgsql security definer set search_path = public as $$
declare p fs_partners;
begin
  if new.pitch_key is null then return new; end if;
  select * into p from fs_partners where pitch_key = new.pitch_key;
  if p.id is null then return new; end if;
  update fs_partners set
    stage = case when stage in ('not_contacted','reached_out','in_conversation','meeting_set','on_hold') then 'committed' else stage end,
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
$$;

drop trigger if exists support_letters_apply on public.support_letters;
create trigger support_letters_apply after insert on public.support_letters
  for each row execute function fs_support_letter_apply();

create or replace function fs_support_letters_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', l.id, 'created_at', l.created_at, 'letter_date', l.letter_date, 'org_name', l.org_name,
      'signer_name', l.signer_name, 'signer_title', l.signer_title, 'email', l.email, 'phone', l.phone,
      'programs', l.programs, 'why', l.why, 'commitment', l.commitment, 'public_ok', l.public_ok, 'status', l.status,
      'pitch_key', l.pitch_key, 'partner', p.name,
      'link', case when l.staff_token is not null then 'https://selassiefest.com/support-letter/view/?t=' || l.staff_token end)
    order by l.created_at desc)
    from support_letters l left join fs_partners p on p.pitch_key = l.pitch_key
    where l.status <> 'hidden'), '[]'::jsonb);
end;
$$;
grant execute on function fs_support_letters_load(uuid) to anon, authenticated;

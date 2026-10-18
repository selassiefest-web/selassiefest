-- ===========================================================================
-- Outgoing partner letters for the Full Spectrum tracker (2026-10-18).
-- Each printable letter (one-page HTML with QR codes) is stored here so the
-- tracker's Letters tab can print it in one click and record delivery.
-- Letters are loaded out of band from Claude outputs/partner-letters/.
-- ===========================================================================
create table if not exists fs_partner_letters (
  id            uuid primary key default gen_random_uuid(),
  partner_id    uuid references fs_partners(id) on delete cascade,
  wave          text not null,                 -- e.g. 'establishment-2026-10-19'
  sort          int not null default 0,        -- delivery route order
  addressee     text not null,
  street        text,
  title         text not null,
  html          text not null,                 -- full printable page
  emailed_to    text,                          -- set when the letter also went by email
  status        text not null default 'to_print' check (status in ('to_print','printed','delivered','emailed_only')),
  delivered_at  timestamptz,
  delivered_note text,
  created_at    timestamptz not null default now(),
  unique (wave, title)
);
alter table fs_partner_letters enable row level security;
comment on table fs_partner_letters is 'Printable outgoing letters for the Full Spectrum tracker Letters tab. Read and written only through session-checked functions.';

create or replace function fs_partner_letters_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return coalesce((select jsonb_agg(jsonb_build_object(
      'id', l.id, 'wave', l.wave, 'sort', l.sort, 'addressee', l.addressee, 'street', l.street, 'title', l.title,
      'html', l.html, 'emailed_to', l.emailed_to, 'status', l.status, 'delivered_at', l.delivered_at,
      'delivered_note', l.delivered_note, 'partner', p.name, 'partner_id', l.partner_id)
    order by l.wave, l.sort)
    from fs_partner_letters l left join fs_partners p on p.id = l.partner_id), '[]'::jsonb);
end;
$$;
grant execute on function fs_partner_letters_load(uuid) to anon, authenticated;

-- Mark a letter printed or delivered; delivery is logged on the partner's record.
create or replace function fs_partner_letter_mark(p_session uuid, p_id uuid, p_status text, p_note text default null)
returns void language plpgsql security definer set search_path = public as $$
declare u record; l fs_partner_letters;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_status not in ('to_print','printed','delivered') then raise exception 'bad status'; end if;
  update fs_partner_letters set status = p_status,
    delivered_at = case when p_status = 'delivered' then now() else null end,
    delivered_note = case when p_status = 'delivered' then nullif(left(trim(coalesce(p_note,'')), 300), '') else delivered_note end
  where id = p_id returning * into l;
  if p_status = 'delivered' and l.partner_id is not null then
    update fs_partners set stage = case when stage = 'not_contacted' then 'reached_out' else stage end, last_contact_at = now(), updated_at = now() where id = l.partner_id;
    insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
    values (l.partner_id, 'note', 'Letter hand-delivered' || coalesce(': left with ' || nullif(trim(coalesce(p_note,'')), ''), '') || '.', 'reached_out', u.v_email, u.v_name);
  end if;
end;
$$;
grant execute on function fs_partner_letter_mark(uuid, uuid, text, text) to anon, authenticated;

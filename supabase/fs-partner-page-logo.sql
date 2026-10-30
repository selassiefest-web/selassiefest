-- Partner page logo: show a partner's own logo at the top of /partner/?k=<pitch_key>, only once they give permission.
-- page_logo_url: the image to show (defaults to the logo they sent for their flyer, flyer->>'logo_url').
-- page_logo_ok: staff tick this in the tracker when the partner says we may use their logo. Until then the page shows their name only.
alter table fs_partners add column if not exists page_logo_url text;
alter table fs_partners add column if not exists page_logo_ok boolean not null default false;
alter table fs_partners add column if not exists page_logo_ok_at timestamptz;

-- Public read: adds logo_url, which is null unless permission is on. Return type changed, so drop first.
drop function if exists fs_pitch_view(text);
create or replace function fs_pitch_view(p_key text)
returns table (name text, pitch text, ask text, program_parts text[], ask_items jsonb, ask_intro text, logo_url text)
language plpgsql security definer set search_path = public as $$
begin
  update fs_partners p set pitch_views = p.pitch_views + 1, pitch_last_viewed = now()
  where p.pitch_key = p_key;
  return query select p.name, p.pitch, p.ask, p.program_parts, p.ask_items, p.ask_intro,
    case when p.page_logo_ok then coalesce(p.page_logo_url, p.flyer->>'logo_url') end
  from fs_partners p where p.pitch_key = p_key;
end;
$$;
grant execute on function fs_pitch_view(text) to anon, authenticated;

-- Tracker: set the page logo and the permission switch.
create or replace function fs_partner_logo_save(p_session uuid, p_partner uuid, p_url text, p_ok boolean)
returns void language plpgsql security definer set search_path = public as $$
declare u record; r fs_partners; v_url text := nullif(trim(p_url), '');
begin
  select * into u from fs_partner_session_user(p_session);
  select * into r from fs_partners where id = p_partner;
  if r.id is null then raise exception 'partner not found'; end if;
  if v_url is not null and v_url !~* '^https://' then raise exception 'the logo link must start with https://'; end if;
  if p_ok and coalesce(v_url, r.flyer->>'logo_url') is null then raise exception 'add their logo before turning it on'; end if;
  if v_url is not distinct from r.page_logo_url and p_ok = r.page_logo_ok then return; end if;
  update fs_partners set page_logo_url = v_url, page_logo_ok = p_ok,
    page_logo_ok_at = case when p_ok and not r.page_logo_ok then now() when not p_ok then null else r.page_logo_ok_at end,
    updated_at = now()
  where id = r.id;
  insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
  values (r.id, 'note', case when p_ok and not r.page_logo_ok then 'Logo permission given: their logo now shows on their page'
                             when not p_ok and r.page_logo_ok then 'Logo taken off their page'
                             else 'Page logo updated' end, u.v_email, u.v_name);
end;
$$;
grant execute on function fs_partner_logo_save(uuid, uuid, text, boolean) to anon, authenticated;

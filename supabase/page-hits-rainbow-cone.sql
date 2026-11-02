-- Add the Rainbow Cone deck to the allowed pages of track_hit (Nov 2, 2026).
-- Same function as supabase/page-hits.sql with one more path. Apply with:
--   supabase db query --linked -f supabase/page-hits-rainbow-cone.sql
create or replace function track_hit(p_page text, p_src text default 'direct', p_event text default 'view', p_ref text default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  if p_page not in ('/full-spectrum/give/','/full-spectrum/rainbow-cone/') then return; end if;
  if p_event not in ('view','play','cta') then return; end if;
  insert into page_hits (page, src, event, ref_host)
  values (p_page,
          case when p_src ~ '^[a-z0-9_-]{1,40}$' then p_src else 'direct' end,
          p_event,
          nullif(left(regexp_replace(coalesce(p_ref,''), '^https?://([^/]+).*$', '\1'), 80), ''));
end $$;
revoke all on function track_hit(text,text,text,text) from public;
grant execute on function track_hit(text,text,text,text) to anon, authenticated;

-- Own-system tracking for QR codes and shared links (no third party, no cookies, no IP stored).
-- A page calls track_hit(page, src, event); src comes from the link, e.g. /full-spectrum/give/?src=flyer.
-- Base table is locked down (RLS on, no policies): anon can only call the function, never read.
-- Read the counts yourself with:  supabase db query --linked "select * from page_hit_summary"
-- Apply with: supabase db query --linked -f supabase/page-hits.sql

create table if not exists page_hits (
  id bigint generated always as identity primary key,
  page text not null,
  src text not null default 'direct',
  event text not null default 'view' check (event in ('view','play','cta')),
  ref_host text,
  created_at timestamptz not null default now()
);
alter table page_hits enable row level security;
revoke all on page_hits from anon, authenticated;

create or replace function track_hit(p_page text, p_src text default 'direct', p_event text default 'view', p_ref text default null)
returns void language plpgsql security definer set search_path = public as $$
begin
  -- only known paths, tidy src values, known events: keeps junk out of an open endpoint
  if p_page not in ('/full-spectrum/give/') then return; end if;
  if p_event not in ('view','play','cta') then return; end if;
  insert into page_hits (page, src, event, ref_host)
  values (p_page,
          case when p_src ~ '^[a-z0-9_-]{1,40}$' then p_src else 'direct' end,
          p_event,
          nullif(left(regexp_replace(coalesce(p_ref,''), '^https?://([^/]+).*$', '\1'), 80), ''));
end $$;
revoke all on function track_hit(text,text,text,text) from public;
grant execute on function track_hit(text,text,text,text) to anon, authenticated;

-- Owner-only summary (not exposed to anon): views, plays and CTA clicks per page, per source, per day.
create or replace view page_hit_summary with (security_invoker = true) as
select page, src, created_at::date as day,
       count(*) filter (where event = 'view') as views,
       count(*) filter (where event = 'play') as plays,
       count(*) filter (where event = 'cta')  as cta_clicks
from page_hits group by 1,2,3 order by 3 desc, 1, 2;
revoke all on page_hit_summary from anon, authenticated;

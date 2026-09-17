-- Deadline reminders for the Opportunity Tracker's Deadline Calendar sheet
-- (/bbpac/organization/opportunity-tracker.html). Same shape as the
-- pre-existing deadlines_due_for_reminder() / send-deadline-reminders
-- pattern elsewhere in this file, just with 7/2/1-day lead times instead of
-- 14/7, and reading bbpac_tracker_items instead of the separate `deadlines`
-- table -- kept as its own function/cron/Edge Function rather than
-- generalizing the existing one, since changing that one's lead times would
-- also change the cadence for its own (unrelated) SelassieFest deadlines.

-- The sheet's dates live inside `fields` as {"label":"Date","value":"YYYY-MM-DD"}
-- (some rows use "ROLLING" or "2026-10-late" instead of an exact date, which
-- can't be reminded on) -- this column is the parsed-out, reminder-ready
-- version, populated once here and kept current by bbpac_tracker_seed.sql
-- re-running the same extraction whenever the register is refreshed.
alter table bbpac_tracker_items add column if not exists deadline_date date;

update bbpac_tracker_items
set deadline_date = (
  select (elem->>'value')::date
  from jsonb_array_elements(fields) elem
  where elem->>'label' = 'Date' and elem->>'value' ~ '^\d{4}-\d{2}-\d{2}$'
  limit 1
)
where sheet = 'deadline_calendar';

-- Returns every deadline exactly 7, 2 or 1 days from today -- run daily,
-- this fires each reminder exactly once per deadline with no separate
-- "already sent" tracking needed, so long as the cron job runs every day
-- (same reasoning as deadlines_due_for_reminder() above). Uses the
-- database's current_date (UTC on Supabase), same day-level-imprecision
-- tradeoff as that function too.
create or replace function public.bbpac_tracker_deadlines_due_for_reminder()
returns table (
  id uuid, title text, link text, deadline_date date, lead_days int,
  date_basis text, why text
)
language sql
security definer
set search_path = ''
stable
as $$
  select
    i.id, i.title, i.link, i.deadline_date,
    (i.deadline_date - current_date)::int as lead_days,
    (select elem->>'value' from jsonb_array_elements(i.fields) elem where elem->>'label' = 'Date basis' limit 1) as date_basis,
    (select elem->>'value' from jsonb_array_elements(i.fields) elem where elem->>'label' = 'Why it matters / action' limit 1) as why
  from public.bbpac_tracker_items i
  where i.sheet = 'deadline_calendar'
    and i.deadline_date is not null
    and (i.deadline_date - current_date) in (7, 2, 1)
  order by i.deadline_date;
$$;

revoke all on function public.bbpac_tracker_deadlines_due_for_reminder() from public, anon, authenticated;
grant execute on function public.bbpac_tracker_deadlines_due_for_reminder() to service_role;

-- The pg_cron schedule that drives this daily is applied directly against
-- the live project, not reproduced here (embeds the
-- send-bbpac-tracker-deadline-reminders Edge Function's URL and its
-- BBPAC_TRACKER_REMINDER_SECRET, neither of which belongs in git) -- same
-- pattern as send-deadline-reminders above. If it ever needs to be
-- recreated: `select cron.schedule('bbpac-tracker-deadline-reminders',
-- '0 13 * * *', $$ select net.http_post(url :=
-- '<send-bbpac-tracker-deadline-reminders URL>', headers :=
-- jsonb_build_object('Content-Type', 'application/json', 'x-webhook-secret',
-- '<BBPAC_TRACKER_REMINDER_SECRET>'), body := '{}'::jsonb) $$);` -- runs
-- daily at 13:00 UTC (~7-8am Chicago, depending on DST).

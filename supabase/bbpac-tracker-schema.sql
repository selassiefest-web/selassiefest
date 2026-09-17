-- ─────────────────────────────────────────────────────────────────────────
-- BBPAC Opportunity Tracker (/bbpac/organization/opportunity-tracker.html) --
-- a shared, volunteer-editable status board over the CPD Opportunity
-- Register (deadlines, CPD partnership routes, funders, contacts, open
-- questions). Same lightweight magic-link pattern as BIOS102
-- (bios102_students / bios102_login_links): a volunteer requests a link,
-- gets it by email, and clicking it is what proves they control that
-- address. bbpac_tracker_volunteers is seeded out of band via the SQL
-- editor (Stephen adding volunteer emails as they join the effort), never
-- committed here, same as bios102_students.
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists bbpac_tracker_volunteers (
  email text primary key,
  display_name text not null,
  created_at timestamptz not null default now()
);

alter table bbpac_tracker_volunteers enable row level security;
-- Deliberately zero policies -- readable only via the SQL editor/service
-- role and through the security-definer functions below.

create or replace function bbpac_tracker_is_volunteer(p_email text)
returns boolean
language sql
security definer
set search_path = public
stable
as $$
  select exists (
    select 1 from bbpac_tracker_volunteers where lower(email) = lower(trim(p_email))
  );
$$;

grant execute on function bbpac_tracker_is_volunteer(text) to anon;

-- Each row is both the emailed magic-link token (while status = 'pending')
-- and, once clicked, the ongoing session token the browser keeps in
-- localStorage (status = 'active') -- identical shape to
-- bios102_login_links. anon can only ever INSERT here; the roster check
-- happens in the RLS policy itself via bbpac_tracker_is_volunteer.
create table if not exists bbpac_tracker_login_links (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  status text not null default 'pending' check (status in ('pending', 'active')),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 minutes')
);

alter table bbpac_tracker_login_links enable row level security;

create policy "anon can request a tracker login link if a known volunteer" on bbpac_tracker_login_links
  for insert to anon
  with check (bbpac_tracker_is_volunteer(email));

create index if not exists bbpac_tracker_login_links_email_idx on bbpac_tracker_login_links (lower(email));

-- Sends the actual email -- see notify-submission/index.ts's
-- formatBbpacTrackerLoginLink + TABLE_CONFIG entry for bbpac_tracker_login_links.
drop trigger if exists bbpac_tracker_login_links_notify on bbpac_tracker_login_links;
create trigger bbpac_tracker_login_links_notify
  after insert on bbpac_tracker_login_links
  for each row execute function notify_submission_webhook();

create or replace function bbpac_tracker_verify_login_link(p_token uuid)
returns table (session_token uuid, email text, display_name text)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
begin
  select v.email into v_email
  from bbpac_tracker_login_links l
  join bbpac_tracker_volunteers v on lower(v.email) = lower(l.email)
  where l.id = p_token
    and (l.status = 'active' or (l.status = 'pending' and l.expires_at > now()));

  if v_email is null then
    return;
  end if;

  update bbpac_tracker_login_links set status = 'active' where id = p_token and status <> 'active';

  return query
    select p_token, v.email, v.display_name
    from bbpac_tracker_volunteers v
    where lower(v.email) = lower(v_email);
end;
$$;

grant execute on function bbpac_tracker_verify_login_link(uuid) to anon;

-- The register itself, imported from the xlsx (see bbpac-tracker-seed.sql).
-- `fields` holds the sheet-specific reference columns as an ordered
-- [{label, value}] array so one table covers five differently-shaped
-- sheets without five differently-shaped tables. `track_status` is OUR
-- volunteer-progress field, distinct from any "Status" column already in
-- the source data (which describes the opportunity's own state, e.g. "Open,
-- rolling") -- that original status lives inside `fields` like everything
-- else from the sheet. Publicly readable: none of this is sensitive, and
-- volunteers need to browse it before they've ever logged in.
create table if not exists bbpac_tracker_items (
  id uuid primary key default gen_random_uuid(),
  sheet text not null check (sheet in ('deadline_calendar', 'cpd_opportunities', 'funders', 'contacts', 'verify_manually')),
  sort_order int not null,
  title text not null,
  link text,
  fields jsonb not null default '[]'::jsonb,
  track_status text not null default 'not_started' check (track_status in ('not_started', 'in_progress', 'submitted', 'done', 'blocked', 'not_applicable')),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (sheet, sort_order)
);

alter table bbpac_tracker_items enable row level security;

create policy "anyone can read tracker items" on bbpac_tracker_items
  for select to anon
  using (true);

create index if not exists bbpac_tracker_items_sheet_idx on bbpac_tracker_items (sheet, sort_order);

-- Append-only activity log per item -- every volunteer's update adds a row
-- instead of overwriting one shared note field, so two volunteers working
-- the same opportunity a week apart both keep their account of what
-- happened. Also publicly readable for the same reason as the items table.
create table if not exists bbpac_tracker_updates (
  id uuid primary key default gen_random_uuid(),
  item_id uuid not null references bbpac_tracker_items(id) on delete cascade,
  status text not null check (status in ('not_started', 'in_progress', 'submitted', 'done', 'blocked', 'not_applicable')),
  note text,
  volunteer_email text not null,
  volunteer_name text not null,
  created_at timestamptz not null default now()
);

alter table bbpac_tracker_updates enable row level security;

create policy "anyone can read tracker updates" on bbpac_tracker_updates
  for select to anon
  using (true);

create index if not exists bbpac_tracker_updates_item_idx on bbpac_tracker_updates (item_id, created_at desc);

-- The only way to change track_status or add a note -- validates the
-- session itself (same pattern as bios102_save_table) rather than trusting
-- an email the client hands over, so nobody can post updates under another
-- volunteer's name just by knowing their address.
drop function if exists bbpac_tracker_add_update(uuid, uuid, text, text);

create or replace function bbpac_tracker_add_update(
  p_session uuid,
  p_item_id uuid,
  p_status text,
  p_note text
)
returns setof bbpac_tracker_updates
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text;
  v_name text;
begin
  select v.email, v.display_name into v_email, v_name
  from bbpac_tracker_login_links l
  join bbpac_tracker_volunteers v on lower(v.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';

  if v_email is null then
    raise exception 'invalid or expired tracker session';
  end if;

  update bbpac_tracker_items
    set track_status = p_status, updated_at = now()
    where id = p_item_id;

  return query
    insert into bbpac_tracker_updates (item_id, status, note, volunteer_email, volunteer_name)
    values (p_item_id, p_status, nullif(trim(p_note), ''), v_email, v_name)
    returning *;
end;
$$;

grant execute on function bbpac_tracker_add_update(uuid, uuid, text, text) to anon;

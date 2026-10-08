-- ─────────────────────────────────────────────────────────────────────────
-- Full Spectrum Partner Tracker (/full-spectrum/partners.html) -- Stephen's
-- private pipeline for bringing partners on board for Full Spectrum at
-- Rainbow Beach: in-kind, financial, strategic programming, and marketing &
-- promotion partners. First list came from the Rainbow Beach park
-- supervisor (South Shore community resources, Oct 2026).
--
-- Unlike the BBPAC Opportunity Tracker, NOTHING here is publicly readable:
-- partner rows carry contact names, phones and emails. All three tables
-- have RLS on and zero policies; the page reads and writes only through the
-- security-definer functions below, each of which re-validates the
-- magic-link session token. The roster (fs_partner_users) and the partner
-- rows themselves are seeded out of band via the SQL editor, never
-- committed here (this file is served publicly with the rest of the repo).
--
-- Sign-in: same magic-link pattern as bbpac_tracker_login_links -- the
-- insert policy checks the roster, and notify-submission emails the link
-- (formatFsPartnerLoginLink + TABLE_CONFIG entry).
-- ─────────────────────────────────────────────────────────────────────────
create table if not exists fs_partner_users (
  email text primary key,
  display_name text not null,
  created_at timestamptz not null default now()
);
alter table fs_partner_users enable row level security;

create or replace function fs_partner_is_user(p_email text)
returns boolean language sql security definer set search_path = public stable as $$
  select exists (select 1 from fs_partner_users where lower(email) = lower(trim(p_email)));
$$;
grant execute on function fs_partner_is_user(text) to anon, authenticated;

create table if not exists fs_partner_login_links (
  id uuid primary key default gen_random_uuid(),
  email text not null,
  status text not null default 'pending' check (status in ('pending', 'active')),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 minutes')
);
alter table fs_partner_login_links enable row level security;
drop policy if exists "known user can request a partner tracker login link" on fs_partner_login_links;
create policy "known user can request a partner tracker login link" on fs_partner_login_links
  for insert to anon, authenticated
  with check (fs_partner_is_user(email));
create index if not exists fs_partner_login_links_email_idx on fs_partner_login_links (lower(email));

drop trigger if exists fs_partner_login_links_notify on fs_partner_login_links;
create trigger fs_partner_login_links_notify
  after insert on fs_partner_login_links
  for each row execute function notify_submission_webhook();

create or replace function fs_partner_verify_login_link(p_token uuid)
returns table (session_token uuid, email text, display_name text)
language plpgsql security definer set search_path = public as $$
declare v_email text;
begin
  select u.email into v_email
  from fs_partner_login_links l
  join fs_partner_users u on lower(u.email) = lower(l.email)
  where l.id = p_token
    and (l.status = 'active' or (l.status = 'pending' and l.expires_at > now()));
  if v_email is null then return; end if;
  update fs_partner_login_links set status = 'active' where id = p_token and status <> 'active';
  return query select p_token, u.email, u.display_name from fs_partner_users u where lower(u.email) = lower(v_email);
end;
$$;
grant execute on function fs_partner_verify_login_link(uuid) to anon, authenticated;

-- Internal: resolve a session token to the signed-in user, or raise.
create or replace function fs_partner_session_user(p_session uuid, out v_email text, out v_name text)
language plpgsql security definer set search_path = public stable as $$
begin
  select u.email, u.display_name into v_email, v_name
  from fs_partner_login_links l
  join fs_partner_users u on lower(u.email) = lower(l.email)
  where l.id = p_session and l.status = 'active';
  if v_email is null then raise exception 'invalid or expired partner tracker session'; end if;
end;
$$;
revoke all on function fs_partner_session_user(uuid) from public, anon, authenticated;

-- The pipeline itself. partner_types / program_parts are small fixed
-- vocabularies kept as text[] so one partner can be several kinds at once.
create table if not exists fs_partners (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  category text not null default 'Other',
  address text,
  phone text,
  email text,
  website text,
  contacts jsonb not null default '[]'::jsonb,      -- [{name, role, email, phone}]
  partner_types text[] not null default '{}',        -- in_kind | financial | programming | marketing
  program_parts text[] not null default '{}',        -- classes | wednesdays | stage | festivals | parties | empress | all
  stage text not null default 'not_contacted'
    check (stage in ('not_contacted','reached_out','in_conversation','meeting_set','committed','confirmed','declined','on_hold')),
  ask text,                                          -- what we plan to ask them for
  commitment text,                                   -- what they've agreed to give
  commitment_value numeric(10,2),                    -- cash or in-kind value, if known
  next_step text,
  next_step_due date,
  hours_note text,
  source text,
  notes text,
  last_contact_at timestamptz,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table fs_partners enable row level security;
create index if not exists fs_partners_stage_idx on fs_partners (stage, next_step_due);

create table if not exists fs_partner_activity (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references fs_partners(id) on delete cascade,
  kind text not null check (kind in ('call','email','visit','meeting','text','note','stage')),
  summary text,
  stage_after text,
  by_email text not null,
  by_name text not null,
  created_at timestamptz not null default now()
);
alter table fs_partner_activity enable row level security;
create index if not exists fs_partner_activity_partner_idx on fs_partner_activity (partner_id, created_at desc);

-- Read everything the page needs in one call.
create or replace function fs_partners_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return jsonb_build_object(
    'partners', coalesce((select jsonb_agg(to_jsonb(p) order by p.category, p.name) from fs_partners p), '[]'::jsonb),
    'activity', coalesce((select jsonb_agg(to_jsonb(a) order by a.created_at desc) from fs_partner_activity a), '[]'::jsonb)
  );
end;
$$;
grant execute on function fs_partners_load(uuid) to anon, authenticated;

-- Create (p_id null) or update a partner from a jsonb of editable fields.
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

-- Log a touch (call, email, visit...) and optionally move the stage and set
-- the next step in the same breath -- the everyday action on the page.
create or replace function fs_partner_log(p_session uuid, p_partner uuid, p_kind text, p_summary text,
                                          p_stage text default null, p_next_step text default null, p_next_due date default null)
returns fs_partner_activity language plpgsql security definer set search_path = public as $$
declare u record; a fs_partner_activity;
begin
  select * into u from fs_partner_session_user(p_session);
  update fs_partners set
    stage = coalesce(nullif(p_stage,''), stage),
    next_step = case when p_next_step is not null then nullif(trim(p_next_step),'') else next_step end,
    next_step_due = case when p_next_step is not null then p_next_due else next_step_due end,
    last_contact_at = case when p_kind in ('call','email','visit','meeting','text') then now() else last_contact_at end,
    updated_at = now()
  where id = p_partner;
  insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
  values (p_partner, p_kind, nullif(trim(p_summary),''), nullif(p_stage,''), u.v_email, u.v_name)
  returning * into a;
  return a;
end;
$$;
grant execute on function fs_partner_log(uuid, uuid, text, text, text, text, date) to anon, authenticated;

create or replace function fs_partner_delete(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  delete from fs_partners where id = p_id;
end;
$$;
grant execute on function fs_partner_delete(uuid, uuid) to anon, authenticated;

-- Weekly digest source (service_role only): next steps due within 7 days or
-- overdue, active partners with no contact in 14+ days, and stage counts.
create or replace function fs_partners_digest()
returns jsonb language sql security definer set search_path = public stable as $$
  select jsonb_build_object(
    'due', coalesce((select jsonb_agg(jsonb_build_object('name',name,'stage',stage,'next_step',next_step,'due',next_step_due) order by next_step_due)
                     from fs_partners where next_step_due is not null and next_step_due <= current_date + 7
                       and stage not in ('confirmed','declined','on_hold')), '[]'::jsonb),
    'stale', coalesce((select jsonb_agg(jsonb_build_object('name',name,'stage',stage,'last',last_contact_at) order by last_contact_at)
                     from fs_partners where stage in ('reached_out','in_conversation','meeting_set','committed')
                       and (last_contact_at is null or last_contact_at < now() - interval '14 days')), '[]'::jsonb),
    'counts', coalesce((select jsonb_object_agg(stage, n) from (select stage, count(*) n from fs_partners group by stage) s), '{}'::jsonb),
    'total', (select count(*) from fs_partners)
  );
$$;
revoke all on function fs_partners_digest() from public, anon, authenticated;
grant execute on function fs_partners_digest() to service_role;

-- The weekly pg_cron job (Mondays ~8am Chicago) that calls the
-- send-fs-partner-digest Edge Function is applied directly to the live
-- project, not reproduced here: it embeds the function URL and its
-- FS_PARTNER_DIGEST_SECRET. Recreate with cron.schedule('fs-partner-digest',
-- '0 13 * * 1', $$ select net.http_post(url := '<function URL>', headers :=
-- jsonb_build_object('Content-Type','application/json','x-webhook-secret',
-- '<FS_PARTNER_DIGEST_SECRET>'), body := '{}'::jsonb) $$);

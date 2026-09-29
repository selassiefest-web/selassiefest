-- ─────────────────────────────────────────────────────────────────────────
-- South Shore Cultural Center Advisory Council -- Bylaws Revision Workspace
-- (/sscc-bylaws/). A subcommittee works through the bylaws as proposals:
-- each proposal targets one section (amend / add after / delete) or just
-- flags an issue, gets discussed in comments, and the chair accepts,
-- rejects, defers, or resolves it. Accepting an amend/add/delete applies it
-- to the working draft right away; the chair then "cuts" a numbered version
-- that snapshots the draft and records which accepted proposals it contains.
--
-- Access, same shape as the BBPAC tracker and BIOS102:
--   * Roster (sscc_bylaws_members) + emailed magic link. The link email is
--     sent by the sscc-bylaws-login Edge Function (service role); the token
--     row IS the session credential once clicked.
--   * Every table: RLS on, zero policies. Reads and writes go only through
--     the security-definer functions below, granted to anon AND
--     authenticated (a lingering Supabase Auth session elsewhere on the site
--     makes a visitor 'authenticated' -- see bios102-fix-authenticated-role).
--   * Public (no sign-in): the working draft and the version history with
--     each version's change log (author display names, no emails).
--     Members only: open proposals, comments, the member list.
-- ─────────────────────────────────────────────────────────────────────────

create table if not exists sscc_bylaws_members (
  email text primary key,
  display_name text not null,
  role text not null default 'member' check (role in ('chair', 'member')),
  created_at timestamptz not null default now()
);
alter table sscc_bylaws_members enable row level security;

create table if not exists sscc_bylaws_login_links (
  token uuid primary key default gen_random_uuid(),
  email text not null,
  status text not null default 'pending' check (status in ('pending', 'active')),
  created_at timestamptz not null default now(),
  expires_at timestamptz not null default (now() + interval '30 minutes')
);
alter table sscc_bylaws_login_links enable row level security;
create index if not exists sscc_bylaws_login_links_email_idx on sscc_bylaws_login_links (lower(email));

-- The working draft. `key` is stable for the life of a section (seeded
-- sections are 'I-1', 'II-3', ...; added ones 'n<proposal id>'); the
-- displayed section number is `section_num`, renumbered on add/delete.
-- `body` holds paragraphs separated by a blank line.
create table if not exists sscc_bylaws_sections (
  key text primary key,
  article_order int not null,
  article_num text not null,
  article_title text not null,
  section_order int not null,
  section_num int not null,
  title text not null,
  body text not null,
  updated_at timestamptz not null default now()
);
alter table sscc_bylaws_sections enable row level security;

create table if not exists sscc_bylaws_proposals (
  id bigserial primary key,
  kind text not null check (kind in ('amend', 'add', 'delete', 'issue')),
  section_key text,              -- amend/delete/issue: the section; add: insert after this one
  article_num text not null,
  base_title text,               -- amend/delete: section text when proposed,
  base_body text,                -- so a stale proposal can't overwrite newer text
  proposed_title text,           -- amend/add
  proposed_body text,            -- amend/add
  summary text not null,         -- one line, used in the change log
  rationale text,
  author_email text,             -- null for the seeded starter review notes
  author_label text,             -- display name override when author_email is null
  status text not null default 'open'
    check (status in ('open', 'accepted', 'rejected', 'deferred', 'withdrawn', 'resolved')),
  decided_by text,
  decision_note text,
  decided_at timestamptz,
  applied_section_key text,      -- add: key of the section it created
  in_version int,                -- version that first contains this change
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table sscc_bylaws_proposals enable row level security;

create table if not exists sscc_bylaws_comments (
  id bigserial primary key,
  proposal_id bigint not null references sscc_bylaws_proposals (id) on delete cascade,
  author_email text not null,
  body text not null,
  created_at timestamptz not null default now()
);
alter table sscc_bylaws_comments enable row level security;

create table if not exists sscc_bylaws_versions (
  num int primary key,
  label text not null unique,
  summary text not null,
  created_by text,
  created_by_label text,
  created_at timestamptz not null default now(),
  snapshot jsonb not null         -- [{key, article_num, article_title, section_num, title, body}, ...] in order
);
alter table sscc_bylaws_versions enable row level security;

-- ---------------- helpers ----------------

create or replace function sscc_bylaws_session(p_token uuid)
returns sscc_bylaws_members
language sql security definer set search_path = public stable
as $$
  select m.* from sscc_bylaws_login_links l
  join sscc_bylaws_members m on lower(m.email) = lower(l.email)
  where l.token = p_token and l.status = 'active';
$$;
revoke execute on function sscc_bylaws_session(uuid) from public, anon, authenticated;

create or replace function sscc_bylaws_name(p_email text, p_label text default null)
returns text
language sql security definer set search_path = public stable
as $$
  select coalesce((select display_name from sscc_bylaws_members where lower(email) = lower(p_email)), p_label, 'Former member');
$$;
revoke execute on function sscc_bylaws_name(text, text) from public, anon, authenticated;

create or replace function sscc_bylaws_snapshot()
returns jsonb
language sql security definer set search_path = public stable
as $$
  select coalesce(jsonb_agg(jsonb_build_object(
      'key', key, 'article_num', article_num, 'article_title', article_title,
      'section_num', section_num, 'title', title, 'body', body)
    order by article_order, section_order), '[]'::jsonb)
  from sscc_bylaws_sections;
$$;
revoke execute on function sscc_bylaws_snapshot() from public, anon, authenticated;

-- renumber an article's sections 1..n in order
create or replace function sscc_bylaws_renumber(p_article text)
returns void
language sql security definer set search_path = public
as $$
  update sscc_bylaws_sections s set section_num = r.n, section_order = r.n
  from (select key, row_number() over (order by section_order) as n
        from sscc_bylaws_sections where article_num = p_article) r
  where s.key = r.key;
$$;
revoke execute on function sscc_bylaws_renumber(text) from public, anon, authenticated;

-- ---------------- sign-in ----------------

-- Clicked link -> activate (within 30 minutes) and return who you are.
-- An already-active token keeps working, so it doubles as the session.
create or replace function sscc_bylaws_verify(p_token uuid)
returns table (session_token uuid, email text, display_name text, role text)
language plpgsql security definer set search_path = public
as $$
begin
  update sscc_bylaws_login_links set status = 'active'
  where token = p_token and status = 'pending' and expires_at > now();
  return query
    select l.token, m.email, m.display_name, m.role
    from sscc_bylaws_login_links l
    join sscc_bylaws_members m on lower(m.email) = lower(l.email)
    where l.token = p_token and l.status = 'active';
end;
$$;
grant execute on function sscc_bylaws_verify(uuid) to anon, authenticated;

-- ---------------- public reads ----------------

create or replace function sscc_bylaws_public()
returns jsonb
language sql security definer set search_path = public stable
as $$
  select jsonb_build_object(
    'draft', sscc_bylaws_snapshot(),
    'versions', coalesce((
      select jsonb_agg(jsonb_build_object(
        'num', v.num, 'label', v.label, 'summary', v.summary, 'created_at', v.created_at,
        'created_by', coalesce(sscc_bylaws_name(v.created_by, v.created_by_label), ''),
        'snapshot', v.snapshot,
        'changes', coalesce((
          select jsonb_agg(jsonb_build_object(
            'id', p.id, 'kind', p.kind, 'article_num', p.article_num, 'summary', p.summary,
            'rationale', p.rationale, 'author', sscc_bylaws_name(p.author_email, p.author_label),
            'decided_at', p.decided_at, 'decision_note', p.decision_note,
            'base_title', p.base_title, 'base_body', p.base_body,
            'proposed_title', p.proposed_title, 'proposed_body', p.proposed_body,
            'section_key', coalesce(p.applied_section_key, p.section_key))
            order by p.decided_at)
          from sscc_bylaws_proposals p where p.in_version = v.num), '[]'::jsonb))
        order by v.num)
      from sscc_bylaws_versions v), '[]'::jsonb),
    'pending_changes', (select count(*) from sscc_bylaws_proposals
                        where status = 'accepted' and kind <> 'issue' and in_version is null)
  );
$$;
grant execute on function sscc_bylaws_public() to anon, authenticated;

-- ---------------- member reads ----------------

create or replace function sscc_bylaws_member_state(p_token uuid)
returns jsonb
language plpgsql security definer set search_path = public stable
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  return jsonb_build_object(
    'me', jsonb_build_object('email', me.email, 'display_name', me.display_name, 'role', me.role),
    'proposals', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', p.id, 'kind', p.kind, 'section_key', p.section_key, 'article_num', p.article_num,
        'base_title', p.base_title, 'base_body', p.base_body,
        'proposed_title', p.proposed_title, 'proposed_body', p.proposed_body,
        'summary', p.summary, 'rationale', p.rationale,
        'author', sscc_bylaws_name(p.author_email, p.author_label),
        'mine', lower(coalesce(p.author_email, '')) = lower(me.email),
        'status', p.status, 'decided_by', case when p.decided_by is null then null else sscc_bylaws_name(p.decided_by) end,
        'decision_note', p.decision_note, 'decided_at', p.decided_at,
        'applied_section_key', p.applied_section_key, 'in_version', p.in_version,
        'created_at', p.created_at, 'updated_at', p.updated_at,
        'comments', coalesce((
          select jsonb_agg(jsonb_build_object('id', c.id, 'author', sscc_bylaws_name(c.author_email),
                   'mine', lower(c.author_email) = lower(me.email), 'body', c.body, 'created_at', c.created_at)
                 order by c.created_at)
          from sscc_bylaws_comments c where c.proposal_id = p.id), '[]'::jsonb))
        order by p.created_at desc)
      from sscc_bylaws_proposals p), '[]'::jsonb),
    'members', coalesce((
      select jsonb_agg(jsonb_build_object(
        'display_name', m.display_name, 'role', m.role,
        'email', case when me.role = 'chair' then m.email else null end)
        order by m.role, m.display_name)
      from sscc_bylaws_members m), '[]'::jsonb)
  );
end;
$$;
grant execute on function sscc_bylaws_member_state(uuid) to anon, authenticated;

-- ---------------- member writes ----------------

create or replace function sscc_bylaws_propose(
  p_token uuid, p_kind text, p_section_key text, p_proposed_title text,
  p_proposed_body text, p_summary text, p_rationale text)
returns bigint
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
  s sscc_bylaws_sections;
  new_id bigint;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if p_kind not in ('amend', 'add', 'delete', 'issue') then raise exception 'unknown proposal kind'; end if;
  select * into s from sscc_bylaws_sections where key = p_section_key;
  if s.key is null then raise exception 'section not found'; end if;
  if nullif(trim(p_summary), '') is null then raise exception 'a one-line summary is required'; end if;
  if p_kind in ('amend', 'add') and nullif(trim(p_proposed_body), '') is null then
    raise exception 'proposed text is required';
  end if;
  if p_kind = 'add' and nullif(trim(p_proposed_title), '') is null then
    raise exception 'a title for the new section is required';
  end if;
  if p_kind = 'amend' and trim(coalesce(p_proposed_title, s.title)) = s.title and trim(p_proposed_body) = s.body then
    raise exception 'the proposed text is the same as the current text';
  end if;
  insert into sscc_bylaws_proposals (kind, section_key, article_num, base_title, base_body,
      proposed_title, proposed_body, summary, rationale, author_email)
  values (p_kind, s.key, s.article_num,
      case when p_kind in ('amend', 'delete') then s.title end,
      case when p_kind in ('amend', 'delete') then s.body end,
      case when p_kind in ('amend', 'add') then trim(coalesce(nullif(trim(p_proposed_title), ''), s.title)) end,
      case when p_kind in ('amend', 'add') then trim(p_proposed_body) end,
      trim(p_summary), nullif(trim(p_rationale), ''), me.email)
  returning id into new_id;
  return new_id;
end;
$$;
grant execute on function sscc_bylaws_propose(uuid, text, text, text, text, text, text) to anon, authenticated;

-- Author edits an open/deferred proposal. p_rebase = true re-reads the
-- section's current text as the new base (after the section changed).
create or replace function sscc_bylaws_edit_proposal(
  p_token uuid, p_id bigint, p_proposed_title text, p_proposed_body text,
  p_summary text, p_rationale text, p_rebase boolean)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
  p sscc_bylaws_proposals;
  s sscc_bylaws_sections;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  select * into p from sscc_bylaws_proposals where id = p_id;
  if p.id is null then raise exception 'proposal not found'; end if;
  if lower(coalesce(p.author_email, '')) <> lower(me.email) and me.role <> 'chair' then
    raise exception 'only the author or the chair can edit this proposal';
  end if;
  if p.status not in ('open', 'deferred') then raise exception 'only open or deferred proposals can be edited'; end if;
  if nullif(trim(p_summary), '') is null then raise exception 'a one-line summary is required'; end if;
  if p_rebase and p.kind in ('amend', 'delete') then
    select * into s from sscc_bylaws_sections where key = p.section_key;
    if s.key is null then raise exception 'that section no longer exists'; end if;
  end if;
  update sscc_bylaws_proposals set
    proposed_title = case when kind in ('amend', 'add') then trim(coalesce(nullif(trim(p_proposed_title), ''), proposed_title)) end,
    proposed_body = case when kind in ('amend', 'add') then trim(coalesce(nullif(trim(p_proposed_body), ''), proposed_body)) end,
    summary = trim(p_summary),
    rationale = nullif(trim(p_rationale), ''),
    base_title = case when p_rebase and kind in ('amend', 'delete') then s.title else base_title end,
    base_body = case when p_rebase and kind in ('amend', 'delete') then s.body else base_body end,
    updated_at = now()
  where id = p_id;
end;
$$;
grant execute on function sscc_bylaws_edit_proposal(uuid, bigint, text, text, text, text, boolean) to anon, authenticated;

create or replace function sscc_bylaws_withdraw(p_token uuid, p_id bigint)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  update sscc_bylaws_proposals set status = 'withdrawn', updated_at = now()
  where id = p_id and lower(coalesce(author_email, '')) = lower(me.email) and status in ('open', 'deferred');
  if not found then raise exception 'only your own open or deferred proposals can be withdrawn'; end if;
end;
$$;
grant execute on function sscc_bylaws_withdraw(uuid, bigint) to anon, authenticated;

create or replace function sscc_bylaws_comment(p_token uuid, p_id bigint, p_body text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if nullif(trim(p_body), '') is null then raise exception 'comment is empty'; end if;
  if not exists (select 1 from sscc_bylaws_proposals where id = p_id) then raise exception 'proposal not found'; end if;
  insert into sscc_bylaws_comments (proposal_id, author_email, body) values (p_id, me.email, trim(p_body));
  update sscc_bylaws_proposals set updated_at = now() where id = p_id;
end;
$$;
grant execute on function sscc_bylaws_comment(uuid, bigint, text) to anon, authenticated;

-- ---------------- chair actions ----------------

-- accepted | rejected | deferred | resolved (issues) | open (reopen).
-- Accepting an amend/add/delete applies it to the working draft now; it
-- lands in the next version the chair cuts. A proposal whose base text no
-- longer matches the section is refused as stale -- its author re-bases it
-- (sscc_bylaws_edit_proposal with p_rebase) and the group re-reads it.
create or replace function sscc_bylaws_decide(p_token uuid, p_id bigint, p_decision text, p_note text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
  p sscc_bylaws_proposals;
  s sscc_bylaws_sections;
  new_key text;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can decide proposals'; end if;
  select * into p from sscc_bylaws_proposals where id = p_id for update;
  if p.id is null then raise exception 'proposal not found'; end if;
  if p_decision not in ('accepted', 'rejected', 'deferred', 'resolved', 'open') then raise exception 'unknown decision'; end if;
  if p.status = 'accepted' and p.kind <> 'issue' then
    raise exception 'an accepted change is already in the draft; propose a new change to alter it';
  end if;
  if p.status = 'withdrawn' then raise exception 'this proposal was withdrawn by its author'; end if;
  if p_decision = 'resolved' and p.kind <> 'issue' then raise exception 'use accepted or rejected for text changes'; end if;
  if p_decision = 'accepted' and p.kind = 'issue' then p_decision := 'resolved'; end if;

  if p_decision = 'accepted' then
    select * into s from sscc_bylaws_sections where key = p.section_key for update;
    if s.key is null then raise exception 'the section this proposal targets no longer exists'; end if;
    if p.kind in ('amend', 'delete') and (s.title <> p.base_title or s.body <> p.base_body) then
      raise exception 'stale: this section changed after the proposal was written; the author should update it to the current text first';
    end if;
    if p.kind = 'amend' then
      update sscc_bylaws_sections set title = p.proposed_title, body = p.proposed_body, updated_at = now() where key = s.key;
    elsif p.kind = 'delete' then
      delete from sscc_bylaws_sections where key = s.key;
      perform sscc_bylaws_renumber(s.article_num);
    elsif p.kind = 'add' then
      new_key := 'n' || p.id;
      update sscc_bylaws_sections set section_order = section_order + 1
      where article_num = s.article_num and section_order > s.section_order;
      insert into sscc_bylaws_sections (key, article_order, article_num, article_title, section_order, section_num, title, body)
      values (new_key, s.article_order, s.article_num, s.article_title, s.section_order + 1, s.section_num + 1, p.proposed_title, p.proposed_body);
      perform sscc_bylaws_renumber(s.article_num);
    end if;
  end if;

  update sscc_bylaws_proposals set
    status = p_decision,
    decided_by = case when p_decision = 'open' then null else me.email end,
    decided_at = case when p_decision = 'open' then null else now() end,
    decision_note = case when p_decision = 'open' then null else nullif(trim(p_note), '') end,
    applied_section_key = coalesce(new_key, applied_section_key),
    updated_at = now()
  where id = p_id;
end;
$$;
grant execute on function sscc_bylaws_decide(uuid, bigint, text, text) to anon, authenticated;

create or replace function sscc_bylaws_cut_version(p_token uuid, p_label text, p_summary text)
returns int
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
  n int;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can publish a version'; end if;
  if nullif(trim(p_label), '') is null or nullif(trim(p_summary), '') is null then
    raise exception 'a version label and summary are required';
  end if;
  if not exists (select 1 from sscc_bylaws_proposals where status = 'accepted' and kind <> 'issue' and in_version is null) then
    raise exception 'there are no accepted changes since the last version';
  end if;
  select coalesce(max(num), 0) + 1 into n from sscc_bylaws_versions;
  insert into sscc_bylaws_versions (num, label, summary, created_by, snapshot)
  values (n, trim(p_label), trim(p_summary), me.email, sscc_bylaws_snapshot());
  update sscc_bylaws_proposals set in_version = n
  where status = 'accepted' and kind <> 'issue' and in_version is null;
  return n;
end;
$$;
grant execute on function sscc_bylaws_cut_version(uuid, text, text) to anon, authenticated;

create or replace function sscc_bylaws_set_member(p_token uuid, p_email text, p_name text, p_role text, p_remove boolean)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if me.role <> 'chair' then raise exception 'only the chair can manage members'; end if;
  if lower(trim(p_email)) = lower(me.email) then raise exception 'you cannot change your own membership here'; end if;
  if p_remove then
    delete from sscc_bylaws_members where lower(email) = lower(trim(p_email));
    delete from sscc_bylaws_login_links where lower(email) = lower(trim(p_email));
  else
    if trim(p_email) !~ '^[^@\s]+@[^@\s]+\.[^@\s]+$' then raise exception 'that does not look like an email address'; end if;
    if nullif(trim(p_name), '') is null then raise exception 'a name is required'; end if;
    insert into sscc_bylaws_members (email, display_name, role)
    values (lower(trim(p_email)), trim(p_name), case when p_role = 'chair' then 'chair' else 'member' end)
    on conflict (email) do update set display_name = excluded.display_name, role = excluded.role;
  end if;
end;
$$;
grant execute on function sscc_bylaws_set_member(uuid, text, text, text, boolean) to anon, authenticated;

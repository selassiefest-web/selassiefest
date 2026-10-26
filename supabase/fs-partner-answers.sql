-- ─────────────────────────────────────────────────────────────────────────
-- Written answers for a partner's questions (/partner/answers/?k=<pitch_key>).
-- When a partner asks us questions before deciding (NNA, Oct 26 2026: four
-- questions on experience, readiness, local leadership and NNA's role), we
-- answer on one living page instead of one long email: a bulleted summary of
-- every answer, each linking to its full answer and its evidence, with a
-- status (answered / partly answered / pending), what an open part is
-- waiting on, and a dated change log. When a new fact arrives, staff edit
-- the answer in /partner/answers/edit.html; every edit bumps the version,
-- keeps the old text in fs_partner_answer_history and must say what changed.
--
-- Same access model as the tracker: both tables have RLS on and zero
-- policies. The public page reads only through fs_partner_qa_view (by the
-- partner's unguessable pitch_key, published answers only, no contacts or
-- notes). Staff read and write only through session-checked functions.
-- The answers themselves are loaded in the live DB, never committed here.
--
-- Apply with: supabase db query --linked -f supabase/fs-partner-answers.sql
-- Safe to re-run.
-- ─────────────────────────────────────────────────────────────────────────
alter table fs_partners add column if not exists qa_title text;          -- page heading, e.g. "Our answers to NNA's questions"
alter table fs_partners add column if not exists qa_intro text;          -- opening note above the summary
alter table fs_partners add column if not exists qa_views int not null default 0;
alter table fs_partners add column if not exists qa_last_viewed timestamptz;

create table if not exists fs_partner_answers (
  id uuid primary key default gen_random_uuid(),
  partner_id uuid not null references fs_partners(id) on delete cascade,
  sort int not null default 1,
  topic text not null,                                  -- short heading for the question
  question text not null,                               -- the partner's own words, verbatim
  summary jsonb not null default '[]'::jsonb,           -- ["bullet", ...]
  detail text,                                          -- full answer: paragraphs, "- " bullets, "### " subheads, **bold**, [label](url)
  evidence jsonb not null default '[]'::jsonb,          -- [{label, href, note}]
  status text not null default 'pending' check (status in ('answered','partial','pending')),
  waiting_on text,                                      -- what an open part is waiting on, said plainly
  published boolean not null default true,
  version int not null default 1,
  updated_by text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table fs_partner_answers enable row level security;
create index if not exists fs_partner_answers_partner_idx on fs_partner_answers (partner_id, sort);

create table if not exists fs_partner_answer_history (
  id uuid primary key default gen_random_uuid(),
  answer_id uuid not null references fs_partner_answers(id) on delete cascade,
  version int not null,                                 -- the version this change produced
  note text not null,                                   -- what changed, shown publicly in the change log
  public boolean not null default true,                 -- false for typo fixes that needn't be announced
  previous jsonb,                                       -- the answer as it was before (staff only)
  changed_by text not null,
  changed_at timestamptz not null default now()
);
alter table fs_partner_answer_history enable row level security;
create index if not exists fs_partner_answer_history_answer_idx on fs_partner_answer_history (answer_id, changed_at desc);

-- Public read by key. Counts the view. Only published answers and public change notes leave the database.
-- With a valid staff session (p_preview), hidden answers show too and the view isn't counted.
drop function if exists fs_partner_qa_view(text);
create or replace function fs_partner_qa_view(p_key text, p_preview uuid default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare p fs_partners; v_staff boolean := false;
begin
  if p_preview is not null then
    v_staff := exists (select 1 from fs_partner_login_links l join fs_partner_users u on lower(u.email) = lower(l.email)
                       where l.id = p_preview and l.status = 'active');
  end if;
  select * into p from fs_partners where pitch_key = p_key;
  if p.id is null or not exists (select 1 from fs_partner_answers a where a.partner_id = p.id and (a.published or v_staff)) then return null; end if;
  if not v_staff then update fs_partners set qa_views = qa_views + 1, qa_last_viewed = now() where id = p.id; end if;
  return jsonb_build_object(
    'name', p.name, 'title', p.qa_title, 'intro', p.qa_intro, 'preview', v_staff,
    'answers', coalesce((select jsonb_agg(jsonb_build_object(
        'sort', a.sort, 'topic', a.topic, 'question', a.question, 'summary', a.summary, 'detail', a.detail,
        'evidence', a.evidence, 'status', a.status, 'waiting_on', a.waiting_on, 'version', a.version, 'published', a.published,
        'created_at', a.created_at, 'updated_at', a.updated_at) order by a.sort, a.created_at)
      from fs_partner_answers a where a.partner_id = p.id and (a.published or v_staff)), '[]'::jsonb),
    'changes', coalesce((select jsonb_agg(jsonb_build_object(
        'sort', a.sort, 'topic', a.topic, 'version', h.version, 'note', h.note, 'changed_at', h.changed_at) order by h.changed_at desc)
      from fs_partner_answer_history h join fs_partner_answers a on a.id = h.answer_id
      where a.partner_id = p.id and (a.published or v_staff) and h.public), '[]'::jsonb)
  );
end;
$$;
grant execute on function fs_partner_qa_view(text, uuid) to anon, authenticated;

-- Staff read: one partner's page settings, every answer (published or not) and the full history.
create or replace function fs_partner_qa_load(p_session uuid, p_partner uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return jsonb_build_object(
    'partner', (select jsonb_build_object('id', p.id, 'name', p.name, 'pitch_key', p.pitch_key, 'qa_title', p.qa_title,
                  'qa_intro', p.qa_intro, 'qa_views', p.qa_views, 'qa_last_viewed', p.qa_last_viewed)
                from fs_partners p where p.id = p_partner),
    'answers', coalesce((select jsonb_agg(to_jsonb(a) order by a.sort, a.created_at) from fs_partner_answers a where a.partner_id = p_partner), '[]'::jsonb),
    'history', coalesce((select jsonb_agg(to_jsonb(h) order by h.changed_at desc) from fs_partner_answer_history h
                  join fs_partner_answers a on a.id = h.answer_id where a.partner_id = p_partner), '[]'::jsonb)
  );
end;
$$;
grant execute on function fs_partner_qa_load(uuid, uuid) to anon, authenticated;

-- Staff: page heading and opening note.
create or replace function fs_partner_qa_intro_save(p_session uuid, p_partner uuid, p_title text, p_intro text)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  update fs_partners set qa_title = nullif(trim(p_title),''), qa_intro = nullif(trim(p_intro),''), updated_at = now() where id = p_partner;
end;
$$;
grant execute on function fs_partner_qa_intro_save(uuid, uuid, text, text) to anon, authenticated;

-- Staff save. p_id null = new answer (version 1). An edit that changes what the
-- partner reads bumps the version, archives the old text and needs a note;
-- p_public false keeps a minor fix out of the public change log.
create or replace function fs_partner_qa_save(p_session uuid, p_partner uuid, p_id uuid, p jsonb, p_note text, p_public boolean default true)
returns fs_partner_answers language plpgsql security definer set search_path = public as $$
declare u record; old fs_partner_answers; r fs_partner_answers; v_changed boolean;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_id is null then
    insert into fs_partner_answers (partner_id, sort, topic, question, summary, detail, evidence, status, waiting_on, published, updated_by)
    values (p_partner, coalesce((p->>'sort')::int, 1), coalesce(nullif(trim(p->>'topic'),''),'Question'), coalesce(nullif(trim(p->>'question'),''),'(question)'),
            coalesce(p->'summary','[]'::jsonb), nullif(trim(p->>'detail'),''), coalesce(p->'evidence','[]'::jsonb),
            coalesce(nullif(p->>'status',''),'pending'), nullif(trim(p->>'waiting_on'),''), coalesce((p->>'published')::boolean, true), u.v_name)
    returning * into r;
    insert into fs_partner_answer_history (answer_id, version, note, public, changed_by)
    values (r.id, 1, coalesce(nullif(trim(p_note),''), 'First answer posted'), p_public, u.v_name);
    return r;
  end if;

  select * into old from fs_partner_answers where id = p_id and partner_id = p_partner;
  if old.id is null then raise exception 'answer not found'; end if;
  update fs_partner_answers set
    sort       = case when p ? 'sort' then coalesce((p->>'sort')::int, sort) else sort end,
    topic      = case when p ? 'topic' then coalesce(nullif(trim(p->>'topic'),''), topic) else topic end,
    question   = case when p ? 'question' then coalesce(nullif(trim(p->>'question'),''), question) else question end,
    summary    = case when p ? 'summary' then coalesce(p->'summary','[]'::jsonb) else summary end,
    detail     = case when p ? 'detail' then nullif(trim(p->>'detail'),'') else detail end,
    evidence   = case when p ? 'evidence' then coalesce(p->'evidence','[]'::jsonb) else evidence end,
    status     = case when p ? 'status' then coalesce(nullif(p->>'status',''), status) else status end,
    waiting_on = case when p ? 'waiting_on' then nullif(trim(p->>'waiting_on'),'') else waiting_on end,
    published  = case when p ? 'published' then coalesce((p->>'published')::boolean, published) else published end
  where id = p_id returning * into r;

  v_changed := (r.topic, r.question, r.summary, coalesce(r.detail,''), r.evidence, r.status, coalesce(r.waiting_on,''))
       is distinct from (old.topic, old.question, old.summary, coalesce(old.detail,''), old.evidence, old.status, coalesce(old.waiting_on,''));
  if v_changed then
    if nullif(trim(p_note),'') is null then raise exception 'Say what changed (the note appears in the change log).'; end if;
    update fs_partner_answers set version = old.version + 1, updated_at = now(), updated_by = u.v_name where id = p_id returning * into r;
    insert into fs_partner_answer_history (answer_id, version, note, public, previous, changed_by)
    values (p_id, r.version, trim(p_note), p_public, to_jsonb(old), u.v_name);
    insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
    values (p_partner, 'note', 'Answers page, "' || r.topic || '" updated to v' || r.version || ': ' || trim(p_note), u.v_email, u.v_name);
  end if;
  return r;
end;
$$;
grant execute on function fs_partner_qa_save(uuid, uuid, uuid, jsonb, text, boolean) to anon, authenticated;

create or replace function fs_partner_qa_delete(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  delete from fs_partner_answers where id = p_id;
end;
$$;
grant execute on function fs_partner_qa_delete(uuid, uuid) to anon, authenticated;

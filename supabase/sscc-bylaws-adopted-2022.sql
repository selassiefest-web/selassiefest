-- SSCC bylaws workspace: the bylaws currently in force (as amended April 9,
-- 2022), stored as a reference document beside the draft. The draft is a
-- full restructuring (6 articles -> 11), so instead of a keyed redline each
-- 2022 provision carries `to`: the draft sections that carry it forward.
-- Read-only; public, like the draft. Text is loaded by
-- sscc-bylaws-adopted-2022-seed.sql.
create table if not exists sscc_bylaws_adopted (
  key text primary key,
  sort int not null,
  article_num text not null,
  article_title text not null,
  label text not null,
  title text not null,
  body text not null,
  maps_to text[] not null default '{}'
);
alter table sscc_bylaws_adopted enable row level security;

-- sscc_bylaws_public() now also returns the 2022 bylaws.
create or replace function sscc_bylaws_public()
returns jsonb
language sql security definer set search_path = public stable
as $$
  select jsonb_build_object(
    'draft', sscc_bylaws_snapshot(),
    'adopted', coalesce((
      select jsonb_agg(jsonb_build_object('key', key, 'article_num', article_num, 'article_title', article_title,
        'label', label, 'title', title, 'body', body, 'to', to_jsonb(maps_to)) order by sort)
      from sscc_bylaws_adopted), '[]'::jsonb),
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

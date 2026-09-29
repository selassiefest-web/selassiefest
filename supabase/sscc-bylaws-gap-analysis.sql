-- SSCC bylaws workspace: the structural gap analysis behind v1.1.
-- Every governance topic (37 "dimensions") was read across the SSCC
-- draft (v1.0), the 2022 bylaws in force, the CPD template and Code of
-- Conduct, other Chicago PACs' bylaws, and a few park groups elsewhere.
-- The study itself (texts, per-document extracts with verified quotes,
-- per-dimension synthesis) lives outside the repo, in the committee's
-- research folder; this table holds what the page shows. Where the
-- analysis recommends a change, it is also filed as a proposal
-- (author_label 'Gap analysis'), so it goes through the same
-- discuss / accept / publish-a-version flow as any other change.
--
-- Members only, like proposals. Loaded by a generated script (not
-- committed; regenerate from the study folder when documents are added).

create table if not exists sscc_bylaws_gap_docs (
  id text primary key,
  sort int not null,
  name text not null,
  short text not null,            -- column label on the matrix
  kind text not null check (kind in ('subject', 'cpd', 'chicago', 'external')),
  structure text,
  overall text
);
alter table sscc_bylaws_gap_docs enable row level security;

create table if not exists sscc_bylaws_gap (
  id text primary key,            -- framework dimension id, e.g. 'quorum'
  sort int not null,
  label text not null,
  verdict text not null check (verdict in ('missing', 'weak', 'adequate', 'strong')),
  proposal_id bigint,             -- the proposal filed for its recommendation, if any
  scores jsonb not null,          -- {doc id: strength 0-3}
  detail jsonb not null           -- the synthesis record (draft summary, CPD, best practices, recommendation, questions)
);
alter table sscc_bylaws_gap enable row level security;

create or replace function sscc_bylaws_gap_state(p_token uuid)
returns jsonb
language plpgsql security definer set search_path = public stable
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  return jsonb_build_object(
    'docs', coalesce((select jsonb_agg(to_jsonb(d) order by d.sort) from sscc_bylaws_gap_docs d), '[]'::jsonb),
    'dims', coalesce((select jsonb_agg(jsonb_build_object(
        'id', g.id, 'label', g.label, 'verdict', g.verdict, 'proposal_id', g.proposal_id,
        'scores', g.scores, 'detail', g.detail) order by g.sort) from sscc_bylaws_gap g), '[]'::jsonb)
  );
end;
$$;
grant execute on function sscc_bylaws_gap_state(uuid) to anon, authenticated;

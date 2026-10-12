-- ─────────────────────────────────────────────────────────────────────────
-- Full Spectrum GRANT PIPELINE (Grants tab of /full-spectrum/partners.html).
-- Turns the staff-only fs_grant_deadlines watch-list (fs-grant-deadlines.sql)
-- into a working pipeline: every funder gets a status (to_research ->
-- drafting -> ready -> submitted -> awarded/declined), an owner, the project
-- it funds, the amount asked/awarded, and a next step with a due date. The
-- Sunday send-fs-grant-deadlines email reads the same columns.
--
-- Still RLS-on with no policies. The page reads/writes only through the
-- security-definer functions below, each of which re-validates the
-- magic-link session token via fs_partner_session_user() (see
-- full-spectrum-partners.sql). Apply with:
--   supabase db query --linked -f supabase/fs-grants-pipeline.sql
-- This file is safe to re-run (idempotent).
-- ─────────────────────────────────────────────────────────────────────────
alter table fs_grant_deadlines add column if not exists status text not null default 'to_research';
alter table fs_grant_deadlines drop constraint if exists fs_grant_deadlines_status_check;
alter table fs_grant_deadlines add constraint fs_grant_deadlines_status_check
  check (status in ('to_research','drafting','ready','submitted','awarded','declined','not_eligible','skip'));
alter table fs_grant_deadlines add column if not exists level text;            -- federal | state | county | city | corporate | foundation
alter table fs_grant_deadlines add column if not exists project text;          -- djclass | wednesdays | selassiefest | heritage | org
alter table fs_grant_deadlines add column if not exists priority int not null default 2;   -- 1 high, 2 normal, 3 low
alter table fs_grant_deadlines add column if not exists owner text;
alter table fs_grant_deadlines add column if not exists eligibility text;      -- who may apply / what blocks us
alter table fs_grant_deadlines add column if not exists match_required text;
alter table fs_grant_deadlines add column if not exists amount_requested numeric(12,2);
alter table fs_grant_deadlines add column if not exists amount_awarded numeric(12,2);
alter table fs_grant_deadlines add column if not exists submitted_on date;
alter table fs_grant_deadlines add column if not exists decision_on date;      -- when we expect / got the decision
alter table fs_grant_deadlines add column if not exists next_step text;
alter table fs_grant_deadlines add column if not exists next_step_due date;
alter table fs_grant_deadlines add column if not exists updated_at timestamptz not null default now();
create index if not exists fs_grant_deadlines_status_idx on fs_grant_deadlines (status, next_step_due);

create or replace function fs_grants_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return coalesce((select jsonb_agg(to_jsonb(g) order by g.deadline_date nulls last, g.funder) from fs_grant_deadlines g), '[]'::jsonb);
end;
$$;
grant execute on function fs_grants_load(uuid) to anon, authenticated;

create or replace function fs_grant_save(p_session uuid, p_id uuid, p jsonb)
returns fs_grant_deadlines language plpgsql security definer set search_path = public as $$
declare u record; r fs_grant_deadlines;
begin
  select * into u from fs_partner_session_user(p_session);
  if p_id is null then
    insert into fs_grant_deadlines (funder, kind) values (coalesce(nullif(trim(p->>'funder'),''),'Untitled funder'), coalesce(nullif(p->>'kind',''),'rolling'))
    returning * into r;
    p_id := r.id;
  end if;
  update fs_grant_deadlines set
    funder           = case when p ? 'funder' then coalesce(nullif(trim(p->>'funder'),''), funder) else funder end,
    program          = case when p ? 'program' then nullif(trim(p->>'program'),'') else program end,
    kind             = case when p ? 'kind' then p->>'kind' else kind end,
    deadline_date    = case when p ? 'deadline_date' then nullif(p->>'deadline_date','')::date else deadline_date end,
    opens_date       = case when p ? 'opens_date' then nullif(p->>'opens_date','')::date else opens_date end,
    amount           = case when p ? 'amount' then nullif(trim(p->>'amount'),'') else amount end,
    verified         = case when p ? 'verified' then (p->>'verified')::boolean else verified end,
    verified_on      = case when p ? 'verified' and (p->>'verified')::boolean then current_date else verified_on end,
    url              = case when p ? 'url' then nullif(trim(p->>'url'),'') else url end,
    notes            = case when p ? 'notes' then nullif(trim(p->>'notes'),'') else notes end,
    active           = case when p ? 'active' then (p->>'active')::boolean else active end,
    status           = case when p ? 'status' then p->>'status' else status end,
    level            = case when p ? 'level' then nullif(p->>'level','') else level end,
    project          = case when p ? 'project' then nullif(p->>'project','') else project end,
    priority         = case when p ? 'priority' then coalesce(nullif(p->>'priority','')::int, 2) else priority end,
    owner            = case when p ? 'owner' then nullif(trim(p->>'owner'),'') else owner end,
    eligibility      = case when p ? 'eligibility' then nullif(trim(p->>'eligibility'),'') else eligibility end,
    match_required   = case when p ? 'match_required' then nullif(trim(p->>'match_required'),'') else match_required end,
    amount_requested = case when p ? 'amount_requested' then nullif(p->>'amount_requested','')::numeric else amount_requested end,
    amount_awarded   = case when p ? 'amount_awarded' then nullif(p->>'amount_awarded','')::numeric else amount_awarded end,
    submitted_on     = case when p ? 'submitted_on' then nullif(p->>'submitted_on','')::date
                            when p ? 'status' and p->>'status' = 'submitted' and submitted_on is null then current_date
                            else submitted_on end,
    decision_on      = case when p ? 'decision_on' then nullif(p->>'decision_on','')::date else decision_on end,
    next_step        = case when p ? 'next_step' then nullif(trim(p->>'next_step'),'') else next_step end,
    next_step_due    = case when p ? 'next_step_due' then nullif(p->>'next_step_due','')::date else next_step_due end,
    updated_at       = now()
  where id = p_id
  returning * into r;
  return r;
end;
$$;
grant execute on function fs_grant_save(uuid, uuid, jsonb) to anon, authenticated;

create or replace function fs_grant_delete(p_session uuid, p_id uuid)
returns void language plpgsql security definer set search_path = public as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  delete from fs_grant_deadlines where id = p_id;
end;
$$;
grant execute on function fs_grant_delete(uuid, uuid) to anon, authenticated;

-- Backfill level/project on the rows seeded by fs-grant-deadlines.sql.
update fs_grant_deadlines set level = 'corporate' where level is null and funder in ('Walmart / Sam''s Club','Target','Costco','ComEd / League of Chicago Theatres','Sweetwater','Guitar Center Music Foundation','D''Addario Foundation');
update fs_grant_deadlines set level = 'foundation' where level is null and funder in ('LPMC Foundation','Field Foundation / MacArthur','Polk Bros. Foundation','Hearst Foundations');
update fs_grant_deadlines set level = 'state' where level is null and funder = 'Illinois Arts Council';
update fs_grant_deadlines set level = 'city' where level is null and funder = 'City of Chicago DCASE';
update fs_grant_deadlines set priority = 1 where funder = 'Walmart / Sam''s Club' and kind = 'dated';

-- ── Added October 2026 from the funder research PDF + ComEd press release ──
-- kind:'paused' here means "no open window; check back" (see fs-grant-deadlines.sql).
insert into fs_grant_deadlines (funder, program, kind, deadline_date, opens_date, amount, verified, url, notes, verified_on, level, project, priority, eligibility, match_required)
select * from (values
('Illinois Arts Council','Creative Accelerator Fund','dated','2026-10-14'::date,'2026-09-02'::date,'varies',false,'https://arts.illinois.gov/granting-opportunities/grants-programs.html','Window opened Sep 2, closes Oct 14. INDIVIDUAL artists only: a DJ / musician / teaching artist applies for their own practice, not the organization. Decide today whether an eligible artist will apply.','2026-10-12'::date,'state','djclass',1,'Individual Illinois artist, not Ras Tafari Inc.',null),
('Chicago Park District','Night Out in the Parks (2027 season)','expected',null,'2026-11-01'::date,'grant + production support',false,'https://www.chicagoparkdistrict.com/','Park District says to watch for the 2027 application to open in November 2026. Free public cultural programming in parks: youth DJ showcase, Caribbean music, outdoor event. Prepare program description, performances, budget, evidence of demand, how it stays free.','2026-10-12'::date,'city','wednesdays',1,'Chicago artists, collectives and organizations',null),
('Chicago Park District','ARCS Arts Partnerships','rolling',null,null,'partnership, not cash',false,'https://www.chicagoparkdistrict.com/','Athletic Use, Resident, Contractor and Service Provider program: ongoing public programming on Park District property. Submit at least 60-90 days before programming. Fits a recurring DJ class at Rainbow Beach.','2026-10-12'::date,'city','djclass',1,'Organizations, community groups, artists, businesses',null),
('ComEd / Metropolitan Mayors Caucus','Powering the Holidays','paused',null,null,'up to $2,500',false,'https://www.comed.com/','Fifth annual round (2025) gave 25 awards for holiday light events held Nov 1-Feb 13; ComEd funds it, Metropolitan Mayors Caucus administers, third-party judges. Nonprofits, municipalities and townships in ComEd territory. Rainbow Beach Park Advisory Council, Ahead Academy (Bronzeville) and Calahan Foundation (Englewood) won in 2025. 2026 round may already be closed: check ComEd.com and mayorscaucus.org now, then calendar the next cycle. Fits the fall and holiday parties (Kids Kostume Party, Noon Year''s Eve) and could be a joint application with the Advisory Council.','2026-10-12'::date,'corporate','parties',1,'Nonprofit or local government in ComEd service area; event Nov-Feb',null),
('National Endowment for the Arts','Grants for Arts Projects','paused',null,null,'$10,000-$100,000',false,'https://www.arts.gov/grants/grants-for-arts-projects','2026 deadlines passed; NEA expects new guidelines in late December 2026. Music, arts education, folk and traditional arts. Challenge America: $10,000 for small orgs serving underserved communities. Needs SAM.gov / UEI registration.','2026-10-12'::date,'federal','djclass',2,'Nonprofits, local governments, tribal communities','1:1 cost share required'),
('National Endowment for the Humanities','Public humanities projects','paused',null,null,'varies',false,'https://www.neh.gov/grants','Humanities only, not equipment or a performance by itself. Fit: documented oral-history project on Jamaican sound-system culture, Caribbean migration and reggae history in Chicago.','2026-10-12'::date,'federal','heritage',3,'Check program-specific eligibility',null),
('Institute of Museum and Library Services','Museum and library grants','relationship',null,null,'varies',false,'https://www.imls.gov/grants','Eligibility is program-specific; an ordinary arts nonprofit will not qualify alone. Possible only with an eligible library or museum partner (music archive, digital learning collection).','2026-10-12'::date,'federal','heritage',3,'Museums, libraries and related institutions',null),
('Illinois Arts Council','General Operating Support (GOS)','paused',null,null,'varies by tier',false,'https://arts.illinois.gov/granting-opportunities/grants-programs.html','Next organizational opportunity expected winter 2027. Pull the guidelines the day they post to confirm applicant category and award limits. Needs Illinois GATA prequalification.','2026-10-12'::date,'state','org',1,'Eligible Illinois nonprofit arts organizations',null),
('Illinois Arts Council','Youth Employment in the Arts (YEA)','paused',null,null,'varies',false,'https://arts.illinois.gov/granting-opportunities/grants-programs.html','Check the next GOS/YEA guidance; do not assume a separate application is open. Fit if Rainbow DJ Class builds a paid youth pathway (production, event tech, sound engineering).','2026-10-12'::date,'state','djclass',2,'Orgs with eligible paid youth arts employment',null),
('Illinois Arts Council','Creative Learning Grants for Schools','relationship',null,null,'up to $20,000',false,'https://arts.illinois.gov/granting-opportunities/grants-programs.html','School-led: eligible public K-12 districts, schools and charters buy arts-learning equipment and services. 2026 deadline passed. Ask a partner school to apply for DJ controllers, headphones, software or our teaching services.','2026-10-12'::date,'state','djclass',2,'Public K-12 schools and charters only',null),
('Illinois Arts Council','Regional Arts Partners (local regranting)','paused',null,null,'small grants',false,'https://arts.illinois.gov/granting-opportunities/grants-programs.html','Regranting through designated regional partners (Chicago DCASE is one); often a more accessible route to small grants. 2026 deadline passed.','2026-10-12'::date,'state','org',2,null,null),
('Illinois Humanities','Project and Collaborative Project Grants','paused',null,null,'varies',false,'https://www.ilhumanities.org/grants/','2026 deadlines were in February; monitor the next cycle. Fit: Caribbean cultural heritage, local music histories, oral histories, public education on reggae and sound-system traditions.','2026-10-12'::date,'state','heritage',2,'Statewide cultural funder, not a state agency',null),
('Chicago DCASE','Individual Artists Program (IAP)','paused',null,null,'varies',false,'https://www.chicago.gov/city/en/depts/dca.html','Chicago-based individual artists (music, performing, film/media). Not an equipment grant for a nonprofit. 2026 cycle is past; watch the Cultural Grants portal. An instructor or DJ could apply personally.','2026-10-12'::date,'city','djclass',2,'Individual Chicago artists',null),
('Chicago DCASE','Cultural Grants portal (organizations, festivals, programs)','paused',null,null,'varies',false,'https://www.chicago.gov/city/en/depts/dca.html','Monitor for any organizational, project, festival or community programming call. Check legal applicant requirements per call.','2026-10-12'::date,'city','selassiefest',2,null,null),
('Arts Work Fund','Capacity for Creative Communities','paused',null,null,'varies',false,'https://artsworkfund.org/','Capacity-building grants for small and mid-sized arts organizations in Chicago and Cook County (strategy, community engagement). Check for the next call.','2026-10-12'::date,'foundation','org',2,null,null),
('Cook County Justice Advisory Council','Starting Block Grants','paused',null,null,'varies',false,'https://www.cookcountyil.gov/','Community grants including arts and culture, nonprofits under $1M budget. County says another round may come, subject to funding. Frame as youth development and community safety, not arts-only.','2026-10-12'::date,'county','djclass',3,'Nonprofits under $1M annual budget',null),
('Cook County Arts','Creative Placemaking / Nonprofit Relief','paused',null,null,'$5,000-$250,000',false,'https://www.cookcountyil.gov/','Past rounds restricted to SUBURBAN Cook County and funded with ARPA money. Rainbow Beach is in the City of Chicago, so this likely does not apply. Do not spend time unless a city-eligible successor appears.','2026-10-12'::date,'county','org',3,'Suburban Cook County only',null)
) as v(funder,program,kind,deadline_date,opens_date,amount,verified,url,notes,verified_on,level,project,priority,eligibility,match_required)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and g.program = v.program);

-- Existing row: note the stale-funding warning from the October 2026 research.
update fs_grant_deadlines set
  notes = coalesce(notes || ' ', '') || 'Oct 2026 research: FY27 funds reported fully expended across all IAC regions as of Aug 7, 2026; next organizational opportunity is General Operating Support, winter 2027. Up to $12,000 for projects with a public presentation.',
  status = 'to_research'
where funder = 'Illinois Arts Council' and program = 'Creative Projects grant' and notes not like '%Oct 2026 research%';

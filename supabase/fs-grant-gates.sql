-- Full Spectrum grants: READINESS GATES. Replaces "skip / not eligible" for funders we cannot ask yet
-- with the specific gate(s) that unlock them, so the Grants tab can show "what is missing" per funder.
--   g0 Compliance and identity (IL AG registration, SAM.gov, one address, assumed-names consent)
--   g1 Evidence and governance (logic model, 3-year budget, independent board/advisors, policies, pilot data)
--   g2 Reviewed financials (closed books, CPA review, Form 990, Candid profile)
--   g3 Track record (a year of classes and organization history)
--   g4 Relationship or invitation (intro, fit call, partner school)
-- Gate definitions, fix steps and links live in /full-spectrum/partners.html (GATES). Tags below are working
-- estimates: confirm against each funder's current guidelines. Also adds funders researched in Oct 2026
-- (Siragusa, Pritzker Traubert, CCT, MacArthur, McCormick, Crown, Obama Foundation, SocialWorks, Common Ground,
-- Frankie Knuckles Foundation, Chicago-HQ corporations). New rows are verified=false, status to_research.
-- This file also supersedes fs_grant_save in fs-grants-pipeline.sql (adds the gates key).
-- Apply: supabase db query --linked -f supabase/fs-grant-gates.sql   (idempotent; safe to re-run)
begin;
alter table fs_grant_deadlines add column if not exists gates text[] not null default '{}';

CREATE OR REPLACE FUNCTION public.fs_grant_save(p_session uuid, p_id uuid, p jsonb)
 RETURNS fs_grant_deadlines
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
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
    gates            = case when p ? 'gates' then coalesce(array(select jsonb_array_elements_text(p->'gates')), '{}') else gates end,
    updated_at       = now()
  where id = p_id
  returning * into r;
  return r;
end;
$function$;
grant execute on function fs_grant_save(uuid, uuid, jsonb) to anon, authenticated;

insert into fs_grant_deadlines (funder, program, kind, url, notes, level, project, priority, eligibility, next_step, gates, verified, status, active)
select v.funder, v.program, v.kind, v.url, v.notes, v.level, v.project, v.priority, v.eligibility, v.next_step, v.gates, false, 'to_research', true
from (values
('Siragusa Family Foundation','Youth Development: Arts Learning','paused','https://siragusa.org/','Oct 2026 search: in 2026 the foundation launched Youth Development as a primary priority with three areas (Arts Learning, Academic enrichment, Wellness). Chicago-area funder. Deadlines and eligibility not yet read from their site.','foundation','djclass',1,'Unconfirmed: read their guidelines for geography, budget size and years-in-operation rules','Read the Youth Development guidelines at siragusa.org; note deadline, award size and whether a new nonprofit can apply','{g0,g1}'::text[]),
('Pritzker Traubert Foundation','Chicago economic-opportunity competitions (Chicago Prize, Chicago Talent Challenge); otherwise invitation','relationship','https://ptfound.org/','Oct 2026 search: focus is Chicago economic opportunity, mainly South and West sides, with education and arts as secondary areas. Sources disagree on unsolicited proposals (one says invitation only, one says one-page synopses accepted); the foundation''s own site was not read. Arts is a minor area, so a youth-workforce angle (paid DJ/audio apprenticeships) fits better than a class alone.','foundation','org',3,'Unconfirmed. Invitation-only or competitions; Chicago-focused','Read ptfound.org for open competitions; ask whether a one-page synopsis is accepted','{g1,g2,g3,g4}'::text[]),
('MacArthur Foundation','Culture, Equity and the Arts','relationship','https://www.macfound.org/','Large endowed Chicago funder. Arts grants are mostly by invitation; the open door for small South and West Side arts groups is the Field Foundation / MacArthur A Road Together program (already listed).','foundation','org',3,'Unconfirmed; assume invitation-only','Confirm there is no open call; keep watching A Road Together','{g2,g3,g4}'::text[]),
('Chicago Community Trust','Discretionary grants and donor-advised funds (gateway funder)','relationship','https://cct.org/','Its grants database shows small awards to South Side music education groups: Musical Arts Institute $15,000, West Point Fellowship $20,000, South Side Jazz Coalition $5,000. Realistic first institutional funder and the door to donor-advised fund holders.','foundation','djclass',1,'Unconfirmed: read current open calls and whether a first-year nonprofit can apply','Read cct.org for open calls; request a short fit conversation with a program officer','{g0,g1,g4}'::text[]),
('Robert R. McCormick Foundation','Community and youth grants','relationship','https://www.mccormickfoundation.org/','Chicago endowed funder. Guidelines not yet read.','foundation','org',3,'Unconfirmed','Read their current priorities and application rules','{g1,g2,g3,g4}'::text[]),
('Crown Family Philanthropies','Chicago community and arts giving','relationship',null,'Chicago family philanthropy. Guidelines not yet read.','foundation','org',3,'Unconfirmed','Find the current guidelines and whether unsolicited inquiries are accepted','{g1,g2,g3,g4}'::text[]),
('Obama Foundation','Community programs near the Obama Presidential Center (South Side)','relationship','https://www.obama.org/','South Side location makes this a geographic fit to check. Programs and partner opportunities not yet read.','foundation','heritage',2,'Unconfirmed','Check Obama Foundation community and partner pages for youth arts opportunities','{g1,g3,g4}'::text[]),
('SocialWorks (Chance the Rapper)','New Chance Arts & Literature Fund (school-based)','relationship',null,'Oct 2026 search: the fund made three-year, $100,000 grants to Chicago schools, which wrote their own action plan. School applies, not an outside nonprofit. Ask a South Shore / Greater Grand Crossing school to apply with RTI as its arts partner.','foundation','djclass',2,'School is the applicant; current round unknown','Find out whether the fund is still open and recruit a partner school (same school as the CPS Creative Schools Fund idea)','{g4}'::text[]),
('Common Ground Foundation (Common)','Youth leadership and arts','relationship',null,'Chicago-born artist''s foundation. Giving process not yet read.','foundation','djclass',2,'Unconfirmed','Find the foundation''s application or partnership process','{g1,g4}'::text[]),
('Frankie Knuckles Foundation','Chicago house music heritage and education','relationship',null,'Strongest story fit: house music was born in Chicago and the DJ Lab is a DJ program. Likely an advisor / guest-instructor / endorsement partner more than a funder.','foundation','heritage',1,'Unconfirmed','Find a contact and ask for an advisory or guest-instructor conversation','{g4}'::text[]),
('Archer Daniels Midland','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('McDonald''s','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('JLL','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('Northern Trust','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('Conagra Brands','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('Old Republic International','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('GE HealthCare','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('Kraft Heinz','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('CME Group','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('Morningstar','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('TransUnion','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[]),
('Hyatt Hotels','Corporate giving and community investment','relationship',null,'Chicago headquarters per the Wikipedia list of Chicago-area companies (Oct 2026). Giving arm, guidelines and contact path not yet researched. Pritzker family-founded company.','corporate','djclass',2,'Unconfirmed: giving priorities, geography and whether a first-year nonprofit can apply','Find the foundation or community-affairs contact and the current guidelines','{g0,g1,g4}'::text[])
) as v(funder,program,kind,url,notes,level,project,priority,eligibility,next_step,gates)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and coalesce(g.program,'') = coalesce(v.program,''));

update fs_grant_deadlines g set gates = t.gates
from (values
('After School Matters',null,'{g0}'::text[]),
('Chicago DCASE','Individual Artists Program (IAP)','{}'::text[]),
('Chicago DCASE','Cultural Grants portal (organizations, festivals, programs)','{g0,g1}'::text[]),
('Chicago Park District','Night Out in the Parks (2027 season)','{g0}'::text[]),
('Chicago Park District','ARCS Arts Partnerships','{g0}'::text[]),
('City of Chicago DCASE','CityArts Program','{g0,g1}'::text[]),
('City of Chicago DFSS',null,'{g0}'::text[]),
('Ingenuity / CPS',null,'{g4}'::text[]),
('SGA Youth & Family Services / Chicago DFSS',null,'{g0}'::text[]),
('AlphaTheta / Pioneer DJ',null,'{g4}'::text[]),
('Audio-Technica',null,'{g4}'::text[]),
('CHAUVET DJ',null,'{g4}'::text[]),
('Focusrite / Novation / ADAM Audio',null,'{g4}'::text[]),
('Gator',null,'{g4}'::text[]),
('HARMAN / JBL',null,'{g4}'::text[]),
('Hercules',null,'{g4}'::text[]),
('inMusic Brands (Numark, Denon DJ, Rane, Akai, Alto)',null,'{g4}'::text[]),
('Koss',null,'{g4}'::text[]),
('Odyssey',null,'{g4}'::text[]),
('On-Stage',null,'{g4}'::text[]),
('QSC',null,'{g4}'::text[]),
('Reloop',null,'{g4}'::text[]),
('Roland',null,'{g4}'::text[]),
('Sennheiser',null,'{g4}'::text[]),
('Shure',null,'{g4}'::text[]),
('Sweetwater',null,'{g4}'::text[]),
('Yamaha',null,'{g4}'::text[]),
('ComEd / League of Chicago Theatres',null,'{g0}'::text[]),
('ComEd / Metropolitan Mayors Caucus',null,'{g0}'::text[]),
('Costco',null,'{g0}'::text[]),
('Target',null,'{g0}'::text[]),
('Walmart / Sam''s Club',null,'{g0}'::text[]),
('D''Addario Foundation',null,'{g0,g1}'::text[]),
('Guitar Center Music Foundation',null,'{g0,g1}'::text[]),
('Cook County Arts',null,'{g0,g1,g2}'::text[]),
('Cook County Justice Advisory Council',null,'{g0,g1,g2,g3}'::text[]),
('Institute of Museum and Library Services',null,'{g4}'::text[]),
('National Endowment for the Arts',null,'{g0,g1,g2,g3}'::text[]),
('National Endowment for the Humanities',null,'{g0,g1,g2,g3}'::text[]),
('Arts Work Fund',null,'{g0,g1,g2}'::text[]),
('Field Foundation / MacArthur',null,'{g2,g3,g4}'::text[]),
('Hearst Foundations',null,'{g1,g2,g3,g4}'::text[]),
('Lloyd A. Fry Foundation',null,'{g0,g1,g2,g3}'::text[]),
('LPMC Foundation',null,'{g0,g1}'::text[]),
('Music for Global Children',null,'{g1}'::text[]),
('NAMM Foundation',null,'{g0,g1}'::text[]),
('Polk Bros. Foundation',null,'{g0,g1,g2,g4}'::text[]),
('Springboard Foundation',null,'{g0,g1}'::text[]),
('The Seabury Foundation',null,'{g0,g1}'::text[]),
('Illinois Arts Council','Creative Projects grant','{g0,g1}'::text[]),
('Illinois Arts Council','General Operating Support (GOS)','{g0,g1,g2,g3}'::text[]),
('Illinois Arts Council','Youth Employment in the Arts (YEA)','{g0,g1,g3}'::text[]),
('Illinois Arts Council','Creative Accelerator Fund','{}'::text[]),
('Illinois Arts Council','Creative Learning Grants for Schools','{g4}'::text[]),
('Illinois Arts Council','Regional Arts Partners (local regranting)','{g0}'::text[]),
('Illinois Humanities',null,'{g0,g1}'::text[])
) as t(funder,program,gates)
where g.funder = t.funder and (t.program is null or g.program = t.program) and g.gates = '{}';

-- post-check: tagged vs untagged (individual-artist rows are intentionally gate-free)
select count(*) filter (where cardinality(gates) > 0) as tagged, count(*) filter (where cardinality(gates) = 0) as no_gates, count(*) as total from fs_grant_deadlines;
select funder, program from fs_grant_deadlines where cardinality(gates) = 0 order by funder;
commit;

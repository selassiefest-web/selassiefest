-- Public figures, athlete foundations and Chicago family funders from the Oct 27 research (general knowledge, NOT verified:
-- every name, giving process and Chicago tie must be confirmed from primary sources). verified=false, to_research.
-- Dry run: change the last line to rollback;
begin;

insert into fs_grant_deadlines (funder, program, kind, url, notes, level, project, priority, eligibility, next_step, gates, verified, status, active)
select v.funder, v.program, v.kind, v.url, v.notes, v.level, v.project, v.priority, v.eligibility, v.next_step, v.gates, false, 'to_research', true
from (values
('Oprah Winfrey Charitable Foundation','Public figure: invitation-based','relationship',null,'Low as a direct ask. Her Chicago base (Harpo) is gone and giving is largely invitation-only. Pursue only through a mutual connection.','foundation','org',3,'Unconfirmed; assume invitation-only','Find a warm introduction before anything else','{g4}'::text[]),
('Jordan Brand / Michael Jordan Foundation','Public figure: community and grant channels','relationship',null,'Low to moderate. The better door is Jordan Brand''s community team, not Michael Jordan. His family foundation has funded Chicago youth clubs before (unconfirmed).','foundation','djclass',2,'Unconfirmed','Find the Jordan Brand community-grants contact and the foundation''s process','{g1,g4}'::text[]),
('Jennifer Hudson (foundation to confirm)','Public figure: youth and music','relationship',null,'Chicago-born; a foundation focused on youth and music (name and process not confirmed).','foundation','djclass',2,'Unconfirmed','Confirm the foundation''s exact name and whether it takes proposals','{g4}'::text[]),
('Wade Family Foundation (Dwyane Wade)','Athlete foundation','relationship',null,'Moderate. Confirm first that youth arts is in scope.','foundation','djclass',3,'Unconfirmed','Read the foundation''s stated focus; skip if youth arts is out of scope','{g4}'::text[]),
('Derrick Rose (foundation to confirm)','Athlete foundation','relationship',null,'Chicago-born; moderate. Foundation name and focus not confirmed.','foundation','djclass',3,'Unconfirmed','Confirm the foundation and whether youth arts is in scope','{g4}'::text[]),
('Candace Parker Foundation','Athlete foundation','relationship',null,'Chicago Sky champion; moderate. Confirm focus and Chicago programs first.','foundation','djclass',3,'Unconfirmed','Read the foundation''s focus and any Chicago programs','{g4}'::text[]),
('Joyce Foundation','Chicago family and venture philanthropy','relationship','https://www.joycefdn.org/','Named in the Oct 27 research as a Chicago funder to read. Focus areas and open calls not yet checked; some foundations of this type will want a year of track record.','foundation','org',3,'Unconfirmed','Read the guidelines for geography and issue areas','{g1,g3,g4}'::text[]),
('Steans Family Foundation','Chicago family philanthropy','relationship',null,'Named in the Oct 27 research as a Chicago funder to read. Focus and process not yet checked.','foundation','org',3,'Unconfirmed','Read the guidelines for geography and issue areas','{g1,g3,g4}'::text[]),
('Chicago Beyond','Chicago venture philanthropy (youth)','relationship','https://www.chicagobeyond.org/','Named in the Oct 27 research. Youth-focused venture philanthropy; expect a data and track-record bar. Not yet read.','foundation','djclass',2,'Unconfirmed','Read what they fund and how they select partners','{g1,g2,g3,g4}'::text[]),
('Reid Hoffman (venture philanthropy)','Bay Area tech philanthropy','relationship',null,'Low fit. No Chicago tie; giving follows his own themes (AI, civic tech, scaling). A free local DJ class does not match. Watch only.','foundation','org',3,'Poor fit','No action unless a Chicago connection appears','{g4}'::text[]),
('MacKenzie Scott / Yield Giving','Unsolicited gifts only','relationship','https://yieldgiving.com/','No applications. She selects organizations herself, so there is nothing to submit. Watch only; the best preparation is the same evidence and financials the other gates need.','foundation','org',3,'No application process','Nothing to do now; keep the readiness gates moving','{g1,g2,g3}'::text[])
) as v(funder, program, kind, url, notes, level, project, priority, eligibility, next_step, gates)
where not exists (select 1 from fs_grant_deadlines d where d.funder = v.funder);

-- Sweetwater: no equipment ask has been written yet.
update fs_grant_deadlines set next_step = 'Write the Sweetwater equipment ask (not in equipment-outreach drafts.md yet); they select partners proactively, so send through their philanthropy page', updated_at = now()
where funder = 'Sweetwater';

select count(*) as funders, count(*) filter (where verified = false) as unverified from fs_grant_deadlines;
commit;

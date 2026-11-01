-- Full Spectrum grants: batch 8 (pasted research notes 2026-11-01; Saints and CCRx re-searched same day, official pages not opened).
-- Most of that round (Awesome Foundation, Springboard, Fry, Polk Bros, Donnelley, Night Out, Target, Best Buy, IAP/Ignite) was already tracked.
-- Idempotent; safe to re-run. Apply: supabase db query --linked -f supabase/fs-grants-batch8.sql
begin;
select count(*) as before_total from fs_grant_deadlines;
insert into fs_grant_deadlines (funder, program, kind, deadline_date, opens_date, amount, verified, url, notes, verified_on, level, project, priority, eligibility, match_required, status, gates, next_step, next_step_due)
select * from (values
('Creative Chicago Reuse Exchange (CCRx)','Surplus art and craft materials (in-kind)','rolling',null::date,null::date,'in-kind materials, free or deeply discounted',false,'https://www.artspace.org/ccrx','Chicago 501(c)(3) that redistributes donated clean, working materials and equipment to teachers, nonprofits and artists. Warehouse reported at 2124 W. 82nd Pl. by appointment; appointments by emailing info@creativechirx.org. Older reports gave a West Englewood address, so CONFIRM the current address and schedule. Use for Rainbow Wednesdays decorations and installation materials: send a short list with quantities.','2026-11-01'::date,'foundation','wednesdays',3,'Teachers, nonprofits, artists; by appointment',null,'to_research','{}'::text[],'Email info@creativechirx.org with a materials list (fabric, paint, found objects) and ask for an appointment',null),
('The Saints','Arts Grants (project support)','expected',null,null,'about $3,000-$6,500',false,'https://www.saintschicago.org','Requires 501(c)(3) status for at least THREE YEARS, so Ras Tafari Inc. (ruling June 2026) does not qualify until about 2029. 2026 application window was reported as Feb 9 to Mar 2 (unconfirmed which program); inquiries to grants@saintschicago.org. Revisit when the three-year mark nears, or ask whether a fiscal sponsor or lead partner may apply.','2026-11-01'::date,'foundation','org',4,'501(c)(3) for 3+ years; Chicago-area performing arts',null,'not_eligible','{g3}'::text[],'Revisit in 2028; no action now',null)
) as v(funder,program,kind,deadline_date,opens_date,amount,verified,url,notes,verified_on,level,project,priority,eligibility,match_required,status,gates,next_step,next_step_due)
where not exists (select 1 from fs_grant_deadlines g where g.funder = v.funder and g.program = v.program);
select count(*) as after_total from fs_grant_deadlines;
commit;

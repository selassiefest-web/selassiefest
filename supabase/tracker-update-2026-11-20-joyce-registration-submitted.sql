-- 2026-11-20 (evening): Stephen SUBMITTED the Joyce Foundation Fluxx registration request (confirmation page loi_created). Re-run safe.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note',
 'Nov 20, 2026 (evening CST): Stephen SUBMITTED the Joyce Foundation Fluxx registration request (not an LOI) at joycefdn.fluxx.io. Program: Culture. Contact Stephen Henry, President, stephen@selassiefest.com, (872) 255-9333. Org: RAS TAFARI INC, EIN 42-3036705, 1401 E. 71st St., Chicago 60619, Public Charity, 0 full-time staff, not invited by staff, project support only, Illinois. Project: Rainbow Wednesdays (14 free all-ages evenings Jun 2-Sep 1, 2027, neighborhood artists, young DJs, families and elders, goal 300 a night). Experience: new org, SelassieFest 2026 about 273, Shure equipment received Nov 6. No dollar amount entered. Confirmation page: "We appreciate you submitting your organization''s information and look forward to getting back to you." Questions: applications@joycefdn.org. (ref joyce-fluxx-registration-2026-11-20)',
 (select stage from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18'), 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p
where p.id = '670cf826-1b34-49ac-b1f9-a0b582debb18'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%(ref joyce-fluxx-registration-2026-11-20)%');

update fs_partners set
  ball_with = 'them', last_contact_at = now(),
  next_step = 'Fluxx registration request SUBMITTED Nov 20, 2026. Wait for Joyce''s email (they review it and say if approved; if approved, an LOI follows). Also waiting on Maddie''s answer about the Apr 1, 2027 cycle and whether the all-ages series is the right project. Follow up once in the same thread Mon Dec 1 if silent; questions about status: applications@joycefdn.org.',
  next_step_due = '2026-12-01',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Fluxx registration request submitted by Stephen (project: Rainbow Wednesdays, all-ages public series). [src:joyce-registration-submitted]'
where id = '670cf826-1b34-49ac-b1f9-a0b582debb18' and coalesce(notes,'') not like '%src:joyce-registration-submitted%';

update fs_grant_deadlines set
  next_step = 'Fluxx registration SUBMITTED Nov 20, 2026. Wait for Joyce''s review email (approval opens an LOI). Follow up with Maddie Dec 1 if silent. Target cycle Apr 1, 2027 (confirm with Maddie).',
  next_step_due = '2026-12-01',
  notes = coalesce(notes,'') || E'\n[2026-11-20] Stephen submitted the Joyce Fluxx registration request (Culture; project Rainbow Wednesdays; no amount entered). Still $16,800 idea for LOI stage only if approved. [src:joyce-registration-submitted]'
where id = 'dc25d586-f390-4553-964a-01fd8090c8e1' and coalesce(notes,'') not like '%src:joyce-registration-submitted%';
commit;
select (select ball_with||' '||next_step_due::text from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18') partner,
 (select (notes like '%src:joyce-registration-submitted%')::text from fs_grant_deadlines where id='dc25d586-f390-4553-964a-01fd8090c8e1') grant_ok;

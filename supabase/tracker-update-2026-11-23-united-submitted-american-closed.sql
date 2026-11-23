-- Nov 23, 2026. United Miles on a Mission submitted by Stephen (page showed Application submitted).
-- American Let Good Take Flight: not eligible until about June 2029. Safe to re-run (tag-guarded). No personal data.
begin;

-- United grant row e621a665 (was drafting, submitted_on null). Goal in miles: unknown, not stated.
update fs_grant_deadlines set
 status = 'submitted',
 submitted_on = '2026-11-23',
 next_step = 'Watch the stephen-at-selassiefest inbox for United and the MileagePlus account email; answer same day. United says review takes 2 to 4 weeks. On approval set up the charity MileagePlus account and line up donors. Check Dec 21, 2026; if no word, follow up through the Miles on a Mission page.',
 next_step_due = '2026-12-21',
 notes = coalesce(notes,'') || E'\n[2026-11-23 submitted] Application submitted online at donate.mileageplus.com/Apply (Miles on a Mission). Page said review takes 2 to 4 weeks; MileagePlus account email follows. Earlier cycle info: fall review closed Sept 14, no next cycle published, so timing is uncertain. Miles goal entered: not recorded here. 28-day option and 100,000+ awards claims are not on United pages. [src:united-submitted-2026-11-23]',
 verified = true, verified_on = '2026-11-23', updated_at = now()
where id = 'e621a665-f5d3-41a6-b067-cb90b1104afa'
  and status <> 'submitted' and coalesce(notes,'') not like '%src:united-submitted-2026-11-23%';

-- United partner row 2dc7bd53
update fs_partners set
 stage = 'reached_out', ball_with = 'them',
 next_step = 'Waiting on United (submitted Nov 23, 2026, review 2 to 4 weeks). Watch the stephen-at-selassiefest inbox for the MileagePlus account email and reply same day. Check Dec 21, 2026.',
 next_step_due = '2026-12-21',
 last_contact_at = now(),
 notes = coalesce(notes,'') || E'\n[2026-11-23] Miles on a Mission application submitted online by Stephen. Page showed Application submitted. No commitment yet. [src:united-submitted-2026-11-23]'
where id = '2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2'
  and stage = 'not_contacted' and coalesce(notes,'') not like '%src:united-submitted-2026-11-23%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2', 'note',
 'Nov 23, 2026: Stephen submitted the Miles on a Mission application (donate.mileageplus.com/Apply); page showed Application submitted. United says review takes 2 to 4 weeks and a MileagePlus account email follows. Ask: 2 Economy round trips SYD-ORD for Audima guests, Mar 25 to Apr 1, 2027. [src:united-submitted-2026-11-23]',
 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2' and summary like '%src:united-submitted-2026-11-23%');

-- American partner row 5fb7a60c: not eligible, closed (not_qualified is an allowed stage)
update fs_partners set
 stage = 'not_qualified', ball_with = 'parked',
 next_step = 'Not eligible until about June 2029: American excludes start-ups with an IRS ruling year under three years (RTI 501(c)(3) effective June 9, 2026). Do not file. Revisit June 8, 2029.',
 next_step_due = '2029-06-08',
 notes = coalesce(notes,'') || E'\n[2026-11-23] Verified at aa.com Let Good Take Flight guidelines: start-up nonprofits with ruling year under three years and events within the current quarter are excluded. [src:aa-guidelines-2026-11-23]'
where id = '5fb7a60c-7195-4c8c-ae06-2259e0691247'
  and stage = 'not_contacted' and coalesce(notes,'') not like '%src:aa-guidelines-2026-11-23%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select '5fb7a60c-7195-4c8c-ae06-2259e0691247', 'note',
 'Nov 23, 2026: checked American Let Good Take Flight guidelines (aa.com). Start-ups with an IRS ruling year under three years are excluded, so RTI is not eligible until about June 2029. No inquiry filed. [src:aa-guidelines-2026-11-23]',
 'not_qualified', 'stephen@selassiefest.com', 'Stephen Henry'
where not exists (select 1 from fs_partner_activity where partner_id='5fb7a60c-7195-4c8c-ae06-2259e0691247' and summary like '%src:aa-guidelines-2026-11-23%');

-- American grant row b73f1660 stays not_eligible, due 2029-06-08; add verification stamp
update fs_grant_deadlines set
 notes = coalesce(notes,'') || E'\n[2026-11-23 verified] aa.com funding restrictions: start-ups under three years since IRS ruling excluded; current-quarter events excluded. Ineligible until about June 2029.',
 verified = true, verified_on = '2026-11-23', updated_at = now()
where id = 'b73f1660-305c-455b-aa12-eb5658263b85' and coalesce(notes,'') not like '%2026-11-23 verified%';
commit;

select id, status, submitted_on, next_step_due, verified_on from fs_grant_deadlines where id in ('e621a665-f5d3-41a6-b067-cb90b1104afa','b73f1660-305c-455b-aa12-eb5658263b85');
select p.name, p.stage, p.ball_with, p.next_step_due, (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%src:%2026-11-23%') new_acts
from fs_partners p where p.id in ('2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2','5fb7a60c-7195-4c8c-ae06-2259e0691247');

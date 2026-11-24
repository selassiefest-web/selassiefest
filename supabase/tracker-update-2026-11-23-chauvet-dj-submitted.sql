-- CHAUVET DJ Marketing Support form submitted Nov 23, 2026 (confirmation on page: "Your inquiry has been received."). Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-23', next_step_due='2026-12-02',
  next_step='Submitted Nov 23, 2026 via https://www.chauvetdj.com/marketing-support/ (ask: LED DJ booth facades toward the 4-booth line, one facade fine). Wait for reply; if none by Dec 2, send one short follow-up through any address they give.'
where id='ad4a1484-d980-4972-87a3-5712f388acfd';
update fs_partners set stage='reached_out', ball_with='them', last_contact_at='2026-11-23', next_step_due='2026-12-02',
  next_step='Waiting on CHAUVET DJ reply to the Nov 23 Marketing Support form. Check Dec 2.'
where id::text like '2b132601%';
insert into fs_partner_activity(partner_id,kind,summary,by_name,by_email)
select p.id,'note','Nov 23, 2026: Stephen submitted the CHAUVET DJ Marketing Support form (https://www.chauvetdj.com/marketing-support/). Ask: donated LED DJ booth facades (one is a fine start, CHAUVET picks the model) toward the four-booth line. Site confirmed receipt. Follow-up Dec 2.','Claude','stephen@selassiefest.com'
from fs_partners p where p.id::text like '2b132601%'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like 'Nov 23, 2026: Stephen submitted the CHAUVET DJ%');
select status, submitted_on, next_step_due from fs_grant_deadlines where id='ad4a1484-d980-4972-87a3-5712f388acfd';
select stage, ball_with, next_step_due from fs_partners where id::text like '2b132601%';
commit;

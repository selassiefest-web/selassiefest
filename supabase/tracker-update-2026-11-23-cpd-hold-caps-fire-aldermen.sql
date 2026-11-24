-- Stephen, Nov 23 2026: table CAPS 3rd District, the Fire Department rows and the 5 aldermen until CPD gives the GO.
-- Keyed by id; safe to re-run. cpd-hold-release.sql releases them to 'us' on GO.
begin;
update fs_partners set ball_with='cpd_hold', next_step_due=null,
  next_step='HOLD until CPD GO (Stephen, Nov 23, 2026). Prior next step: '||coalesce(next_step,'(none)'),
  notes=coalesce(notes,'')||E'\n2026-11-23: tabled to cpd_hold by Stephen until CPD GO.'
where id in (
 '21adc056-d246-48ee-81cd-2a540168d69f','0914b657-e197-4e5b-9938-1d8030375ff8',
 'a25aae8e-6ac0-4b76-a649-09ffcef6ed50','ba985428-8c05-48dd-814f-00d61414641f','131b43c3-bf72-4c52-bc8e-fde06675e0f3',
 '66ffda25-fdbe-46e0-a248-1f45074cebca','a7af1a34-ff8b-47a2-96dd-4780b04c1226','14507a81-daaa-4760-8506-e23f92057696','d216cb43-cfcb-4b53-ae36-034c08ae86a9')
 and ball_with <> 'cpd_hold';
insert into fs_partner_activity(partner_id,kind,summary,by_name,by_email)
select p.id,'note','Nov 23, 2026: Stephen tabled this row until CPD gives the GO (CAPS 3rd District, Fire Dept and aldermen). Draft CAPS 3rd email saved, not sent.','Claude','stephen@selassiefest.com'
from fs_partners p where p.id in (
 '21adc056-d246-48ee-81cd-2a540168d69f','0914b657-e197-4e5b-9938-1d8030375ff8',
 'a25aae8e-6ac0-4b76-a649-09ffcef6ed50','ba985428-8c05-48dd-814f-00d61414641f','131b43c3-bf72-4c52-bc8e-fde06675e0f3',
 '66ffda25-fdbe-46e0-a248-1f45074cebca','a7af1a34-ff8b-47a2-96dd-4780b04c1226','14507a81-daaa-4760-8506-e23f92057696','d216cb43-cfcb-4b53-ae36-034c08ae86a9')
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like 'Nov 23, 2026: Stephen tabled this row%');
select name, ball_with, next_step_due from fs_partners where ball_with='cpd_hold' and notes like '%2026-11-23: tabled%';
commit;

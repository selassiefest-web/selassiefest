-- 2026-11-18: Eames and Clayco nudges SENT at Stephen's "send" (rti-outreach; Resend ids below), each from stephen@, cc stephen@, new message, with the pitch deck link.
-- Rainbow Cone TABLED at Stephen's word (Nov 18): its Nov 20 nudge step is set aside, due date cleared. No partner rows exist for these three funders. Guarded; safe to re-run.
begin;
update fs_grant_deadlines set next_step='Nudge SENT Nov 18, 2026 (Resend 01a1f213-7822-7080-bfb7-bb5aa8a345ca) to info@eamesinstitute.org with the pitch deck, following up the Nov 2 inquiry ($10,000 general support). Wait for Eames; if silent, one more internal check Dec 9, then park until there is an introduction.',
 next_step_due='2026-12-09',
 notes=coalesce(notes,'')||E'\n[2026-11-18] Nudge sent (Resend 01a1f213-7822-7080-bfb7-bb5aa8a345ca) to info@eamesinstitute.org.'
where id='926f48bd-5ad6-46fa-89ac-4d5bb59e237f' and coalesce(notes,'') not like '%01a1f213-7822-7080%';
update fs_grant_deadlines set next_step='Nudge SENT Nov 18, 2026 (Resend 01a1f213-789f-7271-a6dc-b480e13c1ec9) to Melissa Mazrim (MazrimM@RealCRG.com) with the pitch deck, following up the Nov 2 inquiry. Wait for Clayco; if silent, one more internal check Dec 9. Mid-April 2027 (internal date): ask again before the June selection. No Rebuild mention.',
 next_step_due='2026-12-09',
 notes=coalesce(notes,'')||E'\n[2026-11-18] Nudge sent (Resend 01a1f213-789f-7271-a6dc-b480e13c1ec9) to MazrimM@RealCRG.com.'
where id='f1a22e77-6f67-4401-81c2-8eb318c207dd' and coalesce(notes,'') not like '%01a1f213-789f-7271%';
update fs_grant_deadlines set next_step='TABLED by Stephen Nov 18, 2026: no nudge to Staci Ybarra for now. Status unchanged (emailed Nov 1, one-pager sent Nov 2, no reply logged). Revisit only when Stephen says. Deck https://selassiefest.com/full-spectrum/rainbow-cone/',
 next_step_due=null,
 notes=coalesce(notes,'')||E'\n[2026-11-18] TABLED by Stephen (his word in chat); due date cleared; not overdue.'
where id='05f9523f-7717-4e1d-87d9-19e64e7bb971' and coalesce(notes,'') not like '%TABLED by Stephen (his word in chat)%';
commit;
select (select count(*) from fs_grant_deadlines where notes like '%01a1f213-7%') nudges,(select next_step_due from fs_grant_deadlines where id='05f9523f-7717-4e1d-87d9-19e64e7bb971') cone_due;

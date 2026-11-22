-- Nov 22, 2026 (Stephen): DROP Human-I-T. Its nonprofit upload requires a state sales-tax exemption document we do not have. Safe to re-run (marker-guarded).
begin;
update fs_grant_deadlines set
 status='not_eligible', next_step_due=null,
 next_step='DROPPED by Stephen Nov 22, 2026: Human-I-T''s nonprofit membership upload requires proof of a state/multistate sales-tax exemption, which we do not have. No further action; do not work around it. The Human-I-T account Stephen created stays dormant (no purchase, no approval requested). Laptops: see PCs for People, Best Buy and other rows.',
 notes = notes || E'\n2026-11-22 [humanit-dropped-20261122] Stephen: drop this one, we do not have that form (state sales-tax exemption document). Supersedes the earlier plan to uncheck "Tax Exempt" and submit the IRS letter only. Nothing submitted for approval, nothing received.'
where id='1bb6960b-2be0-4e7e-9967-944922c080d3' and notes not like '%humanit-dropped-20261122%';
commit;
select status, next_step_due::text, (notes like '%humanit-dropped-20261122%') noted from fs_grant_deadlines where id='1bb6960b-2be0-4e7e-9967-944922c080d3';

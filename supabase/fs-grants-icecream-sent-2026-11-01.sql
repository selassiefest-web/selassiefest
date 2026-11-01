-- Ice cream pilot emails sent Nov 1 2026 from stephen@ (Prairie Farms, Fox Valley Farms). GlacierPoint form text ready, Stephen submits (math check).
begin;
update fs_grant_deadlines set status='submitted', next_step='Emailed 11/1 (info@prairiefarms.com): follow up by phone 618-659-5700 if no reply', next_step_due='2026-11-09',
 notes = notes || ' SENT 11/1/2026: 50 servings/week pilot request to info@prairiefarms.com (cc Stephen).'
where funder='Prairie Farms Dairy';
update fs_grant_deadlines set status='submitted', next_step='Emailed 11/1 (orders@); leave voicemail 630-231-3005 asking for Sales if no reply', next_step_due='2026-11-09',
 notes = notes || ' SENT 11/1/2026: nonprofit pricing + delivery + loaner freezer request to orders@foxvalleyfarms.com (cc Stephen).'
where funder='Fox Valley Farms';
update fs_grant_deadlines set next_step='Stephen submits the form: text in Claude outputs/ice-cream/glacierpoint-form.txt (math-check box)', next_step_due='2026-11-03'
where funder='GlacierPoint (Great Lakes division)';
commit;

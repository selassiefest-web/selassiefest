-- Morningstar Commitment to Chicago Fund: Stephen submitted the United Way Nonprofit Interest Form (Microsoft Forms) Nov 24, 2026. Fund not open; applications expected 2027 via United Way of Metro Chicago. Safe to re-run.
begin;
update fs_grant_deadlines set next_step_due='2027-03-01',
  eligibility='Connect people to careers in financial services, technology, and related fields; securing financial futures; guidelines not yet published',
  next_step='Interest form submitted Nov 24, 2026 (United Way of Metro Chicago, Morningstar Commitment to Chicago Fund). Fund not open; apply when United Way publishes application details (expected 2027). Recheck https://unitedwaychicago.org/for-partners/agency-partners/morningstar-commitment-to-chicago-fund/ and the Morningstar page on Mar 1, 2027.',
  notes=case when coalesce(notes,'') like '%2026-11-24: interest form submitted (Morningstar)%' then notes else coalesce(notes,'')||E'\n2026-11-24: interest form submitted (Morningstar) by Stephen: focus area Career skills and advancement; instructor tiers $500/Tuesday, $2,000, $19,500. No application open yet.' end
where id='ed906339-e8cf-42f0-91c5-270a11ef34ac';
update fs_partners set stage='reached_out', ball_with='them', last_contact_at='2026-11-24', next_step_due='2027-03-01',
  next_step='Interest form submitted Nov 24, 2026. Waiting for United Way to publish Morningstar Fund application details (expected 2027). Recheck Mar 1, 2027.'
where id='640f3190-2534-4f7a-9b25-41c23bbd34f0';
insert into fs_partner_activity(partner_id,kind,summary,by_name,by_email)
select '640f3190-2534-4f7a-9b25-41c23bbd34f0','note','Nov 24, 2026: Stephen submitted the Morningstar Commitment to Chicago Fund Nonprofit Interest Form on the United Way of Metro Chicago page (focus area Career skills and advancement; message gave the Rainbow DJ Lab and instructor tiers). Fund not open; applications expected 2027. Recheck Mar 1, 2027.','Claude','stephen@selassiefest.com'
where exists (select 1 from fs_partners where id='640f3190-2534-4f7a-9b25-41c23bbd34f0')
 and not exists (select 1 from fs_partner_activity a where a.partner_id='640f3190-2534-4f7a-9b25-41c23bbd34f0' and a.summary like 'Nov 24, 2026: Stephen submitted the Morningstar%');
select next_step_due from fs_grant_deadlines where id='ed906339-e8cf-42f0-91c5-270a11ef34ac';
select stage, ball_with, next_step_due from fs_partners where id='640f3190-2534-4f7a-9b25-41c23bbd34f0';
commit;

-- Aitel Foundation inquiry SENT by Stephen from stephen@selassiefest.com (Outlook), Mon Nov 23 2026 11:35 pm CT (Tue 24 Nov 05:35:58 +0000).
-- To funding@aitelfoundation.org, cc stephen@. Ask: $19,500 instructors (tiers $5,000 / $2,500). No fs_partners row exists. Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-23', amount_requested=19500,
  next_step_due='2026-12-07',
  next_step='Inquiry emailed Nov 23, 2026 (11:35 pm CT) to funding@aitelfoundation.org: $19,500 for instructor pay (tiers $5,000 / $2,500), asks for a reply or 15-minute video call and whether they fund Chicago. Awaiting Aitel reply; one email nudge Dec 7. If they say Chicago is ineligible, set not_eligible and close.',
  notes=case when coalesce(notes,'') like '%CO6P220MB033899E9B36E6CA9017D640ED7442%' then notes else coalesce(notes,'')||E'\n2026-11-23: Stephen sent the v2 inquiry from stephen@selassiefest.com to funding@aitelfoundation.org (cc stephen@), 11:35 pm CT. Message-ID <CO6P220MB033899E9B36E6CA9017D640ED7442@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. Copy: Downloads\BOB\A_DJ_station_of_their_own... .eml.' end
where id='e4b06a99-7c08-4300-ab43-8cf570eca6fc';
select funder,status,submitted_on,amount_requested,next_step_due from fs_grant_deadlines where id='e4b06a99-7c08-4300-ab43-8cf570eca6fc';
commit;

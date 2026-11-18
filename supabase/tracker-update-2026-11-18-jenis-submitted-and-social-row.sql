-- Nov 18, 2026: Jeni's Splendid Ice Creams. Fixes (i) submitted_on, (ii) separate Ice Cream Social opportunity row, (iii) declined-row cleanup.
-- Reviewed by partner-grant-data-quality-reviewer (corrections folded in). Safe to re-run: every statement is guarded.
-- Evidence for Nov 1 (restored in C:\Users\mkepr\Downloads\BOB\):
--   Success!_Your_donation_request_has_been_submitted_to_Jeni's_Splendid_Ice_Creams.eml (and "(1)"): Formstack/Givinga receipt, Date Sun 01 Nov 2026 09:29:53 +0000 (3:29 am CT), attachment JenisIceCream_Submission_1511925484.pdf, Message-IDs <jGvqlYnRSRe6MrMk9nUdbw@geopod-ismtpd-20> and <ecfm3ENfSUO_10_p2i63bw@geopod-ismtpd-10>. "inform you when a decision has been made at least four weeks before your event".
--   Ice_cream_for_a_free_youth_music_program_at_Rainbow_Beach_(Chicago).eml: Stephen to fundraising@jenis.com, Sun 01 Nov 2026 09:18:38 +0000, Message-ID <010001a196675a90-c528b6e6-8704-41c5-a6f7-ce4b697cc2a8-000000@email.amazonses.com>; it asked for a 100-serving pilot "or host an Ice Cream Social fundraiser with us".
--   Decline: Donation_Request_Update_from_Jeni's_Splendid_Ice_Creams.eml, Message-ID <sb4nDWnfRUeMBxFjhOWAYQ@geopod-ismtpd-142>, Sun Nov 15 8:42 pm CT.
-- Row ids: declined request a8b28c45-6e95-4bde-977a-19731a044f5b. The new row is found by funder + program.
begin;

-- (i) submitted_on (receipt dated Nov 1, 2026 in both UTC and Chicago time)
update fs_grant_deadlines set
  submitted_on = date '2026-11-01',
  notes = coalesce(notes,'') || E'\n2026-11-18 RECEIPT FOUND: Givinga/Formstack confirmation Sun Nov 1, 2026 09:29:53 UTC (3:29 am CT), submission PDF JenisIceCream_Submission_1511925484.pdf, Message-IDs <jGvqlYnRSRe6MrMk9nUdbw@geopod-ismtpd-20> and <ecfm3ENfSUO_10_p2i63bw@geopod-ismtpd-10> (two copies). Stephen''s own Nov 1 email to fundraising@jenis.com (09:18 UTC) had also asked about hosting an Ice Cream Social.',
  updated_at = now()
where id = 'a8b28c45-6e95-4bde-977a-19731a044f5b'
  and submitted_on is null and status = 'declined'
  and notes like '%APPLICATION SUBMITTED 11/1/2026%';

-- (ii) separate opportunity: nothing awarded or received, numeric amounts NULL, no owner (none named in any source)
insert into fs_grant_deadlines
  (funder, program, kind, status, level, project, priority, verified, active, url, eligibility, next_step, next_step_due, notes)
select
  'Jeni''s Splendid Ice Creams',
  'Ice Cream Social fundraiser (alternative offer, Nov 2026)',
  'rolling', 'to_research', 'corporate', 'wednesdays', 3, false, true,
  'https://jenis.com/pages/jenis-fundraising',
  'Unverified. Jeni''s social fundraisers reportedly exclude religious organizations (Ras Tafari Inc. is not one); confirm on Jenis.com/Fundraising.',
  'INTERNAL FOLLOW-UP (not a Jeni''s deadline; their Nov 15 email states none): decide yes/no on applying at Jenis.com/Fundraising after verifying current terms (venue, dates, application window). Owner not assigned.',
  date '2026-11-20',
  'OPPORTUNITY ONLY. NOT AWARDED, NOT RECEIVED. Offered Nov 15, 2026 (Sun 8:42 pm CT) by Jeni''s Stewardship Team via Givinga support, Message-ID <sb4nDWnfRUeMBxFjhOWAYQ@geopod-ismtpd-142>, after declining the in-kind request (declined row a8b28c45-6e95-4bde-977a-19731a044f5b, preserved). Stephen''s Nov 1 email to fundraising@jenis.com had itself asked about hosting an Ice Cream Social. Stated terms: local scoop shop, Mon-Thu before 6 pm, max 3 hours, 25% of event proceeds to RTI. Dollar value of the 25% share UNKNOWN, not estimated. No funder deadline stated. Scoop shop, event date and attendance plan not chosen.'
where not exists (
  select 1 from fs_grant_deadlines
  where funder = 'Jeni''s Splendid Ice Creams'
    and (program = 'Ice Cream Social fundraiser (alternative offer, Nov 2026)'
         or (notes like '%sb4nDWnfRUeMBxFjhOWAYQ%' and id <> 'a8b28c45-6e95-4bde-977a-19731a044f5b'))
);

-- (iii) declined row: keep decision of record; one Nov 20 item only (on the new row); no award-looking text
update fs_grant_deadlines set
  next_step = 'DECLINED Nov 15, 2026 (decision of record). The alternative Ice Cream Social is tracked on its own row (program "Ice Cream Social fundraiser (alternative offer, Nov 2026)"). Optional, not yet done: ask Givinga support why the donation was declined and whether a smaller or later in-kind request can be considered.',
  next_step_due = null,
  amount = 'none awarded; declined Nov 15, 2026',
  notes = coalesce(notes,'') || E'\n2026-11-18 CROSS-LINK: Ice Cream Social offer moved to its own tracking row; this row remains the declined in-kind request (amount_awarded 0, decision_on 2026-11-15). Nothing awarded or received.',
  updated_at = now()
where id = 'a8b28c45-6e95-4bde-977a-19731a044f5b'
  and status = 'declined' and amount_awarded = 0 and decision_on = date '2026-11-15'
  and notes not like '%CROSS-LINK: Ice Cream Social offer moved%';

commit;

select id, program, status, kind, amount, amount_requested, amount_awarded, submitted_on, decision_on, owner, next_step_due, verified, left(next_step,60) ns
from fs_grant_deadlines where funder = 'Jeni''s Splendid Ice Creams' order by created_at;

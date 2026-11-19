-- 2026-11-19: four gaps found by the steward. Safe to re-run: every write is keyed on a marker not yet present.
-- (1) CPD Night Out in the Parks Submittable receipt, Message-Id <20261101201750.483f0807ce2f6799@email.submittable.com>, Sun Nov 1 2026 20:17:50 UTC (2:17 pm CST).
--     No fs_partners row exists for Night Out (grant-only record), so the receipt goes in grant 38b44632 notes only; status/next_step already correct, unchanged.
-- (2) John Floeter / CFM 10-208 (Message-ID CH2PR22MB2008124493BEAEBC1C1A6BAFF4682@...): NO fs_partners row exists and fs_partner_activity.partner_id is NOT NULL,
--     so no activity row is inserted and none is created. Substance and Message-ID are already in grant dc89e16f notes (Nov 18). Nothing written here.
-- (3) Jana Rush YES (Message-ID <010001a17d57b11a-068d8abc-f4f2-43f9-ae16-fc808942f992-000000@email.amazonses.com>, Oct 27 2026 12:31:01 UTC): no fs_partners row;
--     her answer is already in fs_guest_djs 63b7f595 notes. Only the Message-ID source tag is appended there.
-- (4) AlphaTheta grant f575d085: CT time added, stale Nov 1 "do not mention these calls again" line neutralized by an appended note (history kept).
--     Partner row a2e09e2e already shows the meeting (next_step Nov 23 3:30 pm CT / 4:30 pm ET, activity Nov 17 and Nov 19): no change.
begin;

-- (1) Night Out receipt
update fs_grant_deadlines
set notes = coalesce(notes,'') || E'\n[2026-11-19] RECEIPT LOGGED (Submittable auto-receipt, "Submission Recieved", from notifications@email.submittable.com to stephen@selassiefest.com, Sun Nov 1 2026 20:17:50 UTC = 2:17 pm CST, Message-Id <20261101201750.483f0807ce2f6799@email.submittable.com>): addressed to Stephen Henry; proposal is now in the Review Stage and will be evaluated by the selection panel; accepted proposals notified by early March 2027. Signed Night Out in the Parks Review Committee (noitp@chicagoparkdistrict.com); do not reply, questions go to the organization. Receipt carries no reference number, amount or attachments (Submittable ID 55665702 and $25,000 on $42,450 are from our own submission record, not this email). Receipt only: not an approval. [src:msgid-20261101201750.483f0807ce2f6799]'
where id = '38b44632-afbe-433e-8fea-4faf7aa379dc'
  and status = 'submitted'
  and coalesce(notes,'') not like '%msgid-20261101201750.483f0807ce2f6799%';

-- (3) Jana Rush source tag only
update fs_guest_djs
set notes = coalesce(notes,'') || E'\nSource: invitation-answer notice email, hello@selassiefest.com to stephen@selassiefest.com (cc one volunteer), Oct 27 2026 12:31:01 UTC, Message-ID <010001a17d57b11a-068d8abc-f4f2-43f9-ae16-fc808942f992-000000@email.amazonses.com>. [src:msgid-010001a17d57b11a]'
where id = '63b7f595-9646-4517-a34f-8075b9a6959c'
  and coalesce(notes,'') not like '%msgid-010001a17d57b11a%';

-- (4) AlphaTheta grant notes
update fs_grant_deadlines
set notes = coalesce(notes,'') || E'\n[2026-11-19] MEETING TIME (CT): Microsoft Teams meeting with Israel Rodriguez (Education & Training Manager, AlphaTheta Music Americas), Mon Nov 23, 2026, 3:30 pm CT = 4:30 pm ET. Israel sent the invitation (his Nov 16 email: "11/23 at 4:30pm EST"); Stephen says he accepted it Nov 18 (his word; no acceptance email on file). Teams link and agenda are not in the emails. SUPERSEDES the Nov 1 line "Do not mention these calls again until Stephen reports the results": that applied only to the phone calls batched into the Nov 4 call log, which are superseded by Israel''s Nov 11 reply (per the 2026-11-18 review); this Teams meeting is a scheduled meeting, not one of those calls, and may be mentioned and prepared for. Earlier history above is unchanged. [src:alphatheta-ct-time-2026-11-19]'
where id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e'
  and coalesce(notes,'') not like '%alphatheta-ct-time-2026-11-19%';

commit;

select 'night_out' as chk, g.id::text, g.status, g.next_step_due::text,
       (g.notes like '%msgid-20261101201750.483f0807ce2f6799%')::text as marker
from fs_grant_deadlines g where g.id = '38b44632-afbe-433e-8fea-4faf7aa379dc'
union all
select 'alphatheta_grant', g.id::text, g.status, g.next_step_due::text,
       (g.notes like '%alphatheta-ct-time-2026-11-19%')::text
from fs_grant_deadlines g where g.id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e'
union all
select 'alphatheta_partner', p.id::text, p.stage, p.next_step_due::text,
       (p.next_step like '%3:30 pm CT%' or exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%3:30 pm CT%'))::text
from fs_partners p where p.id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
union all
select 'jana_rush', d.id::text, d.status, null, (d.notes like '%msgid-010001a17d57b11a%')::text
from fs_guest_djs d where d.id = '63b7f595-9646-4517-a34f-8075b9a6959c'
union all
select 'floeter_grant_unchanged', g.id::text, g.status, g.next_step_due::text,
       (g.notes like '%CH2PR22MB2008124493BEAEBC1C1A6BAFF4682%')::text
from fs_grant_deadlines g where g.id = 'dc89e16f-2331-437b-b4dd-66a54ca834c5';
-- Expected: night_out submitted|2027-03-01|true ; alphatheta_grant submitted|2026-11-23|true ; alphatheta_partner in_conversation|2026-11-23|true ;
--           jana_rush yes|true ; floeter_grant_unchanged drafting|2026-12-02|true

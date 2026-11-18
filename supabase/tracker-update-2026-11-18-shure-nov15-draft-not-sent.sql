-- Nov 18, 2026: Shure CQ-1076. Stephen: NOTHING was sent on Sunday Nov 15. The Nov 15 .eml (Stephen to Cheryl, 20:21:02 UTC, in C:\Users\mkepr\Downloads\, not BOB) is an unsent draft, so it is NOT logged as an activity.
-- The first package to Shure went Nov 18, 3:51 am CT (signed letter, W-9, Form 8283 Part V, 6 photos). Notes only; safe to re-run.
begin;

update fs_partners set
  notes = coalesce(notes,'') || E'\n2026-11-18 NOT SENT: the Nov 15, 2026 email draft (Stephen to Cheryl, with W-9 and photos, MID <CO6P220MB03386C79BCDA4EF2B81A09D6D77D2@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>) was never sent (Stephen confirmed). Do not log it as an email. The first package reached Shure on Nov 18, 3:51 am CT.'
where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d'
  and coalesce(notes,'') not like '%2026-11-18 NOT SENT: the Nov 15%';

commit;

select (length(notes)-length(replace(notes,'2026-11-18 NOT SENT','')))/19 as not_sent_marker_count, stage, ball_with
from fs_partners where id = 'bf4f3ad5-727f-467b-8f88-de2ad65d9c4d';

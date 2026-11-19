-- 2026-11-18: (1) Stephen said HOLD JPMorgan Chase Foundation: we know no one to make an introduction for the major-celebrity/large-foundation rows; date cleared.
-- (2) Add the sent-copy Message-ID of the MPTF one-line reply to the Floeter grant row. Guarded; safe to re-run.
begin;
update fs_grant_deadlines set next_step='HELD by Stephen Nov 18, 2026: no one in our network to make the introduction, so no Chase banker request for now. Status stays drafting. Revisit only if Stephen names a contact (packet 07-chicago-fdn-relationship, file 11-jpmorgan-chase-foundation.md).',
 next_step_due=null,
 notes=coalesce(notes,'')||E'\n[2026-11-18] JPMorgan Chase Foundation HELD by Stephen (his word in chat): we know no one to introduce us; date cleared.'
where id='c9eb035a-d715-4833-a485-60a5aee16894' and coalesce(notes,'') not like '%JPMorgan Chase Foundation HELD by Stephen%';
update fs_grant_deadlines set notes=coalesce(notes,'')||E'\n[2026-11-18] Sent copy of our one-line reply to John Floeter: Message-ID <010001a1f225d771-5260404e-396e-4ff7-8fb0-24d0310523b5-000000@email.amazonses.com> (Nov 19 04:52:08 UTC = Nov 18 10:52 pm CST).'
where id='dc89e16f-2331-437b-b4dd-66a54ca834c5' and coalesce(notes,'') not like '%010001a1f225d771%';
commit;
select (select next_step_due from fs_grant_deadlines where id='c9eb035a-d715-4833-a485-60a5aee16894') chase_due,(select count(*) from fs_grant_deadlines where notes like '%010001a1f225d771%') mptf_mid;

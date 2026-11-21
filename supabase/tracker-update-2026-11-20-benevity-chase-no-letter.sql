-- 2026-11-20: Stephen (chat): he has NO Chase letter/routing number and the Nov 5 Chase meeting did NOT happen. Re-run safe.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select '3fe397bb-f5be-42a3-abc0-3df30b2b862a','note',
 '2026-11-20 Stephen confirmed in chat: the Nov 5 Chase meeting (Kenyatta Webb, Riverdale branch) did NOT happen and he has no Chase account verification letter or routing number. Donation Method (EFT) stays blocked on getting that letter; Benevity gifts pay by check meanwhile. Walmart Spark Good also needs banking details within 21 days of any award notice.',
 'confirmed','stephen@selassiefest.com','Stephen Henry', now()
where not exists (select 1 from fs_partner_activity where partner_id='3fe397bb-f5be-42a3-abc0-3df30b2b862a' and summary like '2026-11-20 Stephen confirmed in chat: the Nov 5 Chase meeting%');

update fs_partners set
  next_step = $t$Mon Nov 23, 2026 (online unless noted): (1) change the Benevity two-factor SMS phone (the old number is off); (2) complete the Declaration https://app.causes.benevity.org/attestations/840-423036705; (3) GET THE CHASE LETTER: the Nov 5 meeting never happened and there is no letter or routing number. Ask Chase for the account verification letter by secure message in Chase online banking, or rebook with Kenyatta Webb (Associate Relationship Banker, Riverdale, 708-841-3601; this is Stephen's own bank, not outreach). (4) Once the letter is in hand, submit the Donation Method (EFT) at https://causes.benevity.org/causesapp/payouts/add/840-423036705; Stephen enters the bank numbers himself. Gifts pay by check until then.$t$,
  notes = coalesce(notes,'')||E'\n[2026-11-20] Stephen: no Chase letter and the Nov 5 meeting did not happen. [src:benevity-chase-no-letter]'
where id='3fe397bb-f5be-42a3-abc0-3df30b2b862a' and coalesce(notes,'') not like '%src:benevity-chase-no-letter%';

update fs_grant_deadlines set
  notes = coalesce(notes,'')||E'\n[2026-11-20] Stephen: no Chase letter; Nov 5 meeting did not happen. EFT blocked until the letter is obtained. [src:benevity-chase-no-letter]'
where id='82577fd2-f0f2-4187-b5b4-2b5d95e7baec' and coalesce(notes,'') not like '%src:benevity-chase-no-letter%';
commit;
select (next_step like '%GET THE CHASE LETTER%')::text ok from fs_partners where id='3fe397bb-f5be-42a3-abc0-3df30b2b862a';

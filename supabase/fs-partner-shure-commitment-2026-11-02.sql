-- Shure: fill the missing commitment from the approval email (Cheryl Jennison Daproza, Oct 29, 2026, request CQ-1076).
-- Source: C:\Users\mkepr\Downloads\BOB\Shure_Donation_Request_CQ-1076_-_Ras_Tafari_Inc.eml
-- commitment_value left empty on purpose: the email states no dollar value and none is recorded elsewhere.
begin;
update fs_partners set
  commitment = 'Product donation approved Oct 29, 2026 (request CQ-1076): 12 pairs of SRH440A headphones and 2 SM58 microphones, shipping to 1401 E. 71st St.',
  updated_at = now()
where name = 'Shure' and stage = 'committed' and commitment is null;
select 'shure commitment' as check, left(commitment, 80) as v from fs_partners where name = 'Shure';
commit;

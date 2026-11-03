-- Deep clean pass 2 (Nov 3, 2026). Run after fs-partner-cleanup-2026-11-03.sql. Safe to re-run.
-- Problem: pass 1 rewrote stale dates, but 20+ boilerplate next steps still say "Call" / "Follow up by phone"
-- for partners with NO phone number anywhere on the row (only an email or an address). Fix the instruction.
begin;
create temp table _nophone on commit drop as
  select id from fs_partners p
  where nullif(trim(coalesce(p.phone,'')),'') is null
    and not exists (select 1 from jsonb_array_elements(p.contacts) c where nullif(trim(coalesce(c->>'phone','')),'') is not null);

update fs_partners set next_step = regexp_replace(next_step, '\. Call\.$', '. No phone on file: find a number or stop by in person.'), updated_at = now()
  where id in (select id from _nophone) and next_step ~ '^Follow-up emailed Oct 2[68]\. No reply logged\. Call\.$' and name !~* 'roland';
update fs_partners set next_step = regexp_replace(next_step, 'Follow up by phone\.$', 'No phone on file: find a number or stop by in person.'), updated_at = now()
  where id in (select id from _nophone) and next_step ~ '^(Wave 2 letter sent Oct 19|Letter hand-delivered or emailed Oct 19|Letter hand-delivered to CPD HQ Oct 19)\. No reply logged yet\. Follow up by phone\.$';
commit;

select 'boilerplate call rows still lacking a phone' as check, count(*)::text as n from fs_partners p
  where p.next_step ~ '(Call\.$|Follow up by phone\.$)' and p.id in (select id from fs_partners p2 where nullif(trim(coalesce(p2.phone,'')),'') is null and not exists (select 1 from jsonb_array_elements(p2.contacts) c where nullif(trim(coalesce(c->>'phone','')),'') is not null))
union all select 'rows now saying no phone on file', count(*)::text from fs_partners where next_step like '%No phone on file%';

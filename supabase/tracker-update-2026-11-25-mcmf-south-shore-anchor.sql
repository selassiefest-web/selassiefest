-- MCMF South Shore anchor, checked Nov 25, 2026 on the City's page https://www.chicago.gov/city/en/depts/fss/provdrs/youth/news/2024/december/-local-organizations-to-present-youth-focused-community-plans-at.html :
-- it lists Lost Boyz Inc. as the Community Anchor Organization for South Shore and Project Exploration for Austin (December 2024; the 2027 assignment is NOT confirmed). Notes only. Safe to re-run.
begin;
update fs_partners set
  notes = coalesce(notes, '') || ' | [mcmf-anchor 2026-11-25] City of Chicago December 2024 announcement (verified Nov 25): Lost Boyz Inc. is the My CHI. My Future. Community Anchor Organization for South Shore; Project Exploration is the Austin anchor. Anchors host monthly partner convenings and a community plan. This is a 2024 listing; whether either holds the 2027 role needs DFSS to confirm. Pasted research also names Urban Male Network as the 2025 Safe Spaces partner for South Shore and Greater Grand Crossing, and a My CHI. My Future. partner portal (partners.mychimyfuture.org): not verified by us. Lost Boyz Inc. is a possible MCMF South Shore contact once Deputy Mayor Humphries confirms what he meant; no contact person or address found yet.',
  updated_at = now()
where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84'
  and coalesce(notes, '') not like '%[mcmf-anchor 2026-11-25]%';
commit;
select (notes like '%[mcmf-anchor 2026-11-25]%') as marked from fs_partners where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84';

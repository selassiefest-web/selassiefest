-- 2026-11-20: reviewer corrections to the stale-next-step triage (rows whose parked reason was inaccurate). Re-run safe.
begin;
-- Hanchi/Hanpin: emailed sales2@hanpin.com.tw Nov 1; online follow-up, not parked
update fs_partners set ball_with='them', next_step_due='2026-12-02',
  next_step=$t$No reply to the Nov 1 email to sales2@hanpin.com.tw. One follow-up on the same thread, or the contact page at hanpin.com.tw (online only). Our own follow-up date, not a partner commitment.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage correction] un-parked: an email address and contact page exist.'
where id='feb24132-508d-442e-945e-c2ccff03dd06' and ball_with='parked';
-- CAPS 3rd District: unconfirmed email address exists; nudge with caveat like the 4th District row
update fs_partners set ball_with='them', next_step_due='2026-12-03',
  next_step=$t$Oct 18 letter and Oct 26 follow-up went to CAPS.003District@chicagopolice.org (address unconfirmed). One more email nudge to that address, noting it is unconfirmed; no call or visit (online only). Our own follow-up date, not a partner commitment.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage correction] un-parked: unconfirmed email address on file.'
where id='0914b657-e197-4e5b-9938-1d8030375ff8' and ball_with='parked';
-- Reword parked reasons only (still parked)
update fs_partners set next_step=$t$PARKED: Nov 1 emails already tried at unverified registry addresses (QQ/163); no verified address. Reactivate only if a verified email or the Alibaba storefront contact route is authorized.$t$
where id in ('ad2d2b98-9709-4770-a6f0-f9366647dab2','6217cded-43c7-48ad-9b47-e03881a186f2') and ball_with='parked';
update fs_partners set next_step=$t$PARKED: no verified youth-ministry email or web form on file. Find one online first (church website or published contact), then send one email nudge. No visit or call (online only).$t$
where id in ('91e5ce1d-f39d-4d9c-968d-00ef53b496ce','afe8cf92-3c32-409c-bca7-87602ecf097c') and ball_with='parked';
update fs_partners set next_step=$t$PARKED: paperwork was delivered in person and the channel is in-person only (no email or web form logged). Check that the Target GiftCards grant row carries its own dated step.$t$
where id='7d576c3f-067d-4157-a334-70e3a8e2d4d1' and ball_with='parked';
update fs_partners set next_step=$t$PARKED: the CPS school must apply first. Revisit when the school applies (email on file).$t$
where id='86949e94-98ae-46c1-82c6-41445f7f3823' and ball_with='parked';
update fs_partners set next_step=$t$PARKED: Fry deadline cycle is Mar 1 / Jun 1 / Sep 1. Revisit before Mar 1, 2027 (email on file).$t$
where id='5be10ce3-36a0-4789-bed9-c18d01c2fd28' and ball_with='parked';
commit;
select count(*) filter (where ball_with='parked') parked, count(*) filter (where next_step_due between '2026-11-23' and '2026-12-18') dated from fs_partners where notes like '%[2026-11-20 triage]%';

-- 2026-11-20: Stephen's answers on the 25 "needs Stephen" stale rows (chat). Benevity/Deed handled separately (agent check). Re-run safe.
begin;
-- 1 Park Advisory Councils fall under the CPD hold (13 rows; Washington Park keeps an internal dated step)
update fs_partners set ball_with='cpd_hold', next_step_due=null,
  next_step=$t$ON CPD HOLD (Stephen, Nov 20, 2026): Park Advisory Councils are covered by the CPD hold. No outreach until the Chicago Park District's GO. Old step (council-meeting visit / call) retired.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: PACs fall under the CPD hold; moved to cpd_hold, no date. Was due '||next_step_due::text||'.'
where id in ('c5f17fd1-ff09-49b7-a70e-a2b4ecf58674','54ef7d3c-6d1b-485f-9ecb-ebfffbcb69b2','2644e48e-5449-4100-a4cd-ac4ba484d624','6f6a62cb-6680-4ddc-bdc8-2648e828966c','533eb164-0103-4f9a-80b4-e7e4f1333ba5','19cafc3b-cada-420d-8d7e-f54db34d724a','03537e93-7c7d-4e94-8652-24f6b5016b03','65ed593b-d7f5-4df0-b497-4850aa91fea1','080f16d7-be51-4979-b1c9-9eb630ff7345','57eb3d08-1eba-4cfc-93c2-ea9ffa302038','9fc1db7b-5b95-4c83-b883-1de23e65b489','f64cf078-9acd-4ab2-95a8-63a4bfc0e166','2d81617f-29fa-4765-9653-42b4eec6de41')
  and next_step_due < '2026-11-20' and ball_with <> 'cpd_hold';
update fs_partners set ball_with='cpd_hold', next_step_due='2026-11-23',
  next_step=$t$ON CPD HOLD for any outreach. INTERNAL step Mon Nov 23, 2026: ask Albert Harris (Washington Park PAC member) what came of the Nov 18 council meeting and whether the letter of support was raised. No outreach to the council or CPD until the CPD GO.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: PACs fall under the CPD hold. Internal check with Albert Harris on the Nov 18 meeting outcome.'
where id='e8aed0e7-b9df-49c9-847c-b7de0242ca1a' and next_step_due < '2026-11-20';
-- 2 Purple Turtle: she has not answered since Nov 4; check-in to Tonia Evans approved (draft only)
update fs_partners set ball_with='us', next_step_due='2026-11-23',
  next_step=$t$Tamera has not answered since Nov 4 (Stephen, Nov 20). Check-in to Tonia Evans (toniaevans2002@icloud.com) APPROVED under the hold: draft at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\purple-turtle\checkin-tonia-2026-11-20.txt; send after Stephen says "send". No park role or date; anything in the park only if the Park District approves.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: no answer from Tamera since Nov 4; OK to send a check-in to Tonia Evans.'
where id='edbc5d31-127a-4bc6-9182-f1b5fb4ef005' and next_step_due < '2026-11-20';
-- 3 and 4 park
update fs_partners set ball_with='parked', next_step_due=null,
  next_step=$t$PARKED (Stephen, Nov 20, 2026). Loop Capital (info@ and media@loopcapital.com) emailed Nov 6; no reply. Reactivate only if Stephen says so.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: park it.'
where id='513140cb-3cb7-483e-965b-2b822a84414a' and next_step_due < '2026-11-20';
update fs_partners set ball_with='parked', next_step_due=null,
  next_step=$t$PARKED (Stephen, Nov 20, 2026). South Shore Chamber (Tonya Trice) was left out of bulk sends; no new email now. Reactivate only if Stephen says so.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: park it.'
where id='27f43bee-af37-425d-81b0-9741d922e9b3' and next_step_due < '2026-11-20';
-- 5 South Shore Works: ask Val Free (NNA)
update fs_partners set ball_with='us', next_step_due='2026-11-24',
  next_step=$t$Ask Val Free (NNA) by email or text for a working contact at South Shore Works (Stephen, Nov 20: yes). Due Tue Nov 24, 2026; then log the answer.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: yes, ask Val Free (NNA).'
where id='cc30737e-25d1-4d7c-b299-bedb048c528b' and next_step_due < '2026-11-20';
-- 7 Polk Bros partner row
update fs_partners set ball_with='us', next_step_due='2027-06-10',
  next_step=$t$Nov 20, 2026: Fluxx eligibility quiz said not eligible (under 1 year, no 990 yet). Re-apply: file the first Form 990 by May 14, 2027, then after Jun 9, 2027 retake the quiz at https://polkbrosfdn.fluxx.io/ and submit the Introduction by Aug 20, 2027. Grant row bbb1ebb4 carries the detail.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: triage. Updated to the 2027 re-apply plan.'
where id='e3d6dd1d-c5e2-40cd-899c-506f7cf429dd' and next_step_due < '2026-11-20';
-- 8 drop the four Alibaba suppliers
update fs_partners set stage='not_qualified', ball_with='parked', next_step_due=null,
  next_step=$t$DROPPED (Stephen, Nov 20, 2026): no Alibaba/Accio Contact Supplier route. Do not revive.$t$,
  notes=coalesce(notes,'')||E'\n[2026-11-20 triage] Stephen: drop them.'
where id in ('f68dae89-0362-4f33-b672-eeed93463a5e','0bf8da3d-a9f2-4f57-8780-d5ab0c128dd4','7206a50c-c073-4e17-9de3-2dcd0631e90d','40494cb4-0dc5-4f91-9a63-190dfca287ec') and next_step_due < '2026-11-20';
commit;
select count(*) filter (where next_step_due < '2026-11-20') still_stale from fs_partners;

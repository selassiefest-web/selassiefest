-- Cliff Dwellers Arts Foundation application SENT by Stephen from stephen@selassiefest.com, Mon Nov 23 2026 11:54 pm CT (Tue 24 Nov 05:54:03 +0000)
-- To artsfoundation@cliff-chicago.org, cc stephen@. 3 PDFs: application+narrative+budget, IRS letter, board list. Ask $2,000 (tiers $1,000 / $500) for Spring 2027 round. Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-23', amount_requested=2000,
  amount='up to $2,000 (cap confirmed in guidelines)', verified=true, verified_on='2026-11-23',
  eligibility='Chicago-area arts orgs and individuals; grants normally up to $2,000; no capital, pre-request expenses or endowment',
  next_step_due='2026-12-08',
  next_step='Application emailed Nov 23, 2026 (11:54 pm CT) to artsfoundation@cliff-chicago.org for the Spring 2027 round (deadline Fri Mar 26, 2027, decision mid-June 2027); asked them to confirm it reaches the Spring round. If no reply, one email nudge Dec 8. Do not resend.',
  notes=case when coalesce(notes,'') like '%CO6P220MB0338E18FB5FB53C2DA660B1CD7442%' then notes else coalesce(notes,'')||E'\n2026-11-23: Stephen sent the application from stephen@selassiefest.com to artsfoundation@cliff-chicago.org (cc stephen@), 11:54 pm CT, with RTI-CDAF-Application-Narrative-Budget.pdf, RTI-IRS-Determination-Letter.pdf, RTI-Board-of-Directors.pdf. Message-ID <CO6P220MB0338E18FB5FB53C2DA660B1CD7442@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>. Sources: cliff-chicago.org/foundation, CDAF-Grant-Guidelines-2025.pdf.' end
where id='0768f6c3-9722-427b-8506-91cd75b2044e';
select funder,status,submitted_on,amount_requested,next_step_due from fs_grant_deadlines where id='0768f6c3-9722-427b-8506-91cd75b2044e';
commit;

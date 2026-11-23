-- Kars4Kids Small Grant application SUBMITTED Nov 23, 2026 (Thank You page seen). Safe to re-run.
begin;
update fs_grant_deadlines set
  status='submitted', submitted_on='2026-11-23', verified=true, verified_on='2026-11-23',
  amount_requested=5000,
  next_step='Submitted online Nov 23, 2026. No phone consults; decision typically 4-6 months, possibly up to a year (about Mar-Nov 2027). No action unless they write; watch stephen@selassiefest.com. Check-in only Apr 1, 2027. Fit risk acknowledged: primary mission must be children; framed on the Rainbow DJ Lab and generations through music.',
  next_step_due='2027-04-01',
  notes = coalesce(notes,'') || E'\n2026-11-23: Kars4Kids online Small Grant form SUBMITTED by Stephen (Thank You page seen). 9 fields, no character limits, EIN field, IRS letter uploaded, no deadline. Summary: mission and generations-through-music heritage, Rainbow DJ Lab opening Jan 12, 2027, SelassieFest. No dollar ask stated in the form text; award typically $5,000.'
where id::text like 'd8cea2da%'
  and coalesce(notes,'') not like '%2026-11-23: Kars4Kids online Small Grant form SUBMITTED%';
commit;
select status, submitted_on, amount_requested, next_step_due from fs_grant_deadlines where id::text like 'd8cea2da%';

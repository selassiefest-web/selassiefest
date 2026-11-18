-- Run ONLY when CPD gives the GO for Full Spectrum (see legal/documents-inbox/CPD-HOLD-RULES.md).
-- Releases every held partner row to us, due today, with a dated note. Safe to re-run.
begin;
update fs_partners set
  ball_with = 'us',
  next_step_due = current_date,
  notes = coalesce(notes,'') || E'\n' || current_date || ': CPD GO received, hold released.'
where ball_with = 'cpd_hold';
select count(*) as released_today from fs_partners where ball_with = 'us' and notes like '%' || current_date || ': CPD GO received%';
commit;

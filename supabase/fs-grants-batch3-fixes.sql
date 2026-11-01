-- Follow-up to fs-grants-batch3.sql (2026-10-31): details confirmed from the funders' own pages. Idempotent.
begin;
update fs_grant_deadlines set kind='dated', deadline_date='2027-01-01', verified=true,
  amount='up to $10,000+ (form offers $10,000+ or Other)',
  notes='CONFIRMED 2026-10-31 on the live application form (form.jotform.com/262735554942162): 2027 Community Grant applications due Jan 1, 2027; status update within 4 weeks. For creators, organizations and community leaders with community projects in Music, Art or the Outdoors. No geographic restriction stated on the form (other Levitate programs are Massachusetts-only), so still ask whether Chicago is eligible. Fits free arts workshops, youth mentorship, community stage.'
where funder='Levitate Foundation' and program='Community Grants (Passion Projects)';
update fs_grant_deadlines set verified=true,
  notes='CONFIRMED 2026-10-31 on driehausfoundation.org/funding: applications are BY INVITATION ONLY. Any aligned initiative may contact staff first; expect a few months before an invitation, and they prefer learning about an initiative in steps. Not a DJ Lab funder (arts education and learning are excluded). Category C: Chicago-rooted art forms, project budgets $30,000-$1 million. Contact Lori Dimun, loridimun@driehausfoundation.org, 312-641-5772 x113. Also on the BBPAC tracker.'
where funder='Driehaus Foundation' and program like 'Arts and Culture%';
commit;

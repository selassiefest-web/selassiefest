-- Adds grant and address-filing dates to the live `deadlines` table so the
-- daily send-deadline-reminders email (2 weeks and 1 week out) covers them.
-- Additive: inserts only, on conflict do nothing. One row corrected (Night Out close).
-- Dates are from Seabury's cycle page (checked 2026-10-20), the Walmart/Target/ComEd/Field
-- rows in fs_grant_deadlines, and the Night Out kit. Estimates are confirmed=false.
update deadlines
   set due_date = '2026-12-08',
       title = 'Night Out in the Parks — call for proposals closes (estimated; 2026 call closed Dec 8)'
 where title = 'Night Out in the Parks — call for proposals closes (estimated)'
   and due_date = '2026-12-01'
   and not exists (select 1 from deadlines where due_date = '2026-12-08' and title like 'Night Out in the Parks — call for proposals closes%');

insert into deadlines (title, description, due_date, category, source_url, confirmed)
select * from (values
('Address change: mail IRS Form 8822-B and confirm Illinois change', 'Internal target. Sign Form 8822-B and mail Certified to IRS, Kansas City, MO 64999; confirm Illinois shows 1401 E. 71st St.', '2026-10-30'::date, 'filing_deadline', 'https://www.irs.gov/filing/where-to-file-form-8822-b', true),
('Springboard Foundation applications open (November)', 'Weekday 3-7 pm school-year class only. Pick the class slot first.', '2026-11-02'::date, 'estimated_window', null, false),
('Walmart Spark Good local grants (FY27 Cycle 3) close', '$250-$5,000; needs Spark Good account and Deed verification first.', '2026-11-30'::date, 'filing_deadline', 'https://www.walmart.org/how-we-give/program-guidelines/spark-good-local-grants-guidelines', true),
('Seabury Foundation: invitations to full proposal sent', 'LOI was received. Watch grants@seaburyfoundation.org; invitation arrives on or before this date.', '2026-12-11'::date, 'event', 'https://seaburyfoundation.org/applying-for-a-grant/', true),
('Target GiftCards cycle ends', 'Local store; avg $25-50, max $500/yr; needs IRS letter.', '2026-12-31'::date, 'filing_deadline', 'https://corporate.target.com/about/purpose-history/communities/grants-corporate-giving', true),
('ComEd Powering the Arts opens (estimated)', 'Estimate from 2026 (opened Jan 12). Chicago arts orgs in ComEd territory.', '2027-01-11'::date, 'estimated_window', 'https://leagueofchicagotheatres.org/comedpoweringthearts/', false),
('Seabury Foundation: full proposal due (only if invited)', 'Spring 2027 Chicago cycle. Awards announced May 14, 2027.', '2027-02-05'::date, 'filing_deadline', 'https://seaburyfoundation.org/applying-for-a-grant/', true),
('ComEd Powering the Arts closes (estimated)', 'Estimate: 2026 closed Mar 13, 2025 closed Mar 28.', '2027-03-12'::date, 'estimated_window', 'https://leagueofchicagotheatres.org/comedpoweringthearts/', false),
('Field Foundation A Road Together opens (estimated)', 'Estimate from past pattern (mid-April to mid-May). Needs Chicago arts org, budget $25K-$1M.', '2027-04-15'::date, 'estimated_window', 'https://fieldfoundation.org/how-to-apply/', false),
('Seabury Foundation: Spring 2027 award decisions', 'Decisions sent by this date.', '2027-05-14'::date, 'event', 'https://seaburyfoundation.org/applying-for-a-grant/', true),
('Field Foundation A Road Together closes (estimated)', '2026 closed May 15.', '2027-05-15'::date, 'estimated_window', 'https://fieldfoundation.org/how-to-apply/', false),
('DCASE CityArts / Neighborhood Access Program deadlines (estimated)', '2027 guidelines not yet published; 2026 CityArts closed Jun 3. Needs 12 months incorporated and a Chicago office.', '2027-05-20'::date, 'estimated_window', 'https://www.chicago.gov/city/en/depts/dca/supp_info/cityarts.html', false)
) as v(title, description, due_date, category, source_url, confirmed)
on conflict (title, due_date) do nothing;

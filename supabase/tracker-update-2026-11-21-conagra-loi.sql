-- Conagra Brands Foundation LOI: funder study done, ask tailored to food insecurity (Stephen, Nov 21, 2026).
-- Safe to re-run: notes only appended once (marker), other fields are plain sets.
begin;

update fs_grant_deadlines set
  amount_requested = 5700,
  verified_on = '2026-11-21',
  next_step = 'Jan 4, 2027: Stephen registers in CyberGrants (https://www.cybergrants.com/conagra/welcomepage/), submits the Letter of Intent (not the Special Event form) for class snacks, $5,700 = 19 of 39 Tuesdays. Answers: C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\conagra\conagra-loi-answers.md. Before Jan 4: check IRS address record, re-read the Nov 26 CPD outcome.',
  notes = case when coalesce(notes,'') like '%[conagra-redo 2026-11-21]%' then notes else coalesce(notes,'') || ' | [conagra-redo 2026-11-21] Funder page read in Chrome: Conagra funds initiatives addressing food insecurity with a clear community focus plus farm-to-fork entrepreneurial skills; 509(a)(1)/(2)/(3) public charities eligible; excludes individuals, fiscal agents, political, sectarian religious; one LOI Jan 1-31, 2027, rolling, staff invite a full application; no award range or limits visible pre-login. Stephen decided Nov 21: ask $5,700 (snack slice only, 19 of 39 Tuesdays), no nutrition-option commitment (supersedes the $11,700 fallback in the Oct 31 note). Barry Callebaut not yet asked (referral via LUMA8 Nov 23).' end,
  updated_at = now()
where id = 'cbc6cfeb-6afd-40e1-9260-b2b8f1bc7459';

update fs_partners set
  next_step = 'Route known: the Conagra grant is an online LOI in CyberGrants, Jan 1-31, 2027 (grant row cbc6cfeb-6afd-40e1-9260-b2b8f1bc7459). No separate inquiry needed; one LOI per org. Stephen files Jan 4, 2027.',
  next_step_due = '2027-01-04',
  notes = case when coalesce(notes,'') like '%[conagra-redo 2026-11-21]%' then notes else coalesce(notes,'') || E'\n[conagra-redo 2026-11-21] Giving route found (CyberGrants LOI window Jan 1-31, 2027); replaces the find-the-giving-form step. Details in the grant row.' end,
  updated_at = now()
where id = '2bbb84b0-98e2-4e18-b567-9c35b331b6d4';

select id, amount_requested, left(next_step,80) as next_step, verified_on from fs_grant_deadlines where id = 'cbc6cfeb-6afd-40e1-9260-b2b8f1bc7459';
select id, next_step_due from fs_partners where id = '2bbb84b0-98e2-4e18-b567-9c35b331b6d4';
commit;

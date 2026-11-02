-- Aerie Real Foundation: Applicant Profile created and application DRAFT saved Nov 2, 2026 (3:02 pm CT). NOT submitted.
update fs_grant_deadlines set status = 'drafting',
  next_step = 'Aerie profile CREATED and application DRAFT SAVED Nov 2 (stephen@selassiefest.com portal; ask $7,800, Women at the Decks guest DJ series, Jan 12 to Dec 28, 2027). STILL EMPTY, need Paul Kelly: (1) Organizational Budget = projected total expenses for this fiscal year (new org; DJ Lab first-year budget is $134,670 if he wants a stand-in) and (2) Program Services %. Then Stephen reviews all, clicks Mark Complete and Submit. Also check the hidden "funding from AEO in the past year" question (answer No). Next proposal deadline June 1, 2027, so no rush; message to Paul drafted.',
  next_step_due = date '2026-11-09', updated_at = now()
where funder ilike '%aerie%';

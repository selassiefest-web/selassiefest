-- Aerie: Organizational Budget filled with the Full Spectrum / Rainbow DJ Lab budget ($134,670) at 3:04 pm CT Nov 2, 2026. Only Program Services % still empty.
update fs_grant_deadlines set
  next_step = 'Aerie application DRAFT saved Nov 2, 3:04 pm CT (NOT submitted). Organizational Budget FILLED with the Rainbow DJ Lab / Full Spectrum 2027 budget ($134,670 = $75,123 cash + $59,547 equipment, labeled as planning figures for a new org). ONLY Program Services % is still empty (Paul to give a number; do not guess). Also check the hidden "funding from AEO in the past year" question (No). Then Stephen reviews, Mark Complete, Submit. Next proposal deadline June 1, 2027.',
  updated_at = now()
where funder ilike '%aerie%';

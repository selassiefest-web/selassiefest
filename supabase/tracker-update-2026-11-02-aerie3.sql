-- Aerie: Program Services % filled (about 95%, planned for 2027) at 3:07 pm CT Nov 2, 2026. All required fields now filled; NOT submitted.
update fs_grant_deadlines set
  next_step = 'Aerie application DRAFT saved Nov 2, 3:07 pm CT (NOT submitted). ALL fields filled. Program Services % = about 95% planned for 2027 (of $75,123 cash costs, about $71,000 program and about $4,100 general: insurance $3,500 + class app/hosting $600; no fundraising line; from Claude outputs/best-buy/rti-2027-budget.html). Paul to confirm the split. If Aerie rejects or Paul disagrees, use the "new organization, no completed year" wording. Check the hidden "funding from AEO in the past year" question (No). Then Stephen reviews, Mark Complete, Submit. Next proposal deadline June 1, 2027.',
  updated_at = now()
where funder ilike '%aerie%';

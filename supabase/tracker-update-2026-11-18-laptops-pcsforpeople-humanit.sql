-- 2026-11-18: 13 DJ-station laptops (about $20,787 at Apple prices; Stephen confirmed Windows laptops are fine). Two new tracker rows from the Nov 18 study:
-- (1) PCs for People: pricing inquiry SENT at Stephen's "send" (rti-outreach, Resend 01a1f247-393b-7a39-8942-8800e1c267ed) to partner@pcsforpeople.org, cc stephen@, with the pitch deck.
-- (2) Human-I-T: free nonprofit membership (refurbished laptops 40-60% off); Stephen creates the account and uploads ID himself. Guarded by funder name; safe to re-run.
begin;
insert into fs_grant_deadlines (funder, program, kind, status, level, project, priority, verified, active, url, eligibility, next_step, next_step_due, notes)
select 'PCs for People', 'Low-cost refurbished laptops for nonprofits (13 DJ-station laptops)', 'rolling', 'submitted', 'national', 'djclass', 2, true, true,
 'https://www.pcsforpeople.org/tech-for-nonprofits/',
 'Any 501(c)(3), documentation of 501(c)(3) status; orders of 6 or more by email to partner@pcsforpeople.org; no computers with Microsoft Office 2019 for community organizations. A purchase at low cost, not a donation.',
 'Pricing inquiry SENT Nov 18, 2026 (Resend 01a1f247-393b-7a39-8942-8800e1c267ed) for 13 refurbished Windows laptops that run Serato and djay Pro; asked configurations, bulk price, Chicago shipping, documents needed. Wait for a reply; if silent, one email nudge Dec 2 (internal).',
 '2026-12-02',
 'Study Nov 18, 2026 (pcsforpeople.org/tech-for-nonprofits): St. Paul MN based, ships nationally; online store caps at 5 computers. Low-cost PURCHASE, not a donation. Dell has no open door (tracker row Dell not_eligible); Best Buy request (submitted Oct 31) still pending.'
where not exists (select 1 from fs_grant_deadlines where funder='PCs for People');
insert into fs_grant_deadlines (funder, program, kind, status, level, project, priority, verified, active, url, eligibility, next_step, next_step_due, notes)
select 'Human-I-T', 'Free nonprofit membership: refurbished laptops 40-60% off (13 DJ-station laptops)', 'rolling', 'to_research', 'national', 'djclass', 2, true, true,
 'https://store.human-i-t.org/non-profit-membership/',
 'Any 501(c)(3): upload IRS determination letter (or state registration or Form 990) and a photo ID of an organization leader; approval in 1-3 business days; membership free. A DISCOUNT on refurbished laptops (Windows, Chromebook, Apple), 1-year warranty, bulk quote; Illinois delivery unconfirmed.',
 'Stephen creates the free nonprofit account at the URL and uploads the IRS determination letter and his photo ID himself (account creation and ID are his). After approval (1-3 business days), request a bulk quote for 13 Windows laptops and confirm Chicago delivery.',
 '2026-11-24',
 'Study Nov 18, 2026 (store.human-i-t.org): discount, not a donation; free devices usually come through grants or corporate programs with limited supply. Stephen confirmed Windows laptops are fine for the DJ Lab.'
where not exists (select 1 from fs_grant_deadlines where funder='Human-I-T');
commit;
select funder, status, next_step_due from fs_grant_deadlines where funder in ('PCs for People','Human-I-T') order by funder;

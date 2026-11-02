-- Full tracker audit, Nov 2, 2026 (Stephen: "The entire tracker needs your attention"). Safe to re-run.

-- 1. Retired girls-only "Empress Decks" track: the only model is the one DJ Lab (guest woman DJ weekly).
--    Fix the public pitch/ask text on partner pages (9 rows). Notes (internal) left as research history.
update fs_partners set
  ask   = replace(replace(replace(replace(replace(replace(replace(replace(ask,
    'a joint Empress Decks introduction for girls who want to try DJing', 'sharing the free Rainbow DJ Lab with the young people you serve'),
    'a short entrepreneurship conversation for Empress Decks', 'a short entrepreneurship conversation for the Rainbow DJ Lab students'),
    'an Empress Decks or heritage-program story pitch', 'a story pitch on the free Rainbow DJ Lab'),
    'a brief Empress Decks entrepreneurship session', 'a brief Rainbow DJ Lab entrepreneurship session'),
    'an Empress Decks invitation for interested girls and caregivers', 'a Rainbow DJ Lab invitation for interested young people and caregivers'),
    'an Empress Decks class-interest flyer', 'a Rainbow DJ Lab class-interest flyer'),
    'an Empress Decks invitation', 'a Rainbow DJ Lab invitation'),
    'an Empress Decks introduction and an invitation', 'a Rainbow DJ Lab introduction and an invitation'),
  pitch = replace(replace(replace(replace(replace(replace(replace(replace(pitch,
    'a joint Empress Decks introduction for girls who want to try DJing', 'sharing the free Rainbow DJ Lab with the young people you serve'),
    'a short entrepreneurship conversation for Empress Decks', 'a short entrepreneurship conversation for the Rainbow DJ Lab students'),
    'an Empress Decks or heritage-program story pitch', 'a story pitch on the free Rainbow DJ Lab'),
    'a brief Empress Decks entrepreneurship session', 'a brief Rainbow DJ Lab entrepreneurship session'),
    'an Empress Decks invitation for interested girls and caregivers', 'a Rainbow DJ Lab invitation for interested young people and caregivers'),
    'an Empress Decks class-interest flyer', 'a Rainbow DJ Lab class-interest flyer'),
    'an Empress Decks invitation', 'a Rainbow DJ Lab invitation'),
    'an Empress Decks introduction and an invitation', 'a Rainbow DJ Lab introduction and an invitation'),
  updated_at = now()
where ask ~* 'empress deck' or pitch ~* 'empress deck';

update fs_partners set
  pitch = regexp_replace(pitch, 'We are building a girls. track of our own, Empress Decks, and we would value', 'We run a weekly guest woman DJ series inside the Rainbow DJ Lab, and we would value'),
  ask   = regexp_replace(coalesce(ask,''), 'We are building a girls. track of our own, Empress Decks, and we would value', 'We run a weekly guest woman DJ series inside the Rainbow DJ Lab, and we would value'),
  updated_at = now()
where name like 'We Rock! Chicago%' and (pitch ~* 'empress deck' or ask ~* 'empress deck');

-- 2. Waiting-on-reply partner rows with no follow-up date: match the dates already on the grant rows.
update fs_partners set next_step_due = date '2026-11-30', updated_at = now() where name like 'My CHI. My Future. Micro-Grants%' and next_step_due is null;
update fs_partners set next_step_due = date '2026-12-01', updated_at = now() where name = 'Siragusa Family Foundation' and next_step_due is null;
update fs_partners set next_step_due = date '2026-11-16', updated_at = now() where name in ('Archer Daniels Midland','SocialWorks (Chance the Rapper)') and next_step_due is null;
update fs_partners set next_step_due = date '2026-11-30', updated_at = now() where name like 'LPMC Foundation%' and next_step_due is null;
update fs_partners set next_step_due = date '2026-11-13', updated_at = now(), next_step = 'Watch for the Shure shipment (12 SRH440A headphones, 2 SM58 mics) to 1401 E. 71st St.; when it arrives, email Cheryl (daprozc@shure.com), then the thank-you note. Check Nov 13.' where name = 'Shure' and next_step_due is null;
update fs_partners set next_step_due = date '2026-11-26', updated_at = now(), next_step = 'HOLD: ask Tonya Trice for the QLP arts committee introduction only after CPD gives the GO for Full Spectrum. Revisit at the ARCS check-in Nov 26.' where name like 'South Shore Chamber CDC%' and next_step_due is null;

-- 3. Submitted grants with no follow-up date.
update fs_grant_deadlines set next_step_due = date '2027-03-01', updated_at = now() where funder = 'Chicago Park District' and status = 'submitted' and next_step_due is null; -- CPD notifies accepted proposals by early March 2027
update fs_grant_deadlines set next_step_due = date '2026-11-30', updated_at = now() where funder = 'Delta Air Lines' and status = 'submitted' and next_step_due is null; -- Delta answers within 4 weeks; do not contact before

-- 4. Springboard: the 2027 Rainbow Wednesdays $26,320 cash figure is stale; the current plan is $75,123 operating + $59,547 equipment = $134,670 (full-spectrum/dj-lab-2027.html).
update fs_grant_deadlines set notes = concat_ws(E'\n | ', notes, '2026-11-02 CORRECTION: ignore the earlier "Lab $75,123 + RW $26,320" cash sum. Current source of truth (dj-lab-2027.html): operating $75,123 (includes Rainbow Wednesdays), equipment $59,547 in-kind, everything $134,670.'), updated_at = now() where funder = 'Springboard Foundation';

-- HYPERFOCUS items 11-13 (Stephen, Nov 25, 2026): funding routes, network organizations, introduction-only funders.
-- Every fact marked VERIFIED was read on the funder's own page on Nov 25, 2026 (URL in the note); NOT verified means the page
-- would not load or does not say it. The pasted ChatGPT research was NOT used as evidence. Safe to re-run (every write is guarded by
-- a not-exists check or the marker [prospects-2026-11-25]).
-- Eligibility read for Ras Tafari Inc.: incorporated Jun 8, 2026; 501(c)(3) effective Jun 9, 2026; FY Jan 1-Dec 31; no Form 990 filed yet.
begin;

-- ============ A. NEW funder rows (fs_grant_deadlines) ============
insert into fs_grant_deadlines (funder, program, kind, status, level, project, priority, opens_date, deadline_date, amount, url,
  eligibility, verified, verified_on, next_step, next_step_due, notes)
select v.funder, v.program, v.kind, v.status, v.level, 'djclass', v.priority, v.opens::date, v.deadline::date, v.amount, v.url,
  v.eligibility, v.verified, date '2026-11-25', v.next_step, v.due::date, v.notes
from (values
 ('Motorola Solutions Foundation', '2027 annual grant cycle: inquiry form (eligibility quiz first)', 'dated', 'to_research', 'corporate', 2,
  '2026-11-25', '2027-01-21', '$50,000 maximum request for new grant partners; returning partners may ask for more; no multi-year grants',
  'https://www.motorolasolutions.com/en_us/about/motorola-solutions-foundation/annual-grants.html',
  'Funds ONLY two areas: first responder programming, and technology and engineering education (computer science, robotics, coding, AI, cybersecurity, vocational/IT/data science; students ages 8-18 prioritized). Needs 501(c)(3). Priority location includes Chicagoland. Prefers strong financial health (the FAQ asks for audited financial statements) and data-driven evaluation. Equipment may not be the majority of a budget.',
  true,
  'DECISION FOR STEPHEN: fit is a stretch (the DJ Lab is music technology, not coding or robotics; we have no audited financials). Our read: low odds; do not draft. If Stephen says try: take the online eligibility quiz first (the quiz gates the inquiry form), file the inquiry by Dec 7, 2026 (deadline Jan 21, 2027). Funder then notifies by late March 2027 and invites a full application due Apr 22, 2027; awards Aug 2027. Funder hosts informational calls in early Dec 2026 (date not published; calls are optional and we are online-only).',
  '2026-12-02',
  '[prospects-2026-11-25] VERIFIED on https://www.motorolasolutions.com/en_us/about/motorola-solutions-foundation/annual-grants.html ("2027 grant cycle is officially open ... must submit an inquiry form by January 21, 2027"; info calls early December 2026), https://www.motorolasolutions.com/content/dam/msi/docs/foundation/grants-priorities-and-process.pdf (max $50,000, application Apr 22, 2027, award notification August 2027) and https://www.motorolasolutions.com/content/dam/msi/docs/foundation/grants-faq.pdf (inquiry required; eligibility quiz required before the inquiry form; no invitation code needed; late-March notification; question address foundation@motorolasolutions.com). NOT verified: whether a program with no operating history can pass the quiz. [src:motorola-2026-11-25]'),
 ('Partnership for Safe and Peaceful Communities (PSPC): Chicago Fund', 'Chicago Fund for Safe and Peaceful Communities (2027 round not posted)', 'expected', 'to_research', 'foundation', 2,
  null, null, '$1,000-$10,000 per grant (2026 round; 2027 amounts NOT verified)',
  'https://safeandpeaceful.org/the-chicago-fund/',
  '2026 round: neighborhood-based nonprofits in 24 priority community areas, which included South Shore and Greater Grand Crossing, proposing events and activities that build community cohesion, provide safe spaces and promote peace, aligned with the Seven Field Principles; collaboration encouraged. 2027 eligibility NOT verified.',
  true,
  'Watch for the 2027 RFP. Dec 1, 2026: sign up for the PSPC news list on https://safeandpeaceful.org/ (the page has a sign-up form) and re-read the Chicago Fund page. Do not draft an application until a 2027 RFP is posted. 2026 round for reference: RFP deadline Mar 2, 2026, awards May 1, checks May 14, activities by Oct 31, 2026, applications through the funder e-CImpact portal.',
  '2026-12-01',
  '[prospects-2026-11-25] VERIFIED on https://safeandpeaceful.org/the-chicago-fund/ and https://safeandpeaceful.org/1-million-in-grants-available-in-2026-for-grassroots-organizations-in-24-chicago-neighborhoods-experiencing-most-violence/ (2026 round only) and the home page (2026 grantees announced; $1.3 million). The pasted research said a 2027 round: NOT found on the funder page; 2027 dates UNVERIFIED. PSPC is a coalition of 50+ funders; this is a separate fund from chicagofund.org (the Chicago Fund for Healthier Communities, a health fund; not ours). [src:pspc-2026-11-25]'),
 ('United Way of Metro Chicago', 'Introduction-only funder (route not verified)', 'relationship', 'to_research', 'foundation', 3,
  null, null, 'not stated',
  null,
  'NOT verified: the funder site (uwmetrochicago.org) did not load from our check on Nov 25, 2026.',
  false,
  'No unsolicited proposal and no contact on file. Re-check the funder site for a public partner or grantee page; approach only through a grantee if its own page says so. Do not guess an address.',
  '2026-12-02',
  '[prospects-2026-11-25] NOT verified: domain did not resolve from our check. The "introduction only" claim in the pasted research is a lead, not a fact. Note the McCormick Foundation page lists United Way neighborhoods as a focus (see the McCormick row). [src:unitedway-2026-11-25]'),
 ('The Allstate Foundation', 'Youth empowerment (nonprofits: closed application process)', 'relationship', 'not_eligible', 'corporate', 3,
  null, null, 'not stated',
  'https://www.allstatecorporation.com/the-allstate-foundation/youth-empowerment.aspx',
  'The foundation''s youth empowerment page says funding opportunities are designed for individual youth, educators and universities, and that for nonprofits "we have a closed application process."',
  true,
  'No action. Closed to unsolicited nonprofit applications per the funder''s own page. An introduction route through a grantee is NOT stated on the page (unverified).',
  null,
  '[prospects-2026-11-25] VERIFIED on https://www.allstatecorporation.com/the-allstate-foundation/youth-empowerment.aspx. [src:allstate-2026-11-25]'),
 ('Boeing (corporate giving)', 'Introduction-only funder (route not verified)', 'relationship', 'to_research', 'corporate', 3,
  null, null, 'not stated',
  null,
  'NOT verified: boeing.com did not respond to our fetch on Nov 25, 2026.',
  false,
  'No unsolicited proposal and no contact on file. Re-check boeing.com giving pages in a browser; approach only through a grantee if the page says so.',
  '2026-12-02',
  '[prospects-2026-11-25] NOT verified: site connection reset. The pasted research claim is a lead only. [src:boeing-2026-11-25]'),
 ('Nike (community giving)', 'Introduction-only funder (route not verified)', 'relationship', 'to_research', 'corporate', 3,
  null, null, 'not stated',
  null,
  'NOT verified: nike.com community pages did not load for our fetch on Nov 25, 2026.',
  false,
  'No unsolicited proposal and no contact on file. Re-check in a browser; approach only through a grantee if the page says so.',
  '2026-12-02',
  '[prospects-2026-11-25] NOT verified: connection reset. The pasted research claim is a lead only. [src:nike-2026-11-25]'),
 ('Chicago Bulls Community Assist Fund (a McCormick Foundation fund)', 'Community Assist Fund grants (application route not stated)', 'relationship', 'to_research', 'foundation', 3,
  null, null, 'not stated',
  'https://www.mccormickfoundation.org/partnerships/chicago-bulls-community-assist-fund/',
  'Supports organizations that promote social and emotional support, educational experiences and career development, combat hate, and use basketball to unite communities; grants go to "qualified nonprofit organizations" that fit the issue areas. How nonprofits are selected is NOT stated on the page. Not a Bulls team grant: it is a McCormick Foundation fund.',
  true,
  'Do not draft. Fit is a stretch (no basketball; social-emotional and career angle only). The page does not say it takes unsolicited proposals or is invitation only; we will not claim either. Check the page again for an application link by Dec 2.',
  '2026-12-02',
  '[prospects-2026-11-25] VERIFIED on https://www.mccormickfoundation.org/partnerships/chicago-bulls-community-assist-fund/ (more than $3.9 million granted since 2009; McCormick matches donations 50 cents on the dollar). The parent McCormick Thriving Communities program is invitation only and does not accept unsolicited LOIs (see the McCormick row). The Bulls team site (nba.com/bulls/community) lists community programs; no grant application found there. [src:bulls-caf-2026-11-25]'),
 ('Bally''s Chicago (casino community giving)', 'Introduction-only funder (route not verified)', 'relationship', 'to_research', 'corporate', 3,
  null, null, 'not stated',
  null,
  'NOT verified: the casino site (casinos.ballys.com/chicago) loaded but showed no grant, sponsorship or community-giving application text we could read; a guessed community page returned 404.',
  false,
  'No unsolicited proposal and no contact on file. Re-check in a browser for a community giving page; approach only through a grantee if the page says so. Do not guess an address.',
  '2026-12-02',
  '[prospects-2026-11-25] NOT verified: no giving page found. The pasted research claim is a lead only. [src:ballys-2026-11-25]')
) as v(funder, program, kind, status, level, priority, opens, deadline, amount, url, eligibility, verified, next_step, due, notes)
where not exists (
  select 1 from fs_grant_deadlines g where
    (v.funder like 'Motorola%' and g.funder ilike '%motorola%')
 or (v.funder like 'Partnership for Safe%' and (g.funder ilike '%safe and peaceful%' or g.funder ilike '%pspc%'))
 or (v.funder like 'United Way%' and g.funder ilike '%united way%')
 or (v.funder like 'The Allstate%' and g.funder ilike '%allstate%')
 or (v.funder like 'Boeing%' and g.funder ilike '%boeing%')
 or (v.funder like 'Nike%' and g.funder ~* '\mnike\M')
 or (v.funder like 'Chicago Bulls%' and g.funder ilike '%bulls%')
 or (v.funder like 'Bally%' and g.funder ilike '%bally%'));

-- ============ B. UPDATES to existing funder rows ============
-- Chicago Park District: Night Out in the Parks 2027 (same call as our Nov 1 submission)
update fs_grant_deadlines set
  verified = true, verified_on = date '2026-11-25',
  next_step = 'Same call as our Nov 1 Submittable submission (55665702): VERIFIED Nov 25 on the CPD page, window Nov 1 to Tue Dec 8, 2026 11:59 pm, one call, no separate second form. Nothing more is required by the Park District. By Wed Dec 2: confirm the board consent (rti-board-2026-11-01) is fully signed (Stephen, Paul, Marlon, Craig) and Submittable still shows Review Stage. CPD notifies by early March 2027; schedule due mid-March 2027; spring 2027 orientation is mandatory (date TBD).',
  next_step_due = date '2026-12-02',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://www.chicagoparkdistrict.com/night-out-parks-proposals: 15th season, runs Jun 1 to Dec 31, 2027; proposals due 11:59 pm Tue Dec 8, 2026, no late submissions; submit at https://chicagoparkdistrict.submittable.com/submit; Chicago-based applicant, main applicant 21+, free to the public, nonprofit status NOT required; $1 million general liability naming the Park District as additional insured is "strongly recommended" and a certificate of insurance is required of organizations; fingerprint background checks possible if partners touch the public; support = permit fee waivers, financial support (full or partial, or space only), up to 1,000 printed pieces of marketing, a liaison; questions to noitp@chicagoparkdistrict.com. The page text says acceptance notices by "March 2, 2026" (a typo for 2027; treat as early March 2027, unverified). The info-session office hours (Nov 16-18) have passed. The pasted research was right about Dec 8; it is the same call. [src:noitp-2026-11-25]'
where id = '38b44632-afbe-433e-8fea-4faf7aa379dc'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- Field Foundation / MacArthur ART: amount floor was wrong on our row ($10,000); the funder page says $25,000
update fs_grant_deadlines set
  amount = '$25,000-$100,000 per year, 3-year unrestricted general operating',
  verified = true, verified_on = date '2026-11-25',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://www.fieldfoundation.org/a-road-together: grants range $25,000 to $100,000 per year (our row said $10,000 minimum: corrected); eligibility is a Chicago-based arts and culture organization with an operating budget of at least $25,000 and at most $1 million; "Applications for the next round of ART grants will open in spring 2027" (no exact dates posted; the Apr 15 to May 15 window in our row is a pattern from earlier years, unverified); 2026 round awarded three-year grants to 25 organizations. The page does not say which year''s budget counts: our 2026 budget (about $14K) is under the floor, our 2027 budget ($75,123 cash plus $29,960 equipment) is over it. Unverified: ask in the funder FAQ when the window opens. [src:art-2026-11-25]'
where id = 'a094cf08-e53d-4f91-bb3a-317a182408fd'
  and amount = '$10,000-$100,000/yr x3 yrs'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- D'Addario: take the eligibility quiz now (file early), not Jan 11
update fs_grant_deadlines set
  verified = true, verified_on = date '2026-11-25',
  eligibility = 'Annual In-Kind path (no cash): 501(c)(3); at least 2 hours per week of in-person instruction per participant; free or affordable (tuition or fees at most 40% of org revenue); typically year-round or academic year; electronic music is a listed category. Must pass the online eligibility quiz and receive a follow-up invitation (or have held a D''Addario grant in the past year). The CASH Community Music Grant needs 3+ hours per week, so the DJ Lab (2 hours) does not qualify for cash.',
  next_step = 'Take the online eligibility quiz (bottom of https://www.daddariofoundation.org/pages/eligibility) by Wed Dec 2, 2026. Answers: free program, Tuesdays 4 to 6 pm = 2 hours a week, year-round, opens Jan 12, 2027, 12 stations, 501(c)(3) effective Jun 9, 2026. Open question: the page says it does not fund "instruments or equipment requests" and in-kind support is D''Addario product; whether DJ equipment or anything else we use counts is UNVERIFIED. The quiz decides.',
  next_step_due = date '2026-12-02',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://www.daddariofoundation.org/pages/eligibility and /pages/grants: in-kind applications are accepted January through October on a rolling basis; in-kind values expire Dec 31 of the award year; one proposal per year; not funded: for-profits, events, concerts, festivals, capital, equipment requests, school-affiliated programs. The earlier "unverified" 2-hour and 3-hour figures in this row are now confirmed. The old Jan 11 date was a late schedule: quiz moved to Dec 2 per the file-early rule. [src:daddario-2026-11-25]'
where id = 'e51fa940-be24-47ba-9b5c-e1304830f8b8'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- Polk Bros.: eligibility verdict confirmed on the funder page; row stays not_eligible
update fs_grant_deadlines set
  verified = true, verified_on = date '2026-11-25',
  eligibility = 'Requires 501(c)(3) (or fiscal sponsor), serves Chicago, in operation at least 1 year, Form 990 filed for one of the two most recent fiscal years, 12+ months since any prior Polk grant. RTI: NOT eligible now (incorporated Jun 8, 2026, so one year is reached Jun 8-9, 2027; first Form 990 for FY2026 not yet filed). Eligible only after both are true.',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://www.polkbrosfdn.org/our-grantmaking/open-application: the same five baseline requirements; the eligibility checklist and Introduction are on the funder Grants Portal; introductions are accepted year-round. Introduction deadlines on the page: Nov 13 and Dec 4, 2026, Mar 5, Jun 4, Aug 20, 2027 (5 pm CT). Aug 20, 2027 (for the Feb 2028 board) is the first one after we can honestly answer Yes to both the one-year and the Form 990 questions. We must not answer the checklist Yes before then. The earlier "call 312-527-4684 first" step is dropped (online only; the checklist is online). [src:polk-2026-11-25]'
where id = 'bbb1ebb4-e6e7-4f57-ae42-993b0a276358'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- A Better Chicago
update fs_grant_deadlines set
  verified = true, verified_on = date '2026-11-25',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://www.abetterchicago.org/grantee-application: "Currently, we are not soliciting applications; however, you can submit an interest form ... reviewed on a rolling basis"; invests in organizations creating opportunity for Black and Latinx youth from low-income backgrounds (education, careers, social-emotional development, trauma-informed mental health, essential needs); general questions to grants@abetterchicago.org. The interest-form link is not visible in the page HTML we could fetch (it loads by script); our Oct 31 email already went out. No new send needed. [src:abc-2026-11-25]'
where id = '9d279d3a-a048-4c95-ac29-af9df6c8a77f'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- Chicago Community Trust (grants)
update fs_grant_deadlines set
  verified_on = date '2026-11-25',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://www.cct.org/grants/opportunities/ (the Sponsorships page itself returned 403 to our fetch): the open-opportunities list shows only Sponsorships and Partnerships & Initiatives; eligibility is a 501(c)(3) that is not a private foundation (or a nonprofit fiscal sponsor), benefiting the Chicago region; endowment grants are limited to organizations based in or primarily serving Cook County; questions to grants@cct.org. No other open call fits the DJ Lab right now. Two partner rows exist for the Trust (d576fc5a reached_out and 5a534711 not_qualified, parked): needs a human merge decision. [src:cct-2026-11-25]'
where id = 'ae12c710-6c22-4acf-8bbe-b3c6389cdd52'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- After School Matters (provider pathway)
update fs_grant_deadlines set
  verified_on = date '2026-11-25',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://afterschoolmatters.org/program-providers/become-a-provider/: webinar, then Rolling Interest Form, then interview; form windows: Spring (sessions Feb-May) form Sep-Dec; Summer (late Jun-early Aug) form Jan-Apr; Fall form Jun-Aug; selection can happen outside the windows. ASM serves high school teens. This confirms the Spring/Summer 2027 windows our earlier note called unverified. No new outreach: ASM replied Nov 19 that nothing more is needed. [src:asm-2026-11-25]'
where id = 'd52c3cbd-d864-4e9e-a09d-718e08c07460'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- SGA / DFSS My CHI. My Future. micro-grants
update fs_grant_deadlines set
  verified_on = date '2026-11-25',
  notes = coalesce(notes, '') || E'\n[prospects-2026-11-25] VERIFIED https://sga-youth.submittable.com/submit on Nov 25, 2026: "There are presently no open calls for submissions." (that page points to a CDPH wellness microgrant, not this program). The sga-youth.org site did not load for our fetch, so a 2027 round date is still UNVERIFIED. City page https://www.chicago.gov/city/en/depts/fss/provdrs/youth/svcs/dfss-and-city-award-microgrants-to-community-organizations-servi.html describes the first round ($600,000, 60+ grants, 15 MCMF regions) and gives no 2027 timing. MCMF partner registration is separate and open: https://partners.mychimyfuture.org/ ("request a MCMF Platform account"; the weekly newsletter lists community RFPs and citywide collaborative meetings). [src:sga-2026-11-25]'
where id = '5c2eee2e-7230-49e0-951b-b5dc3c49fcec'
  and coalesce(notes, '') not like '%[prospects-2026-11-25]%';

-- ============ C. NEW collaborator rows (fs_partners): not_contacted, ball_with us, no contact without evidence ============
insert into fs_partners (id, name, category, email, website, contacts, partner_types, program_parts, stage, ball_with, ask, next_step, next_step_due, source, notes)
select v.id::uuid, v.name, 'Community org', null, v.website, '[]'::jsonb, array['programming'], array['classes'], 'not_contacted', 'us', v.ask, v.next_step, date '2026-12-02',
  'Stephen hyperfocus list item 12, Nov 25, 2026 (named in pasted research, not verified by us)', v.notes
from (values
 ('1b2c3d4e-5f60-4a71-8b92-a3c4d5e6f701', 'Phalanx Family Services', 'https://www.phalanxgrpservices.org/',
  'Learn whether Phalanx Family Services would share the free Rainbow DJ Lab with the Far South Side youth and families it serves.',
  'Find a public contact on the organization''s own site (the page is a script-built app; no email or phone could be read by our fetch). Do not guess an address. Then draft a short video-call request.',
  'VERIFIED on https://www.phalanxgrpservices.org/ (page title and description): "helps children and families on Chicago''s Far South Side pursue self-sufficiency through employment, training, and community support." NOT verified: any role in our work, any contact. [src:prospects-2026-11-25]'),
 ('2c3d4e5f-6071-4b82-9ca3-b4d5e6f7a812', 'Giving Others Dreams', null,
  'Learn who they are and whether they serve South Side youth we can coordinate with.',
  'Verify the organization: its site (givingothersdreams.org) did not load from our check Nov 25, 2026. Find an official site and public contact before any outreach.',
  'NOT verified by us: what the organization does, its location, whether any 2027 role exists. No site or contact found. Tracking only. [src:prospects-2026-11-25]'),
 ('3d4e5f60-7182-4c93-adb4-c5e6f7a8b923', 'Shine On Chicago', null,
  'Learn who they are and whether they serve South Side youth we can coordinate with.',
  'Verify the organization: shineonchicago.org did not load from our check Nov 25, 2026. Find an official site and public contact before any outreach.',
  'NOT verified by us: what the organization does, its location, any 2027 role. No contact found. Tracking only. [src:prospects-2026-11-25]'),
 ('4e5f6071-8293-4da4-bec5-d6f7a8b9ca34', 'Pep Rally Takeover', null,
  'Learn who they are and whether a student showcase or youth event link makes sense.',
  'Verify the organization: pepralltakeover.org and .com did not load from our check Nov 25, 2026. Find an official site and public contact before any outreach.',
  'NOT verified by us: what the organization does, its location, any 2027 role. No contact found. Tracking only. [src:prospects-2026-11-25]'),
 ('5f607182-93a4-4eb5-8cd6-e7a8b9cadb45', 'John Walt Foundation', null,
  'Not an organizational funder: a path for older DJ Lab students to apply on their own.',
  'Companion to the grant row (status not_eligible, individual youth artists only; 2026 applications closed, next opening not announced). Check the foundation page again Dec 2 for a 2027 opening; no outreach.',
  'Companion row only. See fs_grant_deadlines John Walt Foundation: Young Artist Scholarship (02aef656-e5dd-4292-9305-53f85e0af9a7). No contact on file. [src:prospects-2026-11-25]')
) as v(id, name, website, ask, next_step, notes)
where not exists (select 1 from fs_partners p where p.name ilike v.name || '%');

-- ============ D. CALENDAR (file early; none on a deadline day) ============
insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes) values
 ('mcmf-partner-account-2026-12-01', 'Request a My CHI. My Future. partner platform account and join the MCMF email list',
  timestamptz '2026-12-01 09:30-06', timestamptz '2026-12-01 09:45-06', 'https://partners.mychimyfuture.org/request-my-chi-my-future-admin-access',
  'Online form only. Weekly newsletter lists community RFPs and citywide partner meetings; email list: https://cloud.citynews.chicago.gov/MCMF_email'),
 ('pspc-signup-2026-12-01', 'PSPC: sign up for news and re-check the Chicago Fund page for a 2027 RFP',
  timestamptz '2026-12-01 09:45-06', timestamptz '2026-12-01 10:00-06', 'https://safeandpeaceful.org/the-chicago-fund/',
  '2026 round closed Mar 2, 2026; 2027 round not posted. No application until an RFP is posted.'),
 ('dadd-quiz-2026-12-02', 'D''Addario Foundation: take the in-kind eligibility quiz',
  timestamptz '2026-12-02 09:30-06', timestamptz '2026-12-02 09:45-06', 'https://www.daddariofoundation.org/pages/eligibility',
  'Quiz at the bottom of the page. Free, Tuesdays 4 to 6 pm (2 hours a week), year-round, opens Jan 12, 2027.'),
 ('motorola-decide-2026-12-02', 'Stephen decides: try the Motorola Solutions Foundation quiz? (inquiry due Jan 21, 2027)',
  timestamptz '2026-12-02 09:45-06', timestamptz '2026-12-02 10:00-06', 'https://www.motorolasolutions.com/en_us/about/motorola-solutions-foundation/annual-grants.html',
  'Fit is a stretch (tech and engineering education or first responders only). If yes, take the eligibility quiz and file the inquiry by Dec 7, not Jan 21.'),
 ('noitp-precheck-2026-12-02', 'Night Out in the Parks: confirm board consent signed and Submittable in Review Stage (window closes Dec 8)',
  timestamptz '2026-12-02 10:00-06', timestamptz '2026-12-02 10:15-06', 'https://chicagoparkdistrict.submittable.com/submit',
  'Submittable 55665702, submitted Nov 1, 2026. Consent rti-board-2026-11-01 needs Stephen, Paul, Marlon, Craig.'),
 ('polk-intro-file-2027-06-14', 'Polk Bros: file the Introduction as soon as the checklist can honestly be answered Yes (deadline Aug 20, 2027)',
  timestamptz '2027-06-14 09:30-05', timestamptz '2027-06-14 09:45-05', 'https://www.polkbrosfdn.org/our-grantmaking/open-application',
  'Only after Jun 9, 2027 (one year) and the FY2026 Form 990 is filed. Do not wait for the Aug 20 deadline day.')
on conflict (key) do nothing;

commit;

-- ============ E. VERIFY ============
select 'grant' as t, funder as k, status as s, next_step_due::text as d from fs_grant_deadlines
 where notes like '%[prospects-2026-11-25]%'
union all select 'partner', name, stage, next_step_due::text from fs_partners where source like 'Stephen hyperfocus list item 12, Nov 25, 2026%'
union all select 'event', key, null, starts_at::text from rti_calendar_events
 where key in ('mcmf-partner-account-2026-12-01','pspc-signup-2026-12-01','dadd-quiz-2026-12-02','motorola-decide-2026-12-02','noitp-precheck-2026-12-02','polk-intro-file-2027-06-14')
order by 1, 2;

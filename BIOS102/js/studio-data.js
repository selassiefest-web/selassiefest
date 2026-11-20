// BIOS102 Research-to-Grant Studio: verified facts + the worked example.
// RULES FOR THIS FILE
//  * Facts about people, papers, datasets and funders are copied from a source named next to them
//    (OpenAlex, the dataset page, the university pages) and carry the date they were read.
//  * Anything a source did not state is "unverified" or "NOT STATED". Nothing is guessed.
//  * The worked example is built on a REAL public dataset (Dryad) and real papers. The student, the dates,
//    the hours and the budget uses are ILLUSTRATIVE and are labeled that way wherever they appear.
//  * No faculty commitment, signature, lab resource or deadline is invented. Those are listed as pending actions.
window.STUDIO_DATA = (() => {
  const CHECKED = 'November 19, 2026';

  // ---- Per-PI additions to the generated OpenAlex record (studio-pis.js) ----
  // identity: what a student must still confirm. recent: the evidence class for "ongoing research".
  // resources: only items named in a source; `used` says how strong the evidence of past use is.
  //   used: 'method'  -> named in a methods section or dataset page we read
  //         'title'   -> named in a paper title/abstract only: confirm in Methods before relying on it
  //         'profile' -> named on the person's faculty profile or website
  const PI_EXTRA = {
    orlofske: {
      ongoing: 'Publications through 2024; profile lists active research interests (invertebrate biodiversity, biomonitoring).',
      identity: 'OpenAlex record with ORCID 0000-0002-2486-7982 lists University of Wisconsin–Parkside. The faculty profile lists no ORCID: confirm the ORCID against the faculty page link or her website.',
      starter: 'Dragonfly emergence and riverine habitat (2020, 2024 papers); river thresholds in Canadian rivers (2017).',
      resources: [
        { kind: 'site', name: 'Huron Mountains (Michigan) river reaches', used: 'title', src: '10.1002/rra.4339', note: 'Named in the 2024 paper title. Field access is not something a beginner can assume.' },
        { kind: 'site', name: 'Freshwater study reaches used for dragonfly emergence', used: 'title', src: '10.1038/s41598-020-74429-7', note: 'Riparian and in-channel habitat and dragonfly emergence (2020 title).' },
        { kind: 'dataset', name: 'Insect phenology records (multi-author, 78 authors)', used: 'title', src: '10.1002/ecy.4036', note: 'Regional variation in insect phenology across North America (2023 title). Data availability not read.' },
        { kind: 'software', name: 'Personal website: freshwaterbugs.wordpress.com', used: 'profile', src: 'https://freshwaterbugs.wordpress.com/', note: 'Listed on her faculty profile.' },
      ],
    },
    richards: {
      ongoing: 'Profile states active research; latest indexed paper in OpenAlex is 2017. Ask what is current.',
      identity: 'OpenAlex does not tie these papers to Parkside. The three papers listed are by "Gregory R. Richards" on E. coli small-RNA regulation, which matches the topic on his faculty profile. Confirm with coauthors and affiliation on the paper itself before treating them as his.',
      starter: 'E. coli stress responses and small RNAs (2015 to 2017).',
      resources: [
        { kind: 'organism', name: 'Escherichia coli strains (which strains is not stated)', used: 'title', src: '10.1128/aem.01636-17', note: 'E. coli is named in the 2017 title. Which strains are in his lab is not stated.' },
      ],
    },
    preuss: {
      ongoing: 'Publications through 2026 (circadian disruption and alcohol-related injury; aging and the gut).',
      identity: 'OpenAlex record lists University of Wisconsin–Parkside, no ORCID. His OpenAlex list also includes 2015–2016 virtual-reality rehabilitation papers; check coauthors to confirm these are the same person.',
      starter: 'Circadian biology, aging and the gut. Several papers use mice, which need approved animal protocols and trained supervision.',
      resources: [
        { kind: 'organism', name: 'Mouse models (aging mice; ApcMIN mice)', used: 'title', src: '10.3389/fragi.2024.1352299', note: 'RESTRICTED: needs institutional animal-care approval and qualified supervision. Not a beginner-ready resource.' },
        { kind: 'dataset', name: 'Circadian transcriptome data (pancreas, aging)', used: 'title', src: '10.18632/aging.204929', note: 'Named in the 2023 title. Whether the data are public was not read.' },
      ],
    },
    higgs: {
      ongoing: 'Profile states active research; latest indexed paper is 2020. Ask what is current.',
      identity: 'OpenAlex record (David C. Higgs) lists University of Wisconsin–Parkside, no ORCID. His list includes 2002–2009 papers: confirm coauthors for the recent one.',
      starter: 'Green alga Chlamydomonas reinhardtii and chloroplast gene control; a 2020 low-nitrogen mutant paper.',
      resources: [
        { kind: 'organism', name: 'Chlamydomonas reinhardtii strains (including a low-nitrogen-tolerant mutant)', used: 'title', src: '10.1016/j.algal.2020.102000', note: 'Named in the 2020 title.' },
      ],
    },
    lee: {
      ongoing: 'Profile states active research; latest indexed paper is 2018. Ask what is current.',
      identity: 'OpenAlex splits her into two records (Traci Lee, Traci A. Lee), both Parkside, no ORCID. Both are shown merged here; confirm via the papers’ author lists.',
      starter: 'Yeast gene control and sulfur metabolism.',
      resources: [
        { kind: 'organism', name: 'Yeast strains (species and strains not stated in the titles)', used: 'title', src: '10.1534/genetics.117.300679', note: '"Yeast" is named in a 2011 title; the 2018 paper concerns zinc deficiency and sulfur metabolism. Species and strains not read.' },
      ],
    },
    barber: {
      ongoing: 'Publications through 2026 (enzymes of gut bacteria; teaching software).',
      identity: 'OpenAlex record with ORCID 0000-0002-7604-8276 lists University of Wisconsin–Parkside.',
      starter: 'Short-chain fatty acid kinases and related enzymes of gut microbes; Python tools for protein structure.',
      resources: [
        { kind: 'organism', name: 'Bacteroides thetaiotaomicron and Phocaeicola vulgatus (enzyme sources)', used: 'title', src: '10.1016/j.jbc.2025.109486', note: 'Named in a 2025 abstract title. Biosafety requirements: ask before planning bench work.' },
        { kind: 'software', name: 'Python programs for protein visualization and alignment', used: 'title', src: '10.1002/cpz1.292', note: 'A 2021 Current Protocols paper: a possible computational on-ramp.' },
        { kind: 'software', name: 'Python allele-mapping programs (education)', used: 'title', src: '10.1002/bmb.21528', note: '2021 education paper.' },
      ],
    },
    noto: {
      ongoing: 'Publications through 2026 (Cretaceous paleoecology; 3D digital morphology).',
      identity: 'OpenAlex record with ORCID 0000-0003-1829-2593 lists University of Wisconsin–Parkside.',
      starter: 'Arlington Archosaur Site (Texas) paleoecology; MorphoDepot 3D morphology.',
      resources: [
        { kind: 'site', name: 'Arlington Archosaur Site, Texas (fossil locality)', used: 'title', src: '10.1080/01916122.2024.2441667', note: 'Named in 2021 to 2025 titles. Field access and collections access were not read.' },
        { kind: 'software', name: 'MorphoDepot (3D digital morphology workflow)', used: 'title', src: '10.1111/2041-210x.70342', note: '2026 paper title; shared with Dr. Taft.' },
      ],
    },
    taft: {
      ongoing: 'Publications through 2026 (fish fin and muscle anatomy; 3D morphology).',
      identity: 'OpenAlex record with ORCID 0000-0003-1839-7002 lists University of Wisconsin–Parkside.',
      starter: 'Fin and muscle anatomy of fishes (scorpaenoids, yellow perch).',
      resources: [
        { kind: 'organism', name: 'Preserved fish specimens (scorpaenoids; yellow perch)', used: 'title', src: '10.1002/jmor.21597', note: 'Named in 2018 and 2023 titles. Specimen sources not read.' },
        { kind: 'software', name: 'MorphoDepot (3D digital morphology workflow)', used: 'title', src: '10.1111/2041-210x.70342', note: '2026 paper title; shared with Dr. Noto.' },
      ],
    },
    rogers: {
      ongoing: 'Publications and a public dataset through 2026 (forest mesophication, legacy resurveys).',
      identity: 'OpenAlex record with ORCID 0000-0001-9093-308X. That record has 235 works and also lists UAB affiliations and medical-education topics, so it merges more than one person or is mixed. The 8 works shown are the ones OpenAlex ties to University of Wisconsin–Parkside, and all are plant ecology. The Dryad page also lists "David Rogers (University of Wisconsin–Parkside)". Confirm with the papers’ author lists.',
      starter: 'Legacy-data resurveys of Wisconsin plant communities; a 2026 public dataset on forest mesophication.',
      resources: [
        { kind: 'dataset', name: 'Dryad dataset: CommunityComposition.csv, LitterFlammability.csv, OverstoryTraitData.csv, README.md', used: 'method', src: '10.5061/dryad.j3tx95xrx', note: 'Published March 17, 2026 on Dryad (79.42 KB for the four files). The page says content is licensed for reuse under Dryad’s terms.' },
        { kind: 'dataset', name: 'Legacy overstory frequency data (Curtis 1959; Rogers 2005), southern Wisconsin', used: 'method', src: '10.5061/dryad.j3tx95xrx', note: 'Described in the dataset README.' },
        { kind: 'software', name: 'R packages named in the supplement (phytools, pglmm)', used: 'method', src: '10.5061/dryad.j3tx95xrx', note: 'Named on the dataset page; no software requirement is stated for reusing the data.' },
      ],
    },
  };

  // ---- Funding records (UW-Parkside official pages read Nov 19, 2026) ----
  // `unverified` lists what the page did NOT state. The student records how they resolved each one.
  const FUNDERS = [
    {
      id: 'thomson', name: 'Thomson Research Fellowship', kind: 'Departmental fellowship',
      source: 'https://www.uwp.edu/departments/biological-sciences/thomson-research-fellowship/', verified: CHECKED,
      status: 'Awards are made in Fall and Spring; no open or closed cycle stated.',
      deadline: 'NOT STATED',
      period: 'Two semesters, or a summer plus an academic semester.',
      eligibility: 'Declared majors in the Department of Biological Sciences (undergraduate or graduate).',
      amount: '$1,500 research stipend to the student, plus $1,000 for research supplies and support, provided through the research advisor. Total $2,500.',
      stipend: 1500, supplies: 1000,
      expenses: 'Supplies and support through the advisor. No other permitted expenses are listed.',
      route: 'NOT STATED. Questions go to Dr. David Higgs (higgs@uwp.edu).',
      mentor: 'Research must be done "under the supervision of a biological sciences faculty or academic staff member".',
      materials: 'NOT STATED',
      reporting: 'Present at a departmental research symposium near the end of the project with the advisor; document any other presentations, papers or outreach.',
      roles: { writes: 'Student (assumed; the page does not say)', submits: 'NOT STATED', administers: 'NOT STATED (supplies are provided through the research advisor)' },
      minSemesters: 2,
      unverified: ['Application deadline', 'Who submits', 'Required application sections and length limits', 'Whether poster printing or data storage count as supplies', 'Whether a computational or existing-data project qualifies'],
    },
    {
      id: 'urap', name: 'Undergraduate Research Apprenticeship Program (URAP)', kind: 'University program',
      source: 'https://www.uwp.edu/learn/beyondtheclassroom/research/', verified: CHECKED,
      status: '"The University seeks proposals for collaborative research every semester."',
      deadline: 'NOT STATED',
      period: 'During the semester ("competitive awards provide funds to the students during the semester").',
      eligibility: 'NOT STATED (supports undergraduates working one-on-one with faculty or academic staff).',
      amount: 'NOT STATED. "Each student is rewarded with a stipend after the completion of their research."',
      stipend: 0, supplies: 0,
      expenses: 'NOT STATED',
      route: 'Submit the application form to your Dean or Division office. Form: https://www.uwp.edu/wp-content/uploads/2026/07/URAP-Application.docx . Contact: Julie Lee, julie.lee@uwp.edu.',
      mentor: '"Faculty and academic staff are supported by the Provost’s Office to engage undergraduates" in one-on-one mentorships.',
      materials: 'The application form (contents not read).',
      reporting: 'NOT STATED',
      roles: { writes: 'NOT STATED', submits: 'NOT STATED (to the Dean or Division office)', administers: 'NOT STATED' },
      minSemesters: 1,
      unverified: ['Eligibility', 'Award amount', 'Deadline', 'Who submits (student, faculty, or both)', 'Allowed expenses', 'Reporting'],
    },
  ];

  // ---- Terms explained in context (BIOS101-friendly) ----
  const GLOSSARY = {
    PI: 'Principal investigator: the faculty member who leads the lab or project and is responsible for its science and safety.',
    ORCID: 'A permanent 16-digit ID that tells two researchers with similar names apart.',
    DOI: 'A permanent link to a paper or dataset. Always cite with the DOI.',
    OpenAlex: 'A free, open index of papers, authors and institutions. Use it to check a researcher’s identity and publication history.',
    gap: 'A specific question the sources you read leave open, which you could help answer.',
    replicate: 'One independent measurement. Biological replicates are different individuals; technical replicates repeat the measurement of one individual.',
    secondary: 'Secondary analysis: asking a new question of data someone else already collected and shared.',
    ITV: 'Intraspecific trait variation: how much individuals of the same species differ from each other in a trait.',
    ICC: 'Intraclass correlation: the share of total variation that lies among groups (here, among species) rather than within them.',
    fallback: 'The smaller project you switch to if a critical dependency fails. It must still answer a real question.',
  };

  // ---- Screening + comparison criteria for the Gap Arena ----
  const CRITERIA = [
    { id: 'value', label: 'Scientific value to the PI', short: 'Value to PI', w: 3 },
    { id: 'evidence', label: 'Strength of the supporting evidence', short: 'Evidence', w: 2 },
    { id: 'access', label: 'Access and readiness', short: 'Access', w: 2 },
    { id: 'burden', label: 'Training burden (higher score = lighter)', short: 'Light training', w: 1 },
    { id: 'deliver', label: 'Likelihood of an interpretable deliverable', short: 'Deliverable', w: 3 },
  ];
  const GAP_QUESTIONS = [
    ['established', 'What has the lab already established, and where is the evidence?'],
    ['open', 'What specific question remains open in the sources reviewed?'],
    ['action', 'What would you actually do?'],
    ['help', 'How would the result help the lab interpret a finding, choose a next step, or improve a project?'],
    ['null', 'What could you deliver if the expected result does not appear?'],
    ['needs', 'What training, materials, equipment, access, approvals and supervision would it need?'],
    ['hours', 'Could it be done in your available hours, including analysis and reporting?'],
    ['fallback', 'What is the fallback if a critical dependency falls through?'],
  ];
  const SOURCE_KINDS = ['University profile', 'Lab page', 'ORCID', 'OpenAlex', 'PubMed', 'Award listing', 'ResearchRabbit', 'Zotero library', 'Other'];

  // =====================================================================
  // THE WORKED EXAMPLE: Dr. David Rogers + the 2026 mesophication dataset.
  // Every citation below was confirmed in OpenAlex on Nov 19, 2026.
  // =====================================================================
  const REFS = [
    { id: 'r1', cite: 'Anderson SW, Rogers DA, McCulloh KA. 2026. Functional and phylogenetic implications of canopy mesophication in temperate hardwood forests. Ecology and Evolution.', doi: '10.1002/ece3.73323' },
    { id: 'r2', cite: 'Anderson S, Rogers DA, McCulloh K. 2026. Data from: Functional and phylogenetic implications of forest mesophication in temperate hardwood forests. Dryad dataset.', doi: '10.5061/dryad.j3tx95xrx' },
    { id: 'r3', cite: 'Siefert A, Violle C, Chalmandrier L, et al. 2015. A global meta-analysis of the relative extent of intraspecific trait variation in plant communities. Ecology Letters.', doi: '10.1111/ele.12508' },
    { id: 'r4', cite: 'Albert CH, Thuiller W, Yoccoz NG, et al. 2010. A multi-trait approach reveals the structure and the relative importance of intra- vs. interspecific variability in plant traits. Functional Ecology.', doi: '10.1111/j.1365-2435.2010.01727.x' },
    { id: 'r5', cite: 'Violle C, Enquist BJ, McGill BJ, et al. 2012. The return of the variance: intraspecific variability in community ecology. Trends in Ecology & Evolution.', doi: '10.1016/j.tree.2011.11.014' },
    { id: 'r6', cite: 'Bates D, Maechler M, Bolker B, Walker S. 2015. Fitting linear mixed-effects models using lme4. Journal of Statistical Software.', doi: '10.18637/jss.v067.i01' },
    { id: 'r7', cite: 'Ladwig LM, Damschen EI, Rogers DA. 2018. Sixty years of community change in the prairie–savanna–forest mosaic of Wisconsin. Ecology and Evolution.', doi: '10.1002/ece3.4251' },
  ];

  const EXAMPLE = {
    meta: { example: true, label: 'Worked example (illustrative student; real public dataset)' },
    profile: {
      name: 'Illustrative student (not a real person)', major: 'Biological Sciences (declared)', year: 'Junior',
      courses: 'BIOS 101 and 102, BIOS 210 Biostatistics, BIOS 305 Principles of Ecology',
      skills: 'Basic R from Biostatistics (t-tests, regression); spreadsheets; no lab or field research experience yet',
      mode: 'data', modeNote: 'Existing-data (secondary analysis): no field or bench access needed.',
      weeklyHours: 6,
      periods: [
        { label: 'Semester 1 (Spring 2027, illustrative dates)', start: '2027-01-25', end: '2027-05-07' },
        { label: 'Semester 2 (Fall 2027, illustrative dates)', start: '2027-09-06', end: '2027-12-10' },
      ],
      breaks: [
        { label: 'Spring break (illustrative)', start: '2027-03-15', end: '2027-03-19' },
        { label: 'Thanksgiving week (illustrative)', start: '2027-11-22', end: '2027-11-26' },
      ],
      reserve: { training: 15, access: 15, trouble: 10, analysis: 35, reporting: 25 },
    },
    pi: 'rogers',
    identityChecks: {
      affiliation: { done: true, note: 'Dryad dataset page lists "David Rogers (University of Wisconsin–Parkside)". OpenAlex lists the Parkside affiliation on 8 works.' },
      coauthors: { done: true, note: 'The 2026 paper and the dataset share the same three authors (Anderson, Rogers, McCulloh). The 2018 paper is Ladwig, Damschen, Rogers.' },
      history: { done: true, note: 'Parkside-tied works run 2016 to 2026 and are all plant community ecology. OpenAlex also merges unrelated medical-education works into the same ORCID record, so only the Parkside-tied works are used.' },
    },
    sources: [
      { kind: 'University profile', title: 'Dr. Rogers faculty profile', url: 'https://www.uwp.edu/faculty-and-staff/rogersd/', date: '2026-11-19', note: 'Research areas: plant identification, ecological surveys, historical ecology.' },
      { kind: 'OpenAlex', title: 'Author record A5091591367 (Parkside-tied works only)', url: 'https://openalex.org/A5091591367', date: '2026-11-19', note: 'Record also merges unrelated works; filtered by institution.' },
      { kind: 'ORCID', title: 'ORCID 0000-0001-9093-308X', url: 'https://orcid.org/0000-0001-9093-308X', date: '2026-11-19', note: 'Listed by OpenAlex. Not listed on the faculty profile, so it is an unverified link to the faculty page.' },
      { kind: 'Other', title: 'Dryad dataset page', url: 'https://datadryad.org/dataset/doi:10.5061/dryad.j3tx95xrx', date: '2026-11-19', note: 'Published March 17, 2026; four files; licensed for reuse under Dryad terms.' },
    ],
    papers: [
      {
        role: 'foundational', doi: '10.1002/ece3.4251', title: 'Sixty years of community change in the prairie–savanna–forest mosaic of Wisconsin (2018)',
        tested: 'Whether savanna plant communities, resurveyed from 1950s surveys, changed as much as remnant forests and prairies.',
        support: 'Savanna structure and composition changed substantially: tree canopy density nearly doubled and many prairie and savanna specialists were replaced by forest and non-native species.',
        uncertain: 'The abstract says it is unclear how each habitat type contributes to regional diversity; it does not say why individual species changed.',
        relates: 'It establishes the legacy-survey method that the 2026 paper and dataset build on.',
        figure: 'Not read. The student must open the paper and annotate one figure from the open-access PDF (link on the DOI page) before marking this paper done.',
        figureDone: false,
      },
      {
        role: 'recent', doi: '10.1002/ece3.73323', title: 'Functional and phylogenetic implications of canopy mesophication in temperate hardwood forests (2026)',
        tested: 'Whether trait and phylogenetic data explain how Wisconsin forest composition shifted from the 1950s to the 2000s (mesophication).',
        support: 'Forests were phylogenetically clustered in both periods; functional traits explained 40.8% of the variance in that clustering in the 1950s and 19.6% in the 2000s, with broad declines in drought tolerance, fire tolerance and litter flammability.',
        uncertain: 'The authors write that future studies on intraspecific trait variation and trait–environment relationships would clarify functional shifts.',
        relates: 'That sentence is the open question this project takes on: how much do individuals of one species differ, and could that change the picture?',
        figure: 'Not read. The student must annotate one figure (for example the 1950s vs 2000s trait explanatory-value comparison) from the open-access article.',
        figureDone: false,
      },
    ],
    resources: [
      { id: 'dset', kind: 'dataset', name: 'OverstoryTraitData.csv (trait values for each individual replicate of every overstory species)', critical: true,
        used: 'method', usedSrc: 'Dryad dataset page, read Nov 19, 2026', usedNote: 'README: "Trait data is provide at the individual/replicate level". File size 18.12 KB.',
        role: 'The data for Analyses 1 and 2.',
        access: 'public', accessNote: 'Public on Dryad under Dryad’s reuse terms. No permission needed. STILL TO CONFIRM: the number of replicates per species (README does not state it).', route: '' },
      { id: 'comm', kind: 'dataset', name: 'CommunityComposition.csv (sites with environmental variables and overstory species frequencies; 1950s and 2000s)', critical: false,
        used: 'method', usedSrc: 'Dryad dataset page, read Nov 19, 2026', usedNote: 'README: one row per site; 19 species frequency columns; year is "either 1950s or 2000s". File size 42.84 KB.',
        role: 'Used only in Analysis 3 (compare within-species spread to the 1950s-to-2000s shift).',
        access: 'public', accessNote: 'Public. STILL TO CONFIRM: that the 19 species columns map to the 4-letter species codes in the trait file (the README does not state the crosswalk).', route: 'If the crosswalk is not in the README or the Zenodo supplement, ask Dr. Rogers. If it cannot be resolved, skip Analysis 3 and report Analyses 1 and 2 only.' },
      { id: 'flam', kind: 'dataset', name: 'LitterFlammability.csv (one row per burn trial)', critical: false,
        used: 'method', usedSrc: 'Dryad dataset page, read Nov 19, 2026', usedNote: 'README lists burn-trial variables. A species identifier was not confirmed in the variable list read.',
        role: 'NOT used in this project (kept out on purpose; see rejected candidate 3).',
        access: 'public', accessNote: 'Public.', route: '' },
      { id: 'readme', kind: 'dataset', name: 'README.md (variable descriptions)', critical: false,
        used: 'method', usedSrc: 'Dryad dataset page, read Nov 19, 2026', usedNote: 'Does not state number of sites, replicates per species or missing-data codes. Two formula typos noted in the flammability section.',
        role: 'Defines the variables and units for the audit.',
        access: 'public', accessNote: 'Public.', route: '' },
      { id: 'r', kind: 'software', name: 'R (free statistical software) with lme4', critical: true,
        used: 'method', usedSrc: 'Bates et al. 2015 (lme4); the 2026 supplement names R packages phytools and pglmm', usedNote: 'The dataset page names R packages for the original analyses; it states no software requirement for reuse.',
        role: 'All analyses.',
        access: 'public', accessNote: 'R and lme4 are free. The student has used R in BIOS 210. Install on a personal computer or confirm a campus lab machine.', route: 'If the student has no computer access, ask Dr. Rogers or the department about a lab machine. This must be confirmed before week 1.' },
      { id: 'sup', kind: 'training', name: 'Weekly supervision: 30 minutes with Dr. Rogers', critical: true,
        used: 'profile', usedSrc: 'Faculty profile (teaches ecology and botany; supervises student research)', usedNote: 'Past use is not the question here: it is a commitment that only Dr. Rogers can make.',
        role: 'Required by the Thomson Fellowship ("under the supervision of a faculty member").',
        access: 'unconfirmed', accessNote: 'NOT CONFIRMED. Dr. Rogers has not been contacted. This is the main decision the PI meeting must resolve.', route: 'If Dr. Rogers cannot supervise, return to Gap selection and choose another PI whose profile is a better fit. Nothing else in this project works without supervision.' },
    ],
    library: { items: (window.STUDIO_EXLIB || []).map((x) => JSON.parse(JSON.stringify(x))), analysis: {}, evidence: [], searches: [] },
    litChecks: [
      { gapId: 'g1', sources: 'OpenAlex (three searches, listed in the search log)', terms: 'intraspecific trait variation tree leaf traits temperate forest (2022 onward); papers related to the 2026 mesophication paper; the PI\u2019s own works at Parkside', date: '2026-11-19', closest: 'Siefert et al. 2015 (global meta-analysis of intraspecific trait variation: 25% of within-community trait variation on average) and Albert et al. 2010 (about 30% in an alpine catchment). Neither uses this dataset.', limits: 'Searched titles and abstracts only; no systematic review. Wisconsin overstory-specific work may exist behind paywalls.' },
      { gapId: 'g2', sources: 'OpenAlex, the Dryad dataset page', terms: 'species frequency change 1950s 2000s Wisconsin forests mesophication species contribution', date: '2026-11-19', closest: 'The 2026 paper already reports species-level trends and names key species for managers.', limits: 'Abstract-level reading only.' },
    ],
    gaps: [
      {
        id: 'g1', title: 'How much do individual trees of one species differ in leaf traits? (intraspecific trait variation)',
        a: {
          established: 'The 2026 paper and the Dryad dataset show a 1950s-to-2000s shift in overstory traits, with traits explaining 40.8% of phylogenetic clustering variance in the 1950s and 19.6% in the 2000s [@anderson2026]. Raw trait data are shared at the individual level [@anderson2026data].',
          open: 'The authors state that studying intraspecific trait variation would further clarify the shifts [@anderson2026]. Nobody in these sources reports how large the within-species spread is in this dataset.',
          action: 'Audit the trait file, then fit variance-partitioning models for four traits to measure the share of variance within versus among species, and compare that spread with the size of the reported shift.',
          help: 'It tells the lab whether species-mean traits are a safe simplification, or whether individual variation is large enough to qualify the explanatory-value result.',
          null: 'A clean, documented variance-partition table with confidence intervals is a deliverable whatever the answer: "within-species spread is small" is also a useful, interpretable result.',
          needs: 'R and lme4 (free); about 4 data files; no field, bench, animal or biosafety work. Supervision: 30 minutes a week with Dr. Rogers (not yet confirmed).',
          hours: 'Yes: 162 available hours over 27 weeks (see calendar). Analysis plus reporting planned at about 98 h.',
          fallback: 'If the replicates per species are too few, switch to a descriptive replicate audit plus among-species trait tables with bootstrap intervals (about 60 h).',
        },
        evidence: ['E1', 'E2', 'E4', 'E5', 'E8'],
        score: { value: 4, evidence: 4, access: 4, burden: 3, deliver: 5 },
        dependencies: [{ text: 'Replicates per species are enough to estimate within-species variance (not stated in the README).', critical: true, route: 'Resolved in Analysis 1 (week 4 to 5). Fallback exists.' }],
        feasibleHours: true,
      },
      {
        id: 'g2', title: 'Which species drive the compositional change, and do their traits explain it?',
        a: {
          established: 'Community composition for 1950s and 2000s sites is in CommunityComposition.csv [@anderson2026data]; the paper reports species-level trends and highlights key species [@anderson2026].',
          open: 'Whether a simple species-by-species ranking adds anything beyond what the paper already reports is unclear from the abstract.',
          action: 'Rank the 19 species by change in frequency and relate the change to species mean traits.',
          help: 'It would check the paper’s species-level statements with a transparent, simple analysis.',
          null: 'A ranked table of frequency change, which the paper has largely reported already.',
          needs: 'R; the species-code crosswalk between two files (not confirmed); supervision.',
          hours: 'Yes, about 70 h for analysis and reporting.',
          fallback: 'Report frequency change only, without the trait link.',
        },
        evidence: ['E3', 'E6'],
        score: { value: 2, evidence: 4, access: 3, burden: 4, deliver: 3 },
        dependencies: [{ text: 'Species-code crosswalk between the two files is not documented in the README.', critical: false, route: 'Ask Dr. Rogers; the supplement on Zenodo may include it.' }],
        feasibleHours: true,
      },
      {
        id: 'g3', title: 'Which leaf traits best predict how fast litter burns?',
        a: {
          established: 'LitterFlammability.csv has one row per burn trial with flame height, duration, mass consumed and leaf curl [@anderson2026data].',
          open: 'Whether a simple leaf trait (curl) predicts flammability across species.',
          action: 'Relate flammability metrics to leaf traits.',
          help: 'Could help land managers choose species, but the paper already links flammability to species.',
          null: 'Weak: a null result would be hard to interpret without species labels.',
          needs: 'A species identifier in the flammability file, which was NOT confirmed in the README variable list; possible README formula errors to resolve with the authors.',
          hours: 'Unknown until the file is opened.',
          fallback: 'None that still answers a meaningful question.',
        },
        evidence: ['E7'],
        score: { value: 3, evidence: 2, access: 1, burden: 3, deliver: 2 },
        dependencies: [{ text: 'No confirmed species identifier in the flammability file, so the trials cannot be linked to the trait file.', critical: true, route: '' }],
        feasibleHours: true,
      },
    ],
    chosenGap: 'g1',
    justification: 'I chose Candidate 1 because it is the only one where the open question comes straight from the authors’ own sentence on what is needed next [@anderson2026], where the data are public and small enough for me to analyze on my own computer, and where every outcome is useful. Candidate 2 mostly repeats what the paper reports. Candidate 3 fails the screen: it has a critical dependency (no confirmed species label in the flammability file) with no route to resolve it, so I removed it before scoring. Candidate 1 does depend on enough replicates per species, but I will know that by week 5, and the descriptive fallback still answers a real question.',
    funding: {
      primary: 'thomson', alt: 'urap',
      resolutions: {
        'thomson|Application deadline': '', 'thomson|Who submits': '', 'thomson|Required application sections and length limits': '',
        'thomson|Whether poster printing or data storage count as supplies': '', 'thomson|Whether a computational or existing-data project qualifies': '',
      },
      altAssessment: 'URAP funds students "during the semester" and pays a stipend after the research is complete, but its eligibility, amount and deadline are not stated on the page I read. It is a backup if the Thomson route is not open for an existing-data project; I would email Julie Lee (julie.lee@uwp.edu) to ask before relying on it. Compared with Thomson: unknown stipend, unknown route detail, shorter stated period.',
    },
    plan: {
      title: 'Individual differences matter? Partitioning leaf-trait variation within and among species in Wisconsin overstory forests',
      facts: { aimCount: 1, aimTitles: 'Quantify within- versus among-species variance of four leaf traits and judge whether it could change the interpretation of the 1950s-to-2000s shift', minReplicates: 3, totalHours: 162, startDate: '2027-01-25', endDate: '2027-12-10', deliverable: 'Annotated R notebook, cleaned data audit, variance-partition table with intervals, two figures and a 2-page report', budgetTotal: 2500 },
      sections: {
        background: 'Forest mesophication is the shift of forests from fire-adapted, drought-tolerant species toward species suited to shaded, closed canopies. Anderson, Rogers and McCulloh (2026) combined legacy forest surveys of Wisconsin from the 1950s and 2000s with trait and phylogenetic data [@anderson2026]. They found that closely related species occupy similar sites in both periods, and that functional traits explained 40.8% of the variance in that clustering in the 1950s but only 19.6% in the 2000s. Contemporary forests show broad declines in drought tolerance, fire tolerance and litter flammability, and gains in leaf traits linked to acquisitive resource use.',
        evidence: 'The data behind that paper are public [@anderson2026data]: trait values measured on individual trees, community composition for sites in two periods, and litter burn trials. Across plant communities worldwide, intraspecific trait variation averaged 25% of total trait variation within communities and 32% among communities [@siefert2015], and about 30% in one alpine study [@albert2010], so it is rarely negligible.',
        gap: 'The 2026 paper states that future studies on intraspecific trait variation would clarify the functional shifts [@anderson2026]. The sources I reviewed do not report how large within-species spread is for this dataset’s traits.',
        question: 'For four leaf traits measured on individual overstory trees, how much of the total variance lies within species rather than among species, and is that within-species spread large compared with the shifts the 2026 paper reports?',
        aims: 'Aim 1. Quantify, for LMA, log leaf area, turgor loss point and leaf hydraulic conductance (Kleaf), the share of trait variance that lies within versus among species, with uncertainty, and judge whether that spread is large enough to qualify species-mean trait analyses of the 1950s-to-2000s shift. The deliverable is an annotated R notebook, a data audit, a variance-partition table with intervals, two figures and a two-page report for the lab.',
        observation: 'Across southern Wisconsin forests surveyed in the 1950s and again in the 2000s, closely related tree species occupy similar sites, but leaf traits explain far less of that pattern now: 40.8% of the variance in the 1950s versus 19.6% in the 2000s [@anderson2026]. The authors write that studying the influence of intraspecific trait variation, meaning differences among individual trees of the same species, would further clarify these functional shifts [@anderson2026]. In plant communities worldwide that individual variation averages about 25% of trait variation within communities [@siefert2015], and in a New York and New England forest study, whether one trait value can stand in for a species depended on the light and climate conditions where traits were measured [@hecking2022].',
        answer: 'I propose that individual trees of the same species differ enough in these leaf traits that the within-species share of total variance is substantial: at least 20% for at least two of four traits (LMA, log leaf area, turgor loss point and Kleaf). That would be similar to the 25 to 30% averages reported in other systems [@siefert2015][@albert2010], because individuals of a species grow under different local conditions and intraspecific variability is widely recognized as important in community ecology [@violle2012].',
        prediction: 'If my proposed answer is correct, then a random-intercept model with species as the random effect will give a within-species share (residual variance divided by total variance) of at least 20% for at least two of the four traits, and the 95% bootstrap interval for those traits will exclude 10%. I would reject my proposed answer if the within-species share is below 10% for all four traits. Published work suggests leaf morphology traits tend to show less intraspecific variation than leaf chemistry [@siefert2015], so I expect the hydraulic traits (turgor loss point, Kleaf) to carry more of the signal than LMA and leaf area. The 20% line is set below the published averages of about 25 to 32% [@siefert2015][@albert2010] on purpose, and I will agree the thresholds with Dr. Rogers before any analysis begins.',
        variables: 'Unit of observation: one individual tree (a row in OverstoryTraitData.csv). Variables: species code, genus, family, replicate, id, LMA, LA (and logLA), TLP, Kleaf (I will confirm what each abbreviation means, and its units, from the README and copy them into my notebook). Metadata I record: file name and version date, row counts, species with fewer than the minimum replicates, any values outside plausible ranges, and every row I exclude with the reason. Missing data: the README does not state missing-data codes, so I will tabulate blanks and odd codes in the audit; rows missing a trait are dropped only for that trait. Exclusions are logged, never silently removed. Quality checks: duplicate ids, species-code spelling, unit consistency, and recomputing logLA from LA to confirm the file agrees with itself.',
        analysis: 'Tables: (T1) the data audit; (T2) variance components and the within-species share with 95% intervals for each trait. Figures: (F1) within- versus among-species share by trait; (F2) trait values by species showing individual points. Models: a random-intercept model for each trait with species as the random effect, fit in lme4 [@bates2015]; the within-species share is the residual variance divided by the total. Intervals: parametric bootstrap. Sensitivity: repeat with the minimum replicate rule set to 2 and to 5.',
        interpretation: 'Supportive: a within-species share comparable to published values (about 25% or more) for at least some traits would mean the lab should check whether its explanatory-value comparison changes when individual variation is included. Contradictory: a very small share (for example under 10%) would support using species means. Inconclusive: wide intervals or too few replicates; I will report that, show how many species passed the rule, and switch to the fallback if fewer than half the species do. Any of the three is reported plainly.',
        approvals: 'No human or animal subjects, no field access, no biosafety work and no restricted procedures. The data are public under Dryad’s reuse terms (confirm the exact terms on the dataset page when citing). Supervision by Dr. Rogers is required by the Thomson Fellowship and has not been confirmed. Training: refresh R and learn variance components (weeks 1 to 6). Safety: none beyond ordinary computer use.',
        handoff: 'To the lab: the annotated R notebook that reruns from the raw files; the audit table including every exclusion; the variance-partition table; the two figures; a two-page plain-language report stating the answer, its limits and what I would check next. All shared as files the lab can open without my help.',
      },
      experiments: [
        { id: 'e1', aim: 'Aim 1', n: 1, title: 'Data audit and cleaning', design: 'Open the three CSV files and README; count rows, species and replicates per species; check duplicates, units and codes.', materials: 'OverstoryTraitData.csv (18.12 KB), README.md (6.06 KB). No quantities beyond file sizes.', equip: 'R on a personal computer.', methods: 'Read files into R; table counts by species; compare to README; list every anomaly and decision in a log.', controls: 'Recompute logLA from LA and compare with the file; compare row counts with README descriptions.', replication: 'The replicate is the individual tree (as described in the README). Technical replication of single measurements is not described, so none is assumed.', sample: 'No sampling: the entire file is audited.', decision: 'Which species have enough replicates; whether to switch to the fallback (end of week 8 checkpoint).' },
        { id: 'e2', aim: 'Aim 1', n: 2, title: 'Variance partitioning for four traits', design: 'For each trait, fit species as a random effect and compute the within-species share of total variance.', materials: 'The cleaned trait table from Experiment 1.', equip: 'R with lme4.', methods: 'Random-intercept model per trait; within-species share = residual variance / total variance; parametric bootstrap for 95% intervals.', controls: 'Compare to a simple one-way ANOVA estimate; repeat with minimum replicates set to 2, 3 and 5.', replication: 'Replicates per species are the individual trees; species are the higher level. Both levels reported.', sample: 'Include species with at least 3 replicates. Reason: three is the smallest number that gives a within-species spread that is not a single difference; the 2 and 5 sensitivity runs show how much the rule matters. The final n is fixed after Experiment 1.', decision: 'Is within-species spread negligible, moderate or large for each trait?' },
        { id: 'e3', aim: 'Aim 1', n: 3, title: 'Compare within-species spread with the reported shift (conditional)', design: 'Compute community-weighted mean traits for 1950s and 2000s sites and compare the shift to the within-species spread.', materials: 'CommunityComposition.csv (42.84 KB) and species mean traits from Experiment 2.', equip: 'R.', methods: 'Weight each species’ mean trait by its frequency at each site; compare period means; express the within-species spread on the same scale.', controls: 'Weights computed two ways (frequency and relative frequency).', replication: 'Sites are the replicate unit as described in the README; the count is not stated and will be recorded in Experiment 1.', sample: 'All sites in the file; no selection.', decision: 'Whether individual variation is large enough to qualify the shift. SKIPPED if the species-code crosswalk cannot be resolved; Aim 1 still stands on Experiment 2.' },
        { id: 'e4', aim: 'Aim 1', n: 4, title: 'Figures, report and handoff', design: 'Produce the two figures, the notebook and the two-page report.', materials: 'Outputs of Experiments 1 to 3.', equip: 'R and a word processor.', methods: 'Plain-language writing reviewed by Dr. Rogers; notebook rerun from scratch on a clean session.', controls: 'Rerun test: a second person reruns the notebook.', replication: 'Not applicable.', sample: 'Not applicable.', decision: 'What the lab should do next with the result.' },
      ],
      schedule: [
        { from: 1, to: 3, label: 'Training: R refresher, read both papers and the README, first meeting with Dr. Rogers', cat: { training: 18 } },
        { from: 4, to: 5, label: 'Data audit (Experiment 1)', cat: { access: 12 } },
        { from: 6, to: 6, label: 'Training: variance components and lme4', cat: { training: 6 } },
        { from: 7, to: 8, label: 'Cleaning and checkpoint: GO or switch to fallback at end of week 8', cat: { access: 12 } },
        { from: 9, to: 10, label: 'Troubleshooting: model fits, convergence, intervals', cat: { trouble: 12 } },
        { from: 11, to: 14, label: 'Variance partitioning (Experiment 2); interim summary at end of Semester 1', cat: { analysis: 24 } },
        { from: 15, to: 17, label: 'Sensitivity runs and Experiment 3 if the crosswalk is resolved', cat: { analysis: 18 } },
        { from: 18, to: 19, label: 'Figures and tables', cat: { analysis: 12 } },
        { from: 20, to: 20, label: 'Troubleshooting and final analysis', cat: { trouble: 4, analysis: 2 } },
        { from: 21, to: 27, label: 'Report, symposium poster, handoff and rerun test (Experiment 4)', cat: { reporting: 41, analysis: 1 } },
      ],
      fallback: { switchByWeek: 14, hoursNeeded: 60, note: 'Fallback = descriptive replicate audit (about 20 h), among-species trait tables with bootstrap intervals (about 24 h) and a short report (about 16 h). It answers a real question: how many replicates exist and how different the species are. After week 14, 13 weeks remain (78 h), so the latest safe switch is the end of week 14 with an 18 h margin.' },
    },
    budget: [
      { id: 'b1', item: 'Student research stipend (fixed by the Thomson call)', amount: 1500, linksTo: 'Whole project: 162 hours (about $9.26 an hour)', basis: 'Call amount; paid to the student', pay: 'student' },
      { id: 'b2', item: 'Portable drive for data archive and backups', amount: 85, linksTo: 'Experiment 1 (raw files) and the Experiment 4 handoff', basis: 'ASSUMPTION: price is illustrative; whether this counts as a supply is unverified', pay: 'supplies' },
      { id: 'b3', item: 'Poster printing for the departmental symposium', amount: 80, linksTo: 'Experiment 4 and the symposium required by the call', basis: 'ASSUMPTION: illustrative print cost; whether this counts as a supply is unverified', pay: 'supplies' },
      { id: 'b4', item: 'Supplies reserve, directed by the research advisor', amount: 835, linksTo: 'Unallocated: Dr. Rogers decides (for example software, a lab machine, a reference book)', basis: 'Remainder of the $1,000 supplies amount stated in the call', pay: 'supplies' },
    ],
    proposal: {
      facts: { aimCount: 1, aimTitles: 'Quantify within- versus among-species variance of four leaf traits and judge whether it could change the interpretation of the 1950s-to-2000s shift', minReplicates: 3, totalHours: 162, startDate: '2027-01-25', endDate: '2027-12-10', deliverable: 'Annotated R notebook, cleaned data audit, variance-partition table with intervals, two figures and a 2-page report', budgetTotal: 2500 },
      modelNote: 'MODEL PROPOSAL. The Thomson page does not state required sections, order or length limits. These sections are a standard research-proposal structure. Load the real requirements below as soon as the department provides them.',
      sections: [
        { id: 'summary', title: 'Plain-language summary', limit: 150, text: 'Wisconsin’s forests shifted between the 1950s and the 2000s toward shade-loving species, and researchers at Parkside and Madison have shared the measurements behind that finding. Their paper asks what changed. I will ask a companion question: how different are individual trees of the same species from each other? If individuals differ a lot, using one average value per species can hide important detail. I will analyze the public data on my own computer, report how big the individual differences are, and give the lab a notebook they can rerun and a short report.' },
        { id: 'rationale', title: 'Rationale and significance', limit: 300, text: 'The 2026 study by Anderson, Rogers and McCulloh [@anderson2026] shows that traits explained 40.8% of the variance in how related species cluster in the 1950s but 19.6% in the 2000s. The authors state that studying intraspecific trait variation would help clarify these shifts [@anderson2026]. Globally, individual differences within species average about 25% of trait variation within communities [@siefert2015], so they are rarely ignorable. This project measures them for this dataset, which tells the lab whether species means are a safe simplification.' },
        { id: 'aims', title: 'Specific aim', limit: 150, text: 'Aim 1. For LMA, log leaf area, turgor loss point and Kleaf, quantify the share of trait variance within versus among species, with uncertainty, and judge whether the within-species spread is large enough to qualify species-mean trait analyses of the 1950s-to-2000s shift.' },
        { id: 'approach', title: 'Approach', limit: 400, text: 'Experiment 1 audits the public trait file (replicates per species, duplicates, units, missing values) and logs every decision. Experiment 2 fits a random-intercept model for each trait with species as the random effect in R (lme4; [@bates2015]) and computes the within-species share of variance with bootstrap intervals; species with at least 3 replicates are included, and 2 and 5 are run as sensitivity checks. Experiment 3, if the species codes in the composition file can be matched, compares the within-species spread with the shift in community-weighted mean traits. Experiment 4 produces two figures, a rerunnable notebook and a two-page report. Data: Dryad dataset [@anderson2026data], public.' },
        { id: 'feasibility', title: 'Feasibility, risks and fallback', limit: 250, text: 'Feasible in 162 hours over two semesters using free software and public data. The main risk is too few replicates per species, which I will learn by week 5; the go or switch checkpoint is the end of week 8. The fallback (a descriptive replicate audit plus among-species tables with bootstrap intervals, about 60 hours) can be started as late as the end of week 14 and still finish with 18 hours to spare. A second dependency, matching species codes between two files, only affects Experiment 3, which is optional.' },
        { id: 'role', title: 'Student role', limit: 150, text: 'I will do all the data work myself: audit, code, models, figures and report. Dr. Rogers’s role is to supervise, check my interpretation and tell me what matters to his research.' },
        { id: 'mentor', title: 'Mentorship and training', limit: 200, text: 'Requested: 30 minutes of weekly supervision with Dr. Rogers (not yet confirmed) and one review of the draft report. My own training: R refresher and variance components in weeks 1 to 6, using the lme4 paper [@bates2015] and the BIOS 210 foundation I already have.' },
        { id: 'timeline', title: 'Timeline', limit: 250, text: 'Jan 25 to Dec 10, 2027 (illustrative academic dates): 27 working weeks at 6 hours a week. Weeks 1 to 8: training, data audit and the checkpoint. Weeks 9 to 14: troubleshooting and variance partitioning, interim summary at the end of Semester 1. Weeks 15 to 20: sensitivity runs, optional Experiment 3, figures. Weeks 21 to 27: report, poster, handoff and rerun test.' },
        { id: 'outcomes', title: 'Expected outcomes and dissemination', limit: 200, text: 'A variance-partition table for four traits, two figures, an audited and annotated notebook and a two-page report, all given to the lab. I will present a poster at the departmental research symposium as the fellowship requires and document any other presentation.' },
        { id: 'budgetnote', title: 'Budget justification', limit: 250, text: 'Total $2,500: the $1,500 student stipend and $1,000 of supplies through the research advisor, as stated in the call. Of the supplies, $85 for a portable drive (data archive and handoff, Experiments 1 and 4) and $80 for symposium poster printing (Experiment 4); the remaining $835 is reserved for supplies the advisor directs. Whether the drive and poster printing qualify as supplies is not stated in the call and will be confirmed with Dr. Higgs.' },
      ],
    },
    claims: [
      { id: 'c1', text: 'Traits explained 40.8% of clustering variance in the 1950s and 19.6% in the 2000s.', ref: 'anderson2026', verified: false },
      { id: 'c2', text: 'The authors state that studying intraspecific trait variation would help clarify these shifts.', ref: 'anderson2026', verified: false },
      { id: 'c3', text: 'Trait data are provided at the individual/replicate level in a public Dryad dataset.', ref: 'anderson2026data', verified: false },
      { id: 'c4', text: 'Intraspecific variation averaged 25% of within-community trait variation in a global meta-analysis.', ref: 'siefert2015', verified: false },
      { id: 'c5', text: 'Intraspecific variability was about 30% of trait variability in an alpine catchment.', ref: 'albert2010', verified: false },
    ],
    refs: [],
    pending: [
      'Dr. Rogers agrees to supervise (30 minutes a week) and to review the draft report: NOT CONFIRMED',
      'Thomson Fellowship: confirm deadline, who submits, required sections and length limits with Dr. Higgs (higgs@uwp.edu)',
      'Thomson Fellowship: confirm an existing-data project qualifies, and that the drive and poster printing count as supplies',
      'Mentor letter or signature, if the department requires one: not stated',
      'Declared Biological Sciences major confirmed in the student record (Thomson eligibility)',
      'Replicates per species and the species-code crosswalk confirmed by opening the files and, if needed, asking the authors',
    ],
    defense: {
      gap: 'In their 2026 paper, Dr. Rogers’s group says that studying intraspecific trait variation would clarify the forest shift. The public data include trait values for individual trees, so the question of how much trees of one species differ from each other is open and answerable from data they already shared.',
      comparison: 'Candidate 1 has no species-label or crosswalk problem to block it. A comparison group is built in: variance among species versus variance within species. I also run the analysis with minimum replicate rules of 2, 3 and 5 so the choice of 3 does not decide the answer.',
      analysis: 'For each trait I fit a model with species as a random effect and calculate the residual variance divided by the total variance. I get a bootstrap interval, and I show the individual points so a reader can see the pattern behind the numbers.',
      assumption: 'That there are enough replicates per species. If most species have only one or two trees, within-species variance cannot be estimated, and I switch to the fallback by the end of week 8.',
    },
    meeting: { decisions: [], notes: '', status: 'not started' },
    submission: { status: 'Draft', log: [] },
    review: { notes: {}, signoff: '' },
    sectionStatus: {},
  };


  // ---- example library extras: evidence cards, reading cards, search log (all quotes verbatim from abstracts/README read Nov 19, 2026) ----
  (function () {
    const L = EXAMPLE.library; const id = (k) => (L.items.find((i) => i.key === k) || {}).id || '';
    L.evidence = [
      { id: 'E1', type: 'limitation', item: id('anderson2026'), quote: 'While future studies on the influence of intraspecific trait variation and trait-environment relationships would further clarify functional shifts in temperate deciduous forests, our findings provide quantifiable support for the hypothesized functional implications of mesophication.', note: 'The authors name intraspecific trait variation as the next step. This is the strongest evidence for candidate 1.' },
      { id: 'E2', type: 'dataset', item: id('anderson2026data'), quote: 'Trait data is provide at the individual/replicate level', note: 'Individual-level trait values are public (README wording as shown on the Dryad page), so within-species variance can be computed without new fieldwork.' },
      { id: 'E3', type: 'dataset', item: id('anderson2026data'), quote: 'overstory frequency data collected by Curtis (1959) and Rogers (2005) for southern WI temperate forests', note: 'Community composition for two periods is public: the basis for candidate 2.' },
      { id: 'E4', type: 'figure', item: id('hecking2022'), quote: 'the assumption that species may be represented with a single trait value may be warranted for some trait-based analyses provided traits were measured under similar light levels and climate conditions', note: 'A closely related forest study says the single-value shortcut depends on growing conditions. It does not test the Wisconsin overstory data.' },
      { id: 'E5', type: 'unstudied', item: id('dendoncker2026'), quote: 'ITV was substantial but trait-dependent', note: 'Recent work finds large individual variation in tree seedling ROOT traits. Leaf traits of mature overstory trees in these Wisconsin forests are a comparable group not covered there.' },
      { id: 'E6', type: 'limitation', item: id('woodbridge2022'), quote: 'Evidence for shifts in composition provide broad-scale support for mesophication, but we lack information on the fine-scale factors that drive the associated functional changes.', note: 'Supports the idea that species-level detail is still thin (candidate 2), though in a different dataset.' },
      { id: 'E7', type: 'dataset', item: id('anderson2026data'), quote: 'flammability replicates referring to data collected from ~15g litter samples', note: 'The README text read does not mention a species identifier for these trials. That is the dependency that screened candidate 3 out.' },
      { id: 'E8', type: 'conflict', item: id('amatangelo2014'), quote: 'Despite changes in trait and community composition, trait-environment relationships measured directly via fourth-corner analysis remain strong for most plant traits.', note: 'Understory plants in Wisconsin: traits still track the environment. The 2026 overstory study reports traits explaining less of the clustering over time. Different strata and methods, so not a contradiction, but a reason to ask how much individual variation matters.' },
    ];
    L.analysis = {};
    const card = (k, o) => { if (id(k)) L.analysis[id(k)] = o; };
    card('anderson2026', { observation: 'Forests in southern Wisconsin in the 1950s and 2000s show phylogenetically clustered structure; trait explanatory value fell from 40.8% to 19.6%.', tested: 'Whether trait and phylogenetic data explain forest compositional change (mesophication) between two survey periods.', methods: 'Legacy forest surveys from the 1950s and 2000s combined with trait and phylogenetic data; mixed models of phylogenetic clustering with traits added (from the abstract: read the Methods section).', result: 'Contemporary trait syndromes show broad declines in drought tolerance, fire tolerance and litter flammability and gains in acquisitive leaf traits.', limits: 'Future studies on intraspecific trait variation and trait-environment relationships would further clarify functional shifts.', open: 'How large is individual variation within species, and would it change the explanatory-value result?', relevance: 'Source of candidate 1 and of the public dataset.' });
    card('hecking2022', { observation: 'In montane temperate-boreal forests the leaf economic spectrum persists despite intraspecific variability.', tested: 'How traits covary at local scales, vary across gradients, and partition within and among taxa (9 traits, 13 tree species).', methods: 'Trait ordination and variance partitioning on 9 traits for 13 tree species across forest ecotones in New York and New England (from the abstract).', result: 'Intraspecific variability differed considerably among traits and related to light, climate and tree developmental stage; trait rankings across species were generally conserved.', limits: 'The single-value-per-species assumption may be warranted only when traits were measured under similar light and climate.', open: 'Does the same hold for Wisconsin overstory trees measured in a different dataset?', relevance: 'A method precedent (variance partitioning within and among species) and a direct comparison for my result.' });
    card('dendoncker2026', { observation: 'Intraspecific variability in root traits of tree seedlings rivals differences among species.', tested: 'Between-species and intraspecific variation in seven root traits for seedlings of seven tree species.', methods: 'Seedlings sampled under contrasting climate and light in northeastern North America; variation partitioned between species and within plots (from the abstract).', result: 'ITV was substantial but trait-dependent; in four traits within-plot ITV accounted for more than 50% of variation.', limits: 'Fine-scale heterogeneity not captured in the study may strongly influence root ITV.', open: 'Is ITV in leaf traits of mature overstory trees as large as in seedling roots?', relevance: 'Shows the question is live and trait-dependent; roots and seedlings are a different group from my data.' });
    card('amatangelo2014', { observation: 'Wisconsin forest understory trait means changed between the 1950s and 2000s, yet trait-environment relationships stayed strong.', tested: 'How shifts in species composition affected distributions of functional traits (understory plants).', methods: 'Community-weighted trait means and functional diversity for 1950s and 2000s communities; fourth-corner analysis of trait-environment relationships (from the abstract).', result: 'Most traits changed; trait richness and diversity declined; trait-environment relationships remain strong for most traits.', limits: 'Accelerating change could outstrip the ability of species and traits to match their environment.', open: 'Does the same hold for overstory trees, and how much of the pattern is individual variation?', relevance: 'Context for why the overstory result may differ (evidence card E8).' });
    ['anderson2026', 'ladwig2018', 'beck2022', 'hecking2022', 'dendoncker2026', 'amatangelo2014'].forEach((k) => { const it = L.items.find((x) => x.key === k); if (it) it.read = 'read'; });
    L.searches = [
      { date: '2026-11-19', source: 'OpenAlex', mode: 'PI works', terms: 'Author A5091591367 filtered to University of Wisconsin\u2013Parkside', n: 8 },
      { date: '2026-11-19', source: 'OpenAlex', mode: 'Related to a PI paper', terms: 'related works of doi:10.1002/ece3.73323 (2026 mesophication paper)', n: 6 },
      { date: '2026-11-19', source: 'OpenAlex', mode: 'Keyword', terms: 'intraspecific trait variation tree leaf traits temperate forest; published 2022 or later; articles', n: 8 },
    ];
    L.screen = [
      { key: '10.3389/ffgc.2021.754063', title: 'Montane Temperate-Boreal Forests Retain the Leaf Economic Spectrum Despite Intraspecific Variability', doi: '10.3389/ffgc.2021.754063', decision: 'include', reason: '', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1111/1365-2435.14549', title: 'Tree and mycorrhizal fungal diversity drive intraspecific and intraindividual trait variation in temperate forests', doi: '10.1111/1365-2435.14549', decision: 'include', reason: '', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1111/1365-2435.70411', title: 'Intraspecific variability rivals interspecific differences in root traits of temperate tree seedlings', doi: '10.1111/1365-2435.70411', decision: 'include', reason: '', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1002/pei3.70019', title: 'Intraspecific Trait Variation in Seedlings Reveals Independence Between Leaf and Root Traits but a Lack of an Independent Collaboration Axis Belowground', doi: '10.1002/pei3.70019', decision: 'exclude', reason: 'Different method, not useful for my design', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1080/07038992.2025.2608440', title: 'Mapping canopy foliar functional traits in a mixed temperate forest using imaging spectroscopy', doi: '10.1080/07038992.2025.2608440', decision: 'exclude', reason: 'Different method, not useful for my design', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1186/s12870-023-04097-y', title: 'Intraspecific variations in leaf functional traits of Cunninghamia lanceolata provenances', doi: '10.1186/s12870-023-04097-y', decision: 'exclude', reason: 'Different organism or system', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1111/geb.13789', title: 'Trait\u2013micro-environment relationships of forest herb communities across Europe', doi: '10.1111/geb.13789', decision: 'exclude', reason: 'Different organism or system', date: '2026-11-19', pos: '', kind: 'article' },
      { key: '10.1007/s11676-022-01594-y', title: 'Leaf thermal tolerance and sensitivity of temperate tree species are correlated with leaf physiological and functional drought resistance traits', doi: '10.1007/s11676-022-01594-y', decision: 'exclude', reason: 'Not about the PI\u2019s current research direction', date: '2026-11-19', pos: '', kind: 'article' },
    ];
    EXAMPLE.library = L;
  })();

  return { CHECKED, PI_EXTRA, FUNDERS, GLOSSARY, CRITERIA, GAP_QUESTIONS, SOURCE_KINDS, EXAMPLE, REFS };
})();

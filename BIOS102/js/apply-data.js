// BIOS102 Application Hub: the Summer 2027 program data.
//
// SOURCE: "UW-Parkside Summer 2027 Research Directory" (checked Nov 19, 2026), a working
// directory of 43 entries. Seven of the highest-priority programs were also re-read on
// their own official pages on Nov 19, 2026 (field `checked: 'page'`). Everything else is
// `checked: 'directory'`: taken from the directory and NOT re-read on the official page.
// Wherever the directory says a date, pay or link is unverified, this file says so too.
// Rule: never fill a gap with a guess. A blank means "check the official page".
// Before each student submits, they must re-open the official page (the app says so).
//
// req codes:  cit  'us-pr'  U.S. citizen or permanent resident
//                  'us-nat-pr' also U.S. nationals
//                  'visa-ok' also some visa holders with work authorization (MCW SURE)
//             gpa  stated minimum; softGpa = stated only in a secondary listing
//             notGrad  must still be an undergraduate after summer 2027
//             phd  program expects PhD or MD-PhD interest (the student must be truthful)
//             blocked  a stated rule that rules most Parkside students out
window.AP_DATA = (() => {
  const CHECKED = 'November 19, 2026';
  const YEAR = 2027;

  const LA = 'Applications go through the Leadership Alliance portal. Select the exact host and track, and read the host’s site-specific rules before you submit.';
  const GEN = [{ id: 'statement', label: 'Statement of interest or personal statement', hint: 'Check the portal for the exact prompt and length. Start from your master statement.' }];

  const P = [
    // ---------------- ranked ----------------
    { id: 'madison', rank: 1, name: 'UW–Madison Biological Interactions REU', org: 'UW–Madison', region: 'WI', city: 'Madison', focus: 'A full-time, mentored bioscience research project; 10 weeks.',
      dates: 'June 1 to August 7, 2027', deadline: '2027-02-10', deadlineText: 'February 10, 2027 (opened November 1, 2026)',
      pay: '$7,000 stipend', housing: 'Housing, partial meal plan, round-trip travel, health insurance if needed', status: 'Open', checked: 'page',
      req: { cit: 'us-pr', notGrad: true }, eligibility: 'U.S. citizen or permanent resident. At least 2 semesters done by the summer, and at least 1 left afterward. Built for students with limited access to research; no prior research required.',
      beginner: true, lists: ['regional', 'beginner', 'housing'],
      links: { page: 'https://wiscience.wisc.edu/research/summer_research_program/', apply: 'https://etap.nsf.gov/award/8540/opportunity/12051', applyKind: 'portal' },
      recs: 2, recsNote: 'Two people who can write letters. Faculty are preferred.', materials: ['Unofficial transcript (electronic is fine)', 'Four short essays (5,000 characters each)', 'Two recommenders (names and emails)'],
      prompts: [
        { id: 'e1', label: 'How have your background and life experiences (including cultural, geographical, financial, educational, or other opportunities or challenges) motivated your decision to pursue a summer research opportunity?', limit: { chars: 5000 } },
        { id: 'e2', label: 'How would your participation in a summer research program at UW–Madison contribute to your future goals and career plans?', limit: { chars: 5000 } },
        { id: 'e3', label: 'Which area(s) of research are of interest to you and why?', limit: { chars: 5000 } },
        { id: 'e4', label: 'Although previous research experience is not required, please describe any past research experience. This may include research experiences as part of a course if you do not have any other research experiences.', limit: { chars: 5000 } },
      ],
      notes: ['The official page says funding is under review and offers depend on funding.', 'Signed offers are due mid-March to early April.'] },

    { id: 'reuextend', rank: 2, name: 'Illinois Prairie Research Institute REU-EXTEND', org: 'University of Illinois Urbana-Champaign', region: 'IL', city: 'Urbana', focus: 'Biological collections and their data: fieldwork, curation, genomics, bioinformatics; 10 students.',
      dates: 'May 25 to August 1, 2027', deadline: '2027-01-31', deadlineText: 'January 31, 2027. Offers February 22. Accept or decline by March 19.',
      pay: '$7,000 ($700 a week)', housing: 'Residence hall lodging, meals and one round trip included', status: 'Published 2027', checked: 'page',
      req: { cit: 'us-nat-pr', gpa: 3.0, notGrad: true, age18: true }, eligibility: 'At least 18 by the start date. U.S. citizen, national or permanent resident. Enrolled in a life-sciences degree before and after the program. GPA 3.0 or higher. No prior research required.',
      beginner: true, lists: ['regional', 'beginner', 'housing'],
      links: { page: 'https://www.prairie.illinois.edu/about/internships/reu-extend/', apply: 'https://www.prairie.illinois.edu/about/internships/reu-extend/', applyKind: 'instructions' },
      recs: 2, recsNote: 'Two letters of recommendation.', materials: ['Résumé or CV', 'Transcripts', '1-page personal statement on research interests and career goals', 'Two letters of recommendation'],
      prompts: [{ id: 'statement', label: '1-page personal statement: research interests and career goals. In it, rank up to three biological collections you would like to work with.', limit: { note: '1 page' } }],
      notes: ['Preference goes to students from institutions outside UIUC.', 'Start from the official instructions page. A direct portal link was not verified.'] },

    { id: 'freshwater', rank: 3, name: 'Freshwater@UW SROP', org: 'UW System (several campuses)', region: 'WI', city: 'Madison, Milwaukee, Green Bay and other sites', focus: 'Water research; projects at UW–Milwaukee, UW–Green Bay, UW–Madison and other sites.',
      dates: 'Not stated in the directory', deadline: '2027-02-10', deadlineText: 'February 10, 2027',
      pay: '$6,732', housing: 'Housing provided; varies by site', status: 'Published 2027', checked: 'directory',
      req: { cit: 'us-pr', notGrad: true }, eligibility: 'U.S. citizen or permanent resident. Enrolled through fall 2027. Some projects need specific skills.',
      beginner: true, lists: ['regional', 'beginner', 'housing'],
      links: { page: 'https://water.wisc.edu/wateruw-madison-undergraduate-research/', apply: 'https://water.wisc.edu/wateruw-madison-undergraduate-research/', applyKind: 'instructions' },
      recs: null, recsNote: 'Check the project instructions.', materials: ['Check the official instructions'], prompts: GEN,
      notes: ['Select the eligible project sites in the project’s own application instructions.'] },

    { id: 'aspire', rank: 4, name: 'MCW ASPIRE (cardiovascular research)', org: 'Medical College of Wisconsin', region: 'WI', city: 'Milwaukee', focus: 'Paid, mentored, full-time cardiovascular lab research and STEMM/healthcare career preparation; up to 13 students.',
      dates: 'June 2 to August 6, 2027 (housing move-in June 1)', deadline: '2027-02-01', deadlineText: 'February 1, 2027 (opened November 1). Check the time zone in the portal.',
      pay: 'Paid (amount: see the program page). Optional $1,400 for a scientific conference with your mentor.', housing: 'Free housing for students outside the Milwaukee metro area', status: 'Open', checked: 'page',
      req: { cit: 'us-pr' }, eligibility: 'U.S. citizen or permanent resident. GPA is reviewed as part of a holistic review.',
      beginner: true, lists: ['regional', 'beginner', 'housing'],
      links: { page: 'https://www.mcw.edu/departments/cardiovascular-research-center/education/advancing-student-potential-for-inclusion-with-research-experiences-aspire', apply: 'https://admissions.mcw.edu/register/?id=9b322b23-f3c2-4471-a54e-371654c83ce8', applyKind: 'portal' },
      recs: null, recsNote: 'Confirm the number of recommenders inside the form.', materials: ['The shared form is labeled "Summer Programs 2027 Application"', 'Check the form for transcript, essay and recommender requirements'], prompts: GEN,
      notes: ['ASPIRE and SURE use the same MCW form. Choose the programs you want inside it.'] },

    { id: 'sure', rank: 5, name: 'MCW SURE (cardiovascular research, AHA)', org: 'Medical College of Wisconsin', region: 'WI', city: 'Milwaukee', focus: 'Paid, mentored, full-time cardiovascular lab research; up to 4 students.',
      dates: 'June 2 to August 6, 2027 (housing move-in June 1)', deadline: '2027-02-01', deadlineText: 'February 1, 2027 (opened November 1)',
      pay: 'Paid (amount: see the program page)', housing: 'Free housing for students outside the Milwaukee metro area', status: 'Open', checked: 'page',
      req: { cit: 'visa-ok' }, eligibility: 'U.S. citizen, permanent resident, or a foreign national on a valid student, exchange or permanent-resident visa (F-1, H1, H1B, J1, PR, TC, TN) with approved OPT or CPT before the appointment. GPA is part of a holistic review.',
      beginner: true, lists: ['regional', 'beginner', 'housing'],
      links: { page: 'https://www.mcw.edu/departments/cardiovascular-research-center/education/supporting-undergraduate-research-experiences-sure-program', apply: 'https://admissions.mcw.edu/register/?id=9b322b23-f3c2-4471-a54e-371654c83ce8', applyKind: 'portal' },
      recs: null, recsNote: 'Confirm the number of recommenders inside the form.', materials: ['The shared form is labeled "Summer Programs 2027 Application"', 'Check the form for transcript, essay and recommender requirements'], prompts: GEN,
      notes: ['ASPIRE and SURE use the same MCW form.'] },

    { id: 'suip', rank: 6, name: 'Penn Perelman SUIP', org: 'University of Pennsylvania', region: 'National', city: 'Philadelphia, PA', focus: 'Ten weeks of immersive biomedical lab research with a matched mentor, plus a symposium. For students aiming at a PhD or MD-PhD.',
      dates: 'June 7 to August 13, 2027 (move-in June 5 or 6)', deadline: '2027-02-01', deadlineText: 'February 1, 2027 at 11:59 p.m. Eastern (10:59 p.m. Central). Letters are due the same night.',
      pay: '$5,500', housing: 'On-campus housing and round-trip travel', status: 'Open', checked: 'page',
      req: { cit: 'us-pr', notGrad: true, phd: true }, eligibility: 'U.S. citizens and permanent residents only. Enrolled in a four-year college for the fall after the program (graduating seniors are not eligible). Prior research not required; sophomores and juniors are preferred. Meant for students aspiring to a PhD or MD-PhD.',
      beginner: true, lists: ['national', 'beginner', 'housing'],
      links: { page: 'https://www.med.upenn.edu/research-trainee-affairs/suip/', apply: 'https://apply.med.upenn.edu/apply/', applyKind: 'portal' },
      recs: 2, recsNote: 'Two recommenders. The portal emails them automatically. All letters are due 2/1/27 at 11:59 p.m. ET, or your application is incomplete.', materials: ['2-page research and personal statement (8.5 x 11 in, at least 0.5 in margins, at least 11 pt font)', 'Two recommenders in the Recommendations section', 'Select "SUIP" and "Summer 2027" in the portal'],
      prompts: [{ id: 'statement', label: 'Research and personal statement (2 pages): your meaningful research experiences and career goals, how your personal history and experiences shaped your motivation to pursue a PhD, and the challenges you have overcome in accessing research opportunities.', limit: { note: '2 pages' } }],
      notes: ['You can apply through Penn’s portal or through the Leadership Alliance.', 'Apply only if a PhD or MD-PhD is a real goal for you.', 'First-round offers come after February 18; decisions roll through March 18.'] },

    { id: 'lyric', rank: 7, name: 'Northwestern Lurie LYRIC (cancer research)', org: 'Northwestern University', region: 'IL', city: 'Chicago and Evanston', focus: 'Eight weeks of full-time cancer research (35 to 40 hours a week) at the Lurie Comprehensive Cancer Center.',
      dates: 'June 14 to August 6, 2027', deadline: '2027-02-14', deadlineText: 'Midnight Sunday, February 14, 2027. Letters are due the same day. Notifications March 15; commit by April 1.',
      pay: '$6,000 taxable stipend', housing: 'None. You arrange your own housing and daily transportation (a free shuttle links the Chicago and Evanston campuses).', status: 'Open', checked: 'page',
      req: { cit: 'us-pr', notGrad: true }, eligibility: 'U.S. citizen or permanent resident. A college freshman, sophomore, junior or senior in September 2027. Designed to expand access for students with limited research experience.',
      beginner: true, lists: ['regional'],
      links: { page: 'https://www.cancer.northwestern.edu/research/education-training/summer-research/lyric.html', apply: 'https://www.cancer.northwestern.edu/research/education-training/summer-research/lyric.html', applyKind: 'instructions' },
      recs: 2, recsNote: 'Two people, at least one a teacher. The portal emails them automatically when you submit, so submit early.', materials: ['Application (click "apply online here" on the program page)', 'Three short essays (250 words each)', 'Two letters of recommendation, due by February 14', 'Cumulative GPA is requested'],
      prompts: [
        { id: 'e1', label: 'Describe how your background and experiences have shaped your interest in the LYRIC program. Examples might include academic or personal experiences, or an experience related to your background.', limit: { words: 250 } },
        { id: 'e2', label: 'Describe a personal experience of scientific curiosity and wonder.', limit: { words: 250 } },
        { id: 'e3', label: 'Please describe any past research experiences. This can include informal and formal experiences.', limit: { words: 250 } },
      ],
      notes: ['The "apply online here" link first opens a demographics survey. Make sure you reach the full LYRIC application before you assume you are done.', 'Finalists may be invited to a Zoom interview in February or March.'] },

    { id: 'uicsurf', rank: 8, name: 'UIC Pharmacy SURF', org: 'University of Illinois Chicago', region: 'IL', city: 'Chicago', focus: 'Pharmaceutical sciences research.',
      dates: 'June 1 to August 6, 2027', deadline: '2027-01-25', deadlineText: 'January 25, 2027. Letters are due the same day. Decisions by April 15.',
      pay: '$7,000 and travel', housing: 'Not verified', status: 'Open', checked: 'page',
      req: { cit: 'us-pr', gpa: 3.2, phd: true, years: ['second', 'third'] }, eligibility: 'GPA 3.2 or higher on a 4.0 scale. U.S. citizens and permanent residents. Sophomores and juniors in a related major. Interest in graduate study.',
      beginner: false, lists: ['regional'],
      links: { page: 'https://surf.pharmacy.uic.edu/apply/', apply: 'https://surf.pharmacy.uic.edu/apply/', applyKind: 'instructions' },
      recs: 2, recsNote: 'Two academic letters (current or former professors or advisors) on official letterhead with a signature. Recommenders email them to surf@uic.edu by January 25.', materials: ['Application form', 'Personal statement (uploaded)', 'Transcripts (uploaded)', 'Two academic letters emailed to surf@uic.edu'],
      prompts: [{ id: 'statement', label: 'Personal statement', hint: 'See the official page for the prompt.' }],
      notes: ['Letters must go to surf@uic.edu themselves. You cannot upload them for your recommenders.'] },

    { id: 'uchicagome', rank: 9, name: 'UChicago Molecular Engineering REU', org: 'University of Chicago', region: 'IL', city: 'Chicago', focus: 'Molecular engineering lab; choose a biologically relevant project.',
      dates: 'Not stated in the directory', deadline: '2027-02-15', deadlineText: 'February 15, 2027', pay: '$7,000', housing: 'Housing and meals', status: 'Published 2027', checked: 'directory',
      req: { cit: 'us-pr' }, eligibility: 'U.S. citizen or permanent resident. STEM major. Targets colleges with limited research opportunities; confirm how Parkside is classified.',
      beginner: false, lists: ['regional', 'housing'],
      links: { page: 'https://pme.uchicago.edu/academics/stem-education-community-outreach/summer-research-experiences-programs/research', apply: 'https://apply-grad.uchicago.edu/apply/', applyKind: 'portal' },
      recs: null, recsNote: 'Check the portal.', materials: ['Check the official page'], prompts: GEN, notes: [] },

    { id: 'weill', rank: 10, name: 'Weill Cornell Gateways to the Laboratory', org: 'Weill Cornell Medicine', region: 'National', city: 'New York, NY', focus: 'Nine weeks from June 7 with research at Cornell, Rockefeller or Memorial Sloan Kettering.',
      dates: 'From June 7, 2027 (nine weeks)', deadline: '2027-02-03', deadlineText: 'February 3, 2027 via the Leadership Alliance',
      pay: '$5,500', housing: 'Campus housing and travel reimbursement', status: 'Open', checked: 'directory',
      req: { cit: 'us-pr', gpa: 3.0, softGpa: true }, eligibility: 'External via the Leadership Alliance. Check the MD-PhD orientation and site rules.',
      beginner: true, lists: ['national', 'beginner', 'housing'],
      links: { page: 'https://teach.weill.cornell.edu/mdphd/undergraduate-summer-program', apply: 'https://app.theleadershipalliance.org/', applyKind: 'portal' },
      recs: null, recsNote: 'Check the Leadership Alliance portal.', materials: [LA], prompts: GEN, notes: [LA] },

    { id: 'shurp', rank: 11, name: 'Harvard Medical School SHURP', org: 'Harvard Medical School', region: 'National', city: 'Boston, MA', focus: 'Mentored biomedical research; select the Harvard Division of Medical Sciences.',
      dates: 'Not stated in the directory', deadline: '2027-02-03', deadlineText: 'February 3, 2027 via the Leadership Alliance (SR-EIP)',
      pay: 'See the Housing, Travel, and Program Funding tab on the Harvard page', housing: 'See the funding tab', status: 'Open', checked: 'directory',
      req: { cit: 'us-pr', gpa: 3.0, softGpa: true }, eligibility: 'External via the Leadership Alliance. Check the Harvard site-specific rules.',
      beginner: true, lists: ['national', 'beginner'],
      links: { page: 'https://shurp.hms.harvard.edu/application', apply: 'https://app.theleadershipalliance.org/', applyKind: 'portal' },
      recs: null, recsNote: 'Check the Leadership Alliance portal.', materials: [LA], prompts: GEN, notes: [LA] },

    { id: 'pni', rank: 12, name: 'Princeton PNI SYNAPSE (neuroscience)', org: 'Princeton Neuroscience Institute', region: 'National', city: 'Princeton, NJ', focus: 'Neuroscience research.',
      dates: 'May 31 to July 30, 2027', deadline: '2027-02-03', deadlineText: 'February 3, 2027 via the Alliance. The NSF route deadline is to be announced.',
      pay: 'See the PNI funding terms', housing: 'See the PNI funding terms', status: 'Published 2027', checked: 'directory',
      req: { cit: 'us-pr', gpa: 3.0, softGpa: true }, eligibility: 'External route via the Alliance or NSF ETAP. This is separate from the Princeton-only route.',
      beginner: true, lists: ['national', 'beginner'],
      links: { page: 'https://pni.princeton.edu/apply/undergraduate-summer-research-programs/application-process', apply: 'https://app.theleadershipalliance.org/', applyKind: 'portal' },
      recs: null, recsNote: 'Check the portal.', materials: [LA], prompts: GEN, notes: [LA] },

    { id: 'ucsf', rank: 13, name: 'UCSF SRTP', org: 'UCSF', region: 'National', city: 'San Francisco, CA', focus: 'Mentored health-science research.',
      dates: 'Not stated in the directory', deadline: '2027-02-01', deadlineText: 'February 1, 2027 at 11:59 p.m. Pacific (1:59 a.m. Central, February 2)',
      pay: 'Competitive stipend, public transit support and housing', housing: 'Included', status: 'Open', checked: 'directory',
      req: { cit: 'us-pr' }, eligibility: 'External pathway. Check the 2027 eligibility panel.',
      beginner: false, lists: ['national'],
      links: { page: 'https://graduate.ucsf.edu/academics/srtp', apply: 'https://gradapp.ucsf.edu/register/apply', applyKind: 'portal' },
      recs: null, recsNote: 'Check the portal.', materials: ['Check the official page'], prompts: GEN, notes: [] },

    { id: 'jhsip', rank: 14, name: 'Johns Hopkins Medicine Summer Internship Program', org: 'Johns Hopkins Medicine', region: 'National', city: 'Baltimore, MD', focus: 'Biomedical research across divisions; most start May 30 and end August 6.',
      dates: 'Most May 30 to August 6, 2027', deadline: '2027-02-01', deadlineText: 'February 1, 2027 at 11:59 p.m. Eastern (10:59 p.m. Central)',
      pay: 'Check the division-specific stipend', housing: 'Check division terms', status: 'Open', checked: 'directory',
      req: { cit: 'us-pr' }, eligibility: 'External U.S. college students. U.S. citizen or permanent resident. Check division rules.',
      beginner: false, lists: ['national'],
      links: { page: 'https://www.hopkinsmedicine.org/som/pathway/summer-internship-program', apply: 'https://www.hopkinsmedicine.org/som/pathway/summer-internship-program', applyKind: 'instructions' },
      recs: null, recsNote: 'Check the official instructions.', materials: ['Check the official instructions'], prompts: GEN, notes: [] },

    { id: 'stanford', rank: 15, name: 'Stanford SSRP / Amgen Scholars', org: 'Stanford University', region: 'National', city: 'Stanford, CA', focus: 'Biosciences lab research.',
      dates: 'June 19 to August 14, 2027', deadline: '2027-02-01', deadlineText: 'February 1, 2027',
      pay: 'See the funding and eligibility pages', housing: 'See the funding pages', status: 'Open', checked: 'directory',
      req: { cit: 'us-pr', phd: true }, eligibility: 'External pathway. Amgen Scholars citizenship and permanent-resident rules apply.',
      beginner: false, lists: ['national'],
      links: { page: 'https://biosciences.stanford.edu/pathways/ssrp-amgen-scholars-program/the-ssrp-amgen-scholars-program-application/', apply: 'https://biosciences.stanford.edu/pathways/ssrp-amgen-scholars-program/the-ssrp-amgen-scholars-program-application/', applyKind: 'instructions' },
      recs: null, recsNote: 'Check the official instructions.', materials: ['Check the official instructions'], prompts: GEN, notes: ['Amgen programs usually expect interest in a PhD or MD-PhD. Apply only if that is true for you.'] },

    { id: 'thomson', rank: 16, name: 'UW–Parkside Thomson Research Fellowship', org: 'UW–Parkside', region: 'WI', city: 'Kenosha', focus: 'Faculty-mentored research on campus: field or lab projects with a Parkside biology professor.',
      dates: 'Two semesters, or a summer plus a semester', deadline: null, deadlineText: '2027 deadline not verified. Ask Dr. David Higgs (higgs@uwp.edu), the contact on the fellowship page.',
      pay: '$1,500 research stipend plus $1,000 for supplies through your advisor', housing: 'Not applicable (home campus)', status: 'Not verified for 2027', checked: 'page',
      req: { declaredMajor: true }, eligibility: 'Declared majors in the Department of Biological Sciences (undergraduate or graduate). Awarded in Fall and Spring.',
      beginner: true, lists: ['regional'],
      links: { page: 'https://www.uwp.edu/departments/biological-sciences/thomson-research-fellowship/', apply: 'https://www.uwp.edu/departments/biological-sciences/thomson-research-fellowship/', applyKind: 'instructions' },
      recs: null, recsNote: 'Ask Dr. Higgs.', materials: ['Find a faculty research mentor first (use Research Match)', 'Ask Dr. Higgs how and when to apply'], prompts: GEN,
      notes: ['Use the Research Match page to find and interview a mentor before you apply.'] },

    { id: 'argonne', rank: 17, name: 'Argonne DOE SULI', org: 'Argonne National Laboratory (DOE)', region: 'IL', city: 'Lemont', focus: 'Ten weeks; choose a biological or computational project if available.',
      dates: 'About 10 weeks', deadline: '2027-01-06', deadlineText: 'January 6, 2027 at 5 p.m. Eastern (4 p.m. Central)',
      pay: 'Paid; check DOE benefits and Argonne housing terms', housing: 'Check Argonne housing terms', status: 'Open', checked: 'directory',
      req: {}, eligibility: 'External DOE program. Verify the academic, citizenship and project requirements.',
      beginner: false, lists: ['regional'],
      links: { page: 'https://science.osti.gov/wdts/suli/how-to-apply', apply: 'https://science.osti.gov/wdts/suli/how-to-apply', applyKind: 'instructions' },
      recs: null, recsNote: 'Check the official instructions.', materials: ['Check the official instructions'], prompts: GEN, notes: ['This deadline is early. Start now.'] },

    { id: 'fredhutch', rank: 18, name: 'Fred Hutch SURP', org: 'Fred Hutchinson Cancer Center', region: 'National', city: 'Seattle, WA', focus: 'Nine weeks of biomedical and cancer research.',
      dates: 'Nine weeks', deadline: '2027-01-08', deadlineText: 'January 8, 2027. References are due January 15.',
      pay: 'Paid; housing is self-funded (campus option about $3,400)', housing: 'Self-funded', status: 'Open', checked: 'directory',
      req: { cit: 'us-pr' }, eligibility: 'External. Intended for the summer before your final year of a semester or quarter system. Check citizenship rules on the page.',
      beginner: false, lists: ['national'],
      links: { page: 'https://www.fredhutch.org/en/education-training/undergraduate-students/summer-undergraduate-research-program.html', apply: 'https://form.jotform.com/fredhutch/2027SURP', applyKind: 'portal' },
      recs: null, recsNote: 'References are due January 15.', materials: ['Check the application form'], prompts: GEN, notes: ['This deadline is early. Start now.'] },

    { id: 'columbia', rank: 19, name: 'Columbia Amgen Scholars', org: 'Columbia University', region: 'National', city: 'New York, NY', focus: 'Biology and biotechnology lab research.',
      dates: 'June 1 to August 6, 2027', deadline: '2027-02-01', deadlineText: 'February 1, 2027. References by 5 p.m. per Columbia’s instructions.',
      pay: 'Check funding terms', housing: 'Housing provided', status: '2027 instructions, form labeled 2026', checked: 'directory',
      req: { cit: 'us-pr', phd: true }, eligibility: 'External. U.S. citizen or permanent resident. Columbia directs its own students separately.',
      beginner: false, lists: ['national'],
      links: { page: 'https://biology.columbia.edu/content/apply-amgen', apply: 'https://cubweb.biology.columbia.edu/introbio/app/amgen.php', applyKind: 'portal' },
      recs: null, recsNote: 'References are due by 5 p.m. on the deadline.', materials: ['Check the form'], prompts: GEN,
      notes: ['The application heading says 2026 while the instructions name 2027. Confirm the cycle inside the form before you fill it out.'] },

    { id: 'yale', rank: 20, name: 'Yale BioMed Amgen', org: 'Yale School of Medicine', region: 'National', city: 'New Haven, CT', focus: 'Biomedical lab research.',
      dates: 'Conflicting dates: ask Yale to confirm before booking travel', deadline: null, deadlineText: 'Dates conflict between Yale and the Amgen directory. Confirm with Yale.',
      pay: '$5,000, $725 for food, and travel reimbursement up to $750 (per Yale)', housing: 'Housing provided (per Yale)', status: 'Published 2027, dates conflict', checked: 'directory',
      req: { cit: 'us-pr', phd: true }, eligibility: 'External Amgen pathway. U.S. citizen or permanent resident.',
      beginner: false, lists: ['housing'],
      links: { page: 'https://medicine.yale.edu/biomedsurf/', apply: 'https://medicine.yale.edu/biomedsurf/', applyKind: 'instructions' },
      recs: null, recsNote: 'Check the Yale instructions.', materials: ['Check the Yale instructions'], prompts: GEN, notes: ['Do not rely on either date until Yale confirms.'] },

    // ---------------- not ranked ----------------
    { id: 'mcwspur', rank: null, name: 'MCW SPUR', org: 'Medical College of Wisconsin Graduate School', region: 'WI', city: 'Milwaukee', focus: 'Exposure to biomedical graduate research.', dates: 'Check the application page', deadline: null, deadlineText: 'Check the cycle on the application page', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application instructions', checked: 'directory', req: {}, eligibility: 'Students at accredited colleges who are pursuing scientific graduate study.', beginner: false, lists: [], links: { page: 'https://www.mcw.edu/education/graduate-school/prospective-students/summer-program-for-undergraduate-research', apply: 'https://www.mcw.edu/education/graduate-school/prospective-students/summer-program-for-undergraduate-research/spur-application', applyKind: 'portal' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'mcwshrep', rank: null, name: 'MCW SHREP', org: 'Medical College of Wisconsin', region: 'WI', city: 'Milwaukee', focus: 'Mentored biomedical and health research.', dates: 'Check the program page', deadline: null, deadlineText: 'Check the deadlines on the program page', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application instructions', checked: 'directory', req: {}, eligibility: 'Undergraduates and graduate students. Review the applicable track.', beginner: false, lists: [], links: { page: 'https://www.mcw.edu/education/office-of-academic-pathways/summer-programs/shrep', apply: 'https://www.mcw.edu/education/office-of-academic-pathways/summer-programs/shrep', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'marshfield', rank: null, name: 'Marshfield Clinic SRIP', org: 'Marshfield Clinic Research Institute', region: 'WI', city: 'Marshfield', focus: 'Mentored health research.', dates: '2027 terms pending', deadline: null, deadlineText: 'A late-November or early-December 2026 update is expected', pay: '2027 terms pending', housing: 'Pending', status: 'Upcoming update', checked: 'directory', req: {}, eligibility: 'Historically included outside undergraduates. 2027 eligibility is pending.', beginner: false, lists: [], links: { page: 'https://www.marshfieldresearch.org/srip', apply: '', applyKind: 'none' }, recs: null, recsNote: '', materials: ['APPLICATION LINK NOT YET VERIFIED. Return to the official page when the host updates it.'], prompts: GEN, notes: ['No application link has been verified yet.'] },
    { id: 'madisonchem', rank: null, name: 'UW–Madison Chemistry / Chemical and Biological Engineering REU', org: 'UW–Madison', region: 'WI', city: 'Madison', focus: 'Chemistry and engineering; check how well a biological project fits.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the sponsor’s instructions', pay: '$6,000', housing: 'Housing and travel', status: 'Published 2027', checked: 'directory', req: {}, eligibility: 'External NSF route. Check the prerequisites.', beginner: false, lists: [], links: { page: 'https://reucbe.chem.wisc.edu/', apply: 'https://reucbe.chem.wisc.edu/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'ucreate', rank: null, name: 'UIC U-CREATE (cancer research)', org: 'University of Illinois Cancer Center', region: 'IL', city: 'Chicago', focus: 'Ten weeks of cancer research.', dates: '10 weeks', deadline: null, deadlineText: 'Mid-January 2027. The exact date is unverified.', pay: '$5,000 on completion', housing: 'Not verified', status: 'Published 2027', checked: 'directory', req: { gpa: 3.0 }, eligibility: 'Rising sophomores through seniors in STEM. GPA 3.0. Confirm outside-school eligibility on the form.', beginner: false, lists: [], links: { page: 'https://cancer.uillinois.edu/education-training/high-school-undergraduate-and-postbaccalaureate-students/ucreate', apply: 'https://cancer.uillinois.edu/education-training/high-school-undergraduate-and-postbaccalaureate-students/ucreate', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'brown', rank: null, name: 'Brown SR-EIP', org: 'Brown University', region: 'National', city: 'Providence, RI', focus: 'Select a published Brown life-science field in the Alliance portal.', dates: 'Check Brown’s terms', deadline: '2027-02-03', deadlineText: 'February 3, 2027 at 11:59 p.m. Eastern via SR-EIP', pay: 'Check Brown’s terms', housing: 'Check Brown’s terms', status: 'Alliance open; confirm the site selection', checked: 'directory', req: { gpa: 3.0, softGpa: true }, eligibility: 'External. The Leadership Alliance sets a 3.0 minimum and federal-status restrictions. Confirm the field.', beginner: false, lists: [], links: { page: 'https://sites.brown.edu/sreip/brown-sr-eip/', apply: 'https://app.theleadershipalliance.org/', applyKind: 'portal' }, recs: null, recsNote: '', materials: [LA], prompts: GEN, notes: [LA] },
    { id: 'dartmouth', rank: null, name: 'Dartmouth Geisel iSURF', org: 'Dartmouth Geisel School of Medicine', region: 'National', city: 'Hanover, NH', focus: 'About eight weeks of biomedical research.', dates: 'About eight weeks', deadline: null, deadlineText: 'Check the official instructions', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Restricted lead', checked: 'directory', req: { blocked: 'Restricted to students who live or study in listed INBRE jurisdictions. Wisconsin alone does not qualify.' }, eligibility: 'Restricted to enrollment or residency in listed INBRE jurisdictions. Wisconsin alone does not qualify.', beginner: false, lists: [], links: { page: 'https://geiselmed.dartmouth.edu/nhinbre/about-us/isurf/', apply: 'https://geiselmed.dartmouth.edu/nhinbre/about-us/isurf/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Probably not open to Parkside students'], prompts: GEN, notes: [] },
    { id: 'baylor', rank: null, name: 'Baylor SMART', org: 'Baylor College of Medicine', region: 'National', city: 'Houston, TX', focus: 'Biomedical lab research.', dates: 'Check the sponsor', deadline: '2027-01-22', deadlineText: 'January 22, 2027', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Open', checked: 'directory', req: {}, eligibility: 'External pathway. Check the academic and citizenship rules.', beginner: false, lists: ['national'], links: { page: 'https://www.bcm.edu/education/graduate-school-of-biomedical-sciences/degree-programs-and-certificates/smart-program', apply: 'https://www.bcm.edu/education/graduate-school-of-biomedical-sciences/degree-programs-and-certificates/smart-program', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'casepharm', rank: null, name: 'Case Western Pharmacology SURP', org: 'Case Western Reserve University', region: 'National', city: 'Cleveland, OH', focus: 'Introduction to basic laboratory research.', dates: 'Check the sponsor', deadline: '2027-01-15', deadlineText: 'January 15, 2027', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Published 2027', checked: 'directory', req: {}, eligibility: 'Check the academic and citizenship rules.', beginner: true, lists: ['beginner'], links: { page: 'https://case.edu/medicine/pharmacology/education-training/summer-undergraduate-research-program', apply: 'https://case.edu/medicine/pharmacology/education-training/summer-undergraduate-research-program', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'cansur', rank: null, name: 'Case Comprehensive Cancer Center CanSUR', org: 'Case Western Reserve University', region: 'National', city: 'Cleveland, OH', focus: 'Cancer research.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the sponsor’s current cycle', pay: 'Check the sponsor', housing: 'Check the sponsor', status: '2027 announced; stale text also present', checked: 'directory', req: { cit: 'us-pr' }, eligibility: 'U.S. citizen or permanent resident per the site. Check your standing.', beginner: false, lists: [], links: { page: 'https://case.edu/cancer/training-education/cansur/application-instructions', apply: 'https://case.edu/cancer/training-education/cansur/application-instructions', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'moffitt', rank: null, name: 'Moffitt SPARK', org: 'Moffitt Cancer Center', region: 'National', city: 'Tampa, FL', focus: 'Full-time mentored cancer research.', dates: 'Check the sponsor', deadline: '2027-01-06', deadlineText: 'January 6, 2027 at 5 p.m. Eastern (4 p.m. Central)', pay: 'Check the stipend', housing: 'No housing or housing allowance', status: 'Published 2027', checked: 'directory', req: { cit: 'us-pr' }, eligibility: 'At least 18. Enrolled undergraduate. U.S. citizen or permanent resident. No minimum GPA.', beginner: false, lists: [], links: { page: 'https://www.moffitt.org/education/research-education-and-training/office-of-undergraduate-and-visiting-scholar-affairs/spark/', apply: 'https://moffitt.smapply.io/prog/spark_summer_application/', applyKind: 'portal' }, recs: null, recsNote: '', materials: ['Check the portal'], prompts: GEN, notes: ['This deadline is early. Start now.'] },
    { id: 'mayo', rank: null, name: 'Mayo Clinic SURF', org: 'Mayo Clinic College of Medicine and Science', region: 'National', city: 'Rochester, MN and other sites', focus: 'Biomedical lab research.', dates: 'June 1 to August 6, 2027', deadline: '2027-02-03', deadlineText: 'February 3, 2027', pay: 'See Mayo funding terms', housing: 'See Mayo funding terms', status: 'Open', checked: 'directory', req: {}, eligibility: 'External pathway. Verify your standing and the location.', beginner: false, lists: ['national'], links: { page: 'https://college.mayo.edu/academics/biomedical-research-training/summer-undergraduate-research-fellowship-surf/application-process/', apply: 'https://college.mayo.edu/academics/biomedical-research-training/summer-undergraduate-research-fellowship-surf/application-process/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'ufscripps', rank: null, name: 'UF Scripps SURF', org: 'University of Florida Scripps', region: 'National', city: 'Jupiter, FL', focus: 'Biomedical lab research.', dates: 'May 31 to August 13, 2027', deadline: '2027-02-01', deadlineText: 'February 1, 2027. The application is expected in mid-December 2026.', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Upcoming', checked: 'directory', req: {}, eligibility: 'Review the NSF REU eligibility and the track requirements.', beginner: false, lists: [], links: { page: 'https://wertheim.scripps.ufl.edu/education/surf/', apply: 'https://wertheim.scripps.ufl.edu/education/surf/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'gates', rank: null, name: 'Colorado Anschutz Gates GSIP', org: 'University of Colorado Anschutz', region: 'National', city: 'Aurora, CO', focus: 'Regenerative medicine and related biomedical research.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the 2027 portal', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application pathway', checked: 'directory', req: {}, eligibility: 'Check the academic-year and citizenship eligibility.', beginner: false, lists: [], links: { page: 'https://gates.cuanschutz.edu/education-and-training/gates-summer-internship-program', apply: 'https://gsip.secure-platform.com/a', applyKind: 'portal' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'pitt', rank: null, name: 'Pittsburgh Biomedical SURP', org: 'University of Pittsburgh', region: 'National', city: 'Pittsburgh, PA', focus: 'Biomedical research tracks.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the official application page', pay: 'Check the current terms', housing: 'Check the current terms', status: 'Application instructions', checked: 'directory', req: {}, eligibility: 'Check your track’s eligibility.', beginner: false, lists: [], links: { page: 'https://www.gradbiomed.pitt.edu/programs/summer-undergraduate-research-program', apply: 'https://www.gradbiomed.pitt.edu/programs/summer-undergraduate-research-program', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'utsw', rank: null, name: 'UT Southwestern SURF', org: 'UT Southwestern Medical Center', region: 'National', city: 'Dallas, TX', focus: 'Biomedical lab research.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the sponsor’s instructions', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application instructions', checked: 'directory', req: {}, eligibility: 'Check the eligibility and academic standing.', beginner: false, lists: [], links: { page: 'https://gsbs.utsouthwestern.edu/research-opportunities/surf/', apply: 'https://gsbs.utsouthwestern.edu/research-opportunities/surf/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'vssa', rank: null, name: 'Vanderbilt Summer Science Academy', org: 'Vanderbilt University School of Medicine', region: 'National', city: 'Nashville, TN', focus: 'Multiple research tracks, including biomedical programs.', dates: 'Varies by track', deadline: null, deadlineText: 'Varies. Verify the specific 2027 track.', pay: 'Track-specific', housing: 'Track-specific', status: '2027 cycle announced', checked: 'directory', req: {}, eligibility: 'Confirm external eligibility for the individual track. Some are restricted.', beginner: false, lists: [], links: { page: 'https://medschool.vanderbilt.edu/vssa/application/', apply: 'https://medschool.vanderbilt.edu/vssa/application/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'ucsdstars', rank: null, name: 'UC San Diego STARS', org: 'UC San Diego', region: 'National', city: 'La Jolla, CA', focus: 'Match to published 2027 projects.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the STARS application page', pay: 'Check the sponsor', housing: 'Check the sponsor', status: '2027 projects listed', checked: 'directory', req: {}, eligibility: 'Verify external applicant eligibility for your chosen project.', beginner: false, lists: [], links: { page: 'https://www.grad.ucsd.edu/oar2/undergraduate-students/stars/stars-application.html', apply: 'https://www.grad.ucsd.edu/oar2/undergraduate-students/stars/stars-application.html', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'uclabig', rank: null, name: 'UCLA Bruins-in-Genomics', org: 'UCLA', region: 'National', city: 'Los Angeles, CA', focus: 'Computational biology and genomics.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the program cycle', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application pathway', checked: 'directory', req: {}, eligibility: 'Verify the academic and program-specific eligibility.', beginner: false, lists: [], links: { page: 'https://qcb.ucla.edu/big-summer/', apply: 'https://qcb.ucla.edu/big-summer/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'nihsip', rank: null, name: 'NIH Summer Internship Program', org: 'National Institutes of Health', region: 'National', city: 'Multiple sites', focus: 'Mentored research in NIH intramural groups.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the OITE application schedule', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application pathway', checked: 'directory', req: {}, eligibility: 'Check the undergraduate and citizenship requirements. Institute placement varies.', beginner: false, lists: [], links: { page: 'https://www.training.nih.gov/research-training/pb/sip/', apply: 'https://www.training.nih.gov/research-training/pb/sip/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'scrippsr', rank: null, name: 'Scripps Research SURF', org: 'Scripps Research', region: 'National', city: 'La Jolla, CA', focus: 'Biomedical science research.', dates: 'Check the sponsor', deadline: null, deadlineText: 'Check the 2027 instructions', pay: 'Check the sponsor', housing: 'Check the sponsor', status: 'Application pathway', checked: 'directory', req: {}, eligibility: 'Check the external and citizenship requirements.', beginner: false, lists: [], links: { page: 'https://education.scripps.edu/undergraduate/summer-research/surf-program/', apply: 'https://education.scripps.edu/undergraduate/summer-research/surf-program/', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'jax', rank: null, name: 'Jackson Laboratory Summer Student Program', org: 'The Jackson Laboratory', region: 'National', city: 'Bar Harbor, ME / Farmington, CT (check current sites)', focus: 'Mentored genetics and genomics research.', dates: 'Check the site', deadline: '2027-01-25', deadlineText: 'January 25, 2027 at 5 p.m. Eastern (4 p.m. Central)', pay: '$7,500', housing: 'Room, board and travel advertised; Farmington is nonresidential', status: 'Published 2027', checked: 'directory', req: {}, eligibility: 'Check the site, your standing and the citizenship restrictions.', beginner: false, lists: ['national', 'housing'], links: { page: 'https://www.jax.org/education-and-learning/high-school-students-and-undergraduates/learn-earn-and-explore/admission', apply: 'https://www.jax.org/education-and-learning/high-school-students-and-undergraduates/learn-earn-and-explore/admission', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
    { id: 'urmc', rank: null, name: 'Rochester Medical Center Summer Scholars', org: 'University of Rochester Medical Center', region: 'National', city: 'Rochester, NY', focus: 'Mentored biomedical research and professional development.', dates: 'Check the program', deadline: null, deadlineText: 'Check the program instructions', pay: 'Check the program', housing: 'Check the program', status: 'Open per the sponsor', checked: 'directory', req: {}, eligibility: 'Verify your academic standing and status before applying.', beginner: false, lists: [], links: { page: 'https://www.urmc.rochester.edu/education/graduate/summer-scholars', apply: 'https://www.urmc.rochester.edu/education/graduate/summer-scholars', applyKind: 'instructions' }, recs: null, recsNote: '', materials: ['Check the official page'], prompts: GEN, notes: [] },
  ];

  // Programs that are NOT open to a typical Parkside applicant (from the directory's coverage notes).
  const NOT_FOR_YOU = [
    'Marquette Biological Sciences summer program: intended for Marquette undergraduates.',
    'Loyola Building Bridges: requires Loyola enrollment or credits.',
    'Ohio State ASPIRE: requires Ohio State undergraduate enrollment.',
    'Dartmouth TOPS: for first-year Geisel medical students.',
    'Princeton’s general Molecular Biology SURP: for Princeton’s own students (use PNI SYNAPSE for the external route).',
    'Emory SURE: the external instructions exist, but the general page names Emory enrollment. Confirm the external route first.',
    'Rosalind Franklin, Illinois Tech, SIU: no eligible 2027 external undergraduate lab application was verified.',
  ];

  // Deadline-ordered milestones and prep advice from the directory ("Prepare and apply").
  const PREP = [
    { when: 'November and December', text: 'Check your graduation date, GPA, semesters completed, and citizenship against each program. Ask two faculty members who can describe how you work to write for you. Give them your CV, a few examples from class or lab, and the deadline list.' },
    { when: 'Before winter break', text: 'Have a one-page CV, an unofficial transcript, a statement about what you want to learn, and two examples of how you handled feedback, documented observations, or persisted through a hard assignment. Add fall grades when a program asks. Verify recommendation counts, fees, interview requirements and transcript rules for each program.' },
    { when: 'Early January', text: 'Submit the January 6 to 15 applications first. Track whether your reference requests were sent and completed. Budget local transport, meals, deposits and move-in days. If housing is self-funded, subtract the housing cost from the published pay before you compare offers.' },
    { when: 'Late January and early February', text: 'Submit the late-January and February applications ahead of the deadlines. For the Leadership Alliance, review the site choices and rules before you submit. Keep every confirmation and note each reference deadline.' },
    { when: 'February through April', text: 'Prepare a short explanation of why you chose each program, and questions about day-to-day mentorship, training, the project and presentations. Before you accept, confirm offer dates, housing costs, travel reimbursement and the first pay date.' },
  ];

  // Master statement template pieces (from the directory). The student fills in their own words.
  const STATEMENT_FIELDS = [
    { id: 'noticed', label: 'Where did you notice something? (a course, lab, job or volunteer experience)', hint: 'For example: in BIOS102 lab, while dissecting an earthworm.' },
    { id: 'observation', label: 'What specific thing did you notice?', hint: 'One concrete observation you can picture.' },
    { id: 'question', label: 'What question did it make you curious about?', hint: 'A real question, not a slogan.' },
    { id: 'didwhat', label: 'What did you actually do to explore it?', hint: 'Only what you really did, even if small: looked it up, asked your instructor, repeated a measurement.' },
    { id: 'learned', label: 'What did you learn, or where did you get stuck?', hint: 'Getting stuck counts. It shows how you handle evidence.' },
    { id: 'skill', label: 'What habit or skill would you bring to a lab?', hint: 'For example: careful notes, showing up on time, following a protocol, asking for help early.' },
    { id: 'develop', label: 'What research skill do you hope to develop?', hint: 'For example: sterile technique, pipetting, PCR, microscopy, data analysis.' },
    { id: 'decide', label: 'What will this summer help you decide?', hint: 'An academic, scientific or career question.' },
  ];

  return { CHECKED, YEAR, PROGRAMS: P, NOT_FOR_YOU, PREP, STATEMENT_FIELDS };
})();

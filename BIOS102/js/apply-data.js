// BIOS102 Application Hub: constants, advice text and the link to the generated program data.
//
// PROGRAMS come from apply-programs.js, which is GENERATED from these files (all in
// Downloads\BOB, checked November 19, 2026):
//   - Summer 2027 Undergraduate Biology and Biomedical Research Directory (87 records)
//   - Parkside_Federal_Research_2027.xlsx (federal and NSF rows)
//   - Summer 2027 Federal and Access-Focused Research: Verified Supplement (newest; it corrects
//     the earlier federal table: NASA is March 1 and U.S. citizens only; the NOAA Hollings
//     internship is Summer 2028; MIT requires prior research)
//   - Summer 2027 Research Application Playbook (priority list and the A/B/C/housing lists)
//   - the correction notes supplied by the instructor
// Eight programs were also re-read on their own official pages (checked: "page").
// Each program carries `checked`: 'page' | 'supplement' | 'directory' | 'note'. Only 'page' and
// 'supplement' were individually confirmed; the others must be confirmed on the official page.
// Rule: never fill a gap with a guess. A blank means "check the official page".
window.AP_DATA = (() => {
  const CHECKED = 'November 19, 2026';
  const YEAR = 2027;
  const PROGRAMS = window.AP_PROGRAMS || [];
  const RELATED = window.AP_RELATED || [];

  const LISTS = {
    top: 'Top 20 picks',
    A: 'Wisconsin and Illinois picks',
    B: 'National picks',
    C: 'Good with little lab experience',
    H: 'Strong stipend and housing',
  };

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

  // The playbook's timeline, in plain steps.
  const PREP = [
    { when: 'Now through early December', text: 'Check the earliest dates first. Request your unofficial transcript and two recommendations. Start the UW or MCW form that fits. Note the programs that announce openings later, so you do not miss them.' },
    { when: 'December', text: 'Draft one statement you can adapt, then write a research-specific paragraph for each program. When a form has a live picker, check that the host, the program and Summer 2027 all appear before you submit. Check Marshfield’s update window (opens November 23) before you use an old page.' },
    { when: 'January', text: 'Submit before the deadline, ideally at least seven days early for portals that email your references only after you submit. DOE SULI closes January 6. Save every confirmation and confirm each recommender’s letter arrived.' },
    { when: 'Early to mid-February', text: 'Take the February 1 cluster one program at a time, then the February 10 and later ones. Freshwater@UW needs five project choices and at least one recommendation; a mentor email is not the application.' },
    { when: 'March and April', text: 'Compare written offers and waitlists by what you would actually keep after costs, by research fit, and by mentoring. If you get no offer, ask a Parkside faculty mentor about a summer-plus-fall Thomson project (use Research Match) instead of paying for a program that is mostly shadowing.' },
  ];

  const VERIFY = [
    'The form names the correct program and Summer 2027.',
    'The applicant category is undergraduate.',
    'Every required letter has a route that has not expired.',
    'If the link only reaches a general sign-in page, follow the program’s own instructions. A sign-in page does not prove you can submit.',
    'If a page still says 2026, email the named coordinator and ask for the current link and requirements before you send any sensitive information.',
  ];

  const AFFORD = 'Treat a stipend as gross cash. Housing and travel benefits are separate support. Estimate what you would keep: guaranteed cash, minus rent and deposits, meals, local transportation, travel the program does not cover, fees, and a tax reserve if the stipend is taxable. A taxable stipend, free housing and a reimbursement are not the same thing.';

  // Master statement template pieces (from the directory). The student fills in their own words.
  const STATEMENT_FIELDS = [
    { id: 'noticed', label: 'Where did you notice something? (a course, lab, job or volunteer experience)', hint: 'For example: in a biology lab, while dissecting an earthworm.' },
    { id: 'observation', label: 'What specific thing did you notice?', hint: 'One concrete observation you can picture.' },
    { id: 'question', label: 'What question did it make you curious about?', hint: 'A real question, not a slogan.' },
    { id: 'didwhat', label: 'What did you actually do to explore it?', hint: 'Only what you really did, even if small: looked it up, asked your instructor, repeated a measurement.' },
    { id: 'learned', label: 'What did you learn, or where did you get stuck?', hint: 'Getting stuck counts. It shows how you handle evidence.' },
    { id: 'skill', label: 'What habit or skill would you bring to a lab?', hint: 'For example: careful notes, showing up on time, following a protocol, asking for help early.' },
    { id: 'develop', label: 'What research skill do you hope to develop?', hint: 'For example: sterile technique, pipetting, PCR, microscopy, data analysis.' },
    { id: 'decide', label: 'What will this summer help you decide?', hint: 'An academic, scientific or career question.' },
  ];

  return { CHECKED, YEAR, PROGRAMS, RELATED, LISTS, NOT_FOR_YOU, PREP, VERIFY, AFFORD, STATEMENT_FIELDS };
})();

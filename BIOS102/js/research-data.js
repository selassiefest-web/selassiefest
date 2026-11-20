// BIOS102 Research Match: the faculty database, the interest cards, the
// interview question bank and the opportunity pathways.
//
// SOURCES (all checked Nov 19, 2026 against the official pages; where this
// file says "verified" it means it appears on one of these):
//   Directory:  https://www.uwp.edu/faculty-and-staff/
//   Department: https://www.uwp.edu/departments/biological-sciences/
//   Fellowship: https://www.uwp.edu/departments/biological-sciences/thomson-research-fellowship/
//   Each person's own profile page (the `profile` field below).
// Rule for this file: no invented projects. "Research" text restates the
// person's own profile. "Past student projects" are titles copied from the
// Thomson Fellowship archive. Anything not found on those pages is marked
// `unverified` and the student is told to ask. Update the `checked` date and
// re-read the profile pages before each new semester.
window.RM_DATA = (() => {
  const CHECKED = 'November 19, 2026';

  // ---- Interest dimensions (what a professor's work involves) ------------
  const TAGS = {
    microbes:     'Microbes and bacteria',
    genes:        'Genes and how cells switch them on',
    proteins:     'Proteins and enzymes',
    plants:       'Plants and algae',
    animals:      'Whole animals and their bodies',
    evolution:    'Evolution and how life is related',
    form:         'Anatomy, form and function',
    ecology:      'Ecology and ecosystems',
    conservation: 'Conservation and protecting species',
    aquatic:      'Streams, rivers and freshwater life',
    paleo:        'Fossils and ancient life',
    health:       'Human health and disease',
    computing:    'Data, statistics and coding',
    field:        'Working outdoors in the field',
    wetlab:       'Bench work in a lab',
    animalfac:    'Working with lab animals',
    collections:  'Museum specimens and collections',
  };

  // ---- The faculty -------------------------------------------------------
  // weights: 0-3, how central each tag is to what this person's students do.
  // Derived from the profile text plus the fellowship project titles.
  const FACULTY = [
    {
      id: 'orlofske', name: 'Jessica Orlofske', first: 'Jessica', last: 'Orlofske', honorific: 'Dr.',
      title: 'Associate Professor of Biology; Director, Center for Environmental Studies',
      email: 'orlofske@uwp.edu', phone: '(262) 595-2547',
      profile: 'https://www.uwp.edu/faculty-and-staff/orlofske/', website: 'https://freshwaterbugs.wordpress.com/',
      areas: ['Invertebrate ecology and conservation', 'Aquatic ecology', 'Wildlife parasitology', 'Biostatistics'],
      oneLine: 'Insects, rivers and parasites: how bugs live, what they tell us about water quality, and how to protect rare ones.',
      plain: 'Dr. Orlofske studies invertebrates (insects, spiders and their relatives). Her work has two halves: biodiversity and conservation (including threatened and endangered species), and biomonitoring, which means using the bugs in a stream to judge how healthy that stream is. She works with local, state and federal agencies and conservation groups, and she runs outdoor lab and field experiences in her classes.',
      day: 'Based on past student projects: sampling streams and ponds, identifying insects under a microscope, running experiments on how bugs respond to temperature or chemicals, examining fish for parasites, and analyzing the data with statistics.',
      tags: { aquatic: 3, ecology: 3, conservation: 3, field: 3, health: 1, computing: 2, wetlab: 1, collections: 1, animals: 1 },
      projects: [
        ['Fall 2025 – Spring 2026', 'Evaluating habitat viability targeting water composition for the Hine’s emerald dragonfly (Somatochlora hineana) in southeastern Wisconsin'],
        ['Spring–Summer 2026', 'We’ll all float on: characterizing impacts of the sink/float cycle on entomological evidence in aquatic decomposition'],
        ['Fall 2024 – Spring 2025', 'Parasites of gamefish in the Pike Lake Chain'],
        ['Fall 2024 – Spring 2025', 'Isopods in space'],
        ['Fall 2023 – Spring 2024', 'An assessment of integrity of the WAV citizen monitoring biotic index in Wisconsin (MS)'],
      ],
      mentorship: { level: 'strong', note: 'Listed as a Thomson Fellowship mentor from 2015 through Spring 2026, the most of anyone in the department.' },
      readFirst: 'Her lab blog (freshwaterbugs.wordpress.com) and the 2022 article "Flow velocity-ecology thresholds in Canadian rivers" (Freshwater Biology).',
      animals: false, outdoors: true, summerTravel: false,
      ask: ['Which of your current projects could use a first-year or second-year student right now?', 'How much of the work is outdoors versus identifying and analyzing samples at a bench or computer?'],
    },
    {
      id: 'richards', name: 'Gregory Richards', first: 'Gregory', last: 'Richards', honorific: 'Dr.',
      title: 'Associate Professor of Biological Sciences',
      email: 'richarg0@uwp.edu', phone: '(262) 595-2174',
      profile: 'https://www.uwp.edu/faculty-and-staff/richarg0/', website: '',
      areas: ['Microbiology', 'Molecular biology', 'Microbial genetics', 'Bacterial stress responses'],
      oneLine: 'How E. coli survives starvation, and what that says about the microbes in your gut.',
      plain: 'Dr. Richards studies how bacteria sense and respond to stress. His focus is glucose-phosphate stress in E. coli, a kind of starvation that stops growth. The long-term goal is to understand the conditions and stresses that helpful and harmful microbes face in the human gut. His work was supported by an NIH grant. On his profile he says he loves having students do research in his lab and that 100% of the almost forty students he has mentored went on to medical school, graduate school or a job in their chosen scientific or medical field.',
      day: 'Based on past student projects: growing E. coli, testing how mutants grow on different sugars and nutrients, and measuring how genes respond to stress. Classic microbiology and molecular biology bench work.',
      tags: { microbes: 3, genes: 2, health: 2, proteins: 1, wetlab: 3 },
      projects: [
        ['Fall 2025 – Spring 2026', 'Pathways to survival: characterizing alternative carbon source metabolism in Escherichia coli during glucose-phosphate stress'],
        ['Fall 2024 – Spring 2025', 'The effect of the pentose phosphate pathway and related carbon source metabolism on the growth of E. coli during glucose-phosphate stress (MS)'],
        ['Fall 2023 – Spring 2024', 'Nucleosides function as alternative carbon sources, aiding in the recovery of Escherichia coli under conditions of glucose-phosphate stress (MS)'],
        ['Fall 2022 – Spring 2023', 'Characterizing the effect of nucleoside metabolism on E. coli bacterial stress levels during glucose-phosphate stress'],
      ],
      mentorship: { level: 'strong', note: 'Thomson Fellowship mentor from 2015 through Spring 2026. His profile reports almost forty students mentored in research.' },
      readFirst: 'His Wisconsin Public Television talk "Bacterial Hunger Games" (linked on his profile) and the 2017 paper "Stringent response regulators contribute to the recovery from glucose-phosphate stress in Escherichia coli".',
      animals: false, outdoors: false, summerTravel: false,
      ask: ['What would a new student learn in their first month?', 'Do students usually start by taking BIOS 303 or 411 with you, or can someone start earlier?'],
    },
    {
      id: 'preuss', name: 'Fabian Preuss', first: 'Fabian', last: 'Preuss', honorific: 'Dr.',
      title: 'Associate Professor of Biological Sciences; Director, Animal Care Facility',
      email: 'preussf@uwp.edu', phone: '(262) 595-2124',
      profile: 'https://www.uwp.edu/faculty-and-staff/preussf/', website: '',
      areas: ['Circadian rhythms', 'Intestinal cancer', 'Fiber and prebiotics', 'Microbiota'],
      oneLine: 'Your body clock, your diet and your gut microbes, studied in mice.',
      plain: 'Dr. Preuss studies circadian rhythms (the body’s internal clock) and how they affect physiology, sleep and aging. His current work links the circadian system to how the body responds to diet and disease, with a focus on the gut microbiota. He directs UW–Parkside’s Animal Care Facility, has hosted workshops in animal research and says dozens of independent-study students have done research with him.',
      day: 'Based on past student projects: working with mouse models (including breeding and genetics), tracking diets and body-clock genes, and sampling and analyzing gut microbiomes. This is animal research, so it involves handling mice.',
      tags: { animals: 3, health: 3, microbes: 2, genes: 2, animalfac: 3, wetlab: 2 },
      projects: [
        ['Spring–Summer 2026', 'Breeding colon specific conditional knockout mice to investigate circadian and microbiome signaling in gut homeostasis'],
        ['Fall 2025 – Spring 2026', 'Longitudinal effects of diets on the gut microbiome'],
        ['Fall 2024 – Spring 2025', 'Finding relation between circadian systems and microbiome growth with age'],
        ['Fall 2023 – Spring 2024', 'Looking for links between circadian rhythm disruption and early onset Parkinson’s'],
      ],
      mentorship: { level: 'strong', note: 'Thomson Fellowship mentor from 2016 through 2026. His profile cites an instructional award for providing exceptional student research opportunities.' },
      readFirst: 'The 2025–26 fellowship project titles above, and his profile’s paper on Fibersol-2 and colorectal cancer cells (Cancer Biology & Therapy).',
      animals: true, outdoors: false, summerTravel: false,
      ask: ['What training is required before a student can work with the mice?', 'How many hours a week do animal projects realistically need, including weekends?'],
    },
    {
      id: 'higgs', name: 'David Higgs', first: 'David', last: 'Higgs', honorific: 'Dr.',
      title: 'Professor of Bioscience; contact for the Thomson Research Fellowship',
      email: 'higgs@uwp.edu', phone: '(262) 595-2786',
      profile: 'https://www.uwp.edu/faculty-and-staff/higgs/', website: '',
      areas: ['Molecular biology', 'Genetics', 'Plant physiology', 'Eukaryotic gene expression', 'Photosynthesis'],
      oneLine: 'Green algae, photosynthesis and gene control, including algae that grow well on very little nitrogen.',
      plain: 'Dr. Higgs works with Chlamydomonas, a single-celled green alga, to study how genes are controlled and how cells run photosynthesis. His group studies how algae respond when nitrogen is scarce and how the nucleus and the chloroplast coordinate. One of his published papers describes a mutant alga that tolerates low nitrogen and makes more biomass under nitrogen stress. He is also the listed contact for questions about the Thomson Research Fellowship.',
      day: 'Based on past student projects: growing algae, creating and screening mutants (including with CRISPR-Cas9), and measuring gene expression and lipid production.',
      tags: { genes: 3, plants: 3, wetlab: 3, proteins: 1, computing: 1, health: 0 },
      projects: [
        ['Fall 2024 – Spring 2025', 'Investigating the effects of CRISPR-Cas9 induced mutations and lipid production in Chlamydomonas reinhardtii'],
        ['Fall 2022 – Spring 2023', 'Analysis of gene expression in mutant strain of alga Chlamydomonas reinhardtii under low-nitrogen conditions'],
        ['Fall 2021 – Spring 2022', 'Molecular genetic characterization of a mutant algal strain tolerant to low nitrogen (MS)'],
      ],
      mentorship: { level: 'good', note: 'Thomson Fellowship mentor from 2015 through 2025. He is also the contact person for the Fellowship itself.' },
      readFirst: 'His paper "Characterization of a Chlamydomonas reinhardtii mutant strain with tolerance to low nitrogen and increased growth and biomass under nitrogen stress" (Algal Research).',
      animals: false, outdoors: false, summerTravel: false,
      ask: ['What is the first technique a new student learns?', 'Can you walk me through how the Thomson Fellowship application works?'],
    },
    {
      id: 'lee', name: 'Traci Lee', first: 'Traci', last: 'Lee', honorific: 'Dr.',
      title: 'Associate Professor of Biology',
      email: 'leet@uwp.edu', phone: '(262) 595-2641',
      profile: 'https://www.uwp.edu/faculty-and-staff/leet/', website: 'http://homepages.uwp.edu/leet/',
      areas: ['Regulation of gene expression', 'Transcription factor families', 'The cell cycle'],
      oneLine: 'How a cell decides which genes to use, studied in baker’s yeast.',
      plain: 'Dr. Lee asks a basic question: how does a cell respond appropriately to its environment in terms of the genes it chooses to express? (Her example: your skin cells and liver cells have the same DNA; gene expression is why they differ.) She studies it using the genes that handle sulfur in budding yeast, and the transcription factor complex Met4 that controls them.',
      day: 'Based on past student projects: yeast genetics, building and testing strains, purifying proteins, and measuring gene expression with RT-qPCR and RNA-seq data.',
      tags: { genes: 3, proteins: 2, wetlab: 3, computing: 1, health: 1 },
      projects: [
        ['Fall 2019 – Spring 2020', 'Characterizing the expression of the Met4 transcriptional complex upon swapping the promoters of MET31 and MET32 (MS)'],
        ['Fall 2019 – Spring 2020', 'The role of the promoter in expression and regulation of MET32 in Saccharomyces cerevisiae (MS)'],
        ['Fall 2017 – Spring 2018', 'Re-processing of raw RNA-Seq data and RT-qPCR to measure transcript levels in Met4 target genes (MS)'],
      ],
      mentorship: { level: 'good', note: 'Thomson Fellowship mentor listed 2015–2020. Recent undergraduate projects are not listed on the fellowship page, so ask about current openings.' },
      readFirst: 'Her lab page (homepages.uwp.edu/leet) and the paper "Dissection of combinatorial control by the Met4 transcriptional complex" (Molecular Biology of the Cell).',
      animals: false, outdoors: false, summerTravel: false,
      ask: ['Are you taking undergraduates into the yeast lab this year?', 'Which courses should I have finished first (for example BIOS 260 General Genetics)?'],
    },
    {
      id: 'barber', name: 'Robert Barber', first: 'Robert', last: 'Barber', honorific: 'Dr.',
      title: 'Professor of Biological Sciences',
      email: 'barber@uwp.edu', phone: '(262) 595-2419',
      profile: 'https://www.uwp.edu/faculty-and-staff/barber/', website: 'http://www.uwp.edu/~barber',
      areas: ['Genomics', 'Biochemistry', 'Microbiology', 'Molecular biology', 'Bioinformatics'],
      oneLine: 'How enzymes evolve, using code, protein structure predictions and bench biochemistry.',
      plain: 'Dr. Barber combines genetics, biochemistry and bioinformatics to understand how families of enzymes evolved. Two protein families are the focus: short-chain fatty acid kinases, which may matter for gut bacteria and probiotic therapies, and the PfpI/DJ-1 superfamily, to learn how protein structure evolved. He builds Python tools for biology teaching and has consulted for DuPont.',
      day: 'Based on past student projects: purifying and testing enzymes from gut bacteria, and writing or using bioinformatics software to compare protein sequences.',
      tags: { proteins: 3, computing: 3, evolution: 2, microbes: 2, genes: 2, health: 1, wetlab: 3 },
      projects: [
        ['Fall 2024', 'Characterization of short chain fatty acid kinase in Roseburia intestinalis'],
        ['Fall 2021 – Spring 2022', 'NEV-BLAST computer application to study protein evolution'],
        ['Fall 2020 – Spring 2021', 'Characterizing a proposed butyrate kinase from Bacteroides thetaiotaomicron (MS)'],
      ],
      mentorship: { level: 'good', note: 'Thomson Fellowship mentor from 2016 through Fall 2024.' },
      readFirst: 'His 2021 paper "Writing python programs to map alleles related to genetic disease" (Biochemistry and Molecular Biology Education) is written for students.',
      animals: false, outdoors: false, summerTravel: false,
      ask: ['Do I need programming experience, or do students learn it in the lab?', 'How is the work split between the computer and the bench?'],
    },
    {
      id: 'noto', name: 'Christopher Noto', first: 'Christopher', last: 'Noto', honorific: 'Dr.',
      title: 'Professor and Chair of Biological Sciences',
      email: 'noto@uwp.edu', phone: '(262) 595-2213',
      profile: 'https://www.uwp.edu/faculty-and-staff/noto/', website: 'http://chrisnoto.com',
      areas: ['Paleontology', 'Paleobiology', 'Fossils', 'Dinosaurs', 'Evolution'],
      oneLine: 'Dinosaurs and ancient ecosystems: fieldwork in Texas, Wyoming and Utah and 3D digital anatomy.',
      plain: 'Dr. Noto calls himself a paleoecologist. He studies how climate and local environments shaped vertebrate diversity in the fossil record, and uses anatomy and biomechanics to understand dinosaurs and their communities. He is using geometric morphometrics to study the shape of fossil claws and the soft-tissue anatomy of bird claws, which helps explain how the theropod forelimb evolved toward flight. He also describes fossils from the Arlington Archosaur Site in Texas. He is the department chair and the program contact for both majors.',
      day: 'Based on past student projects: fossil preparation, fieldwork, CT scans and 3D modeling of bones, and measuring shape variation.',
      tags: { paleo: 3, evolution: 3, form: 3, field: 3, computing: 2, collections: 2, ecology: 2, animals: 1 },
      projects: [
        ['Summer–Fall 2023', 'Creating 3D models of Protohadros forelimb mobility via ROM analysis and cartilage reconstruction'],
        ['Fall 2017 – Spring 2018', 'Using turtle shell preservation to understand depositional conditions at the Arlington Archosaur Site in Texas'],
      ],
      mentorship: { level: 'some', note: 'Two Thomson Fellowship projects are listed (2018 and 2023).' },
      readFirst: 'His website (chrisnoto.com) and the Arlington Archosaur Site (arlingtonarchosaursite.com), linked from his profile.',
      animals: false, outdoors: true, summerTravel: true,
      ask: ['When does the field season run, and can a first-time student join, or does the work start in the lab?', 'What does it cost a student to go on a dig, and is travel covered?'],
    },
    {
      id: 'taft', name: 'Natalia Taft', first: 'Natalia', last: 'Taft', honorific: 'Dr.',
      title: 'Associate Professor of Biological Sciences',
      email: 'taft@uwp.edu', phone: '(262) 595-2078',
      profile: 'https://www.uwp.edu/faculty-and-staff/taft/', website: '',
      areas: ['Evolutionary morphology', 'Functional morphology', 'Biomechanics', 'Vertebrate anatomy'],
      oneLine: 'How the fins of fish are built, how they work and what they tell us about the origin of limbs.',
      plain: 'Dr. Taft is a vertebrate evolutionary and functional morphologist. She studies the relationship between structure and function in bony fish fins, in primitive ray-finned fishes and in flatfish, and she is newly interested in the evolution of fish coloration. She co-designed the sophomore-level Research Process in Biology course.',
      day: 'Based on past student projects: dissecting and measuring fish fins, testing how stiff or flexible they are, and comparing species.',
      tags: { form: 3, evolution: 3, animals: 2, wetlab: 2, collections: 2, computing: 1, field: 0 },
      projects: [
        ['Fall 2018 – Spring 2019', 'Comparative analysis of the material properties of the fin rays of the Coho Salmon'],
        ['Summer–Fall 2016', 'Functional morphology of the fin rays of Acipenser fulvescens'],
        ['Fall 2015 – Spring 2016', 'Climbing sucks: do fin rays help?'],
      ],
      mentorship: { level: 'some', note: 'Thomson Fellowship mentor 2015–2019. No more recent fellowship project is listed, so ask whether she has openings now.' },
      readFirst: 'Her 2020 PNAS paper "Fin ray patterns at the fin-to-limb transition".',
      animals: false, outdoors: false, summerTravel: false,
      ask: ['Would Research Process in Biology be the best on-ramp before joining a project?', 'Is the fin work currently active, and what is a small first task?'],
    },
    {
      id: 'rogers', name: 'David Rogers', first: 'David', last: 'Rogers', honorific: 'Dr.',
      title: 'Associate Professor (his profile also lists Department Chair; the department page names Dr. Noto as chair)',
      email: 'rogersd@uwp.edu', phone: '(262) 595-2071',
      profile: 'https://www.uwp.edu/faculty-and-staff/rogersd/', website: '',
      areas: ['Plant identification', 'Ecological surveys', 'Historical ecology'],
      oneLine: 'How Wisconsin’s prairies and forests have changed since the 1950s, and how to restore them.',
      plain: 'Dr. Rogers studies long-term change in natural plant communities and how past and present land uses affect them. He uses historical, landscape and physiological ecology on practical conservation problems, and works with regional land managers so the research feeds restoration and management. He teaches botany, ecology, restoration ecology and conservation biology to prepare students for field-biology careers.',
      day: 'Based on his publications and one past student project: plant identification, surveying plots, comparing modern surveys with historical records, and analyzing community data.',
      tags: { plants: 3, ecology: 3, conservation: 3, field: 3, computing: 2, wetlab: 0 },
      projects: [
        ['Summer–Fall 2015', 'The effects of land-use: comparing vegetative compositions between old growth and secondary growth forest communities'],
      ],
      mentorship: { level: 'few', note: 'One Thomson Fellowship project is listed (2015). Parkside has listed him as a thesis supervisor. Ask about current undergraduate projects.' },
      readFirst: 'His 2016 paper in Science Advances (Alstad et al.), "The pace of plant community change is accelerating in remnant prairies".',
      animals: false, outdoors: true, summerTravel: false,
      ask: ['Are there field seasons or survey projects where an undergraduate can help?', 'Do I need to know plant identification already, or do I learn it on the job?'],
    },
  ];

  // Everyone else on the Biological Sciences directory (not matchable as research mentors,
  // but the student should know who they are and why).
  const OTHERS = [
    { name: 'Albert Harris', role: 'Lecturer', note: 'Teaches BIOS 100, 101, 102, 202 and 303. No research program is listed; he is a good person to ask how to prepare for any of the interviews.', email: 'harria01@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/harria01/' },
    { name: 'Catherine “Cathy” Mossman', role: 'Distinguished Lecturer', note: 'Teaches introductory organismal biology, animal behavior and biostatistics, and has taught at Parkside for over 20 years. She does not have an active research lab on campus, but she is a good person to ask for advice about animal behavior and how to get started.', email: 'mossman@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/mossman/' },
    { name: 'Gregory Mayer', role: 'Professor of Biological Sciences', note: 'Teaches Evolutionary Biology and Vertebrate Zoology. His profile lists no research statement, but he has supervised student projects on sea-snake body form and the Puerto Rican woodpecker. A good person to ask about evolution and animal specimens.', email: 'mayerg@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/mayerg/' },
    { name: 'John Bennett', role: 'Visiting Assistant Professor', note: 'His profile says he has no active research. His most recent project helped a student study dementia-related health-care policy in Milwaukee County. A good conversation if health law or policy interests you.', email: 'bennettj@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/bennettj/' },
    { name: 'Anna Kase', role: 'Adjunct Instructor', note: 'Teaches BIOS 101. No research listed.', email: 'kase@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/kase/' },
    { name: 'Sarah Pergande', role: 'Adjunct Instructor', note: 'Teaches BIOS 300 Human Functional Anatomy. No research listed.', email: 'pergande@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/pergande/' },
    { name: 'Valerie Simpson', role: 'Nursing Consortium', note: 'Teaches BIOS 190 Fundamentals of Human Nutrition. No research listed.', email: 'simpsonv@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/simpsonv/' },
  ];

  // ---- Interest cards (Stage 1) ------------------------------------------
  // Each card is a concrete thing a student might do. The student rates it 1-5.
  // Ratings become a preference vector over TAGS; matching is a transparent dot product.
  const CARDS = [
    { id: 'c_stream', text: 'Wade into a river with a net, collect insects, and identify them under a microscope', tags: { aquatic: 1, ecology: 1, field: 1, conservation: 0.6 } },
    { id: 'c_starve', text: 'Grow bacteria and work out how they survive when their food runs out', tags: { microbes: 1, genes: 0.5, wetlab: 1, health: 0.5 } },
    { id: 'c_algae', text: 'Edit the genes of green algae and see what changes in how they grow', tags: { genes: 1, plants: 1, wetlab: 1 } },
    { id: 'c_mice', text: 'Care for lab mice and track how diet and body clocks change their health', tags: { animals: 1, health: 1, animalfac: 1.2, microbes: 0.4 } },
    { id: 'c_fossil', text: 'Dig for fossils in the field, then build 3D models of dinosaur bones', tags: { paleo: 1, evolution: 0.8, form: 0.8, field: 1, computing: 0.4 } },
    { id: 'c_fins', text: 'Dissect fish and test how their fins bend, to learn how limbs evolved', tags: { form: 1, evolution: 0.8, animals: 0.7, wetlab: 0.5, collections: 0.4 } },
    { id: 'c_code', text: 'Write code that compares protein sequences to figure out how enzymes evolved', tags: { proteins: 1, computing: 1.2, evolution: 0.7 } },
    { id: 'c_prairie', text: 'Survey prairie and forest plots and compare them with records from the 1950s', tags: { plants: 1, ecology: 1, conservation: 0.8, field: 1, computing: 0.5 } },
    { id: 'c_yeast', text: 'Use yeast to discover how a cell decides which genes to switch on', tags: { genes: 1, proteins: 0.7, wetlab: 1 } },
    { id: 'c_museum', text: 'Measure skulls and feathers from museum collections to sort out which species are related', tags: { collections: 1, evolution: 1, form: 0.7, computing: 0.5 } },
    { id: 'c_parasite', text: 'Search fish and insects for parasites and work out how they spread', tags: { ecology: 0.8, health: 0.5, aquatic: 0.6, wetlab: 0.5, field: 0.4 } },
    { id: 'c_stats', text: 'Spend a day turning messy data into graphs and statistics that answer a question', tags: { computing: 1 } },
    { id: 'c_gut', text: 'Study the microbes in the human gut and how they affect health', tags: { microbes: 1, health: 1, wetlab: 0.5 } },
  ];

  // ---- Choices (Stage 1, step 2) -----------------------------------------
  const CHOICES = [
    { id: 'orient', text: 'Which question pulls at you more?', options: [
      { v: 'applied', label: 'A practical one: how can this help people, health, farms or the environment?', tags: { health: 0.8, conservation: 0.5 } },
      { v: 'basic', label: 'A "why does life work this way?" one, even if nobody can use the answer yet', tags: { evolution: 0.5, genes: 0.5, form: 0.5 } },
    ] },
    { id: 'place', text: 'Where would you rather spend most of a research week?', options: [
      { v: 'outside', label: 'Outdoors, in rivers, prairies or on a dig', tags: { field: 1.2 } },
      { v: 'bench', label: 'At a lab bench with pipettes, cultures and microscopes', tags: { wetlab: 1.2 } },
      { v: 'screen', label: 'At a computer, with data, code and images', tags: { computing: 1.2 } },
      { v: 'mix', label: 'A mix, I want to try all of it', tags: {} },
    ] },
    { id: 'scale', text: 'Which scale feels most exciting?', options: [
      { v: 'tiny', label: 'Molecules and cells (genes, proteins, bacteria)', tags: { genes: 0.6, proteins: 0.6, microbes: 0.6 } },
      { v: 'organism', label: 'Whole organisms (bodies, behavior, anatomy)', tags: { animals: 0.6, form: 0.6 } },
      { v: 'big', label: 'Populations, ecosystems and deep time', tags: { ecology: 0.6, conservation: 0.6, paleo: 0.6, evolution: 0.4 } },
    ] },
  ];

  const CONSTRAINTS = {
    animals: { text: 'How do you feel about working with live lab animals such as mice?', options: [['ok', 'Fine with it'], ['maybe', 'I would need to think about it'], ['no', 'I would rather not']] },
    travel: { text: 'Could you do fieldwork that involves a day trip, or a summer trip away from Kenosha?', options: [['yes', 'Yes, travel is fine'], ['local', 'Local day trips only'], ['no', 'No, I need to stay close']] },
    hours: { text: 'How many hours a week could you realistically give a research project on top of classes and work?', options: [['2-3', '2 to 3'], ['4-6', '4 to 6'], ['7+', '7 or more']] },
    goal: { text: 'What are you hoping this leads to?', options: [['health', 'A health profession (medicine, nursing, vet, PA, and so on)'], ['grad', 'Graduate school or a research career'], ['field', 'Fieldwork, conservation or natural resources'], ['industry', 'A job in biotech, labs or industry'], ['unsure', 'I am not sure yet']] },
    stage: { text: 'Where are you in your degree?', options: [['first', 'First year'], ['second', 'Second year'], ['third', 'Third year or later'], ['undecided', 'Not sure of my major yet']] },
  };

  const FREE = [
    { id: 'wonder', text: 'Something about living things that made you stop and ask "how does that work?"', hint: 'A disease, an animal you watched, a plant, your own body, something from a lab this semester. One or two sentences.' },
    { id: 'worth', text: 'What would make a research experience worth your time?', hint: 'Skills, a letter of recommendation, a paper or poster, a stipend, just trying it out. Be honest.' },
    { id: 'worry', text: 'What worries you about asking a professor for this?', hint: 'It helps to name it. We will work on it in the interview stage.' },
  ];

  // ---- Interview question bank (Stage 4) ---------------------------------
  const QUESTIONS = [
    { cat: 'The science', items: [
      'In two minutes, what is the big question your lab is trying to answer?',
      'What got you interested in this question?',
      'What was the most surprising result your lab has had in the last couple of years?',
      'What is one paper of yours I should read first, and what should I look for when I read it?',
      'Where do you think this field will be in five years?',
    ] },
    { cat: 'How the lab works', items: [
      'What does a typical week in your lab look like?',
      'Who works in the lab right now (undergraduates, graduate students, others), and how do you all meet?',
      'Do students work on their own projects or on a piece of a bigger one?',
      'How do you decide what an undergraduate works on?',
      'What techniques or skills would I learn in my first semester?',
    ] },
    { cat: 'What a student actually does', items: [
      'What would my first month look like?',
      'What is something a student in your lab did that you were proud of?',
      'What does a student need to know already, and what can they learn on the job?',
      'Is the work done on campus, in the field, at a computer, or some mix?',
      'Are there specific times of day or weekends when the work has to happen?',
    ] },
    { cat: 'Expectations and logistics', items: [
      'How many hours a week do you expect, and is that flexible around exams?',
      'Is this for credit (independent study), a fellowship, a volunteer position, or paid? What is the usual path?',
      'Are there courses you want me to finish before I start?',
      'When would be the right time to start: this spring, summer or next fall?',
      'What would make a student not work out in your lab?',
    ] },
    { cat: 'Mentorship and outcomes', items: [
      'How do you work with students who are new to research?',
      'Where have your former undergraduate researchers ended up?',
      'Do students present their work (department symposium, Research in the Rotunda, a conference)?',
      'Would you be able to write a letter of recommendation after a semester or two together?',
    ] },
    { cat: 'Closing', items: [
      'Is there anyone else you think I should talk to?',
      'If I am interested, what is the best next step, and by when should I take it?',
      'Is it all right if I follow up with you by email in a week?',
    ] },
  ];

  // ---- Opportunity pathways (verified unless flagged) --------------------
  const OPPORTUNITIES = [
    {
      id: 'thomson', name: 'Thomson Research Fellowship', verified: true,
      what: 'A competitive fellowship for student–faculty research in Biological Sciences. $1,500 research stipend to you, plus $1,000 for supplies through your research advisor. You carry out independent research under a faculty or academic staff member for two semesters (or a summer plus one semester), present at a departmental symposium, and document any other presentations or papers. Awarded in Fall and Spring. More than 60 students have received one since 2015.',
      who: 'Declared majors in the Department of Biological Sciences (undergraduate or graduate). If you have not declared the major yet, you cannot apply yet. Talk to a mentor and the department about timing.',
      next: 'Find a faculty mentor first. Then email Dr. David Higgs (higgs@uwp.edu), the contact on the fellowship page, to ask how the application works and when it is due.',
      url: 'https://www.uwp.edu/departments/biological-sciences/thomson-research-fellowship/',
    },
    {
      id: 'indep', name: 'Independent study with a faculty mentor', verified: true,
      what: 'The department page says it encourages you to schedule an appointment with any of the faculty to discuss "the possibility and/or requirements for conducting independent study research projects." Several faculty list BIOS 499 Independent Study among their courses, and Dr. Preuss says dozens of independent-study students have done research with him.',
      who: 'Requirements are set by the department and the mentor. They are not on the pages checked, so ask during your interview.',
      next: 'Use your interview to ask: is this for credit, how many credits, what prerequisites, and what is the deadline to register?',
      url: 'https://www.uwp.edu/departments/biological-sciences/',
    },
    {
      id: 'mbb', name: 'Molecular Biology & Bioinformatics (MBB) major', verified: true,
      what: 'Built around research. MBB seniors complete a full year of independent research that ends in a written thesis and a public seminar. A 3+2 option lets qualified MBB majors earn a B.S. and an M.S. in Applied Molecular Biology in as little as five years. The department says the majority of MBB graduates go on to graduate or medical school.',
      who: 'Students who declare the MBB major.',
      next: 'If lab research is the draw, ask the department chair (Dr. Noto, noto@uwp.edu, 262-595-2213) how MBB compares with the Biological Sciences major for you.',
      url: 'https://www.uwp.edu/learn/programs/biologicalsciences/',
    },
    {
      id: 'rpb', name: 'Research Process in Biology (sophomore course)', verified: true,
      what: 'Dr. Taft’s profile says she co-designed and team-teaches a sophomore-level Research Process in Biology course. It is a possible on-ramp before joining a lab.',
      who: 'Check the catalog for the number and prerequisites; they were not on the pages checked.',
      next: 'Ask Dr. Taft or your advisor when it is offered and whether it fits your plan.',
      url: 'https://www.uwp.edu/faculty-and-staff/taft/',
    },
    {
      id: 'ritr', name: 'Research in the Rotunda', verified: false,
      what: 'A statewide showcase where undergraduates present research to legislators. It is mentioned in secondary sources about Parkside students (Higgs, Orlofske). This was not confirmed on the official pages checked.',
      who: 'Ask your mentor.',
      next: 'Ask your mentor during your interview whether students in the lab present there.',
      url: '',
    },
    {
      id: 'prehealth', name: 'Pre-Health advising', verified: true,
      what: 'If your goal is a health profession, the department page says you can schedule appointments with a pre-health adviser through the Pre-Health Program Assistant, Lisa Lee, in Greenquist Hall, room 302.',
      who: 'Any student considering a health career.',
      next: 'Book a Pre-Health appointment and ask which research experiences matter most for your target program.',
      url: 'https://www.uwp.edu/departments/biological-sciences/',
    },
  ];

  const DEPT = {
    office: 'D132, or text 312-296-9816',
    chair: { name: 'Dr. Christopher Noto', email: 'noto@uwp.edu', phone: '262-595-2213' },
    instructor: { name: 'Professor Albert Harris', email: 'harria01@uwp.edu' },
    directory: 'https://www.uwp.edu/faculty-and-staff/',
    page: 'https://www.uwp.edu/departments/biological-sciences/',
  };

  // ---- "Spark" cards: what to read and ponder before writing the email -------
  // Every fact below comes from the professor's own profile, a paper abstract
  // (PubMed / Crossref, checked Nov 19, 2026) or the Thomson Fellowship archive.
  // latest = the newest paper on their profile that we could read an abstract for;
  // `said` is the abstract's own wording, trimmed; `plain` is our plain-English version.
  // Posters: the department symposium posters are not posted publicly, so "where the
  // lab is today" uses the most recent supervised student projects instead.
  const SPARK = {
    orlofske: {
      latest: { title: 'Extensive regional variation in the phenology of insects and their response to temperature across North America', venue: 'Ecology', year: 2023, link: 'https://pubmed.ncbi.nlm.nih.gov/36944538/',
        said: 'We found strong regional differences in the phenology of insects and their response to temperature, even within the same taxonomic group, habitat type, and time of season.',
        plain: 'Scientists set insect traps at 96 grassland sites across North America over three summers (2019 to 2021, more than 1,000 samples) to test whether insects everywhere react to temperature the same way. They do not. The same kind of fly can behave differently depending on which part of the continent it lives in, which matters for predicting how climate change will hit insects.' },
      today: 'The newest student projects in her lab (2025 to 2026) are about habitat water chemistry for the Hine’s emerald dragonfly (Somatochlora hineana) in southeastern Wisconsin, and about how the sinking and floating of a body in water changes the insect evidence investigators rely on.',
      facts: [
        { t: 'Did you know a Parkside student studied "Isopods in space"?', use: 'I saw that a student in your lab worked on a project called "Isopods in space," and I would love to know how that started.' },
        { t: 'Did you know her lab is looking at what makes a stream good enough for a rare dragonfly to live in?', use: 'I read that students in your lab are studying the water conditions that the Hine’s emerald dragonfly needs.' },
        { t: 'Did you know insects can act as a river’s health report card?', use: 'I learned that you use the insects in a stream to judge how healthy the stream is, and I want to understand how that works.' },
        { t: 'Did you know one of her latest papers used traps at 96 sites across a whole continent?', use: 'I read your paper on insects at 96 sites across North America and was struck that the same insect group responded to temperature differently in different regions.' },
      ],
      ponder: ['If insects in different regions respond differently to warming, why might one region’s results not predict another’s?', 'What would you measure to decide if a stream is healthy, if you could only look at bugs?', 'Why might a rare dragonfly be so picky about water chemistry?'],
    },
    richards: {
      latest: { title: 'Apex predator nematodes and meso-predator bacteria consume their basal insect prey through discrete stages of chemical transformations', venue: 'mSystems', year: 2022, link: 'https://doi.org/10.1128/msystems.00312-22',
        said: 'Trophic analysis established bacteria as meso-predators and primary insect consumers. Nematodes hold a trophic position of 4.6, indicative of an apex predator, consuming bacteria and likely other nematodes.',
        plain: 'A tiny worm (a nematode) and the bacterium that lives inside it team up to infect and kill an insect, then multiply inside it. The researchers traced who eats what and found the bacteria act like mid-level predators of the insect, while the worm sits at the top of this microscopic food chain.' },
      today: 'The most recent student projects (2025 to 2026) look at how E. coli survives on alternative food sources when it is stuck in glucose-phosphate stress, a kind of starvation. His NIH-supported research asks what stresses helpful and harmful microbes face in the human gut.',
      facts: [
        { t: 'Did you know bacteria can be starved by the very sugar they eat?', use: 'I learned that E. coli can get into trouble from a sugar problem called glucose-phosphate stress, and I want to understand why that happens.' },
        { t: 'Did you know he co-wrote a paper where a worm scores as an "apex predator" at a food-chain level of 4.6?', use: 'I read your paper about a nematode acting as an apex predator in a microscopic food chain, and it changed how I think about food chains.' },
        { t: 'Did you know almost forty students he mentored in research went on to medical school, graduate school or a science job?', use: 'I read on your profile that nearly all of the students you have mentored in research went on to medical school, graduate school or a job in science, and I would like to learn what that experience looks like.' },
        { t: 'Did you know he gave public talks called "Bacterial Hunger Games" and "The Scary Side of Microbes"?', use: 'I watched part of your talk "Bacterial Hunger Games" and it made me curious about how microbes handle starvation.' },
      ],
      ponder: ['What might a gut bacterium do when its favorite food suddenly runs out?', 'Why would knowing how bacteria cope with stress help us understand infections?', 'If you could grow bacteria on different foods, what would you test first?'],
    },
    preuss: {
      latest: { title: 'Fibersol-2 Induces Apoptosis of Apc-deficient Colorectal Cancer (SW480) Cells and Decreases Polyp Formation in Apc-MIN Mice', venue: 'Cancer Biology & Therapy', year: 2016, link: 'https://pubmed.ncbi.nlm.nih.gov/27143108/',
        said: 'Fibersol-2, a digest-resistant maltodextrin, not only inhibits proliferation of colorectal SW480 cancer cell lines by increasing reactive oxygen species (ROS), but decreases the numbers of the adenoma count in [mice prone to intestinal tumors] by 84 d of age.',
        plain: 'A dietary fiber ingredient slowed the growth of colon cancer cells in a dish and reduced the number of early tumors (polyps) in mice that are prone to them. This is the newest paper listed on his profile, so his current work (below) is the better thing to ask about.' },
      today: 'His students’ newest projects (2025 to 2026) include breeding mice with a gene removed only in the colon to study how the body clock and gut microbes talk to each other, and a longitudinal study of how different diets change the gut microbiome.',
      facts: [
        { t: 'Did you know your body has an internal clock that also seems to affect your gut?', use: 'I learned that the body’s clock may be tied to gut health, and I want to understand how a clock gene could affect the gut.' },
        { t: 'Did you know a Parkside student studied possible links between a disrupted body clock and early-onset Parkinson’s?', use: 'I saw that a student in your lab looked for links between circadian rhythm disruption and early-onset Parkinson’s, which I had never thought of as connected.' },
        { t: 'Did you know he directs the campus Animal Care Facility and has hosted workshops on animal research?', use: 'I read that you direct the Animal Care Facility and that many students have done independent research with you, and I would like to understand what that involves.' },
        { t: 'Did you know a fiber ingredient reduced early tumors in mice in one of his papers?', use: 'I read your paper showing a dietary fiber reduced polyps in mice, and I wondered how fiber might protect the gut.' },
      ],
      ponder: ['Why might the time of day you eat matter for your health?', 'How would you test whether gut microbes cause a change, or just go along with it?', 'What would it take for you to be comfortable working with lab mice?'],
    },
    higgs: {
      latest: { title: 'Characterization of a Chlamydomonas reinhardtii mutant strain with tolerance to low nitrogen and increased growth and biomass under nitrogen stress', venue: 'Algal Research', year: 2020, link: 'https://doi.org/10.1016/j.algal.2020.102000',
        said: '',
        plain: 'The title says it: his group found a mutant strain of the green alga Chlamydomonas that keeps growing, and builds more biomass, when nitrogen is scarce. That is useful for understanding how plants and algae cope with low nutrients and for algae-based fuels. (We could not retrieve this paper’s abstract, so read it yourself and use your own words.)' },
      today: 'The newest student project listed (2024 to 2025) uses CRISPR-Cas9 to make mutations in Chlamydomonas and tests how they change lipid (oil) production. Earlier projects analyzed gene expression in the low-nitrogen mutant.',
      facts: [
        { t: 'Did you know he found an alga that grows better than normal when it is short on nitrogen?', use: 'I read that you found an alga mutant that tolerates low nitrogen and even grows more, and I would like to understand how a mutation could do that.' },
        { t: 'Did you know a student in his lab used CRISPR-Cas9 gene editing on algae to study oil production?', use: 'I saw that a student used CRISPR-Cas9 in algae to study lipid production, and I would love to learn how gene editing works in a lab like yours.' },
        { t: 'Did you know one of his papers on algae oil for biofuel was presented at the Wisconsin Space Conference?', use: 'I noticed your biofuel algae work was presented at the Wisconsin Space Conference, and I was curious how algae connect to space research.' },
        { t: 'Did you know he is also the person to ask about the Thomson Research Fellowship?', use: 'I am also interested in learning about the Thomson Research Fellowship, which your department lists you as the contact for.' },
      ],
      ponder: ['Why might an alga that thrives on little nitrogen be useful to farmers or fuel makers?', 'If you edited one gene in an alga, how would you know what changed?', 'How does a cell’s nucleus tell its chloroplast what to do?'],
    },
    lee: {
      latest: { title: 'An Autophagy-Independent Role for ATG41 in Sulfur Metabolism During Zinc Deficiency', venue: 'Genetics', year: 2018, link: 'https://pubmed.ncbi.nlm.nih.gov/29321173/',
        said: 'Atg41 is required for growth in zinc-deficient conditions, but not when zinc is abundant or when other metals are limiting.',
        plain: 'Baker’s yeast needs a particular gene (ATG41) to grow when zinc is scarce. At first the gene looked like it was needed for the cell’s self-recycling process (autophagy), but the experiments suggested it has another job too, so the team is working out what that second job is.' },
      today: 'Her page lists her newest paper as 2018, and her most recent Thomson Fellowship students are from 2019 to 2020 (promoter swaps for the MET31 and MET32 genes in yeast). We could not find what her lab is doing now, so that is a great first question for her.',
      facts: [
        { t: 'Did you know your skin cells and liver cells have the same DNA?', use: 'I liked your example on your profile that skin cells and liver cells have the same DNA and differ because of gene expression.' },
        { t: 'Did you know a gene can have a second, hidden job a cell only needs when a nutrient is missing?', use: 'I read your paper about ATG41 and was surprised that a gene could matter for something other than the job it was named for.' },
        { t: 'Did you know she received an award from Cold Spring Harbor RNA-Seq for the Next Generation program?', use: 'I read that you received the RNA-Seq for the Next Generation award, and I would like to know how undergraduates use RNA-Seq in your lab.' },
        { t: 'Did you know she studies how yeast handles sulfur, a building block of life?', use: 'I learned that you study sulfur metabolism genes in yeast, and I want to understand why sulfur is so important to a cell.' },
      ],
      ponder: ['How does a cell “know” which genes to switch on when it runs out of something?', 'Why would a lab use yeast to learn about human cells?', 'What would count as proof that a gene has a second job?'],
    },
    barber: {
      latest: { title: 'Characterization of a Rhodobacter sphaeroides primary fatty acid kinase', venue: 'Archives of Microbiology', year: 2021, link: 'https://pubmed.ncbi.nlm.nih.gov/33040182/',
        said: 'Biochemical characterization of a predicted acetate kinase from Rhodobacter sphaeroides reveals a novel enzyme with broad substrate specificity for primary fatty acids of varying lengths (C2 to C8).',
        plain: 'An enzyme in a purple bacterium that scientists predicted would only handle acetate (a two-carbon fatty acid) turned out to work on fatty acids of many lengths, from 2 to 8 carbons. That is a surprise, because enzymes like it were thought to be pickier.' },
      today: 'His newest listed student work (Fall 2024) characterizes a short-chain fatty acid kinase from Roseburia intestinalis, a gut bacterium. His lab studies these enzymes for what they might do in gut microbes and for probiotic therapies.',
      facts: [
        { t: 'Did you know he thanks DeepMind’s AlphaFold on his faculty page for changing how his lab studies proteins?', use: 'I read that you use predicted protein structures, such as AlphaFold, in your lab, and I would like to learn how they are used with experiments.' },
        { t: 'Did you know he has written Python tools and a "game" to teach bioinformatics?', use: 'I saw that you wrote a Python-based way to teach genetic-disease alleles and a bioinformatics game, and I would like to learn programming in a biology setting.' },
        { t: 'Did you know one enzyme he studied handles fatty acids of many sizes, not just one?', use: 'I read your paper on the Rhodobacter fatty acid kinase and was surprised an enzyme could work on fatty acids of such different lengths.' },
        { t: 'Did you know his lab studies enzymes from gut bacteria that might one day help in probiotic treatments?', use: 'I learned that the enzymes you study in gut bacteria could matter for probiotic therapies, and I want to understand how.' },
      ],
      ponder: ['How could you tell whether two enzymes are related just by comparing their sequences?', 'What would you test to learn what a gut bacterium’s enzyme does?', 'Do you like the bench, the computer, or the mix? He uses both.'],
    },
    noto: {
      latest: { title: 'Multiproxy synthesis at the Arlington Archosaur Site: New insights into Cretaceous paralic paleoenvironments and regional stratigraphy, Woodbine Group, Texas, USA', venue: 'Sedimentologika', year: 2025, link: 'https://doi.org/10.57035/journals/sdk.2025.e31.1435',
        said: 'Here we describe a new, high-resolution palynological and sedimentologic dataset from the Arlington Archosaur Site (AAS) of the Lewisville Formation (Woodbine Group; Middle Cenomanian).',
        plain: 'The Arlington Archosaur Site in Texas is a rich fossil bed from the middle of the Cretaceous. This paper combines new pollen-and-spore data with rock layers and fossil evidence to rebuild what that ancient coastal environment was like and to pin down when it existed.' },
      today: 'His 2023 fellowship student built 3D models of the forelimb of Protohadros, a duck-billed dinosaur, to test how its arm could move. He is currently using geometric morphometrics on fossil claw shape and studying the soft-tissue anatomy of bird claws to learn about the evolution of flight.',
      facts: [
        { t: 'Did you know he helped prepare fossils of the giant crocodile relative Sarcosuchus as an undergraduate at the University of Chicago?', use: 'I read that you prepared fossils for Paul Sereno as an undergraduate, including Sarcosuchus, and I would love to hear how you got started.' },
        { t: 'Did you know the Arlington Archosaur Site sits between Dallas and Fort Worth and has produced fish, turtles, dinosaurs and a new species of giant crocodilian?', use: 'I learned that the Arlington Archosaur Site in Texas has produced everything from fish to dinosaurs and a new giant crocodilian, and I would like to know how a student can get involved.' },
        { t: 'Did you know a Parkside student made 3D models of a dinosaur forelimb to test how far it could move?', use: 'I saw that a student built 3D models of Protohadros forelimb mobility, and I am curious how you test the range of motion of a fossil.' },
        { t: 'Did you know studying the claws of modern birds helps explain how dinosaurs evolved toward flight?', use: 'I learned that you study bird claws to understand dinosaur claws and the evolution of flight, which I had never thought to connect.' },
      ],
      ponder: ['How can pollen and spores tell you what a place was like 95 million years ago?', 'Would you rather dig in the field, prepare fossils, or build 3D models at a computer?', 'If you could only use one bone to reconstruct an animal, what would you hope for?'],
    },
    taft: {
      latest: { title: 'Fin ray patterns at the fin-to-limb transition', venue: 'Proceedings of the National Academy of Sciences', year: 2020, link: 'https://pubmed.ncbi.nlm.nih.gov/31888998/',
        said: 'In Tiktaalik, dorsal rays fully cover the third and fourth mesomeres, while ventral rays are restricted distal to these elements, suggesting the presence of ventralized musculature at the fin tip analogous to a fleshy "palm."',
        plain: 'Using CT scans of fossil fish fins (including Tiktaalik, a famous fish-to-land transition animal), the team found that the fin’s fine rays changed in a pattern as the fin turned into a limb. In Tiktaalik the pattern hints at a fleshy, palm-like pad at the tip of the fin.' },
      today: 'Her page lists her newest paper as 2020 and her fellowship students from 2015 to 2019 (fin ray stiffness in Coho salmon, sturgeon fins). Her page also mentions new interest in the evolution of fish coloration. Ask her what is active now.',
      facts: [
        { t: 'Did you know the fins of Tiktaalik may have had something like a fleshy "palm"?', use: 'I read your PNAS paper about Tiktaalik’s fin rays suggesting a fleshy palm at the fin tip, and I would love to understand how CT scans reveal that.' },
        { t: 'Did you know a Parkside student asked "Climbing sucks: do fin rays help?"', use: 'I saw a past student project called "Climbing sucks: do fin rays help?" and I am curious how fish fins get used for climbing.' },
        { t: 'Did you know she did her postdoc with Neil Shubin, who helped discover Tiktaalik?', use: 'I saw that you did a postdoc with Neil Shubin, and I would like to hear how that shaped your work on fins and limbs.' },
        { t: 'Did you know she is newly interested in why fish are colored the way they are?', use: 'I read that you are starting to study the evolution of fish coloration, and I wondered what you hope to learn.' },
      ],
      ponder: ['How would you measure how stiff or flexible a fin is?', 'What could a flatfish’s fins tell you that a trout’s cannot?', 'What is the difference between "how a fin works" and "how a fin evolved"?'],
    },
    rogers: {
      latest: { title: 'Sixty years of community change in the prairie-savanna-forest mosaic of Wisconsin', venue: 'Ecology and Evolution', year: 2018, link: 'https://pubmed.ncbi.nlm.nih.gov/30250715/',
        said: 'Savanna community structure and composition changed substantially over the past 60 years. Tree canopy density nearly doubled and many prairie and savanna specialist species were replaced by forest and non-native species.',
        plain: 'The team went back to savanna plots that scientists first surveyed in the 1950s and surveyed them again. In 60 years the tree canopy nearly doubled, and many plants that specialize in open prairie and savanna were replaced by forest and non-native plants.' },
      today: 'His page and papers describe ongoing resurveys of Wisconsin plant communities and work with regional land managers on restoration. His only Thomson Fellowship project is from 2015, so ask what undergraduates can join now.',
      facts: [
        { t: 'Did you know he re-surveyed plants at sites first studied in the 1950s?', use: 'I read that you re-surveyed Wisconsin plant communities first measured in the 1950s, and I would love to know how you find and relocate the old plots.' },
        { t: 'Did you know in remnant prairies the rate of plants arriving and disappearing sped up by over 100% between survey periods?', use: 'I read your Science Advances paper showing the pace of change in remnant prairies is accelerating, and I wondered what is driving it.' },
        { t: 'Did you know tree canopy in the savannas he studied nearly doubled in 60 years?', use: 'I learned from your savanna paper that tree canopy nearly doubled in 60 years, and I am curious what that means for the plants that live there.' },
        { t: 'Did you know he spent years doing botany and forestry fieldwork around the country before graduate school?', use: 'I read that you did botany and forestry fieldwork around the U.S. before graduate school, and I would like to hear how you got into plant ecology.' },
      ],
      ponder: ['What could old survey notebooks tell you that a new survey cannot?', 'Is a prairie that is slowly turning into forest a problem? For whom?', 'Could you identify plants well enough to survey a plot, or would you want to learn?'],
    },
  };
  FACULTY.forEach((f) => { f.spark = SPARK[f.id] || null; });

  // Research-area color groups (one color per area, used for scanning cards only).
  const AREAS = {
    eco:  'Ecology and field work',
    mol:  'Molecules, genes and microbes',
    body: 'Animals and health',
    evo:  'Fossils, evolution and form',
  };
  const AREA_OF = { orlofske: 'eco', rogers: 'eco', richards: 'mol', lee: 'mol', higgs: 'mol', barber: 'mol', preuss: 'body', noto: 'evo', taft: 'evo' };
  FACULTY.forEach((f) => { f.area = AREA_OF[f.id] || 'mol'; });


  // ---- Nervous? Content (interview-day script and honest reassurance) -------
  const CALM = {
    opening: 'Hi Dr. [Last name], thank you for making time. I am [name], a [year] student at Parkside. I read [one thing from their page or paper] and it made me curious. I am trying to find out what research is really like, so I have a few questions.',
    blank: 'If your mind goes blank, say this: "Can I look at my notes for a second?" Then read the next question off your list. Nobody minds. Professors like students who come prepared.',
    close: 'Before you leave say: "Thank you. What is the best next step for me?" Then write down exactly what they say and send your thank-you note the same day.',
    grades: 'If your grades are not where you want them: the department pages I checked do not list a GPA minimum for independent study, and the Thomson Fellowship page only says you must be a declared Biological Sciences major. Requirements can differ by professor, so ask. You can say: "I have not done as well as I would like in some classes, and I am working on it. I want to show what I can do in a lab. What would you need to see from me?" Professors mostly care that you show up, follow through and are curious.',
    nerves: [
      'Being nervous means you care. It does not mean you will do badly.',
      'You only need to do one small step at a time. Today\u2019s step can take 10 minutes.',
      'A friend sitting next to you while you work (even quietly) makes starting easier.',
      'You are asking for 20 minutes, not a job. A "no" or silence is about their schedule.',
      'Set a phone alarm for 10 minutes. When it rings you are allowed to stop.',
    ],
  };
  return { CHECKED, TAGS, FACULTY, OTHERS, CARDS, CHOICES, CONSTRAINTS, FREE, QUESTIONS, OPPORTUNITIES, DEPT, CALM, AREAS };
})();

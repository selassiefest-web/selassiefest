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
      readFirst: 'His 2019 paper in Science Advances, "The pace of plant community change is accelerating in remnant prairies".',
      animals: false, outdoors: true, summerTravel: false,
      ask: ['Are there field seasons or survey projects where an undergraduate can help?', 'Do I need to know plant identification already, or do I learn it on the job?'],
    },
    {
      id: 'mayer', name: 'Gregory Mayer', first: 'Gregory', last: 'Mayer', honorific: 'Dr.',
      title: 'Professor of Biological Sciences',
      email: 'mayerg@uwp.edu', phone: '(262) 595-2074',
      profile: 'https://www.uwp.edu/faculty-and-staff/mayerg/', website: 'http://homepages.uwp.edu/mayerg/cvgcm.pdf',
      areas: ['Evolutionary biology and vertebrate zoology (from the courses he teaches: BIOS 314, 318)'],
      oneLine: 'Evolution and vertebrate diversity, measured on real specimens (sea snakes, woodpeckers).',
      plain: 'His profile page lists courses (Evolutionary Biology, Vertebrate Zoology, Independent Study, Thesis) but no research statement, so what we know comes from the fellowship archive and his CV (linked above). The projects he has mentored measure and compare animal specimens: the quantitative genetics of sea-snake body form, and the morphometrics, systematics and distribution of the Puerto Rican woodpecker.',
      day: 'Based on two past projects: measuring specimens, statistics on shape, and working out how species are related and where they live.',
      tags: { evolution: 3, form: 2, collections: 3, animals: 2, computing: 2, field: 0 },
      projects: [
        ['Spring–Summer 2024', 'Morphometrics, systematics and distribution of the Puerto Rican woodpecker (Melanerpes portoricensis) (MS)'],
        ['Fall 2021 – Spring 2022', 'Quantitative genetics of morphological characteristics of sea snakes'],
      ],
      mentorship: { level: 'some', note: 'Two Thomson Fellowship projects are listed (2022 and 2024). He teaches Independent Study (BIOS 499) and Thesis (BIOS 711). His own profile has no research statement, so read his CV first.' },
      readFirst: 'His CV, linked above.',
      animals: false, outdoors: false, summerTravel: false,
      unverifiedNote: 'Research focus is inferred from past student projects and course list; confirm in your interview.',
      ask: ['What are you working on right now, and is there a piece a student could take?', 'Is the work done on museum specimens, in the field or on a computer?'],
    },
  ];

  // Everyone else on the Biological Sciences directory (not matchable as research mentors,
  // but the student should know who they are and why).
  const OTHERS = [
    { name: 'Albert Harris', role: 'Lecturer', note: 'Your BIOS102 instructor. Teaches BIOS 100, 101, 102, 202 and 303. No research program is listed; he is a good person to ask how to prepare for any of the interviews.', email: 'harria01@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/harria01/' },
    { name: 'Catherine “Cathy” Mossman', role: 'Distinguished Lecturer', note: 'Teaches introductory organismal biology, animal behavior and biostatistics, and has taught at Parkside for over 20 years. She does not have an active research lab on campus, but she is a good person to ask for advice about animal behavior and how to get started.', email: 'mossman@uwp.edu', profile: 'https://www.uwp.edu/faculty-and-staff/mossman/' },
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
      what: 'A statewide showcase where undergraduates present research to legislators. It is mentioned in secondary sources about Parkside students (Higgs, Orlofske, Mayer). This was not confirmed on the official pages checked.',
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
    office: 'Greenquist Hall L321',
    chair: { name: 'Dr. Christopher Noto', email: 'noto@uwp.edu', phone: '262-595-2213' },
    instructor: { name: 'Professor Albert Harris', email: 'harria01@uwp.edu' },
    directory: 'https://www.uwp.edu/faculty-and-staff/',
    page: 'https://www.uwp.edu/departments/biological-sciences/',
  };

  return { CHECKED, TAGS, FACULTY, OTHERS, CARDS, CHOICES, CONSTRAINTS, FREE, QUESTIONS, OPPORTUNITIES, DEPT };
})();

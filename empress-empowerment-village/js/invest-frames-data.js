// Content spec: transcribed verbatim from EEV_Pitch_Deck_Trimmed.md / slides.json
// (trimmed-v7-image-fixes), the reviewed 14-slide Empress Empowerment Village
// investor deck. Narration lines are the approved script, split into short
// utterances for speech pacing -- wording is not paraphrased. On-screen bullets
// are the deck's own on_screen_text lines. Slide 7's bio for Paul Kelly is
// published as approved by Paul.
//
// Images: all 14 frames now have a real photo, content-matched against each
// slide's approved image_prompt rather than trusted by filename order --
// several delivered files drifted from their own slide's prompt during
// generation. Frame 7 needed a second generation pass (the first violated
// the deck's own "no vintage/sepia" fix note); frames 11-13 came from a
// separate later batch. No frame relies on the CSS gradient fallback anymore.

const BATCH_LABELS = {
  why: 'The Opportunity',
  how: 'The Model',
  experience: 'The Experience',
  org: 'Who We Are',
  invest: 'The Investment',
  impact: 'The Impact',
  close: 'The Ask'
};

const FRAMES = [
  {
    id: 1,
    batch: 'why',
    personalize: 'start',
    image: 'assets/images/frame-01.jpg',
    visual: "A girl at the edge of a festival crowd watches a group of professional women pass by, an unmistakable look of ‘I could be that.’",
    headline: 'THE EMPRESS EMPOWERMENT VILLAGE',
    bullets: [
      'See It. Learn It. Become It.',
      'Selassie Fest 2027 · July 24 · Seven Hills, Washington Park, Chicago, IL',
      'Presented by Ras Tafari Inc., a 501(c)(3) nonprofit'
    ],
    voice: [
      "Good morning, and thank you for the chance to share something we believe can change the trajectory of a girl's life in a single day.",
      "This is the Empress Empowerment Village, a signature experience inside Selassie Fest, happening July 24th, 2027, at Seven Hills in Washington Park, Chicago.",
      "It's built and presented by Ras Tafari Incorporated, a 501c3 nonprofit.",
      "Our theme is simple: see it, learn it, become it.",
      "By the end of this, I think you'll understand exactly why that matters."
    ],
    tellMore: null
  },
  {
    id: 2,
    batch: 'why',
    image: 'assets/images/frame-02.jpg',
    visual: 'A girl alone with a laptop, searching for an answer the screen doesn’t have.',
    headline: 'THE OPPORTUNITY GAP',
    bullets: [
      "Women earn 38% of STEM bachelor's degrees — but hold just 34% of STEM jobs¹",
      'More than 1 in 3 young people grow up without a mentor²',
      '“You can’t be what you can’t see.”'
    ],
    voice: [
      "Here's the problem we're solving.",
      "Nationally, women earn 38 percent of STEM bachelor's degrees, but they hold only 34 percent of STEM jobs.",
      "That gap doesn't close on its own. It closes when someone shows a girl the path and helps her walk it.",
      "And that kind of guidance is rare: more than one in three young people grow up without a mentor of any kind.",
      "The gap isn't talent. It's exposure.",
      "As the saying goes, you can't be what you can't see.",
      "That is the gap the Empress Empowerment Village exists to close."
    ],
    tellMore: [
      "Sources — women earning 38.2% of STEM bachelor's degrees (2020–21): U.S. Dept. of Education, National Center for Education Statistics, Digest of Education Statistics, Table 318.45. Women holding roughly 34% of STEM jobs (2019): Pew Research Center analysis of National Science Board, ‘The State of U.S. Science and Engineering 2021.’",
      "‘More than 1 in 3 young people grow up without a mentor’: MENTOR — The National Mentoring Partnership (mentoring.org). This is a general-youth statistic, not girl-specific.",
      "The line ‘You can't be what you can't see’ is widely attributed to Marian Wright Edelman, founder of the Children's Defense Fund. The attribution is commonly used but has not been independently verified against a primary source."
    ]
  },
  {
    id: 3,
    batch: 'how',
    image: 'assets/images/frame-03.jpg',
    visual: 'A festival pathway lined with booths — women and girls in conversation, not shopping, not eating: connecting.',
    headline: 'AN EDUCATION-TO-OPPORTUNITY ECOSYSTEM',
    bullets: [
      'Not a marketplace. Not a food court. A career launchpad.',
      'Meet professionals. Learn the path. Leave with a plan.'
    ],
    voice: [
      "Our solution is the Empress Empowerment Village, a one-day immersive career-discovery experience built specifically for girls and women.",
      "It is not a vendor marketplace, and it's not a food court. It's a career launchpad.",
      "In a single afternoon, a girl can meet an accomplished professional woman face to face, learn the exact pathway into that career, connect with a mentor or a scholarship opportunity, and walk out with a personalized roadmap for her own future.",
      "That's the promise behind our theme: see it, learn it, become it."
    ],
    tellMore: null
  },
  {
    id: 4,
    batch: 'how',
    image: 'assets/images/frame-04.jpg',
    visual: 'A young woman gazing out toward the Chicago skyline at golden hour, the festival gathered behind her.',
    headline: 'FROM ONE DAY TO A NATIONAL MODEL',
    bullets: [
      'Year 1 (2027) — Launch: 500+ girls, 40+ careers represented',
      'Year 2 (2028) — Expand: 60+ careers, year-round mentorship begins',
      'Year 3 (2029) — Scale: a national model for festival-based workforce development'
    ],
    voice: [
      "We're not asking you to imagine a finished national program on day one. We're asking you to help us build toward one, deliberately.",
      "In year one, 2027, we launch at Selassie Fest with over 500 girls and more than 40 careers represented.",
      "In year two, we expand: more career fields, and we launch year-round mentorship so the relationships don't end when the festival does.",
      "By year three, we're positioning the Village as a national model for how a single community event can become a real workforce development pipeline.",
      "This is a three-year build, not a one-time event."
    ],
    tellMore: null
  },
  {
    id: 5,
    batch: 'experience',
    image: 'assets/images/frame-05.jpg',
    visual: 'A girl’s hands holding an open passport booklet stamped gold.',
    headline: 'EVERY GIRL LEAVES WITH A ROADMAP',
    bullets: [
      'The Empress Passport — stamped at every stop',
      'Marketplace → Leadership Corner → Nonprofit Pavilion → Empress Stage → “I Will Become…” Wall',
      'Completion = Certificate + Mentor Connection + Scholarship Access'
    ],
    voice: [
      "Every participant receives an Empress Passport the moment she walks in, and that passport is the difference between a girl who wanders the festival and a girl who leaves with a plan.",
      "She visits the Marketplace of Possibilities to meet career professionals, stops at the Girls Leadership Corner to build something of her own, connects with real resources at the Women's Nonprofit Pavilion, sits in on a session at the Empress Stage, and finishes at our Success Wall, where she writes down exactly who she's going to become.",
      "Complete the passport, and she walks away with a certificate, a mentor connection, and access to scholarships.",
      "This turns a day of inspiration into a day of action."
    ],
    tellMore: null
  },
  {
    id: 6,
    batch: 'experience',
    image: 'assets/images/frame-06.jpg',
    visual: 'Four zones across one lawn — bamboo-and-fabric booths in gold and emerald green.',
    headline: 'THE FOUR ZONES',
    bullets: [
      'Marketplace of Possibilities — Meet 40+ professionals across every industry',
      'Girls Leadership Corner — Pitch a business, build a prototype, lead a panel',
      "Women's Nonprofit Pavilion — Direct connections to mentorship, scholarships, legal & financial help",
      'Empress Stage — Themed talks and panels all day, closing with a keynote'
    ],
    voice: [
      "The Village is organized into four zones, each doing something specific.",
      "The Marketplace of Possibilities is where she meets more than 40 professionals: surgeons, engineers, judges, entrepreneurs, each one answering the same five questions about how they got there.",
      "The Girls Leadership Corner is where girls stop watching and start doing: pitching businesses, building prototypes, leading their own panels.",
      "The Women's Nonprofit Pavilion connects her directly to real resources: mentorship, scholarships, legal aid, financial literacy, no brochures, just action.",
      "And the Empress Stage runs themed programming throughout the day, closing with a keynote that sends everyone home inspired and informed."
    ],
    tellMore: null
  },
  {
    id: 7,
    batch: 'org',
    image: 'assets/images/frame-07.jpg',
    visual: 'An elder and a young girl standing side by side, looking out together toward the festival ahead.',
    headline: 'WHO WE ARE',
    bullets: [
      'Selassie Fest — a Chicago tradition since 1981',
      'A 30-year hiatus. Revived in 2026.',
      'Now formally stewarded by Ras Tafari Inc., a registered 501(c)(3) nonprofit',
      "Stephen Henry, President — Owner, Prestige Sound (Chicago's largest dancehall dubplate catalog)",
      'Albert Harris, Secretary — Biologist, event planning & execution',
      'Paul Kelly, VP/Treasurer — Founder of S.I.P. (Self-Improvement Philosophy); built on 13 years of transforming his own mind'
    ],
    voice: [
      "Before we ask you to invest, you should know the story behind this.",
      "Selassie Fest has been a Chicago tradition since 1981, a celebration of Rastafari and Caribbean culture that ran for fifteen years before going on a thirty-year hiatus.",
      "In 2026, it came back. Selassie Fest returned to Chicago, and this time it's being formally stewarded by Ras Tafari Incorporated, a registered 501c3 nonprofit built to carry this legacy forward with real structure and accountability.",
      "Our board brings the city with it: President Stephen Henry owns Prestige Sound, an original dancehall sound system with the largest catalog of dancehall dubplates in Chicago.",
      "Secretary Albert Harris is a biologist with deep expertise in event planning and execution.",
      "And Vice President and Treasurer Paul Kelly was born in Kingston, Jamaica and raised in Brooklyn.",
      "He spent thirteen years in federal prison, and he used that time to rebuild his own mind, emerging with a philosophy he calls S.I.P., Self-Improvement Philosophy.",
      "He brings that same discipline to building this organization.",
      "The Empress Empowerment Village is the newest cornerstone of that legacy, and 2027 is its debut."
    ],
    tellMore: null
  },
  {
    id: 8,
    batch: 'invest',
    image: 'assets/images/frame-08.jpg',
    visual: 'Many hands, bangles and beads, stacking together in the center of the frame.',
    headline: 'HOW YOU CAN BUILD THE VILLAGE',
    bullets: [
      'Invest Financially — fund the experience',
      'Invest Your Time — bring your expertise',
      'Invest Opportunity — open a door',
      'This is investment, not sponsorship — impact, not just exposure'
    ],
    voice: [
      "There are three ways to build this with us, and none of them require you to write the biggest check in the room.",
      "You can invest financially: fund the stations, the programming, the scholarships.",
      "You can invest your time: bring your own expertise and spend a few hours, or a full day, as a mentor or a guide.",
      "Or you can invest opportunity: open a door with an internship, a scholarship, or a hiring pathway.",
      "We call this investment, not sponsorship, because we're not asking for a logo placement. We're asking for a role in transforming a life."
    ],
    tellMore: null
  },
  {
    id: 9,
    batch: 'invest',
    ask: true,
    image: 'assets/images/frame-09.jpg',
    visual: 'A coin passing hand to hand through an open doorway, the festival glowing beyond.',
    headline: 'INVEST FINANCIALLY',
    bullets: [
      'Our Selassie Fest 2027 Goal: $250,000',
      'Raised through Zeffy · GoFundMe · Silent Auction · Direct & Corporate Partnerships',
      "$25 → One girl's Career Passport · $250 → Bring one mentor to the floor · $1,000+ → Expand Village programming",
      'Corporate & Foundation levels: $1,000 to $25,000 (Presenting Partner)',
      'Village allocation: Infrastructure 30% · Programming 25% · Scholarships 20% · Marketing 15% · Operations 10%'
    ],
    voice: [
      "To fund Selassie Fest 2027, including the Empress Empowerment Village, we're raising two hundred fifty thousand dollars through a mix of channels: our Zeffy campaign, GoFundMe, a silent auction, and direct and corporate partnerships.",
      "Every gift has a clear job. Twenty-five dollars puts a Career Passport in one girl's hands.",
      "Two hundred fifty dollars brings a professional woman onto the floor to share her journey.",
      "A thousand dollars or more helps us expand mentorship and programming citywide.",
      "For corporations and foundations, our levels run from one thousand dollars up to twenty-five thousand dollars as our Presenting Partner.",
      "Within that goal, the Village's own budget breaks down clearly: thirty percent into infrastructure and materials, twenty-five percent into programming, twenty percent directly into scholarships, and the rest into outreach and operations.",
      "This isn't a black box. It's a budget you can hold us to."
    ],
    tellMore: [
      "The $250,000 goal funds Selassie Fest 2027 as a whole; the allocation above is the Empress Empowerment Village's own share within that total. A full festival-wide budget breakdown beyond the Village's allocation is still being finalized.",
      "Zeffy and GoFundMe links launch closer to the event. In the meantime, reach out directly."
    ],
    detailTables: [
      {
        title: 'Individual & Family Giving',
        headers: ['Investment', 'What It Funds'],
        rows: [
          ['$25', "Career Passport and educational materials for one girl"],
          ['$50', 'Mentor station support and supplies'],
          ['$100', 'Leadership workshop support'],
          ['$250', 'Bring one professional woman to share her career journey'],
          ['$500', 'Career exploration experiences for multiple participants'],
          ['$1,000+', 'Expand mentorship and educational programming'],
          ['Custom', 'Build lasting opportunities for future leaders']
        ]
      },
      {
        title: 'Foundation & Corporate Levels',
        headers: ['Level', 'Focus Area'],
        rows: [
          ['$25,000', 'Presenting Partner of the Empress Empowerment Village'],
          ['$15,000', 'Girls Leadership Corner'],
          ['$10,000', 'Career Marketplace'],
          ['$7,500', "Women's Nonprofit Pavilion"],
          ['$5,000', 'Empress Stage Educational Series'],
          ['$2,500', 'Career Passport Program'],
          ['$1,000', 'Sponsor a Professional Mentor Booth'],
          ['$500', "Sponsor One Girl's Leadership Experience"]
        ]
      }
    ]
  },
  {
    id: 10,
    batch: 'invest',
    image: 'assets/images/frame-10.jpg',
    visual: 'A mentor and a girl, heads bent together over a hand-built model, deep in conversation.',
    headline: 'INVEST YOUR TIME',
    bullets: [
      'Career Guide · Mentor · Panelist · Workshop Leader',
      'Commitments range from 2 hours to a full day',
      '“A four-hour conversation could produce the next generation of doctors.”'
    ],
    voice: [
      "If you don't have a check to write, you have something just as valuable: your time and your story.",
      "We need Career Guides to staff a station and share their journey, Mentors for one-on-one conversations, Panelists for two-hour discussions, and Workshop Leaders to run hands-on sessions.",
      "Commitments range from two hours to a full day.",
      "Think about this: a physician who spends four hours explaining the path to medical school could be talking to the next generation of doctors.",
      "That's the kind of return on time we're talking about."
    ],
    tellMore: null,
    detailTables: [
      {
        title: 'Volunteer Roles',
        headers: ['Role', 'Description', 'Time'],
        rows: [
          ['Career Guide', 'Staff a Marketplace of Possibilities booth; share your career journey', 'Full day'],
          ['Mentor', 'One-on-one conversations with participants; post-festival follow-up', 'Full day'],
          ['Panelist', 'Participate in an Empress Stage panel discussion', '2 hours'],
          ['Workshop Leader', 'Facilitate Girls Leadership Corner activities', '2–4 hours'],
          ['Passport Coach', 'Guide participants through passport activities', 'Full day'],
          ['Leadership Coach', 'Mentor youth entrepreneurs and pitch competition participants', '2–4 hours']
        ]
      }
    ]
  },
  {
    id: 11,
    batch: 'invest',
    image: 'assets/images/frame-11.jpg',
    visual: 'An open tent doorway, backlit — a girl’s silhouette stepping through toward the light.',
    headline: 'INVEST OPPORTUNITY',
    bullets: [
      'Internships · Apprenticeships · Scholarships · Job Shadowing · Hiring Pathways',
      "“Instead of writing a check, you're building a pipeline.”"
    ],
    voice: [
      "The third way to invest doesn't cost a dollar, and it might be the most valuable of all.",
      "If your company or institution can offer an internship, an apprenticeship, a scholarship, a job-shadow day, or a direct hiring pathway, you're not writing a check. You're opening a door that stays open long after the festival ends.",
      "That's a pipeline, not a donation, and its impact compounds every year."
    ],
    tellMore: null,
    detailTables: [
      {
        title: 'Opportunity Types',
        headers: ['Type', 'Examples'],
        rows: [
          ['Internships', 'Summer internships, semester internships'],
          ['Apprenticeships', 'Trade apprenticeships, tech apprenticeships'],
          ['Scholarships', 'College scholarships, trade school scholarships'],
          ['Job Shadowing', 'Shadow a physician, attorney, engineer'],
          ['College Tours', 'University admissions events, campus tours'],
          ['Research Opportunities', 'STEM research, social science research'],
          ['Leadership Fellowships', 'Civic leadership, nonprofit leadership'],
          ['Business Incubation', 'Mentorship, space, resources for young entrepreneurs'],
          ['Hiring Pathways', 'Paid work experiences, entry-level positions']
        ]
      }
    ]
  },
  {
    id: 12,
    batch: 'impact',
    image: 'assets/images/frame-12.jpg',
    visual: 'A hand resting on a passport booklet, its pages visibly stamped.',
    headline: "WE DON'T JUST INSPIRE. WE MEASURE.",
    bullets: [
      '500+ girls served · 60+ mentors · 40+ careers represented',
      '100+ mentorship registrations · 50+ internship/job-shadow leads · 10+ scholarships',
      'Tracked again at 6 and 12 months'
    ],
    voice: [
      "We don't just want you to feel good about this. We want you to see the numbers.",
      "In year one, we're targeting more than 500 girls served, over 60 professional mentors, and more than 40 career fields represented.",
      "We're tracking at least 100 mentorship registrations, 50 internship or job-shadow leads, and 10 scholarships awarded or referred.",
      "And we don't stop counting on festival day. We follow up at six months, and again at twelve months, to track real career and educational advancement.",
      "This is data-driven impact, not just a feel-good afternoon."
    ],
    tellMore: null
  },
  {
    id: 13,
    batch: 'impact',
    image: 'assets/images/frame-13.jpg',
    visual: 'A footpath winding from a shaded entrance toward an open, sunlit field.',
    headline: 'HOW WE CREATE LASTING CHANGE',
    bullets: [
      'Inputs → Activities → Outputs → Outcomes → Impact',
      'Funded & staffed → Stations & workshops → Girls engaged & passports completed → Mentor connections & registrations → Career advancement, tracked long-term'
    ],
    voice: [
      "Here's the logic behind everything we've shown you.",
      "We take your investment, along with our partners and volunteers: that's our input. That funds career stations, workshops, and panels: our activities.",
      "Those activities produce real outputs: hundreds of girls engaged, hundreds of completed passports.",
      "Those outputs lead to outcomes: mentor connections, program registrations, internship leads.",
      "And over time, those outcomes become impact: real career and educational advancement that we track for a full year after the festival ends.",
      "This is how a single day builds into lasting change."
    ],
    tellMore: null
  },
  {
    id: 14,
    batch: 'close',
    cta: true,
    image: 'assets/images/frame-14.jpg',
    visual: 'A group of women embracing warmly at golden hour, festival lights glowing behind them.',
    headline: 'JOIN US. BUILD THE FUTURE.',
    bullets: [
      'The Empress Empowerment Village · July 24, 2027 · Seven Hills, Washington Park, Chicago',
      'Become a Founding Partner today',
      '“Together, we are creating a place where every girl can see what’s possible — and begin the journey to become it.”'
    ],
    voice: [
      "We invite you to become a founding partner of the Empress Empowerment Village at Selassie Fest.",
      "Your investment, whether it's financial, your time, or an opportunity you can open, helps transform a single day of inspiration into a real pathway: mentors, scholarships, education, and leadership experiences that shape a girl's future for years to come.",
      "Together, we are creating a place where every girl can see what's possible, and begin the journey to become it.",
      "Thank you."
    ],
    tellMore: null
  }
];

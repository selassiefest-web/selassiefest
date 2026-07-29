// Content spec: transcribed from Draft_Proposal_Selassie_Fest.docx (Ras Tafari Inc.'s
// Vision Proposal for restoring Selassie Fest), in the same 27-frame flip-book format
// as /the-yawd. {{name}} is replaced at render time with the viewer's name/org
// (frames 1 and 26 only). No partner logo images exist for this project yet — frame 2
// uses a text wordmark instead (see the `wordmark` field).

const FRAMES = [
  {
    id: 1,
    batch: 'hook',
    personalize: 'start',
    visual: "Archival-toned photo of a packed festival field at Seven Hills in Washington Park, 1990s film grain, dissolving into the same hillside today — quiet, empty, waiting.",
    headline: 'From 1981 to 1997, Selassie Fest was one of the largest three-day festivals on Chicago’s South Side. Then, for thirty years, it stopped.',
    voice: [
      'Prepared for {{name}}.',
      'For sixteen years, thousands of people gathered at Washington Park’s Historic Seven Hills to celebrate Caribbean and African Diaspora culture.',
      'In 1997, the festival held its final gathering — but the legacy never actually left.'
    ],
    tellMore: "For nearly two decades, Selassie Fest was more than an annual gathering. It was a place where families reunited, elders shared history with younger generations, musicians and artists found audiences, entrepreneurs introduced their businesses, and educators inspired learning — a place where culture wasn't simply displayed, it was lived. Although the festival concluded in 1997, its legacy has endured through the memories of those who attended and the generations who continue to recognize its importance in Chicago's cultural history."
  },
  {
    id: 2,
    batch: 'hook',
    wordmark: { line1: 'SELASSIE', line2: 'FEST', sub: 'Preserving the Past. Inspiring the Future.' },
    visual: 'Full-bleed reveal of the Selassie Fest wordmark in gold and white over a dark, minimal background.',
    headline: 'Ras Tafari Inc. presents a vision to restore that legacy.',
    voice: ['Ras Tafari Inc. presents a vision to restore that legacy.'],
    tellMore: 'Not simply by recreating what once existed, but by building on its historic foundation to meet the opportunities of the twenty-first century. Ras Tafari Inc. is a 501(c)(3) cultural curator and community creator dedicated to preserving, celebrating, and advancing Caribbean and African Diaspora culture through education, arts, music, entrepreneurship, wellness, and community engagement.'
  },
  {
    id: 3,
    batch: 'hook',
    visual: 'Split frame — a black-and-white archival crowd shot from the original festival beside a full-color rendering of a modern Washington Park gathering.',
    headline: 'Not a rerun. A living, year-round institution — with an unforgettable festival at its center.',
    voice: [
      'This isn’t about recreating exactly what once existed.',
      'It’s a year-round cultural institution — education, the arts, entrepreneurship, wellness, youth engagement — that happens to throw one of the biggest parties in Chicago.'
    ],
    tellMore: 'We envision Selassie Fest as a year-round cultural institution that strengthens communities through education, the arts, entrepreneurship, wellness, youth engagement, cultural preservation, and civic partnership — one that honors its history while embracing innovation, creating opportunities that extend beyond the festival grounds and throughout the City of Chicago.'
  },
  {
    id: 4,
    batch: 'legacy',
    visual: 'Archival-mood photo collage — a crowded festival field, vendor tents, a stage, family portraits, warm film-grain color.',
    headline: 'Where families reunited, elders taught history, and culture wasn’t performed — it was lived.',
    voice: [
      'Musicians and artists found audiences here. Entrepreneurs found their first customers.',
      'It became a place where culture wasn’t something on display — it was something you lived, for three days, every year.'
    ],
    tellMore: 'From 1981 through 1997, Selassie Fest became one of the largest three-day cultural festivals on Chicago’s South Side. Held at the historic Seven Hills in Washington Park, it welcomed thousands of attendees each year to celebrate the rich cultural traditions, artistic excellence, entrepreneurial spirit, and community values of the Caribbean and African Diaspora — reflecting the diversity, creativity, and resilience that continue to define Chicago today.'
  },
  {
    id: 5,
    batch: 'legacy',
    visual: 'A simple timeline graphic — 1981, 1997, 2026, July 24 2027 — four markers on a single line.',
    headline: '1981–1997: sixteen years running. 1998–2026: the legacy waited. July 24, 2027: it comes home.',
    voice: [
      'Every generation inherits traditions — and the responsibility of deciding which ones deserve to continue.',
      'Ras Tafari Inc. believes Selassie Fest is one of them.'
    ],
    tellMore: 'Although the festival concluded in 1997, its influence did not end. Its legacy has endured through the memories of those who attended, the relationships that were formed, and the generations who continue to recognize its importance within Chicago’s cultural history. Its restoration is an opportunity to honor those who built it, inspire those who will inherit it, and strengthen the cultural fabric of Chicago for generations to come.'
  },
  {
    id: 6,
    batch: 'organization',
    visual: 'Clean, institutional graphic — the Ras Tafari Inc. name alongside simple icons for education, arts, entrepreneurship, and wellness.',
    headline: 'Ras Tafari Inc.: a 501(c)(3) cultural curator, not a one-weekend promoter.',
    voice: [
      'Culture is more than a reflection of the past — it’s a living resource that strengthens communities, inspires innovation, and connects generations.',
      'That belief is the entire reason this organization exists.'
    ],
    tellMore: 'As a cultural curator and community creator, Ras Tafari Inc. is dedicated to preserving, celebrating, and advancing Caribbean and African Diaspora culture through education, arts, music, entrepreneurship, wellness, and meaningful community engagement. Our work is rooted in a simple understanding: when communities know their history, celebrate their diversity, and invest in one another, they become stronger, more resilient, and better prepared for the future.'
  },
  {
    id: 7,
    batch: 'organization',
    visual: "Two stacked panels — 'Mission' and 'Vision' — clean typographic layout, no photography.",
    headline: 'Mission: preserve and advance the culture. Vision: a Chicago where that heritage is treated like infrastructure.',
    voice: [
      'To preserve, celebrate, and advance Caribbean and African Diaspora culture through education, the arts, entrepreneurship, wellness, and community partnerships.',
      'We envision a Chicago where cultural heritage is recognized as a vital resource for education, economic opportunity, and community development — not an afterthought.'
    ],
    tellMore: "Mission — To preserve, celebrate, and advance Caribbean and African Diaspora culture through educational programming, artistic expression, cultural experiences, community partnerships, and initiatives that strengthen neighborhoods while creating opportunities for present and future generations.\n\nVision — A Chicago where cultural heritage is recognized as a vital resource for education, economic opportunity, artistic excellence, tourism, and community development; where neighborhoods have cultural institutions as gathering places for learning and civic engagement; and where young people grow up with a deep appreciation for their heritage alongside the confidence and leadership skills to shape their communities' future."
  },
  {
    id: 8,
    batch: 'organization',
    visual: 'Overlapping circles motif in green and gold, representing residents, educators, artists, businesses, and public agencies converging.',
    headline: 'Stewardship is the job — not just running an annual event, but building an institution worth the trust placed in it.',
    voice: [
      'Preserving a historic cultural tradition requires thoughtful planning, transparent leadership, and a long-term commitment to excellence.',
      'And meaningful impact can’t be achieved by one organization alone.'
    ],
    tellMore: 'Ras Tafari Inc. understands that preserving a historic cultural tradition requires thoughtful planning, transparent leadership, collaborative partnerships, and a long-term commitment to excellence. Our role is to serve as responsible stewards of this legacy — listening to the community, working alongside public and private partners, and ensuring Selassie Fest continues to evolve in ways that honor its history while responding to the needs of future generations. Selassie Fest is our signature initiative, but it represents only one expression of a broader, year-round commitment to community development.'
  },
  {
    id: 9,
    batch: 'momentum',
    visual: 'A calendar page turning, landing on July 2027, with soft gold light.',
    headline: 'Some traditions quietly fade. Others get rediscovered because a community decides they still matter.',
    voice: [
      'The opportunity to restore Selassie Fest comes at a meaningful moment in Chicago’s history.',
      'Neighborhoods across the city are investing in education, public space, small business, arts and culture — this fits squarely into that momentum, not against it.'
    ],
    tellMore: 'Across Chicago, neighborhoods continue to invest in education, public spaces, small businesses, arts and culture, youth engagement, and community partnerships. Residents are seeking opportunities to reconnect with one another, celebrate the richness of Chicago’s diverse cultures, and create experiences that strengthen civic pride. Selassie Fest’s restoration is not about looking backward with nostalgia — it’s about carrying forward a tradition that can continue serving Chicago in new and meaningful ways.'
  },
  {
    id: 10,
    batch: 'momentum',
    visual: "A single date, large on screen — 'July 24, 2027' — with a small portrait-style engraving motif of Emperor Haile Selassie I in the corner.",
    headline: 'July 24, 2027 — commemorating the Earthstrong of His Imperial Majesty Emperor Haile Selassie I.',
    voice: [
      'The date is deliberate.',
      'But this isn’t a closed-door commemoration — it’s a day dedicated to culture, community, and shared humanity, open to everyone who wants to learn and celebrate.'
    ],
    tellMore: 'Beginning July 24, 2027, Selassie Fest returns as an annual one-day signature event at the Historic Seven Hills in Washington Park, held on the weekend of, or nearest to, July 23. The date commemorates the birth of His Imperial Majesty Emperor Haile Selassie I, whose life and legacy continue to inspire people around the world through principles of dignity, self-determination, education, service, unity, and international cooperation. While this historical commemoration remains central to the festival’s identity, Selassie Fest is designed to welcome all who wish to learn, celebrate, and participate.'
  },
  {
    id: 11,
    batch: 'momentum',
    visual: 'A wide crowd shot rendered as a mosaic of many different faces and cultures gathered on the same lawn.',
    headline: 'Rooted in the Caribbean and African Diaspora. Open to every neighbor in Chicago.',
    voice: [
      'Chicago has always been strengthened by the contributions of people from many cultures.',
      'Selassie Fest welcomes residents and visitors of every age, background, faith, and nationality — because understanding another culture enriches your own.'
    ],
    tellMore: 'Selassie Fest is rooted in the heritage of the Caribbean and African Diaspora, yet its spirit extends far beyond any single community. Accordingly, Selassie Fest welcomes residents and visitors of every age, background, faith, and nationality to gather at the Historic Seven Hills in Washington Park in an atmosphere of mutual respect, learning, and celebration. Entertainment draws people together, education gives the experience lasting value, and community gives it purpose.'
  },
  {
    id: 12,
    batch: 'momentum',
    visual: "A wide landscape shot of Washington Park's Seven Hills, empty and green, golden-hour light.",
    headline: 'The Historic Seven Hills isn’t just the venue. It’s part of the story.',
    voice: [
      'This is where families gathered for sixteen years, where friendships formed and businesses were introduced.',
      'Returning here honors the festival’s history — and the generations of residents who’ve gathered on this ground.'
    ],
    tellMore: 'From 1981 through 1997, this remarkable setting welcomed thousands of residents and visitors who gathered to celebrate the rich heritage of the Caribbean and African Diaspora through music, education, entrepreneurship, art, and community fellowship. Ras Tafari Inc. is committed to working collaboratively with the Chicago Park District, community organizations, volunteers, and public partners to promote responsible stewardship of this cherished public space — respecting the land, planning thoughtfully, and ensuring future generations may continue to enjoy this remarkable setting.'
  },
  {
    id: 13,
    batch: 'experience',
    visual: 'Wide festival-day montage — a stage performance, a food vendor row, a children’s activity tent, an artisan market table, all under string lights and afternoon sun.',
    headline: 'One day. Music, education, entrepreneurship, family, and food — all on the same lawn.',
    voice: [
      'Families enjoy live music and cultural performances.',
      'Children take part in educational activities. Artists exhibit work. Entrepreneurs introduce their businesses. Food vendors share culinary traditions from across the diaspora.'
    ],
    tellMore: 'From the moment visitors arrive at the Historic Seven Hills in Washington Park, Selassie Fest offers opportunities to experience the richness of Caribbean and African Diaspora culture through engaging, accessible programming: live music and performances for families, educational activities for children, exhibits from artists, talks from authors and historians, product showcases from entrepreneurs and local businesses, and food from vendors representing the diverse cultures across the festival. Throughout the day, every space is designed to encourage learning, conversation, and meaningful connection.'
  },
  {
    id: 14,
    batch: 'experience',
    visual: 'Close-up montage — hands drumming, a dancer mid-motion, a historian speaking to a small circle of listeners.',
    headline: 'Culture is the heartbeat. Education is woven through every corner of it.',
    voice: [
      'Music, dance, visual arts, storytelling, fashion, cuisine — traditions preserved and introduced to a new generation.',
      'Visitors engage directly with historians, educators, and cultural practitioners — this isn’t a textbook, it’s a conversation.'
    ],
    tellMore: 'Throughout the day, visitors experience music, dance, visual arts, storytelling, fashion, cuisine, and creative expression that reflect the diversity, resilience, and contributions of Caribbean and African Diaspora communities — preserving traditions while introducing them to new generations in ways that are engaging and inclusive. Education is woven throughout: visitors engage with historians, educators, authors, cultural practitioners, and community leaders through exhibits, presentations, demonstrations, and conversations that encourage curiosity and lifelong learning.'
  },
  {
    id: 15,
    batch: 'experience',
    visual: 'A row of small-business vendor tents, artisans at work, a family with children at a craft table.',
    headline: 'A launchpad for small business. A homecoming for families.',
    voice: [
      'Small businesses, artisans, and entrepreneurs showcase their products and ideas to new audiences.',
      'And children, parents, grandparents, and elders learn, create, and celebrate together — building memories that outlast a single afternoon.'
    ],
    tellMore: 'Selassie Fest celebrates the creativity and innovation of small businesses, artisans, nonprofit organizations, and entrepreneurs — providing opportunities to showcase products, services, and community resources while encouraging collaboration and neighborhood investment. Families are at the heart of the festival: children, parents, grandparents, and elders find opportunities to learn, create, play, and celebrate together, with interactive activities and cultural demonstrations encouraging shared discovery across generations.'
  },
  {
    id: 16,
    batch: 'experience',
    visual: 'Volunteers in matching festival shirts guiding guests, an accessible seating area, a welcome tent.',
    headline: 'Built on service. Designed so every visitor feels they belong.',
    voice: [
      'Volunteers, nonprofits, educators, and community partners are what actually make this run.',
      'Every visitor should feel welcomed, respected, and valued — and should leave with more than a photo. New knowledge. New friendships. A renewed sense of where they come from.'
    ],
    tellMore: 'Selassie Fest recognizes that strong communities are built through service — volunteers, nonprofit organizations, educators, civic leaders, and community partners all play an essential role in creating an event that reflects cooperation, generosity, and shared responsibility. Every visitor should feel welcomed, respected, and valued. As the day concludes at the Historic Seven Hills, the hope is that every guest leaves with new knowledge, new friendships, new appreciation for culture, and a renewed understanding that preserving history means carrying its lessons into the future.'
  },
  {
    id: 17,
    batch: 'impact',
    visual: 'A neighborhood-scale graphic — small icons of a school, a storefront, a family, a community center, all connected by lines to a central festival icon.',
    headline: 'This isn’t measured in one day of attendance. It’s measured in what it leaves behind.',
    voice: [
      'Communities flourish when people have opportunities to come together with purpose.',
      'Selassie Fest is built to create relationships that extend well beyond the festival weekend itself.'
    ],
    tellMore: 'Selassie Fest creates a welcoming environment where residents, families, community organizations, educators, artists, businesses, and civic leaders can build relationships that extend beyond the festival itself. Through cultural exhibits, historical presentations, and interactive learning experiences, it encourages curiosity, preserves knowledge, and inspires lifelong learning — creating opportunities for young people and adults alike to explore history and appreciate the contributions of the Caribbean and African Diaspora to Chicago.'
  },
  {
    id: 18,
    batch: 'impact',
    visual: 'A simple bar-style graphic representing local vendors, artists, and entrepreneurs gaining new customers and exposure.',
    headline: 'Strong communities need strong local economies — and civic pride that isn’t manufactured.',
    voice: [
      'Entrepreneurs, artists, artisans, and small businesses get in front of new audiences and new customers.',
      'And when a city restores a tradition like this, it’s reaffirming that culture is one of its greatest strengths — not a footnote.'
    ],
    tellMore: 'Selassie Fest provides opportunities for entrepreneurs, artists, artisans, authors, nonprofit organizations, food vendors, and small businesses to introduce their work to new audiences — contributing to economic activity while fostering relationships that continue long after the event concludes. By restoring Selassie Fest, Chicago celebrates not only the heritage of the Caribbean and African Diaspora but also its enduring commitment to preserving the traditions that enrich every neighborhood. When communities honor their history, they strengthen their future.'
  },
  {
    id: 19,
    batch: 'impact',
    visual: "A simple scorecard-style graphic — not ticket sales, but 'partnerships formed,' 'volunteers engaged,' 'businesses supported,' 'youth inspired.'",
    headline: 'Success isn’t attendance. It’s partnerships formed, businesses supported, and youth inspired.',
    voice: [
      'The metric that matters isn’t how many people showed up.',
      'It’s the partnerships established, the volunteers engaged, the local businesses supported, and the young people who leave inspired.'
    ],
    tellMore: 'The success of Selassie Fest will not be measured solely by attendance. It will also be reflected in the partnerships established, volunteers engaged, educational opportunities created, local businesses supported, artists showcased, youth inspired, and communities strengthened. These outcomes represent the lasting legacy of a festival designed to serve Chicago with purpose and integrity, not simply to draw a crowd once a year.'
  },
  {
    id: 20,
    batch: 'impact',
    visual: 'A calendar showing a single festival weekend in July, with faint activity markers scattered across the rest of the year — workshops, mentorship sessions, small gatherings.',
    headline: 'The festival is one day. The work behind it never stops.',
    voice: [
      'Selassie Fest is the signature gathering — but it’s the annual celebration of a mission that runs all year.',
      'Workshops, youth programs, artist and entrepreneur partnerships — the relationships built at the festival are meant to keep going after the tents come down.'
    ],
    tellMore: 'While Selassie Fest is celebrated over one day each year, the commitment behind it continues throughout the year — expanding cultural education through workshops, lectures, youth programs, and historical presentations; supporting artists and entrepreneurs with ongoing partnerships; collaborating with neighborhood organizations and civic leaders on community engagement and preservation initiatives; and building the next generation of leaders through volunteerism, mentorship, and youth participation. The festival marks a milestone each year, but the work of building community never pauses.'
  },
  {
    id: 21,
    batch: 'impact',
    visual: 'A simple five-marker timeline graphic — Year 1 through Year 5 — each marker slightly taller than the last.',
    headline: 'Five years out: growth measured by quality, not just size.',
    voice: [
      'Each year builds on the last through community feedback and stronger partnerships — not just a bigger footprint.',
      'The goal is an institution recognized for educational excellence and community leadership, not just a bigger stage.'
    ],
    tellMore: 'Over the next five years, Ras Tafari Inc. seeks to strengthen relationships with neighborhood organizations, educational institutions, cultural organizations, businesses, philanthropic foundations, civic leaders, and public agencies — expanding educational opportunities for youth, supporting Chicago’s creative economy, and preserving history through innovation such as digital storytelling and oral history archives. Growth will be measured by quality, not simply by size: the goal is to establish Selassie Fest as an enduring cultural institution recognized for educational excellence, community leadership, and responsible stewardship.'
  },
  {
    id: 22,
    batch: 'partnership',
    ask: true,
    visual: 'An open circle graphic with five empty seats labeled — City of Chicago, Chicago Park District, Educational Institutions, Businesses & Philanthropy, Community Organizations.',
    headline: 'This restoration is not the work of one organization. It’s an open invitation to five kinds of partners.',
    voice: [
      'No single organization can do this alone.',
      'This is a direct invitation to the City of Chicago, the Chicago Park District, schools and universities, businesses and philanthropic partners, and neighborhood organizations to help shape the next chapter.',
      'Every partner brings something the others can’t.'
    ],
    tellMore: [
      'Ras Tafari Inc. believes that meaningful and lasting community impact is achieved through collaboration — every successful cultural institution is strengthened by the people, organizations, and public partners who believe in its mission.',
      'The City of Chicago plays an essential role in preserving the traditions, public spaces, and cultural experiences that enrich residents’ lives — the invitation is to collaborate on the highest standards of public service, safety, accessibility, and stewardship.',
      'The Chicago Park District is a direct steward partner for the Historic Seven Hills in Washington Park itself — responsible planning, environmental care, and accessibility depend on that relationship.',
      'Educational institutions — schools, colleges, universities, libraries, and museums — are invited to collaborate on educational programming, historical interpretation, research, internships, and youth engagement that extend beyond the annual festival.',
      'Businesses and philanthropic organizations are invited into sponsorship, community investment, and collaborative initiatives that benefit residents while contributing to Chicago’s cultural vitality.',
      'Community organizations — neighborhood groups, nonprofits, faith communities, artists, and volunteers — each contribute unique strengths; the future of Selassie Fest depends on listening, learning, and building together with them.'
    ]
  },
  {
    id: 23,
    batch: 'partnership',
    visual: "A simple 'what we're asking for' checklist graphic — five lines, each with an open checkbox.",
    headline: 'What partnership looks like, concretely — not just goodwill.',
    voice: [
      'Public service, safety, and permitting support from the City.',
      'Responsible co-stewardship of Washington Park with the Park District.',
      'Educational collaboration, sponsorship dollars, and volunteer hands from everyone else at the table.'
    ],
    tellMore: 'Ras Tafari Inc. extends an open invitation to every individual and organization that shares this vision. Whether through partnership, sponsorship, volunteer service, educational collaboration, artistic participation, or community leadership, every contribution helps strengthen Selassie Fest and the communities it serves. The preservation of culture is not the responsibility of one generation alone — by working together, we ensure that traditions are not only remembered, but experienced, celebrated, and passed forward.'
  },
  {
    id: 24,
    batch: 'close',
    visual: 'A simple five-line commitment card — Heritage, Community, Education, Partnership, Stewardship — each with a small check already ticked.',
    headline: 'Five commitments Ras Tafari Inc. is making before asking anyone else to make one.',
    voice: [
      'To heritage — honoring the history of Selassie Fest with integrity.',
      'To community — an atmosphere where every visitor belongs.',
      'To education, to partnership, and to responsible stewardship of the park entrusted to us.'
    ],
    tellMore: 'We commit to honoring the history of Selassie Fest with integrity and respect. We commit to creating an annual gathering where every person who attends feels they belong. We commit to preserving history through education, to working collaboratively with the City, the Park District, and every partner listed here, and to responsibly caring for the Historic Seven Hills and every public resource entrusted to us. The greatest success of Selassie Fest will be measured by what future generations inherit because of the work we begin today.'
  },
  {
    id: 25,
    batch: 'close',
    proof: true,
    visual: "A formal document graphic — 'Resolution No. 2026-01' letterhead, with a signature line.",
    headline: 'This isn’t a pitch waiting on a board’s approval. The board already resolved it.',
    voice: [
      'Resolution No. 2026-01 — the Ras Tafari Inc. Board of Directors has already adopted this Vision Proposal as the organization’s guiding framework.',
      'The commitment to restoration is already on the record. What’s needed now are partners.'
    ],
    tellMore: 'WHEREAS Selassie Fest was held from 1981 through 1997 at the Historic Seven Hills in Washington Park, becoming one of Chicago’s most recognized celebrations of Caribbean and African Diaspora culture, the Board of Directors of Ras Tafari Inc. has resolved to adopt this Vision Proposal as the organization’s guiding framework for the restoration, preservation, and future growth of Selassie Fest — affirming its commitment to preserving the historic legacy, promoting education and community engagement, strengthening partnerships throughout Chicago, practicing responsible stewardship of the Historic Seven Hills, and supporting annual planning for Selassie Fest on the weekend of, or nearest, July 23 each year.'
  },
  {
    id: 26,
    batch: 'close',
    personalize: 'close',
    visual: "Return to frame 1's shot of the Seven Hills — now lit at dusk, tents up, a crowd gathered.",
    headline: 'Selassie Fest — Restoring a Chicago Legacy. Together, we carry it forward.',
    voice: [
      '{{name}}, this is the vision.',
      'The next chapter starts with the partners who choose to help build it.'
    ],
    tellMore: 'This document is a Vision Proposal prepared by Ras Tafari Inc. for board review and community collaboration — Version 1.0. It is offered as an invitation to public agencies, community organizations, educational institutions, businesses, artists, residents, and civic leaders to join in restoring a historic Chicago tradition and shaping a future in which culture continues to educate, inspire, and unite.'
  },
  {
    id: 27,
    batch: 'close',
    cta: true,
    visual: "Minimal, on-brand card — the Selassie Fest wordmark, the Ras Tafari Inc. name, and a 'Let's talk' prompt.",
    headline: 'Let’s talk.',
    voice: [],
    tellMore: null
  }
];

const BATCH_LABELS = {
  hook: 'The Vision',
  legacy: 'The Legacy',
  organization: 'The Organization',
  momentum: 'The Moment',
  experience: 'The Experience',
  impact: 'The Impact',
  partnership: 'The Partnership',
  close: 'The Commitment'
};

// Content spec: transcribed from One_Umbrella_FlipBook_BeatSheet.md, backed by
// The One Umbrella Experience proposal (MarlonTRC x One Umbrella Sports & Entertainment x Ticket Tailor).
// {{name}} is replaced at render time with the investor's name/firm (frames 1 and 25 only).
// Real partner logos live in assets/logos/ — see the `logos` field on frames 2, 3, and 27.

const LOGOS = {
  marlontrc: { src: 'assets/logos/marlontrc.png', alt: 'MarlonTRC — The Reggae Connection' },
  oneUmbrella: { src: 'assets/logos/one-umbrella-primary.png', alt: 'One Umbrella Sports & Entertainment' },
  oneUmbrellaBadge: { src: 'assets/logos/one-umbrella-badge.png', alt: 'One Umbrella Sports & Entertainment' },
  ticketTailor: { src: 'assets/logos/ticket-tailor.png', alt: 'Ticket Tailor' },
  theYawd: { src: 'assets/logos/the-yawd.png', alt: 'The Yawd — Come Home.' }
};

const FRAMES = [
  {
    id: 1,
    batch: 'hook',
    personalize: 'start',
    visual: 'Aerial night shot of the Chicago skyline — one warm-lit building glowing on the South or West Side, everything else dark.',
    headline: 'Chicago has never had a permanent home for Jamaican dancehall and reggae.',
    voice: [
      'Prepared for {{name}}.',
      "Chicago has every other genre covered — house, hip-hop, Latin music all have a room they can call home.",
      "Dancehall and reggae don't. Not one permanent address, anywhere in this city."
    ],
    tellMore: "Chicago's nightlife map is dense with hip-hop, house, and Latin music venues, but it has no permanent, purpose-built home for dancehall and reggae — despite a large and passionate Caribbean and Afro-diaspora audience across the city. The One Umbrella Experience is framed as a deliberate correction: using a dedicated property and a committed operating partner to build the infrastructure the culture has been missing."
  },
  {
    id: 2,
    batch: 'hook',
    logoReveal: true,
    logos: [LOGOS.theYawd],
    visual: "Full-bleed reveal of The Yawd's own gold wordmark on a dark, minimal background.",
    headline: 'One partner. One property. One movement that never stops.',
    voice: ['One partner. One property. One movement that never stops.'],
    tellMore: 'The flagship property carries its own name and identity: The Yawd — "Come Home." Music, Culture, Food, Community.'
  },
  {
    id: 3,
    batch: 'hook',
    logos: [LOGOS.marlontrc, LOGOS.oneUmbrella, LOGOS.ticketTailor],
    visual: 'The three partner marks side by side — MarlonTRC, One Umbrella Sports & Entertainment, Ticket Tailor.',
    headline: 'A proposal from MarlonTRC, built to run with One Umbrella Sports & Entertainment and Ticket Tailor.',
    voice: [
      "This isn't a solo pitch.",
      "It's three parties, each doing the one thing they're actually built for."
    ],
    tellMore: 'Prepared by MarlonTRC as a proposed cultural and business partnership framework for consideration by One Umbrella Sports & Entertainment and Ticket Tailor. This document outlines a concept — not an executed agreement — intended as the starting point for a three-way conversation about building, operating, and ticketing a permanent home for Jamaican dancehall and reggae culture in Chicago.'
  },
  {
    id: 4,
    batch: 'hook',
    visual: 'Simple 3-step diagram: Book → House → Perform, icon-driven, no paragraph text on screen.',
    headline: 'Instead of renting a stage for one night — build the pipeline that brings Jamaica to Chicago every month.',
    voice: [
      'MarlonTRC runs it.',
      "One Umbrella's relationships — and the artists' own network — book it.",
      'Ticket Tailor makes every dollar visible.',
      'Every month, the island touches down.'
    ],
    tellMore: [
      'A dedicated concert property in Chicago is developed and branded as the flagship home of Jamaican dancehall and reggae in the Midwest.',
      'One Umbrella Sports & Entertainment, in conjunction with reggae icons, is positioned as the operating partner, liaison, and owner of record.',
      "At least once a month, the property brings a Jamaican dancehall or reggae artist to perform, drawing on One Umbrella's industry relationships and the artists' own peer network — no single artist's calendar is the bottleneck.",
      'The property is designed to host both the show and the traveling artist — stage, sound, and a place to sleep, all on one site.',
      'Ticket Tailor powers every transaction — single tickets, VIP add-ons, the monthly membership pass, and pay-per-view — so revenue reporting is unified from night one.',
      'Proceeds are structured so the artist, the property, and the production company all have a stake in the night going well.'
    ]
  },
  {
    id: 5,
    batch: 'hook',
    visual: 'Concept render — exterior + interior mainstage shot, warm stage lighting, a glimpse of a rooftop apartment window.',
    headline: 'Welcome to The Yawd: 200 to 4,000 guests, world-class sound, a 5-star suite for the artist.',
    voice: [
      "Every touring artist's two biggest headaches in America are inconsistent sound and expensive lodging.",
      'The Yawd solves both, on one site.'
    ],
    tellMore: [
      'Location — Chicago, Illinois; site to be finalized in partnership with local ward and city permitting.',
      'Capacity — 200–4,000 guests, with the ability to section the venue to match crowd size.',
      'Stage — permanent mainstage built for live and sound-system performance.',
      "Sound — world-class, purpose-installed sound system, the property's signature feature.",
      "Backline — so band members don't need to travel with major equipment.",
      'Artist Housing — on-site furnished apartment, set up as a 5-star suite with smart features and solid-state recording equipment.',
      'Revenue Streams — ticketing (via Ticket Tailor), alcohol, food, concessions, and membership dues.',
      'Cadence — minimum one Jamaican artist booking per month, plus at least one Afro-Beats, one Reggaetón, and one pop booking per month, year-round.'
    ]
  },
  {
    id: 6,
    batch: 'momentum',
    visual: "Portrait-style art — a silhouette of an artist stepping off a plane at O'Hare, city lights behind.",
    headline: 'One Umbrella opens the door. The artists keep it open.',
    voice: [
      "One Umbrella's job is to make the first bookings — the ones nobody else could get.",
      "But the model isn't built to depend on that contact list forever."
    ],
    tellMore: "One Umbrella Sports & Entertainment's role is the engine of the entire model. As the property's operating partner and booking liaison, One Umbrella is responsible for identifying and bringing at least one Jamaican dancehall or reggae artist to the property every month — drawing on its own standing in sports and entertainment and its artists' own peer relationships, while MarlonTRC runs the business and day-to-day operations, to make bookings that outside promoters could not secure on their own."
  },
  {
    id: 7,
    batch: 'momentum',
    visual: 'Chain-link / relay-baton motif — one artist icon handing off to the next, radiating outward.',
    headline: 'Every artist who plays becomes the next booking agent.',
    voice: [
      'Once an artist has actually performed here — been housed, watched the numbers, been paid out — they become the most credible person in Jamaica to vouch for this room.',
      "That's not a call sheet. That's a chain."
    ],
    tellMore: "This is the difference between a venue that occasionally books reggae acts and a venue that Jamaica trusts. A rotating roster of artists — not a single name — is the credential that makes the monthly pipeline durable: no one artist's schedule, health, or availability can take the property dark."
  },
  {
    id: 8,
    batch: 'momentum',
    proof: true,
    visual: "A small, packed neighborhood club — warm string lights, a modest stage. The real Wild Hare, Chicago's self-declared reggae capital of the USA.",
    headline: 'This model already exists at bar scale — it’s called the Wild Hare.',
    voice: [
      'There’s already a small version of this running today.',
      'The Wild Hare — Chicago’s self-declared reggae capital of the USA — is sized like a neighborhood bar, not a flagship stage.',
      'MarlonTRC runs the room. One Umbrella, and the artists themselves, are who actually book it.'
    ],
    tellMore: 'The Wild Hare (wildharemusic.com) is a real, currently operating Chicago venue that calls itself the reggae capital of the USA — but it’s sized like a neighborhood bar, not built to hold a top-tier touring reggae act at the scale Jamaica’s biggest names actually draw. MarlonTRC operates the room day to day. But the bookings that fill it come from One Umbrella Sports & Entertainment’s own artist relationships, and from artists booking their own performer friends directly — the same referral-engine dynamic this proposal scales up. MarlonTRC’s strength is running the business and the room; the artist relationships live with One Umbrella and the artists themselves. That honest division of labor is already proven at small scale — this proposal is what happens when it’s given a room big enough to matter.'
  },
  {
    id: 9,
    batch: 'momentum',
    visual: "A live-updating ticket counter graphic (mocked, e.g. '347 / 500 sold — 3 days to show').",
    headline: 'The artist doesn’t wait on a promoter’s word. They watch the room fill in real time.',
    voice: [
      "The biggest fear a touring artist has isn't the show — it's the promoter.",
      'Ticket Tailor makes that fear irrelevant: the ticket count itself is the collateral.'
    ],
    tellMore: "A shared, real-time Ticket Tailor reporting dashboard — gross sales, fees, net — makes transparency operational rather than promised. And under every deal structure, loss-sharing stays honest: the artist can never end the night owing the house money. The artist's worst case is their airfare; the house's worst case is its documented cost."
  },
  {
    id: 10,
    batch: 'momentum',
    visual: 'Calendar-style grid, five distinct color-coded Saturday tiles with series names.',
    headline: 'The Dancehall Experience. Hardcore. International. Culture. Queens.',
    voice: ['Five identities, one flagship stage — fans plan their month around it.'],
    tellMore: [
      '1st Saturday — The Dancehall Experience, Live',
      '2nd Saturday — Hardcore Dancehall Experience',
      '3rd Saturday — International Experience',
      '4th Saturday — Culture Experience',
      '5th Saturday — Queens of Dancehall Experience',
      'Monthly cadence gives the property a reputation as reliable, not occasional — fans plan around it, and each edition can spotlight a different artist from the touring roster.'
    ]
  },
  {
    id: 11,
    batch: 'momentum',
    visual: 'Small inline data table (the actual 2027–2030 counts) over a faded calendar background.',
    headline: '17 bonus editions between 2027 and 2030 — budgeted like a quarterly flagship, not a monthly one.',
    voice: [
      "We're not going to oversell this one.",
      'A 5th Saturday only happens when the calendar gives us one — so that’s exactly how we’re pricing and sponsoring it.'
    ],
    tellMore: 'A month only gets a 5th Saturday when the calendar lines up — not every month. Counting forward from 2027 through 2030, that happens 17 times total: 2027 (Jan, May, Jul, Oct), 2028 (Jan, Apr, Jul, Sep, Dec), 2029 (Mar, Jun, Sep, Dec), 2030 (Mar, Jun, Aug, Nov). That’s just over four a year — sized and sponsored like a quarterly flagship, not a fifth guaranteed monthly show.'
  },
  {
    id: 12,
    batch: 'money',
    visual: "Two-column diagram — 'Operating Business' (MarlonTRC + One Umbrella icons) vs. 'Real Estate' (an empty/dotted icon slot, deliberately unfilled).",
    headline: 'The operating business is spoken for. The real estate is the open seat.',
    voice: [
      'Production company, booking pipeline, the series itself — MarlonTRC and One Umbrella own that.',
      'The building is a different question. That’s the next frame.'
    ],
    tellMore: "The proposal contemplates One Umbrella Sports & Entertainment and MarlonTRC holding ownership across all three layers of the business, with exact percentages subject to negotiation, so incentives are aligned with the long-term success of the property rather than a single night's paycheck: the Production Company owns the brand, the booking pipeline, and the show operations. Real Estate owns the physical property, meaning the venue's value grows as the series grows. The Series owns the relationship with Jamaica, as the pipeline every visiting act works through."
  },
  {
    id: 13,
    batch: 'money',
    ask: true,
    visual: "The empty icon slot from the previous frame fills in — a building icon lights up, base-rent-plus-percentage graphic (a rising bar with a 'kicker' arrow).",
    headline: 'Neither One Umbrella nor MarlonTRC can buy this building. That’s not a gap — it’s the opportunity.',
    voice: [
      'A fixed-rent lease gives an investor a bond-like return — and no reason to care if the room is full or empty.',
      'This deal is built the opposite way.',
      'Base rent covers your debt service from day one.',
      'A percentage of revenue on top means your return grows exactly the way the venue grows.',
      'That’s real skin in the game.'
    ],
    tellMore: [
      'Neither One Umbrella Sports & Entertainment nor MarlonTRC owns or can independently finance the real estate itself — a funding or ownership partner for the building is the single largest open item in this proposal.',
      'What’s being proposed, structurally, and subject to negotiation and a formal agreement:',
      'What the funding partner gets — an ownership or financing stake in the real estate layer specifically, separate from, and senior to, the operating business.',
      'Base rent — set to cover the property’s debt service from day one, functioning like the floor of a traditional lease.',
      'Percentage rent — a share of revenue on top of base rent, so the return scales up as the venue’s business grows, not a fixed bond-like payment regardless of performance.',
      'Optional equity path — room for a funding partner to convert into a direct ownership stake in the real estate rather than remaining a lessor only.',
      'Exact percentages, rent figures, and equity terms are not fixed here — they are the specific subject of the next conversation with a funding partner, same as every other deal term in this package.'
    ]
  },
  {
    id: 14,
    batch: 'money',
    visual: 'The Option A table, reformatted as a clean visual split-bar (not a text-heavy table).',
    headline: 'The first $5,000 at the door belongs to the artist — before the house takes a dollar.',
    voice: [
      "It's the inverse of a typical club deal, on purpose.",
      'That inversion is the message to Jamaica.'
    ],
    tellMore: "Option A — Artist-First Door: the first 200 tickets sold (at $25) go 100% to the visiting artist, up to $5,000, earned off the top of the door — functioning as an earned guarantee. Tickets 201–500 split 60% artist / 40% property. Tickets 501 and above split 40% artist / 60% property. Alcohol, food and concessions are 100% property, covering the venue, sound system, staffing, and the artist suite. Artist merchandise is 100% artist — the house provides the table and a seller. A soft night of 200 tickets still pays the artist $5,000 before the house touches a dollar of ticketing; a sell-out keeps paying them on a sliding scale while the house recovers its fixed costs from the tiers and the bar."
  },
  {
    id: 15,
    batch: 'money',
    visual: 'The three-column worked-example table (200 / 500 / 1,000 tickets), reformatted as a simple bar chart.',
    headline: 'Three deal structures. Every one guarantees the artist can’t lose.',
    voice: [
      'Open-books 50/50 for marquee names.',
      'Guarantee-versus-percentage for agents who want familiar paper.',
      'Pick the deal, not the risk.'
    ],
    tellMore: "Option B — Partnership Pool (Open-Books 50/50): the house publishes its documented per-show cost — sound, staff, security, and marketing, estimated at $6,000–$8,000 per event — before the deal is signed. Every dollar the night generates goes into one pool; the house cost is recouped first, everything above splits 50/50. If the pool falls short, the artist owes nothing.\n\nOption C — Guarantee vs. Percentage: the artist receives whichever is greater — a guarantee of $2,500–$5,000 (by artist tier), or 70% of net door — plus a kicker of 10% of bar sales above a published break-even.\n\nWorked example, at a $25 ticket:\n200 tickets sold → Option A: $5,000 · Option B: $1,000 · Option C: $3,360\n500 tickets sold → Option A: $9,500 · Option B: $7,750 · Option C: $8,600\n1,000 tickets sold → Option A: $14,500 · Option B: $19,000 · Option C: $18,000\n\nOption A pays best on a soft night — the trust-builder. Options B and C reward the artist hardest on a blowout. Recommended posture: lead with Option A as the house default, hold Option B for marquee names who want to see the books, and keep Option C for agents who prefer familiar paper."
  },
  {
    id: 16,
    batch: 'money',
    visual: 'A single frame photo-style render of the artist suite (bed, recording nook, skyline view).',
    headline: 'Housing, transport, a stocked pantry, a recording rig — a $2,500–$4,000 value, in-kind, every booking.',
    voice: [
      'Flights are still on the artist.',
      'Almost everything else isn’t.'
    ],
    tellMore: 'The Residency Package (in-kind, every booking): the on-site artist suite for 5–7 nights, a stocked Jamaican pantry and daily catering, ground transport from O’Hare or Midway, full house backline with an engineer, and secure merch storage — replacement value $2,500–$4,000 per visit.\n\nThe Bridge Fund: 3% of every ticket sold across all weekly programming is ring-fenced for artist travel, collected automatically as a Ticket Tailor add-on fee at checkout. At a modest 2,500 tickets a month, the fund banks $1,800+ in monthly airfare reimbursements.\n\nLoss-sharing stays honest: under every option, the artist can never end the night owing the house money. The artist’s worst case is their airfare; the house’s worst case is its documented cost.'
  },
  {
    id: 17,
    batch: 'systems',
    visual: "Flow diagram — ticket sale → split → three bank-account icons (artist, promoter, house) — no central 'clearinghouse' box.",
    headline: 'No clearinghouse. Every stakeholder gets their cut the moment the ticket sells.',
    voice: [
      'This is the specific reason Ticket Tailor is the platform, not a vendor choice.',
      'Money doesn’t pool and wait — it splits at the source.'
    ],
    tellMore: "Flat, low fees protect the Artist-First Door model — a platform that takes a large percentage cut works directly against the promise that the artist gets the first dollars. Ticket Tailor's flat per-ticket fee keeps more of every ticket dollar in the split the artist and the house actually agreed to. Trackable promo codes make the Coalition Council's commissions and co-promoter fees calculate automatically, with no manual reconciliation. A shared, real-time reporting dashboard makes Option B's open-books promise operational rather than just promised. And the property — not the ticketing platform — owns the relationship with every ticket buyer, which matters for a business whose long-term value is a loyal, recurring membership base."
  },
  {
    id: 18,
    batch: 'systems',
    visual: 'The "one headline night" illustration table, reformatted as payout chips (co-promoter, selecta, dancer, house sound).',
    headline: 'Every role on the settlement sheet — not a favor.',
    voice: [
      'Commission, presale margin, co-promotion points, afterparty door.',
      'If you work this beat, your piece is written down before the show, not negotiated after.'
    ],
    tellMore: 'Illustration of what one headline night pays the local scene: a co-promoter of record earns roughly $875 ($750 fee plus 1% of a $12,500 door). A coalition promoter selling 60 tickets by code earns $150, uncapped. A promoter flipping a 40-ticket presale block earns a $200 margin. A support selecta earns a $200–$400 posted house rate. The House Sound of the Month earns a $300–$500 monthly stipend plus branding. A resident dance crew of four earns $100–$150 each, on payroll. An in-house afterparty host keeps 100% of the afterparty door.\n\nA quarterly Coalition Council — participating promoters, sound systems, and dance crews — reviews the rotation calendar, rate card, and roster each quarter, with rotations published a quarter in advance. The Scene Fund ring-fences 2% of gross door on headline nights for micro-grants toward coalition members’ own independent events.'
  },
  {
    id: 19,
    batch: 'systems',
    visual: "Map-style graphic — Chicago's existing music-venue density (house, hip-hop, Latin) with a highlighted gap where dancehall/reggae should be.",
    headline: 'Every genre in this city has a room. This is dancehall’s.',
    voice: [
      'This isn’t a bet on a new audience.',
      'It’s building the room a real, existing audience has never had.'
    ],
    tellMore: 'Chicago’s nightlife map is dense with hip-hop, house, and Latin music venues, but has no permanent, purpose-built home for dancehall and reggae — despite a large and passionate Caribbean and Afro-diaspora audience across the city. The property is meant to create a recurring, predictable calendar reason for Jamaican music fans to gather monthly, give local promoters, selectas, dancers, vendors, and hospitality workers steady, repeatable income, build a direct cultural and economic bridge between Chicago and Jamaica, and give Chicago-based reggae and dancehall talent a training ground and stage.'
  },
  {
    id: 20,
    batch: 'systems',
    visual: 'The weekly grid (Monday–Sunday) as a horizontal timeline strip, one icon per night.',
    headline: 'A property this size can’t sit dark six nights and light up once a month.',
    voice: [
      'Monday breaks new artists.',
      'Tuesday trains selectors.',
      'Wednesday teaches newcomers.',
      'Thursday honors house music, Chicago’s own.',
      'Friday is the whole diaspora.',
      'Saturday is the flagship.',
      'Sunday already has a following.'
    ],
    tellMore: 'Monday — New Music Live: a launchpad for Chicago’s up-and-coming artists to premiere original music. Tuesday — Riddim Tuesday: an open-deck night for selectors and MCs to build reputation. Wednesday — Dancehall 101: an introduction night for newcomers. Thursday — House Foundation Thursday: Chicago’s own house DJs on the biggest rig in the city, becoming House Meets Dancehall once a month. Friday — Diaspora Friday: Soca and Afrobeats for the whole Caribbean and African diaspora, becoming Island Bridge Friday once a month with a visiting Jamaican headliner. Saturday — One Umbrella Presents: the flagship marquee night. Sunday — Sing Over Sundays: an existing MarlonTRC brand, an elegant reggae/R&B dance party pairing R&B originals with their reggae covers across a five-hour arc, anchored by the signature "Cover Story" hour.'
  },
  {
    id: 21,
    batch: 'experience',
    visual: 'Split-frame — sunrise fitness class on the mainstage floor / the Selecta Academy classroom on the same rig, day vs. night lighting.',
    headline: 'The building that never sleeps: fitness at 6 AM, the Academy at 2 PM, the flagship at 10 PM.',
    voice: [
      'A one-show-a-month room is dark 714 hours out of 720.',
      'This one is programmed for over 120 hours a week.'
    ],
    tellMore: 'The Day-Part Grid runs sunrise Riddim Workout fitness classes, midday jerk lunch service and studio co-working, afternoon Selecta Academy sessions, the evening weekly program, and after-hours studio lockouts — seven days a week. The Selecta Academy trains the next generation on a world-class rig via a rotating faculty of established selectors and touring artists, with a free/sliding-scale youth track (ages 13–18) and paid adult cohorts ($350–$500 per seat). Every cohort graduates live on Riddim Tuesday’s open decks. Riddim Workout is a fitness brand family — led by ReggaeRobics, an existing MarlonTRC brand — mapping classic fitness formats onto the building’s genres (Bruk Out Bootcamp, Carnival Cardio, The House Werk, Afrobeats Burn, Rocksteady, Lovers Rock & Stretch), each taught on the biggest sound system in the city.'
  },
  {
    id: 22,
    batch: 'experience',
    visual: "The artist suite reimagined as a boutique short-stay listing — moodboard style, 'Legacy Closet' display case with a signed item under glass.",
    headline: 'Between residencies, the suite pays for itself — and the Legacy Closet keeps paying the artist for months after they fly home.',
    voice: [
      '$31,000 to $49,000 a year from a space the property already built.',
      'That’s before the merchandise case.'
    ],
    tellMore: 'Between residencies, the suite lists as a themed short-stay (Airbnb/Vrbo) — 15 booked nights a month at $175–$275 a night is $2,600–$4,100 monthly, roughly $31,000–$49,000 a year. A blackout calendar automatically clears the suite for each monthly residency window. The Legacy Closet displays signed items visiting artists leave behind — a stage-worn shirt, signed vinyl, a handwritten setlist — sold to short-stay and VIP guests through the same Ticket Tailor point-of-sale, split 70% artist / 30% house on consignment, so the artist keeps earning from Chicago months after they fly home. The suite’s recording rig also rents by the day to Chicago artists whenever no residency is in.'
  },
  {
    id: 23,
    batch: 'experience',
    visual: 'Icon grid — 8 small icons (livestream, membership pass, facility fee, sponsorship, private rentals, merch, daytime programming, marquee premiums).',
    headline: 'Eight revenue lines. None of them require a bigger room.',
    voice: ['The livestream alone adds roughly $5,000 a show without a single extra body on the floor.'],
    tellMore: 'Livestream pay-per-view: the monthly headline show streams to the diaspora at $9.99; five hundred streams adds roughly $5,000 per show. The Riddim Pass: a monthly membership (illustratively $30/month) covering entry to all weekly nights plus discounts. Facility fee: $1–$2 on every ticket, funding a capital-improvement reserve. Sponsorship & naming rights: rum, beer, jerk-sauce brands, Caribbean airlines, and remittance companies. Dark-day private rentals: weddings, repasses, and corporate events on off nights. Co-branded merchandise sold in-room, in the suite, and online. Daytime programming: brunch, dance and drumming classes, youth workshops. Marquee-night premiums: VIP tables, bottle service, coat check, and parking.'
  },
  {
    id: 24,
    batch: 'close',
    visual: 'Same building-icon graphic from the ask frame, now shown fully built and lit.',
    headline: 'This is the single largest open item in the proposal — and the one thing that sets the timeline.',
    voice: [
      'Everything else in this pitch can move in parallel.',
      'Site selection and construction can’t start without a funding partner.'
    ],
    tellMore: 'A funding or ownership partner for the real estate is the single largest open item in this proposal — everything else (the Ticket Tailor scoping call, the Coalition Council, the Selecta Academy curriculum, the booking calendar) can move in parallel, but site selection and construction cannot begin without a funding partner in place.'
  },
  {
    id: 25,
    batch: 'close',
    visual: "A clean numbered checklist graphic, 9 items, first one already ticked ('MarlonTRC ↔ One Umbrella conversation').",
    headline: 'Nine steps. One of them is the one that matters most.',
    voice: ['The rest of this list moves the day the real estate question is answered.'],
    tellMore: [
      '1. Introductory conversation between MarlonTRC and One Umbrella Sports & Entertainment leadership to confirm interest and align on the anchor-partner role.',
      '2. Scoping call with Ticket Tailor’s partnerships team to configure a multi-event box office ahead of a soft launch and confirm fee terms.',
      '3. Site selection and walkthrough of candidate Chicago properties.',
      '4. Term sheet covering ownership percentages, the selected deal structure, the Bridge Fund, suite rental and Legacy Closet terms, and loss-sharing provisions.',
      '5. Convening of the founding Coalition Council to ratify the rotation calendar, rate card, and Scene Fund terms.',
      '6. Curriculum design and sponsor outreach for the Selecta Academy, including school-district partnership conversations.',
      '7. ReggaeRobics rollout plan — instructor certification, on-demand filming schedule, and trademark housekeeping.',
      '8. Formation of the production company and real estate holding structure.',
      '9. Booking calendar for the first six flagship series editions.'
    ]
  },
  {
    id: 26,
    batch: 'close',
    personalize: 'close',
    visual: "Return to frame 1's skyline shot — now the building is lit, and the whole block around it is lit too.",
    headline: 'The One Umbrella Experience — introducing The Yawd. Roots in Jamaica. A Home in Chicago.',
    voice: [
      '{{name}}, this is the proposal.',
      'The next conversation is yours to start.'
    ],
    tellMore: 'This package is a proposal prepared by MarlonTRC for discussion purposes only. All figures, ownership terms, and revenue splits are subject to negotiation and formal legal agreement before any partnership is binding.'
  },
  {
    id: 27,
    batch: 'close',
    cta: true,
    logos: [LOGOS.marlontrc, LOGOS.oneUmbrella, LOGOS.ticketTailor, LOGOS.theYawd],
    visual: "Minimal, on-brand card — MarlonTRC, One Umbrella, Ticket Tailor, and The Yawd marks, plus a 'Schedule a call' button.",
    headline: 'Let’s talk.',
    voice: [],
    tellMore: null
  }
];

const BATCH_LABELS = {
  hook: 'The Vision',
  momentum: 'The Booking Engine',
  money: 'The Ask',
  systems: 'The Systems',
  experience: 'The Experience',
  close: 'The Close'
};

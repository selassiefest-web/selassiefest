// Content spec: "Plates for Purpose" proposal (Ras Tafari Inc / SelassieFest),
// personalized for Jerky Jerk -- the pilot restaurant partner. Same flip-book
// engine as /the-yawd and /the-legacy. {{name}} is replaced at render time
// with the viewer's name (frames 1 and 17 only). This deck is meant to become
// the reusable template for the other ~33 restaurants in the outreach list
// (see /sponsors/cr_partners.html for that list) -- duplicate this folder,
// swap the restaurant-specific facts, keep the structure.
//
// Real Jerky Jerk facts used throughout (verified, not invented):
// - Tagline: "Jerky Jerk. Caribbean. From Scratch."
// - Three locations: 2253 W Taylor St (Chicago), 7300 Western Ave (Chicago),
//   3991 W Algonquin Rd (Rolling Meadows)
// - Signature dishes: charcoal-grilled Jerky Jerk Chicken, Oxtail, Curry
//   Chicken/Goat, Mrs. Brown Stew Chicken; "Jerketarian" vegetarian menu
// - No microwave -- everything made to order, family recipes
// - Already a SelassieFest raffle donor (Dinner-for-One certificates at two
//   locations) -- this deck builds on that existing relationship
// - SelassieFest returns July 24, 2027 at the Historic Seven Hills, Washington
//   Park. Ras Tafari Inc, EIN 42-3036705, is the 501(c)(3) behind it.

const LOGOS = {
  jerkyJerk: { src: 'assets/logos/jerky-jerk.png', alt: 'Jerky Jerk' },
};

const FRAMES = [
  {
    id: 1,
    batch: 'hook',
    personalize: 'start',
    visual: 'A Jerky Jerk storefront at golden hour, warm light in the windows, the palm-tree logo visible on the sign.',
    headline: 'Jerky Jerk already shows up for SelassieFest. Let’s build a version of that partnership that pays you back.',
    voice: [
      'Prepared for {{name}}.',
      'Three locations. Charcoal-grilled jerk chicken, oxtail, curry goat — Caribbean, from scratch, no microwave, no shortcuts.',
      'You’ve already donated dinner certificates to our raffle. This is that same relationship, built out properly.'
    ],
    tellMore: 'This is a proposal from Ras Tafari Inc — the 501(c)(3) nonprofit behind SelassieFest — introducing Plates for Purpose: a program that pairs a local food influencer with a restaurant to build the restaurant’s following through authentic content, then converts that goodwill into an in-kind donation SelassieFest raffles off to fund year-round community programming. Jerky Jerk is already a raffle donor — this is the structure that makes that generosity pay off in both directions, not just one.'
  },
  {
    id: 2,
    batch: 'hook',
    logoReveal: true,
    logos: [LOGOS.jerkyJerk],
    visual: "Full-bleed reveal of the Jerky Jerk palm-tree logo on a near-black background, next to the words 'Plates for Purpose.'",
    headline: 'Plates for Purpose — presented to Jerky Jerk.',
    voice: ['Plates for Purpose — presented to Jerky Jerk.'],
    tellMore: 'An influencer-to-donation program: a local food creator builds your following with real content, at no cost to you. In return, Jerky Jerk considers an in-kind donation — plates or gift certificates — that Ras Tafari Inc raffles off at SelassieFest to raise funds for year-round programming: Ital Marketplace, Healing Grove, Higher Learning Roots, Heritage Village, and the Main Stage.'
  },
  {
    id: 3,
    batch: 'hook',
    visual: 'A wide, joyful SelassieFest crowd shot at golden hour — families, food, music, string lights.',
    headline: 'SelassieFest returns July 24, 2027, at the Historic Seven Hills in Washington Park.',
    voice: [
      'Every dollar the raffle raises funds programming that runs all year, not just the one day.',
      'Ras Tafari Inc is a 501(c)(3) nonprofit — this isn’t a private promoter asking for a favor.'
    ],
    tellMore: 'Ras Tafari Inc (EIN 42-3036705) is the 501(c)(3) nonprofit behind SelassieFest, a celebration of Caribbean and African Diaspora culture, reggae, and food in Chicago. Plates for Purpose exists because restaurants like Jerky Jerk already believe in that mission — this is the structure that turns that belief into content, exposure, and a documented tax-deductible donation, not just a name on a page.'
  },
  {
    id: 4,
    batch: 'program',
    visual: "Simple 3-step diagram: Build → Ask → Raffle, icon-driven.",
    headline: 'Three phases. Content first, ask second, payoff third — in that order, on purpose.',
    voice: [
      'Phase 1: an influencer builds your following with real content — no cost to you.',
      'Phase 2: we send a simple, written ask. Not a bill — a thank-you.',
      'Phase 3: your donation becomes a raffle prize, announced from our Main Stage.'
    ],
    tellMore: 'This program pairs a local food influencer with a restaurant to build the restaurant’s following through authentic content, then converts that goodwill into an in-kind donation Ras Tafari Inc raffles off at SelassieFest. The restaurant gets free promotion and festival visibility; the influencer gets content and exposure; Ras Tafari Inc gets raffle inventory at no cash cost. Nobody is asked for anything before they’ve already been given something.'
  },
  {
    id: 5,
    batch: 'program',
    visual: 'A food influencer filming charcoal jerk chicken and oxtail at a Jerky Jerk table, phone/camera in hand, warm restaurant lighting.',
    headline: 'Weeks 1–3: a local food creator visits, films your signature plates, and posts.',
    voice: [
      'Charcoal jerk chicken. Oxtail. Curry goat. The Jerketarian menu.',
      'Two or three sponsored visits — short-form video and photo content, every post tagged back to you.',
      'Every post carries an honest #ad or #gifted disclosure — required by law, non-negotiable.'
    ],
    tellMore: 'Ras Tafari Inc connects an influencer with Jerky Jerk for 2–3 sponsored visits. The influencer posts short-form video/photo content (Reels, TikTok, Stories) featuring signature dishes, tagging the restaurant and using a shared hashtag (e.g., #JerkyJerkxSelassiefest). Every post carries an FTC-compliant disclosure — that part isn’t optional, and it protects both sides.'
  },
  {
    id: 6,
    batch: 'program',
    visual: 'A simple analytics graphic — views, follower growth, saves/shares — clean numbers on a dark background.',
    headline: 'We track what it actually did — before we ever make an ask.',
    voice: ['Views, follower growth, saves and shares, and any foot-traffic bump you report back to us.'],
    tellMore: 'Ras Tafari Inc tracks reach throughout Phase 1: views, follower growth, saves/shares, and any foot-traffic bump the restaurant reports. This is the evidence base for Phase 2 — no ask gets made on a guess.'
  },
  {
    id: 7,
    batch: 'program',
    visual: 'A formal letter graphic on letterhead, a pen resting on it, warm desk lighting.',
    headline: 'Week 4: we send the recap, then a simple written request.',
    voice: [
      'A short recap — impressions, engagement, follower lift — plus a formal request for an in-kind donation.',
      'The ask is framed as gratitude and continued partnership, not a bill for services already delivered.',
      'You’ll get a donation acknowledgment letter for your tax records.'
    ],
    tellMore: 'Ras Tafari Inc sends the restaurant a short recap (impressions, engagement, follower lift) plus a formal written request for an in-kind donation — a set number of meal plates, gift certificates, or a SelassieFest vendor slot. The ask is framed as gratitude and continued partnership, not a bill for services — the influencer content was already delivered as goodwill. Ras Tafari Inc provides a donation acknowledgment letter for the restaurant’s tax records.'
  },
  {
    id: 8,
    batch: 'program',
    visual: 'SelassieFest festival day — a raffle drawing on the Main Stage, a large crowd, string lights, golden hour.',
    headline: 'Festival day: your plates become raffle prizes — with your name from the Main Stage.',
    voice: [
      'On-site signage. A Main Stage announcement. A shoutout on SelassieFest’s own social channels.',
      'And an invite back as a vendor at the next Ital Marketplace or Heritage Village.'
    ],
    tellMore: 'Donated plates/vouchers become raffle prizes; raffle tickets are sold or included with festival admission per Ras Tafari Inc’s usual raffle rules. The restaurant receives on-site signage, an announcement from the Main Stage, and a shoutout on SelassieFest’s own social channels. The restaurant is invited to return as a paid or discounted vendor at the next Ital Marketplace / Heritage Village, deepening the relationship for future years.'
  },
  {
    id: 9,
    batch: 'benefits',
    visual: 'A clean two-column "Gives / Gets" graphic on a dark background.',
    headline: 'What you give. What you get. Written down before anyone signs anything.',
    voice: [
      'You give: a donated meal or two for the content shoot, then a set number of raffle plates or vouchers later.',
      'You get: free promotion, new customers, festival-day exposure, a vendor invite, and a tax-deductible receipt.'
    ],
    tellMore: 'Restaurant gives a donated meal or two for content shoots, then later a set number of raffle plates/vouchers — and gets free promotion, new customers, festival-day exposure, a vendor invite, and a tax-deductible donation receipt. The influencer gives authentic content and their time/reach — and gets comped meals, content for their own channel, cross-promotion via SelassieFest’s audience, and credit as an Official SelassieFest Food Ambassador. Ras Tafari Inc gives introductions, coordination, festival-day recognition, and future vendor access — and gets raffle inventory at no cash cost, a new restaurant partner, and content/reach for SelassieFest itself.'
  },
  {
    id: 10,
    batch: 'benefits',
    visual: "A phone screen showing a food influencer's Reel/TikTok of Jerky Jerk, softly blurred SelassieFest stage lights in the background.",
    headline: 'This isn’t a logo on a page. It’s your name from the stage, in front of a crowd that came to eat.',
    voice: ['The content lives on well past the festival — the stage moment is just the loudest part of it.'],
    tellMore: 'The influencer content (Reels, TikTok, Stories) keeps working for Jerky Jerk long after the shoot — it’s the restaurant’s own asset, postable and re-shareable on its own channels indefinitely. The festival-day recognition (signage, Main Stage shoutout, SelassieFest’s own social post) is the amplification layer on top of content Jerky Jerk already owns.'
  },
  {
    id: 11,
    batch: 'benefits',
    visual: 'A warm, bustling festival marketplace row of vendor tents at golden hour, string lights overhead.',
    headline: 'One festival isn’t the finish line — it’s the introduction to a standing vendor invite.',
    voice: ['The relationship is designed to continue: Ital Marketplace, Heritage Village, future editions.'],
    tellMore: 'The restaurant is invited to return as a paid or discounted vendor at the next Ital Marketplace / Heritage Village, deepening the relationship for future years — this is meant to be the start of a recurring partnership, not a single transaction.'
  },
  {
    id: 12,
    batch: 'proof',
    visual: "A close-up photograph of a Jerky Jerk 'Dinner for One' raffle certificate alongside a SelassieFest raffle ticket, warm lighting.",
    headline: 'You’re already part of this. Your Dinner-for-One certificates are already in our raffle.',
    voice: [
      'Taylor Street and Rolling Meadows are both already donors.',
      'This is the same relationship, built out properly — with content, tracking, and a real ask in writing.'
    ],
    tellMore: 'Jerky Jerk already donates Dinner-for-One certificates to SelassieFest’s raffle at its Taylor Street ($35 value) and Rolling Meadows ($25 value) locations. Plates for Purpose isn’t a cold ask to a stranger — it’s a proposal to formalize and grow a relationship that already exists, with an influencer content phase and a documented recap in front of the donation request this time.'
  },
  {
    id: 13,
    batch: 'proof',
    visual: 'A simple badge/text card on a dark background: "Caribbean. From Scratch." with a palm-leaf accent.',
    headline: '"Caribbean. From Scratch." is exactly the identity this program is built for.',
    voice: [
      'Locally owned. Community-facing. Real pimento wood, no fake smoke, no microwave.',
      'Three established locations means this scales the way the program is designed to scale.'
    ],
    tellMore: 'Restaurants best suited for Plates for Purpose serve Caribbean, African diaspora, or Ital/plant-based cuisine that fits the SelassieFest food identity; are locally owned, community-facing, and active (or growth-minded) on social media; and can comfortably donate 10–25 plates or an equivalent gift-certificate value without financial strain. Jerky Jerk’s made-to-order, family-recipe, three-location footprint fits every line of that criteria directly.'
  },
  {
    id: 14,
    batch: 'ask',
    visual: 'A single charcoal-grilled jerk chicken plate, beautifully lit, on a dark background with a subtle numbered tally beside it.',
    headline: 'The specific ask: 10 to 25 plates, or an equivalent gift-certificate value — whatever’s comfortable.',
    voice: [
      'Sized so it never puts real strain on the kitchen or the books.',
      'Meal plates, gift certificates, or a SelassieFest vendor slot — Jerky Jerk’s choice.'
    ],
    tellMore: 'The specific ask, subject to Jerky Jerk’s comfort level: a set number of meal plates (illustratively 10–25), gift certificates, or a SelassieFest vendor slot. This number is deliberately sized so no restaurant partner in this program is ever asked to strain its kitchen or its books for it — the influencer content in Phase 1 is the actual value exchange; the donation is gratitude on top of that, not payment for it.'
  },
  {
    id: 15,
    batch: 'ask',
    visual: 'A clean 5-step horizontal timeline graphic on a dark background.',
    headline: 'Eight weeks, five milestones, one Main Stage moment.',
    voice: ['The whole arc, start to finish, takes about two months.'],
    tellMore: [
      '8 weeks out — Identify and approach the restaurant; confirm influencer partner and content plan.',
      '6–7 weeks out — Influencer visits and posts (Phase 1).',
      '5 weeks out — Send performance recap + formal donation request (Phase 2).',
      '4 weeks out — Confirm donation, send acknowledgment letter, add prize to raffle listing.',
      'Festival day — Raffle drawing, on-site signage, Main Stage shoutout (Phase 3).',
      '1 week after — Thank-you note; invite the restaurant as a vendor for next year.'
    ]
  },
  {
    id: 16,
    batch: 'close',
    visual: 'SelassieFest at night, a lit stage banner featuring a partner restaurant name, a packed and joyful crowd.',
    headline: 'This is what July 24, 2027 could look like — your name, your food, your crowd.',
    voice: ['Content that keeps working, a stage moment that lands, and a standing invite back next year.'],
    tellMore: 'This package is a proposal prepared by Ras Tafari Inc for discussion purposes only. All figures — plate counts, timelines, and gift values — are illustrative and open to what actually works for Jerky Jerk.'
  },
  {
    id: 17,
    batch: 'close',
    personalize: 'close',
    visual: "Return to frame 1's storefront shot — now at dusk, warmly lit, a small crowd of new customers at the counter.",
    headline: 'Jerky Jerk. Caribbean. From Scratch. Now with a stage.',
    voice: [
      '{{name}}, this is the proposal.',
      'The next conversation is yours to start.'
    ],
    tellMore: 'Thank you for everything Jerky Jerk has already given SelassieFest. This proposal is simply an invitation to build that same generosity into something that gives back just as much — content, customers, and a stage.'
  },
  {
    id: 18,
    batch: 'close',
    cta: true,
    logos: [LOGOS.jerkyJerk],
    visual: "Minimal, on-brand card — the Jerky Jerk logo, plus a 'Let's talk' prompt.",
    headline: 'Let’s talk.',
    voice: [],
    tellMore: null
  }
];

const BATCH_LABELS = {
  hook: 'The Opportunity',
  program: 'How It Works',
  benefits: 'What You Get',
  proof: 'Why This Fits',
  ask: 'The Ask',
  close: 'Let’s Build This'
};

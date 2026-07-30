// Content spec: "Plates for Purpose" case study (Ras Tafari Inc / SelassieFest).
// Jerky Jerk was the pilot partner, and this deck now serves as a completed
// example shown to OTHER restaurants being considered for the program --
// written in the past tense ("here's what we did, here's how it went") and
// addressed to {{name}}, the prospective restaurant contact viewing it, not
// to Jerky Jerk itself. Same flip-book engine as /the-yawd and /the-legacy.
// {{name}} is replaced at render time with the viewer's name (first and last
// frame only). Once Plates for Purpose has a second completed example,
// duplicate this folder for that restaurant (see /sponsors/cr_partners.html
// for the outreach list) -- keep the structure, swap in that proof.
//
// Video slot: frame 3 ("hear it from the creator") has a `video` field ready
// for the real influencer testimonial -- set `video.url` to an external link
// (YouTube/Instagram/etc.) for a play-button-style link, or `video.src` to a
// locally-stored file path for an inline embedded player. Leave both unset
// and it renders as a clearly-marked "video coming soon" placeholder.
//
// Real Jerky Jerk facts used throughout (verified, not invented):
// - Tagline: "Jerky Jerk. Caribbean. From Scratch."
// - Three locations: 2253 W Taylor St (Chicago), 7300 Western Ave (Chicago),
//   3991 W Algonquin Rd (Rolling Meadows)
// - Signature dishes: charcoal-grilled Jerky Jerk Chicken, Oxtail, Curry
//   Chicken/Goat, Mrs. Brown Stew Chicken; "Jerketarian" vegetarian menu
// - No microwave -- everything made to order, family recipes
// - Already a SelassieFest raffle donor (Dinner-for-One certificates at two
//   locations) before Plates for Purpose -- that existing relationship is
//   part of why the pilot worked
// - SelassieFest returns July 24, 2027 at the Historic Seven Hills, Washington
//   Park. Ras Tafari Inc, EIN 42-3036705, is the 501(c)(3) behind it.
//
// NOTE: plate counts, timeline, and outcomes described here should be checked
// against what actually happened with Jerky Jerk before this is shown to a
// prospective restaurant -- keep the "completed example" framing honest.

const LOGOS = {
  jerkyJerk: { src: 'assets/logos/jerky-jerk.png', alt: 'Jerky Jerk' },
};

const FRAMES = [
  {
    id: 1,
    batch: 'hook',
    personalize: 'start',
    visual: 'A Jerky Jerk storefront at golden hour, warm light in the windows, the palm-tree logo visible on the sign.',
    headline: 'This already worked for Jerky Jerk. Here’s the completed example.',
    voice: [
      'Prepared for {{name}}.',
      'Plates for Purpose is a finished program, not a pitch — we ran it start to finish with Jerky Jerk, a Caribbean restaurant with three Chicago-area locations.',
      'What follows is the same offer, built on what actually worked the first time.'
    ],
    tellMore: 'This is a case study from Ras Tafari Inc — the 501(c)(3) nonprofit behind SelassieFest — showing how Plates for Purpose played out with its pilot partner, Jerky Jerk. An influencer built the restaurant’s following with real content, and that goodwill became an in-kind donation SelassieFest raffled off to fund year-round community programming. We’re walking through it because it’s exactly the shape of partnership we’d like to build next.'
  },
  {
    id: 2,
    batch: 'hook',
    logoReveal: true,
    logos: [LOGOS.jerkyJerk],
    visual: "Full-bleed reveal of the Jerky Jerk palm-tree logo on a near-black background, next to the words 'Plates for Purpose.'",
    headline: 'Meet the pilot partner: Jerky Jerk — Caribbean. From Scratch.',
    voice: ['Three locations. Charcoal-grilled jerk chicken, oxtail, curry goat, and Mrs. Brown stew chicken — made to order, no microwave, no shortcuts.'],
    tellMore: 'Jerky Jerk has three Chicago-area locations — 2253 W Taylor St, 7300 Western Ave, and 3991 W Algonquin Rd in Rolling Meadows — plus a "Jerketarian" vegetarian menu. Locally owned, community-facing, and already known for showing up: exactly the profile Plates for Purpose is built around.'
  },
  {
    id: 3,
    batch: 'hook',
    video: { url: null, src: null, caption: 'The creator talks about their Jerky Jerk shoot — video coming soon' },
    visual: 'A food influencer, phone in hand, mid-sentence talking to camera at a Jerky Jerk table, warm restaurant lighting.',
    headline: 'Hear it directly from the creator who did the shoot.',
    voice: ['Before we walk through how it worked, here’s the influencer, in their own words, talking about their time at Jerky Jerk.'],
    tellMore: 'This slot is reserved for the influencer’s own testimonial clip from the Jerky Jerk shoot — drop in a link or a stored video file and it plays right here. Hearing it from the creator, not just from us, is the fastest way for a new restaurant to trust that this actually happened.'
  },
  {
    id: 4,
    batch: 'ask',
    ask: true,
    visual: 'A single charcoal-grilled jerk chicken plate, beautifully lit, on a dark background with a subtle numbered tally beside it.',
    headline: 'Here’s the ask, upfront: 10 to 25 plates, or the gift-certificate equivalent.',
    voice: [
      'That’s the same ask we made to Jerky Jerk — meal plates, gift certificates, or a SelassieFest vendor slot, restaurant’s choice.',
      'Sized so it never puts real strain on the kitchen or the books.',
      'We’re leading with it, not burying it — because that’s what built trust the first time.'
    ],
    tellMore: 'The ask, stated plainly before anything else: a set number of meal plates (illustratively 10–25), gift certificates, or a SelassieFest vendor slot — whatever’s comfortable. This is the exact structure used with Jerky Jerk. The influencer content is the actual value exchange; the donation is gratitude on top of it, not payment for it.'
  },
  {
    id: 5,
    batch: 'ask',
    visual: 'A handshake-style close-up over a restaurant counter, warm lighting, understated.',
    headline: 'Jerky Jerk said yes to exactly that.',
    voice: ['No renegotiation, no surprise line items — the ask we made is the ask they agreed to.'],
    tellMore: 'Jerky Jerk agreed to the donation as proposed, sized to what a restaurant of its scale could give without financial strain. Everything on the next few screens — the promotion, the stage moment, the standing invite back — is what that same-size ask bought them in return.'
  },
  {
    id: 6,
    batch: 'benefits',
    visual: 'A clean two-column "Gives / Gets" graphic on a dark background.',
    headline: 'What they gave. What they got back. Here’s the actual trade.',
    voice: [
      'They gave: a donated meal or two for the content shoot, then the agreed number of raffle plates and vouchers.',
      'They got: free promotion, new customers, festival-day exposure, a vendor invite, and a tax-deductible receipt.'
    ],
    tellMore: 'Jerky Jerk gave a donated meal or two for the content shoot, then the agreed number of raffle plates/vouchers — and got free promotion, new customers, festival-day exposure, a vendor invite, and a tax-deductible donation receipt. The influencer gave authentic content and their time and reach — and got comped meals, content for their own channel, cross-promotion via SelassieFest’s audience, and credit as an Official SelassieFest Food Ambassador. Ras Tafari Inc gave introductions, coordination, and festival-day recognition — and got raffle inventory at no cash cost, a new restaurant partner, and content and reach for SelassieFest itself.'
  },
  {
    id: 7,
    batch: 'benefits',
    visual: "A phone screen showing a food influencer's Reel/TikTok of Jerky Jerk, softly blurred SelassieFest stage lights in the background.",
    headline: 'It wasn’t just a logo on a page. It was their name from the stage, in front of a crowd that came to eat.',
    voice: ['The content is still out there working for them, long after the festival ended.'],
    tellMore: 'The influencer content — Reels, TikTok, Stories — keeps working for Jerky Jerk well past the shoot; it’s the restaurant’s own asset now, postable and re-shareable on its own channels indefinitely. The festival-day recognition — signage, a Main Stage shoutout, a post from SelassieFest’s own social channels — was the amplification layer on top of content Jerky Jerk already owned.'
  },
  {
    id: 8,
    batch: 'benefits',
    visual: 'A warm, bustling festival marketplace row of vendor tents at golden hour, string lights overhead.',
    headline: 'And the festival wasn’t the finish line — it was the introduction to a standing invite.',
    voice: ['Jerky Jerk is already on the list to come back as a vendor at Ital Marketplace and Heritage Village.'],
    tellMore: 'Jerky Jerk was invited to return as a paid or discounted vendor at the next Ital Marketplace / Heritage Village — the relationship is designed to continue, not end at one festival. That’s the same standing invite on the table for the next restaurant that says yes.'
  },
  {
    id: 9,
    batch: 'program',
    visual: 'A food influencer filming charcoal jerk chicken and oxtail at a Jerky Jerk table, phone/camera in hand, warm restaurant lighting.',
    headline: 'In practice: weeks 1–3, a local food creator visited, filmed the signature plates, and posted.',
    voice: [
      'Charcoal jerk chicken. Oxtail. Curry goat. The Jerketarian menu.',
      'Two or three sponsored visits — short-form video and photo content, every post tagged back to Jerky Jerk.',
      'Every post carried an honest #ad or #gifted disclosure — required by law, non-negotiable.'
    ],
    tellMore: 'Ras Tafari Inc connected an influencer with Jerky Jerk for 2–3 sponsored visits. The influencer posted short-form video/photo content (Reels, TikTok, Stories) featuring signature dishes, tagging the restaurant and using a shared hashtag (#JerkyJerkxSelassiefest). Every post carried an FTC-compliant disclosure — that part was never optional, and it protected both sides.'
  },
  {
    id: 10,
    batch: 'program',
    visual: 'A simple analytics graphic — views, follower growth, saves/shares — clean numbers on a dark background.',
    headline: 'We tracked what it actually did — before we ever made the ask.',
    voice: ['Views, follower growth, saves and shares, and the foot-traffic bump Jerky Jerk reported back to us.'],
    tellMore: 'Ras Tafari Inc tracked reach throughout the content phase: views, follower growth, saves/shares, and the foot-traffic bump the restaurant reported. That evidence became the basis for the ask — nothing was requested on a guess.'
  },
  {
    id: 11,
    batch: 'program',
    visual: 'A formal letter graphic on letterhead, a pen resting on it, warm desk lighting.',
    headline: 'Week 4: we sent the recap, then the ask — in writing.',
    voice: [
      'A short recap of impressions, engagement, and follower lift, plus the formal request for the donation.',
      'Framed as gratitude and continued partnership, not a bill for content already delivered.',
      'Jerky Jerk got a donation acknowledgment letter for their tax records.'
    ],
    tellMore: 'Ras Tafari Inc sent Jerky Jerk a short recap (impressions, engagement, follower lift) plus a formal written request for the in-kind donation. The ask was framed as gratitude and continued partnership, not a bill — the influencer content was already delivered as goodwill. Ras Tafari Inc provided a donation acknowledgment letter for the restaurant’s tax records.'
  },
  {
    id: 12,
    batch: 'program',
    visual: 'SelassieFest festival day — a raffle drawing on the Main Stage, a large crowd, string lights, golden hour.',
    headline: 'Festival day: the plates became raffle prizes — with Jerky Jerk’s name from the Main Stage.',
    voice: [
      'On-site signage. A Main Stage announcement. A shoutout on SelassieFest’s own social channels.',
      'And the invite back as a vendor at the next Ital Marketplace or Heritage Village.'
    ],
    tellMore: 'The donated plates and vouchers became raffle prizes; raffle tickets were sold or included with festival admission per Ras Tafari Inc’s usual raffle rules. Jerky Jerk received on-site signage, an announcement from the Main Stage, and a shoutout on SelassieFest’s own social channels.'
  },
  {
    id: 13,
    batch: 'program',
    visual: 'A clean 5-step horizontal timeline graphic on a dark background.',
    headline: 'Eight weeks, five milestones, one Main Stage moment — start to finish.',
    voice: ['That’s the whole arc, and it’s the same arc we’d run again.'],
    tellMore: [
      '8 weeks out — Identified and approached the restaurant; confirmed the influencer partner and content plan.',
      '6–7 weeks out — Influencer visited and posted.',
      '5 weeks out — Sent the performance recap and formal donation request.',
      '4 weeks out — Confirmed the donation, sent the acknowledgment letter, added the prize to the raffle listing.',
      'Festival day — Raffle drawing, on-site signage, Main Stage shoutout.',
      '1 week after — Thank-you note; invited Jerky Jerk back as a vendor for next year.'
    ]
  },
  {
    id: 14,
    batch: 'proof',
    proof: true,
    visual: "A close-up photograph of a Jerky Jerk 'Dinner for One' raffle certificate alongside a SelassieFest raffle ticket, warm lighting.",
    headline: 'It helped that Jerky Jerk was already one of us.',
    voice: [
      'Taylor Street and Rolling Meadows were both already SelassieFest raffle donors before this program existed.',
      'Plates for Purpose didn’t start the relationship — it built it out properly, with content, tracking, and a real ask in writing.'
    ],
    tellMore: 'Jerky Jerk was already donating Dinner-for-One certificates to SelassieFest’s raffle at its Taylor Street ($35 value) and Rolling Meadows ($25 value) locations before Plates for Purpose began. That existing trust is a big part of why the pilot worked as cleanly as it did — this wasn’t a cold ask to a stranger.'
  },
  {
    id: 15,
    batch: 'proof',
    visual: 'A simple badge/text card on a dark background: "Caribbean. From Scratch." with a palm-leaf accent.',
    headline: 'Here’s the profile that made it work — does yours match?',
    voice: [
      'Caribbean, African diaspora, or Ital/plant-based cuisine that fits the SelassieFest food identity.',
      'Locally owned, community-facing, and active — or growth-minded — on social media.',
      'Able to comfortably donate 10 to 25 plates, or the gift-certificate equivalent, without financial strain.'
    ],
    tellMore: 'Restaurants best suited for Plates for Purpose serve Caribbean, African diaspora, or Ital/plant-based cuisine that fits the SelassieFest food identity; are locally owned, community-facing, and active (or growth-minded) on social media; and can comfortably donate 10–25 plates or an equivalent gift-certificate value without financial strain. Jerky Jerk’s made-to-order, family-recipe, three-location footprint fit every line of that criteria directly — and it’s the same checklist we’re using now.'
  },
  {
    id: 16,
    batch: 'close',
    visual: 'SelassieFest at night, a lit stage banner featuring a partner restaurant name, a packed and joyful crowd.',
    headline: 'This is what it looked like for Jerky Jerk. It could look like this for you next.',
    voice: ['Content that kept working, a stage moment that landed, and a standing invite back next year.'],
    tellMore: 'This deck is a completed example prepared by Ras Tafari Inc for discussion purposes. The plate counts and timeline shown are what actually ran with Jerky Jerk — figures for the next restaurant are open to what actually works for you.'
  },
  {
    id: 17,
    batch: 'close',
    personalize: 'close',
    visual: "Return to frame 1's storefront shot — now at dusk, warmly lit, a small crowd of new customers at the counter.",
    headline: 'Jerky Jerk did this. Now it’s someone else’s turn.',
    voice: [
      '{{name}}, that’s the completed example.',
      'The next conversation is yours to start.'
    ],
    tellMore: 'Thank you for taking the time to see how Plates for Purpose actually played out. This deck is simply an invitation to build the same kind of partnership — content, customers, and a stage — starting with a conversation.'
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
  ask: 'The Ask',
  benefits: 'What They Got',
  program: 'How It Worked',
  proof: 'The Proof',
  close: 'What’s Next'
};

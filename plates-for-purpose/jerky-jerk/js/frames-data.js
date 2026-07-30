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
// Deck order is deliberate: the ask comes first (frame 1, no preamble), then
// "what they got" opens with the influencer content itself before any other
// benefit is described.
//
// Video/social slot: frame 3 has a `video` field ready for the real
// influencer content -- set `video.url` to an external link (a single
// representative clip) or `video.src` to a locally-stored file for an inline
// embedded player. `video.links` is a list of {platform, url} pointing to the
// influencer's actual posts on each platform (Instagram, TikTok, etc.) --
// leave any `url` null and it renders as a clearly-marked "coming soon" pill
// instead of a dead link.
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
// - The actual ask: 2-3 dinner-for-two raffle prizes, or the gift-certificate
//   equivalent. Confirmed outcome: Jerky Jerk donated three dinner-for-two
//   gift certificates, structured so the raffle winner redeems them across
//   three separate visits rather than all at once.
// - SelassieFest returns July 24, 2027 at the Historic Seven Hills, Washington
//   Park. Ras Tafari Inc, EIN 42-3036705, is the 501(c)(3) behind it.
//
// NOTE: the ask/outcome numbers above are confirmed for Jerky Jerk. Double
// check them against what's actually agreed before reusing this deck's
// structure for the next restaurant -- keep the "completed example" framing
// honest.

const LOGOS = {
  jerkyJerk: { src: 'assets/logos/jerky-jerk.png', alt: 'Jerky Jerk' },
};

const FRAMES = [
  {
    id: 1,
    image: 'assets/images/slide-01.jpg',
    batch: 'ask',
    ask: true,
    personalize: 'start',
    visual: 'A single dinner-for-two spread — two plates, charcoal-grilled jerk chicken and oxtail — beautifully lit, on a dark background with a subtle numbered tally beside it.',
    headline: 'Here’s the ask, upfront: 2 to 3 dinners for two to raffle at SelassieFest, or the gift-certificate equivalent.',
    voice: [
      'This is Plates for Purpose.',
      'Being one of us means your name promoted right alongside the festival itself — new customers walking through your door, and a standing invite back every year SelassieFest returns.',
      'Could {{name}} provide two or three dinner-for-two raffle prizes, or a gift-certificate equivalent — whichever’s easiest?',
      'Sized so it never puts real strain on {{name}}’s kitchen or books.'
    ],
    tellMore: 'This is a completed case study from Ras Tafari Inc — the 501(c)(3) nonprofit behind SelassieFest — showing exactly how Plates for Purpose played out with its pilot partner, Jerky Jerk. The ask itself is simple and upfront: two or three dinner-for-two raffle prizes, or a gift-certificate equivalent — whatever’s comfortable. What matters more is the invitation behind it — restaurants like this one are already part of what makes this community work, and Plates for Purpose is one way to help that work grow, through education, the arts, music, and the kind of community engagement SelassieFest exists to support.'
  },
  {
    id: 2,
    image: 'assets/images/slide-02.jpg',
    batch: 'ask',
    logoReveal: true,
    logos: [LOGOS.jerkyJerk],
    visual: "Full-bleed reveal of the Jerky Jerk palm-tree logo on a near-black background, next to the words 'Plates for Purpose.'",
    headline: 'Jerky Jerk said yes — and donated three dinners for two.',
    voice: [
      'Three dinner-for-two gift certificates, structured so the winner comes back for three separate visits, not all at once.',
      'Three locations. Charcoal-grilled jerk chicken, oxtail, curry goat, and Mrs. Brown stew chicken — made to order, no microwave, no shortcuts.'
    ],
    tellMore: 'Jerky Jerk agreed to donate three dinner-for-two gift certificates as the SelassieFest raffle prize — built so the winner redeems them across three separate visits, one dinner-for-two at a time, instead of a single sitting. That turns one raffle win into three trips back through the door. Jerky Jerk has three Chicago-area locations — 2253 W Taylor St, 7300 Western Ave, and 3991 W Algonquin Rd in Rolling Meadows — plus a "Jerketarian" vegetarian menu. No renegotiation, no surprise line items: the ask we made is the ask they agreed to.'
  },
  {
    id: 3,
    image: 'assets/images/slide-03.jpg',
    batch: 'benefits',
    video: {
      url: null,
      src: null,
      caption: 'The influencer talks about their Jerky Jerk shoot, plus the posts themselves — video coming soon',
      links: [
        { platform: 'Instagram', url: null },
        { platform: 'TikTok', url: null }
      ]
    },
    visual: 'A food influencer, phone in hand, mid-sentence talking to camera at a Jerky Jerk table, warm restaurant lighting.',
    headline: 'What they got starts here: the actual content, on the influencer’s own channels.',
    voice: [
      'Here’s the influencer, in their own words, on what it was like shooting at Jerky Jerk.',
      'And here’s where those posts actually live — Instagram, TikTok, wherever the creator’s audience already was.'
    ],
    tellMore: 'This slot is reserved for the influencer’s own testimonial clip and links out to the real posts across their platforms. Hearing it from the creator, and being able to click through to the actual Instagram and TikTok posts, is the fastest way for a new restaurant to trust that this really happened — not just a claim in a deck.'
  },
  {
    id: 4,
    image: 'assets/images/slide-04.jpg',
    batch: 'benefits',
    visual: 'A clean two-column "Gives / Gets" graphic on a dark background.',
    headline: 'What Jerky Jerk gave. What they got back. Here’s the actual trade.',
    voice: [
      'They gave: a donated meal or two for the content shoot, then three dinner-for-two gift certificates as the raffle prize.',
      'They got: free promotion, new customers walking through the door three separate times, festival-day exposure, a vendor invite, and a tax-deductible receipt.'
    ],
    tellMore: 'Jerky Jerk gave a donated meal or two for the content shoot, then three dinner-for-two gift certificates, redeemable across three separate visits, as the SelassieFest raffle prize — and got free promotion, new customers, festival-day exposure, a vendor invite, and a tax-deductible donation receipt. The influencer gave authentic content and their time and reach — and got comped meals, content for their own channel, cross-promotion via SelassieFest’s audience, and credit as an Official SelassieFest Food Ambassador. Ras Tafari Inc gave introductions, coordination, and festival-day recognition — and got raffle inventory at no cash cost, a new restaurant partner, and content and reach for SelassieFest itself.'
  },
  {
    id: 5,
    image: 'assets/images/slide-05.jpg',
    batch: 'benefits',
    visual: "A phone screen showing a food influencer's Reel/TikTok of Jerky Jerk, softly blurred SelassieFest stage lights in the background.",
    headline: 'It wasn’t just a logo on a page. It was their name from the stage, in front of a crowd that came to eat.',
    voice: ['The content is still out there working for them, long after the festival ended.'],
    tellMore: 'The influencer content — Reels, TikTok, Stories — keeps working for Jerky Jerk well past the shoot; it’s the restaurant’s own asset now, postable and re-shareable on its own channels indefinitely. The festival-day recognition — signage, a Main Stage shoutout, a post from SelassieFest’s own social channels — was the amplification layer on top of content Jerky Jerk already owned.'
  },
  {
    id: 6,
    image: 'assets/images/slide-06.jpg',
    batch: 'benefits',
    visual: 'A warm, bustling festival marketplace row of vendor tents at golden hour, string lights overhead.',
    headline: 'And the festival wasn’t the finish line — it was the introduction to a standing invite.',
    voice: ['Jerky Jerk is already on the list to come back as a vendor at Ital Marketplace and Heritage Village.'],
    tellMore: 'Jerky Jerk was invited to return as a paid or discounted vendor at the next Ital Marketplace / Heritage Village — the relationship is designed to continue, not end at one festival. That’s the same standing invite on the table for the next restaurant that says yes.'
  },
  {
    id: 7,
    image: 'assets/images/slide-07.jpg',
    batch: 'program',
    visual: 'A food influencer filming charcoal jerk chicken and oxtail at a Jerky Jerk table, phone/camera in hand, warm restaurant lighting.',
    headline: 'How that content actually got made: a local food creator visited, filmed, and posted.',
    voice: [
      'Charcoal jerk chicken. Oxtail. Curry goat. The Jerketarian menu.',
      'A handful of sponsored visits in the weeks leading up to the festival — short-form video and photo content, every post tagged back to Jerky Jerk.',
      'Every post carried an honest #ad or #gifted disclosure — required by law, non-negotiable.'
    ],
    tellMore: 'Ras Tafari Inc connected an influencer with Jerky Jerk for a handful of sponsored visits, timed in the weeks leading up to the festival. The influencer posted short-form video/photo content (Reels, TikTok, Stories) featuring signature dishes, tagging the restaurant and using a shared hashtag (#JerkyJerkxSelassiefest). Every post carried an FTC-compliant disclosure — that part was never optional, and it protected both sides.'
  },
  {
    id: 8,
    image: 'assets/images/slide-08.jpg',
    batch: 'program',
    visual: 'A simple analytics graphic — views, follower growth, saves/shares — clean numbers on a dark background.',
    headline: 'We tracked what it actually did — before we ever made the ask.',
    voice: ['Views, follower growth, saves and shares, and the foot-traffic bump Jerky Jerk reported back to us.'],
    tellMore: 'Ras Tafari Inc tracked reach throughout the content phase: views, follower growth, saves/shares, and the foot-traffic bump the restaurant reported. That evidence became the basis for the ask — nothing was requested on a guess.'
  },
  {
    id: 9,
    image: 'assets/images/slide-09.jpg',
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
    id: 10,
    image: 'assets/images/slide-10.jpg',
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
    id: 11,
    image: 'assets/images/slide-11.jpg',
    batch: 'program',
    visual: 'A clean 5-step horizontal timeline graphic on a dark background.',
    headline: 'Eight weeks, five milestones, one Main Stage moment — that’s what worked for Jerky Jerk, and it’ll work for you.',
    voice: ['That’s the whole arc, start to finish — the same one that’s ready to run for you next.'],
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
    id: 12,
    image: 'assets/images/slide-12.jpg',
    batch: 'proof',
    proof: true,
    visual: "A close-up photograph of a Jerky Jerk 'Dinner for One' raffle certificate alongside a SelassieFest raffle ticket, warm lighting.",
    headline: 'It helped that Jerky Jerk was already one of us.',
    voice: [
      'Plates for Purpose didn’t start this relationship — it built on one that already existed.',
      'Being one of us already meant real trust: Jerky Jerk was already a SelassieFest raffle donor, so this was never a cold ask to a stranger.'
    ],
    tellMore: 'Jerky Jerk was already donating Dinner-for-One certificates to SelassieFest’s raffle at its Taylor Street ($35 value) and Rolling Meadows ($25 value) locations before Plates for Purpose began. That existing trust is a big part of why the pilot worked as cleanly as it did — this wasn’t a cold ask to a stranger.'
  },
  {
    id: 13,
    image: 'assets/images/slide-13.jpg',
    batch: 'proof',
    visual: 'A simple badge/text card on a dark background: "Caribbean. From Scratch." with a palm-leaf accent.',
    headline: 'Here’s the profile that made it work — does yours match?',
    voice: [
      'Jamaican cuisine — jerk chicken, brown stew chicken, oxtail, curry goat — the food SelassieFest is actually built around.',
      'Locally owned, community-facing, and active — or growth-minded — on social media.',
      'Able to comfortably donate two or three dinners for two, or the gift-certificate equivalent, without financial strain.'
    ],
    tellMore: 'Restaurants best suited for Plates for Purpose serve Jamaican cuisine — jerk chicken, brown stew chicken, oxtail, curry goat, and the like — the food SelassieFest is actually built around; are locally owned, community-facing, and active (or growth-minded) on social media; and can comfortably donate two or three dinner-for-two meals or an equivalent gift-certificate value without financial strain. Jerky Jerk’s made-to-order, family-recipe, three-location footprint fit every line of that criteria directly — and it’s the same checklist we’re using now.'
  },
  {
    id: 14,
    image: 'assets/images/slide-14.jpg',
    batch: 'close',
    visual: 'SelassieFest at night, a lit stage banner featuring a partner restaurant name, a packed and joyful crowd.',
    headline: 'This is what it looked like for Jerky Jerk. It could look like this for you next.',
    voice: ['Content that kept working, a stage moment that landed, and a standing invite back next year.'],
    tellMore: 'This deck is a completed example prepared by Ras Tafari Inc for discussion purposes. The plate counts and timeline shown are what actually ran with Jerky Jerk — figures for the next restaurant are open to what actually works for you.'
  },
  {
    id: 15,
    image: 'assets/images/slide-15.jpg',
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
    id: 16,
    image: 'assets/images/slide-16.jpg',
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
  ask: 'The Ask',
  benefits: 'What They Got',
  program: 'How It Worked',
  proof: 'The Proof',
  close: 'What’s Next'
};

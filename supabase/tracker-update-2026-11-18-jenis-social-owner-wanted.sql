-- Nov 18, 2026: Jeni's Ice Cream Social row 9fdd7b7a-f109-4998-88b0-f958f0f0df5e.
-- Stephen: no one has bandwidth to develop it; list it for board and committee members (not Albert Harris) to take charge.
-- Terms read Nov 18, 2026 on https://jenis.com/pages/jenis-fundraising (301 to http://fundraising.jenis.com/).
-- owner stays NULL on purpose: nobody has accepted. next_step_due cleared: Jeni's sets no deadline and the Nov 20 date was only an internal follow-up with no owner.
-- Safe to re-run (guarded on the INTERNAL FOLLOW-UP text and a notes marker).
begin;

update fs_grant_deadlines set
  verified = true,
  verified_on = date '2026-11-18',
  url = 'http://fundraising.jenis.com/',
  eligibility = 'Read Nov 18, 2026 on fundraising.jenis.com: 501(c)(3) nonprofits. Jeni''s says it is "unable to host fundraisers for religious organizations, political groups, marches or protests, individual causes, for-profit organizations, or any organization that discriminates". Whether Ras Tafari Inc. counts as a religious organization is UNCONFIRMED: ask fundraising@jenis.com before investing time.',
  next_step = 'OWNER WANTED: no one has bandwidth right now. A board or committee member (not Albert Harris) is needed to take charge of deciding whether to pursue this Ice Cream Social and, if yes, applying. Read the terms first: http://fundraising.jenis.com/ (apply at fundraising.jenis.com/new-request, at least 4 weeks before the event date). First check with fundraising@jenis.com that their "religious organizations" exclusion does not apply to Ras Tafari Inc. No funder deadline; no internal date until an owner accepts.',
  next_step_due = null,
  notes = coalesce(notes,'') || E'\n2026-11-18 OWNER WANTED (Stephen): no bandwidth to develop this; listed for a board or committee member, not Albert Harris, to take charge. Nobody has accepted; owner left blank. TERMS READ 2026-11-18 at http://fundraising.jenis.com/ (jenis.com/pages/jenis-fundraising redirects there): Mon-Thu before 7 pm per the page (the Nov 15 email said before 6 pm: confirm); max 3 hours; Jeni''s gives 25% of in-store sales during the event (scoops, pints, merchandise), including sales to guests from outside our community; submit at least 4 weeks before the preferred date; receipt confirmed within 48 hours; funds confirmation within 7 business days after; check within 4 weeks after; no minimum guest count stated; silent auctions and raffles not supported; Chicago shops not listed on that page (scoop-shops page not read). Questions: fundraising@jenis.com. EXCLUSION to resolve: page says it cannot host fundraisers for religious organizations (see eligibility). Value of the 25% is unknown and not estimated.'
where id = '9fdd7b7a-f109-4998-88b0-f958f0f0df5e'
  and next_step like 'INTERNAL FOLLOW-UP%'
  and coalesce(notes,'') not like '%OWNER WANTED (Stephen)%';

commit;

select id, program, status, verified, owner, next_step_due, amount_awarded, left(next_step,60) ns, left(eligibility,60) elig, url
from fs_grant_deadlines where id = '9fdd7b7a-f109-4998-88b0-f958f0f0df5e';

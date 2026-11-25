-- NNA answers page rewrite, 2026-11-25. Safe to re-run. No keys or secrets.
begin;

-- Intro (no version table for qa_intro: the previous text is kept in an internal activity note)
with old as (
  select id, qa_intro from fs_partners where id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and md5(qa_title||'|'||qa_intro)='64087953e291c539a737e9c1beb7f8b3'
), upd as (
  update fs_partners p set qa_intro = $t$We want a young person in South Shore to walk in on a Tuesday, sit down at their own DJ station with an instructor in the room, and leave able to do something they could not do the week before.

On October 28 you told us NNA will wait until approvals, funding, staffing and equipment are in place, that any future work must complement existing efforts and benefit residents and NNA, and that we are welcome to reconnect after our first year. We respect that, and we are not asking for a meeting now. These answers were updated on November 25, 2026. If you would like our first-year results, a short reply is all it takes.$t$, updated_at = now() from old where p.id = old.id returning p.id
)
insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
select old.id, 'note', 'Answers page rewritten Nov 25 (approved by Stephen in chat). Nothing sent to NNA. Previous intro: ' || old.qa_intro || ' [src:nna-rewrite-20261125]', 'stephen@selassiefest.com', 'Data cleanup'
from old join upd on upd.id = old.id;

-- Answer 1: v4 -> v5
with old as (
  select * from fs_partner_answers where id='e945db6c-0ae9-414b-857f-36fbfb67d85d' and partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and version=4
    and md5(topic||question||summary::text||coalesce(detail,'')||evidence::text||status||coalesce(waiting_on,''))='2f9a51a5d5750746225b894e0491dfba'
), upd as (
  update fs_partner_answers a set summary = $t$["One completed program: SelassieFest, a one-day roots reggae and cultural festival on Saturday, July 25, 2026, on a private lot at 6227 S. Prairie Ave. in Washington Park. It drew about 273 people.", "No completed programs in South Shore yet, and no South Shore program partner yet.", "Two partner references signed letters of support for Full Spectrum in October. Neither has seen us run a program."]$t$::jsonb, detail = $t$### References
- **Juan P. Mosqueda**, Director of Community Relations, UI Health Community Relations. Signed October 26, 2026, and offered to share our flyers and posts through its social media and community outreach networks.
- **The Avalon Regal Theater (The ART Foundation)**, 1645 E. 79th St. Letter signed October 27, 2026, by "J".

Contact details are available on request.

### Who we are
Ras Tafari Inc. was incorporated on June 8, 2026, and is a 501(c)(3) public charity effective June 9, 2026. Our office is at 1401 E. 71st St. Our Secretary, Albert Harris, is a member of the South Shore Cultural Center Park Advisory Council.$t$, evidence = $t$[{"href": "/rti/kits/cpd-arcs/irs-determination-letter.pdf", "label": "IRS 501(c)(3) determination letter", "note": "effective June 9, 2026; shows our founding address in South Holland; the office is now 1401 E. 71st St."}, {"href": "/about/timeline.html", "label": "Ras Tafari Inc. timeline", "note": "from the 2022 idea to incorporation and SelassieFest 2026"}, {"href": "/rti/kits/cpd-arcs/board-consent-2026-10-18-signed.pdf", "label": "Board consent adopting Full Spectrum as a program, Oct 18, 2026"}]$t$::jsonb, status = 'answered', waiting_on = null,
    version = 5, updated_at = now(), updated_by = 'Data cleanup'
  from old where a.id = old.id returning a.id
)
insert into fs_partner_answer_history (answer_id, version, note, public, previous, changed_by)
select old.id, 5, $t$Updated to November 25: references and current ties; contact details now on request$t$, true, to_jsonb(old), 'Data cleanup' from old join upd on upd.id = old.id;

-- Answer 2: v3 -> v4
with old as (
  select * from fs_partner_answers where id='189c0106-f23e-4151-a292-55cbe46779f6' and partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and version=3
    and md5(topic||question||summary::text||coalesce(detail,'')||evidence::text||status||coalesce(waiting_on,''))='928e452f1889770c0e52098139a327aa'
), upd as (
  update fs_partner_answers a set summary = $t$["Park District: not approved. Park staff offered the Rainbow Beach fieldhouse game room for Tuesday classes on October 20; we filed the partnership proposal on October 27, receipt was confirmed October 30, and it is in review.", "Funding and gifts: a small grant for youth art supplies has been awarded, donated microphones and student headphones have been received, and software licenses for class computers have been granted. Instructors, snacks and summer sound for 2027 are not funded.", "Staff: no paid employees; officers serve without pay; no resident instructor is under contract.", "Equipment: we have no DJ players, controllers or mixers for the class stations yet."]$t$::jsonb, detail = $t$### Program content and audiences
- **Rainbow DJ Lab:** free, every Tuesday from 4 to 6 pm, scheduled to open January 12, 2027 (39 class Tuesdays), subject to Park District approval. Twelve stations, so each child has their own deck. Children join any Tuesday and work at their own pace through 14 Missions (42 skills); graduation is all 42 skills plus a final set. Mainly grades 6 to 12.
- **Rainbow Wednesdays:** 14 free all-ages evenings on the beach, June 2 to September 1, 2027, with young DJs, live instruments and local artists. Our goal is 300 people a night, about 4,200 visits.
- **Also planned:** live stage shows, Caribbean and African diaspora heritage days, festivals and holiday parties.

None of the summer or special events is approved yet.

### Budget
The first-year budget for the DJ Lab, including summer sound, is $75,123 in cash plus $59,547 of equipment. Other grant requests and inquiries are awaiting answers, and some have been declined.

### People and safeguards
- **Board:** Stephen Henry (President), Paul Kelly (Vice President and Treasurer), Albert Harris (Secretary), and directors Marlon Reid and Craig Rainford. We have 10 volunteers.
- **Instructors:** the plan is two resident DJ instructors at $250 a session each and a weekly guest woman DJ at $200 an hour.
- **Insurance:** general liability and abuse and molestation coverage, in force from October 22, 2026, with the Park District named as additional insured.
- **Safety:** the board adopted the DJ Lab's safety, privacy and governance policies on October 17, 2026. Adults who work with children must pass the Park District's background check; those checks are not yet complete.$t$, evidence = $t$[{"href": "/dj-lab/governance/", "label": "DJ Lab safety, privacy and governance policies (adopted by our board Oct 17, 2026)", "note": "the insurance status shown there predates our policy"}, {"href": "/rti/kits/cpd-arcs/board-resolution-2026-10-15-signed.pdf", "label": "Board resolution approving the Park District proposal, Oct 15, 2026"}]$t$::jsonb,
    version = 4, updated_at = now(), updated_by = 'Data cleanup'
  from old where a.id = old.id returning a.id
)
insert into fs_partner_answer_history (answer_id, version, note, public, previous, changed_by)
select old.id, 4, $t$Updated to November 25: approval status, funding, staffing, equipment and program plan$t$, true, to_jsonb(old), 'Data cleanup' from old join upd on upd.id = old.id;

-- Answer 3: v1 -> v2
with old as (
  select * from fs_partner_answers where id='6de161e9-4e76-4a04-af63-d69af4f1a12c' and partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and version=1
    and md5(topic||question||summary::text||coalesce(detail,'')||evidence::text||status||coalesce(waiting_on,''))='70896558855087c98d4e2670b1176f38'
), upd as (
  update fs_partner_answers a set summary = $t$["So far the plan has been written by our board, with Rainbow Beach Park staff advising on space. South Shore residents have not shaped it yet.", "We propose a community planning group of residents and organizations that meets before each season to help choose themes, the calendar, DJs and artists.", "Local first: guest DJs, artists, vendors and helpers would come first from people South Shore organizations refer."]$t$::jsonb, detail = $t$### How residents, artists and organizations would take part
Anything inside Rainbow Beach Park is the Park District's decision, and we will ask the Park District before offering any organization a role there.

- A neighborhood member on every selection panel, for example for featured DJs and youth performers.
- Class snacks bought from neighborhood restaurants: $20 a person for 15 people, 39 Tuesdays, $11,700 a year.
- DJ Lab students play the summer evenings.

### Where support stands
Since October 18 we have written to more than 70 neighborhood organizations. Besides our two references, a marketplace and a church have written that they can help get the word out, including by displaying our flyers. The marketplace will do so once the Park District gives the green light. A residents' letter is open to South Side residents; it has no signatures yet.

### Complementing work already under way
The 2022 South Shore Quality of Life Plan names Rainbow Park and Beach as a place to make more accessible and better used, and it points to the arts and young people. Full Spectrum is meant to support those goals. When the time is right, we would ask NNA which programs to schedule around or join, and which residents, artists and groups to invite first.$t$, evidence = $t$[{"href": "https://www.chicagoqlps.org/south-shore-2022", "label": "South Shore Quality of Life Plan (2022)", "note": "names Rainbow Park and Beach"}, {"href": "/full-spectrum/sign/", "label": "The residents' letter, open to South Side residents"}]$t$::jsonb,
    version = 2, updated_at = now(), updated_by = 'Data cleanup'
  from old where a.id = old.id returning a.id
)
insert into fs_partner_answer_history (answer_id, version, note, public, previous, changed_by)
select old.id, 2, $t$Updated to November 25: participation proposal and current support$t$, true, to_jsonb(old), 'Data cleanup' from old join upd on upd.id = old.id;

-- Answer 4: v3 -> v4
with old as (
  select * from fs_partner_answers where id='baa61d69-5a4b-4ad2-b070-fab16ffd7188' and partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and version=3
    and md5(topic||question||summary::text||coalesce(detail,'')||evidence::text||status||coalesce(waiting_on,''))='08a2a67853adab8cb957afde8d870a27'
), upd as (
  update fs_partner_answers a set summary = $t$["No, our budget does not pay a partner for outreach or coordination. We carry that work ourselves.", "Proposed role: one or two NNA seats on the community planning group, with a real say in the calendar, featured artists and local hiring.", "Time we would ask: nothing now. If NNA joins after our first year, about one planning meeting each season."]$t$::jsonb, detail = $t$### Benefits we envision for NNA and residents
Anything that takes place in the park depends on the Park District's approval.

- **Hey Neighbor:** DJ Lab students and guest DJs could play NNA's walks and events, free.
- **Digital equity:** hands-on music technology training, open to young people from NNA's digital-equity work.
- **Resident leadership:** we would invite South Shore Community Collaborative members to the resident seats.
- **Stories:** student mixes, profiles and season results for NNA's newsletter and podcast, with families' consent for anything about a student.
- **Measurement and credit:** attendance and participation reports after each season, including the numbers that help NNA report on the Quality of Life Plan, and community-partner credit worded as NNA approves.

We would also ask NNA to share our flyers and suggest residents for the planning group. No support letter is needed.$t$,
    version = 4, updated_at = now(), updated_by = 'Data cleanup'
  from old where a.id = old.id returning a.id
)
insert into fs_partner_answer_history (answer_id, version, note, public, previous, changed_by)
select old.id, 4, $t$Updated to November 25: timing now follows your October 28 reply$t$, true, to_jsonb(old), 'Data cleanup' from old join upd on upd.id = old.id;

-- Pre-commit assertion
do $a$
begin
  if (select count(*) from fs_partner_answers a join (values ('e945db6c-0ae9-414b-857f-36fbfb67d85d'::uuid,5),('189c0106-f23e-4151-a292-55cbe46779f6'::uuid,4),('6de161e9-4e76-4a04-af63-d69af4f1a12c'::uuid,2),('baa61d69-5a4b-4ad2-b070-fab16ffd7188'::uuid,4)) x(id,v) on x.id=a.id and a.version>=x.v) <> 4 then
    raise exception 'an answer was not updated'; end if;
  if (select count(*) from fs_partner_answer_history h join (values ('e945db6c-0ae9-414b-857f-36fbfb67d85d'::uuid,5),('189c0106-f23e-4151-a292-55cbe46779f6'::uuid,4),('6de161e9-4e76-4a04-af63-d69af4f1a12c'::uuid,2),('baa61d69-5a4b-4ad2-b070-fab16ffd7188'::uuid,4)) x(id,v) on x.id=h.answer_id and h.version=x.v and h.public and h.previous is not null) <> 4 then
    raise exception 'version history missing'; end if;
  if not exists (select 1 from fs_partners where id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and qa_intro = $t$We want a young person in South Shore to walk in on a Tuesday, sit down at their own DJ station with an instructor in the room, and leave able to do something they could not do the week before.

On October 28 you told us NNA will wait until approvals, funding, staffing and equipment are in place, that any future work must complement existing efforts and benefit residents and NNA, and that we are welcome to reconnect after our first year. We respect that, and we are not asking for a meeting now. These answers were updated on November 25, 2026. If you would like our first-year results, a short reply is all it takes.$t$) then
    raise exception 'intro not updated'; end if;
  if exists (select 1 from fs_partner_answers where partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and published
       and concat_ws(' ', topic, question, summary::text, detail, evidence::text, waiting_on) ~* $r$(alphatheta|pioneer|roland|shure|serato|algoriddim|djay|hercules|audima|sway|reloop|white sox|major league|goodall|roots & shoots|tremendous|portillo|seabury|after school matters|illinois arts|joyce|\m150\M|k=[a-z0-9]{8}|@)$r$)
     or exists (select 1 from fs_partners where id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and concat_ws(' ', qa_title, qa_intro) ~* $r$(alphatheta|pioneer|roland|shure|serato|algoriddim|djay|hercules|audima|sway|reloop|white sox|major league|goodall|roots & shoots|tremendous|portillo|seabury|after school matters|illinois arts|joyce|\m150\M|k=[a-z0-9]{8}|@)$r$) then
    raise exception 'a name or stale figure remains in the public text'; end if;
end $a$;

commit;

select a.sort, a.topic, a.version, a.status, a.published, a.waiting_on, h.note
from fs_partner_answers a left join fs_partner_answer_history h on h.answer_id=a.id and h.version=a.version
where a.partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' order by a.sort;

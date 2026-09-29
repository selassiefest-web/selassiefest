-- SSCC bylaws workspace: a starting meeting plan to the December 12, 2026
-- PAC meeting (second Saturday), per La'Vonne's 2026-09-16 email: meet
-- bi-weekly and present recommendations in December. Dates are tentative
-- (confirmed = false, so no reminders go out) until the coordinator sets the
-- real day, time, and place. Run once; the coordinator edits it on the page after that.
insert into sscc_bylaws_meetings (kind, meets_on, title, focus, agenda) values
('meeting', '2026-10-03', 'Kickoff: purpose and membership', '{I,II}',
 $q$How the workspace works: propose, discuss, accept, publish a version.
Agree on the calendar and on adopting under the 2022 rules (written motion to the Secretary; 2/3 of eligible voting members, quorum of 10).
Articles I and II: name, purpose, membership, removal (the new notice-and-hearing process).$q$),
('meeting', '2026-10-17', 'Meetings, quorum, and voting', '{III,IV}',
 $q$Articles III and IV.
Open questions from the 2022 comparison: quorum drops from 10 to 8; the 14-day posted notice is dropped; virtual-meeting specifics; voting eligibility (the two conflicting 2022 texts).$q$),
('meeting', '2026-10-31', 'Officers, board, and elections', '{V,VI}',
 $q$Articles V and VI: officers, the Executive Board, terms, nominations, and elections.$q$),
('meeting', '2026-11-14', 'Committees through effective date; settle the draft', '{VII,VIII,IX,X,XI}',
 $q$Articles VII to XI: committees, ethics and conflicts, records, amendments (2/3 of eligible voters vs. 2/3 of votes cast), effective date.
Walk through anything still open; the coordinator marks each section the committee agrees on as settled.$q$),
('milestone', '2026-11-21', 'Publish the final version and submit the written motion', '{}',
 $q$The coordinator publishes the version the committee recommends and prints the adoption packet.
Submit the amendment motion in writing to the Secretary (2022 Art. VI).$q$),
('milestone', '2026-11-28', 'Post notice of the December 12 meeting', '{}',
 $q$Notice of the membership meeting must be posted at the South Shore Cultural Center 14 days before it (2022 Art. II §5), and emailed to members. Include the adoption packet.$q$),
('milestone', '2026-12-12', 'PAC meeting: present the recommendations', '{}',
 $q$Present the proposed amended and restated bylaws to the membership. Adoption needs a 2/3 majority of eligible voting members with a quorum of 10 (2022 Art. III §1). Send a copy of the adopted bylaws to the Chicago Park District.$q$);

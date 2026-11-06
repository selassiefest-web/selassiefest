-- Nov 6, 2026: 7704 S. Stony Island owner outreach row (Caribbean Cultural Center letters, 4 of 7 returned). Safe to re-run.
begin;

insert into fs_partners (name, category, stage, ball_with, contacts, last_contact_at, next_step, next_step_due, notes)
select 'South Side Studios Ventures LLC (7704 S. Stony Island owner)', 'Other', 'reached_out', 'us',
 '[{"name":"James Reynolds Jr., Manager (per IL SOS file 10004063)","address":"425 South Financial Place, Suite 2700, Chicago, IL 60605"},{"name":"Loop Capital main line (public; research lead, NOT confirmed to reach Reynolds)","phone":"312-913-4900","email":"info@loopcapital.com"}]'::jsonb,
 '2026-10-03T12:00:00Z',
 'Mail the Nov 6 letters (Reynolds, Cogency, Dudley at 1515 Walker Ave, Cronin) from Claude outputs/7704-stony-island-resend/letters-UPDATED-2026-11-06.pdf + envelopes-UPDATED-2026-11-06.pdf. Then Stephen decides whether to call Loop Capital 312-913-4900 and ask for Jim Reynolds'' office about the Stony Island lot.',
 '2026-11-10',
 E'Sender: Caribbean Cultural Center (Yawd LLC d/b/a), Stephen Henry, 765 E. 154th St., South Holland. Property: 7704 S. Stony Island Ave, PIN 20-26-423-001-0000. Owner of record: South Side Studios Ventures LLC (formerly Regal Mile Ventures LLC, renamed 6/25/2025, IL SOS 10004063).\nFirst mailing about Oct 3 and Oct 20, 2026 to 7 addresses. RETURNED (photos Nov 6): 111 W. Jackson #1901 (no such street); 9777 Wilshire, Beverly Hills (unable to forward); Joseph Dabbah, 1 Central Park S. (not deliverable); Derek Dudley, 1190 W. Wesley Rd NW (forward time expired; USPS gave 1515 Walker Ave, Atlanta GA 30337-1539). NOT returned, no reply: Reynolds (425 S. Financial Pl.), Cogency Global (registered agent, Springfield), Susan Cronin (403 N. Crescent Dr., Beverly Hills).\nRESEARCH Nov 6: 425 S. Financial Pl., Suite 2700 is Loop Capital''s public headquarters (loopcapital.com/contact-us: 312-913-4900, info@loopcapital.com, media@loopcapital.com). Press coverage names Regal Mile principals as Derek Dudley (ID8 Ventures), Joseph Dabbah, Jim Reynolds and Susan Cronin of Loop Capital; the Mayor''s 2023 release says the same. NOT verified that Jim Reynolds = James Reynolds Jr.; no personal phone or email found, and none should be guessed. Log: Claude outputs/7704-stony-island-resend/RETURNED-MAIL-2026-11-06.md.'
where not exists (select 1 from fs_partners where name like 'South Side Studios Ventures LLC (7704%');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select p.id, 'note',
 'Nov 6, 2026: photos of 4 returned letters logged (Jackson, Wilshire, Dabbah dead; Dudley forwarded to 1515 Walker Ave). Dudley resend approved by Stephen. Letters and envelopes rebuilt for the 4 live addresses. Loop Capital public contact found for 425 S. Financial Pl.',
 'reached_out', 'stephen@selassiefest.com', 'Claude (for Stephen Henry)'
from fs_partners p
where p.name like 'South Side Studios Ventures LLC (7704%'
  and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like 'Nov 6, 2026: photos of 4 returned%');

commit;

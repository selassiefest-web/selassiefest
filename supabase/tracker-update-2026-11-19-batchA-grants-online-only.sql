-- tracker-update-2026-11-19-batchA-grants-online-only.sql (revised after reviewer, Nov 19 2026)
-- Stephen, Nov 19 2026: no snail mail, no phone, no visits; every contact online.
-- Marker: [online-only-A 2026-11-19]. Safe to re-run (guards on id + old due + old status/stage + marker).
-- Convention: like batches 1 and 2, no fs_partner_activity rows; markers and reasons go in notes.
-- Sources (read Nov 19, 2026): computerswithcauses.org/application/ and /contact/; gatorco.com (gatorcases.com 301 redirect) /contact/, /help-center/;
-- on-stage.com /contact, /about; Costco charitable-giving page and FAQ (costco.com/f/-/charitable-giving, /charitable-giving-faq);
-- barry-callebaut.com returned 403 to the automated reader; web search found no published donation request process.
begin;

do $$
declare n int;
begin
  -- 1. Computers with Causes: no electronic route -> skip (grant), parked (partner)
  update fs_grant_deadlines set
    status = 'skip',
    next_step = 'SKIP: mailed-form-only program; no electronic route (online-only rule). Laptops via PCs for People (purchase; grant row submitted Nov 18) and Human-I-T (to_research) instead.',
    next_step_due = null,
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] Skip. computerswithcauses.org/application/ (read Nov 19, 2026): "Applications are accepted on the mailed form only. Not by phone, not by email, and not through any form on this website."; contact form is donor-only. Prior next step (sign and mail the organization application) removed under the Nov 19 no-snail-mail rule. Laptop need goes via PCs for People (purchase inquiry sent Nov 18) and Human-I-T (to_research). Reopen only if they add an online application.'
  where id = 'cada0607-00a9-4b54-af68-f803440dd9ca'
    and next_step_due is null and status = 'to_research'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'CwC grant rows: %', n;

  update fs_partners set
    ball_with = 'parked',
    next_step = 'PARKED: Computers with Causes accepts mailed paper applications only (no electronic route). Laptops via PCs for People and Human-I-T. See grant row cada0607.',
    next_step_due = null,
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] Parked: mailed-form-only (computerswithcauses.org/application/, read Nov 19, 2026); no email, phone or web form. Stephen rule Nov 19: online contact only.'
  where id = 'd170a4cc-cab4-496c-95f8-77b04c8c79dc'
    and next_step_due = date '2026-11-12' and stage = 'not_contacted' and ball_with = 'us'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'CwC partner rows: %', n;

  -- 2. Gator: contact form, Stephen submits (grant + partner row + url)
  update fs_grant_deadlines set
    next_step = 'Stephen submits the Gator contact request at https://gatorco.com/contact/ ("Submit a contact request"): ask who handles community/education donations and request 13 laptop stands ($455 line). Packet 02-gear-audio/03-gator.md. Same stands line asked of On-Stage; first yes wins.',
    next_step_due = date '2026-11-23',
    url = 'https://gatorco.com/contact/',
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] SUPERSEDES the Oct 31 "no form, no email" finding (that was shop.gatorco.com). Route found (gatorco.com, read Nov 19, 2026; gatorcases.com redirects to gatorco.com): contact form https://gatorco.com/contact/ ("Submit a contact request"); the help center also lists a callback request page; otherwise phone/text only, no email, no donation page. Replaces the phone and mail steps. Row url updated from shop.gatorco.com/contact.'
  where id = 'de947322-dbc9-4af0-80b9-713f47fb844a'
    and next_step_due = date '2026-12-07' and status = 'ready'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'Gator grant rows: %', n;

  update fs_partners set
    next_step = 'Online only: Stephen submits the Gator contact request at https://gatorco.com/contact/ (see grant row de947322), asking who handles community/education donations.',
    next_step_due = date '2026-11-23',
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] was due 2026-11-04 with a phone step; replaced by the gatorco.com contact form (online-only rule).'
  where id = 'd8211717-4fab-4c5d-86ab-ff62b95010e2'
    and next_step_due = date '2026-11-04' and ball_with = 'us' and next_step like 'Call 813-221-4191%'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'Gator partner rows: %', n;

  -- 3. On-Stage: no electronic route -> skip (grant), parked (partner)
  update fs_grant_deadlines set
    status = 'skip',
    next_step = 'SKIP: no electronic route found (phone and Berlin CT mail address only). Stands line stays with Gator.',
    next_step_due = null,
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] Skip. The packet states no email, no form, no donation or education contact; on-stage.com /contact and /about (read Nov 19, 2026) show only a phone line and the Berlin CT address, and no donation or sponsorship page. An earlier instruction to send the email to the address given has no address, so there is no electronic route. Phone and mail steps removed under the Nov 19 online-only rule. Reopen if an email or form appears. Same stands line is asked of Gator.'
  where id = 'a4287c9e-7de0-4540-83df-cfa63c3850bc'
    and next_step_due = date '2026-12-07' and status = 'ready'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'On-Stage grant rows: %', n;

  update fs_partners set
    ball_with = 'parked',
    next_step = 'PARKED: no electronic route for On-Stage / The Music People (phone and mail address only). Stands line stays with Gator (see grant row a4287c9e).',
    next_step_due = null,
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] was due 2026-11-04 with a phone step; parked because there is no electronic route (online-only rule).'
  where id = '414dde79-6b11-4c98-ae44-dcdc579bcb64'
    and next_step_due = date '2026-11-04' and ball_with = 'us' and next_step like 'Call sales 800-289-8889%'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'On-Stage partner rows: %', n;

  -- 4. Barry Callebaut: route unverified -> to_research with an online route check (not skip)
  update fs_grant_deadlines set
    status = 'to_research',
    next_step = 'Route unverified; online only: open barry-callebaut.com contact and community pages in Chrome (the site returns 403 to automated readers), log any web form or email for community giving, and if none exists mark skip.',
    next_step_due = date '2026-11-23',
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] Phone and mail steps removed (online-only rule). barry-callebaut.com blocked the automated reader (403) and web search found no published donation request process; past Chicago giving was event sponsorship (Halloweek, 2022) and product donations (per web search, unverified). Row url (cacao-barry.com/en-US/contact) is a brand contact page, not a verified donation route. No email or form on file. Snacks line ($6,000 ask) split with Conagra stays asked elsewhere. Route unverified, not closed.'
  where id = 'e562dd73-084f-45fa-be5f-5c8e8bca8910'
    and next_step_due = date '2026-12-07' and status = 'ready'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'Barry Callebaut grant rows: %', n;

  update fs_partners set
    next_step = 'Route unverified; online only: check barry-callebaut.com contact/community pages in Chrome for a web form or email (see grant row e562dd73); if none, mark skip.',
    next_step_due = date '2026-11-23',
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] was due 2026-11-04 with a call step; replaced by an online route check (online-only rule).'
  where id = '6e21e33a-c72b-4133-a646-f552e5087f01'
    and next_step_due = date '2026-11-04' and ball_with = 'us' and next_step ilike '%call the main line%'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'Barry Callebaut partner rows: %', n;

  -- 5. Costco: online Grant Application (Benevity) is the only electronic route; Stephen presses Submit only if the form fits
  update fs_grant_deadlines set
    next_step = 'Online only (no warehouse visit): application-preparer reads the Costco Grant Application (Benevity https://forms.benevity.org/eb5f89d4-4631-4c20-8681-0186712671a0) in Chrome and fills it up to Submit. Costco takes ONE application per fiscal year (Sep-Aug), so Stephen presses Submit only if the form fits Ras Tafari; if it says warehouse-only or ineligible, mark skip. Ask $1,000 cash (supplies, Passports, printing).',
    next_step_due = date '2026-11-23',
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] Route change. Costco charitable-giving page and FAQ (read Nov 19, 2026): 501(c)(3) required; monetary requests only; children/education/health; "Warehouse Donations" (local orgs) are submitted to the nearest warehouse, which is in person, so dropped under the online-only rule; "Grant Applications" (larger, broad-based orgs) are online via Benevity, the only electronic route; FAQ lists CommunityRelations@costco.com for application questions, review of 4-6 weeks, incomplete applications not considered, and 3 months lead for planned events. Honest fit: Ras Tafari is probably a stretch for "larger, broad-based"; the Oct 31 packet judged the Benevity route not recommended this year and preferred the warehouse route. The $1,000 ask is within the FAQ limit of 10% of the program budget (preparer to confirm against the program budget). Row url and program label still describe the warehouse route.'
  where id = '94f4ffa2-ecf9-4a08-ad80-453c6becb9a5'
    and next_step_due = date '2026-12-07' and status = 'ready'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'Costco grant rows: %', n;

  update fs_partners set
    next_step = 'Online only: warehouse delivery dropped (no visits). The only electronic route is the Costco Benevity Grant Application (see grant row 94f4ffa2); application-preparer reads the form first.',
    next_step_due = date '2026-11-23',
    notes = coalesce(notes,'') || E'\n[online-only-A 2026-11-19] was due 2026-11-11 with a warehouse delivery step; replaced by the online Grant Application check (online-only rule).'
  where id = 'efc8c36e-7d83-414d-996b-75d96a50475f'
    and next_step_due = date '2026-11-11' and ball_with = 'us' and next_step like 'Download Warehouse Donation%'
    and coalesce(notes,'') not like '%[online-only-A 2026-11-19]%';
  get diagnostics n = row_count; raise notice 'Costco partner rows: %', n;
end $$;

commit;

select 'grant' k, left(id::text,8) id, funder, status, next_step_due, left(next_step,60) next_step, (notes like '%[online-only-A 2026-11-19]%') marked
from fs_grant_deadlines where left(id::text,8) in ('cada0607','de947322','a4287c9e','e562dd73','94f4ffa2')
union all
select 'partner', left(id::text,8), name, ball_with, next_step_due, left(next_step,60), (notes like '%[online-only-A 2026-11-19]%')
from fs_partners where left(id::text,8) in ('d170a4cc','d8211717','414dde79','6e21e33a','efc8c36e');

-- Portillo's fundraiser night request SUBMITTED by Stephen Nov 24, 2026 (confirmation page: "Thank you for submitting your request"). Earned proceeds (20% of supporter sales), not a grant. Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-24', amount_requested=null, next_step_due='2026-12-08',
  next_step='Wait for Portillo''s approval email (questions: fundraisers@portillos.com). Requested Tue Jan 19, 2027 at Chicago Canal & Taylor, 520 W. Taylor St. (5-8 pm, confirm), est. 40 supporters; 20% of supporter sales, $200 minimum. After approval: get flyers and the fundraiser code, promote the night, add Jan 19 (prep Jan 12) to the calendar. If silent Dec 8, email fundraisers@portillos.com.',
  notes=case when coalesce(notes,'') like '%2026-11-24: Portillo%form filed%' then notes else coalesce(notes,'')||E'\n2026-11-24: Portillo''s form filed by Stephen for Tue Jan 19, 2027, Canal & Taylor (520 W. Taylor St.), 40 est. supporters, funds mailed to 1401 E. 71st St.; W-9 (1401) and IRS letter uploaded. Confirmation page shown; no email yet.' end
where id='fc1eb971-3254-4fb5-b4e5-5a9b1766fd90';
select funder,status,submitted_on,next_step_due from fs_grant_deadlines where id='fc1eb971-3254-4fb5-b4e5-5a9b1766fd90';
commit;

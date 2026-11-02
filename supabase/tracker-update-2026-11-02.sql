-- Tracker update, Nov 2, 2026: replies received Nov 2 (emails in C:\Users\mkepr\Downloads\BOB\).
-- Apply with: supabase db query --linked -f supabase/tracker-update-2026-11-02.sql
-- Safe to re-run.

-- 1. Meijer declined request #106199133 (cybergrants.com form decline, no reason given).
update fs_grant_deadlines set
  status = 'declined',
  decision_on = date '2026-11-02',
  next_step = 'DECLINED Nov 2, 2026 (Request ID 106199133, form decline, no reason given). Opening-day snacks, fruit and water: ask a local grocer in person or buy from the DJ Lab budget.',
  next_step_due = null, updated_at = now()
where id = '28f29270-e628-483b-9f71-a34f8a3b2f7a';

-- 2. Good Humor / Unilever (Case #56545801): pointed us to GoodHumor.Direct@magnumicecream.com,
--    which is for delivery and store issues, not sponsorships.
update fs_grant_deadlines set
  next_step = 'Unilever (Case #56545801, Nov 2) did not introduce an operator; it pointed to GoodHumor.Direct@magnumicecream.com (delivery and store issues). Optional: re-send there, or call a local Good Humor distributor. Distributors (GlacierPoint, Prairie Farms, Fox Valley Farms) stay ranked first.',
  next_step_due = date '2026-11-16', updated_at = now()
where id = '218ec91c-a38c-4a80-b89d-733880aab5d2';

-- 3. DCASE (Julie Partynski, Nov 2): closing out 2026 programs; 2027 programs to be announced soon;
--    sign up for the newsletter for the opening and training. None of the 4 questions answered.
update fs_grant_deadlines set
  next_step = 'DCASE replied Nov 2 (Julie Partynski): closing out 2026, 2027 programs announced soon, sign up for the newsletter at https://www.chicago.gov/city/en/depts/dca/provdrs/grants.html. Our 4 questions (NAP and CityArts opening, 12-month rule, pre-incorporation history, festival grant) were NOT answered. Next: sign up for the newsletter; ask again or book a Consult DCASE session.',
  next_step_due = date '2026-11-16', updated_at = now()
where id = 'bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed';

update fs_grant_deadlines set
  next_step = 'DCASE (Nov 2) did not answer the 12-month incorporation question; 2027 programs are "announced soon". Likely not eligible until 2028. Watch the DCASE newsletter and re-ask.',
  updated_at = now()
where id = 'eef3f6bf-2e42-4503-958b-57c0172063cd';

-- 4. Jane Goodall Roots & Shoots Chicago Basecamp (Alex Biswas replied Nov 2).
update fs_grant_deadlines set
  next_step = 'Alex Biswas replied Nov 2: fine to be considered without registration (their sign-up page problem); they will say when to register, then send her our member name. If the project is not done by Dec 30, send a project update; no smaller project needed.',
  next_step_due = date '2026-11-09', updated_at = now()
where id = '38c4ff8b-f15a-4c28-9182-8093fb370263';

-- 5. Candid: approved Nov 2. Delta waits on the Bronze seal.
update fs_grant_deadlines set
  next_step = 'CANDID APPROVED Nov 2, 2026 (stephen@selassiefest.com can edit the profile). Next: fill the Candid profile for the BRONZE seal at https://app.candid.org/user/organizations, then finish and submit Delta. If submitting after Nov 11, move the first date past Feb 9, 2027 to keep 90 days.',
  next_step_due = date '2026-11-04', updated_at = now()
where id = '7d0f78f9-4739-4bb0-a6ab-3086b7028d9f';

-- 6. Algoriddim: the 13 voucher codes arrived Nov 2 (ticket 262652, valid 1 year from redemption).
update fs_partners set
  next_step = '13 djay Pro vouchers RECEIVED Nov 2 (ticket 262652; each valid 1 year once redeemed). Keep the codes private. Assign 12 students + 1 spare and redeem close to the Jan 12, 2027 opening.',
  next_step_due = date '2027-01-05', last_contact_at = timestamp '2026-11-02 08:00', updated_at = now()
where id = '0891b777-3154-49cd-b714-450f7876f95f';

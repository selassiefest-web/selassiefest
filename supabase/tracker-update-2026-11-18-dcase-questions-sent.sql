-- 2026-11-18: DCASE questions email SENT at Stephen's "send" (rti-outreach, Resend 01a1f257-2b08-7dcc-a477-9da316a67201) to CulturalGrantMaking@cityofchicago.org, cc stephen@, new message, with the pitch deck.
-- Asks: which program fits (Neighborhood Access or CityArts), when first eligible under the 12-month rule (incorporated June 8, 2026), whether pre-incorporation programming counts. Grant row eef3f6bf (CityArts) and the NAP/Chicago Presents row bb5d4340. Guarded; safe to re-run.
begin;
update fs_grant_deadlines set next_step='Questions EMAIL SENT Nov 18, 2026 (Resend 01a1f257-2b08-7dcc-a477-9da316a67201) to CulturalGrantMaking@cityofchicago.org: which program fits, when first eligible under the 12-month rule, whether pre-incorporation programming counts. Wait for DCASE; if silent, one email nudge Dec 9 (internal). Stephen: sign up for the DCASE grants newsletter at https://www.chicago.gov/city/en/depts/dca/provdrs/grants.html (his email). Likely not eligible until 2028.',
 next_step_due='2026-12-09',
 notes=coalesce(notes,'')||E'\n[2026-11-18] DCASE questions email sent (Resend 01a1f257-2b08-7dcc-a477-9da316a67201).'
where id='bb5d4340-0ec1-4da1-9b19-3ad9734ec5ed' and coalesce(notes,'') not like '%01a1f257-2b08-7dcc%';
update fs_grant_deadlines set next_step='DCASE questions email sent Nov 18, 2026 (Resend 01a1f257-2b08-7dcc-a477-9da316a67201), asking when we would first be eligible under the 12-month rule. Wait for the reply; likely not eligible until 2028. Watch the DCASE newsletter. Check Dec 9 (internal).',
 next_step_due='2026-12-09',
 notes=coalesce(notes,'')||E'\n[2026-11-18] DCASE questions email sent (Resend 01a1f257-2b08-7dcc-a477-9da316a67201).'
where id='eef3f6bf-2e42-4503-958b-57c0172063cd' and coalesce(notes,'') not like '%01a1f257-2b08-7dcc%';
commit;
select (select count(*) from fs_grant_deadlines where notes like '%01a1f257-2b08-7dcc%') rows_logged;

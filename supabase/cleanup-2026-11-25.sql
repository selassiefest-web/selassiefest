-- Stale-fact cleanup, 2026-11-25. Safe to re-run. Contains no keys or secrets.
begin;

-- 1. NNA intro (no version history exists for qa_intro)
update fs_partners set qa_intro = replace(replace(qa_intro, $q$- Asked equipment makers for the class stations: AlphaTheta (Pioneer DJ) has forwarded our request internally and Roland is looking further into a partnership. Neither has committed.$q$, $q$- Asked equipment makers about the class stations. Roland has not committed to a partnership.$q$), $q$and we own no DJ equipment yet.$q$, $q$and we own no DJ players, controllers or mixers yet.$q$), updated_at = now()
where id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and position($q$- Asked equipment makers for the class stations: AlphaTheta (Pioneer DJ) has forwarded our request internally and Roland is looking further into a partnership. Neither has committed.$q$ in qa_intro)>0 and position($q$and we own no DJ equipment yet.$q$ in qa_intro)>0;

-- 1b. NNA published answer, with version history (same shape as fs_partner_qa_save)
with old as (
  select * from fs_partner_answers
  where id='189c0106-f23e-4151-a292-55cbe46779f6' and partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and version=2
    and position($q$- **Equipment:** Ras Tafari Inc. owns no DJ equipment yet. We have asked DJ equipment makers to supply the 12 class stations. AlphaTheta (the maker of Pioneer DJ gear) has forwarded our request internally, and Roland is looking further into a partnership. Neither has committed anything yet.$q$ in detail)>0 and summary ? $q$Equipment: none owned yet. AlphaTheta (Pioneer DJ) has forwarded our request and Roland is looking further into a partnership; nothing committed.$q$
), upd as (
  update fs_partner_answers a set
    detail = replace(a.detail, $q$- **Equipment:** Ras Tafari Inc. owns no DJ equipment yet. We have asked DJ equipment makers to supply the 12 class stations. AlphaTheta (the maker of Pioneer DJ gear) has forwarded our request internally, and Roland is looking further into a partnership. Neither has committed anything yet.$q$, $q$- **Equipment:** Ras Tafari Inc. owns no DJ players, controllers or mixers yet. We have asked DJ equipment makers about the 12 class stations. Roland has not committed to a partnership.$q$),
    summary = (select jsonb_agg(case when e = to_jsonb($q$Equipment: none owned yet. AlphaTheta (Pioneer DJ) has forwarded our request and Roland is looking further into a partnership; nothing committed.$q$::text) then to_jsonb($q$Equipment: no DJ players, controllers or mixers owned yet. Roland has not committed to a partnership.$q$::text) else e end order by n)
               from jsonb_array_elements(a.summary) with ordinality t(e,n)),
    version = 3, updated_at = now(), updated_by = 'Data cleanup'
  from old where a.id = old.id
  returning a.id
)
insert into fs_partner_answer_history (answer_id, version, note, public, previous, changed_by)
select old.id, 3, 'Equipment wording updated', true, to_jsonb(old), 'Data cleanup' from old join upd on upd.id = old.id;

insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
select '587b1b67-f593-470c-9e7e-b04d6dcf33f7', 'note', $q$Answers page corrected: equipment wording in the intro and in the 'Where the program stands' answer (now v3) updated; an out-of-date equipment-maker sentence removed. Nothing sent to NNA. [src:cleanup-20261125-nna]$q$, 'stephen@selassiefest.com', 'Data cleanup'
where not exists (select 1 from fs_partner_activity where partner_id='587b1b67-f593-470c-9e7e-b04d6dcf33f7' and position('[src:cleanup-20261125-nna]' in summary)>0);

-- 2. Retire the AlphaTheta private-link page (guarded by id)
update fs_partners set pitch_key = null, updated_at = now()
where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and pitch_key is not null;

insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
select 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a', 'note', $q$Private-link partner page retired (its template still showed asks). No other field changed. Nothing sent. [src:cleanup-20261125-page-retired]$q$, 'stephen@selassiefest.com', 'Data cleanup'
where not exists (select 1 from fs_partner_activity where partner_id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and position('[src:cleanup-20261125-page-retired]' in summary)>0);

-- 3. Chicago Community Trust duplicate row (no delete)
update fs_partners p set stage='not_qualified', ball_with='parked', next_step=$q$DUPLICATE: do not work this row. Use partner d576fc5a-8554-4209-9fa3-1495327d4ec5 (Chicago Community Trust).$q$, next_step_due=null,
  notes = concat_ws(E'
', $q$[2026-11-25] DUPLICATE: do not work this row. Use partner d576fc5a-8554-4209-9fa3-1495327d4ec5 (Chicago Community Trust). Closed as a duplicate, not a decision by the Trust. Research notes and contact check below are kept.$q$, p.notes), updated_at=now()
where p.id='5a534711-01f6-4e4f-8616-4ee78cbef694' and p.stage='not_contacted' and p.last_contact_at is null
  and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id)
  and exists (select 1 from fs_partners k where k.id='d576fc5a-8554-4209-9fa3-1495327d4ec5');

insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
select '5a534711-01f6-4e4f-8616-4ee78cbef694', 'note', $q$Closed as a duplicate of partner d576fc5a-8554-4209-9fa3-1495327d4ec5, which holds the history. No outreach was ever logged here. [src:cleanup-20261125-cct-duplicate]$q$, 'stephen@selassiefest.com', 'Data cleanup'
where not exists (select 1 from fs_partner_activity where partner_id='5a534711-01f6-4e4f-8616-4ee78cbef694' and position('[src:cleanup-20261125-cct-duplicate]' in summary)>0);

-- 4. Hotel inquiries were sent: status submitted, submitted_on = first inquiry on file
update fs_grant_deadlines set status='submitted', submitted_on='2026-10-28',
  notes = concat_ws(E'
', notes, $q$[2026-11-25] Status corrected from ready to submitted: First inquiry sent Oct 28; follow-ups Nov 18 and Nov 23. Inquiry only; no award or reply. [src:cleanup-20261125-status]$q$), updated_at=now()
where id::text like '6c050a1a-%' and status='ready' and submitted_on is null;

update fs_grant_deadlines set status='submitted', submitted_on='2026-10-28',
  notes = concat_ws(E'
', notes, $q$[2026-11-25] Status corrected from ready to submitted: First inquiry sent Oct 28; follow-ups Nov 18 and Nov 23. Inquiry only; no award or reply. [src:cleanup-20261125-status]$q$), updated_at=now()
where id::text like '5cbce63b-%' and status='ready' and submitted_on is null;

update fs_grant_deadlines set status='submitted', submitted_on='2026-11-23',
  notes = concat_ws(E'
', notes, $q$[2026-11-25] Status corrected from ready to submitted: Inquiry emailed Nov 23 to Marriott@maritz.com. Inquiry only; no award or reply. [src:cleanup-20261125-status]$q$), updated_at=now()
where id::text like '94726569-%' and status='ready' and submitted_on is null;

-- 5. Joyce: no confirmed deadline
update fs_grant_deadlines set deadline_date=null,
  notes = concat_ws(E'
', notes, $q$[2026-11-25] Cleared deadline_date 2026-12-01: it was the published Dec 1 cycle, which Maddie Easton (Nov 20) said was unlikely; registration comes first and no cycle date is confirmed (April 2027 possible). Dec 1 remains only our own follow-up date. [src:cleanup-20261125-joyce-deadline]$q$), updated_at=now()
where id='dc25d586-f390-4553-964a-01fd8090c8e1' and deadline_date='2026-12-01' and status='drafting';

-- 6. Future calendar alerts: drop closed, held or re-dated items; carry re-dated items to the right day
update rti_calendar_events set title=$q$Awesome Foundation check$q$, notes=replace(replace(notes, $q$G ed906339 Morningstar; $q$, $q$$q$), $q$; G 6568f74b Levitate; G d3f65537 New York Life$q$, $q$$q$)
where key='nov25-tasks-2026-11-25' and active and md5(title||'|'||coalesce(notes,''))='905caaba05e6c893773eca5eeb3b22f2';

update rti_calendar_events set title=$q$Follow-ups: Frankie Knuckles nudge, Walmart status, A Better Chicago, LPMC, Prince, CCT sponsorships$q$, notes=replace(replace(notes, $q$G 5c2eee2e SGA; $q$, $q$$q$), $q$P 0fa79d13 ComEd; $q$, $q$$q$)
where key='nov30-followups-2026-11-30' and active and md5(title||'|'||coalesce(notes,''))='2e59b0dc7272e91dbf477690a0fedbd6';

update rti_calendar_events set title=$q$Dec 1: Portillo's calendar and promotion prep, Wallace/Rebuild, White Sox in-kind form, Busey, U.S. Bank, Kresge, Wells, Siragusa, Theresa decision$q$, notes=replace(replace(notes, $q$G b9040174 Fry; $q$, $q$$q$), $q$G 532ee394 Best Buy; $q$, $q$$q$)
where key='dec01-tasks-2026-12-01' and active and md5(title||'|'||coalesce(notes,''))='0f0d819ea665f5c7530f6a21675932c9';

update rti_calendar_events set title=$q$Follow-ups due: Roland, NAMM, ComEd, Pritzker Traubert, Rebuild asks, PCs for People, CHAUVET DJ$q$, notes=replace(notes, $q$G 6c050a1a Hyatt; G 5cbce63b IHG; $q$, $q$P 2b132601 CHAUVET DJ (form sent Nov 23); $q$)
where key='dec02-followups-2026-12-02' and active and md5(title||'|'||coalesce(notes,''))='b9b6f741bd18b3c8203dbc8065e40c49';

update rti_calendar_events set title=$q$Follow-ups: Free to Dream, Music for Global Children, SAI$q$, notes=replace(notes, $q$G a75ac9d3 NEH; $q$, $q$$q$)
where key='dec04-followups-2026-12-04' and active and md5(title||'|'||coalesce(notes,''))='c7c7fdb9eaa7ac42a67fd56127edfaee';

update rti_calendar_events set title=$q$Follow-ups: PNC, Prairie Farms, Good Humor, B&B, Dippin Dots, Homers, Kilwins, Target, Eames, Clayco$q$, notes=replace(notes, $q$G fc085d99 GlacierPoint; $q$, $q$$q$)
where key='dec08-followups-2026-12-08' and active and md5(title||'|'||coalesce(notes,''))='e55fca78d7c065fc5e62bbe389153551';

update rti_calendar_events set title=$q$Internal research: Strong Mind Strong Body$q$, notes=replace(notes, $q$G b7d59a35 Peoples Gas; $q$, $q$$q$)
where key='dec10-research-2026-12-10' and active and md5(title||'|'||coalesce(notes,''))='d0a40aee0034f63f149833a2deac468a';

update rti_calendar_events set title=$q$White Sox in-kind form deadline; Genesis Inspiration; Bears$q$, notes=replace(notes, $q$; G e621a665 United Airlines$q$, $q$$q$)
where key='dec15-deadlines-2026-12-15' and active and md5(title||'|'||coalesce(notes,''))='f6d7cd02120273c50024c23123903caa';

update rti_calendar_events set title=$q$After School Matters programs review check; 4imprint quote under $500; New York Life recheck; SGA micro-grant check$q$, notes=notes || $q$ G d3f65537 New York Life recheck; G 5c2eee2e SGA micro-grant check.$q$
where key='asm-4imprint-2027-01-04' and active and md5(title||'|'||coalesce(notes,''))='aacda3fa0669a09190a4d9c81ddcf03e';

update rti_calendar_events set title=$q$QSC check, Focusrite follow-up, Taco Bell feedthebeat.com watch, CPD proposal notice window, Oriental Trading form, Morningstar recheck$q$, notes=notes || $q$ G ed906339 Morningstar recheck.$q$
where key='mar01-checks-2027-03-01' and active and md5(title||'|'||coalesce(notes,''))='384ff2d9b1832f6f56ba080e34634a99';

update rti_calendar_events set notes=replace(notes, $q$CHAUVET DJ [2b132601-4117-4170-aa03-92d52375573f] | $q$, $q$$q$)
where key='triage-followups-2026-12-04' and active and md5(title||'|'||coalesce(notes,''))='83c9f9bcdebc9992f7b2fca7da310c63';

update rti_calendar_events set notes=replace(notes, $q$Chicago Community Trust [d576fc5a-8554-4209-9fa3-1495327d4ec5] | $q$, $q$Hyatt Hotels [ae44d885-832f-4de2-8322-e8321175edc8] | IHG Hotels & Resorts [6e6c31a2-a474-48b6-aedc-ad3e8d39e022] | Marriott International [7e7b3f6e-fb74-449f-97dd-d111815fedc0] | $q$)
where key='triage-followups-2026-12-07' and active and md5(title||'|'||coalesce(notes,''))='9b5a71f0936f013fdaa03bed6253f247';

update rti_calendar_events set notes=replace(notes, $q$ | Odyssey [43075ae7-1438-49c8-80e5-d6319b69ae31]$q$, $q$$q$)
where key='triage-followups-2026-12-08' and active and md5(title||'|'||coalesce(notes,''))='ed60510dd9179fbbf07e5a98aa37b520';

update rti_calendar_events set notes=replace(notes, $q$American Airlines [5fb7a60c-7195-4c8c-ae06-2259e0691247] | $q$, $q$$q$)
where key='triage-followups-2026-12-09' and active and md5(title||'|'||coalesce(notes,''))='671e4301d875b3f1ab7d73707d21ebc5';

update rti_calendar_events set notes=replace(replace(notes, $q$Marriott International [7e7b3f6e-fb74-449f-97dd-d111815fedc0] | $q$, $q$$q$), $q$Morningstar [640f3190-2534-4f7a-9b25-41c23bbd34f0] | $q$, $q$$q$)
where key='triage-followups-2026-12-14' and active and md5(title||'|'||coalesce(notes,''))='b69e40f0ed6a52c053cc6b0ee50b83f6';

update rti_calendar_events set notes=replace(notes, $q$ | United Airlines [2dc7bd53-77f9-4c0e-bbea-e75bf4aa00e2]$q$, $q$$q$)
where key='triage-followups-2026-12-15' and active and md5(title||'|'||coalesce(notes,''))='bed857b12baeea221050896a800d10a9';

-- Pre-commit assertion: any miss rolls everything back
do $a$
declare bad text;
begin
  select string_agg(chk, ', ') into bad from (values
    ('nna_intro', (select position('AlphaTheta' in qa_intro)=0 and position('own no DJ equipment' in qa_intro)=0 from fs_partners where id='587b1b67-f593-470c-9e7e-b04d6dcf33f7')),
    ('nna_answer', (select version>=3 and position('AlphaTheta' in detail||summary::text)=0 from fs_partner_answers where id='189c0106-f23e-4151-a292-55cbe46779f6')),
    ('nna_history', exists(select 1 from fs_partner_answer_history where answer_id='189c0106-f23e-4151-a292-55cbe46779f6' and version=3 and previous is not null)),
    ('alphatheta_page', (select pitch_key is null from fs_partners where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a')),
    ('cct_duplicate', (select stage='not_qualified' and ball_with='parked' and next_step_due is null from fs_partners where id='5a534711-01f6-4e4f-8616-4ee78cbef694')),
    ('hotels', (select count(*)=3 from fs_grant_deadlines where id::text ~ '^(6c050a1a|5cbce63b|94726569)-' and status='submitted' and submitted_on is not null)),
    ('joyce', (select deadline_date is null and next_step_due='2026-12-01' from fs_grant_deadlines where id='dc25d586-f390-4553-964a-01fd8090c8e1')),
    ('calendar_removed', not exists(select 1 from rti_calendar_events where
        (key='nov25-tasks-2026-11-25' and notes ~ '(ed906339|6568f74b|d3f65537)') or
        (key='nov30-followups-2026-11-30' and notes ~ '(5c2eee2e|0fa79d13)') or
        (key='dec01-tasks-2026-12-01' and notes ~ '(b9040174|532ee394)') or
        (key='dec02-followups-2026-12-02' and notes ~ '(6c050a1a|5cbce63b)') or
        (key='dec04-followups-2026-12-04' and notes ~ 'a75ac9d3') or
        (key='dec08-followups-2026-12-08' and notes ~ 'fc085d99') or
        (key='dec10-research-2026-12-10' and notes ~ 'b7d59a35') or
        (key='dec15-deadlines-2026-12-15' and (notes ~ 'e621a665' or title ~ 'United')) or
        (key='triage-followups-2026-12-04' and notes ~ '2b132601') or
        (key='triage-followups-2026-12-07' and notes ~ 'd576fc5a') or
        (key='triage-followups-2026-12-08' and notes ~ '43075ae7') or
        (key='triage-followups-2026-12-09' and notes ~ '5fb7a60c') or
        (key='triage-followups-2026-12-14' and notes ~ '(7e7b3f6e|640f3190)') or
        (key='triage-followups-2026-12-15' and notes ~ '2dc7bd53'))),
    ('calendar_carried', (select count(*)=4 from rti_calendar_events where
        (key='dec02-followups-2026-12-02' and notes ~ '2b132601') or
        (key='triage-followups-2026-12-07' and notes ~ 'ae44d885' and notes ~ '6e6c31a2' and notes ~ '7e7b3f6e') or
        (key='asm-4imprint-2027-01-04' and notes ~ 'd3f65537' and notes ~ '5c2eee2e') or
        (key='mar01-checks-2027-03-01' and notes ~ 'ed906339')))
  ) v(chk, ok) where ok is not true;
  if bad is not null then raise exception 'cleanup assertion failed: %', bad; end if;
end $a$;

commit;

select 'partner' as t, id::text as id, name as label, stage||' / '||coalesce(ball_with,'-')||' / page '||case when pitch_key is null then 'retired' else 'live' end as state
  from fs_partners where id in ('587b1b67-f593-470c-9e7e-b04d6dcf33f7','a2e09e2e-5916-4e5a-b232-2369cfc8b57a','5a534711-01f6-4e4f-8616-4ee78cbef694')
union all select 'answer', id::text, topic, 'v'||version||' / mention removed: '||(position('AlphaTheta' in detail||summary::text)=0) from fs_partner_answers where id='189c0106-f23e-4151-a292-55cbe46779f6'
union all select 'grant', id::text, funder, status||' / submitted '||coalesce(submitted_on::text,'-')||' / deadline '||coalesce(deadline_date::text,'-')||' / due '||coalesce(next_step_due::text,'-')
  from fs_grant_deadlines where id::text ~ '^(6c050a1a|5cbce63b|94726569|dc25d586)'
union all select 'calendar', key, title, (starts_at at time zone 'America/Chicago')::text from rti_calendar_events
  where key ~ '^(triage-followups-2026-12-(04|07|08|09|14|15)|nov25-tasks|nov30-followups|dec01-tasks|dec02-followups|dec04-followups|dec08-followups|dec10-research|dec15-deadlines|mar01-checks|asm-4imprint)'
order by 1,2;

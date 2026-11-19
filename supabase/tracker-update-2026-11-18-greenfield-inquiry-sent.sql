-- 2026-11-18: Benjamin B. Green-Field Foundation inquiry SENT at Stephen's "send" (rti-outreach, Resend 01a1f1e0-dc62-769e-bcbb-c6124cc5437d),
-- stephen@ to Kathy@Greenfieldfoundation.org, cc stephen@. Three sentences, no amount; email-first instead of the packet's call-first step (online only). No partner row exists. Guarded; safe to re-run.
begin;
update fs_grant_deadlines
set next_step='Inquiry SENT Nov 18, 2026 (Resend 01a1f1e0-dc62-769e-bcbb-c6124cc5437d) to Kathy@Greenfieldfoundation.org: asks whether first-time requests from a 2026-founded youth music program are considered, next board review date, what would meet the memorial requirement, and request size. No amount named. Wait for her reply; if silent follow up Dec 2 (phone 708-444-4241 is parked, online only). After a go-ahead: full letter (packet 06-chicago-fdn-open/03-benjamin-b-green-field-foundation.md) by email to Kathy@ AND a hard copy to 18313 Greenleaf Ct., Tinley Park, IL 60487.',
    next_step_due='2026-12-02',
    notes=coalesce(notes,'')||E'\n[2026-11-18] Inquiry sent (Resend 01a1f1e0-dc62-769e-bcbb-c6124cc5437d), email-first, three sentences, no amount, no plaque promised (board approval of memorial wording still needed before any commitment).'
where id='25f4ac41-f367-4dbc-bf0d-e0f1843679ea' and coalesce(notes,'') not like '%01a1f1e0-dc62-769e%';
commit;
select status, next_step_due, notes like '%01a1f1e0-dc62-769e%' logged from fs_grant_deadlines where id='25f4ac41-f367-4dbc-bf0d-e0f1843679ea';

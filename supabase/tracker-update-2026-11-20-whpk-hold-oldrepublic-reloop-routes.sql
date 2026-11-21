-- Nov 20, 2026. Stephen: "WHPK leave until we have a go from CPD"; fix Old Republic partner-row gap; Reloop precise route.
-- Routes verified in Chrome Nov 20: oldrepublic.com/contact HAS a form (no attachment, required operating-company dropdown, message box, no giving option);
-- americanmusicandsound.com/contact has NO form/email, only the Reloop link bit.ly/amscustomersupport -> Zoho form "AM&S Customer Support Request Form" (request type Support/Sales/Marketing).
-- Website address is 154 Woodlawn Road, Berlin CT 06037 (not the Woodland Hills address in Reloop's email). Safe to re-run.
begin;

update fs_partners set ball_with='cpd_hold', next_step_due=null,
 next_step='HOLD until CPD gives a GO (Stephen, Nov 20, 2026). Then, online only: email booking@whpk.org (Nic Restivo, Booking Director; alternate web form https://whpk.org/contact), two sentences plus deck https://selassiefest.com/full-spectrum/deck.html, after Stephen says "send". Do NOT use sm@whpk.org (FCC/emergencies). No studio visit in the email (online-only). Keep park wording factual ("applying"); no claim of approval.'
where id='7040e7f0-e62a-473a-b25f-a0094a4512b1';

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'note','Nov 20, 2026: Stephen put WHPK on HOLD until CPD gives a GO; the booking@whpk.org email is not sent. (ref WHPK-hold 2026-11-20)',p.stage,'stephen@selassiefest.com','Stephen Henry',now()
from fs_partners p where p.id='7040e7f0-e62a-473a-b25f-a0094a4512b1'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%WHPK-hold 2026-11-20%');

update fs_partners set next_step_due='2026-11-23',
 notes='Chicago headquarters (307 N. Michigan Ave, Chicago IL 60601; HQ phone (312) 346-8100, from oldrepublic.com/contact, Nov 20, 2026). Giving contact: none published; no giving page, giving email or unsolicited-request policy found. 2025 Sustainability Report confirms local giving; a Chicago corporate-giving job posting exists (Oct 31 research, see grant row 6a15168d). Contact page https://oldrepublic.com/contact HAS a web form (verified in Chrome Nov 20): Company Name*, First*, Last*, Job Title, Email*, Phone, State, Industry (includes Nonprofit Organizations), required "Which company" dropdown of operating companies only, Message box; no attachment field. The Nov 1 printed letter was NOT mailed; online only (Stephen, Nov 19). Phone follow-up parked, not before Dec 7.',
 next_step='STEPHEN, Mon Nov 23: submit the web form at https://oldrepublic.com/contact using the paste-ready text at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\old-republic\contact-form-message.txt (asks who handles Chicago community giving; no attachment possible). Required dropdown has no giving option: choose the closest corporate-level one. After Stephen says "send", log it and set a 14-day follow-up. If the form is rejected, mark skip and log other angles. Phone (312) 346-8100 parked, not before Dec 7.'
where id='ea55b1a8-0d0e-4847-b6aa-309d69855b59';

update fs_grant_deadlines set next_step_due='2026-11-23',
 next_step='STEPHEN, Mon Nov 23: submit the web form at https://oldrepublic.com/contact (verified: form exists, no attachment, required operating-company dropdown, message box) with the text at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\old-republic\contact-form-message.txt asking who handles Chicago community giving. Partner row ea55b1a8. Phone parked, not before Dec 7.',
 notes=notes || E'\n2026-11-20 Contact form verified in Chrome (fields listed on partner row ea55b1a8); no giving page or email exists. [src:or-form-verified-20261120]'
where id='6a15168d-fb2e-40c6-80c8-9531166570ca' and notes not like '%or-form-verified-20261120%';

update fs_partners set next_step_due='2026-11-23',
 next_step='STEPHEN, Mon Nov 23: submit American Music & Sound''s web form (they publish no email): https://bit.ly/amscustomersupport (opens https://zfrmz.com/o6ZrCjQ9pev5VIMfbWPR). First field Contact Request Type: choose Marketing. Paste the message at C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\reloop-ams\ams-form-message.txt (asks for the education/community contact or one demo turntable setup; deck https://selassiefest.com/full-spectrum/deck.html). After Stephen says "send", log it. If no answer, check Dec 4, 2026. Note: their site lists 154 Woodlawn Road, Berlin CT 06037, (800) 431-2609; Reloop''s email gave a Woodland Hills CA address.'
where id='aad5ab14-8354-47f0-ac24-a09f195f03a2';

update fs_grant_deadlines set next_step_due='2026-11-23',
 next_step='Reloop Support REPLIED Nov 19 (redirect to Reloop USA / American Music & Sound); the Nov 18 follow-up is answered, not silent. NEXT: Stephen submits the AM&S web form Mon Nov 23 (route and paste-ready text on partner row aad5ab14; file C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\reloop-ams\ams-form-message.txt). If no answer, check Dec 4, 2026.',
 notes=coalesce(notes,'') || E'\n2026-11-20 Reloop reply of Nov 19 logged on partner row aad5ab14 [src:msgid-c30ef27b48f04d738bfe2b2e562a6e44]; AM&S form route verified in Chrome. [src:reloop-route-20261120]'
where id='383b51a1-d28a-4fff-b8c2-0dfbb808925b' and coalesce(notes,'') not like '%reloop-route-20261120%';

commit;

select 'whpk' k, ball_with, next_step_due::text from fs_partners where id='7040e7f0-e62a-473a-b25f-a0094a4512b1'
union all select 'or_partner', ball_with, next_step_due::text from fs_partners where id='ea55b1a8-0d0e-4847-b6aa-309d69855b59'
union all select 'or_grant', status, next_step_due::text from fs_grant_deadlines where id='6a15168d-fb2e-40c6-80c8-9531166570ca'
union all select 'reloop_partner', ball_with, next_step_due::text from fs_partners where id='aad5ab14-8354-47f0-ac24-a09f195f03a2'
union all select 'reloop_grant', status, next_step_due::text from fs_grant_deadlines where id='383b51a1-d28a-4fff-b8c2-0dfbb808925b';

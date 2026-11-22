-- Nov 22, 2026: correction. The live Old Republic contact form has NO message field (checked in Chrome). Safe to re-run.
begin;
update fs_grant_deadlines set
 notes = notes || E'\n2026-11-22 [or-form-correction-20261122] CORRECTION to the Nov 21 audit: the live form at https://oldrepublic.com/contact has NO message/comments field. Fields: Company Name, First Name, Last Name, Job Title, Email, Phone Number, State/Region, Industry, "Which company are you looking to connect with?" (required), reCAPTCHA, Submit. Filled in Chrome Nov 22 (Ras Tafari Inc., Stephen Henry, President, IL, Nonprofit Organizations, Old Republic Title); NOT submitted (reCAPTCHA and Submit are Stephen''s). Because there is no message box, our question (who handles charitable giving, deck link) cannot go in the form: expect a routing reply, then ask the question by reply.'
where id='6a15168d-fb2e-40c6-80c8-9531166570ca' and notes not like '%or-form-correction-20261122%';
commit;
select (notes like '%or-form-correction-20261122%') noted, status, next_step_due::text from fs_grant_deadlines where id='6a15168d-fb2e-40c6-80c8-9531166570ca';

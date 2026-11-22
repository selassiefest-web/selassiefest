-- Nov 22, 2026: Old Republic contact form could not be submitted (page error). Safe to re-run.
begin;
update fs_grant_deadlines set
 next_step = 'Old Republic web form (https://oldrepublic.com/contact) filled but NOT submitted: Nov 22 it errored ("Oops! Something went wrong. This page didn''t load Google Maps correctly") and the invisible reCAPTCHA would not pass. Retry once Mon Nov 23 from a normal Chrome window (no extension; values in notes). The form has no message field, so expect a routing reply and then ask who handles giving. If it still fails, park until the HQ phone window opens Dec 7 (online-only rule).',
 notes = notes || E'\n2026-11-22 [or-form-error-20261122] Stephen tried to submit the Old Republic contact form; the page showed "Oops! Something went wrong. This page didn''t load Google Maps correctly." Not submitted. Values to enter: Company Ras Tafari Inc.; Stephen Henry, President; stephen@selassiefest.com; (872) 255-9333; IL; Industry Nonprofit Organizations; company Old Republic Title. Status stays ready; nothing sent, awarded or received.'
where id='6a15168d-fb2e-40c6-80c8-9531166570ca' and notes not like '%or-form-error-20261122%';
commit;
select status, next_step_due::text, (notes like '%or-form-error-20261122%') noted from fs_grant_deadlines where id='6a15168d-fb2e-40c6-80c8-9531166570ca';

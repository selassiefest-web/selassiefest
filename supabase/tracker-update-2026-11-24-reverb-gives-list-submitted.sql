-- Reverb Gives: Stephen submitted the contact-list Google Form Nov 24, 2026 (his word in chat; the form gives no reference number; confirmation page not captured by Claude). Safe to re-run.
begin;
update fs_grant_deadlines set
  next_step='Contact-list form SUBMITTED by Stephen Nov 24, 2026 (no reference number issued). Window CLOSED until 2027, dates unpublished. Recheck https://reverb.com/page/reverb-gives Jan 4, 2027, then monthly; apply the first day it opens: 13 controllers $22,477, 13 headphones, 14 take-home drives at $15 (credits buy gear only).',
  notes=case when coalesce(notes,'') like '%2026-11-24: contact-list form submitted (Reverb Gives)%' then notes else coalesce(notes,'')||E'\n2026-11-24: contact-list form submitted (Reverb Gives) by Stephen (his word in chat). Form issues no reference number; confirmation page not captured.' end
where id='84c13f12-570b-4ef2-9858-1c6b68cefcb2';
select funder,status,next_step_due from fs_grant_deadlines where id='84c13f12-570b-4ef2-9858-1c6b68cefcb2';
commit;

-- Music Farming: Stephen's inquiry to tim@musicfarming.org bounced (Gmail "Address not found", Mon Nov 23 2026 22:51:52 -0800). That is the only email address on musicfarming.org; no other contact is published. Only route: the initial application Typeform (private on Nov 24, 2026). Safe to re-run.
begin;
update fs_grant_deadlines set next_step_due='2027-01-02',
  next_step='Inquiry email to tim@musicfarming.org BOUNCED Nov 23-24, 2026 (address does not exist; it is the only email on musicfarming.org, no other contact published). Do not resend. Only route is the initial application Typeform https://juxzjuo9qnh.typeform.com/to/DPGQGkog (private on Nov 24): recheck https://www.musicfarming.org/apply-for-funding Jan 2, 2027 and file the eligibility form the first day it opens (Spring proposals due beginning of Feb 2027).',
  notes=case when coalesce(notes,'') like '%2026-11-24: inquiry bounced (Music Farming)%' then notes else coalesce(notes,'')||E'\n2026-11-24: inquiry bounced (Music Farming): tim@musicfarming.org does not exist (Gmail NoSuchUser). Site lists no other email, name, phone or address; /contact is 404. Typeform link unchanged and private.' end
where id='ed49e5a0-618d-450b-833e-c7ded43e912a';
select funder,status,next_step_due from fs_grant_deadlines where id='ed49e5a0-618d-450b-833e-c7ded43e912a';
commit;

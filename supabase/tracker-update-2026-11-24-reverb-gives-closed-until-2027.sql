-- Reverb Gives: grant window closed, reopens in 2027 (dates unpublished). Grants are Reverb Credits for gear for youth music education programs. Source: reverb.com/page/reverb-gives, checked Nov 24, 2026. The contact-list form is filled and waiting for Stephen to submit (not yet submitted). Safe to re-run.
begin;
update fs_grant_deadlines set verified=true, verified_on='2026-11-24', next_step_due='2027-01-04',
  next_step='Window CLOSED ("will re-open for new and returning applicants in 2027", no dates). Contact-list Google Form filled Nov 24, 2026; Stephen submits it (tab/ link: https://docs.google.com/forms/d/e/1FAIpQLSeRPMMMRBdZolw6WWDIwgUN5qirJ9p6xn3NahZwa0F-mTI24Q/viewform). Recheck https://reverb.com/page/reverb-gives Jan 4, 2027, then monthly; apply the first day it opens: 13 controllers $22,477, 13 headphones, 14 take-home drives at $15 (credits buy gear only).',
  notes=case when coalesce(notes,'') like '%2026-11-24: window closed (Reverb Gives)%' then notes else coalesce(notes,'')||E'\n2026-11-24: window closed (Reverb Gives). Grants are Reverb Credits for gear, youth music education; eligible: 501(c)(3) youth music programs, fiscally sponsored programs, public schools; need documented. Contact reverbgives@reverb.com is on the funder page. Over 200 programs since 2018 including Chicago Afrorack.' end
where id='84c13f12-570b-4ef2-9858-1c6b68cefcb2';
select funder,status,next_step_due from fs_grant_deadlines where id='84c13f12-570b-4ef2-9858-1c6b68cefcb2';
commit;

-- Reverb Gives contact-list form: proof of submission. Stephen sent screenshots in chat Nov 24, 2026 of the Google Forms confirmation "Reverb Gives: Contact List - Your response has been recorded." (no reference number is issued). Safe to re-run.
begin;
update fs_grant_deadlines set
  notes=case when coalesce(notes,'') like '%2026-11-24: confirmation seen (Reverb Gives)%' then notes else coalesce(notes,'')||E'\n2026-11-24: confirmation seen (Reverb Gives): Stephen sent screenshots in chat of the Google Forms page "Your response has been recorded." Form issues no reference number.' end
where id='84c13f12-570b-4ef2-9858-1c6b68cefcb2';
select funder, (notes like '%confirmation seen (Reverb Gives)%') as proof_logged from fs_grant_deadlines where id='84c13f12-570b-4ef2-9858-1c6b68cefcb2';
commit;

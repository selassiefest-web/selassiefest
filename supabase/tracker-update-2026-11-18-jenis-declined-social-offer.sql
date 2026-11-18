-- Nov 18, 2026: Jeni's Splendid Ice Creams (Givinga support) declined the in-kind donation, offered an Ice Cream Social fundraiser. No fs_partners row exists; the grant row is the record. No is not final. Safe to re-run.
begin;

update fs_grant_deadlines set
  status = 'declined',
  amount_awarded = 0,
  decision_on = '2026-11-15',
  next_step = 'NOT FINAL. Jeni''s offered an alternative: an Ice Cream Social fundraiser at a local scoop shop (Mon-Thu, any time before 6 pm, max 3 hours; Jeni''s donates 25% of proceeds to RTI); apply at Jenis.com/Fundraising. Decide yes/no and apply (verify terms on Jenis.com/Fundraising first). Also reply to Givinga support asking why the donation was declined and whether a smaller or later in-kind request can be considered (next cycle). Do not guess dollar value of the 25% share.',
  next_step_due = '2026-11-20',
  notes = coalesce(notes,'') || E'\n2026-11-15 REPLY (Sun 8:42 pm CT; Mon Nov 16 02:42 UTC): Jeni''s Stewardship Team via Support <support@givinga.com> to stephen@selassiefest.com, subject "Donation Request Update from Jeni''s Splendid Ice Creams", Message-ID <sb4nDWnfRUeMBxFjhOWAYQ@geopod-ismtpd-142>. "While we can''t provide the requested donation this time around, would a fundraising event be a possibility?" Ice Cream Socials: local scoop shop, Mon-Thu before 6 pm, max 3 hours, 25% of proceeds back to RTI, apply at Jenis.com/Fundraising. Answers our Nov 1 email and Givinga application. No reason given. Stephen standing order: no is not final.'
where id = 'a8b28c45-6e95-4bde-977a-19731a044f5b';

commit;
select status, amount_awarded, decision_on, next_step_due, left(next_step,80) from fs_grant_deadlines where id = 'a8b28c45-6e95-4bde-977a-19731a044f5b';

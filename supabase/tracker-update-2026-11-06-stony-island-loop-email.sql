-- Nov 6, 2026: email sent to Loop Capital (info@ and media@) about 7704 S. Stony Island. Safe to re-run.
begin;

update fs_partners set
  stage = 'reached_out', ball_with = 'them',
  last_contact_at = now(),
  next_step = 'Waiting on a reply from Loop Capital (info@ and media@loopcapital.com, sent Nov 6, 2026). If none by Nov 13, Stephen calls 312-913-4900 and asks who handles the Regal Mile / Stony Island property. Also mail the Nov 6 letters (Reynolds, Cogency, Dudley at 1515 Walker Ave, Cronin) if not yet mailed.',
  next_step_due = '2026-11-13',
  notes = coalesce(notes,'') || E'\n2026-11-06 EMAIL SENT from stephen@selassiefest.com (Ras Tafari Inc.) via rti-outreach, Resend id 01a1b1ab-620f-7e8e-93da-f1a332bbaea4, to info@loopcapital.com and media@loopcapital.com, cc stephen@selassiefest.com. Subject: Question about 7704 S. Stony Island Ave (Regal Mile Ventures / South Side Studios Ventures LLC). Asks to be routed to whoever handles the property; offers an interim-use and caretaker agreement (we are caretaker for the upkeep of the entire property, pay for upkeep, security, insurance, owner as additional insured, leave on notice). Does not claim Reynolds works at Loop. Files: Claude outputs/7704-stony-island-resend/loop-capital-email.html and send-loop-capital-email.js.'
where name like 'South Side Studios Ventures LLC (7704%'
  and notes not like '%01a1b1ab-620f-7e8e-93da-f1a332bbaea4%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select p.id, 'email',
 'Nov 6, 2026: emailed Loop Capital at info@loopcapital.com and media@loopcapital.com (cc stephen@selassiefest.com), from stephen@selassiefest.com: asks to be routed to whoever handles the 7704 S. Stony Island property and proposes an interim-use and caretaker agreement. Resend id 01a1b1ab-620f-7e8e-93da-f1a332bbaea4.',
 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
from fs_partners p
where p.name like 'South Side Studios Ventures LLC (7704%'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%01a1b1ab-620f-7e8e-93da-f1a332bbaea4%');

commit;

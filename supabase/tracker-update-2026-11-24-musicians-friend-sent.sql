-- Musician's Friend request SENT by Stephen from stephen@selassiefest.com (Outlook), Tue Nov 24 2026 08:08:20 +0000 (2:08 am CT) to charitablegiving@musiciansfriend.com, cc stephen@. Attachments: request letter on letterhead (PDF) and IRS determination letter. Ask: 13 DJ controllers $22,477 (options $6,916 / $390 / $210). Asks whether Chicago is within their giving communities. Safe to re-run.
begin;
update fs_grant_deadlines set status='submitted', submitted_on='2026-11-24', amount_requested=22477, verified=true, verified_on='2026-11-24',
  next_step_due='2026-12-22',
  next_step='Request emailed Nov 24, 2026 (2:08 am CT) to charitablegiving@musiciansfriend.com on letterhead with the IRS letter: 13 DJ controllers $22,477 (options 4 for $6,916, headphones $390, drives $210); asked whether Chicago is within the communities where their staff live and work. Committee reviews monthly (they want 8 weeks lead time). Follow up Dec 22, 2026 if silent; if they say Chicago is outside their communities, close the row.',
  notes=case when coalesce(notes,'') like '%SJ0P220MB03492B45E5CA37AE0311EE6BD7442%' then notes else coalesce(notes,'')||E'\n2026-11-24: Stephen sent the request from stephen@selassiefest.com to charitablegiving@musiciansfriend.com (cc stephen@), 2:08 am CT, with RTI request letter PDF (letterhead with SelassieFest crest) and IRS letter. Message-ID <SJ0P220MB03492B45E5CA37AE0311EE6BD7442@SJ0P220MB0349.NAMP220.PROD.OUTLOOK.COM>. Address verified on the funder page Nov 24, 2026.' end
where id='845df475-8d46-4800-bfec-55eb54cae276'
  and coalesce(notes, '') not like '%[musicians-friend-bounce 2026-11-25]%';
select funder,status,amount_requested,next_step_due from fs_grant_deadlines where id='845df475-8d46-4800-bfec-55eb54cae276'
  and coalesce(notes, '') not like '%[musicians-friend-bounce 2026-11-25]%';
commit;

-- tracker-update-2026-11-19-foia-6929-owner-and-reply-draft.sql
-- Stephen, Nov 19, 2026: "check the BOB folder and the database, why are you asking me". Evidence found in the repo:
--   bbpac/research/foia_drafts/2-sending/PN-2_jackson-boundary-and-GIS_Steven-Peters.txt names Steven Peters (jamaicanstevie87@gmail.com) as the sender
--   of this request and says "You own the follow-up"; bbpac/organization/onboarding/how-it-works.html lists "Jamaican Stevie" / jamaicanstevie87@gmail.com.
--   A reply draft for Steven to send already exists: Claude outputs/foia-6929-reply/reply-for-steven-peters.txt (Nov 18, 2026).
--   No reply to CPD is in C:\Users\mkepr\Downloads\BOB (only the Oct 7 request and the Nov 13 CPD notice).
-- Safe to re-run (guarded on 'UNVERIFIED: who Steven Peters is').
begin;

update fs_partners
set notes = replace(notes,
      'UNVERIFIED: who Steven Peters is and who holds this account relative to Ras Tafari Inc.; confirm with Stephen.',
      'Steven Peters ("Jamaican Stevie", jamaicanstevie87@gmail.com) is the volunteer who owns this FOIA per the BBPAC FOIA drafts (bbpac/research/foia_drafts/2-sending/PN-2_jackson-boundary-and-GIS_Steven-Peters.txt: "You own the follow-up"). Only he sends from that account. A reply draft for him exists at Claude outputs/foia-6929-reply/reply-for-steven-peters.txt (agrees to the Nov 20 COB extension).'),
    next_step = next_step || ' REPLY DRAFT for Steven Peters to send: C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\foia-6929-reply\reply-for-steven-peters.txt.'
where name = 'Chicago Park District FOIA 6929 (Jackson Park No. 19 boundary, 63rd St Beach GIS)'
  and notes like '%UNVERIFIED: who Steven Peters is%';

commit;

select name, next_step_due, (notes like '%per the BBPAC FOIA drafts%') as owner_noted, (next_step like '%REPLY DRAFT for Steven Peters%') as draft_noted
from fs_partners where name like 'Chicago Park District FOIA 6929%';

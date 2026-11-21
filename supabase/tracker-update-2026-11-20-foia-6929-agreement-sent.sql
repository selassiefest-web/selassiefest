-- FOIA 6929: Steven Peters sent the written agreement to Nov 30 COB, Fri Nov 20, 2026 8:03 pm CST (02:03 UTC Nov 21),
-- From jamaicanstevie87@gmail.com to FOIA@chicagoparkdistrict.com. Source: eml saved at C:\Users\mkepr\Documents\lease\Issues and fixes\09 - Personal Care, Hygiene and Clothing\. Safe to re-run.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'email',
 'Nov 20, 2026 (8:03 pm CST): Steven Peters SENT the written agreement to extend FOIA 6929 to Mon Nov 30, 2026 COB, from jamaicanstevie87@gmail.com to FOIA@chicagoparkdistrict.com, replying to CPD''s 4:14 pm message; asked CPD to send each existing record as it becomes ready. Message-ID <CAMn0-4udFBTpcffEiK0Wq3fQUvGk0KS2SjdtxJi0YNAUT07fVw@mail.gmail.com>. (ref FOIA6929 evt 2026-11-20 20:03 sent)',
 p.stage,'jamaicanstevie87@gmail.com','Steven Peters','2026-11-21 02:03:15+00'::timestamptz
from fs_partners p where p.id='a0eaeac2-9987-41b3-8206-e465a11a9463'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6929 evt 2026-11-20 20:03 sent%');
update fs_partners set ball_with='them', next_step_due='2026-11-30',
 next_step='WAIT for CPD records; agency due Mon Nov 30, 2026 COB (agreement sent by Steven Peters Nov 20, 8:03 pm CST). On Nov 30, if nothing arrives, Steven Peters asks CPD in writing for a firm production date, from jamaicanstevie87@gmail.com only.',
 last_contact_at='2026-11-21 02:03:15+00'::timestamptz
where id='a0eaeac2-9987-41b3-8206-e465a11a9463';
commit;
select name,ball_with,next_step_due,(select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6929 evt 2026-11-20 20:03 sent%') logged from fs_partners p where id='a0eaeac2-9987-41b3-8206-e465a11a9463';

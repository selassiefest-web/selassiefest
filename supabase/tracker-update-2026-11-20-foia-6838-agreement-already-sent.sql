-- FOIA 6838: Stephen already SENT the written agreement to extend to Nov 23 COB on Wed Nov 18, 2026 7:34 pm CST (01:34 UTC Nov 19)
-- from rastafari501c3@gmail.com to FOIA@chicagoparkdistrict.com, replying to CPD's Nov 16 message. Source: BOB .eml (Message-ID below). Safe to re-run.
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id,'email',
 'Nov 18, 2026 (7:34 pm CST): Stephen SENT the written agreement to extend FOIA 6838 (Maggie Daley Park / North Grant Park / Park No. 1303) to Mon Nov 23, 2026 COB, from rastafari501c3@gmail.com to FOIA@chicagoparkdistrict.com, replying to CPD''s Nov 16 request. Message-ID <CAG0kn=UbCj1nKXrWE5t3r2om2gg-hgDFEWaFqZEOgkKH5znOPQ@mail.gmail.com>. (ref FOIA6838 evt 2026-11-18 19:34 sent)',
 p.stage,'rastafari501c3@gmail.com','Stephen Henry','2026-11-19 01:34:22+00'::timestamptz
from fs_partners p where p.id='91fad49d-bff1-4b1f-a611-e6de12145eb5'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6838 evt 2026-11-18 19:34 sent%');
update fs_partners set ball_with='them', next_step_due='2026-11-23',
 next_step = 'WAIT for CPD. FOIA 6838 agency due Mon Nov 23, 2026 COB (agreement already sent Nov 18). Dec 2 in-person review of FOIA 6903 at CPD (confirm time/room Nov 30). FOIA 6925 due Nov 30 COB (agreement sent Nov 20). On Nov 23 COB, if no 6838 records, reply from rastafari501c3@gmail.com asking for a firm production date.'
where id='91fad49d-bff1-4b1f-a611-e6de12145eb5';
commit;
select ball_with,next_step_due,(select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%FOIA6838 evt 2026-11-18 19:34 sent%') logged from fs_partners p where id='91fad49d-bff1-4b1f-a611-e6de12145eb5';

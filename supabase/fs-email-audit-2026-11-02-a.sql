-- Outlook email audit batch A (Nov 2, 2026). Source: stephen@selassiefest.com mailbox, threads read in full.
-- Siragusa: ImpactCouncil@siragusa.org replied Mon Nov 2, 2026 9:19 AM CT to Stephen's Oct 31 notify-me note: "we will make sure to add you to next year's mailing list."
-- Hilton: HGF declined Nov 2 (already recorded); the live next step is our own call to a downtown Hilton, so the ball is ours.
begin;
update fs_partners set ball_with = 'us', updated_at = now() where name = 'Hilton' and ball_with <> 'us';

update fs_partners set
  last_contact_at = timestamptz '2026-11-02 09:19-06',
  next_step = 'I.M.P.A.C.T. Council replied Nov 2: you are on next year''s mailing list (the Oct 26 deadline was missed; no 2026 round). Watch for the next round announcement; check Dec 1.',
  updated_at = now()
where name = 'Siragusa Family Foundation' and next_step like 'Notify-me email SENT Oct 31%';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email', 'Reply from I.M.P.A.C.T. Council (ImpactCouncil@siragusa.org), Nov 2: "we will make sure to add you to next year''s mailing list." Auto-reply Oct 31 confirmed receipt. No 2026 round open to us.', p.stage, 'stephen@selassiefest.com', 'Stephen Henry', timestamptz '2026-11-02 09:19-06'
from fs_partners p where p.name = 'Siragusa Family Foundation'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Reply from I.M.P.A.C.T. Council%');
update fs_grant_deadlines set
  next_step = 'Notify-me email SENT Oct 31; I.M.P.A.C.T. Council REPLIED Nov 2: we are on next year''s mailing list. Watch for the next round; check Dec 1.',
  updated_at = now()
where funder = 'Siragusa Family Foundation' and next_step like 'Notify-me email SENT Oct 31%' and next_step not like '%REPLIED Nov 2%';

select p.name, p.ball_with, p.last_contact_at::date lc, (select count(*) from fs_partner_activity a where a.partner_id = p.id) acts from fs_partners p where p.name in ('Hilton','Siragusa Family Foundation');
commit;

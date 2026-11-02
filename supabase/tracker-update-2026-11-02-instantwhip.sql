-- Tracker update, Nov 2, 2026: Instantwhip-Chicago email sent (Resend id 01a19e8e-072d-748c-9224-98179f2d60b9).
-- Apply with: supabase db query --linked -f supabase/tracker-update-2026-11-02-instantwhip.sql
update fs_partners set
  stage = 'reached_out',
  next_step = 'Email SENT Nov 2, 2026 (id 01a19e8e-072d-748c-9224-98179f2d60b9) to info@instantwhipfoods.com, cc stephen@. Wait; if no reply by Mon Nov 9, call (773) 235-5588 or 800-214-1413.',
  next_step_due = date '2026-11-09',
  last_contact_at = now(), updated_at = now()
where name = 'Instantwhip-Chicago, Inc.';
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select id, 'email', 'Emailed info@instantwhipfoods.com (cc stephen@): small weekly wrapped novelties (about 20 Tue + 30 Wed, about 1,200 servings in 2027), donated or nonprofit pricing. Resend id 01a19e8e-072d-748c-9224-98179f2d60b9.', 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry'
from fs_partners where name = 'Instantwhip-Chicago, Inc.'
and not exists (select 1 from fs_partner_activity a where a.partner_id = fs_partners.id and a.summary like '%01a19e8e-072d%');

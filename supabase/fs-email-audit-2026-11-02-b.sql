-- Outlook email audit batch B (Nov 2, 2026). ASCAP Foundation partner row was still not_contacted with a "find the starting point" step,
-- while the grant row and the mailbox show: contact-form inquiry Oct 31 8:46 PM CT, reply from Ariya Sonethavy Nov 2 11:26 AM CT inviting a
-- one-page proposal (501(c)(3) only), and Stephen's reply Nov 2 12:12 PM CT (one-pager for the $5,000 My Song Project, per the grant row).
begin;
update fs_partners set
  stage = 'reached_out',
  ball_with = 'them',
  last_contact_at = timestamptz '2026-11-02 12:12-06',
  email = 'asonethavy@ascap.com',
  phone = '212-621-8347',
  contacts = jsonb_build_array(jsonb_build_object('name','Ariya Sonethavy','role','Communications & Operations Coordinator, The ASCAP Foundation (they/them)','email','asonethavy@ascap.com','phone','212-621-8347')),
  next_step = 'One-page proposal ($5,000 My Song Project) sent Nov 2 at their invitation. Waiting on their review. One nudge about Nov 20 or Nov 23. Separate ASCAP licensing question (Message B) still unsent.',
  next_step_due = date '2026-11-20',
  notes = coalesce(notes,'') || chr(10) || 'Nov 2: process confirmed by the Foundation (proposals by invitation; they invited a one-page proposal; grants to 501(c)(3)s only). Contact form sent Oct 31 via foundation@ascap.com.',
  updated_at = now()
where name = 'ASCAP Foundation' and stage = 'not_contacted';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, v.kind, v.summary, 'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', v.at::timestamptz
from fs_partners p, (values
  ('email', 'Foundation Contact Us form sent to foundation@ascap.com asking how a youth music program comes to the Foundation''s attention (it considers proposals by invitation).', '2026-10-31 20:46-05'),
  ('email', 'Reply from Ariya Sonethavy, The ASCAP Foundation: send a one-page proposal about the program and request; grants only to 501(c)(3) nonprofits.', '2026-11-02 11:26-06'),
  ('email', 'Replied to Ariya with the one-page proposal ($5,000 My Song Project) and IRS letter; asked their review timeline and preferred request size.', '2026-11-02 12:12-06')
) as v(kind, summary, at)
where p.name = 'ASCAP Foundation'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary = v.summary);

select p.name, p.stage, p.ball_with, p.next_step_due, (select count(*) from fs_partner_activity a where a.partner_id = p.id) acts from fs_partners p where p.name = 'ASCAP Foundation';
commit;

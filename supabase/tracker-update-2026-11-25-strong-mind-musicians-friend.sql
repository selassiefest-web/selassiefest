-- Strong Mind eligibility form sent Nov 25, 2026; Musician's Friend Nov 24 email bounced. Safe to re-run.
begin;

update fs_grant_deadlines
set status = 'drafting',
    amount_requested = 1409,
    next_step = 'Eligibility form SENT Nov 25, 2026 (on-screen "Thank you for your message. It has been sent."). Planned $1,409: 1 XDJ-AN deck $1,199 + 14 take-home USB drives $210. They say they answer within 3 business days and send a one-page application if eligible. Check Dec 2.',
    next_step_due = date '2026-12-02',
    notes = coalesce(notes, '') || ' | [strong-mind-inquiry 2026-11-25] Community Grants Eligibility form at https://strongmindstrongbody.org/community-grants-program/inquiry/ sent by Stephen. Inquiry, not yet an application. Prior: to_research, due 2026-12-10, amount null.',
    owner = 'Stephen',
    updated_at = now()
where id = 'bef5b48a-edff-4a36-b199-8b76d87eba2a'
  and coalesce(notes, '') not like '%[strong-mind-inquiry 2026-11-25]%';

update rti_calendar_events set active = false
where key = 'dec10-research-2026-12-10' and active;

update fs_grant_deadlines
set status = 'to_research',
    submitted_on = null,
    amount_requested = null,
    next_step = 'NOT DELIVERED: the Nov 24, 2026 request to charitablegiving@musiciansfriend.com bounced (550 5.4.1, address not found). Stephen to decide whether to look for a working online route. Do not resend to that address. Any new ask uses 13 XDJ-AN decks x $1,199 = $15,587.',
    next_step_due = null,
    notes = coalesce(notes, '') || ' | [musicians-friend-bounce 2026-11-25] Delivery failure from Microsoft Outlook dated Nov 24, 2026 2:08 am CT for Message-ID <SJ0P220MB03492B45E5CA37AE0311EE6BD7442@SJ0P220MB0349.NAMP220.PROD.OUTLOOK.COM>; seen in the stephen@ inbox Nov 25. Earlier status submitted and $22,477 amount reversed because the request never arrived. Published address bounced. Prior: submitted_on 2026-11-24, next_step_due 2026-12-22.',
    verified = false,
    updated_at = now()
where id = '845df475-8d46-4800-bfec-55eb54cae276'
  and coalesce(notes, '') not like '%[musicians-friend-bounce 2026-11-25]%';

insert into rti_calendar_events (key, title, starts_at, ends_at, place, notes)
values ('strong-mind-check-2026-12-02', 'Strong Mind: check for eligibility reply and one-page application',
  timestamptz '2026-12-02 09:15-06', timestamptz '2026-12-02 09:30-06', 'Online (email)',
  'Eligibility form sent Nov 25. Check inbox and spam; if silent, follow up online only.')
on conflict (key) do nothing;

commit;

select funder, status, submitted_on, amount_requested, next_step_due, left(next_step, 140) as next_step
from fs_grant_deadlines
where id in ('bef5b48a-edff-4a36-b199-8b76d87eba2a', '845df475-8d46-4800-bfec-55eb54cae276');

select key, active, starts_at from rti_calendar_events where key in ('strong-mind-check-2026-12-02', 'dec10-research-2026-12-10');

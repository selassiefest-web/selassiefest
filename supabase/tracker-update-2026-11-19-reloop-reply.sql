-- 2026-11-19: Reloop Support reply (redirect to US distributor Reloop USA / American Music & Sound).
-- Source: BOB\AW__Following_up__education_demo_setup_for_a_free_youth_DJ_class.eml
-- Message-ID <c30ef27b48f04d738bfe2b2e562a6e44@reloop.com>; In-Reply-To <010001a1f1ead495-235286a6-78ba-4178-a16b-057d810354b9-000000@email.amazonses.com>
-- Sent Thu 2026-11-19 08:11:40 UTC (2:11 am CT). Safe to re-run. Activity is inserted only if the update fired.
-- Stage stays reached_out (support-desk redirect, no engagement); ball moves to us. Dates marked "proposed" are ours, not the email's.
begin;

with u as (
  update fs_partners
  set ball_with = 'us',
      last_contact_at = '2026-11-19 08:11:40+00',
      next_step = 'Reloop Support replied Nov 19, 2026 and redirected us to Reloop USA / American Music & Sound, 22020 Clarendon St, Suite 305, Woodland Hills CA 91367 (as given in the email). NEXT (proposed, needs Stephen''s go before anything is sent): send a two-sentence note to American Music & Sound, online only, no phone, asking for one demo turntable setup or a US education contact for our free youth DJ class in Chicago, with the pitch deck link https://selassiefest.com/full-spectrum/deck.html. Proposed send by Nov 20; if no answer, check Dec 4, 2026.',
      next_step_due = '2026-11-20',
      contacts = '[{"name":"Reloop Support Team","role":"From-address of the Nov 19, 2026 reply (Reloop / Global Distribution, Muenster, Germany); not a named person","email":"support@reloop.com"},{"name":"Reloop USA / American Music & Sound","role":"US distributor named in the Nov 19, 2026 reply; Reloop told us to contact them directly; phone +1 800 431 2609 (as given in the email)","website":"www.americanmusicandsound.com"}]'::jsonb,
      notes = coalesce(notes,'') || E'\n[2026-11-19] REPLY from Reloop Support (support@reloop.com), Nov 19, 2026 2:11 am CT, Message-ID <c30ef27b48f04d738bfe2b2e562a6e44@reloop.com>, to our Nov 18 follow-up. Redirect only: contact Reloop USA / American Music & Sound directly (22020 Clarendon St, Suite 305, Woodland Hills CA 91367, +1 800 431 2609, www.americanmusicandsound.com). No contact name, no gear, no program offered, no dollar value. [src:msgid-c30ef27b48f04d738bfe2b2e562a6e44]'
  where id = 'aad5ab14-8354-47f0-ac24-a09f195f03a2'
    and stage = 'reached_out' and ball_with = 'them'
    and coalesce(notes,'') not like '%msgid-c30ef27b48f04d738bfe2b2e562a6e44%'
  returning id
)
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select u.id, 'email',
  'Nov 19, 2026 (2:11 am CT; 08:11 UTC) REPLY from Reloop Support (support@reloop.com), subject "AW: Following up: education demo setup for a free youth DJ class", answering our Nov 18 follow-up (In-Reply-To <010001a1f1ead495-235286a6-78ba-4178-a16b-057d810354b9-000000@email.amazonses.com>). Redirect only: get in touch directly with the US distributor, Reloop USA / American Music & Sound, 22020 Clarendon Street, Suite 305, Woodland Hills CA 91367, +1 800 431 2609, www.americanmusicandsound.com. No contact name, no gear, no program, no value offered. Ball moves to us. Message-ID <c30ef27b48f04d738bfe2b2e562a6e44@reloop.com>. [src:msgid-c30ef27b48f04d738bfe2b2e562a6e44]',
  'reached_out', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 08:11:40+00'
from u;

commit;

select p.id, p.name, p.stage, p.ball_with, p.next_step_due, p.last_contact_at,
       jsonb_array_length(p.contacts) as contacts_n,
       (select count(*) from fs_partner_activity a where a.partner_id = p.id) as activity_n,
       (select count(*) from fs_partner_activity a where a.partner_id = p.id and a.summary like '%msgid-c30ef27b48f04d738bfe2b2e562a6e44%') as this_msg_activity_n
from fs_partners p where p.id = 'aad5ab14-8354-47f0-ac24-a09f195f03a2';
-- Expected: reached_out | us | 2026-11-20 | 2026-11-19 08:11:40+00 | contacts_n 2 | activity_n 4 | this_msg_activity_n 1

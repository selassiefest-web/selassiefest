-- 2026-11-19: Joyce Foundation reply (Bridget, Applications inbox) copying the Culture Program Assistant.
-- Source: BOB\RE__Letter_of_inquiry_question__free_youth_DJ_lab_on_Chicago's_South_Side.eml
-- Message-ID <DS2PR15MB6905072C0194E3B80CE40F64D5792@DS2PR15MB6905.namprd15.prod.outlook.com>
-- In-Reply-To <CO6P220MB03382FFE7E7D5E4CA3C02F21D7792@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM> (our Nov 18 Nudge A)
-- Sent Thu 2026-11-19 14:28:07 UTC (8:28 am CST). Safe to re-run: guarded on the msgid marker in notes.
-- Handoff only: no answer yet on program fit, the $16,800 LOI idea or the Dec 1 cycle. Stage and ball unchanged.
-- Partner row and grant row are updated in one transaction; activity inserts only if the partner update fired.
begin;

with u as (
  update fs_partners
  set last_contact_at = '2026-11-19 14:28:07+00',
      next_step = 'Joyce replied Nov 19, 2026 (Bridget, Applications) and copied Maddie Easton, Program Assistant for Culture, who will assist. Still NO answer on fit, on an LOI for the $16,800 sound/technical line, or on whether Dec 1 is open. Waiting on Maddie. No reply needed now (Stephen asked Nov 18). If silent, Mon Dec 1, 2026: reply in the same thread with Bridget and Maddie both on the To line, online only, restating the two questions. Otherwise next proposal deadline Apr 1, 2027 (LOI about early-mid Feb 2027).',
      next_step_due = '2026-12-01',
      contacts = '[{"name":"Bridget","role":"Applications inbox (applications@joycefdn.org); handed us to Culture on Oct 29 and again Nov 19, 2026","email":"applications@joycefdn.org"},{"name":"Maddie Easton","role":"Program Assistant for Culture; copied by Bridget Nov 19, 2026 as the person to assist","email":"MEaston@joycefdn.org"}]'::jsonb,
      notes = coalesce(notes,'') || E'\n[2026-11-19] REPLY from Bridget (applications@joycefdn.org), Nov 19, 2026 8:28 am CST, Cc Maddie Easton (MEaston@joycefdn.org), answering our Nov 18 Nudge A: Bridget copied Maddie Easton to assist Handoff only: no answer on fit, on an LOI for the $16,800 production line, or on the Dec 1 cycle. Maddie is now on the thread. Message-ID <DS2PR15MB6905072C0194E3B80CE40F64D5792@DS2PR15MB6905.namprd15.prod.outlook.com>. [src:msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792]'
  where id = '670cf826-1b34-49ac-b1f9-a0b582debb18'
    and stage = 'in_conversation' and ball_with = 'them'
    and coalesce(notes,'') not like '%msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792%'
  returning id
),
g as (
  update fs_grant_deadlines
  set next_step = 'Joyce replied Nov 19, 2026 (Bridget) and copied Maddie Easton (Culture Program Assistant). Still no answer on cycle (Dec 1 proposal deadline vs Apr 1, 2027 with LOI early-mid Feb) or on an LOI for the $16,800 line. Waiting on Maddie. If silent, Mon Dec 1, 2026: reply in thread to Bridget and Maddie, online only.',
      next_step_due = '2026-12-01',
      notes = coalesce(notes,'') || E'\n[2026-11-19] Bridget (applications@joycefdn.org) replied Nov 19 8:28 am CST and copied Maddie Easton (MEaston@joycefdn.org) to assist; no answer yet on fit or Dec 1. No amount or status change (still $16,800 requested, drafting). Partner row 670cf826-1b34-49ac-b1f9-a0b582debb18. [src:msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792]'
  where id = 'dc25d586-f390-4553-964a-01fd8090c8e1'
    and status = 'drafting'
    and coalesce(notes,'') not like '%msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792%'
  returning id
)
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select u.id, 'email',
  'Nov 19, 2026 (8:28 am CST; 14:28 UTC) REPLY from Bridget at Joyce Foundation Applications (applications@joycefdn.org), Cc Maddie Easton (MEaston@joycefdn.org), subject "RE: Letter of inquiry question: free youth DJ lab on Chicago''s South Side", answering our Nov 18 Nudge A (In-Reply-To <CO6P220MB03382FFE7E7D5E4CA3C02F21D7792@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM>). Substance: Bridget copied Maddie Easton to assist Handoff only. No answer yet on program fit, an LOI for the $16,800 sound/technical line, or the Dec 1 cycle. No attachments. Ball stays with Joyce (Maddie). Message-ID <DS2PR15MB6905072C0194E3B80CE40F64D5792@DS2PR15MB6905.namprd15.prod.outlook.com>. [src:msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792]',
  'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-19 14:28:07+00'
from u;

commit;

select p.id, p.name, p.stage, p.ball_with, p.next_step_due, p.last_contact_at,
       jsonb_array_length(p.contacts) as contacts_n,
       (select count(*) from fs_partner_activity a where a.partner_id = p.id) as activity_n,
       (select count(*) from fs_partner_activity a where a.partner_id = p.id and a.summary like '%msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792%') as this_msg_activity_n,
       (select status || ' | ' || next_step_due || ' | ' || amount_requested from fs_grant_deadlines where id = 'dc25d586-f390-4553-964a-01fd8090c8e1') as grant_state,
       (select count(*) from fs_grant_deadlines where id = 'dc25d586-f390-4553-964a-01fd8090c8e1' and notes like '%msgid-DS2PR15MB6905072C0194E3B80CE40F64D5792%') as grant_noted
from fs_partners p where p.id = '670cf826-1b34-49ac-b1f9-a0b582debb18';
-- Expected: in_conversation | them | 2026-12-01 | 2026-11-19 14:28:07+00 | contacts_n 2 | activity_n 5 | this_msg 1 | drafting | 2026-12-01 | 16800.00 | grant_noted 1

-- tracker-update-2026-11-24-alphatheta-meeting.sql
-- Nov 23, 2026 Teams meeting (source: Stephen in chat, Nov 24; no .eml) and our Nov 24 reply (source: Outlook Sent Items screenshot). Neutral public page and weekly-email rows.
-- Re-runnable: updates guarded by expected current values (md5 hashes) and [src:] markers; the insert is keyed by fixed id.
begin;

-- 1. Meeting activity
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'meeting',
  'Nov 23, 2026 (3:30 pm CT): Microsoft Teams meeting held. Attendees: Israel Rodriguez (Education & Training Manager, AlphaTheta Music Americas) and Albert Harris. We use the name Rainbow DJ Lab. We told Israel we would send him our system builder link and the Audima links; the reply went out Nov 24 (separate entry). The Club YOXO / Yokohama introduction was not discussed. Private arrangement; terms are in Stephen''s mailbox and are not recorded here. Source: Stephen in chat, Nov 24, 2026; no .eml. [src:alphatheta-meeting-20261123]',
  'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-23 15:30:00-06'::timestamptz
from fs_partners p
where p.id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id
                  and position('[src:alphatheta-meeting-20261123]' in a.summary) > 0);

-- 1b. Our reply, sent Nov 24 11:46 pm CT. No saved .eml or Message-ID, so keyed on a marker.
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'email',
  'Nov 24, 2026 (11:46 pm CT): reply SENT to israel.rodriguez@alphatheta.com, cc stephen@selassiefest.com, in the "Following up: Start From Scratch in Chicago" thread, signed in Albert Harris''s name: meeting thank-you; controller choice awaiting Audima input; system builder, Audima and video links sent. Private arrangement; terms are not recorded here. Source: Stephen''s Outlook Sent Items screenshot; no saved .eml or Message-ID. [src:israel-reply-sent-20261124]',
  'in_conversation', 'stephen@selassiefest.com', 'Stephen Henry', '2026-11-24 23:46:00-06'::timestamptz
from fs_partners p
where p.id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id
                  and position('[src:israel-reply-sent-20261124]' in a.summary) > 0);

-- 2. Partner row, including the fields shown on its private-link page. Old values are kept in notes (not public).
update fs_partners set
  ball_with = 'them',
  last_contact_at = greatest(last_contact_at, '2026-11-24 23:46:00-06'::timestamptz),
  commitment = 'Private arrangement; terms are in Stephen''s mailbox and are not recorded here.',
  next_step = 'Waiting on Israel Rodriguez (reply sent Nov 24) and on Audima (Jeremy Buckley, Isaac Jack) for input on controller choice for Sway; pass that input to Israel when it arrives. Proposed follow-up Mon Dec 7: check both and draft a note if needed; send only after Stephen says send. Keep the haptics loan a separate ask.',
  next_step_due = '2026-12-07',
  pitch = 'Ras Tafari Inc. runs the Rainbow DJ Lab, a free year-round DJ class for young people on Chicago''s South Side, every Tuesday from 4 to 6 pm, opening January 12, 2027. Students work through 14 Missions at their own pace.',
  ask = null,
  ask_intro = null,
  ask_items = '[]'::jsonb,
  gear = '{}'::jsonb,
  notes = coalesce(notes,'')
    || E'\n[2026-11-23] Teams meeting held (Israel Rodriguez, Albert Harris). We use the name Rainbow DJ Lab. Reply to Israel sent Nov 24, 11:46 pm CT. Awaiting Audima input on controller choice for Sway. Club YOXO / Yokohama introduction not discussed; tracked as its own row. Private arrangement; terms are in Stephen''s mailbox and are not recorded here. Private-link page rewritten to neutral wording. [src:alphatheta-meeting-20261123] [src:israel-reply-sent-20261124]'
    || E'\nPrevious next step: ' || coalesce(next_step,'(none)')
    || E'\nPrevious commitment text: ' || coalesce(commitment,'(none)')
    || E'\nPrevious page pitch: ' || coalesce(pitch,'(none)')
    || E'\nPrevious page ask: ' || coalesce(ask,'(none)')
    || E'\nPrevious page ask items: ' || ask_items::text
    || E'\nPrevious plan-page gear wording: ' || gear::text,
  updated_at = now()
where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
  and stage = 'in_conversation' and ball_with = 'us' and next_step_due = '2026-11-25'
  and md5(next_step) = '7b10e70f8471f95a3e77724f09a326c2'
  and md5(commitment) = '4ce0e58b9093cf26f6e7d416391452e6'
  and md5(pitch) = '21b04e81d8ac09e797006f816610f594'
  and md5(ask) = 'f68c502f65758dbcf7ed273fc7aa53bc'
  and ask_intro is null
  and md5(ask_items::text) = '8db440e73579851d991d1898cd478bf5'
  and md5(gear::text) = 'aa208abcf5c78a43587c686a65dff9ed'
  and position('[src:alphatheta-meeting-20261123]' in coalesce(notes,'')) = 0;

-- 3. Grant row: active=false takes it out of the Sunday email (which prints notes of active submitted rows).
--    Status and submitted_on stay as the historical record.
update fs_grant_deadlines set
  active = false,
  program = 'Rainbow DJ Lab (education relationship)',
  next_step = 'No separate application or deadline. Followed on the partner record.',
  next_step_due = null,
  notes = coalesce(notes,'')
    || E'\n[2026-11-24] Nov 23 meeting held. Row set inactive: there is no open application to track here and the relationship is followed on the partner record. Previous program name: ' || coalesce(program,'(none)')
    || E'. Previous next step: ' || coalesce(next_step,'(none)') || ' [src:alphatheta-grant-inactive-20261124]',
  updated_at = now()
where id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e'
  and status = 'submitted' and active and next_step_due = '2026-11-25'
  and program = 'Start From Scratch (DJ education access)'
  and md5(next_step) = '1b4528b8182780b0432d345bae6a09ec'
  and position('[src:alphatheta-grant-inactive-20261124]' in coalesce(notes,'')) = 0;

-- 4. New row: Club YOXO / Yokohama introduction. No public page (pitch_key null).
insert into fs_partners (id, name, category, partner_types, program_parts, stage, ball_with, next_step, next_step_due, source, notes, pitch_key)
select '7c3f9a52-1d64-4b8e-9f27-5a0c8e41b6d3',
  'Club YOXO (Yokohama): introduction for Rainbow Wednesday', 'Other',
  array['programming'], array['wednesdays'], 'not_contacted', 'cpd_hold',
  'Proposed date (ours, not agreed with anyone): after we report on the 1st Rainbow DJ Lab class (Jan 12, 2027), raise a Club YOXO introduction with Israel Rodriguez for Rainbow Wednesday. Nothing is sent until the Chicago Park District gives the GO.',
  '2027-01-26', 'Stephen in chat, Nov 24, 2026',
  '[2026-11-24] Stephen: the Club YOXO / Yokohama introduction was not discussed at the Nov 23 meeting; he wants it tracked as its own item for a later date, after we report on the 1st DJ class. Jan 26, 2027 is a proposed date. Nothing has been sent about it since that meeting; no existing row found. Related partner row a2e09e2e-5916-4e5a-b232-2369cfc8b57a. [src:yoxo-item-20261124]',
  null
where not exists (select 1 from fs_partners where id = '7c3f9a52-1d64-4b8e-9f27-5a0c8e41b6d3' or name ilike '%yoxo%');

-- 5. Assert every change is present before commit
do $$
begin
  if (select count(*) from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
        and kind = 'meeting' and position('[src:alphatheta-meeting-20261123]' in summary) > 0) <> 1 then
    raise exception 'meeting activity missing or duplicated';
  end if;
  if (select count(*) from fs_partner_activity where partner_id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
        and kind = 'email' and position('[src:israel-reply-sent-20261124]' in summary) > 0) <> 1 then
    raise exception 'sent-reply activity missing or duplicated';
  end if;
  if not exists (select 1 from fs_partners where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
        and position('[src:alphatheta-meeting-20261123]' in notes) > 0
        and position('[src:israel-reply-sent-20261124]' in notes) > 0) then
    raise exception 'partner update did not land (a current value changed since review)';
  end if;
  if exists (select 1 from fs_partners where id = 'a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
        and concat_ws(' ', pitch, ask, ask_intro, ask_items::text, gear::text) ~* '(start from scratch|alphatheta|pioneer|donate)') then
    raise exception 'public page fields still carry old wording';
  end if;
  if not exists (select 1 from fs_grant_deadlines where id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e'
        and position('[src:alphatheta-grant-inactive-20261124]' in notes) > 0 and not active) then
    raise exception 'grant update did not land or row is active again';
  end if;
  if (select count(*) from fs_partners where id = '7c3f9a52-1d64-4b8e-9f27-5a0c8e41b6d3'
        and position('[src:yoxo-item-20261124]' in notes) > 0 and pitch_key is null) <> 1 then
    raise exception 'Club YOXO row missing or has a public key (check for a differently keyed row)';
  end if;
end $$;

commit;

-- 6. Verify (read only; does not call the page function, so no page view is counted)
select 'partner' as rec, p.id::text as id, p.stage as stage_or_status, p.ball_with as ball_or_active, p.next_step_due::text as due,
  p.commitment as detail,
  concat_ws(' | ', p.pitch, coalesce(p.ask,'(no ask)'), p.ask_items::text, p.gear::text) as page_fields,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('[src:alphatheta-meeting-20261123]' in a.summary) > 0)::text as meeting_rows,
  (select count(*) from fs_partner_activity a where a.partner_id = p.id and position('[src:israel-reply-sent-20261124]' in a.summary) > 0)::text as reply_rows
from fs_partners p where p.id in ('a2e09e2e-5916-4e5a-b232-2369cfc8b57a','7c3f9a52-1d64-4b8e-9f27-5a0c8e41b6d3')
union all
select 'grant', g.id::text, g.status, g.active::text, g.next_step_due::text, g.program, null, null, null
from fs_grant_deadlines g where g.id = 'f575d085-f8ee-4f12-a90d-bcf7e2a4d28e';

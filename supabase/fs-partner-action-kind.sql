-- Tracker item 4 (Nov 2, 2026): tag each active partner's next step as a walk stop, a call, an email or research,
-- so "walk stop" can be told apart from "needs an email or call". Generated from next_step / stage / next_step_due,
-- so it stays correct when the next step is edited and needs no change to fs_partner_save.
-- Apply: supabase db query --linked -f supabase/fs-partner-action-kind.sql   (safe to re-run)
-- fs_partners_load returns to_jsonb(p), so the page receives action_kind with no function change.
alter table fs_partners drop column if exists action_kind;
alter table fs_partners add column action_kind text generated always as (
  case
    when stage not in ('not_contacted','reached_out','in_conversation','meeting_set') then null
    when next_step is null or btrim(next_step) = '' then null
    when next_step ~* '^(find|read|search|look|research|verify|ask)' then 'research'
    when next_step ~* '^call' then 'call'
    when next_step ~* '^email' then 'email'
    when stage = 'not_contacted' and next_step_due between date '2026-11-06' and date '2026-11-08' then 'walk'
    when next_step ~* 'hand-deliver|deliver the letter|drop off|walk' then 'walk'
    when next_step ~* 'by phone|call if|call or' then 'call'
    when next_step ~* 'email|send|reply' then 'email'
    else null
  end
) stored;
create index if not exists fs_partners_action_kind_idx on fs_partners (action_kind, next_step_due);

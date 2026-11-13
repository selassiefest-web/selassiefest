-- ===========================================================================
-- Venue evaluation for the RTI board room (/rti/board/budget/). Extends the
-- budget room (supabase/rti-board-budget.sql): each series/venue now also has
-- a shared due-diligence checklist (sections A-I), a venue record and a board
-- decision, worked on live by every director.
--
-- One row per (series, key):
--   checklist findings  key 'A1'..'I6'          status pass|issue|fail|na|'' + note (evidence)
--   venue record        key 'meta.<field>'      value in note
--   board decision      key 'decision.<field>'  value in note
-- Every change is also written to rti_bb_history with kind = 'item'.
-- The checklist questions live in the page code (public, generic); findings
-- live only here. Read/written only by the rti-board-budget edge function.
-- ===========================================================================
create table if not exists public.rti_bb_items (
  series_id   text not null references public.rti_bb_series (id) on delete cascade,
  key         text not null check (key ~ '^([A-I][0-9]{1,2}|meta\.[a-z_]{1,30}|decision\.[a-z_]{1,30})$'),
  status      text not null default '' check (status in ('','pass','issue','fail','na')),
  note        text not null default '' check (char_length(note) <= 4000),
  member_id   bigint references public.rti_bb_members (id),
  updated_at  timestamptz not null default now(),
  primary key (series_id, key)
);

alter table public.rti_bb_history add column if not exists kind text not null default 'budget';
alter table public.rti_bb_history add column if not exists item_key text;

comment on table public.rti_bb_items is 'Venue checklist findings, venue record and board decision fields per series. Edge function only.';

alter table public.rti_bb_items enable row level security;

-- Area analysis (added 2026-11-13): who could complain about a venue's
-- activities. Computed by the rti-board-budget "area" action from the US Census
-- geocoder (municipality, block-group/tract population and housing) and
-- OpenStreetMap via Overpass (parking, nearest homes, residential streets,
-- schools/churches, other nightlife). Stored so every director sees one result.
alter table public.rti_bb_series add column if not exists area jsonb;
alter table public.rti_bb_series add column if not exists area_at timestamptz;

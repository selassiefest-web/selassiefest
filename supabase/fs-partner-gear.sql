-- ─────────────────────────────────────────────────────────────────────────
-- Personalized equipment lines for the DJ Lab plan page.
-- /full-spectrum/dj-lab-2027.html?k=<pitch_key> shows a partner its own
-- brand on the budget lines it would supply; with no key (or no gear set)
-- the page shows brand-neutral wording ("brand open to our equipment partner").
--
-- gear: {"controllers": "Roland DJ controllers and beat-making instruments ...",
--        "headphones": "...", "booths": "..."}
-- Keys match data-gear="..." on the plan page's budget rows:
--   controllers, laptops, headphones, power, tables, booths.
--
-- fs_partner_gear only reads; it does not count a pitch view (the deck or
-- partner page that linked here already counted it).
--
-- Apply with: supabase db query --linked -f supabase/fs-partner-gear.sql
-- Safe to re-run. Partner rows are seeded out of band (never committed).
-- ─────────────────────────────────────────────────────────────────────────
alter table fs_partners add column if not exists gear jsonb not null default '{}'::jsonb;

create or replace function fs_partner_gear(p_key text)
returns table (name text, gear jsonb)
language sql stable security definer set search_path = public as $$
  select p.name, p.gear from fs_partners p where p.pitch_key = p_key and p_key is not null;
$$;
grant execute on function fs_partner_gear(text) to anon, authenticated;

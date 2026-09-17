-- Fix: a visitor with ANY lingering Supabase Auth session on this origin
-- (e.g. a bbpac_formation_members login from elsewhere on the site) gets
-- PostgREST role 'authenticated', not 'anon' -- and every policy/grant
-- below was anon-only, so that visitor silently got zero rows / a denied
-- insert instead of an error. The tracker has no real user accounts of its
-- own (identity is the volunteer roster + magic link), so both roles
-- should be treated the same here.

drop policy if exists "anon can request a tracker login link if a known volunteer" on bbpac_tracker_login_links;
create policy "known volunteer can request a tracker login link" on bbpac_tracker_login_links
  for insert to anon, authenticated
  with check (bbpac_tracker_is_volunteer(email));

drop policy if exists "anyone can read tracker items" on bbpac_tracker_items;
create policy "anyone can read tracker items" on bbpac_tracker_items
  for select to anon, authenticated
  using (true);

drop policy if exists "anyone can read tracker updates" on bbpac_tracker_updates;
create policy "anyone can read tracker updates" on bbpac_tracker_updates
  for select to anon, authenticated
  using (true);

grant execute on function bbpac_tracker_is_volunteer(text) to authenticated;
grant execute on function bbpac_tracker_verify_login_link(uuid) to authenticated;
grant execute on function bbpac_tracker_add_update(uuid, uuid, text, text) to authenticated;

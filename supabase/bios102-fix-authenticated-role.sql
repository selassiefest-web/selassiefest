-- Fix: same bug as bbpac-tracker-fix-authenticated-role.sql. A visitor with
-- ANY lingering Supabase Auth session on this origin (e.g. a
-- bbpac_formation_members login from elsewhere on the site) gets PostgREST
-- role 'authenticated', not 'anon' -- and the BIOS102 login-link insert
-- policy was anon-only, so that visitor's link request was denied and the
-- login page reported "not on the class roster" even for an enrolled email.
-- BIOS102 has no Supabase Auth accounts of its own (identity is the roster
-- + magic link), so both roles should be treated the same. The bios102_*
-- functions already carry the default PUBLIC execute grant, so only the
-- two anon-only policies need widening.

drop policy if exists "anon can request a bios102 login link if enrolled" on bios102_login_links;
drop policy if exists "enrolled student can request a bios102 login link" on bios102_login_links;
create policy "enrolled student can request a bios102 login link" on bios102_login_links
  for insert to anon, authenticated
  with check (bios102_is_enrolled(email));

drop policy if exists "Allow anon insert to bios102-organism-photos" on storage.objects;
drop policy if exists "Allow insert to bios102-organism-photos" on storage.objects;
create policy "Allow insert to bios102-organism-photos" on storage.objects
  for insert to anon, authenticated
  with check (bucket_id = 'bios102-organism-photos');

drop policy if exists "Allow public read of bios102-organism-photos" on storage.objects;
create policy "Allow public read of bios102-organism-photos" on storage.objects
  for select to anon, authenticated
  using (bucket_id = 'bios102-organism-photos');

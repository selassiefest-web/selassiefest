-- Add students to the BIOS102 roster as their emails come in. Edit the rows, then:
--   supabase db query --linked -f supabase/bios102-add-students.sql
-- Safe to re-run (existing emails are left alone). Do NOT commit real student
-- emails: copy this file to "Claude outputs" and fill it in there.
-- Students then sign in at /BIOS102/ with the emailed link and find Research Match
-- on their dashboard. major is free text ('Biology', 'Undeclared', ...); anything
-- starting with 'Instructor' is treated as an instructor account.
begin;
insert into bios102_students (email, display_name, major) values
  ('example.student@rangers.uwp.edu', 'Example Student', 'Undeclared')
on conflict (email) do nothing;
commit;
select count(*) as roster_size from bios102_students;

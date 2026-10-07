-- Public form tables no longer take direct anon/authenticated inserts
-- (applied in the SQL editor 10/7/2026). Bots were using the open inserts to
-- add rows and trigger emails. Every form below now posts to the
-- public-submit edge function (Turnstile + honeypot + per-IP throttle +
-- column allowlist), which inserts with the service role. This overrides the
-- "Allow anon insert" policies and `grant insert ... to anon` lines for these
-- tables in schema.sql and the other *.sql files. newsletter_subscribers was
-- closed the same way earlier (newsletter-signup function).
do $$
declare t text; p record;
begin
  foreach t in array array[
    'anansi_story_submissions','volunteer_signups','sponsor_inquiries','camp_registrations',
    'game_submissions','vendor_applications','security_guard_contracts','plates_for_purpose_responses',
    'bbpac_meeting_notify','bbpac_volunteer_signups','bbpac_membership_signups','bbpac_sponsor_inquiries',
    'bbpac_vendor_applications','bbpac_contact_messages','bbpac_photo_submissions',
    'bbpac_formation_section_signup_requests','clrwf_quote_requests','clrwf_maintenance_agreement_requests',
    'clrwf_contact_messages','clrwf_job_applications','yawd_waitlist']
  loop
    for p in select policyname from pg_policies
             where schemaname = 'public' and tablename = t and cmd = 'INSERT' loop
      execute format('drop policy %I on public.%I', p.policyname, t);
    end loop;
    execute format('revoke insert on public.%I from anon, authenticated', t);
  end loop;
end $$;

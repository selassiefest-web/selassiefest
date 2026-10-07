-- Removes the 2nd Chance Housing lease e-signature bridge (10/7/2026).
-- selassiefest.com/lease-sign/ is gone; 2nd Chance Housing signs leases in
-- its own system (the lease repo / 2ndchinc.org), and nothing there calls
-- this project. Stephen confirmed none of the data here is needed.
-- Run once in the SQL editor; triggers go with their tables. The two storage
-- buckets (lease-signed-pdfs, lease-draft-pdfs) are emptied and deleted in the
-- dashboard (Storage), since Supabase blocks deleting storage files with SQL.

drop function if exists get_lease_signing_request(uuid);
drop table if exists lease_signatures;          -- also drops its two triggers
drop table if exists lease_signing_requests;    -- also drops its trigger
drop function if exists mark_lease_signing_request_completed();

drop policy if exists "Allow anon insert to lease-signed-pdfs" on storage.objects;
drop policy if exists "Allow anon insert to lease-draft-pdfs" on storage.objects;

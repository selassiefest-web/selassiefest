-- Donor thank-you pages (rti/donation/ tool -> /donors/?k=KEY). Locked down: only the rti-donor-page edge function (service role) reads or writes.
begin;
create table if not exists rti_donor_pages (
  key text primary key,
  donor text not null,
  request_no text,
  html text not null,
  created_at timestamptz not null default now(),
  views int not null default 0,
  last_viewed_at timestamptz
);
alter table rti_donor_pages enable row level security;
commit;
select count(*) as donor_pages from rti_donor_pages;

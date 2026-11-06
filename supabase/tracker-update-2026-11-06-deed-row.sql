-- Nov 6, 2026: Deed (Bonterra) platform account row + login-change email. Safe to re-run.
begin;

insert into fs_partners (name, category, stage, ball_with, email, last_contact_at, next_step, next_step_due, notes)
select 'Deed (Bonterra)', 'Other', 'confirmed', 'us', 'nonprofits@joindeed.com', '2026-11-06T12:35:11Z',
 'Tue Nov 10, 2026: Deed login moves to Bonterra. Go to admin.joindeed.org/login, click "Log in" (never "Sign up"), Next, password. Same email and password. Confirm login works, then confirm Spark Good shows Active for the Walmart Cycle 3 application.',
 '2026-11-10',
 E'PLATFORM ACCOUNT, not a funder or sponsor. Deed (a Bonterra product) is the volunteering/giving platform that verified Ras Tafari Inc. for Walmart Spark Good (verified and Walmart affiliation approved Oct 20, 2026; Spark Good sync unconfirmed). Linked grant row: Walmart / Sam''s Club, Spark Good Local Grants FY27 Cycle 3 (ebb1afe5-1d4b-4dd4-a7b2-5bcdb6e9aa8c).\n2026-11-06 notice from The Deed Team (nonprofits@joindeed.com), Message-ID <3fc941e5-ece7-42c3-96af-ac1d0b3bfb73@gsemail.gainsightapp.com>: login moves to Bonterra (auth.bonterra.network) on Tue Nov 10. Allow bonterra.network in email filters. Reset-password link is on the Bonterra screen. Browser autofill may not work the first time. Nothing to set up in advance. Help: nonprofits@joindeed.com.'
where not exists (select 1 from fs_partners where name = 'Deed (Bonterra)');

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select p.id, 'email',
 'Nov 6, 2026 email from The Deed Team (nonprofits@joindeed.com) to stephen@selassiefest.com, "New login for Deed on Tuesday, November 10": Deed login moves to Bonterra on Tue Nov 10; same email and password; use "Log in" not "Sign up". Informational, no reply needed. Message-ID <3fc941e5-ece7-42c3-96af-ac1d0b3bfb73@gsemail.gainsightapp.com>.',
 'confirmed', 'nonprofits@joindeed.com', 'The Deed Team'
from fs_partners p
where p.name = 'Deed (Bonterra)'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%3fc941e5-ece7%');

commit;

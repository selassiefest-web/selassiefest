-- Benevity Causes Portal: bring the partner row, grant row and activity log up to date (Nov 2, 2026).
-- Sources: legal/documents-inbox/CURRENT-STATUS.md items 9 and the Thu Nov 5 Chase meeting; Claude outputs/grants/benevity-donation-method-fill-sheet.md.
-- Not a grant: money only arrives when an employee or company picks us, so no dollar commitment is recorded.
begin;

update fs_partners set
  stage = 'confirmed',
  ball_with = 'us',
  commitment = 'Registered and APPROVED in the Benevity Causes Portal Nov 1, 2026 (EIN 42-3036705). No dollar amount: gifts arrive when employees or companies choose us, paid by EFT once the Donation Method is set.',
  next_step = 'Stephen: (1) Declaration, any time (https://app.causes.benevity.org/attestations/840-423036705). (2) Donation Method (EFT) is WAITING on the Chase meeting Thu Nov 5, 9:00 AM CT (Riverdale branch, Kenyatta Webb): get the account verification letter on letterhead + EFT routing number, then use the fill sheet. (3) Then Account Completion to 100% and add a logo.',
  next_step_due = date '2026-11-05',
  notes = coalesce(notes,'') || chr(10) || 'Nov 2: TFA on, Cause Profile saved (publishes within 24h; address left as South Holland per the IRS-address rule), Self-Certification done. Donation Method form has no save-draft, so it stays unfilled until the Chase letter is in hand. Fill sheet: C:\Users\mkepr\Documents\GitHub\selassiefest\Claude outputs\grants\benevity-donation-method-fill-sheet.md',
  updated_at = now()
where name = 'Benevity Causes Portal' and notes not like '%Donation Method form has no save-draft%';

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note', v.summary, 'confirmed', 'stephen@selassiefest.com', 'Stephen Henry', v.at::timestamptz
from fs_partners p, (values
  ('Benevity Causes Portal application APPROVED (Benevity email Nov 1, 08:46 UTC). Registered under EIN 42-3036705.', '2026-11-01 03:46-05'),
  ('Benevity setup Nov 2: two-factor on, Cause Profile saved, Self-Certification completed by Stephen. Declaration still to do.', '2026-11-02 12:00-06'),
  ('Donation Method (EFT) paused: needs the Chase account verification letter and routing number. Chase meeting booked Thu Nov 5, 9:00 AM CT, Riverdale branch with Kenyatta Webb. After the letter: submit the Donation Method using the fill sheet.', '2026-11-02 18:00-06')
) as v(summary, at)
where p.name = 'Benevity Causes Portal'
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary = v.summary);

update fs_grant_deadlines set
  next_step = 'Nov 2 done: registration ACTIVE, 2-factor ON, Cause Profile saved (publishes within 24 hours), Self-Certification COMPLETED. LEFT: (1) Declaration (https://app.causes.benevity.org/attestations/840-423036705), Stephen, any time. (2) Donation Method (EFT), Stephen only: WAITING on the Chase meeting Thu Nov 5, 9:00 AM CT (Riverdale, Kenyatta Webb) for the account verification letter + EFT routing number; it cannot be saved as a draft, so do it in one sitting after the meeting (https://causes.benevity.org/causesapp/payouts/add/840-423036705; fill sheet in Claude outputs\grants\benevity-donation-method-fill-sheet.md). (3) Then Account Completion to 100% and add a logo. Rule: no naming a Benevity corporate donor publicly without that client''s written consent. Renew the Self-Certification yearly (Nov 2027).',
  next_step_due = date '2026-11-05',
  updated_at = now()
where funder = 'Benevity Causes Portal' and next_step not like '%WAITING on the Chase meeting%';

select p.name, p.stage, p.ball_with, p.next_step_due, left(p.commitment,60) commitment, (select count(*) from fs_partner_activity a where a.partner_id=p.id) acts,
       (select next_step_due from fs_grant_deadlines where funder='Benevity Causes Portal') grant_due
from fs_partners p where p.name = 'Benevity Causes Portal';
commit;

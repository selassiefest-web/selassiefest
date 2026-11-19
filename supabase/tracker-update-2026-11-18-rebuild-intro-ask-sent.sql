-- 2026-11-18: Rebuild Foundation introduction ask SENT at Stephen's "send" (rti-outreach, Resend 01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d),
-- stephen@ to info@rebuild-foundation.org, cc stephen@. Asks for two introductions: Good Chaos (Christy MacLear / Elizabeth Armour) and Jerry Fogelson; links the pitch deck. Safe to re-run (guarded).
begin;
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select 'df05922a-d53a-43a1-b074-ea1949c266e1','email',
 'Introduction ask SENT Nov 18, 2026 (Resend 01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d) to info@rebuild-foundation.org, cc stephen@: asks for two introductions (Good Chaos: Christy MacLear or Elizabeth Armour; Jerry Fogelson), a 20-minute conversation; promises not to use Rebuild''s name without agreement and to copy them; links pitch deck https://selassiefest.com/full-spectrum/deck.html. Follows letters of Oct 18 and Oct 28 (no real reply, auto-reply only).',
 'reached_out','stephen@selassiefest.com','Stephen Henry', now()
where not exists (select 1 from fs_partner_activity where partner_id='df05922a-d53a-43a1-b074-ea1949c266e1' and summary like '%01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d%');
update fs_partners set ball_with='them', last_contact_at=now(),
 next_step='Intro ask sent Nov 18 (Good Chaos, Fogelson). Wait for Rebuild; if silent, one follow-up Wed Dec 2. Send the matching packet within 24 hours of any introduction and copy the Rebuild introducer. Do not name Rebuild to funders without their agreement.',
 next_step_due='2026-12-02'
where id='df05922a-d53a-43a1-b074-ea1949c266e1' and next_step not like 'Intro ask sent Nov 18%';
update fs_grant_deadlines set next_step='Rebuild asked Nov 18 (Resend 01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d) to introduce us to Good Chaos (Christy MacLear / Elizabeth Armour). Wait for Rebuild; if they introduce, send 12-rebuild-list/06-good-chaos.md within 24 hours and copy the introducer. No intro by Dec 2 = park.',
 next_step_due='2026-12-02', notes=coalesce(notes,'')||E'\n[2026-11-18] Intro ask sent to Rebuild (Resend 01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d).'
where id='1d1db2f7-40c3-4594-928e-12bb2e27ed21' and coalesce(notes,'') not like '%01a1f1d4-a62a-7a82%';
update fs_grant_deadlines set next_step='Rebuild asked Nov 18 (Resend 01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d) to introduce us to Jerry Fogelson. Wait for Rebuild; if they introduce, send 12-rebuild-list/11-fogelson-family-foundation.md ($3,900 snacks, 13 Tuesdays) within 24 hours and copy the introducer. No intro by Dec 2 = park.',
 next_step_due='2026-12-02', notes=coalesce(notes,'')||E'\n[2026-11-18] Intro ask sent to Rebuild (Resend 01a1f1d4-a62a-7a82-bd00-5d9f60b9cc8d).'
where id='b32c816f-bdfa-42b5-869e-45b17f4a7eae' and coalesce(notes,'') not like '%01a1f1d4-a62a-7a82%';
commit;
select (select count(*) from fs_partner_activity where summary like '%01a1f1d4-a62a%') acts,(select next_step_due from fs_partners where id='df05922a-d53a-43a1-b074-ea1949c266e1') p,(select count(*) from fs_grant_deadlines where notes like '%01a1f1d4-a62a%') grants;

-- Nov 21, 2026. Outlook "Partnered" intake: 8 unlogged partner emails found among 25 .eml files exported to Downloads\BOB.
-- Reviewed by partner-grant-data-quality-reviewer (corrections applied). Activity rows use the email's real Date header as created_at.
-- Every insert is guarded on the Message-ID local part; last_contact_at only ever moves forward (greatest). Safe to re-run: a second run inserts 0 and updates 0.
-- Not changed (needs Stephen): Ivry stage, Joyce ball_with, Roland ball_with, old Serato created_at repairs, Joyce grant row dc25d586 (grants-awards-steward).
begin;

-- 1. AlphaTheta (a2e09e2e): Israel, Nov 18 21:53 UTC
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 18, 2026 (3:53 pm CT): Israel Rodriguez (AlphaTheta) replied to Stephen''s Nov 16 email (Stephen: "I accepted the meeting and will see you then. Anything you need from me?"): "I do not need anything. See you next week." Meeting Mon Nov 23, 3:30 pm CT (4:30 pm ET), Teams. (Message-ID local part TY7P286MB688276D7D93AADF343E3E40FEC7A2)','in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-18 21:53:04+00'
from fs_partners p where p.id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%TY7P286MB688276D7D93AADF343E3E40FEC7A2%');

update fs_partners set
 next_step = replace(next_step,'Stephen says he accepted it Nov 18 (his word; no acceptance email or calendar evidence on file).','Acceptance: Stephen''s Nov 16 email says he accepted (quoted in Israel''s Nov 18 reply); Israel confirmed Nov 18 (3:53 pm CT) he needs nothing from us and will see us next week; Stephen''s chat said Nov 18; Teams calendar status not verified.'),
 last_contact_at = greatest(coalesce(last_contact_at,'-infinity'),'2026-11-18 21:53:04+00'), updated_at=now()
where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a' and next_step like '%Stephen says he accepted it Nov 18%';

-- 2. Roland (f34194d7): out-of-office auto-reply (a note, not contact; last_contact_at untouched)
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'note','Nov 18, 2026 (10:18 pm CT; Nov 19 04:18 UTC): automatic out-of-office from Jared Selter replying to our Nov 18 nudge: out 11/17 to 11/27, receiving email, may be slow to respond. Auto-reply, not a decision. True Date header used (it sorts just before the nudge row, which was stamped 61 seconds later at processing). (Message-ID local part b97a053625044f00affa77cd3d571876)','in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-19 04:18:40+00'
from fs_partners p where p.id='f34194d7-0ce8-4a67-81e8-722eda18b9cf'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%b97a053625044f00affa77cd3d571876%');

update fs_partners set next_step = next_step || ' Jared out of office 11/17 to 11/27 (auto-reply Nov 18 10:18 pm CT); nudge Dec 2 stands.', updated_at=now()
where id='f34194d7-0ce8-4a67-81e8-722eda18b9cf' and next_step not like '%Jared out of office 11/17 to 11/27%';

-- 3-5. Serato (85a2975b): ticket 1231468 backfills + welcome email (no partner field changes)
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 16, 2026 (8:19 pm CT; Nov 17 02:19 UTC), ticket 1231468: Brad D (Serato Sales) will look into it and asks for proof of non-profit status. (Message-ID local part M69PGZZEJ01_6afbb9bd414b1_834832c37c63df_sprut)','in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-17 02:19:41+00'
from fs_partners p where p.id='85a2975b-ae91-4f6f-b7d7-7dd14181c167'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%M69PGZZEJ01_6afbb9bd414b1_834832c37c63df_sprut%');

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 16, 2026 (8:29 pm CT; Nov 17 02:29 UTC), ticket 1231468: Brad D says he can provide software for the classes; Serato does not make educational software and student age raises data concerns, so he linked the Student Data Policy to be signed and returned. The quoted thread shows Stephen sent the IRS letter, certified articles and Goodstack verification at 8:28 pm CT (Nov 17 02:28 UTC), between Brad''s two messages. (Message-ID local part M69PGZZEJ01_6afbbc0943ca2_03a4d1bae00418_sprut)','in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-17 02:29:29+00'
from fs_partners p where p.id='85a2975b-ae91-4f6f-b7d7-7dd14181c167'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%M69PGZZEJ01_6afbbc0943ca2_03a4d1bae00418_sprut%');

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'note','Nov 20, 2026 (3:28 pm CT; 21:28 UTC): automated "Welcome to Serato" to stephen@selassiefest.com confirming the account created Nov 20 (Rainbow DJ Lab / DJ VIBGYOR). Body is an HTML image with no readable text. Not a license grant. (Message-ID local part RiBPX89WRrG8npSKLHI6RA)','in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-20 21:28:56+00'
from fs_partners p where p.id='85a2975b-ae91-4f6f-b7d7-7dd14181c167'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%RiBPX89WRrG8npSKLHI6RA%');

-- 6-7. CPD Ivry Ector (381db08e): her Nov 19 reply, Stephen's Nov 19 FYI (backfill, minutes from quoted header), her Nov 20 reply; put on CPD hold
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 19, 2026 (1:48 pm CT; 19:48 UTC): Ivry Ector (Rainbow Beach Park Supervisor) replied to our Nov 18 Roots & Shoots $250 / lawn-plan email: "All of these are wonderful ideas." But because the partnership is not yet approved she cannot give any suggestion; her input begins once approval is complete. No choice of the nine ideas, no plan submitted. Evidence of receipt only; not approval. (Message-ID local part SA0PR09MB6315A11AFD0304684DF6580386792)','reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-19 19:48:59+00'
from fs_partners p where p.id='381db08e-a28a-4466-b74b-261cd248a4a1'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%SA0PR09MB6315A11AFD0304684DF6580386792%');

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 19, 2026 (about 2:34 pm CT; about 20:34 UTC, minutes taken from the quoted header in Ivry''s Nov 20 reply): Stephen told Ivry that international DJ equipment makers and program managers are exploring bringing their overseas DJ programs to the U.S. with us. This is Stephen''s statement to her, not a confirmed partner commitment (no manufacturer has committed; Shure is the only donor; AlphaTheta, Roland and Serato are in conversation). (Message-ID local part CO6P220MB033896078CF304E2E902E14ED7792)','reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-19 20:34:00+00'
from fs_partners p where p.id='381db08e-a28a-4466-b74b-261cd248a4a1'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%CO6P220MB033896078CF304E2E902E14ED7792%');

insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 20, 2026 (9:24 am CT; 15:24 UTC): Ivry replied "That is so exciting. I can''t wait" to Stephen''s Nov 19 FYI about DJ equipment makers. Courtesy acknowledgment only. No decision or commitment. (Message-ID local part SA0PR09MB6315F1B86EF7572EFD19C2B686782)','reached_out','stephen@selassiefest.com','Stephen Henry','2026-11-20 15:24:05+00'
from fs_partners p where p.id='381db08e-a28a-4466-b74b-261cd248a4a1'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%SA0PR09MB6315F1B86EF7572EFD19C2B686782%');

update fs_partners set ball_with='cpd_hold', next_step_due=null,
 next_step='ON CPD HOLD. Ivry (Rainbow Beach Park Supervisor) said Nov 19 she cannot advise on the lawn plan or the $250 Roots & Shoots art grant until the CPD partnership is approved; her input starts after approval. No nudges or new asks to Ivry until CPD GO. Gate row: fc21556e (CPD Rainbow Legacy approval, owner us, permission request not yet sent). Resume with the lawn-plan choice after approval.',
 last_contact_at = greatest(coalesce(last_contact_at,'-infinity'),'2026-11-20 15:24:05+00'), updated_at=now()
where id='381db08e-a28a-4466-b74b-261cd248a4a1' and next_step not like 'ON CPD HOLD. Ivry%';

-- 8. Joyce (670cf826): Maddie Easton, Nov 20 22:31 UTC (last_contact_at already later; greatest keeps it)
insert into fs_partner_activity (partner_id,kind,summary,stage_after,by_email,by_name,created_at)
select p.id,'email','Nov 20, 2026 (4:31 pm CT; 22:31 UTC): Maddie Easton (Culture and Democracy Program Assistant) replied to Stephen''s 4:21 pm questions. (1) "You could potentially be on track for that following April cycle," but she cannot say which cycle a registered grant would be considered for; the Culture program director decides alongside other grants and the rest-of-year plans. (2) On fit, it would help Joyce to understand how the program interacts with and engages both artists and the community. No decision; no April date was named by Joyce. (Message-ID local part LV0SPRMB001221199874F49FBD31FF67D7782)','in_conversation','stephen@selassiefest.com','Stephen Henry','2026-11-20 22:31:29+00'
from fs_partners p where p.id='670cf826-1b34-49ac-b1f9-a0b582debb18'
 and not exists (select 1 from fs_partner_activity a where a.partner_id=p.id and a.summary like '%LV0SPRMB001221199874F49FBD31FF67D7782%');

update fs_partners set
 next_step='Fluxx registration SUBMITTED Nov 20. Maddie (Nov 20, 4:31 pm CT): possibly on track for the following April cycle but Joyce cannot say which cycle; the Culture program director decides. She said it would help Joyce to understand how the program engages artists and the community (the registration already frames Rainbow Wednesdays as the all-ages series with neighborhood artists). Wait for Joyce''s review email (approval opens an LOI). Follow up once in the same thread Mon Dec 1 if silent; status questions: applications@joycefdn.org.',
 last_contact_at = greatest(coalesce(last_contact_at,'-infinity'),'2026-11-20 22:31:29+00'), updated_at=now()
where id='670cf826-1b34-49ac-b1f9-a0b582debb18' and next_step like '%waiting on Maddie''s answer about the Apr 1, 2027 cycle%';

commit;

select 'activity_rows' k, count(*)::text v from fs_partner_activity a
 where a.summary ~ '(TY7P286MB688276D7D93AADF343E3E40FEC7A2|b97a053625044f00affa77cd3d571876|M69PGZZEJ01_6afbb9bd414b1_834832c37c63df_sprut|M69PGZZEJ01_6afbbc0943ca2_03a4d1bae00418_sprut|RiBPX89WRrG8npSKLHI6RA|SA0PR09MB6315A11AFD0304684DF6580386792|CO6P220MB033896078CF304E2E902E14ED7792|SA0PR09MB6315F1B86EF7572EFD19C2B686782|LV0SPRMB001221199874F49FBD31FF67D7782)'
union all select 'ivry', ball_with||' | '||coalesce(next_step_due::text,'null')||' | '||last_contact_at::text from fs_partners where id='381db08e-a28a-4466-b74b-261cd248a4a1'
union all select 'alphatheta', last_contact_at::text||' | '||left(next_step,60) from fs_partners where id='a2e09e2e-5916-4e5a-b232-2369cfc8b57a'
union all select 'joyce', last_contact_at::text||' | '||left(next_step,60) from fs_partners where id='670cf826-1b34-49ac-b1f9-a0b582debb18'
union all select 'roland', last_contact_at::text||' | '||right(next_step,70) from fs_partners where id='f34194d7-0ce8-4a67-81e8-722eda18b9cf';

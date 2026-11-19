-- 2026-11-18: fix ASM nudge activity: real send time + eml Message-ID. Safe to re-run.
begin;
update fs_partner_activity
set created_at = '2026-11-19 02:54:26+00',
    summary = summary || ' Message-ID <010001a1f1ba148f-f127c32c-eaf4-4e7e-b374-778594f05e57-000000@email.amazonses.com>; sent 2026-11-18 8:54 pm CST.'
where id = '581b256c-fbf8-4671-b576-08a7f8be984d'
  and partner_id = 'ffa174aa-db33-4f38-b21c-af00273717f2'
  and summary not like '%010001a1f1ba148f%';

update fs_partners
set last_contact_at = '2026-11-19 02:54:26+00'
where id = 'ffa174aa-db33-4f38-b21c-af00273717f2'
  and last_contact_at > '2026-11-19 02:54:26+00' and last_contact_at < '2026-11-19 03:30:00+00';

update fs_grant_deadlines
set notes = notes || E'\n[2026-11-18] Sent copy Message-ID <010001a1f1ba148f-f127c32c-eaf4-4e7e-b374-778594f05e57-000000@email.amazonses.com> (Nov 18 8:54 pm CST).'
where id = 'd52c3cbd-d864-4e9e-a09d-718e08c07460'
  and notes not like '%010001a1f1ba148f%';
commit;

select a.created_at, right(a.summary,160) tail, a.summary like '%010001a1f1ba148f%' act_has_mid,
       p.last_contact_at, p.next_step_due p_due,
       g.notes like '%010001a1f1ba148f%' g_has_mid, g.next_step_due g_due
from fs_partner_activity a, fs_partners p, fs_grant_deadlines g
where a.id = '581b256c-fbf8-4671-b576-08a7f8be984d'
  and p.id = 'ffa174aa-db33-4f38-b21c-af00273717f2'
  and g.id = 'd52c3cbd-d864-4e9e-a09d-718e08c07460';

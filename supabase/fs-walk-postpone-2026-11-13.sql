-- Walk postponed one week (Stephen, Nov 5 2026): Fri Nov 13 to Sun Nov 15, roll to Mon Nov 16.
-- Safe to re-run: only touches rows still due Nov 6 to 9.
begin;
update fs_partners set next_step_due = next_step_due + 7 where next_step_due between date '2026-11-06' and date '2026-11-09';
create or replace function fs_walk_load(p_session uuid)
returns jsonb language plpgsql security definer set search_path = public stable as $$
declare u record;
begin
  select * into u from fs_partner_session_user(p_session);
  return jsonb_build_object(
    'partners', coalesce((
      select jsonb_agg(jsonb_build_object(
        'id', p.id, 'name', p.name, 'category', p.category, 'address', p.address, 'phone', p.phone,
        'stage', p.stage, 'next_step', p.next_step, 'next_step_due', p.next_step_due, 'hours_note', p.hours_note,
        'pitch_key', p.pitch_key,
        'walk_last', (select a.summary from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %' order by a.created_at desc limit 1),
        'walk_log', (select coalesce(jsonb_agg(jsonb_build_object('by', a.by_name, 'at', a.created_at, 'text', a.summary) order by a.created_at desc), '[]'::jsonb) from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %'),
        'walk_by', (select a.by_name from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %' order by a.created_at desc limit 1),
        'walk_at', (select a.created_at from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %' order by a.created_at desc limit 1),
        'scans', (select count(*) from fs_partner_scans s where s.pitch_key = p.pitch_key),
        'scan_last', (select max(s.created_at) from fs_partner_scans s where s.pitch_key = p.pitch_key)
      ) order by p.name)
      from fs_partners p
      where (p.stage = 'not_contacted' and p.next_step_due between date '2026-11-13' and date '2026-11-15')
         or exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Walk %')
    ), '[]'::jsonb)
  );
end $$;
commit;
select next_step_due, count(*) from fs_partners where next_step_due between date '2026-11-06' and date '2026-11-16' group by 1 order by 1;

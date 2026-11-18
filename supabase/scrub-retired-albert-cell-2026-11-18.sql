-- Nov 18, 2026: Albert's old cell (262-344-7075) was turned off; Stephen ordered every trace removed. Replaced with 312-296-9816. Safe to re-run.
begin;
update fs_partners set
  notes = regexp_replace(notes, '\+?1?[ -]?\(?262\)?[-. ]*344[-. ]*7075', '312-296-9816', 'g'),
  next_step = regexp_replace(next_step, '\+?1?[ -]?\(?262\)?[-. ]*344[-. ]*7075', '312-296-9816', 'g')
where notes ~ '262[-. )]*344[-. ]*7075' or next_step ~ '262[-. )]*344[-. ]*7075';
update fs_grant_deadlines set notes = regexp_replace(notes, '\+?1?[ -]?\(?262\)?[-. ]*344[-. ]*7075', '312-296-9816', 'g') where notes ~ '262[-. )]*344[-. ]*7075';
update fs_partner_activity set summary = regexp_replace(summary, '\+?1?[ -]?\(?262\)?[-. ]*344[-. ]*7075', '312-296-9816', 'g') where summary ~ '262[-. )]*344[-. ]*7075';
commit;
-- verify: scan every public text/jsonb column for the retired number
do $$
declare r record; n int; tot int := 0;
begin
  for r in select table_name, column_name, data_type from information_schema.columns
           where table_schema='public' and data_type in ('text','character varying','jsonb','json','ARRAY')
             and table_name in (select table_name from information_schema.tables where table_schema='public' and table_type='BASE TABLE') loop
    execute format('select count(*) from %I where %I::text ~ %L', r.table_name, r.column_name, '262[-. )]*344[-. ]*7075') into n;
    if n > 0 then raise notice 'REMAINING % %: %', r.table_name, r.column_name, n; tot := tot + n; end if;
  end loop;
  raise notice 'total remaining rows: %', tot;
end $$;
select count(*) as partners_left from fs_partners where to_jsonb(fs_partners)::text ~ '262[-. )]*344[-. ]*7075';

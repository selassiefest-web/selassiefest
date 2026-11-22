-- Nov 21, 2026: shut the building down. Remove table permissions the public/logged-in roles never need.
-- (1) 115 RLS tables with ZERO policies: revoke everything from anon and authenticated (grants were useless: RLS already denied).
-- (2) All other public tables (RLS + policies): revoke only TRUNCATE, TRIGGER, REFERENCES (RLS cannot govern TRUNCATE).
-- (3) Future tables created by postgres in public no longer auto-grant to anon/authenticated.
-- Views, functions, sequences and the service_role are untouched. Idempotent (revoke is a no-op when already revoked).
begin;
do $$
declare r record; n_all int := 0; n_part int := 0;
begin
  for r in
    select c.relname,
      (select count(*) from pg_policies p where p.schemaname='public' and p.tablename=c.relname) pol
    from pg_class c
    where c.relnamespace='public'::regnamespace and c.relkind='r' and c.relrowsecurity
  loop
    if r.pol = 0 then
      execute format('revoke all on table public.%I from anon, authenticated', r.relname); n_all := n_all + 1;
    else
      execute format('revoke truncate, trigger, references on table public.%I from anon, authenticated', r.relname); n_part := n_part + 1;
    end if;
  end loop;
  raise notice 'revoked all on % no-policy tables; revoked truncate/trigger/references on % policy tables', n_all, n_part;
end $$;
alter default privileges in schema public revoke all on tables from anon, authenticated;
commit;
select
 (select count(*) from information_schema.role_table_grants g join pg_class c on c.relname=g.table_name and c.relnamespace='public'::regnamespace and c.relkind='r' where g.table_schema='public' and g.grantee in ('anon','authenticated') and g.privilege_type in ('TRUNCATE','TRIGGER','REFERENCES')) destructive_left,
 (select count(*) from information_schema.role_table_grants g where g.table_schema='public' and g.table_name in ('fs_partners','fs_partner_activity') and g.grantee in ('anon','authenticated')) partner_grants_left;

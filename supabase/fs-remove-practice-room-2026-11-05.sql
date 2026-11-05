-- Stephen, Nov 5 2026: the winter "practice room" ask is removed everywhere. Safe to re-run.
begin;
update fs_partners set ask = 'Could your youth leader review one short DJ-learning invitation and share it with your families?'
 where name in ('Haven of Rest Missionary Baptist Church','First Presbyterian Church of Chicago')
   and ask ~* '(winter|supervised DJ session)';
update fs_partners set
  next_step = replace(replace(next_step,'asked 3 clarifying questions','asked 2 clarifying questions'),', (3) why winter practice',''),
  notes = replace(replace(notes,', and details on winter practice;',';'),', and why winter practice;',';')
 where name = 'First Presbyterian Church of Chicago';
update fs_partner_activity set summary = replace(replace(summary,', and why winter practice;',';'),', and details on winter practice;',';')
 where summary ~* 'winter practice' and partner_id in (select id from fs_partners where name='First Presbyterian Church of Chicago');
commit;
select name, ask ~* 'winter|practice' as ask_bad, next_step ~* 'winter|practice' as ns_bad, notes ~* 'winter practice|practice room' as notes_bad from fs_partners where name in ('Haven of Rest Missionary Baptist Church','First Presbyterian Church of Chicago');
select count(*) as activity_bad from fs_partner_activity where summary ~* 'winter practice|practice room';

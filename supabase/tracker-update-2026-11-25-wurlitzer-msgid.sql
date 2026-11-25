-- Message-ID for the Nov 24 Wurlitzer / DeKalb inquiry (saved by the mail sorter). Safe to re-run.
begin;
update fs_grant_deadlines set notes = concat_ws(E'\n', notes, '[2026-11-24] Sent copy on file: inquiry to george@dekalbccf.org, cc stephen@, 11:18 pm CT. [src:msgid-CO6P220MB0338730DAB3A1C089499BD0ED7432@CO6P220MB0338.NAMP220.PROD.OUTLOOK.COM]'), updated_at = now()
where id = '013d3944-c420-4534-b9af-7f3a604c0235' and position('CO6P220MB0338730DAB3A1C089499BD0ED7432' in coalesce(notes,'')) = 0;
commit;
select funder, status, next_step_due, position('CO6P220MB0338730DAB3A1C089499BD0ED7432' in notes) > 0 as logged from fs_grant_deadlines where id = '013d3944-c420-4534-b9af-7f3a604c0235';

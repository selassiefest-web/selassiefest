-- BIOS102 Research Match: stop a stale device from silently overwriting newer saved work.
-- The client sends its state with a "_base" key = the "_t" of the server version it last loaded or
-- saved. If the stored state's "_t" differs, the save is refused with 'rm_conflict' and the page
-- asks the student which version to keep. Equality check, so device clocks do not matter.
-- A client that does not send "_base" (an old cached page) still saves as before.
-- Safe to re-run (create or replace). Apply: supabase db query --linked -f supabase/bios102-research-match-conflict.sql
begin;

create or replace function bios102_rm_save(p_session uuid, p_state jsonb)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_email text := bios102_rm_email(p_session);
  v_at timestamptz;
  v_cur_t text;
  v_has_row boolean;
begin
  if v_email is null then
    raise exception 'invalid or expired BIOS102 session';
  end if;
  if p_state is null or jsonb_typeof(p_state) <> 'object' then
    raise exception 'state must be a JSON object';
  end if;
  if octet_length(p_state::text) > 200000 then
    raise exception 'state too large';
  end if;
  select true, r.state ->> '_t' into v_has_row, v_cur_t
    from bios102_research_state r where r.email = v_email for update;
  if coalesce(v_has_row, false) and (p_state ? '_base') and v_cur_t is not null
     and v_cur_t is distinct from (p_state ->> '_base') then
    raise exception 'rm_conflict: a newer version was saved from another device';
  end if;
  insert into bios102_research_state (email, state)
  values (v_email, p_state)
  on conflict (email) do update set state = excluded.state
  returning updated_at into v_at;
  return v_at;
end;
$$;
grant execute on function bios102_rm_save(uuid, jsonb) to anon;

commit;

select proname, prosecdef from pg_proc where proname = 'bios102_rm_save';

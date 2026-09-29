-- SSCC bylaws workspace: let a signed-in member set their own display name.
-- Members added from an email address alone start with the address's local
-- part as their name; the page prompts them to replace it on first sign-in.
create or replace function sscc_bylaws_set_my_name(p_token uuid, p_name text)
returns void
language plpgsql security definer set search_path = public
as $$
declare
  me sscc_bylaws_members;
begin
  me := sscc_bylaws_session(p_token);
  if me.email is null then raise exception 'not signed in' using errcode = '28000'; end if;
  if nullif(trim(p_name), '') is null or length(trim(p_name)) > 80 then raise exception 'please enter your name (up to 80 characters)'; end if;
  update sscc_bylaws_members set display_name = trim(p_name) where email = me.email;
end;
$$;
grant execute on function sscc_bylaws_set_my_name(uuid, text) to anon, authenticated;

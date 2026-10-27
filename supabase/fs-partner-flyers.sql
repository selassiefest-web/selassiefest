-- Partner flyers: a personalized flyer for each partner who agrees to display one, tracked step by step.
-- Apply with: supabase db query --linked -f supabase/fs-partner-flyers.sql   (safe to re-run)
--
-- fs_partners.flyer (jsonb, null = no flyer for this partner):
--   { sizes: {letter, tabloid, card, bizcard}, logo_url, logo_name, logo_link, note, proof_url,
--     steps: { supporter, logo, proof, ok, cpd, printed, delivered } }   -- each step is a timestamp, or absent
-- Partners see and update their own flyer on /partner/?k=<pitch_key>: they send their logo (upload or link) and sizes,
-- then approve the proof. Staff tick the other steps on the tracker card (/full-spectrum/partners.html).
-- Logos go to the public storage bucket fs-partner-logos under <pitch_key>/logo/. Anyone with the page link can add a file
-- there, nobody can list the bucket, and files are only reachable by their exact URL. Logos are public marketing images.

alter table fs_partners add column if not exists flyer jsonb;

-- Write-only event log; its trigger emails staff (formatFsPartnerFlyer in notify-submission/index.ts).
create table if not exists fs_partner_flyer_events (
  id uuid primary key default gen_random_uuid(),
  created_at timestamptz not null default now(),
  pitch_key text not null,
  partner_name text,
  kind text not null check (kind in ('logo', 'approved', 'changes')),
  summary text
);
alter table fs_partner_flyer_events enable row level security;
drop trigger if exists fs_partner_flyer_events_notify on fs_partner_flyer_events;
create trigger fs_partner_flyer_events_notify after insert on fs_partner_flyer_events
  for each row execute function notify_submission_webhook();

-- Partner page: their flyer (null if they don't have one).
create or replace function fs_flyer_view(p_key text)
returns jsonb language sql stable security definer set search_path = public as $$
  select p.flyer from fs_partners p where p.pitch_key = p_key and p.flyer is not null;
$$;
grant execute on function fs_flyer_view(text) to anon, authenticated;

-- Partner page: send logo (uploaded file URL and/or a link) and sizes.
create or replace function fs_flyer_submit(p_key text, p jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare r fs_partners; f jsonb; s jsonb := '{}'::jsonb; k text; n int; v_url text; v_link text; v_sum text;
begin
  select * into r from fs_partners where pitch_key = p_key and flyer is not null;
  if r.id is null then raise exception 'flyer not found'; end if;
  f := r.flyer;
  v_url := nullif(trim(p->>'logo_url'), '');
  if v_url is not null and v_url not like 'https://xdjbgcqaynnzykrglgnf.supabase.co/storage/v1/object/public/fs-partner-logos/' || p_key || '/logo/%' then
    raise exception 'logo file must be uploaded from this page';
  end if;
  v_link := left(nullif(trim(p->>'logo_link'), ''), 500);
  if v_link is not null and v_link !~* '^https?://' then raise exception 'the logo link must start with http:// or https://'; end if;
  foreach k in array array['letter', 'tabloid', 'card', 'bizcard'] loop
    n := greatest(0, least(10000, coalesce((p->'sizes'->>k)::int, 0)));
    if n > 0 then s := s || jsonb_build_object(k, n); end if;
  end loop;
  if v_url is null and v_link is null and coalesce(f->>'logo_url', f->>'logo_link') is null then raise exception 'please add your logo file or a link to it'; end if;
  if s = '{}'::jsonb then raise exception 'please choose at least one size'; end if;
  f := f || jsonb_build_object('sizes', s, 'note', left(coalesce(p->>'note', ''), 1000));
  if v_url is not null then f := f || jsonb_build_object('logo_url', v_url, 'logo_name', left(coalesce(p->>'logo_name', ''), 200)); end if;
  if v_link is not null then f := f || jsonb_build_object('logo_link', v_link); end if;
  f := jsonb_set(f, '{steps,logo}', to_jsonb(now()), true);
  update fs_partners set flyer = f, updated_at = now() where id = r.id;
  v_sum := 'Sent their flyer details on their page: ' ||
    (select string_agg(value || ' × ' || case key when 'letter' then '8.5x11' when 'tabloid' then '11x17' when 'card' then '4x6 card' else 'business cards' end, ', ') from jsonb_each_text(s)) ||
    case when v_url is not null then '; uploaded ' || coalesce(nullif(p->>'logo_name', ''), 'a logo') else '' end ||
    case when v_link is not null then '; logo link ' || v_link else '' end ||
    case when coalesce(p->>'note', '') <> '' then '; note: ' || left(p->>'note', 300) else '' end;
  insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name) values (r.id, 'note', v_sum, coalesce(r.email, 'partner page'), r.name || ' (their page)');
  insert into fs_partner_flyer_events (pitch_key, partner_name, kind, summary) values (p_key, r.name, 'logo', v_sum);
  return f;
end;
$$;
grant execute on function fs_flyer_submit(text, jsonb) to anon, authenticated;

-- Partner page: approve the proof, or ask for changes.
create or replace function fs_flyer_approve(p_key text, p_ok boolean, p_note text default null)
returns jsonb language plpgsql security definer set search_path = public as $$
declare r fs_partners; f jsonb; v_sum text;
begin
  select * into r from fs_partners where pitch_key = p_key and flyer is not null;
  if r.id is null or r.flyer->>'proof_url' is null then raise exception 'there is no flyer proof to approve yet'; end if;
  f := r.flyer;
  if p_ok then f := jsonb_set(f, '{steps,ok}', to_jsonb(now()), true); else f := f #- '{steps,ok}'; end if;
  update fs_partners set flyer = f, updated_at = now() where id = r.id;
  v_sum := case when p_ok then 'Approved their flyer proof on their page' else 'Asked for changes to their flyer proof' end ||
    case when coalesce(p_note, '') <> '' then ': ' || left(p_note, 500) else '' end;
  insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name) values (r.id, 'note', v_sum, coalesce(r.email, 'partner page'), r.name || ' (their page)');
  insert into fs_partner_flyer_events (pitch_key, partner_name, kind, summary) values (p_key, r.name, case when p_ok then 'approved' else 'changes' end, v_sum);
  return f;
end;
$$;
grant execute on function fs_flyer_approve(text, boolean, text) to anon, authenticated;

-- Tracker: start, edit or stop a partner's flyer. p = { on: bool, proof_url, sizes, note, steps: {step: true|false} }.
create or replace function fs_flyer_staff_save(p_session uuid, p_partner uuid, p jsonb)
returns jsonb language plpgsql security definer set search_path = public as $$
declare u record; r fs_partners; f jsonb; k text; done text[] := '{}'; undone text[] := '{}';
begin
  select * into u from fs_partner_session_user(p_session);
  select * into r from fs_partners where id = p_partner;
  if r.id is null then raise exception 'partner not found'; end if;
  if (p->>'on') = 'false' then
    update fs_partners set flyer = null, updated_at = now() where id = r.id;
    insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name) values (r.id, 'note', 'Flyer removed from their page', u.v_email, u.v_name);
    return null;
  end if;
  f := coalesce(r.flyer, jsonb_build_object('steps', jsonb_build_object('supporter', now())));
  if p ? 'proof_url' then f := f || jsonb_build_object('proof_url', nullif(trim(p->>'proof_url'), '')); end if;
  if p ? 'sizes' then f := f || jsonb_build_object('sizes', p->'sizes'); end if;
  if p ? 'note' then f := f || jsonb_build_object('note', left(coalesce(p->>'note', ''), 1000)); end if;
  if p ? 'steps' then
    foreach k in array array['supporter', 'logo', 'proof', 'ok', 'cpd', 'printed', 'delivered'] loop
      if (p->'steps'->>k) = 'true' and f->'steps'->>k is null then f := jsonb_set(f, array['steps', k], to_jsonb(now()), true); done := done || k; end if;
      if (p->'steps'->>k) = 'false' and f->'steps'->>k is not null then f := f #- array['steps', k]; undone := undone || k; end if;
    end loop;
  end if;
  update fs_partners set flyer = f, updated_at = now() where id = r.id;
  insert into fs_partner_activity (partner_id, kind, summary, by_email, by_name)
  values (r.id, 'note', 'Flyer updated' ||
    case when r.flyer is null then ' (started; now shown on their page)' else '' end ||
    case when array_length(done, 1) > 0 then '; done: ' || array_to_string(done, ', ') else '' end ||
    case when array_length(undone, 1) > 0 then '; reopened: ' || array_to_string(undone, ', ') else '' end, u.v_email, u.v_name);
  return f;
end;
$$;
grant execute on function fs_flyer_staff_save(uuid, uuid, jsonb) to anon, authenticated;

-- Storage: public-read logo bucket, 25 MB per file, images and PDFs only.
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values ('fs-partner-logos', 'fs-partner-logos', true, 26214400,
        array['image/png', 'image/jpeg', 'image/svg+xml', 'image/webp', 'image/tiff', 'application/pdf', 'application/postscript', 'image/heic'])
on conflict (id) do update set public = excluded.public, file_size_limit = excluded.file_size_limit, allowed_mime_types = excluded.allowed_mime_types;

create or replace function fs_flyer_key_ok(p_key text)
returns boolean language sql stable security definer set search_path = public as $$
  select exists (select 1 from fs_partners where pitch_key = p_key and flyer is not null);
$$;
grant execute on function fs_flyer_key_ok(text) to anon, authenticated;

drop policy if exists "fs partner logos: partners add their own" on storage.objects;
create policy "fs partner logos: partners add their own" on storage.objects for insert to anon, authenticated
  with check (bucket_id = 'fs-partner-logos' and (storage.foldername(name))[2] = 'logo' and public.fs_flyer_key_ok((storage.foldername(name))[1]));

-- Janeicia Williams added as a second contact on the MCMF row (Stephen, Nov 25, 2026: "My CHI. My Future. lists her at jwilliams@projectexploration.org", for the 2026 operating details). Safe to re-run.
-- Also records that Stephen and Albert watched the Keystone Teen Party video Deputy Mayor Humphries sent and want a 2027 version in Rainbow Wednesdays.
begin;

update fs_partners set
  contacts = contacts || '[{"name":"Janeicia Williams","email":"jwilliams@projectexploration.org","role":"Listed on My CHI. My Future. as a contact for the 2026 operating details (per Stephen, Nov 25, 2026; not yet verified by us)"}]'::jsonb,
  email = coalesce(email, 'jwilliams@projectexploration.org'),
  next_step = 'Write Janeicia Williams (jwilliams@projectexploration.org), listed on My CHI. My Future. as a contact for the 2026 operating details (draft, Stephen says send), and ask Deputy Mayor Humphries (reply drafted) which program "MCMF South Shore and MCMF Citywide" means and who to write to at each. Our reading of MCMF as My CHI. My Future. is UNCONFIRMED.',
  notes = coalesce(notes, '') || ' | [janeicia 2026-11-25] Stephen added Janeicia Williams (jwilliams@projectexploration.org) as a second contact; the address is from My CHI. My Future. per Stephen and is not yet verified by us.',
  updated_at = now()
where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84'
  and coalesce(notes, '') not like '%[janeicia 2026-11-25]%';

update fs_partners set
  notes = coalesce(notes, '') || ' | [keystone-video 2026-11-25] Stephen and Albert watched the video Khari sent in his Nov 25 email (Message-ID fragment AT6PR09MB13092348DFD563D79CEBF98CBFA432), "James Jordan Boys & Girls Club - Keystone Teen Party (2003)" (https://www.youtube.com/watch?v=w3sW0sldplg), and are excited to plan an updated 2027 version as part of Rainbow Wednesdays. A 2027 teen party is a plan, not a commitment, and needs the Park District''s approval.',
  updated_at = now()
where name = 'Office of Mayor Brandon Johnson'
  and coalesce(notes, '') not like '%[keystone-video 2026-11-25]%';

commit;

select name, jsonb_array_length(contacts) as contacts, next_step_due::text from fs_partners where id = 'e0b74f53-8ac6-4d91-b245-6fc03b0a4d84'
union all select name, null, null from fs_partners where name = 'Office of Mayor Brandon Johnson' and notes like '%[keystone-video 2026-11-25]%';

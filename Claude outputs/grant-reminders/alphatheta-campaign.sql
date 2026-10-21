-- AlphaTheta campaign dates (cadence in equipment-outreach/alphatheta-campaign.md).
update fs_partners
   set next_step = 'Oct 22: call 1-844-784-0000; email HOMECOMING, Boudica, On The Rise DJ Academy; LinkedIn Ellie Donovan. Send tracked link https://selassiefest.com/startfromscratch-chicago/?k=d97jdsce',
       next_step_due = '2026-10-22',
       notes = coalesce(notes,'') || ' CAMPAIGN 2026-10-21: proposal site live (startfromscratch-chicago). Named people/routes and the cadence are in equipment-outreach/alphatheta-campaign.md. When pitch_views rises, call within the hour.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%CAMPAIGN 2026-10-21%';

insert into deadlines (title, description, due_date, category, source_url, confirmed)
values
('AlphaTheta campaign: Email 3 (last note) and review', 'Nov 2 send the last note to anyone silent; Nov 3 call and review views, replies and pitch changes. Cadence in equipment-outreach/alphatheta-campaign.md.', '2026-11-03', 'event', 'https://selassiefest.com/startfromscratch-chicago/', true)
on conflict (title, due_date) do nothing;

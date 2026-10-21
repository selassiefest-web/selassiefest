update fs_partners
   set email = coalesce(email, 'john.powell@pioneerdj.com'),
       notes = coalesce(notes,'') || ' POWELL CONTACT 2026-10-21: published email john.powell@pioneerdj.com and phone 424-488-0480 in Music Connection (Apr 1, 2020); deliverability unconfirmed. 2024 Girls Make Beats Miami donation precedent quotes him. Email drafted in equipment-outreach/alphatheta-campaign.md.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%POWELL CONTACT 2026-10-21%';

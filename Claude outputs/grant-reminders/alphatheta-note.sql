-- AlphaTheta Start From Scratch pages checked 2026-10-20: no application, form, email or phone for the program; partners named are HOMECOMING (Lagos) and Boudica (Europe); no US or Chicago mention. Only route found is the US support line.
update fs_partners
   set notes = coalesce(notes,'') || ' CHECKED 2026-10-20: Start From Scratch pages list no application, email or phone. Named partners are in Lagos and Europe; no US/Chicago mention. Support gateway: alphatheta.com/en/support/. Best route remains the Americas phone line 1-844-784-0000, asking for community partnerships.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%CHECKED 2026-10-20%';

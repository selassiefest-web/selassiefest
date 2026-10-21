-- AlphaTheta angle, checked 2026-10-20: US arm is AlphaTheta Music Americas, Torrance CA (not Chicago); global HQ Yokohama.
-- Start From Scratch is run in Europe / Middle East / Africa (London, Paris, Dubai, Lagos). Serves women, People of Colour, LGBTQIA+, neurodiverse people. Free workshops led by community guest experts, with an Accelerator (a funded DJ course) for some attendees.
update fs_partners
   set pitch = 'Start From Scratch brings free, community-led DJ education to underrepresented people in Europe, the Middle East and Africa. Rainbow DJ Lab does the same on Chicago''s South Side: free, every Tuesday, year-round, with a girls-only Empress Decks track taught by women DJs, accommodations for neurodiverse students, and public showcases. We would like to be the Chicago pilot of that model on your gear.',
       notes = coalesce(notes,'') || ' ANGLE 2026-10-20: do not rename our program; present it as a Chicago pilot of the same model. US arm is AlphaTheta Music Americas, Torrance CA. Their program has no stated US presence.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%ANGLE 2026-10-20%';

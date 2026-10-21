-- AlphaTheta pitch reframed (Stephen, 2026-10-20): not a donation request. Ask AlphaTheta to launch Start From Scratch in Chicago as the US pilot, with Ras Tafari as the local host partner (as HOMECOMING in Lagos and Boudica in Europe host for them).
update fs_partners
   set ask = 'Launch Start From Scratch in Chicago as the US pilot, with Ras Tafari as local host partner: the framework and name, 12 matching student controllers and headphones, guest experts, and a path into their Accelerator Programme.',
       pitch = 'Start From Scratch trains underrepresented people to DJ in Europe, the Middle East and Africa through local host partners. We are a Chicago 501(c)(3) opening a free Tuesday class on the South Side on January 12, 2027, with a girls-only track, accommodations for neurodiverse students and public showcases. We would like AlphaTheta to lead the Chicago launch under Start From Scratch, with us as your local host.',
       partner_types = array['in_kind','programming','marketing'],
       notes = coalesce(notes,'') || ' FLAGSHIP FRAMING 2026-10-20 (Stephen): we have proposals and no brand to protect; bring in AlphaTheta to lead under their flagship. Section 4 of equipment-outreach/drafts.md rewritten. Our Jan 12 opening does not depend on their answer.'
 where name = 'AlphaTheta / Pioneer DJ' and coalesce(notes,'') not like '%FLAGSHIP FRAMING 2026-10-20%';

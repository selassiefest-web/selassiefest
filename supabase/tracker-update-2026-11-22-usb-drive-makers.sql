-- Nov 22, 2026 (Stephen): Rainbow DJ Lab USB flash drives. Research-only partner rows for Transcend, Kingston, Nexcopy, SanDisk.
-- Source: Stephen's paste Nov 22, 2026 (ChatGPT-sourced; every fact UNVERIFIED). CPD HOLD: no outreach until CPD's GO.
-- Safe to re-run: rows keyed by exact name (insert only if absent); activity keyed by marker [usb-research-20261122] per partner.
begin;

insert into fs_partners (name, category, website, partner_types, program_parts, stage, ask, commitment, commitment_value, next_step, next_step_due, source, notes, ball_with)
select v.name, 'Computers', v.website, array['in_kind'], array['classes'], 'not_contacted', v.ask, null, null, v.next_step, date '2026-11-26',
 $s$Stephen's paste Nov 22, 2026 (ChatGPT-sourced, UNVERIFIED)$s$, v.notes, 'cpd_hold'
from (values
 ($n$Transcend Information (JetFlash USB drives)$n$,
  $w$https://us.transcend-info.com/support/contact$w$,
  $a$14 matching 64 GB dual USB-A/USB-C flash drives (12 students + 2 spares) for the Rainbow DJ Lab, in-kind, or a nonprofit discount if in-kind is unavailable.$a$,
  $x$ON CPD HOLD (Stephen, Nov 22, 2026): research row only. No outreach until CPD's GO. Priority 1 of 4 (Transcend, Kingston, Nexcopy, SanDisk). On the GO, send one inquiry through the published Transcend contact form (online only) asking for 14 drives. Revisit Nov 26 at the ARCS check-in.$x$,
  $t$[usb-research-20261122] ALL FACTS BELOW ARE UNVERIFIED research from a ChatGPT-sourced paste (Stephen, Nov 22, 2026); verify on the funder's own pages before any send.
DECISION (Stephen, Nov 22, 2026): every Rainbow DJ Lab student gets their own USB drive and keeps it at graduation. Current plan 14 drives (12 students + 2 spares); System Builder prices them at $15 each as an allowance (not a donated value). The paste said 15 (13 stations + 2 spares): mismatch flagged; 14 is the current ask unless Stephen says otherwise. AlphaTheta XDJ-AN takes USB-C drives only and has one slot, so dual USB-A/USB-C drives are required.
CLAIM (UNVERIFIED): closest match. Reportedly pledged 500 JetFlash USB drives to the Satya Bharti School Program in India (education donation, same product type). Model to ask about: 64 GB JetFlash 890, TS64GJF890S, or current equivalent.
ROUTE (published): Transcend sales/partnership inquiries https://us.transcend-info.com/support/contact ; press item https://us.transcend-info.com/About/press/1256 . Online only.
ASK (tailored): drives only, 14 count, or nonprofit discount. Pitch: students prepare playlists on classroom computers, load them onto the standalone DJ system, and learn to perform without a laptop. If the XDJ-AN is selected, test one sample with a rekordbox OneLibrary export first (https://alphatheta.com/en/product/all-in-one-dj-system/xdj-an/black/).
Nothing promised, no value stated, no contact made.$t$),
 ($n$Kingston Technology (DataTraveler microDuo 3C)$n$,
  $w$https://www.kingston.com/en/company/contacts$w$,
  $a$14 matching 64 GB dual USB-A/USB-C flash drives (12 students + 2 spares) for the Rainbow DJ Lab, in-kind, or a nonprofit discount if in-kind is unavailable.$a$,
  $x$ON CPD HOLD (Stephen, Nov 22, 2026): research row only. No outreach until CPD's GO. Priority 2 of 4. On the GO, use the published Kingston U.S. corporate contacts page (online only) to reach the community-giving or product-sponsorship team and ask for 14 drives. Revisit Nov 26 at the ARCS check-in.$x$,
  $t$[usb-research-20261122] ALL FACTS BELOW ARE UNVERIFIED research from a ChatGPT-sourced paste (Stephen, Nov 22, 2026); verify before any send.
DECISION (Stephen, Nov 22, 2026): every student gets their own drive and keeps it at graduation. Current plan 14 drives (12 students + 2 spares); System Builder allowance $15 each (not a donated value). Paste said 15: mismatch flagged; 14 is the current ask. XDJ-AN takes USB-C only, one slot: dual USB-A/USB-C required.
CLAIM (UNVERIFIED): strongest recent giving record; its 2024 report reportedly states over $500,000 in monetary and in-kind donations and support for more than 80 community organizations. Model to ask about: 64 GB DataTraveler microDuo 3C (USB-A and USB-C).
ROUTE (published): Kingston U.S. corporate contacts https://www.kingston.com/en/company/contacts (ask for the team handling community giving or product sponsorship). Report: https://media.kingston.com/kingston/company/pdf/2024_Kingston_GRI.pdf . Online only.
ASK (tailored): drives only, 14 count, or nonprofit discount. Same student-playlist, no-laptop pitch; test one sample with a rekordbox OneLibrary export if the XDJ-AN is selected.
Nothing promised, no value stated, no contact made.$t$),
 ($n$Nexcopy (RecycleUSB)$n$,
  $w$https://www.nexcopy.com/contact-us/$w$,
  $a$Ask whether Nexcopy can supply or help source 14 matching 64 GB dual USB-A/USB-C flash drives (12 students + 2 spares) for the Rainbow DJ Lab.$a$,
  $x$ON CPD HOLD (Stephen, Nov 22, 2026): research row only. No outreach until CPD's GO. Priority 3 of 4. On the GO, use the published Nexcopy contact form (online only) to ask whether they can supply or help source 14 drives. Revisit Nov 26 at the ARCS check-in.$x$,
  $t$[usb-research-20261122] ALL FACTS BELOW ARE UNVERIFIED research from a ChatGPT-sourced paste (Stephen, Nov 22, 2026); verify before any send.
DECISION (Stephen, Nov 22, 2026): every student gets their own drive and keeps it at graduation. Current plan 14 drives (12 students + 2 spares); allowance $15 each in the System Builder (not a donated value). Paste said 15: mismatch flagged; 14 is the current ask. XDJ-AN takes USB-C only, one slot: dual USB-A/USB-C required.
CLAIM (UNVERIFIED): education-focused industry lead. The USB equipment company reportedly helped run RecycleUSB and contributed labor and equipment to turn donated flash drives into learning tools for children and schools. The documented initiative is HISTORICAL; current donation capacity unknown.
ROUTE (published): https://www.nexcopy.com/contact-us/ ; https://www.recycleusb.com/about/ . Online only.
ASK (tailored): supply or help source matching drives, 14 count; nothing else.
Nothing promised, no value stated, no contact made.$t$),
 ($n$SanDisk (Ultra Dual Drive Go)$n$,
  $w$https://www.sandisk.com/company/contact-us$w$,
  $a$14 matching 64 GB dual USB-A/USB-C flash drives (12 students + 2 spares) for the Rainbow DJ Lab, in-kind, or a nonprofit discount if in-kind is unavailable.$a$,
  $x$ON CPD HOLD (Stephen, Nov 22, 2026): research row only. No outreach until CPD's GO. Priority 4 of 4. On the GO, route one inquiry through SanDisk's published corporate contact page (online only; support and customer care do not supply donations per the paste, UNVERIFIED). Revisit Nov 26 at the ARCS check-in.$x$,
  $t$[usb-research-20261122] ALL FACTS BELOW ARE UNVERIFIED research from a ChatGPT-sourced paste (Stephen, Nov 22, 2026); verify before any send.
DECISION (Stephen, Nov 22, 2026): every student gets their own drive and keeps it at graduation. Current plan 14 drives (12 students + 2 spares); allowance $15 each in the System Builder (not a donated value). Paste said 15: mismatch flagged; 14 is the current ask. XDJ-AN takes USB-C only, one slot: dual USB-A/USB-C required.
CLAIM (UNVERIFIED): good product fit, less direct donation route. The 64 GB Ultra Dual Drive Go is the model family pictured in the gear pack. SanDisk reportedly says its support and customer care teams do not supply donations, so go through corporate contacts.
ROUTE (published): https://www.sandisk.com/company/contact-us ; datasheet https://documents.sandisk.com/content/dam/asset-library/en_us/assets/public/sandisk/product/usb-flash/ultra-dual-drive-go-usb-3-1-type-c/data-sheet-ultra-dual-drive-go-usb-3-1-type-c.pdf . Online only.
ASK (tailored): drives only, 14 count, or nonprofit discount.
Nothing promised, no value stated, no contact made.$t$)
) as v(name, website, ask, next_step, notes)
where not exists (select 1 from fs_partners p where p.name = v.name);

insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name)
select p.id, 'note',
 $s$[usb-research-20261122] Nov 22, 2026: research row added from Stephen's paste of Nov 22, 2026 (ChatGPT-sourced; every fact UNVERIFIED; utm_source=chatgpt.com stripped from links). Rainbow DJ Lab USB drives: ask is 14 dual USB-A/USB-C 64 GB drives (12 students + 2 spares; paste said 15, flagged), in-kind or nonprofit discount. No contact made, nothing promised, no value stated. CPD HOLD: outreach waits for CPD's GO. Priority order: Transcend, Kingston, Nexcopy, SanDisk.$s$,
 'not_contacted', 'stephen@selassiefest.com', 'Stephen Henry'
from fs_partners p
where p.name in ($n$Transcend Information (JetFlash USB drives)$n$, $n$Kingston Technology (DataTraveler microDuo 3C)$n$, $n$Nexcopy (RecycleUSB)$n$, $n$SanDisk (Ultra Dual Drive Go)$n$)
  and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like '%[usb-research-20261122]%');

commit;

select p.name, p.category, p.stage, p.ball_with, p.next_step_due::text, p.commitment, p.commitment_value,
       (p.notes like '%[usb-research-20261122]%') noted,
       (select count(*) from fs_partner_activity a where a.partner_id=p.id and a.summary like '%[usb-research-20261122]%') activity_rows
from fs_partners p
where p.name in ('Transcend Information (JetFlash USB drives)','Kingston Technology (DataTraveler microDuo 3C)','Nexcopy (RecycleUSB)','SanDisk (Ultra Dual Drive Go)')
order by p.name;

-- Nov 21, 2026: Audima Labs (Jeremy Buckley, Isaac Jack) guest-class invitation page built. NOT sent. Safe to re-run (keyed on name).
begin;
insert into fs_partners (name, category, contacts, partner_types, program_parts, stage, ask, next_step, source, notes, ball_with)
select 'Audima Labs (Jeremy Buckley and Isaac Jack): Rainbow DJ Lab guest class',
 'Software',
 '[{"name":"Jeremy Buckley","role":"Audima Labs, Sway MIDI controller"},{"name":"Isaac Jack","role":"Audima Labs, Sway MIDI controller"}]'::jsonb,
 array['programming'], array['dj_lab'], 'not_contacted',
 'Teach one Rainbow DJ Lab Tuesday (4:00-6:00 pm CT): lesson "One Loop, Two Ways" (Hot Cues and Loops) with the Sway controller; stay for the 5:30-6:00 guest set. Travel from Australia, lodging, fee and gear to be discussed.',
 'Stephen decides how and when to send the invitation page https://selassiefest.com/full-spectrum/audima/ (no contact email on file yet; audima.com.au). Nothing sent. Visit depends on Chicago Park District approval and the Lab launch.',
 'Stephen invitation page Nov 21, 2026',
 E'Private invitation page (noindex): https://selassiefest.com/full-spectrum/audima/ (file full-spectrum/audima/index.html, copied verbatim from Downloads\BOB\Rainbow-DJ-Lab-Audima-Invitation.html). Links on page: mailto stephen@selassiefest.com (subject Rainbow DJ Lab guest class), YouTube Sway overview RnAa7wgdjvg, https://selassiefest.com/dj-lab/about/ and curriculum.html, https://audima.com.au/. Page has no phone number. Proposed location Rainbow Beach Park; CPD hold applies to partner sends until CPD GO.',
 'us'
where not exists (select 1 from fs_partners where name like 'Audima Labs (Jeremy Buckley and Isaac Jack)%');
insert into fs_partner_activity (partner_id, kind, summary, stage_after, by_email, by_name, created_at)
select p.id, 'note',
 'Invitation page built Nov 21, 2026 at https://selassiefest.com/full-spectrum/audima/ (exact copy of the supplied HTML, no style or content changes). Not sent to Audima yet; no contact address on file.',
 'not_contacted', 'stephen@selassiefest.com', 'Stephen Henry', now()
from fs_partners p where p.name like 'Audima Labs (Jeremy Buckley and Isaac Jack)%'
 and not exists (select 1 from fs_partner_activity a where a.partner_id = p.id and a.summary like 'Invitation page built Nov 21, 2026%');
commit;
select p.name, p.stage, p.ball_with, (select count(*) from fs_partner_activity a where a.partner_id = p.id) activities from fs_partners p where p.name like 'Audima Labs%';

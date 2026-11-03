-- Levitt Foundation: festival choice + packet strengthened, Nov 3 2026. Safe to re-run (guarded by marker text).
begin;
update fs_grant_deadlines
set notes = notes || E'\n[2026-11-03] DECISION: enter the Full Spectrum Festival at Rainbow Beach (one Saturday, mid-Sept 2027), NOT SelassieFest (one application per org; SelassieFest has no confirmed venue, format not ratified, free-ticket reserve flow conflicts with Levitt). Packet strengthened: cites RTI''s SelassieFest 2026 record (about 273 people, planned in 47 days) as track record; attendance goal 400; Rainbow Wednesdays figure corrected to about 150 a night. WARNING: the saved Formstack form still has Oct 31 placeholder dates 7/24-25/2027; fix to the festival timeframe before submitting. Levitt rules re-verified Nov 3 (deadline Nov 20 3 PM ET; up to $5,000; free, no RSVP; 4+ hrs; new festivals OK).',
    next_step = 'Stephen: (1) open the saved Formstack form and replace the placeholder dates 7/24-25/2027 with the Full Spectrum festival timeframe; (2) get Ivry OK to name Rainbow Beach (Nov 6); (3) type EIN, tick e-comms box, upload 2-3 REAL photos (lawn, Ifficial Reggae Movement with band OK, an RTI event); (4) confirm attendance 400, mission wording, budget lines; then say "submit". Deadline Fri Nov 20 2026, 2 PM CT. Packet: Claude outputs\grants\applications-2026-10-31\06-chicago-fdn-open\06-levitt-foundation.md'
where funder ilike '%levitt%' and notes not like '%[2026-11-03] DECISION: enter the Full Spectrum Festival%';
commit;
select funder, status, left(next_step,160) ns, right(notes,120) n from fs_grant_deadlines where funder ilike '%levitt%';

-- Photos received Nov 3 (2 of 3 ready in the packet folder levitt-images). Safe to re-run.
begin;
update fs_grant_deadlines
set notes = notes || E'\n[2026-11-03] 2 of 3 Levitt images READY (real SelassieFest 2026 photos: banner on lawn, live band on stage) in Claude outputs\grants\applications-2026-10-31\06-chicago-fdn-open\levitt-images. Still need: photo of the Rainbow Beach Park lawn (location).'
where funder ilike '%levitt%' and notes not like '%2 of 3 Levitt images READY%';
commit;

-- Ivry's OK granted Nov 3 (Stephen). Safe to re-run.
begin;
update fs_grant_deadlines
set notes = notes || E'\n[2026-11-03] Ivry''s OK GRANTED (Stephen) to name the Rainbow Beach festival in the Levitt application. Specific Saturday, if set, not yet recorded.',
    next_step = replace(next_step, '(2) get Ivry OK to name Rainbow Beach (Nov 6); ', '(2) Ivry OK DONE Nov 3; ')
where funder ilike '%levitt%' and notes not like '%Ivry''s OK GRANTED%';
commit;
select left(next_step,200) ns from fs_grant_deadlines where funder ilike '%levitt%';

-- Attendance 400 confirmed by Stephen Nov 3. Safe to re-run.
begin;
update fs_grant_deadlines
set notes = notes || E'\n[2026-11-03] Attendance 400 CONFIRMED by Stephen for the Levitt form.',
    next_step = replace(next_step, '(4) confirm attendance 400, mission wording, budget lines', '(4) attendance 400 CONFIRMED; still confirm mission wording and budget lines')
where funder ilike '%levitt%' and notes not like '%Attendance 400 CONFIRMED%';
commit;
select left(next_step,520) ns from fs_grant_deadlines where funder ilike '%levitt%';

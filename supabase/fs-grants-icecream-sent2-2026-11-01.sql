-- Ice cream emails sent Nov 1 2026 (second batch, 9 recipients, cc Stephen). Log: Claude outputs/ice-cream/rest-2026-11-01-sent.json
begin;
update fs_grant_deadlines set status='submitted', next_step='Emailed 11/1; follow up by phone/in person if no reply', next_step_due='2026-11-15',
 notes = notes || ' EMAILED 11/1/2026 from stephen@ (50 servings/week pilot request).'
where funder in ('Jeni''s Splendid Ice Creams','The Original Rainbow Cone','B&B Ice Cream & Candy','Kilwins Hyde Park','Dippin'' Dots Illinois','Homer''s Ice Cream','Tillamook','Vandalay Brands')
  and not (funder='Jeni''s Splendid Ice Creams' and program='Ice cream social sponsorship idea');
update fs_grant_deadlines set status='submitted', next_step='Emailed 11/1 asking for a Chicago truck-operator introduction', next_step_due='2026-11-15',
 notes = notes || ' EMAILED 11/1/2026 from stephen@.'
where funder='Good Humor / Neighborhood Joy (Magnum Ice Cream Co.)';
commit;

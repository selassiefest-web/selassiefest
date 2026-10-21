-- Follow-up reminder for the Springboard survey submitted 2026-10-20.
insert into deadlines (title, description, due_date, category, source_url, confirmed)
values ('Springboard: follow up if no phone-call invitation', 'Survey submitted Oct 20, 2026. Email sejal@springboardfoundation.org if nothing has arrived. Ask which year''s budget counts toward the $100,000 limit.', '2026-11-03', 'event', 'https://springboardfoundation.org/apply-grant', true)
on conflict (title, due_date) do nothing;

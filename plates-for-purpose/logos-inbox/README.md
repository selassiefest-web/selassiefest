# Restaurant logo intake

Drop each restaurant's logo file in here, named exactly `<slug>.png` (or
`.jpg`/`.webp`) — e.g. `14-parish-restaurant-and-rhum-bar.png`. Slugs match
the `?r=` value on that restaurant's ask page; the full list is visible on
`/plates-for-purpose/cards/`.

This folder is git-ignored — files placed here are staged locally only, then
uploaded straight to the `plates-for-purpose-logos` Supabase Storage bucket
and never committed to the repo. Once told "logos are ready," the process
is:

1. Compress/resize each file the same way the deck artwork is (long edge
   capped, reasonable quality).
2. `supabase storage cp -r . ss:///plates-for-purpose-logos --linked`
   (uploads every file in this folder to the bucket in one shot).
3. For each uploaded file, `update plates_for_purpose_restaurants set
   logo_path = '<filename>' where slug = '<slug>';`
4. Delete the local copies from this folder once confirmed live.

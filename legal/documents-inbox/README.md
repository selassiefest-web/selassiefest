# documents-inbox

Local staging folder for internal business documents (leases, contracts, signed agreements, etc.) that must **never** be committed to this repo.

This site deploys to GitHub Pages: every file committed here becomes publicly downloadable at its path on selassiefest.com. Business documents with financial or personal terms don't belong in that tree.

Everything in this folder except this README is gitignored. Drop files here to keep them alongside the project locally; if a document needs to be referenced from the live site, upload it to private storage (e.g. Supabase Storage with a signed/authenticated URL) the same way `plates-for-purpose/logos-inbox/` handles restaurant logos, and link to that instead of committing the file.

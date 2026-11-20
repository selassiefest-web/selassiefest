# Research-to-Grant Studio: build plan (Nov 19, 2026)

Spec: `C:\Users\mkepr\Downloads\BOB\research grants\Pasted_text.txt` (8 parts). Three earlier AI drafts in the same folder are UNVERIFIED reference only.

## Decisions from Stephen (Nov 19, 2026)
1. Every PI with ongoing research is entered: the 9 research cards in `BIOS102/js/research-data.js` (Orlofske, Richards, Preuss, Higgs, Lee, Barber, Noto, Taft, Rogers). Mossman and Mayer have no research program and stay in "Also on the directory".
2. Lives with Research Match as a button. Only invited students open it. Everyone else sees: "Ask harria01@uwp.edu for access."
3. "Send" = open a pre-filled email draft (mailto) plus a print-ready packet. Never auto-send. Outreach and submission stay with the student.

## Phases (test after every phase; nothing ships unverified)
0. Access: table `bios102_studio_access` + RPC `bios102_studio_has_access(p_session)` (mirror `bios102_grades_is_instructor`), invite by email. Needs Stephen's OK before it touches live Supabase.
1. Verify: for each of the 9 PIs record identity (OpenAlex id + ORCID + affiliation), profile page text, recent papers (DOI), resources with source and date. Method proven on Orlofske: OpenAlex ORCID 0000-0002-2486-7982 at UW-Parkside; profile lists interests, no ORCID, no named grants. Anything not on a source = "unverified".
2. Funding: re-read Thomson Fellowship and URAP official pages; record deadline, eligibility, expenses, route; unverified stays unverified.
3. Data file `js/studio-data.js` (facts only, each with source + date).
4. UI: mission-control dashboard, gap arena (3+ candidates), resource inventory with two lights (lab has used it / I can use it), calendar hours, plan + proposal editors with cross-check, student and instructor views.
5. Failure tests from spec: missing critical resource, ineligible funder, incomplete document.
6. Exports: print-ready packet, mailto draft, interactive defense deck.

## "Ongoing research" rule
A PI counts if the profile states an active research focus AND the record shows work within the last ~5 years (OpenAlex/PubMed/profile). Evidence is shown per PI; weak cases are labeled, not dropped silently.

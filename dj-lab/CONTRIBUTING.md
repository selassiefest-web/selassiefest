# Contributing

Thank you for helping keep the Rainbow DJ Lab site accurate. This guide is for Ras Tafari Inc. staff and volunteers.

## Never put children's data anywhere in this repo

Do not include any child's or family's name, age, photo, contact details, medical or allergy information, pickup list or class activity in issues, pull requests, commits, comments, screenshots or test data. Use made-up placeholders such as "Kid A." If you find real data in the repo, report it right away under [`SECURITY.md`](SECURITY.md).

## Proposing a correction

1. **Small fixes** (typos, broken links): open an issue or a pull request that edits the `.md` source file, or email stephen@selassiefest.com with the page and the fix.
2. **Fact changes:** every fact must agree with `rainbow-wednesdays/development/DJLAB_FACTS.md`. If the fact sheet is wrong, propose the change to the fact sheet first and say where the correct information comes from (an official source, signed document or board decision).
3. **Status changes** (for example, a launch requirement completed): include the evidence, or say where it is kept. A second officer must check the evidence before the [Launch Readiness Checklist](https://selassiefest.com/dj-lab/governance/index.html) is updated.

Edit the `.md` file, then run `python dj-lab/_build/build.py` and commit both the `.md` and the generated `.html`. See [`README.md`](README.md).

## Safety content needs the President's review

Any change to safety, youth-protection, privacy or incident-reporting content, including anything under `safety/`, `privacy/`, or the live app's handling of children's data, must be reviewed and approved by **Stephen Henry, President**, before it is merged. Changes to adopted policies also need a board vote.

## Writing style

- Write for a careful parent of a 9-year-old: plain, warm, specific.
- Be honest about what is still pending. Never write "approved," "licensed," "certified program," "insured," "permitted" or "guaranteed" about anything not yet done.
- Do not name coaches, staff or volunteers, and do not post an EIN or license numbers.
- Use root-absolute links, for example `/dj-lab/safety/index.html`.

## Conduct

All contributors follow the [`CODE_OF_CONDUCT.md`](CODE_OF_CONDUCT.md).

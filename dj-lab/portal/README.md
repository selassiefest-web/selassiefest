# Portal (`/dj-lab/portal/`)

The portal is the front door to the Rainbow DJ Lab's tools. Each entry page sends a person to what they need and nothing more.

## Entry pages

| Page | For | What it does |
|---|---|---|
| **Family** | Parents and guardians | Opens the family view of the live class app. Families don't use a class code: each approved child's guardian is emailed a **private family link** that shows only their own child. A lost or shared link is re-issued by the coach. |
| **Coach** | Screened coaches on the roster | Coach sign-in by emailed one-time link, then the coach controls and the **Safety now** panel (including the incident log, which emails Stephen Henry) in the [live class app](../live/README.md). |
| **Kid** | Kids in class | Opens the Kid view on an in-room screen. In-room screens use a **room code** the coach issues for each class; it expires (4 hours by default). No personal information is collected here. |
| **Sign-out** | Coaches at pickup | Records each child's release at the end of class and emails the parent. |

## Sign-out

Children are released only to adults on the child's **authorized-pickup list**, after a **photo ID check**. Every release is recorded in the Lab's sign-out log. For each release, the log records:

- **who picked up the child** (the authorized adult's name, as it appears on the pickup list);
- **the time** of release;
- **the ID check**: that a photo ID was checked and matched an adult on the child's authorized-pickup list.

Rules the sign-out page enforces or reminds coaches of:

- If the adult is **not** on the authorized list, the child is not released. Staff call the parent or guardian.
- If the adult **appears impaired**, the child is not released. Staff call another authorized adult. If the child is in danger, staff call 911 and make a DCFS Hotline report (1-800-25-ABUSE / 1-800-252-2873) as required.
- Children aged 8–11 are **never released to walk home alone** unless a parent or guardian gave written permission in advance.
- Little DJs (ages 5–7) stay with their own grown-up for the whole class.
- The server enforces the rules: a child can be released only to a listed adult, after the ID check is recorded.
- **The parent gets an email at every sign-out.**
- A pickup adult is added only after a written request (email or text from the number on file) and a call back to that number, and the request is recorded. Never on a phone call alone, and never on the word of the adult at the door.

## Privacy

- The sign-out log and the authorized-pickup lists are visible **only to signed-in coaches.** They are never shown on family or kid pages, and never sent to a family link or an in-room screen.
- **No ID images are stored.** The log records that an ID was checked, not a copy of it.
- Sign-out records are registration records and follow the Lab's retention policy (kept 3 years for safety and insurance purposes, then deleted). See the [privacy policy](https://selassiefest.com/dj-lab/privacy/index.html).
- The log is spot-checked during each season by an officer other than the President. See [Enforcement and self-accountability](https://selassiefest.com/dj-lab/governance/enforcement-self-accountability.html).

Any change to the sign-out flow is safety content and needs the President's review (see [`../CONTRIBUTING.md`](../CONTRIBUTING.md)).

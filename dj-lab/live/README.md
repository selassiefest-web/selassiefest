# Live class app (`/dj-lab/live/`)

The live class app is the shared classroom screen for a Rainbow DJ Lab session (the app calls the course brand "Rainbow DJ Academy"). Every screen follows the same session clock, but each kind of screen sees only what it needs: in-room Kid/Station screens see the station board, a family sees only their own child, and coaches see the whole class.

## What it does

- **Session clock.** It runs a 90-minute session through its 9 blocks (Drop In, Mission Card, Watch Me Think, Deck Time 1, Move Break, Deck Time 2, Wordplay Lab, Spotlight, Check Out), drawn as a rainbow waveform with one bar per minute. It also supports the 2-hour spring fast-track workshops (W1–W6).
- **Station board.** It shows groups of 4 kids per controller, with jobs (DJ, Co-pilot, Hype, Logger) rotating every 3 minutes 45 seconds. There are up to 3 stations.
- **Kid check-ins.** Each kid records a prediction, a Mild/Medium/Spicy challenge level, a traffic-light self-rating, a "Next time I'll…" line, a "Data!" count and a Mix Log.
- **Passport stamps and glow notes**, given by coaches.
- **Coach controls:** running and moving the clock, editing the class roster, stamping Passports, writing glows, approving registrations, issuing room codes, sending family links, logging incidents, and sending optional recap emails to families who opted in.

## Three ways in

With none of these, the page is empty until someone picks "See a demo".

### Room code (in-room Kid/Station screens)

- The coach issues a **room code** for each class. It **expires** (4 hours by default), and the coach can end it at any time, so a leaked code stops working when the class ends.
- Room-code screens show only the **Kid tab** and the read-only coach script.
- They see the station board for that class: first names and last initials, stations, jobs, check-in times and in-class activity. They **never** see glow notes or private data.
- A room-code screen can save a kid's own check-in fields only if that child's family gave digital-tracking consent.
- The permanent class identifier no longer opens the class board.

### Private family link (parents and guardians)

- Families never use a class code. When a coach approves a child, the guardian is emailed a **private family link** (`/dj-lab/live/?f=…`).
- It shows **only their own child**: the live class clock and block, their child's station and job, self-ratings, "Next time I'll…", Mix Log, Passport, the coach's glow note for their child, and coach messages.
- It never shows other children. The Spotlight banner appears only when it's their own child.
- A lost or shared link is re-issued by the coach.

### Coach sign-in

- Coaches sign in with an **emailed one-time link** ("magic link"). There are no passwords.
- A link can be requested only for an email address on the coach roster, and an unused link expires after 30 minutes.
- Only a signed-in coach session can run the clock or make coach changes. Everyone else is read-only, apart from a kid's own check-in on a room-code screen.
- Coaches see the whole class plus a **Safety now** panel: allergy, EpiPen, medical and custody flags for the children checked in; guardian phone and emergency numbers; links to the sign-out tool and the emergency plans; and an **incident log**. Each incident (kind, child, what happened, action taken, whether the parent was called, whether 911 was called) is emailed to Stephen Henry.

## Consent, enforced by the server

- **No in-class app activity is saved** without the family's digital-tracking consent. The child tells the coach their answer instead.
- **No child can be put in the Spotlight** without performance consent.
- Children added by a coach (rather than through registration) need their paper forms on file, and the coach records which consents are on paper.
- Interest-list entries (collected before launch) can never be approved onto a class.

## Sign-out

Release is only to listed adults after an ID check, enforced by the server. **The parent gets an email at every sign-out.** A pickup adult is added only on a written request, which is recorded. See [`../portal/README.md`](../portal/README.md).

## Data model (summary)

The source of truth is `supabase/dj-lab.sql` in the repo root.

| Table | Holds |
|---|---|
| `djlab_coaches` | Coach roster (email, display name) |
| `djlab_coach_login_links` | One-time sign-in links and active coach sessions |
| `djlab_cohorts` | A class: name, class identifier, the current room code and when it expires, the shared live clock state, a version number |
| `djlab_kids` | A kid in a class: first name + last initial, station, seat, stamps, check-in times, glow notes; **private:** guardian name, email, phone, recap opt-in, private family-link key |
| `djlab_checkins` | One row per kid per session: prediction, level, self-rating, next-time line, Data! count, Mix Log |
| `djlab_recaps_sent` | Which recap emails were sent, so none goes twice |
| `djlab_registrations` | Registration requests and interest-list entries (submitted through the Turnstile-protected form). Interest-list entries can never be approved |
| `djlab_signouts` | The sign-out log; each release emails the parent |
| `djlab_incidents` | The incident log; each entry emails Stephen Henry |
| `djlab_family_links_sent` | Private family-link emails sent to guardians |

Every table has row-level security on. The page never reads tables directly. All access goes through security-definer functions (`djlab_state`, `djlab_family_state`, `djlab_checkin`, `djlab_coach_*`). Recap emails are sent by the `djlab-send-recaps` Edge Function through Resend.

## Privacy boundaries

- **A family's private link shows only their own child:** station and job, check-in, in-class activity (prediction, level, self-rating, "Next time I'll…", Data! count, Mix Log), Passport stamps and the coach's glow note for their child.
- **In-room screens with a room code see:** each child's first name and last initial, station, job, check-in time and in-class activity. Never glow notes or private data.
- **Only coaches can see** (stored privately and never sent to family or room screens): guardian name, email and phone, emergency contacts, medical and allergy notes, the authorized-pickup list, and consents.
- **The app does not** show ads, use tracking pixels, sell or share data, store photos or video, use biometrics, or track location.
- **Retention:** child activity data is deleted within 90 days after the season ends, unless the family asks to keep their child's Passport. Registration records are kept 3 years, then deleted. Interest-list entries are deleted if the Lab hasn't started within 12 months.
- Lab data is never shared with or used for SelassieFest. See the [data-sharing agreement](https://selassiefest.com/dj-lab/governance/data-sharing-agreement-selassiefest.html) and the [privacy policy](https://selassiefest.com/dj-lab/privacy/index.html).

Never add a field that sends private guardian, medical or pickup data to a family or room screen. Any change to what a screen can see needs the President's review (see [`../CONTRIBUTING.md`](../CONTRIBUTING.md)).

## Server-synced clock

Class time runs on the **server's clock, not each device's.** Every poll returns the server time, and the app uses the round trip to work out how far off this device's clock is. Coaches stamp clock changes in server time, so every screen counts from the same instant, even if a tablet's own clock is wrong.

Clients poll every couple of seconds (`djlab_state` with a room code, `djlab_family_state` with a family link, `djlab_coach_state` for a coach). Each write bumps the class version, so a poll with nothing new returns almost nothing.

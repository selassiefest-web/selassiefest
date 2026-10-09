# Live class app (`/dj-lab/live/`)

The live class app is the shared classroom screen for a Rainbow DJ Lab session (the app calls the course brand "Rainbow DJ Academy"). Every screen in the room, whether kid, station, coach or parent, follows the same session clock and sees the same board.

## What it does

- **Session clock.** It runs a 90-minute session through its 9 blocks (Drop In, Mission Card, Watch Me Think, Deck Time 1, Move Break, Deck Time 2, Wordplay Lab, Spotlight, Check Out), drawn as a rainbow waveform with one bar per minute. It also supports the 2-hour spring fast-track workshops (W1–W6).
- **Station board.** It shows groups of 4 kids per controller, with jobs (DJ, Co-pilot, Hype, Logger) rotating every 3 minutes 45 seconds. There are up to 3 stations.
- **Kid check-ins.** Each kid records a prediction, a Mild/Medium/Spicy challenge level, a traffic-light self-rating, a "Next time I'll…" line, a "Data!" count and a Mix Log.
- **Passport stamps and glow notes**, given by coaches.
- **Coach controls:** running and moving the clock, editing the class roster, stamping Passports, writing glows, approving registrations, and sending optional recap emails to families who opted in.

## Class codes

- Each class has a 6-character class code. Families and kids join with it (for example `/dj-lab/live/?c=CODE`).
- With the code, a screen can read the class board and write **only its own kid's** check-in fields.
- **Anyone with the code sees the whole class's board.** Share it only with enrolled families. A coach can archive a class or issue a new code.

## Coach sign-in

- Coaches sign in with an **emailed one-time link** ("magic link"). There are no passwords.
- A link can be requested only for an email address on the coach roster, and an unused link expires after 30 minutes.
- Only a signed-in coach session can run the clock or make coach changes. Everyone else is read-only, apart from their own kid's check-in.

## Data model (summary)

The source of truth is `supabase/dj-lab.sql` in the repo root.

| Table | Holds |
|---|---|
| `djlab_coaches` | Coach roster (email, display name) |
| `djlab_coach_login_links` | One-time sign-in links and active coach sessions |
| `djlab_cohorts` | A class: name, class code, the shared live clock state, a version number |
| `djlab_kids` | A kid in a class: first name + last initial, station, seat, stamps, check-in times, glow notes; **private:** guardian name, email, phone, recap opt-in |
| `djlab_checkins` | One row per kid per session: prediction, level, self-rating, next-time line, Data! count, Mix Log |
| `djlab_recaps_sent` | Which recap emails were sent, so none goes twice |
| `djlab_registrations` | Registration requests (submitted through the Turnstile-protected form) awaiting coach approval |

Every table has row-level security on. The page never reads tables directly. All access goes through security-definer functions (`djlab_state`, `djlab_checkin`, `djlab_coach_*`). Recap emails are sent by the `djlab-send-recaps` Edge Function through Resend.

## Privacy boundaries

- **Families with the class code can see:** each child's first name and last initial, station, check-in time, in-class activity (prediction, level, self-rating, "Next time I'll…", Data! count, Mix Log), Passport stamps and glow notes.
- **Only coaches can see** (stored privately and never sent to the page): guardian name, email and phone, emergency contacts, medical and allergy notes, the authorized-pickup list, and consents.
- **The app does not** show ads, use tracking pixels, sell or share data, store photos or video, use biometrics, or track location.
- **Retention:** child activity data is deleted within 90 days after the season ends, unless the family asks to keep their child's Passport. Registration records are kept 3 years, then deleted.
- Lab data is never shared with or used for SelassieFest. See the [data-sharing agreement](https://selassiefest.com/dj-lab/governance/data-sharing-agreement-selassiefest.html) and the [privacy policy](https://selassiefest.com/dj-lab/privacy/index.html).

Never add a field that sends private guardian, medical or pickup data to the page. Any change to what the page can see needs the President's review (see [`../CONTRIBUTING.md`](../CONTRIBUTING.md)).

## Server-synced clock

Class time runs on the **server's clock, not each device's.** Every poll returns the server time, and the app uses the round trip to work out how far off this device's clock is. Coaches stamp clock changes in server time, so every screen counts from the same instant, even if a tablet's own clock is wrong.

Clients poll `djlab_state(code, version)` every couple of seconds. Each write bumps the class version, so a poll with nothing new returns almost nothing.

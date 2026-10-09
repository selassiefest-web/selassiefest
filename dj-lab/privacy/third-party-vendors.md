---
title: Third-Party Vendors
description: Every outside service Rainbow DJ Lab uses, what each one does, and exactly what family data it touches.
---

## Our service providers

Rainbow DJ Lab is a small program, so we use a few established outside services instead of running our own servers. Each one gets only what it needs to do its job. **None of them is allowed to use your family's information for advertising, and we don't sell or share data with anyone else.**

> **Status:** The Lab is proposed and not running yet. This list describes the class app as built. Signed data-protection terms with each provider, reviewed against the 2025 COPPA Rule amendments, are part of our launch work. See the [launch checklist](/dj-lab/governance/index.html).

## Vendor table

| Vendor | What it does for us | What data it touches | Privacy policy |
|---|---|---|---|
| **Supabase** | Our database, and the server functions that run the class app and send emails | **Everything the Lab stores:** registrations (guardian contact, emergency contacts, medical and allergy notes, pickup list, consents), the class board, sign-out records, coach sign-in records | [supabase.com/privacy](https://supabase.com/privacy) |
| **Resend** | Sends the Lab's emails | Recipient email addresses and email contents: registration confirmations, opt-in session recaps (child's first name, the session's mission, self-rating, coach's note), coach sign-in links, sign-out notices to parents (who picked the child up, when, and that ID was checked), and the registration notice to Stephen Henry, which shows medical, pickup and custody information only as **yes/no flags**, never the details | [resend.com/legal/privacy-policy](https://resend.com/legal/privacy-policy) |
| **Cloudflare Turnstile** | A bot check on the registration form, so automated spam can't flood it | Technical signals from the browser and device filling in the form (such as IP address). It doesn't receive what you type into the form | [cloudflare.com/privacypolicy](https://www.cloudflare.com/privacypolicy/) (see its Turnstile section) |
| **GitHub Pages** | Hosts the Lab's web pages | Standard web-request information (such as IP address and pages requested). The pages themselves contain no family data | [GitHub General Privacy Statement](https://docs.github.com/en/site-policy/privacy-policies/github-general-privacy-statement) |
| **Google Fonts** | Supplies the typefaces the pages use | Standard web-request information (IP address, browser details) when the page loads. No family data | [Google Privacy Policy](https://policies.google.com/privacy) |
| **cdnjs** | Supplies icons used by some pages | Standard web-request information when the page loads. No family data | cdnjs is delivered over Cloudflare's network; see [cloudflare.com/privacypolicy](https://www.cloudflare.com/privacypolicy/) |
| **jsDelivr** | Supplies the code library the class app uses to talk to the database | Standard web-request information when the page loads. No family data | [jsdelivr.com](https://www.jsdelivr.com/) |

## What "standard web-request information" means

Whenever your phone or computer loads any web page, it tells the server delivering each file its IP address and basic browser details, so the file can be sent back. Our hosting, font, icon and code-library providers get that, the same as for any website. They don't get your child's name, anything typed into the app, or anything from the class board.

## What none of them get

- No advertising networks. We don't use any.
- No analytics or tracking pixels in the Lab pages.
- No data brokers. We never sell or share data.

## How we choose and manage vendors

- **Only what's needed.** A vendor gets only the data required for its job.
- **Locked-down database.** The database tables are closed to the public page. The family page gets only the class-board fields, and private fields go only to a signed-in coach.
- **Reviewing contracts before launch.** Under the federal COPPA Rule, we must take reasonable steps to release children's information only to providers that can keep it confidential and secure. Confirming each provider's data-protection terms is part of our launch work.
- **We'll tell you about changes.** If we add or replace a vendor that touches family data, we'll update this page and email registered families first.

## Questions

Stephen Henry, 414-909-3279, stephen@selassiefest.com.

## Sources

- Federal Trade Commission, [Complying with COPPA: Frequently Asked Questions](https://www.ftc.gov/business-guidance/resources/complying-coppa-frequently-asked-questions): disclosure to service providers and their confidentiality and security.
- Each vendor's privacy policy, linked in the table above.

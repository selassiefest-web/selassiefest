// Announcement for the updated BIOS102 "My grades" page (sent with {"mode":"invite","lesson":"mygrades"}).
// Plain JavaScript-compatible on purpose, so the preview script can load the exact same text the real send uses.
// Short on purpose, and only what applies to that student: the late-work paragraph appears ONLY for a student who has
// something not turned in. Calm wording: no "missed", "lost" or "zero". `first`, `late.items` and `late.until` arrive
// already HTML-escaped. `late` is null for a student with nothing outstanding (which is most students).

export const MYGRADES_SUBJECT = "BIOS102: your My grades page is updated (with a way to plan for Exam 3)";

export function mygradesHtml(first, late) {
  const lateParagraph = late && late.items && late.items.length
    ? `
              <p>${late.items.length === 1 ? "One piece of work is" : "A few pieces of work are"} not turned in yet: ${late.items.join(", ")}. I will accept late work until <strong>${late.until}</strong>. Whether it earns full or partial credit is my decision.</p>`
    : "";
  return `
              <p>Hi ${first},</p>
              <p>Your <strong>My grades</strong> page now has your latest lab scores and a way to plan for Exam 3.</p>
              <p><a href="https://selassiefest.com/BIOS102/my-grades.html">Open My grades</a></p>
              <p>Log in the usual way: go to <a href="https://selassiefest.com/BIOS102/index.html">selassiefest.com/BIOS102</a>, type your class email, and click the link that arrives.</p>${lateParagraph}
              <p>Nothing you do on the page changes your actual grade. If a number looks wrong, just reply to this email.</p>
              <p>Professor Harris</p>`;
}

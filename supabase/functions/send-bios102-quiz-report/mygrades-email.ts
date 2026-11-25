// Announcement for the updated BIOS102 "My grades" page (sent with {"mode":"invite","lesson":"mygrades"}).
// Plain JavaScript-compatible on purpose, so the preview script can load the exact same text the real send uses.
// Calm wording on purpose: no "missed", "lost" or "zero". `first` arrives already HTML-escaped.

export const MYGRADES_SUBJECT = "BIOS102: your My grades page is updated (with a way to plan for Exam 3)";

export function mygradesHtml(first) {
  return `
              <p>Hi ${first},</p>
              <p>Your <strong>My grades</strong> page on the BIOS102 Lab Companion now has your latest lab scores. It is there for you to look at whenever you like, and it takes the guesswork out of Exam 3.</p>
              <p><a href="https://selassiefest.com/BIOS102/my-grades.html">Open My grades</a></p>
              <p>Log in the usual way: go to <a href="https://selassiefest.com/BIOS102/index.html">selassiefest.com/BIOS102</a>, type your class email, and click the link that arrives.</p>
              <p>Here is what you can do on the page:</p>
              <ul>
                <li><strong>See where you stand.</strong> Your lab scores, piece by piece, and your lab grade so far.</li>
                <li><strong>Plan for Exam 3.</strong> Type a score you might get, in points or as a percent, and see what it does to your grade. Or pick the grade you are hoping for and see the score that gets you there.</li>
                <li><strong>See your overall grade.</strong> The lab counts for 50% of your course and lecture counts for the other 50%. Type in your lecture grade as a percent and the page shows your overall grade. Your lecture instructors set the lecture half and your final course grade, so this is a planning tool, not a promise. What you type is saved to your account, so it is there on any device.</li>
                <li><strong>Study for Exam 3 (optional).</strong> At the bottom of the page there is a study guide you can open. It is a checklist of what to be able to do. Your marks save to your account too.</li>
              </ul>
              <p>If anything on your page shows as not turned in, I will accept late work until <strong>Tuesday, December 1 at 4:50 PM Central</strong>. Whether late work earns full or partial credit is my decision.</p>
              <p>Nothing you do on the page changes your actual grade. If a number looks wrong, or the page says your grades are not available, just reply to this email.</p>
              <p>Professor Harris</p>`;
}

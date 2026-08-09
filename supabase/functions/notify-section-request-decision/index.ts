// Fires on UPDATEs to bbpac_formation_section_signup_requests when status
// moves from 'pending' to 'approved' or 'declined' -- see the
// bbpac_formation_notify_section_request_decision trigger function (not
// reproduced in schema.sql, same reason as notify_submission_webhook: it
// embeds a shared secret). Not called from any client-side code; only the
// database itself calls this, authenticated by the shared
// SECTION_DECISION_WEBHOOK_SECRET header rather than a user JWT.
//
// This closes a real gap: approving or declining a request via the Table
// Editor previously changed a status column with nobody outside staff ever
// knowing it happened. Now the requester gets a real email either way.
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const WEBHOOK_SECRET = Deno.env.get("SECTION_DECISION_WEBHOOK_SECRET");
const FROM = "SelassieFest <hello@selassiefest.com>";
const REPLY_TO = "stephen@selassiefest.com";

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

Deno.serve(async (req) => {
  if (req.headers.get("x-webhook-secret") !== WEBHOOK_SECRET) {
    return new Response("Unauthorized", { status: 401 });
  }
  if (req.method !== "POST") {
    return new Response("Method not allowed", { status: 405 });
  }

  const { record } = await req.json();
  const sections = Array.isArray(record.requested_sections) ? record.requested_sections.join(", ") : record.requested_sections;

  let subject: string, html: string;
  if (record.status === "approved") {
    subject = `You're approved — Section ${sections}, Bongo Beach Formation`;
    html = `
      <p>Hi ${escapeHtml(record.full_name)},</p>
      <p>Your request to work on Section ${escapeHtml(String(sections))} of the Bongo Beach Master Due-Diligence Matrix has been <strong>approved</strong>.</p>
      <p>Log in with this email address at <a href="https://selassiefest.com/bbpac/organization/my-section.html">My Section</a> — you'll get a one-time login link, no password needed.</p>
      <p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically by the Bongo Beach formation tracking system.</p>
    `;
  } else if (record.status === "declined") {
    subject = `Update on your Bongo Beach section request`;
    html = `
      <p>Hi ${escapeHtml(record.full_name)},</p>
      <p>Thanks for your interest in Section ${escapeHtml(String(sections))} of the Bongo Beach Master Due-Diligence Matrix. We're not able to take you on for that section right now, but we appreciate you reaching out — feel free to request a different section at
      <a href="https://selassiefest.com/bbpac/organization/join-a-section.html">Join a Section</a>.</p>
      <p style="color:#5b6b7a;font-size:0.85rem;">Sent automatically by the Bongo Beach formation tracking system.</p>
    `;
  } else {
    // Any other status transition -- nothing to email about.
    return new Response(JSON.stringify({ ok: true, skipped: true }), { status: 200 });
  }

  const resendRes = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
    body: JSON.stringify({ from: FROM, to: record.email, reply_to: REPLY_TO, subject, html }),
  });

  if (!resendRes.ok) {
    const errText = await resendRes.text();
    return new Response(JSON.stringify({ error: `Email send failed: ${errText}` }), { status: 502 });
  }

  return new Response(JSON.stringify({ ok: true }), { status: 200 });
});

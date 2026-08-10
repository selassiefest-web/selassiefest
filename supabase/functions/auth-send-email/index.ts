// Supabase Auth "Send Email" Hook. Once enabled in the Dashboard
// (Authentication -> Auth Hooks -> Send Email), GoTrue calls THIS function
// for every auth email on the whole project -- signup confirmation, magic
// link, password recovery, invite, email change, everything -- for every
// venture sharing this Supabase project, not just Bongo Beach/SelassieFest.
// The built-in Email Templates / SMTP Sender Name in the Dashboard stop
// being used at all once this hook is active; this function is now the
// only thing composing and sending those emails.
//
// Why this exists: the Dashboard only has ONE global template and ONE
// global sender name, shared by every venture. Stephen wants each venture
// to look like its own standalone product in the inbox (its own sender
// name, its own link target), not all wearing whichever name was set last.
// VENTURES below is the per-venture routing table -- add an entry for any
// future venture rather than editing the others' behavior.
import { Webhook } from "https://esm.sh/standardwebhooks@1.0.0";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL");
const RESEND_API_KEY = Deno.env.get("RESEND_API_KEY");
const HOOK_SECRET = (Deno.env.get("SEND_EMAIL_HOOK_SECRET") || "").replace("v1,whsec_", "");
const FROM_EMAIL = "hello@selassiefest.com";

function escapeHtml(s: unknown) {
  return String(s == null ? "" : s).replace(/[&<>"']/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c] as string));
}

type EmailData = {
  token_hash: string;
  redirect_to: string;
  email_action_type: string;
  site_url: string;
};

// The classic Supabase-native verify link -- exactly what {{ .ConfirmationURL }}
// would have produced. Used for any venture that hasn't opted into a
// custom click-through confirm page of its own.
function classicVerifyLink(d: EmailData) {
  const base = d.site_url || SUPABASE_URL;
  // GoTrue's GET /verify endpoint takes this value under the query param
  // named "token" (a legacy-naming holdover) -- NOT "token_hash", which is
  // only the correct param name for the POST-based verifyOtp() call that
  // confirm-login.html uses. Confirmed against the native action_link
  // Supabase itself generated earlier this session, which used "token=".
  return `${SUPABASE_URL}/auth/v1/verify?token=${encodeURIComponent(d.token_hash)}&type=${encodeURIComponent(d.email_action_type)}&redirect_to=${encodeURIComponent(d.redirect_to || base)}`;
}

const VENTURES: Array<{ key: string; matches: (redirectTo: string) => boolean; senderName: string; buildLink: (d: EmailData) => string }> = [
  {
    key: "bbpac",
    matches: (redirectTo) => redirectTo.startsWith("https://selassiefest.com/bbpac/"),
    senderName: "Bongo Beach Formation",
    // Routed through the click-through confirm page (fixes email-scanner
    // "phantom link" clicks) instead of the classic direct verify link.
    buildLink: (d) => `https://selassiefest.com/bbpac/organization/confirm-login.html?token_hash=${encodeURIComponent(d.token_hash)}&redirect_to=${encodeURIComponent(d.redirect_to)}`,
  },
  {
    key: "trcevent",
    matches: (redirectTo) => redirectTo.startsWith("https://trcevent.com/"),
    senderName: "TRC Events",
    buildLink: classicVerifyLink,
  },
];

const DEFAULT_VENTURE = { key: "default", senderName: "SelassieFest", buildLink: classicVerifyLink };

function ventureFor(redirectTo: string) {
  return VENTURES.find((v) => redirectTo && v.matches(redirectTo)) || DEFAULT_VENTURE;
}

const LINK_SUBJECTS: Record<string, string> = {
  signup: "Confirm your sign-up",
  magiclink: "Your sign-in link",
  email: "Your sign-in link",
  invite: "You've been invited",
  recovery: "Reset your password",
  email_change: "Confirm your new email",
  reauthentication: "Confirm it's you",
};

function renderLinkEmail(actionType: string, link: string) {
  const subject = LINK_SUBJECTS[actionType] || "Action required";
  const verb = actionType === "recovery" ? "reset your password"
    : actionType === "invite" ? "accept your invitation"
    : actionType === "email_change" ? "confirm your new email"
    : "sign in";
  const buttonLabel = verb === "sign in" ? "Sign in" : "Continue";
  return {
    subject,
    html: `<h2>${escapeHtml(subject)}</h2><p>Follow the link below to ${verb}. This link expires shortly and can only be used once.</p><p><a href="${link}">${buttonLabel}</a></p>`,
  };
}

// Pure informational notifications (no token_hash, nothing to click) --
// not currently triggered by anything on this project, but handled so the
// hook never errors outright if one ever is.
const NOTIFICATION_SUBJECTS: Record<string, string> = {
  password_changed_notification: "Your password was changed",
  email_changed_notification: "Your email was changed",
  phone_changed_notification: "Your phone number was changed",
  identity_linked_notification: "A new sign-in method was linked to your account",
  identity_unlinked_notification: "A sign-in method was removed from your account",
  mfa_factor_enrolled_notification: "Two-factor authentication was enabled",
  mfa_factor_unenrolled_notification: "Two-factor authentication was disabled",
};

Deno.serve(async (req) => {
  const payload = await req.text();
  const headers = Object.fromEntries(req.headers);

  let user: { email: string }, email_data: EmailData;
  try {
    const wh = new Webhook(HOOK_SECRET);
    const verified = wh.verify(payload, headers) as { user: { email: string }; email_data: EmailData };
    user = verified.user;
    email_data = verified.email_data;
  } catch {
    return new Response(JSON.stringify({ error: { http_code: 401, message: "Invalid webhook signature" } }), {
      status: 401,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const actionType = email_data.email_action_type;
    const redirectTo = email_data.redirect_to || "";
    const venture = ventureFor(redirectTo);

    let subject: string, html: string;
    if (NOTIFICATION_SUBJECTS[actionType]) {
      subject = NOTIFICATION_SUBJECTS[actionType];
      html = `<p>${escapeHtml(subject)}. If this wasn't you, contact us immediately.</p>`;
    } else {
      const link = venture.buildLink(email_data);
      ({ subject, html } = renderLinkEmail(actionType, link));
    }

    const resendRes = await fetch("https://api.resend.com/emails", {
      method: "POST",
      headers: { Authorization: `Bearer ${RESEND_API_KEY}`, "Content-Type": "application/json" },
      body: JSON.stringify({ from: `${venture.senderName} <${FROM_EMAIL}>`, to: user.email, subject, html }),
    });

    if (!resendRes.ok) {
      const errText = await resendRes.text();
      return new Response(JSON.stringify({ error: { http_code: 500, message: `Email send failed: ${errText}` } }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(JSON.stringify({}), { status: 200, headers: { "Content-Type": "application/json" } });
  } catch (err) {
    return new Response(JSON.stringify({ error: { http_code: 500, message: (err as Error).message || "Unknown error" } }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});

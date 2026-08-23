// Fires on inserts into notification-worthy tables (marketplace_preorders,
// and more as they're added) via a database trigger
// that calls net.http_post — see supabase/schema.sql. Not called from any
// client-side code; only the database itself calls this, authenticated by
// the shared WEBHOOK_SECRET header rather than a user JWT.

const RESEND_API_KEY = Deno.env.get('RESEND_API_KEY')!;
const WEBHOOK_SECRET = Deno.env.get('WEBHOOK_SECRET')!;
// Auto-injected into every Edge Function's env by Supabase -- used only to
// fetch the signed PDF back out of the private security-guard-contracts
// Storage bucket (see fetchStorageObjectAsBase64 below), which bypasses RLS.
const SUPABASE_URL = Deno.env.get('SUPABASE_URL')!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!;
const NOTIFY_TO = 'selassiefest@gmail.com';
// Bongo Beach PAC (bbpac/) is a Ras Tafari Inc. community initiative, not
// the festival itself -- its forms go to Stephen directly rather than the
// shared festival inbox above.
const BBPAC_NOTIFY_TO = 'stephen@selassiefest.com';
// C. L. Rainford Welding & Fabrication (clrwf/) is an unrelated business,
// same shared-Supabase-project pattern as bbpac/ above. Routed to Stephen
// for now, same reasoning as BBPAC_NOTIFY_TO -- update to Rainford's own
// inbox once he's onboarded to receive leads directly.
const CLRWF_NOTIFY_TO = 'stephen@selassiefest.com';
// selassiefest.com is verified with Resend, so mail now sends from a real
// address instead of the onboarding@resend.dev sandbox (which could only
// ever deliver to the account's own inbox). reply_to keeps replies landing
// in the org's actual inbox rather than an address nobody checks.
const FROM = 'SelassieFest <hello@selassiefest.com>';
const REPLY_TO = 'selassiefest@gmail.com';
// "SelassieFest Newsletter" Resend Audience — lets staff compose and send
// campaigns to subscribers directly from the Resend dashboard (Broadcasts)
// without any code here. Every newsletter_subscribers insert gets synced
// into it below, in addition to the subscriber's own confirmation email.
const NEWSLETTER_AUDIENCE_ID = '6561e97b-31be-45c8-a069-e8d8ae29711e';
const STORAGE_PUBLIC_BASE = 'https://xdjbgcqaynnzykrglgnf.supabase.co/storage/v1/object/public/game-submissions';
const VENDOR_APPLICATIONS_PUBLIC_BASE = 'https://xdjbgcqaynnzykrglgnf.supabase.co/storage/v1/object/public/vendor-applications';

// Downloads a private Storage object (service-role, bypasses RLS) and
// base64-encodes it for Resend's `attachments[].content` field. Contract
// PDFs here are a few pages/KB at most, so the char-by-char binary-string
// conversion (btoa needs a binary string, not a raw byte array) is cheap.
async function fetchStorageObjectAsBase64(bucket: string, path: string): Promise<string> {
  const res = await fetch(`${SUPABASE_URL}/storage/v1/object/${bucket}/${path}`, {
    headers: {
      Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}`,
      apikey: SUPABASE_SERVICE_ROLE_KEY,
    },
  });
  if (!res.ok) {
    throw new Error(`Storage fetch failed (${bucket}/${path}): ${res.status} ${await res.text()}`);
  }
  const bytes = new Uint8Array(await res.arrayBuffer());
  let binary = '';
  for (const b of bytes) binary += String.fromCharCode(b);
  return btoa(binary);
}

function escapeHtml(s: unknown): string {
  return String(s ?? '').replace(/[&<>"']/g, (c) =>
    ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' } as Record<string, string>)[c]
  );
}

function formatMarketplacePreorder(record: Record<string, any>) {
  const items = Array.isArray(record.items) ? record.items : [];
  const itemsList = items
    .map((i: any) => `${escapeHtml(i.name)}${i.variant ? ' (' + escapeHtml(i.variant) + ')' : ''} x${escapeHtml(i.qty)}`)
    .join('<br>');
  return {
    subject: `New Marketplace Pre-Order — ${record.customer_name}`,
    html: `
      <h2>New Marketplace Pre-Order</h2>
      <p><strong>Customer:</strong> ${escapeHtml(record.customer_name)} (${escapeHtml(record.customer_email)}, ${escapeHtml(record.customer_phone)})</p>
      <p><strong>Pickup:</strong> ${escapeHtml(record.pickup_time)}</p>
      <p><strong>Guests:</strong> ${escapeHtml(record.guest_count)}</p>
      <p><strong>Items:</strong><br>${itemsList}</p>
      <p><strong>Total:</strong> $${escapeHtml(record.total_amount)}</p>
    `,
  };
}

function formatVolunteerSignup(record: Record<string, any>) {
  return {
    subject: `New Volunteer Application — ${record.full_name}`,
    html: `
      <h2>New Volunteer Application</h2>
      <p><strong>Name:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.email)}, ${escapeHtml(record.phone)})</p>
      <p><strong>Age:</strong> ${escapeHtml(record.age)}</p>
      <p><strong>Preferred Role:</strong> ${escapeHtml(record.role_choice)}</p>
      <p><strong>Shift:</strong> ${escapeHtml(record.shift_preference)}</p>
      <p><strong>T-Shirt:</strong> ${escapeHtml(record.tshirt_size)}</p>
      <p><strong>Emergency Contact:</strong> ${escapeHtml(record.emergency_contact)}</p>
      <p><strong>Accommodations:</strong> ${escapeHtml(record.accommodations)}</p>
      <p><strong>Referral:</strong> ${escapeHtml(record.referral_source)}</p>
      <p><strong>Waiver Accepted:</strong> ${record.waiver_accepted ? 'Yes' : 'No'}</p>
    `,
  };
}

function formatSponsorInquiry(record: Record<string, any>) {
  const fields = Array.isArray(record.fields) ? record.fields : [];
  const fieldsList = fields.map((f: any) => `<p><strong>${escapeHtml(f.label)}:</strong> ${escapeHtml(f.value)}</p>`).join('');
  return {
    subject: `New Sponsor Inquiry — ${record.source_page || 'sponsors'}`,
    html: `
      <h2>New Sponsor Inquiry</h2>
      <p><strong>From page:</strong> ${escapeHtml(record.source_page)}</p>
      ${fieldsList}
    `,
  };
}

function formatCampRegistration(record: Record<string, any>) {
  const data = record.registration_data || {};
  const weeks = Object.keys(data)
    .filter((k) => /^week\d+$/.test(k) && data[k])
    .map((k) => k.replace('week', 'Week '));
  return {
    subject: `New Camp Registration — ${record.camper_name}`,
    html: `
      <h2>New Camp Registration</h2>
      <p><strong>Camper:</strong> ${escapeHtml(record.camper_name)}</p>
      <p><strong>Guardian:</strong> ${escapeHtml(record.guardian_name)} (${escapeHtml(record.guardian_email)}, ${escapeHtml(record.guardian_phone)})</p>
      <p><strong>Weeks Selected:</strong> ${weeks.length ? escapeHtml(weeks.join(', ')) : 'None selected'}</p>
      <p><strong>Full details:</strong> see the camp_registrations table in Supabase (registration_data column) for allergies, medical info, consents, and everything else submitted.</p>
    `,
  };
}

function formatDonation(record: Record<string, any>) {
  const fundLabel = record.fund === 'scholarship' ? 'Youth Scholarship Fund' : 'General Fund';
  return {
    subject: `New Donation — $${escapeHtml(record.amount)}${record.recurring === 'true' ? '/mo' : ''} (${fundLabel})`,
    html: `
      <h2>New Donation</h2>
      <p><strong>Fund:</strong> ${escapeHtml(fundLabel)}</p>
      <p><strong>Amount:</strong> $${escapeHtml(record.amount)} ${escapeHtml((record.currency || 'usd').toUpperCase())}${record.recurring === 'true' ? ' / month (recurring)' : ' (one-time)'}</p>
      <p><strong>Donor Email:</strong> ${escapeHtml(record.email)}</p>
      <p><strong>Stripe Payment Intent:</strong> ${escapeHtml(record.payment_intent_id)}</p>
    `,
  };
}

function formatGameSubmission(record: Record<string, any>) {
  const photoUrl = record.photo_path ? `${STORAGE_PUBLIC_BASE}/${record.photo_path}` : null;
  const videoUrl = record.video_path ? `${STORAGE_PUBLIC_BASE}/${record.video_path}` : null;
  return {
    subject: `New Games Archive Submission — ${record.game_name}`,
    html: `
      <h2>New Games Archive Submission</h2>
      <p><strong>Game:</strong> ${escapeHtml(record.game_name)} (${escapeHtml(record.game_slug)})</p>
      <p><strong>Submitted by:</strong> ${escapeHtml(record.submitter_name)}${record.submitter_email ? ' (' + escapeHtml(record.submitter_email) + ')' : ''}</p>
      ${record.story_text ? `<p><strong>Story:</strong><br>${escapeHtml(record.story_text)}</p>` : ''}
      ${photoUrl ? `<p><strong>Photo:</strong> <a href="${photoUrl}">${photoUrl}</a></p>` : ''}
      ${videoUrl ? `<p><strong>Video (temporary — move to YouTube, then update video_path and delete from Storage):</strong> <a href="${videoUrl}">${videoUrl}</a></p>` : ''}
      <p><strong>Status:</strong> ${escapeHtml(record.status)}</p>
    `,
  };
}

function formatGameSubmissionConfirmation(record: Record<string, any>) {
  return {
    subject: `Thanks for sharing your ${record.game_name} story!`,
    html: `
      <h2>Thank you, ${escapeHtml(record.submitter_name)}!</h2>
      <p>We got your ${escapeHtml(record.game_name)} story${record.photo_path ? ', photo' : ''}${record.video_path ? ', video' : ''} for the Pickney Time Games Archive.</p>
      <p>Our team reviews every submission by hand — if yours is featured, we'll credit you right on the game's page.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">Thank you for helping preserve this piece of culture for the next generation.</p>
    `,
  };
}

// Most tables' triggers exist to notify staff of a new submission; a couple
// (newsletter signups, game story submissions) ALSO/instead send a
// confirmation back to the person who submitted — see TABLE_CONFIG below.
function formatDh101Signup(record: Record<string, any>) {
  return {
    subject: `New Dancehall 101 signup — ${record.full_name}`,
    html: `
      <h2>New Dancehall 101 Free Ticket Signup</h2>
      <p><strong>Name:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.edu_email)})</p>
      <p><strong>School ID:</strong> ${escapeHtml(record.school_id)}</p>
      <p><strong>Segment:</strong> ${escapeHtml(record.student_segment)}</p>
      ${record.ambassador_id ? `<p><strong>Ambassador ID:</strong> ${escapeHtml(record.ambassador_id)}</p>` : ''}
      <p>Verification email has been sent to the student.</p>
    `,
  };
}

function formatDh101VerificationEmail(record: Record<string, any>) {
  const verifyUrl = `https://selassiefest.com/dancehall101/ticket.html?token=${encodeURIComponent(record.verification_token)}`;
  return {
    subject: `Confirm your free Dancehall 101 ticket`,
    html: `
      <h2>You're almost in — Dancehall 101</h2>
      <p>Hi ${escapeHtml(record.full_name)}, click below to verify your .edu email and get your free ticket:</p>
      <p style="margin:20px 0;"><a href="${verifyUrl}" style="background:#0E5E36;color:#fff;padding:12px 22px;border-radius:8px;text-decoration:none;display:inline-block;">Verify &amp; view my ticket</a></p>
      <p>Bring your ticket (this same link) and a physical photo ID (21+) to the door on Wednesday night at Uptown Lounge.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">Dancehall 101 — presented by TRC Events. If you didn't sign up for this, you can safely ignore this email.</p>
    `,
  };
}

function formatNewsletterConfirmation(record: Record<string, any>) {
  return {
    subject: `You're on the list — SelassieFest`,
    html: `
      <h2>Welcome to SelassieFest!</h2>
      <p>You're signed up for festival dates, camp registration, and community updates.</p>
      <p>We'll only email you when there's something worth sharing.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">If you didn't sign up for this, you can safely ignore this email.</p>
    `,
  };
}

function formatVendorApplication(record: Record<string, any>) {
  const photos: string[] = Array.isArray(record.photo_paths) ? record.photo_paths : [];
  const photoUrls = photos.map((p) => `${VENDOR_APPLICATIONS_PUBLIC_BASE}/${p}`);
  const logoUrl = record.logo_path ? `${VENDOR_APPLICATIONS_PUBLIC_BASE}/${record.logo_path}` : null;
  return {
    subject: `New Vendor Application — ${record.business_name}`,
    html: `
      <h2>New Heritage Village Vendor Application</h2>
      <p><strong>Business:</strong> ${escapeHtml(record.business_name)} (${escapeHtml(record.contact_email)})</p>
      <p><strong>Items sold:</strong><br>${escapeHtml(record.product_description)}</p>
      ${record.webpage_highlight ? `<p><strong>Webpage should highlight:</strong><br>${escapeHtml(record.webpage_highlight)}</p>` : ''}
      <p><strong>Marketing plan:</strong><br>${escapeHtml(record.marketing_plan)}</p>
      ${record.preferred_space ? `<p><strong>Preferred space:</strong> ${escapeHtml(record.preferred_space)}</p>` : ''}
      ${logoUrl ? `<p><strong>Logo:</strong> <a href="${logoUrl}">${logoUrl}</a></p>` : ''}
      ${photoUrls.length ? `<p><strong>Product photos:</strong><br>${photoUrls.map((u) => `<a href="${u}">${u}</a>`).join('<br>')}</p>` : ''}
      <p><strong>Status:</strong> ${escapeHtml(record.status)}</p>
    `,
  };
}

function formatPlatesForPurposeResponse(record: Record<string, any>) {
  const decisionLabel =
    { yes: "YES — they're in", no: 'No / declined', maybe: 'Maybe / needs follow-up' }[record.decision] || record.decision;
  return {
    subject: `Plates for Purpose — ${record.business_name}: ${decisionLabel}`,
    html: `
      <h2>Plates for Purpose — Restaurant Decision</h2>
      <p><strong>Restaurant:</strong> ${escapeHtml(record.business_name)} (${escapeHtml(record.restaurant_slug)})</p>
      <p><strong>Decision:</strong> ${escapeHtml(decisionLabel)}</p>
      ${record.offer_details ? `<p><strong>What they're offering:</strong><br>${escapeHtml(record.offer_details)}</p>` : ''}
      ${record.respondent_name ? `<p><strong>Respondent:</strong> ${escapeHtml(record.respondent_name)}${record.respondent_title ? ', ' + escapeHtml(record.respondent_title) : ''}</p>` : ''}
      ${record.email ? `<p><strong>Email:</strong> ${escapeHtml(record.email)}</p>` : ''}
      ${record.contact_info ? `<p><strong>Other contact info:</strong> ${escapeHtml(record.contact_info)}</p>` : ''}
      ${record.message ? `<p><strong>Message:</strong><br>${escapeHtml(record.message)}</p>` : ''}
    `,
  };
}

// Confirmation sent back to the restaurant itself, only on a "yes" decision
// (a maybe/no doesn't have an auction item to prepare) -- see the
// conditional `to` in TABLE_CONFIG below, which is what actually gates this
// to decision === 'yes'.
function formatPlatesForPurposeConfirmation(record: Record<string, any>) {
  return {
    subject: `You're in! Your Plates for Purpose auction item is being prepared`,
    html: `
      <h2>Thank you, ${escapeHtml(record.business_name)}!</h2>
      <p>We've got your "yes" for Plates for Purpose${record.offer_details ? ` — <strong>${escapeHtml(record.offer_details)}</strong>` : ''}.</p>
      <p>Your auction item is being prepared now. Someone from the SelassieFest team will follow up shortly to confirm the details and next steps.</p>
      <p>If you have a logo on file with us, you'll find your official "Proud Plates for Purpose Partner" badge attached — feel free to share it on your own social media!</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">Ras Tafari Inc — the 501(c)(3) nonprofit behind SelassieFest. Questions in the meantime? Reply to this email or call (414) 909-3279.</p>
    `,
  };
}

// Looks up the restaurant's badge_path by slug (service-role, bypasses RLS
// on the otherwise anon-unreachable plates_for_purpose_restaurants table).
async function fetchRestaurantBadgePath(slug: string): Promise<string | null> {
  const res = await fetch(
    `${SUPABASE_URL}/rest/v1/plates_for_purpose_restaurants?slug=eq.${encodeURIComponent(slug)}&select=badge_path`,
    { headers: { apikey: SUPABASE_SERVICE_ROLE_KEY, Authorization: `Bearer ${SUPABASE_SERVICE_ROLE_KEY}` } },
  );
  if (!res.ok) return null;
  const rows = await res.json();
  return rows[0]?.badge_path ?? null;
}

function formatEventNotifySignup(record: Record<string, any>) {
  return {
    subject: `New "notify me" signup — ${record.event_name}`,
    html: `
      <h2>New Notify-Me Signup</h2>
      <p><strong>Event:</strong> ${escapeHtml(record.event_name)} (${escapeHtml(record.event_slug)})</p>
      <p><strong>Email:</strong> ${escapeHtml(record.email)}</p>
    `,
  };
}

function formatSecurityGuardContract(record: Record<string, any>) {
  return {
    subject: `Signed Security Guard Contract — ${record.vendor_company_name}`,
    html: `
      <h2>Signed Security Guard Services Agreement</h2>
      <p><strong>Event:</strong> SelassieFest, July 25, 2026, 6:00 PM – 10:00 PM gate check-in shift</p>
      <p><strong>Vendor:</strong> ${escapeHtml(record.vendor_company_name)}</p>
      ${record.vendor_address ? `<p><strong>Vendor Address:</strong> ${escapeHtml(record.vendor_address)}</p>` : ''}
      ${record.vendor_contact ? `<p><strong>Vendor Contact:</strong> ${escapeHtml(record.vendor_contact)}</p>` : ''}
      ${record.guard_names ? `<p><strong>Guards Assigned:</strong> ${escapeHtml(record.guard_names)}</p>` : ''}
      <p><strong>Signed by:</strong> ${escapeHtml(record.signer_name)}${record.signer_title ? ', ' + escapeHtml(record.signer_title) : ''}</p>
      <p>Signed PDF is attached.</p>
    `,
  };
}

// 2nd Chance Housing lease e-signature bridge -- see supabase/schema.sql's
// "lease e-signature bridge" section for the full data-flow explanation.
// This is unrelated-organization mail routed through SelassieFest's already
// -verified Resend sending domain (a shared-infrastructure decision, not a
// SelassieFest feature), so both formatters below use the `from`/`replyTo`
// overrides to keep the display name and reply address correct for 2nd
// Chance Housing rather than SelassieFest.
const LEASE_SIGN_FROM = '2nd Chance Housing <hello@selassiefest.com>';
const LEASE_MANAGER_EMAIL = 'mkepropertymanager@gmail.com';

function formatLeaseSigningRequest(record: Record<string, any>) {
  const signUrl = `https://selassiefest.com/lease-sign/?id=${record.id}`;
  return {
    subject: `Please review and sign your lease${record.unit_label ? ' — ' + record.unit_label : ''}`,
    html: `
      <h2>Your lease is ready to sign</h2>
      <p>Hi ${escapeHtml(record.tenant_name)},</p>
      <p>Please review and sign your lease${record.unit_label ? ` for <strong>${escapeHtml(record.unit_label)}</strong>` : ''} using the secure link below:</p>
      <p style="margin:24px 0;"><a href="${signUrl}" style="background:#2b7a4b;color:#fff;padding:12px 24px;border-radius:6px;text-decoration:none;font-weight:600;">Review &amp; Sign Lease</a></p>
      <p style="font-size:0.85rem;color:#888;">Or copy this link: ${signUrl}</p>
      <p>Once you sign, you and our office will both automatically receive a copy of the fully signed lease by email.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">Questions? Reply to this email.</p>
    `,
  };
}

function formatLeaseSigningRequestStaffCopy(record: Record<string, any>) {
  return {
    subject: `The Attached Lease was sent to ${record.tenant_name}`,
    html: `
      <h2>Lease sent for signature</h2>
      <p><strong>Tenant:</strong> ${escapeHtml(record.tenant_name)} (${escapeHtml(record.tenant_email)})</p>
      ${record.unit_label ? `<p><strong>Unit:</strong> ${escapeHtml(record.unit_label)}</p>` : ''}
      <p>A copy of the lease as sent (unsigned) is attached for your records. You'll get another email once it's signed.</p>
    `,
  };
}

function formatLeaseSignatureStaff(record: Record<string, any>) {
  return {
    subject: `Signed Lease — ${record.tenant_name}${record.unit_label ? ' (' + record.unit_label + ')' : ''}`,
    html: `
      <h2>Lease Signed</h2>
      <p><strong>Tenant:</strong> ${escapeHtml(record.tenant_name)} (${escapeHtml(record.tenant_email)})</p>
      ${record.unit_label ? `<p><strong>Unit:</strong> ${escapeHtml(record.unit_label)}</p>` : ''}
      <p><strong>Signed as:</strong> ${escapeHtml(record.signature_typed_name)}</p>
      <p><strong>Signed at:</strong> ${escapeHtml(record.signed_at)}</p>
      <p>Signed PDF is attached.</p>
    `,
  };
}

function formatLeaseSignatureTenantCopy(record: Record<string, any>) {
  return {
    subject: `Your signed lease copy${record.unit_label ? ' — ' + record.unit_label : ''}`,
    html: `
      <h2>Thank you, ${escapeHtml(record.tenant_name)}!</h2>
      <p>Your lease${record.unit_label ? ` for <strong>${escapeHtml(record.unit_label)}</strong>` : ''} has been signed and submitted. A copy is attached for your records.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">Questions? Reply to this email.</p>
    `,
  };
}

function formatEventNotifyConfirmation(record: Record<string, any>) {
  return {
    subject: `You're on the list — ${record.event_name}`,
    html: `
      <h2>You're on the list!</h2>
      <p>We'll email you the moment tickets for <strong>${escapeHtml(record.event_name)}</strong> go live.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">If you didn't sign up for this, you can safely ignore this email.</p>
    `,
  };
}

// 63rd Street Bongo Beach Park Advisory Council (bbpac/) formatters -- six
// simple low-stakes forms, all notifying BBPAC_NOTIFY_TO only (no submitter
// confirmation), same pattern as sponsor_inquiries/vendor_applications above.
function formatBbpacMeetingNotify(record: Record<string, any>) {
  return {
    subject: `New Bongo Beach PAC meeting notify signup`,
    html: `
      <h2>New Meeting Notification Signup</h2>
      <p><strong>Email:</strong> ${escapeHtml(record.email)}</p>
    `,
  };
}

function formatBbpacVolunteerSignup(record: Record<string, any>) {
  return {
    subject: `New Bongo Beach PAC Volunteer — ${record.full_name}`,
    html: `
      <h2>New Bongo Beach PAC Volunteer Signup</h2>
      <p><strong>Name:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.email)}${record.phone ? ', ' + escapeHtml(record.phone) : ''})</p>
      ${record.interest_area ? `<p><strong>Interest area:</strong> ${escapeHtml(record.interest_area)}</p>` : ''}
      ${record.availability ? `<p><strong>Availability:</strong> ${escapeHtml(record.availability)}</p>` : ''}
    `,
  };
}

function formatBbpacMembershipSignup(record: Record<string, any>) {
  return {
    subject: `New Friends of Bongo Beach Member — ${record.full_name}`,
    html: `
      <h2>New Friends of Bongo Beach Membership Signup</h2>
      <p><strong>Name:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.email)})</p>
      ${record.membership_level ? `<p><strong>Membership level:</strong> ${escapeHtml(record.membership_level)}</p>` : ''}
      ${record.message ? `<p><strong>Message:</strong><br>${escapeHtml(record.message)}</p>` : ''}
    `,
  };
}

// Sent back to the new member themselves, in addition to the staff
// notification above -- points them at the member directory so they can
// confirm they were actually added rather than just trusting the form.
function formatBbpacMembershipConfirmation(record: Record<string, any>) {
  return {
    subject: `Welcome to Friends of Bongo Beach!`,
    html: `
      <h2>Welcome, ${escapeHtml(record.full_name)}!</h2>
      <p>You're in — thanks for joining Friends of Bongo Beach${record.membership_level ? ` as a <strong>${escapeHtml(record.membership_level)}</strong>` : ''}.</p>
      <p>Want to double-check you're actually on the list? Head to our <a href="https://selassiefest.com/bbpac/get-involved/members.html">member directory</a> and confirm your email to see your name.</p>
      <p style="margin-top:24px;color:#888;font-size:0.85rem;">Questions in the meantime? Reply to this email.</p>
    `,
  };
}

function formatBbpacSponsorInquiry(record: Record<string, any>) {
  return {
    subject: `New Bongo Beach PAC Sponsor Inquiry — ${record.business_name}`,
    html: `
      <h2>New Bongo Beach PAC Sponsor Inquiry</h2>
      <p><strong>Business:</strong> ${escapeHtml(record.business_name)}</p>
      ${record.contact_name ? `<p><strong>Contact:</strong> ${escapeHtml(record.contact_name)}</p>` : ''}
      <p><strong>Email:</strong> ${escapeHtml(record.email)}</p>
      ${record.message ? `<p><strong>Message:</strong><br>${escapeHtml(record.message)}</p>` : ''}
    `,
  };
}

function formatBbpacVendorApplication(record: Record<string, any>) {
  return {
    subject: `New Bongo Beach PAC Vendor Application — ${record.business_name}`,
    html: `
      <h2>New Bongo Beach PAC Vendor Application</h2>
      <p><strong>Business:</strong> ${escapeHtml(record.business_name)}</p>
      ${record.contact_name ? `<p><strong>Contact:</strong> ${escapeHtml(record.contact_name)}</p>` : ''}
      <p><strong>Email:</strong> ${escapeHtml(record.email)}</p>
      ${record.product_description ? `<p><strong>Products:</strong><br>${escapeHtml(record.product_description)}</p>` : ''}
      ${record.preferred_event ? `<p><strong>Preferred event:</strong> ${escapeHtml(record.preferred_event)}</p>` : ''}
    `,
  };
}

function formatBbpacContactMessage(record: Record<string, any>) {
  return {
    subject: `New Bongo Beach PAC Contact Message — ${record.name}`,
    html: `
      <h2>New Bongo Beach PAC Contact Message</h2>
      <p><strong>From:</strong> ${escapeHtml(record.name)} (${escapeHtml(record.email)})</p>
      ${record.topic ? `<p><strong>Topic:</strong> ${escapeHtml(record.topic)}</p>` : ''}
      <p><strong>Message:</strong><br>${escapeHtml(record.message)}</p>
    `,
  };
}

function formatBbpacPhotoSubmission(record: Record<string, any>) {
  return {
    subject: `New Bongo Beach PAC Photo Submission — ${record.name}`,
    html: `
      <h2>New Bongo Beach PAC Photo/Archive Submission</h2>
      <p><strong>From:</strong> ${escapeHtml(record.name)} (${escapeHtml(record.email)})</p>
      ${record.era ? `<p><strong>Era:</strong> ${escapeHtml(record.era)}</p>` : ''}
      ${record.description ? `<p><strong>Description:</strong><br>${escapeHtml(record.description)}</p>` : ''}
    `,
  };
}

// A request to own/co-own one or more Master Due-Diligence Matrix sections
// via My Section (bbpac/organization/my-section.html) -- NOT auto-granted.
// Any opted-in approver (set via set-approver-optin) reviews it from the
// Review Queue, which calls approve-section-signup to actually create the
// member row and grant the sections.
function formatBbpacSectionSignupRequest(record: Record<string, any>) {
  const sections = Array.isArray(record.requested_sections) ? record.requested_sections.join(', ') : record.requested_sections;
  return {
    subject: `New Section Signup Request — ${record.full_name} (Section ${sections})`,
    html: `
      <h2>New Bongo Beach Matrix Section Signup Request</h2>
      <p><strong>From:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.email)})</p>
      <p><strong>Requested section(s):</strong> ${escapeHtml(String(sections))}</p>
      ${record.message ? `<p><strong>Message:</strong><br>${escapeHtml(record.message)}</p>` : ''}
      <p style="color:#5b6b7a;font-size:0.85rem;">Any opted-in approver can review this from the <a href="https://selassiefest.com/bbpac/organization/review-queue.html">Review Queue</a>. Not auto-granted.</p>
    `,
  };
}

// New /clrwf/quote submission. The DB trigger has already dropped this
// straight into the shop's Intake column (see clrwf_quote_request_to_job in
// supabase/schema.sql) by the time this email goes out -- this is a
// heads-up, not an approval step, so the copy says so explicitly.
function formatClrwfQuoteRequest(record: Record<string, any>) {
  const categoryLabel: Record<string, string> = {
    residential: 'Residential',
    commercial: 'Commercial',
    'custom-jerk-pit': 'Custom — Jerk Pit',
    'custom-other': 'Custom — Other',
  };
  const photoCount = Array.isArray(record.photo_paths) ? record.photo_paths.length : 0;
  return {
    subject: `New CLRWF Quote Request — ${record.full_name} (${categoryLabel[record.category] || record.category})`,
    html: `
      <h2>New Quote Request — C. L. Rainford Welding &amp; Fabrication</h2>
      <p><strong>From:</strong> ${escapeHtml(record.full_name)} (${escapeHtml(record.email)}${record.phone ? ', ' + escapeHtml(record.phone) : ''})</p>
      <p><strong>Job type:</strong> ${escapeHtml(categoryLabel[record.category] || record.category)}</p>
      ${record.description ? `<p><strong>Description:</strong><br>${escapeHtml(record.description)}</p>` : ''}
      ${record.pit_configuration ? `<p><strong>Pit configuration:</strong><br>${escapeHtml(JSON.stringify(record.pit_configuration))}</p>` : ''}
      ${record.budget_range ? `<p><strong>Budget range:</strong> ${escapeHtml(record.budget_range)}</p>` : ''}
      ${record.timeline ? `<p><strong>Timeline:</strong> ${escapeHtml(record.timeline)}</p>` : ''}
      ${photoCount ? `<p><strong>Photos:</strong> ${photoCount} attached below.</p>` : ''}
      <p style="color:#5b6b7a;font-size:0.85rem;">Already added to the shop board's Intake column automatically — no approval step needed.</p>
    `,
  };
}

// Commercial "Request a Maintenance Agreement" -- a separate lead type
// from clrwf_quote_requests (see schema.sql), so it's flagged distinctly
// here too rather than reusing the quote-request formatter.
function formatClrwfMaintenanceAgreementRequest(record: Record<string, any>) {
  return {
    subject: `New Maintenance Agreement Inquiry — ${record.business_name}`,
    html: `
      <h2>New Maintenance Agreement Inquiry — C. L. Rainford Welding &amp; Fabrication</h2>
      <p><strong>Business:</strong> ${escapeHtml(record.business_name)}</p>
      <p><strong>Contact:</strong> ${escapeHtml(record.contact_name)} (${escapeHtml(record.email)}${record.phone ? ', ' + escapeHtml(record.phone) : ''})</p>
      ${record.property_description ? `<p><strong>Property/equipment:</strong><br>${escapeHtml(record.property_description)}</p>` : ''}
      ${record.service_needs ? `<p><strong>Service needs:</strong><br>${escapeHtml(record.service_needs)}</p>` : ''}
      ${record.message ? `<p><strong>Message:</strong><br>${escapeHtml(record.message)}</p>` : ''}
      <p style="color:#5b6b7a;font-size:0.85rem;">Recurring commercial lead — track separately from one-off quote requests.</p>
    `,
  };
}

type Notification = {
  to: (record: Record<string, any>) => string | null | undefined;
  format: (record: Record<string, any>) => { subject: string; html: string };
  // Optional per-notification sender override -- defaults to FROM below.
  // Used by dh101_signups: Dancehall 101 is its own event brand (sibling to
  // SelassieFest under Ras Tafari Inc / TRC Events, not a sub-feature of
  // it), so its emails must not carry the "SelassieFest" display name even
  // though they still send from the same verified selassiefest.com domain.
  from?: (record: Record<string, any>) => string;
  // Optional reply-to override -- defaults to REPLY_TO below. Used by the
  // lease e-signature notifications so replies land at
  // mkepropertymanager@gmail.com instead of SelassieFest's own inbox.
  replyTo?: (record: Record<string, any>) => string;
  // Optional file attachments (Resend's {filename, content: base64} shape).
  // Only security_guard_contracts uses this so far, to attach the signed PDF
  // pulled back out of its private Storage bucket.
  attachments?: (record: Record<string, any>) => Promise<{ filename: string; content: string }[]>;
};

type TableConfig = {
  notifications: Notification[];
};

const TABLE_CONFIG: Record<string, TableConfig> = {
  marketplace_preorders: { notifications: [{ to: () => NOTIFY_TO, format: formatMarketplacePreorder }] },
  volunteer_signups: { notifications: [{ to: () => NOTIFY_TO, format: formatVolunteerSignup }] },
  sponsor_inquiries: { notifications: [{ to: () => NOTIFY_TO, format: formatSponsorInquiry }] },
  camp_registrations: { notifications: [{ to: () => NOTIFY_TO, format: formatCampRegistration }] },
  vendor_applications: { notifications: [{ to: () => NOTIFY_TO, format: formatVendorApplication }] },
  plates_for_purpose_responses: {
    notifications: [
      { to: () => 'stephen@selassiefest.com', format: formatPlatesForPurposeResponse },
      {
        to: (record) => (record.decision === 'yes' ? record.email : null),
        format: formatPlatesForPurposeConfirmation,
        attachments: async (record) => {
          const badgePath = await fetchRestaurantBadgePath(record.restaurant_slug);
          if (!badgePath) return [];
          return [
            {
              filename: `Plates-for-Purpose-Partner-Badge-${record.restaurant_slug}.jpg`,
              content: await fetchStorageObjectAsBase64('plates-for-purpose-badges', badgePath),
            },
          ];
        },
      },
    ],
  },
  stripe_donations: { notifications: [{ to: () => NOTIFY_TO, format: formatDonation }] },
  newsletter_subscribers: { notifications: [{ to: (record) => record.email, format: formatNewsletterConfirmation }] },
  game_submissions: {
    notifications: [
      { to: () => NOTIFY_TO, format: formatGameSubmission },
      // Only sent if the submitter gave an email -- it's optional on this form.
      { to: (record) => record.submitter_email, format: formatGameSubmissionConfirmation },
    ],
  },
  dh101_signups: {
    notifications: [
      { to: () => NOTIFY_TO, format: formatDh101Signup },
      {
        to: (record) => record.edu_email,
        format: formatDh101VerificationEmail,
        from: () => 'Dancehall 101 <hello@selassiefest.com>',
      },
    ],
  },
  security_guard_contracts: {
    notifications: [
      {
        to: () => 'stephen@selassiefest.com',
        format: formatSecurityGuardContract,
        attachments: async (record) => [
          {
            filename: `SelassieFest-Security-Guard-Contract-${record.vendor_company_name || record.id}.pdf`,
            content: await fetchStorageObjectAsBase64('security-guard-contracts', record.pdf_path),
          },
        ],
      },
    ],
  },
  event_notify_signups: {
    notifications: [
      { to: () => NOTIFY_TO, format: formatEventNotifySignup },
      {
        to: (record) => record.email,
        format: formatEventNotifyConfirmation,
        from: (record) =>
          record.brand === 'trc' ? 'TRC Events <hello@selassiefest.com>' : 'SelassieFest <hello@selassiefest.com>',
      },
    ],
  },
  lease_signing_requests: {
    notifications: [
      {
        to: (record) => record.tenant_email,
        format: formatLeaseSigningRequest,
        from: () => LEASE_SIGN_FROM,
        replyTo: () => LEASE_MANAGER_EMAIL,
      },
      {
        to: () => LEASE_MANAGER_EMAIL,
        format: formatLeaseSigningRequestStaffCopy,
        from: () => LEASE_SIGN_FROM,
        replyTo: () => LEASE_MANAGER_EMAIL,
        attachments: async (record) => {
          if (!record.draft_pdf_path) return [];
          return [
            {
              filename: `Lease-Sent-${record.tenant_name || record.id}.pdf`,
              content: await fetchStorageObjectAsBase64('lease-draft-pdfs', record.draft_pdf_path),
            },
          ];
        },
      },
    ],
  },
  bbpac_meeting_notify: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacMeetingNotify }] },
  bbpac_volunteer_signups: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacVolunteerSignup }] },
  bbpac_membership_signups: {
    notifications: [
      { to: () => BBPAC_NOTIFY_TO, format: formatBbpacMembershipSignup },
      {
        to: (record) => record.email,
        format: formatBbpacMembershipConfirmation,
        from: () => 'Bongo Beach PAC <hello@selassiefest.com>',
      },
    ],
  },
  bbpac_sponsor_inquiries: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacSponsorInquiry }] },
  bbpac_vendor_applications: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacVendorApplication }] },
  bbpac_contact_messages: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacContactMessage }] },
  bbpac_photo_submissions: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacPhotoSubmission }] },
  bbpac_formation_section_signup_requests: { notifications: [{ to: () => BBPAC_NOTIFY_TO, format: formatBbpacSectionSignupRequest }] },
  clrwf_quote_requests: {
    notifications: [
      {
        to: () => CLRWF_NOTIFY_TO,
        format: formatClrwfQuoteRequest,
        from: () => 'C. L. Rainford Welding & Fabrication <hello@selassiefest.com>',
        // clrwf-job-photos is a private bucket (see schema.sql) -- base64
        // attachments, same pattern as security_guard_contracts/lease PDFs,
        // rather than a public link that would 403.
        attachments: async (record) => {
          const paths: string[] = Array.isArray(record.photo_paths) ? record.photo_paths : [];
          return Promise.all(paths.map(async (p, i) => ({
            filename: `CLRWF-Quote-Photo-${i + 1}.${p.split('.').pop() || 'jpg'}`,
            content: await fetchStorageObjectAsBase64('clrwf-job-photos', p),
          })));
        },
      },
    ],
  },
  clrwf_maintenance_agreement_requests: {
    notifications: [
      {
        to: () => CLRWF_NOTIFY_TO,
        format: formatClrwfMaintenanceAgreementRequest,
        from: () => 'C. L. Rainford Welding & Fabrication <hello@selassiefest.com>',
      },
    ],
  },
  lease_signatures: {
    notifications: [
      {
        to: () => LEASE_MANAGER_EMAIL,
        format: formatLeaseSignatureStaff,
        from: () => LEASE_SIGN_FROM,
        replyTo: () => LEASE_MANAGER_EMAIL,
        attachments: async (record) => [
          {
            filename: `Signed-Lease-${record.tenant_name || record.id}.pdf`,
            content: await fetchStorageObjectAsBase64('lease-signed-pdfs', record.pdf_path),
          },
        ],
      },
      {
        to: (record) => record.tenant_email,
        format: formatLeaseSignatureTenantCopy,
        from: () => LEASE_SIGN_FROM,
        replyTo: () => LEASE_MANAGER_EMAIL,
        attachments: async (record) => [
          {
            filename: `Signed-Lease-${record.tenant_name || record.id}.pdf`,
            content: await fetchStorageObjectAsBase64('lease-signed-pdfs', record.pdf_path),
          },
        ],
      },
    ],
  },
};

Deno.serve(async (req: Request) => {
  if (req.headers.get('x-webhook-secret') !== WEBHOOK_SECRET) {
    return new Response(JSON.stringify({ error: 'unauthorized' }), { status: 401 });
  }

  try {
    const payload = await req.json();
    const table: string = payload.table;
    const record = payload.record;

    const config = TABLE_CONFIG[table];
    if (!config) {
      return new Response(JSON.stringify({ skipped: true, reason: `no formatter for table ${table}` }), { status: 200 });
    }

    // Best-effort — a Resend Audience hiccup shouldn't block the
    // confirmation email itself.
    if (table === 'newsletter_subscribers') {
      try {
        await fetch(`https://api.resend.com/audiences/${NEWSLETTER_AUDIENCE_ID}/contacts`, {
          method: 'POST',
          headers: {
            Authorization: `Bearer ${RESEND_API_KEY}`,
            'Content-Type': 'application/json',
          },
          body: JSON.stringify({ email: record.email, unsubscribed: false }),
        });
      } catch (e) {
        console.error('Resend audience sync failed:', e);
      }
    }

    // Dispatched concurrently, not sequentially -- the trigger's net.http_post
    // call into this function has a hard 5s timeout (pg_net default), and two
    // sequential Resend round-trips (each individually well under 5s) can add
    // up past that ceiling on tables with 2+ notifications, silently dropping
    // the whole webhook call (confirmed: bbpac_membership_signups' 2-email
    // config reliably timed out sequential, completed fine parallel).
    const results = await Promise.all(config.notifications.map(async (notification) => {
      const to = notification.to(record);
      if (!to) {
        return { skipped: true, reason: 'no recipient email on record' };
      }

      const { subject, html } = notification.format(record);
      const from = notification.from ? notification.from(record) : FROM;
      const replyTo = notification.replyTo ? notification.replyTo(record) : REPLY_TO;
      const attachments = notification.attachments ? await notification.attachments(record) : undefined;

      const resendRes = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${RESEND_API_KEY}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({ from, to, reply_to: replyTo, subject, html, ...(attachments ? { attachments } : {}) }),
      });

      if (!resendRes.ok) {
        const errText = await resendRes.text();
        console.error('Resend send failed:', resendRes.status, errText);
        return { error: errText };
      }
      return { sent: true, to };
    }));

    const anySent = results.some((r) => r.sent);
    const anyError = results.some((r) => r.error);
    return new Response(JSON.stringify({ results }), { status: anySent || !anyError ? 200 : 502 });
  } catch (e) {
    console.error('notify-submission error:', e);
    return new Response(JSON.stringify({ error: String(e) }), { status: 500 });
  }
});

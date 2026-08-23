// SelassieFest shared Supabase client. Loaded sitewide via a plain <script> tag
// (no build step), so the SDK is pulled in with a dynamic import() of the CDN
// ESM build. See supabase/schema.sql for the tables this talks to.
//
// Fill in these two values from Project Settings -> API in the Supabase
// dashboard. The anon key is meant to be public — it only grants what the
// Row Level Security policies in schema.sql allow (insert-only, no read-back).
const SUPABASE_URL = 'https://xdjbgcqaynnzykrglgnf.supabase.co';
const SUPABASE_ANON_KEY = 'sb_publishable_1B4Musk5YF23XHb_BEOiTA_w1DGM5P4';

window.sfSupabaseReady = (async () => {
  const { createClient } = await import('https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2/+esm');
  return createClient(SUPABASE_URL, SUPABASE_ANON_KEY);
})();

window.sfSupabase = {
  async subscribeNewsletter(email, source = null) {
    const client = await window.sfSupabaseReady;
    // Plain insert, not upsert: upsert asks PostgREST to select the row back
    // to report whether it inserted or ignored a duplicate, which needs a
    // SELECT policy we intentionally don't grant (write-only table). A
    // duplicate email just throws a unique-violation (code 23505), which
    // callers already treat as a friendly "you're already subscribed".
    const { error } = await client.from('newsletter_subscribers').insert({ email, source });
    if (error) throw error;
  },

  async submitAnansiStory({ name, email, storyTitle, storyText }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('anansi_story_submissions').insert({
      name,
      email,
      story_title: storyTitle,
      story_text: storyText,
    });
    if (error) throw error;
  },

  async submitVolunteerSignup({ fullName, email, phone, age, roleChoice, shiftPreference, tshirtSize, emergencyContact, accommodations, referralSource, waiverAccepted }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('volunteer_signups').insert({
      full_name: fullName,
      email,
      phone,
      age,
      role_choice: roleChoice,
      shift_preference: shiftPreference,
      tshirt_size: tshirtSize,
      emergency_contact: emergencyContact,
      accommodations,
      referral_source: referralSource,
      waiver_accepted: waiverAccepted,
    });
    if (error) throw error;
  },

  async submitSponsorInquiry({ sourcePage, email, fields }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('sponsor_inquiries').insert({
      source_page: sourcePage,
      email,
      fields,
    });
    if (error) throw error;
  },

  async submitCampRegistration({ camperName, guardianName, guardianEmail, guardianPhone, registrationData }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('camp_registrations').insert({
      camper_name: camperName,
      guardian_name: guardianName,
      guardian_email: guardianEmail,
      guardian_phone: guardianPhone,
      registration_data: registrationData,
    });
    if (error) throw error;
  },

  // Resizes/re-encodes an image client-side (long edge capped at 1600px,
  // JPEG q=0.82) before upload. Keeps the free Storage tier's 1GB budget
  // stretching across many more submitted photos than raw phone photos
  // would allow — a single uncompressed phone photo can be 10-20MB.
  async _compressImage(file) {
    const bitmap = await createImageBitmap(file);
    const maxEdge = 1600;
    const scale = Math.min(1, maxEdge / Math.max(bitmap.width, bitmap.height));
    const canvas = document.createElement('canvas');
    canvas.width = Math.round(bitmap.width * scale);
    canvas.height = Math.round(bitmap.height * scale);
    const ctx = canvas.getContext('2d');
    ctx.drawImage(bitmap, 0, 0, canvas.width, canvas.height);
    const blob = await new Promise((resolve) => canvas.toBlob(resolve, 'image/jpeg', 0.82));
    return blob || file;
  },

  // Uploads an optional photo + optional video (max 50MB, matching both
  // Supabase's free-tier per-file cap and the bucket's own configured
  // limit) to the game-submissions Storage bucket, then records the
  // submission. Videos are a TEMPORARY holding spot -- staff move approved
  // ones to YouTube by hand and delete the Storage copy (see schema.sql).
  async submitGameStory({ gameSlug, gameName, submitterName, submitterEmail, storyText, photoFile, videoFile }) {
    const MAX_BYTES = 50 * 1024 * 1024;
    if (videoFile && videoFile.size > MAX_BYTES) {
      throw new Error('Video is too large (50MB max). Please trim it and try again.');
    }

    const client = await window.sfSupabaseReady;
    const stamp = Date.now() + '-' + Math.random().toString(36).slice(2, 8);

    let photoPath = null;
    if (photoFile) {
      const compressed = await this._compressImage(photoFile);
      photoPath = `${gameSlug}/${stamp}-photo.jpg`;
      const { error } = await client.storage.from('game-submissions').upload(photoPath, compressed, {
        contentType: 'image/jpeg',
      });
      if (error) throw error;
    }

    let videoPath = null;
    if (videoFile) {
      const ext = (videoFile.name.split('.').pop() || 'mp4').toLowerCase();
      videoPath = `${gameSlug}/${stamp}-video.${ext}`;
      const { error } = await client.storage.from('game-submissions').upload(videoPath, videoFile, {
        contentType: videoFile.type || 'video/mp4',
      });
      if (error) throw error;
    }

    const { error } = await client.from('game_submissions').insert({
      game_slug: gameSlug,
      game_name: gameName,
      submitter_name: submitterName,
      submitter_email: submitterEmail || null,
      story_text: storyText || null,
      photo_path: photoPath,
      video_path: videoPath,
    });
    if (error) throw error;
  },

  // Uploads an optional logo + optional product photos (max 5, matching the
  // vendor package's "3-5 images" request) to the vendor-applications
  // Storage bucket, then records the application. Photos are compressed
  // client-side via _compressImage, same as submitGameStory above.
  async submitVendorApplication({ businessName, contactEmail, productDescription, webpageHighlight, marketingPlan, preferredSpace, logoFile, photoFiles }) {
    const client = await window.sfSupabaseReady;
    const stamp = Date.now() + '-' + Math.random().toString(36).slice(2, 8);

    let logoPath = null;
    if (logoFile) {
      const compressed = await this._compressImage(logoFile);
      logoPath = `${stamp}-logo.jpg`;
      const { error } = await client.storage.from('vendor-applications').upload(logoPath, compressed, {
        contentType: 'image/jpeg',
      });
      if (error) throw error;
    }

    const photoPaths = [];
    for (let i = 0; i < (photoFiles || []).length; i++) {
      const compressed = await this._compressImage(photoFiles[i]);
      const path = `${stamp}-photo-${i + 1}.jpg`;
      const { error } = await client.storage.from('vendor-applications').upload(path, compressed, {
        contentType: 'image/jpeg',
      });
      if (error) throw error;
      photoPaths.push(path);
    }

    const { error } = await client.from('vendor_applications').insert({
      business_name: businessName,
      contact_email: contactEmail,
      product_description: productDescription,
      webpage_highlight: webpageHighlight || null,
      marketing_plan: marketingPlan,
      preferred_space: preferredSpace || null,
      logo_path: logoPath,
      photo_paths: photoPaths,
    });
    if (error) throw error;
  },

  // Uploads the client-generated signed contract PDF to the private
  // security-guard-contracts bucket, then records the submission. The
  // notify-submission Edge Function picks the PDF back up (service role,
  // bypasses this bucket's no-public-read policy) and emails it to Stephen.
  async submitSecurityGuardContract({ vendorCompanyName, vendorAddress, vendorContact, guardNames, signerName, signerTitle, pdfBlob }) {
    const client = await window.sfSupabaseReady;
    const stamp = Date.now() + '-' + Math.random().toString(36).slice(2, 8);
    const pdfPath = `${stamp}.pdf`;

    const { error: uploadError } = await client.storage.from('security-guard-contracts').upload(pdfPath, pdfBlob, {
      contentType: 'application/pdf',
    });
    if (uploadError) throw uploadError;

    const { error } = await client.from('security_guard_contracts').insert({
      vendor_company_name: vendorCompanyName,
      vendor_address: vendorAddress || null,
      vendor_contact: vendorContact || null,
      guard_names: guardNames || null,
      signer_name: signerName,
      signer_title: signerTitle || null,
      pdf_path: pdfPath,
    });
    if (error) throw error;
  },

  // Reads from plates_for_purpose_restaurants_public (a view, not the base
  // table) -- the ask page passes the ?r=<slug> from its own URL. Returns
  // null if the slug doesn't match any restaurant (bad/old QR code), which
  // the calling page treats as "show a fallback, don't crash".
  async fetchPlatesForPurposeRestaurant(slug) {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client
      .from('plates_for_purpose_restaurants_public')
      .select('slug, business_name, address, donation_ask, target_ask_value, suggested_donation, logo_path, offer_choices, offer_note')
      .eq('slug', slug)
      .maybeSingle();
    if (error) throw error;
    return data;
  },

  // Aggregate-only count (see plates_for_purpose_confirmed_count in
  // schema.sql) -- never exposes which specific restaurants have confirmed,
  // only how many. Returns 0 on any error so a hiccup here just hides the
  // social-proof line rather than breaking the page.
  async fetchPlatesForPurposeConfirmedCount() {
    try {
      const client = await window.sfSupabaseReady;
      const { data, error } = await client
        .from('plates_for_purpose_confirmed_count')
        .select('confirmed_count')
        .maybeSingle();
      if (error) throw error;
      return data ? data.confirmed_count : 0;
    } catch (err) {
      console.error('Failed to fetch confirmed count:', err);
      return 0;
    }
  },

  async submitPlatesForPurposeResponse({
    restaurantSlug,
    businessName,
    decision,
    offerDetails,
    respondentName,
    respondentTitle,
    email,
    contactInfo,
    message,
  }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('plates_for_purpose_responses').insert({
      restaurant_slug: restaurantSlug,
      business_name: businessName,
      decision,
      offer_details: offerDetails || null,
      respondent_name: respondentName || null,
      respondent_title: respondentTitle || null,
      email: email || null,
      contact_info: contactInfo || null,
      message: message || null,
    });
    if (error) throw error;
  },

  // Reads from game_submissions_public (a view, not the base table) --
  // pre-filtered to status='approved' and missing submitter_email entirely,
  // so this is safe to call from any page without further filtering.
  async fetchApprovedGameSubmissions(gameSlug, limit = 12) {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client
      .from('game_submissions_public')
      .select('id, submitter_name, story_text, photo_path, video_path, created_at')
      .eq('game_slug', gameSlug)
      .order('created_at', { ascending: false })
      .limit(limit);
    if (error) throw error;
    return data || [];
  },

  // 2nd Chance Housing lease e-signature bridge (see supabase/schema.sql's
  // "lease e-signature bridge" section) -- unrelated to SelassieFest itself,
  // just reusing this already-configured Supabase project. get_lease_signing_request
  // is a security-definer RPC, not a table select, so it's the only way this
  // (public, unauthenticated) page can ever read a single lease record --
  // it returns null for an unknown id or one already marked completed.
  async fetchLeaseSigningRequest(id) {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client.rpc('get_lease_signing_request', { request_id: id });
    if (error) throw error;
    return (data && data[0]) || null;
  },

  async submitLeaseSignature({ requestId, tenantName, tenantEmail, unitLabel, signedData, signatureTypedName, pdfBlob }) {
    const client = await window.sfSupabaseReady;
    const stamp = Date.now() + '-' + Math.random().toString(36).slice(2, 8);
    const pdfPath = `${stamp}.pdf`;

    const { error: uploadError } = await client.storage.from('lease-signed-pdfs').upload(pdfPath, pdfBlob, {
      contentType: 'application/pdf',
    });
    if (uploadError) throw uploadError;

    const { error } = await client.from('lease_signatures').insert({
      request_id: requestId,
      tenant_name: tenantName,
      tenant_email: tenantEmail,
      unit_label: unitLabel || null,
      signed_data: signedData,
      signature_typed_name: signatureTypedName,
      pdf_path: pdfPath,
    });
    if (error) throw error;
  },

  // 63rd Street Bongo Beach Park Advisory Council (bbpac/) -- a Ras Tafari
  // Inc. community initiative, separate from the SelassieFest festival itself
  // but sharing this same Supabase project. All six tables below are
  // write-only inserts, same convention as everything above.
  async bbpacMeetingNotify(email) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_meeting_notify').insert({ email });
    if (error) throw error;
  },

  async bbpacVolunteerSignup({ fullName, email, phone, interestArea, availability }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_volunteer_signups').insert({
      full_name: fullName,
      email,
      phone: phone || null,
      interest_area: interestArea || null,
      availability: availability || null,
    });
    if (error) throw error;
  },

  async bbpacMembershipSignup({ fullName, email, membershipLevel, message }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_membership_signups').insert({
      full_name: fullName,
      email,
      membership_level: membershipLevel || null,
      message: message || null,
    });
    if (error) throw error;
  },

  async bbpacSponsorInquiry({ businessName, contactName, email, message }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_sponsor_inquiries').insert({
      business_name: businessName,
      contact_name: contactName || null,
      email,
      message: message || null,
    });
    if (error) throw error;
  },

  async bbpacVendorApplication({ businessName, contactName, email, productDescription, preferredEvent }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_vendor_applications').insert({
      business_name: businessName,
      contact_name: contactName || null,
      email,
      product_description: productDescription || null,
      preferred_event: preferredEvent || null,
    });
    if (error) throw error;
  },

  async bbpacContactMessage({ name, email, topic, message }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_contact_messages').insert({
      name,
      email,
      topic: topic || null,
      message,
    });
    if (error) throw error;
  },

  async bbpacPhotoSubmission({ name, email, description, era }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('bbpac_photo_submissions').insert({
      name,
      email,
      description: description || null,
      era: era || null,
    });
    if (error) throw error;
  },

  // C. L. Rainford Welding & Fabrication (clrwf/) -- unrelated business,
  // same shared-project pattern as bbpac/ above. Photos go to the private
  // clrwf-job-photos bucket (see schema.sql) -- anon can insert but never
  // read back, same as every other write-only form here. The DB trigger on
  // clrwf_quote_requests auto-creates the client + job row in Intake; no
  // approval step, unlike bbpac's section-signup flow.
  async submitClrwfQuoteRequest({ fullName, email, phone, category, description, budgetRange, timeline, photoFiles, pitConfiguration }) {
    const client = await window.sfSupabaseReady;
    const stamp = Date.now() + '-' + Math.random().toString(36).slice(2, 8);

    const photoPaths = [];
    for (let i = 0; i < (photoFiles || []).length; i++) {
      const compressed = await this._compressImage(photoFiles[i]);
      const path = `${stamp}-photo-${i + 1}.jpg`;
      const { error } = await client.storage.from('clrwf-job-photos').upload(path, compressed, {
        contentType: 'image/jpeg',
      });
      if (error) throw error;
      photoPaths.push(path);
    }

    const { error } = await client.from('clrwf_quote_requests').insert({
      full_name: fullName,
      email,
      phone: phone || null,
      category,
      description: description || null,
      budget_range: budgetRange || null,
      timeline: timeline || null,
      photo_paths: photoPaths,
      pit_configuration: pitConfiguration || null,
    });
    if (error) throw error;
  },

  // Distinct from submitClrwfQuoteRequest -- see schema.sql's
  // clrwf_maintenance_agreement_requests comment for why recurring
  // commercial leads are tracked separately from one-off quotes.
  async submitClrwfMaintenanceAgreementRequest({ businessName, contactName, email, phone, propertyDescription, serviceNeeds, message }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('clrwf_maintenance_agreement_requests').insert({
      business_name: businessName,
      contact_name: contactName || null,
      email,
      phone: phone || null,
      property_description: propertyDescription || null,
      service_needs: serviceNeeds || null,
      message: message || null,
    });
    if (error) throw error;
  },

  async submitClrwfContactMessage({ name, email, message }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('clrwf_contact_messages').insert({ name, email, message });
    if (error) throw error;
  },
};

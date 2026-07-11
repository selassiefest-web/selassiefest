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

  async submitRaffleEntry({ buyerName, buyerEmail, ticketQty, totalAmount, paymentMethod, transactionId, prizeId, prizeName }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('raffle_entries').insert({
      buyer_name: buyerName,
      buyer_email: buyerEmail,
      ticket_qty: ticketQty,
      total_amount: totalAmount,
      payment_method: paymentMethod,
      transaction_id: transactionId,
      prize_id: prizeId,
      prize_name: prizeName,
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
};

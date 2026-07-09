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
};

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
  async subscribeNewsletter(email) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('newsletter_subscribers').insert({ email });
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

  async submitMarketplacePreorder({ customerName, customerEmail, customerPhone, pickupTime, guestCount, items, totalAmount }) {
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('marketplace_preorders').insert({
      customer_name: customerName,
      customer_email: customerEmail,
      customer_phone: customerPhone,
      pickup_time: pickupTime,
      guest_count: guestCount,
      items,
      total_amount: totalAmount,
    });
    if (error) throw error;
  },
};

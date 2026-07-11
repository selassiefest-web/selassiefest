// Shared data layer for the Dancehall 101 pages. Built on the site's
// existing window.sfSupabaseReady client (assets/js/supabase-client.js) --
// same Supabase project, just talking to the dh101_* tables/RPCs, which
// carry their own RLS independent of every other table on the site.
window.DH101 = (function () {
  function escapeHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function applyBranding(school) {
    if (!school) return;
    document.documentElement.style.setProperty('--school-primary', school.color_primary || '#C8102E');
    document.documentElement.style.setProperty('--school-secondary', school.color_secondary || '#F2B705');
  }

  // Real cleared logo -> an <img>. No cleared logo -> a styled text
  // wordmark using the school's own short code/initials and colors, NOT a
  // generic placeholder icon -- see dh101_schools.logo_url comment in
  // schema.sql for why most schools don't have a cleared image yet.
  function wordmarkHtml(school, sizeClass) {
    if (!school) return '';
    if (school.logo_url) {
      // Some official logo files are white-on-transparent (meant for a dark
      // header on the school's own site) -- logo_bg records which backing
      // color actually makes that specific file visible, per school.
      var bgClass = school.logo_bg === 'dark' ? 'dh-wordmark-img-dark' : '';
      return '<img class="dh-wordmark-img ' + bgClass + ' ' + sizeClass + '" src="' + school.logo_url + '" alt="' + escapeHtml(school.name) + ' logo" loading="lazy" />';
    }
    var initials = (school.short_code || school.name.slice(0, 3)).slice(0, 6);
    return '<div class="dh-wordmark-badge ' + sizeClass + '"><span>' + escapeHtml(initials) + '</span></div>';
  }

  async function fetchActiveSchools() {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client
      .from('dh101_schools')
      .select('id, slug, name, short_code, logo_url, logo_bg, mascot, color_primary, color_secondary, default_campaign_code')
      .order('name', { ascending: true });
    if (error) throw error;
    return data || [];
  }

  async function fetchSchoolBySlug(slug) {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client
      .from('dh101_schools')
      .select('id, slug, name, short_code, logo_url, logo_bg, mascot, color_primary, color_secondary, default_campaign_code')
      .eq('slug', slug)
      .maybeSingle();
    if (error) throw error;
    return data;
  }

  // honeypot: if the hidden field got filled in (a bot did it, no human
  // sees it), silently pretend success without ever hitting the network --
  // cheap, zero-cost bot filter, no server round trip needed.
  async function submitSignup({ school, fullName, eduEmail, dob, studentSegment, referralCode, honeypot }) {
    if (honeypot) {
      return { skipped: true };
    }
    const client = await window.sfSupabaseReady;
    const { error } = await client.from('dh101_signups').insert({
      school_id: school.id,
      full_name: fullName,
      edu_email: eduEmail,
      dob,
      student_segment: studentSegment,
      referral_code: referralCode || null,
      campaign_code: school.default_campaign_code || null,
    });
    if (error) throw error;
    return { skipped: false };
  }

  async function verifyAndGetTicket(token) {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client.rpc('dh101_verify_and_get_ticket', { p_token: token });
    if (error) throw error;
    return (data && data[0]) || null;
  }

  async function fetchAmbassadorLeaderboard() {
    const client = await window.sfSupabaseReady;
    const { data, error } = await client
      .from('dh101_ambassador_leaderboard')
      .select('*')
      .order('signup_count', { ascending: false });
    if (error) throw error;
    return data || [];
  }

  return {
    applyBranding,
    wordmarkHtml,
    fetchActiveSchools,
    fetchSchoolBySlug,
    submitSignup,
    verifyAndGetTicket,
    fetchAmbassadorLeaderboard,
  };
})();

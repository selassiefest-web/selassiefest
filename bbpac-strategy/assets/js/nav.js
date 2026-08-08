/* ==========================================================================
   nav.js — single source of truth for site-wide navigation.
   ==========================================================================
   HOW THIS WORKS (read this if you are maintaining the site):

   1. Every HTML page has an empty <div id="site-nav"></div> near the top of
      <body>, and sets one attribute on the <html> tag:

          <html data-root="./">        <!-- for pages at the site root -->
          <html data-root="../">       <!-- for pages one folder deep,
                                             e.g. /departments/law.html -->

      data-root tells this script how many "../" to prepend to every link
      so navigation works no matter how deep the current page is.

   2. The header is intentionally compact: a "Back to Command Center" link,
      the disclaimer banner, the site title, and the search box. There is no
      full page-by-page link list in the header — index.html's card grid is
      the page directory, and the search box covers everything else. To add
      a new page, just give it the standard shell (data-root, data-page,
      <div id="site-nav">, <footer id="site-footer">, the nav.js/search.js
      script tags) and add a card for it on index.html.
   ========================================================================== */

(function () {
  var ROOT = document.documentElement.getAttribute('data-root') || './';

  function buildHeader() {
    // Pages that need maximum vertical space for their own content (e.g. the
    // interactive roadmap) can opt out of the full header/banner by setting
    // <html data-minimal-nav="true">. window.SITE_ROOT is still set below so
    // search.js and page-relative links keep working.
    if (document.documentElement.getAttribute('data-minimal-nav') === 'true') {
      return;
    }

    var html =
      '<div class="compact-topbar" style="padding:10px 20px 0;"><a href="' + ROOT + 'roadmap.html">&larr; Back to Command Center</a></div>' +
      '<div class="top-banner">Internal campaign planning system — <strong>not an official Chicago Park District document</strong>. See <a href="' + ROOT + 'sources.html" style="color:#fff;text-decoration:underline;">Sources &amp; Methodology</a> before external distribution.</div>' +
      '<header class="site-header">' +
        '<div class="site-header-inner">' +
          '<a class="site-title" href="' + ROOT + 'index.html">' +
            '<span class="kicker">Presentation Architecture</span>' +
            'Bongo Beach PAC Recognition Campaign' +
          '</a>' +
          '<div class="nav-search">' +
            '<input type="search" id="site-search-input" placeholder="Search the whole system (e.g. &quot;Lane Beach&quot;, &quot;FAQ privatization&quot;, &quot;General Superintendent&quot;)" autocomplete="off">' +
            '<div id="search-results"></div>' +
          '</div>' +
        '</div>' +
      '</header>';

    document.getElementById('site-nav').innerHTML = html;
  }

  function buildFooter() {
    var el = document.getElementById('site-footer');
    if (!el) return;
    el.innerHTML =
      '<div class="site-footer-inner">' +
        '<div>63rd Street Bongo Beach Park Advisory Council — Recognition Campaign<br>' +
        'Presentation architecture generated for internal use. Verify every factual claim against primary CPD records before it is shown to an outside decision-maker. See <a href="' + ROOT + 'sources.html">Sources &amp; Methodology</a>.</div>' +
        '<div><a href="' + ROOT + 'index.html">System Overview</a> &nbsp;·&nbsp; <a href="' + ROOT + 'matrix.html">Routing Matrix</a> &nbsp;·&nbsp; <a href="' + ROOT + 'evidence-status.html">Evidence Status</a></div>' +
      '</div>';
  }

  buildHeader();
  buildFooter();

  // Expose ROOT globally so search.js and other scripts can resolve links.
  window.SITE_ROOT = ROOT;
})();

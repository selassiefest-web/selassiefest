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

   2. This script also sets which nav link is "active" by comparing the
      current page's file name (in <html data-page="...">) against the
      NAV_LINKS list below.

   3. TO ADD A NEW PAGE: add one object to the relevant group in NAV_LINKS
      below (file, label), then on the new HTML page itself set
      data-root and data-page and include:
        <div id="site-nav"></div>
        <script src="[root]assets/js/nav.js"></script>
      That is the only place page links need to be registered.
   ========================================================================== */

(function () {
  var ROOT = document.documentElement.getAttribute('data-root') || './';
  var CURRENT = document.documentElement.getAttribute('data-page') || '';

  var NAV_LINKS = [
    {
      group: 'Start',
      items: [
        { file: 'index.html', label: 'System Overview' },
        { file: 'roadmap.html', label: 'Start → Yes Roadmap' },
        { file: 'matrix.html', label: 'Stakeholder & Authority Matrix' },
        { file: 'precedents.html', label: 'Precedent Library' },
        { file: 'evidence-status.html', label: 'Evidence & Verification Status' },
        { file: 'sources.html', label: 'Sources & Methodology' }
      ]
    },
    {
      group: 'Global',
      items: [
        { file: 'global/master-presentation.html', label: 'Master Case (Global Deck)' }
      ]
    },
    {
      group: 'CPD Departments',
      items: [
        { file: 'departments/lca.html', label: 'Legislative & Community Affairs' },
        { file: 'departments/planning.html', label: 'Planning & Development' },
        { file: 'departments/law.html', label: 'Law / General Counsel' },
        { file: 'departments/operations.html', label: 'Operations & Community Recreation' },
        { file: 'departments/natural-resources-aquatics.html', label: 'Natural Resources & Aquatics' },
        { file: 'departments/facilities-revenue.html', label: 'Facilities & Revenue' },
        { file: 'departments/budget.html', label: 'Budget & Management' }
      ]
    },
    {
      group: 'Decision-Makers',
      items: [
        { file: 'decision-makers/superintendent.html', label: 'General Superintendent & CEO' },
        { file: 'decision-makers/board-of-commissioners.html', label: 'Board of Commissioners' },
        { file: 'decision-makers/alderman-yancy.html', label: '5th Ward Alderman' },
        { file: 'decision-makers/mayor-city-council.html', label: "Mayor's Office / City Council Committee" }
      ]
    },
    {
      group: 'Partner Organizations',
      items: [
        { file: 'partners/jpac.html', label: 'Jackson Park Advisory Council' },
        { file: 'partners/south-shore-cca.html', label: 'South Shore Cultural Center Advisory Council' },
        { file: 'partners/friends-of-the-parks.html', label: 'Friends of the Parks' },
        { file: 'partners/chicago-parks-foundation.html', label: 'Chicago Parks Foundation' }
      ]
    },
    {
      group: 'Community',
      items: [
        { file: 'community/community-presentation.html', label: 'Community & Public Presentation' }
      ]
    }
  ];

  function buildHeader() {
    // Pages that need maximum vertical space for their own content (e.g. the
    // interactive roadmap) can opt out of the full header/banner by setting
    // <html data-minimal-nav="true">. window.SITE_ROOT is still set below so
    // search.js and page-relative links keep working.
    if (document.documentElement.getAttribute('data-minimal-nav') === 'true') {
      return;
    }

    var groupsHtml = NAV_LINKS.map(function (g) {
      var links = g.items.map(function (item) {
        var isActive = item.file === CURRENT;
        return '<a href="' + ROOT + item.file + '"' + (isActive ? ' class="active" aria-current="page"' : '') + '>' + item.label + '</a>';
      }).join('');
      return '<div class="nav-links"><span class="nav-group-label">' + g.group + '</span>' + links + '</div>';
    }).join('');

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
          '<div class="nav-groups">' + groupsHtml + '</div>' +
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

// Sitewide search overlay. Progressively enhances any [data-sf-search-trigger]
// element (see the header search button duplicated across pages). Builds its
// own modal DOM and styles at runtime so no markup/CSS needs to be duplicated
// per-page -- only this script + the Fuse.js CDN tag are shared includes.
(function () {
  var INDEX_URL = '/assets/data/search-index.json';
  var FUSE_CDN = 'https://cdn.jsdelivr.net/npm/fuse.js@7.0.0/dist/fuse.min.js';

  var fuse = null;
  var indexPromise = null;
  var fusePromise = null;
  var overlay = null;
  var input = null;
  var resultsEl = null;
  var lastQuery = '';

  function escapeHtml(s) {
    return String(s == null ? '' : s).replace(/[&<>"']/g, function (c) {
      return { '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[c];
    });
  }

  function loadScript(src) {
    return new Promise(function (resolve, reject) {
      var s = document.createElement('script');
      s.src = src;
      s.onload = resolve;
      s.onerror = reject;
      document.head.appendChild(s);
    });
  }

  function ensureFuse() {
    if (fusePromise) return fusePromise;
    fusePromise = (window.Fuse ? Promise.resolve() : loadScript(FUSE_CDN)).then(function () {
      return fetchIndex();
    }).then(function (data) {
      fuse = new window.Fuse(data, {
        includeScore: true,
        threshold: 0.34,
        ignoreLocation: true,
        keys: [
          { name: 'title', weight: 0.4 },
          { name: 'heading', weight: 0.3 },
          { name: 'description', weight: 0.2 },
          { name: 'section', weight: 0.1 },
        ],
      });
    });
    return fusePromise;
  }

  function fetchIndex() {
    if (indexPromise) return indexPromise;
    indexPromise = fetch(INDEX_URL).then(function (r) { return r.json(); });
    return indexPromise;
  }

  function injectStyles() {
    if (document.getElementById('sf-search-styles')) return;
    var style = document.createElement('style');
    style.id = 'sf-search-styles';
    style.textContent = [
      '.sf-search-overlay{position:fixed;inset:0;background:rgba(0,0,0,.75);backdrop-filter:blur(3px);z-index:5000;display:none;align-items:flex-start;justify-content:center;padding:10vh 20px 20px;}',
      '.sf-search-overlay.open{display:flex;}',
      '.sf-search-panel{width:100%;max-width:640px;background:#111;border:1px solid rgba(229,169,60,.3);border-radius:20px;box-shadow:0 20px 60px rgba(0,0,0,.6);overflow:hidden;font-family:"Jost",sans-serif;}',
      '.sf-search-input-row{display:flex;align-items:center;gap:12px;padding:18px 20px;border-bottom:1px solid rgba(255,255,255,.08);}',
      '.sf-search-input-row i{color:#E5A93C;font-size:1.1rem;}',
      '.sf-search-input-row input{flex:1;background:transparent;border:none;outline:none;color:#F5F5F5;font-family:"Jost",sans-serif;font-size:1.05rem;font-weight:300;}',
      '.sf-search-input-row input::placeholder{color:#777;}',
      '.sf-search-close{background:transparent;border:none;color:#888;font-size:1.3rem;cursor:pointer;line-height:1;padding:4px;}',
      '.sf-search-close:hover{color:#fff;}',
      '.sf-search-results{max-height:56vh;overflow-y:auto;}',
      '.sf-search-empty{padding:32px 20px;text-align:center;color:#888;font-weight:300;font-size:.95rem;}',
      '.sf-search-hint{padding:14px 20px;color:#666;font-size:.8rem;font-weight:300;}',
      '.sf-search-result{display:block;padding:14px 20px;text-decoration:none;border-bottom:1px solid rgba(255,255,255,.05);transition:background .15s;}',
      '.sf-search-result:hover,.sf-search-result.active{background:rgba(229,169,60,.08);}',
      '.sf-search-result .sfr-top{display:flex;align-items:center;gap:10px;margin-bottom:4px;}',
      '.sf-search-result .sfr-section{font-size:.65rem;font-weight:600;text-transform:uppercase;letter-spacing:.06em;color:#E5A93C;background:rgba(229,169,60,.12);padding:2px 10px;border-radius:20px;}',
      '.sf-search-result .sfr-title{color:#F5F5F5;font-weight:500;font-size:.98rem;}',
      '.sf-search-result .sfr-desc{color:#aaa;font-size:.85rem;font-weight:300;line-height:1.4;overflow:hidden;text-overflow:ellipsis;display:-webkit-box;-webkit-line-clamp:2;-webkit-box-orient:vertical;}',
      '.site-search-trigger{background:transparent;border:1px solid rgba(255,255,255,.15);color:#ddd;width:38px;height:38px;border-radius:50%;display:inline-flex;align-items:center;justify-content:center;cursor:pointer;transition:.2s;flex-shrink:0;}',
      '.site-search-trigger:hover{border-color:#E5A93C;color:#E5A93C;}',
    ].join('');
    document.head.appendChild(style);
  }

  function buildOverlay() {
    if (overlay) return;
    injectStyles();
    overlay = document.createElement('div');
    overlay.className = 'sf-search-overlay';
    overlay.innerHTML =
      '<div class="sf-search-panel" role="dialog" aria-modal="true" aria-label="Search SelassieFest">' +
        '<div class="sf-search-input-row">' +
          '<i class="fas fa-search" aria-hidden="true"></i>' +
          '<input type="text" placeholder="Search the site…" aria-label="Search query" autocomplete="off" />' +
          '<button class="sf-search-close" aria-label="Close search">&times;</button>' +
        '</div>' +
        '<div class="sf-search-results"></div>' +
      '</div>';
    document.body.appendChild(overlay);

    input = overlay.querySelector('input');
    resultsEl = overlay.querySelector('.sf-search-results');
    resultsEl.innerHTML = '<div class="sf-search-hint">Start typing to search events, games, marketplace, and more.</div>';

    overlay.addEventListener('click', function (e) {
      if (e.target === overlay) close();
    });
    overlay.querySelector('.sf-search-close').addEventListener('click', close);

    var debounceTimer;
    input.addEventListener('input', function () {
      clearTimeout(debounceTimer);
      var q = input.value;
      debounceTimer = setTimeout(function () { runSearch(q); }, 150);
    });

    input.addEventListener('keydown', function (e) {
      if (e.key === 'Escape') { close(); return; }
      if (e.key === 'Enter') {
        var first = resultsEl.querySelector('.sf-search-result');
        if (first) window.location.href = first.getAttribute('href');
      }
    });
  }

  function runSearch(query) {
    lastQuery = query;
    var q = query.trim();
    if (!q) {
      resultsEl.innerHTML = '<div class="sf-search-hint">Start typing to search events, games, marketplace, and more.</div>';
      return;
    }
    ensureFuse().then(function () {
      if (lastQuery !== query) return; // stale response
      var matches = fuse.search(q, { limit: 8 });
      if (!matches.length) {
        resultsEl.innerHTML = '<div class="sf-search-empty">No results for "' + escapeHtml(q) + '". Try a different word.</div>';
        return;
      }
      resultsEl.innerHTML = matches.map(function (m) {
        var item = m.item;
        return '<a class="sf-search-result" href="' + item.url + '">' +
          '<div class="sfr-top"><span class="sfr-section">' + escapeHtml(item.section) + '</span>' +
          '<span class="sfr-title">' + escapeHtml(item.title) + '</span></div>' +
          '<div class="sfr-desc">' + escapeHtml(item.description || item.heading || '') + '</div>' +
          '</a>';
      }).join('');
    });
  }

  function open() {
    buildOverlay();
    overlay.classList.add('open');
    document.body.style.overflow = 'hidden';
    setTimeout(function () { input.focus(); }, 30);
    ensureFuse();
  }

  function close() {
    if (!overlay) return;
    overlay.classList.remove('open');
    document.body.style.overflow = '';
  }

  document.addEventListener('DOMContentLoaded', function () {
    document.querySelectorAll('[data-sf-search-trigger]').forEach(function (el) {
      el.addEventListener('click', open);
    });
  });

  document.addEventListener('keydown', function (e) {
    var isMeta = e.metaKey || e.ctrlKey;
    if (isMeta && e.key.toLowerCase() === 'k') {
      e.preventDefault();
      open();
    }
  });

  window.SFSearch = { open: open, close: close };
})();

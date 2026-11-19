// BIOS102 Docket look: shared helper. After a tool renders a page, call Docket.head(viewElement).
// It groups the banner illustration, the small label, the title and the intro text into one header
// block (.sd-head) so the illustration always gets its full height and never slides behind a card.
window.Docket = (function () {
  function head(view) {
    if (!view) return;
    const banner = view.querySelector(':scope > .sd-bannerbg');
    const kick = view.querySelector(':scope > .sd-kicker');
    if (!banner || !kick) return;
    const wrap = document.createElement('header');
    wrap.className = 'sd-head';
    view.insertBefore(wrap, banner);
    wrap.appendChild(banner);
    wrap.appendChild(kick);
    // Take what follows the label: an optional back link, the title (or hero block), chips and the intro line.
    let seenTitle = false;
    let el = wrap.nextElementSibling;
    while (el) {
      const isTitle = el.matches('.rm-h1, .rm-hero');
      const isLede = el.matches('.rm-lede');
      const isRow = el.matches('.rm-row') && !el.querySelector('button, a.btn-p, a.btn-s, select');
      const isBack = !seenTitle && el.matches('button.btn-t');
      if (!(isTitle || isLede || isRow || isBack)) break;
      const next = el.nextElementSibling;
      wrap.appendChild(el);
      if (isTitle) seenTitle = true;
      if (el.matches('.rm-hero') || isLede) break;   // the hero holds its own intro; a lede ends the header
      el = next;
    }
  }
  // Fill a list with links to the page's own section headings (h2), with smooth scrolling.
  function pageNav(ol, root) {
    if (!ol || !root) return;
    const hs = Array.from(root.querySelectorAll('h2')).filter((h) => h.offsetParent !== null || true);
    const seen = {};
    ol.innerHTML = hs.map((h) => {
      let id = h.id || h.textContent.trim().toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '') || 'section';
      while (seen[id]) id += '-2';
      seen[id] = 1; h.id = id;
      return '<li><a href="#' + id + '"><svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 12h14M13 6l6 6-6 6"/></svg>' + h.textContent.trim().replace(/</g, '&lt;') + '</a></li>';
    }).join('');
    ol.addEventListener('click', (e) => { const a = e.target.closest('a'); if (!a) return; const t = document.getElementById(a.getAttribute('href').slice(1)); if (t) { e.preventDefault(); t.scrollIntoView({ behavior: 'smooth', block: 'start' }); } });
  }
  return { head, pageNav };
})();

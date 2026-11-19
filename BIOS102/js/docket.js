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
  return { head };
})();

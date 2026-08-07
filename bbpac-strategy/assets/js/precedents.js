/* ==========================================================================
   precedents.js — renders the shared Precedent Library from
   assets/data/precedents.json. Every department/decision-maker/partner
   deck links INTO this page (with an anchor, e.g. precedents.html#lane-beach)
   rather than repeating precedent text, so facts never drift out of sync.
   ========================================================================== */

(function () {
  var root = window.SITE_ROOT || './';
  var mount = document.getElementById('precedent-library');
  if (!mount) return;

  fetch(root + 'assets/data/precedents.json')
    .then(function (r) { return r.json(); })
    .then(render);

  function stars(n) {
    return '★★★★★'.slice(0, n) + '<span style="color:#d8dbdd">' + '★★★★★'.slice(n) + '</span>';
  }

  function statusChip(status) {
    var labels = { confirmed: 'Confirmed', partial: 'Partially confirmed', pending: 'Pending verification', na: 'Not applicable' };
    return '<span class="status-chip ' + status + '">' + (labels[status] || status) + '</span>';
  }

  function bucketHtml(bucket) {
    var cards = bucket.items.map(function (item) {
      return (
        '<div class="precedent-card" id="' + item.id + '">' +
        '<h4>' + item.title + '</h4>' +
        '<div class="rating" aria-hidden="true">' + stars(item.rating) + '</div>' +
        '<p>' + item.whatHappened + '</p>' +
        '<p><strong>Why it matters:</strong> ' + item.whyItMatters + '</p>' +
        '<p>' + statusChip(item.verificationStatus) + '</p>' +
        '<p style="font-size:12.5px;color:#5a6672;"><em>' + item.verificationNote + '</em></p>' +
        '</div>'
      );
    }).join('');
    return (
      '<div class="deck-section">' +
      '<h2>' + bucket.title + '</h2>' +
      '<p><em>' + bucket.question + '</em></p>' +
      '<div class="precedent-grid">' + cards + '</div>' +
      '</div>'
    );
  }

  function voidedHtml(list) {
    var rows = list.map(function (v) {
      return '<tr><td>' + v.name + '</td><td>#' + v.parkNumber + '</td><td>' + v.status + '</td><td>' + v.note + '</td></tr>';
    }).join('');
    return (
      '<div class="deck-section" id="voided-properties">' +
      '<h2>Voided Beach Park Numbers</h2>' +
      '<p>The Chicago Public Library\'s transferred CPD drawing archive labels these park numbers "voided property." Voided does not automatically mean split or merged — each requires its own confirmation.</p>' +
      '<div class="evidence-table-wrap"><table class="evidence"><thead><tr><th>Former beach</th><th>Park #</th><th>Status</th><th>Note</th></tr></thead><tbody>' + rows + '</tbody></table></div>' +
      '</div>'
    );
  }

  function paperTrailHtml(pt) {
    var rows = pt.items.map(function (i) {
      return (
        '<tr><td>' + i.n + '</td><td>' + i.target + '</td><td>' + statusChip(i.status) + '</td><td>' + i.detail + '</td></tr>'
      );
    }).join('');
    return (
      '<div class="deck-section" id="paper-trail">' +
      '<h2>' + pt.title + '</h2>' +
      '<p>' + pt.intro + '</p>' +
      '<div class="evidence-table-wrap"><table class="evidence"><thead><tr><th>#</th><th>Target</th><th>Status</th><th>Detail</th></tr></thead><tbody>' + rows + '</tbody></table></div>' +
      '</div>'
    );
  }

  function render(data) {
    mount.innerHTML =
      bucketHtml(data.bucketA) +
      bucketHtml(data.bucketB) +
      voidedHtml(data.voidedProperties) +
      paperTrailHtml(data.paperTrail);

    // Content is injected async, so the browser's automatic "scroll to
    // #anchor on load" already ran (and failed, since the element didn't
    // exist yet) before we got here. Finish the job manually.
    if (location.hash) {
      var target = document.getElementById(location.hash.slice(1));
      if (target) target.scrollIntoView();
    }
  }
})();

/* ==========================================================================
   matrix.js — renders the Stakeholder, Authority & Presentation Routing
   Matrix from assets/data/matrix.json as a searchable / filterable /
   sortable table. This is the "campaign control sheet" described in the
   source planning document: for every organization/individual it records
   who they are, what authority they hold, what they need to see, and
   which tailored presentation to send them to.
   ========================================================================== */

(function () {
  var root = window.SITE_ROOT || './';
  var tbody = document.getElementById('matrix-body');
  var searchInput = document.getElementById('matrix-search');
  var tierSelect = document.getElementById('matrix-tier-filter');
  var authSelect = document.getElementById('matrix-authority-filter');
  var statusSelect = document.getElementById('matrix-status-filter');
  var countEl = document.getElementById('matrix-count');
  if (!tbody) return;

  var DATA = [];
  var sortKey = null;
  var sortDir = 1;

  var AUTH_LABELS = {
    D: 'Decision-maker', R: 'Recommender', T: 'Technical validator',
    G: 'Gatekeeper / process owner', C: 'Champion', A: 'Ally',
    S: 'Stakeholder', P: 'Public / community'
  };

  fetch(root + 'assets/data/matrix.json')
    .then(function (r) { return r.json(); })
    .then(function (data) {
      DATA = data;
      populateFilters();
      renderRows(DATA);
    });

  function populateFilters() {
    var tiers = uniq(DATA.map(function (d) { return d.tier; }));
    tiers.forEach(function (t) {
      var opt = document.createElement('option');
      opt.value = t; opt.textContent = t;
      tierSelect.appendChild(opt);
    });
    Object.keys(AUTH_LABELS).forEach(function (k) {
      var opt = document.createElement('option');
      opt.value = k; opt.textContent = k + ' — ' + AUTH_LABELS[k];
      authSelect.appendChild(opt);
    });
    var statuses = uniq(DATA.map(function (d) { return d.status; }));
    statuses.forEach(function (s) {
      var opt = document.createElement('option');
      opt.value = s; opt.textContent = s;
      statusSelect.appendChild(opt);
    });
  }

  function uniq(arr) {
    return arr.filter(function (v, i) { return v && arr.indexOf(v) === i; });
  }

  function rowHtml(d) {
    var link = d.presentationHref
      ? '<a href="' + root + d.presentationHref + '">' + d.presentationLabel + '</a>'
      : '<span style="color:#8a8f93">' + (d.presentationLabel || 'No dedicated deck — see routing note') + '</span>';
    return (
      '<tr data-tier="' + d.tier + '" data-authority="' + d.authority + '" data-status="' + escapeAttr(d.status) + '" data-search="' + escapeAttr((d.name + ' ' + d.organization + ' ' + d.department + ' ' + d.interest + ' ' + d.ask).toLowerCase()) + '">' +
      '<td class="name">' + d.name + '<div style="font-weight:400;color:#5a6672;font-size:12px;">' + d.department + '</div></td>' +
      '<td>' + d.organization + '</td>' +
      '<td><span class="auth-tag ' + d.authority + '" title="' + AUTH_LABELS[d.authority] + '">' + d.authority + '</span></td>' +
      '<td>' + d.interest + '</td>' +
      '<td>' + d.ask + '</td>' +
      '<td>' + link + '</td>' +
      '<td><span class="status-chip ' + statusClass(d.status) + '">' + d.status + '</span></td>' +
      '</tr>'
    );
  }

  function statusClass(s) {
    s = (s || '').toLowerCase();
    if (s.indexOf('not started') !== -1 || s.indexOf('not yet contacted') !== -1) return 'pending';
    if (s.indexOf('drafted') !== -1 || s.indexOf('review') !== -1 || s.indexOf('progress') !== -1) return 'partial';
    if (s.indexOf('ready') !== -1 || s.indexOf('sent') !== -1 || s.indexOf('complete') !== -1) return 'confirmed';
    return 'na';
  }

  function escapeAttr(s) { return (s || '').replace(/"/g, '&quot;'); }

  function renderRows(data) {
    tbody.innerHTML = data.map(rowHtml).join('');
    countEl.textContent = data.length + ' of ' + DATA.length + ' stakeholders shown';
    applyFilters();
  }

  function applyFilters() {
    var q = (searchInput.value || '').toLowerCase();
    var tier = tierSelect.value;
    var auth = authSelect.value;
    var status = statusSelect.value;
    var visibleCount = 0;
    Array.prototype.forEach.call(tbody.querySelectorAll('tr'), function (row) {
      var matches = true;
      if (q && row.getAttribute('data-search').indexOf(q) === -1) matches = false;
      if (tier && row.getAttribute('data-tier') !== tier) matches = false;
      if (auth && row.getAttribute('data-authority') !== auth) matches = false;
      if (status && row.getAttribute('data-status') !== status) matches = false;
      row.classList.toggle('row-hidden', !matches);
      if (matches) visibleCount++;
    });
    countEl.textContent = visibleCount + ' of ' + DATA.length + ' stakeholders shown';
  }

  [searchInput, tierSelect, authSelect, statusSelect].forEach(function (el) {
    el.addEventListener('input', applyFilters);
    el.addEventListener('change', applyFilters);
  });

  Array.prototype.forEach.call(document.querySelectorAll('table.matrix th[data-sort]'), function (th) {
    th.addEventListener('click', function () {
      var key = th.getAttribute('data-sort');
      sortDir = (sortKey === key) ? -sortDir : 1;
      sortKey = key;
      var sorted = DATA.slice().sort(function (a, b) {
        return (a[key] || '').localeCompare(b[key] || '') * sortDir;
      });
      renderRows(sorted);
    });
  });
})();

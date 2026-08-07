/* ==========================================================================
   evidence-status.js — renders the Gate 0 Recognition Dossier + campaign
   evidence checklist from assets/data/evidence.json as a status dashboard.
   ========================================================================== */

(function () {
  var root = window.SITE_ROOT || './';
  var mount = document.getElementById('evidence-table');
  var summaryMount = document.getElementById('evidence-summary');
  if (!mount) return;

  fetch(root + 'assets/data/evidence.json')
    .then(function (r) { return r.json(); })
    .then(render);

  function render(items) {
    var counts = { confirmed: 0, partial: 0, pending: 0 };
    items.forEach(function (i) { counts[i.status] = (counts[i.status] || 0) + 1; });

    summaryMount.innerHTML =
      '<div class="evidence-stat"><div class="num confirmed">' + counts.confirmed + '</div><div class="label">Confirmed</div></div>' +
      '<div class="evidence-stat"><div class="num partial">' + counts.partial + '</div><div class="label">Partially confirmed</div></div>' +
      '<div class="evidence-stat"><div class="num pending">' + counts.pending + '</div><div class="label">Pending / not started</div></div>' +
      '<div class="evidence-stat"><div class="num">' + items.length + '</div><div class="label">Total tracked items</div></div>';

    var byCategory = {};
    items.forEach(function (i) {
      byCategory[i.category] = byCategory[i.category] || [];
      byCategory[i.category].push(i);
    });

    var html = '';
    Object.keys(byCategory).forEach(function (cat) {
      var rows = byCategory[cat].map(function (i) {
        return (
          '<tr><td style="font-weight:700;">' + i.item + '</td>' +
          '<td><span class="status-chip ' + i.status + '">' + statusLabel(i.status) + '</span></td>' +
          '<td>' + i.owner + '</td>' +
          '<td>' + i.next + '</td></tr>'
        );
      }).join('');
      html += '<h3 style="margin-top:26px;color:#0b4f4a;">' + cat + '</h3>' +
        '<div class="evidence-table-wrap"><table class="evidence"><thead><tr><th style="width:26%">Item</th><th style="width:14%">Status</th><th style="width:18%">Owner</th><th>Next step</th></tr></thead><tbody>' + rows + '</tbody></table></div>';
    });
    mount.innerHTML = html;
  }

  function statusLabel(s) {
    return { confirmed: 'Confirmed', partial: 'Partially confirmed', pending: 'Pending / not started' }[s] || s;
  }
})();

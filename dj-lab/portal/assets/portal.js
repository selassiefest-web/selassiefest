// Rainbow DJ Lab portal helpers: role redirects into the live app.
window.DJLabPortal = {
  go: function (role) {
    var c = window.DJLabAuth.code();
    location.replace("/dj-lab/live/" + (c ? "?c=" + encodeURIComponent(c) : "") + "#" + role);
  },
  esc: function (s) { return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
};

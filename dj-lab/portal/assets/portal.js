// Rainbow DJ Lab portal helpers: role redirects into the live app.
window.DJLabPortal = {
  go: function (role) {
    // The live app remembers this device's family link, room code or coach class.
    location.replace("/dj-lab/live/#" + role);
  },
  esc: function (s) { return String(s == null ? "" : s).replace(/[&<>"']/g, function (c) { return { "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;", "'": "&#39;" }[c]; }); }
};

// Rainbow DJ Lab portal: who is signed in. Coach sessions and the class
// code are shared with the live app (/dj-lab/live/) through localStorage on
// this device; coaches sign in there with the emailed one-time link.
window.DJLabAuth = {
  coach: function () { try { return JSON.parse(localStorage.getItem("djlab-coach") || "null"); } catch (e) { return null; } },
  code: function () {
    var q = new URLSearchParams(location.search).get("c");
    if (q) { try { localStorage.setItem("djlab-code", q.toUpperCase()); } catch (e) {} return q.toUpperCase(); }
    try { return localStorage.getItem("djlab-code"); } catch (e) { return null; }
  },
  coachClass: function () { try { return JSON.parse(localStorage.getItem("djlab-coach-class") || "null"); } catch (e) { return null; } },
  signOutCoach: function () { try { localStorage.removeItem("djlab-coach"); } catch (e) {} }
};

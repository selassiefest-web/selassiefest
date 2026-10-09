// Rainbow DJ Lab portal: Supabase calls. (The sitemap called this
// firestore.js; the Lab runs on Supabase, the same project as the live
// class app, so every call goes through the security-definer RPCs in
// supabase/dj-lab.sql.)
window.DJLabDB = {
  rpc: function (name, args) {
    return window.sfSupabaseReady.then(function (c) { return c.rpc(name, args); })
      .then(function (r) { if (r.error) throw r.error; return r.data; });
  },
  coachState: function (session, cohort) { return this.rpc("djlab_coach_state", { p_session: session, p_cohort: cohort, p_since: 0 }); },
  safetyRoster: function (session, cohort) { return this.rpc("djlab_coach_safety_roster", { p_session: session, p_cohort: cohort }); },
  signout: function (session, cohort, kid, unit, by, idChecked, self) {
    return this.rpc("djlab_coach_signout", { p_session: session, p_cohort: cohort, p_kid: kid, p_unit: unit,
      p_picked_up_by: by, p_id_checked: !!idChecked, p_self: !!self });
  }
};

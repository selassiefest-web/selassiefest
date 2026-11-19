// BIOS102 Research Match: the matching engine, email drafts, calendar files and
// the next-step planner. Pure functions only (no DOM, no network) so the logic
// can be checked in Node. The UI lives in research-app.js.
//
// HOW THE MATCH WORKS (and what the page tells students):
//   1. Each interest card the student rates 1-5 becomes a signed vote (rating minus 3,
//      so -2..+2) spread over the tags that card touches. The three "which pulls you
//      more" questions add a smaller positive nudge for the chosen answer.
//   2. A professor's score is the sum, over every tag, of (student preference x how
//      central that tag is to the professor's work, 0-3). Liking things a lab does
//      raises the score; disliking things a lab does lowers it.
//   3. Hard preferences apply on top: "rather not work with live animals" and "no
//      travel" push the affected labs down and flag them.
//   4. Evidence of student mentorship (the Thomson archive) only breaks near-ties.
//   5. The page shows the reasons behind every score. It is a conversation starter.
//      The interview, not the score, decides.
window.RM_ENGINE = (() => {
  const D = () => window.RM_DATA;

  function computePrefs(answers) {
    const pref = {};
    const add = (t, v) => { pref[t] = (pref[t] || 0) + v; };
    const ratings = (answers && answers.ratings) || {};
    D().CARDS.forEach((c) => {
      const r = Number(ratings[c.id]);
      if (!r) return;
      Object.entries(c.tags).forEach(([t, w]) => add(t, (r - 3) * w));
    });
    const choices = (answers && answers.choices) || {};
    D().CHOICES.forEach((q) => {
      const opt = q.options.find((o) => o.v === choices[q.id]);
      if (opt) Object.entries(opt.tags).forEach(([t, w]) => add(t, 1.5 * w));
    });
    const k = (answers && answers.constraints) || {};
    if (k.goal === 'health') add('health', 1.5);
    if (k.goal === 'field') { add('field', 1); add('conservation', 1); }
    if (k.goal === 'grad') { add('wetlab', 0.5); add('computing', 0.5); }
    if (k.goal === 'industry') { add('wetlab', 0.8); add('proteins', 0.4); }
    return pref;
  }

  function answeredCount(answers) {
    const r = (answers && answers.ratings) || {};
    return Object.keys(r).filter((id) => Number(r[id]) > 0).length;
  }

  const MIN_CARDS = 8;
  function profileComplete(answers) {
    const a = answers || {};
    const rated = answeredCount(a);
    const choices = a.choices || {};
    const k = a.constraints || {};
    // Eight cards are enough to get useful matches. The rest sharpen them but are optional.
    return rated >= MIN_CARDS;
  }

  const MENTOR_BONUS = { strong: 1.0, good: 0.6, some: 0.2, pathway: 0.3, few: 0 };

  function cardOverlap(card, f) {
    return Object.entries(card.tags).reduce((s, [t, w]) => s + w * (f.tags[t] || 0), 0);
  }

  // How many of a card's defining tags (weight >= 0.8) are central (>= 2) to this professor's work.
  function sharedCore(card, f) {
    return Object.entries(card.tags).filter(([t, w]) => w >= 0.8 && (f.tags[t] || 0) >= 2).length;
  }

  function matchAll(answers) {
    const pref = computePrefs(answers);
    const k = (answers && answers.constraints) || {};
    const ratings = (answers && answers.ratings) || {};
    const rows = D().FACULTY.map((f) => {
      let raw = 0;
      Object.entries(pref).forEach(([t, v]) => { raw += v * (f.tags[t] || 0); });
      const cautions = [];
      if (k.animals === 'no' && f.animals) { raw -= 12; cautions.push('This lab works with live animals, and you said you would rather not.'); }
      else if (k.animals === 'maybe' && f.animals) { cautions.push('This lab works with live animals. You said you would need to think about it, so ask what the animal work involves.'); }
      if (k.travel === 'no' && f.summerTravel) { raw -= 6; cautions.push('This work includes fieldwork trips away from Kenosha, and you said you need to stay close.'); }
      else if (k.travel === 'local' && f.summerTravel) { cautions.push('Some of this work involves summer travel. Ask whether local-only options exist.'); }
      const bonus = MENTOR_BONUS[f.mentorship.level] || 0;
      const reasons = D().CARDS
        .map((c) => ({ c, r: Number(ratings[c.id]) || 0, o: cardOverlap(c, f) }))
        .filter((x) => x.r >= 4 && x.o >= 1.2 && sharedCore(x.c, f) >= 1)
        .sort((a, b) => (b.o * b.r) - (a.o * a.r))
        .slice(0, 3)
        .map((x) => x.c.text);
      const lukewarm = D().CARDS
        .map((c) => ({ c, r: Number(ratings[c.id]) || 0, o: cardOverlap(c, f) }))
        .filter((x) => x.r && x.r <= 2 && sharedCore(x.c, f) >= 2)
        .sort((a, b) => b.o - a.o)
        .slice(0, 2)
        .map((x) => x.c.text);
      lukewarm.forEach((t) => cautions.push('You were lukewarm on: "' + t + '", which is part of this work.'));
      return { f, raw, score: raw + bonus, reasons, cautions };
    });
    rows.sort((a, b) => b.score - a.score);
    const top = rows[0] ? Math.max(rows[0].score, 0.0001) : 1;
    rows.forEach((r, i) => {
      r.rank = i + 1;
      r.rel = Math.max(0, Math.min(1, r.score / top));
      const gap = r.score / top;
      r.band = i === 0 ? 'Strongest match'
        : (gap >= 0.8 ? 'Strong match' : gap >= 0.55 ? 'Worth a conversation' : 'Less likely a fit');
      if (r.score <= 0) r.band = 'Less likely a fit';
    });
    return rows;
  }

  // A student's top interest tags, for the "your profile" strip.
  function fingerprint(answers, n) {
    const pref = computePrefs(answers);
    const T = D().TAGS;
    return Object.entries(pref).filter(([, v]) => v > 0.5).sort((a, b) => b[1] - a[1]).slice(0, n || 5)
      .map(([t]) => T[t]);
  }

  // ---- Email drafts -------------------------------------------------------
  function sig(student) {
    return [student.name || '[Your name]', 'BIOS102 student, UW\u2013Parkside', student.email || ''].filter(Boolean).join('\n');
  }

  function interviewRequest(student, f, o) {
    const line = (o && o.customLine && o.customLine.trim()) || '[YOUR OWN SENTENCE: what in their work caught your attention, and why]';
    const when = (o && o.times && o.times.trim()) || '[2 or 3 days and times you are free, for example Tuesday after 2 pm]';
    const stage = (o && o.stage) || '';
    const subject = 'BIOS102 student asking for 20 minutes to learn about your research';
    const body =
`Dear ${f.honorific} ${f.last},

My name is ${student.name || '[Your name]'} and I am a student in Professor Harris's BIOS102 (Organismal Biology) class${stage ? ', ' + stage : ''}. As part of a course project I am learning how research works at Parkside and finding out which labs might be a good fit for me.

${line}

I am not asking for a position. I would be grateful for 20 minutes of your time, in person or by video, to hear how you got into this work and what your lab does day to day. ${when === '' ? '' : 'I am free ' + when + ', or I can work around your office hours.'}

Thank you for considering it.

${sig(student)}`;
    return { to: f.email, subject, body };
  }

  function followUp(student, f, o) {
    return {
      to: f.email,
      subject: 'Following up: BIOS102 student request to talk about your research',
      body:
`Dear ${f.honorific} ${f.last},

I wrote last week asking for 20 minutes to learn about your research. I know this is a busy time of the semester, so I wanted to follow up once in case my note was buried. If it is easier, I can stop by your office hours. If now is not a good time, no problem at all and thank you for reading.

${sig(student)}`,
    };
  }

  function thankYou(student, f, o) {
    const learned = (o && o.notes && o.notes.learned && o.notes.learned.trim()) || '[ONE specific thing you learned or found interesting]';
    return {
      to: f.email,
      subject: 'Thank you for talking with me about your research',
      body:
`Dear ${f.honorific} ${f.last},

Thank you for taking the time to talk with me${(o && o.interviewDate) ? ' on ' + fmtDate(o.interviewDate) : ''}. ${learned}

${(o && o.notes && o.notes.nextStep && o.notes.nextStep.trim()) ? 'You suggested that my next step is: ' + o.notes.nextStep.trim() + ' I will do that and keep you posted.' : 'I would like to keep learning about your work and will follow up on any next steps you suggest.'}

${sig(student)}`,
    };
  }

  function askEmail(student, f, o, path) {
    const why = (o && o.askWhy && o.askWhy.trim()) || '[In your own words: why this lab, and what you would like to do there]';
    const start = (o && o.askStart && o.askStart.trim()) || '[when you could start, for example next spring or this summer]';
    return {
      to: f.email,
      subject: 'Request to join your research group',
      body:
`Dear ${f.honorific} ${f.last},

Thank you again for meeting with me. I enjoyed learning about your work, and I would like to ask whether I could join your research group${path ? ' through ' + path : ''}.

${why}

I could start ${start} and can commit about ${hoursText(student)} hours a week. I understand that you may have limited space, and I would welcome any advice on how to prepare or on a better time to ask.

${sig(student)}`,
    };
  }

  function hoursText(student) {
    const h = student && student.hours;
    return h === '2-3' ? '2 to 3' : h === '4-6' ? '4 to 6' : h === '7+' ? '7 or more' : '[hours per week]';
  }

  // Students have UWP Outlook (Microsoft 365). These open Outlook on the web with the message
  // or event already filled in, so nothing depends on a desktop mail app being set up.
  function outlookCompose(draft) {
    return 'https://outlook.office.com/mail/deeplink/compose?to=' + encodeURIComponent(draft.to) + '&subject=' + encodeURIComponent(draft.subject) + '&body=' + encodeURIComponent(draft.body);
  }
  function outlookEvent({ title, start, minutes, location, description }) {
    const d = new Date(start); const e = new Date(d.getTime() + (minutes || 20) * 60000);
    return 'https://outlook.office.com/calendar/0/deeplink/compose?path=%2Fcalendar%2Faction%2Fcompose&rru=addevent&subject=' + encodeURIComponent(title)
      + '&startdt=' + encodeURIComponent(d.toISOString()) + '&enddt=' + encodeURIComponent(e.toISOString())
      + (location ? '&location=' + encodeURIComponent(location) : '') + '&body=' + encodeURIComponent(description || '');
  }

  function mailto(draft) {
    return 'mailto:' + encodeURIComponent(draft.to).replace('%40', '@') + '?subject=' + encodeURIComponent(draft.subject) + '&body=' + encodeURIComponent(draft.body);
  }

  // ---- Dates / calendar ---------------------------------------------------
  function fmtDate(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d)) return String(iso);
    return d.toLocaleDateString('en-US', { weekday: 'long', month: 'long', day: 'numeric' });
  }
  function fmtDateTime(iso) {
    if (!iso) return '';
    const d = new Date(iso);
    if (isNaN(d)) return String(iso);
    return d.toLocaleString('en-US', { weekday: 'short', month: 'short', day: 'numeric', hour: 'numeric', minute: '2-digit' });
  }
  function daysSince(iso) {
    if (!iso) return null;
    const t = new Date(iso).getTime();
    return isNaN(t) ? null : Math.floor((Date.now() - t) / 86400000);
  }

  // Floating (local-time) .ics event so it lands at the right hour in any calendar.
  function icsEvent({ title, start, minutes, location, description }) {
    const d = new Date(start);
    const p = (n) => String(n).padStart(2, '0');
    const stamp = (x) => `${x.getFullYear()}${p(x.getMonth() + 1)}${p(x.getDate())}T${p(x.getHours())}${p(x.getMinutes())}00`;
    const end = new Date(d.getTime() + (minutes || 20) * 60000);
    const esc = (s) => String(s || '').replace(/\\/g, '\\\\').replace(/\n/g, '\\n').replace(/,/g, '\\,').replace(/;/g, '\\;');
    return ['BEGIN:VCALENDAR', 'VERSION:2.0', 'PRODID:-//BIOS102 Research Match//EN', 'BEGIN:VEVENT',
      'UID:rm-' + d.getTime() + '@selassiefest.com', 'DTSTAMP:' + stamp(new Date()), 'DTSTART:' + stamp(d), 'DTEND:' + stamp(end),
      'SUMMARY:' + esc(title), location ? 'LOCATION:' + esc(location) : '', 'DESCRIPTION:' + esc(description),
      'BEGIN:VALARM', 'TRIGGER:-PT60M', 'ACTION:DISPLAY', 'DESCRIPTION:' + esc(title), 'END:VALARM', 'END:VEVENT', 'END:VCALENDAR']
      .filter(Boolean).join('\r\n');
  }

  // ---- Stage + next-step planner -----------------------------------------
  const STATUS = {
    none: 'Not started',
    drafted: 'Email drafted',
    sent: 'Email sent',
    scheduled: 'Interview scheduled',
    done: 'Interview done',
    declined: 'They said not now',
    noreply: 'No reply, moving on',
  };

  function outreachOf(state, id) {
    return ((state && state.outreach) || {})[id] || { status: 'none' };
  }

  // The single most useful thing to do next, plus a short list.
  function nextActions(state) {
    const out = [];
    const F = Object.fromEntries(D().FACULTY.map((f) => [f.id, f]));
    const s = state || {};
    if (!s.profileDone) {
      out.push({ stage: 'know', text: 'Finish the interest cards (about 8 minutes).', urgency: 1 });
      return out;
    }
    const list = s.shortlist || [];
    if (!list.length) { out.push({ stage: 'match', text: 'Pick 2 or 3 professors from your matches to interview.', urgency: 1 }); return out; }
    list.forEach((id) => {
      const f = F[id]; if (!f) return;
      const o = outreachOf(s, id);
      const nm = f.honorific + ' ' + f.last;
      if (o.status === 'none') out.push({ stage: 'interview', id, text: 'Write your own sentence and send the interview request to ' + nm + '.', urgency: 2 });
      else if (o.status === 'drafted') out.push({ stage: 'interview', id, text: 'Send your drafted email to ' + nm + ' and mark it sent.', urgency: 2 });
      else if (o.status === 'sent') {
        const d = daysSince(o.sentAt);
        if (d !== null && d >= 7) out.push({ stage: 'interview', id, text: nm + ' has not replied in ' + d + ' days. Send the short follow-up, or visit office hours.', urgency: 3 });
        else out.push({ stage: 'interview', id, text: 'Waiting on ' + nm + (d !== null ? ' (sent ' + d + ' day' + (d === 1 ? '' : 's') + ' ago). Follow up after 7 days.' : '.'), urgency: 0 });
      } else if (o.status === 'scheduled') {
        const when = o.interviewDate ? ' ' + fmtDateTime(o.interviewDate) : '';
        out.push({ stage: 'interview', id, text: 'Interview with ' + nm + when + '. Choose your questions and print the prep sheet.', urgency: 3 });
      } else if (o.status === 'done') {
        if (!o.fit) out.push({ stage: 'debrief', id, text: 'Write your debrief for ' + nm + ' while it is fresh, and send the thank-you within 24 hours.', urgency: 3 });
      }
    });
    const doneCount = list.filter((id) => outreachOf(s, id).status === 'done' && outreachOf(s, id).fit).length;
    if (doneCount && !(s.final && s.final.faculty)) out.push({ stage: 'decide', text: 'Compare your interviews and choose where to ask for a place.', urgency: 2 });
    if (s.final && s.final.faculty) out.push({ stage: 'decide', text: 'Send your ask to ' + (F[s.final.faculty] ? F[s.final.faculty].honorific + ' ' + F[s.final.faculty].last : 'your first choice') + '.', urgency: 2 });
    out.sort((a, b) => b.urgency - a.urgency);
    return out;
  }

  // Combines the interview-before score with what the student learned. Weights are shown on the page.
  function finalRanking(state, matches) {
    const byId = Object.fromEntries(matches.map((m) => [m.f.id, m]));
    const s = state || {};
    const rows = (s.shortlist || []).map((id) => {
      const o = outreachOf(s, id);
      const m = byId[id];
      const pre = m ? m.rel : 0;                       // 0-1
      const post = (o.fit && Number(o.fit.overall) > 0) ? Number(o.fit.overall) / 5 : null; // 0-1
      const score = post === null ? pre * 0.5 : (pre * 0.3 + post * 0.7);
      return { id, f: m && m.f, pre, post, score, would: o.would || '' };
    });
    rows.sort((a, b) => b.score - a.score);
    return rows;
  }

  return {
    computePrefs, answeredCount, profileComplete, matchAll, fingerprint,
    interviewRequest, followUp, thankYou, askEmail, mailto, outlookCompose, outlookEvent, MIN_CARDS,
    fmtDate, fmtDateTime, daysSince, icsEvent,
    STATUS, outreachOf, nextActions, finalRanking,
  };
})();

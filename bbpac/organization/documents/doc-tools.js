// Shared PDF / print / read-aloud tools for the BBPAC governance document
// library. Loaded by every phase-XX.html page so the ~510 documents in the
// library all get these controls from one file instead of per-page copies.
// No backend involved: PDF generation runs in the browser via jsPDF (CDN
// script tag in each page's <head>), printing uses the browser's own print
// dialog (which is also how a visitor gets a PDF via "Save as PDF" if they
// prefer that over the Download PDF button), and read-aloud uses the
// browser's built-in Web Speech API. Voice choice today is whatever
// voices the visitor's own browser/OS ships (labelled with a best-guess
// gender hint) -- a true custom/cloned voice is a planned future upgrade
// to a paid cloud TTS provider, not something the Web Speech API can do.
(function () {
  'use strict';

  function findCards() {
    return Array.prototype.slice.call(document.querySelectorAll('.doc-card, .tmpl-card'));
  }

  // Block children (p / h4 / ul / letter-block / coord-note, etc.) have no
  // textContent separation of their own -- naive .textContent on the whole
  // body would run every paragraph together with no breaks. Walk direct
  // children instead so each becomes its own paragraph/line.
  function extractParagraphs(el) {
    if (!el) return [];
    if (el.tagName && el.tagName.toLowerCase() === 'p' && !el.children.length) {
      var only = el.textContent.trim();
      return only ? [only] : [];
    }
    var paras = [];
    Array.prototype.forEach.call(el.children, function (child) {
      var tag = child.tagName.toLowerCase();
      if (tag === 'ul' || tag === 'ol') {
        var items = Array.prototype.map.call(child.querySelectorAll('li'), function (li) {
          return '• ' + li.textContent.trim();
        });
        if (items.length) paras.push(items.join('\n'));
      } else if (tag === 'h4') {
        var heading = child.textContent.trim();
        if (heading) paras.push(heading.toUpperCase());
      } else {
        var t = child.textContent.trim();
        if (t) paras.push(t);
      }
    });
    if (!paras.length) {
      var fallback = el.textContent.trim();
      if (fallback) paras.push(fallback);
    }
    return paras;
  }

  function cardMeta(card) {
    var titleEl = card.querySelector('h3, .tmpl-head h4');
    var idEl = card.querySelector('.doc-id, .cid');
    var bodyEl = card.querySelector('.doc-body, .tmpl-fields');
    var ownerEl = card.querySelector('.owner-line');
    return {
      id: (idEl && idEl.textContent.trim()) || card.id.replace(/^doc-/, ''),
      title: titleEl ? titleEl.textContent.trim() : 'Untitled document',
      paragraphs: extractParagraphs(bodyEl),
      ownerText: ownerEl ? ownerEl.textContent.trim() : '',
    };
  }

  // ---- toolbar injection ------------------------------------------------
  function injectToolbars() {
    findCards().forEach(function (card) {
      if (card.querySelector('[data-dt-toolbar]')) return; // idempotent
      var bar = document.createElement('div');
      bar.className = 'doc-toolbar';
      bar.setAttribute('data-dt-toolbar', '');
      bar.innerHTML =
        '<button type="button" class="dt-btn" data-dt-pdf><i class="fas fa-file-pdf"></i> PDF</button>' +
        '<button type="button" class="dt-btn" data-dt-print><i class="fas fa-print"></i> Print</button>' +
        '<button type="button" class="dt-btn" data-dt-listen><i class="fas fa-volume-up"></i> Listen</button>';
      card.insertBefore(bar, card.firstChild);
    });
  }

  // ---- PDF ---------------------------------------------------------------
  function downloadPdf(meta) {
    if (!window.jspdf || !window.jspdf.jsPDF) {
      alert('The PDF library did not load (check your connection) -- try again, or use Print instead.');
      return;
    }
    var doc = new window.jspdf.jsPDF({ unit: 'pt', format: 'letter' });
    var margin = 56, y = margin, maxWidth = 612 - margin * 2, pageBottom = 792 - margin;

    function ensureRoom(lineHeight) {
      if (y + lineHeight > pageBottom) { doc.addPage(); y = margin; }
    }
    function writeBlock(text, size, style, gapAfter) {
      doc.setFont('helvetica', style || 'normal');
      doc.setFontSize(size);
      var lines = doc.splitTextToSize(text, maxWidth);
      lines.forEach(function (line) {
        ensureRoom(size * 1.3);
        doc.text(line, margin, y);
        y += size * 1.3;
      });
      y += gapAfter || 0;
    }

    writeBlock(meta.id + ' — ' + meta.title, 14, 'bold', 10);
    doc.setDrawColor(180);
    doc.line(margin, y - 4, 612 - margin, y - 4);
    y += 8;

    var body = meta.paragraphs.length ? meta.paragraphs : ['No text has been drafted for this document yet.'];
    body.forEach(function (para) { writeBlock(para, 10.5, 'normal', 8); });
    if (meta.ownerText) writeBlock(meta.ownerText, 9, 'italic', 0);

    var fileSafe = (meta.id + '-' + meta.title).toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
    doc.save(fileSafe.slice(0, 80) + '.pdf');
  }

  // ---- Print -------------------------------------------------------------
  function printOne(card) {
    card.classList.add('dt-print-target');
    document.body.classList.add('dt-printing-one');
    function cleanup() {
      card.classList.remove('dt-print-target');
      document.body.classList.remove('dt-printing-one');
      window.removeEventListener('afterprint', cleanup);
    }
    window.addEventListener('afterprint', cleanup);
    window.print();
    setTimeout(cleanup, 5000); // fallback in case afterprint never fires
  }

  // ---- Read aloud (one shared floating player) ---------------------------
  var reader = { voices: [] };

  function ttsPrefs() {
    try { return JSON.parse(localStorage.getItem('bbpac_tts_prefs') || '{}'); } catch (e) { return {}; }
  }
  function saveTtsPrefs() {
    var select = document.getElementById('dtVoiceSelect');
    var rate = document.getElementById('dtRate');
    localStorage.setItem('bbpac_tts_prefs', JSON.stringify({
      voiceName: select ? select.value : '',
      rate: rate ? rate.value : '1',
    }));
  }

  function guessGenderMark(name) {
    if (/zira|susan|samantha|karen|moira|tessa|victoria|allison|ava|kate|serena|female|joanna|salli|kimberly/i.test(name)) return '♀ ';
    if (/david|mark|alex|daniel|fred|male|tom|aaron|guy|matthew|justin|joey/i.test(name)) return '♂ ';
    return '';
  }

  function populateVoices() {
    if (!('speechSynthesis' in window)) return;
    reader.voices = window.speechSynthesis.getVoices();
    var select = document.getElementById('dtVoiceSelect');
    if (!select) return;
    var prefs = ttsPrefs();
    select.innerHTML = reader.voices.map(function (v) {
      return '<option value="' + v.name + '">' + guessGenderMark(v.name) + v.name + ' (' + v.lang + ')</option>';
    }).join('');
    if (prefs.voiceName && reader.voices.some(function (v) { return v.name === prefs.voiceName; })) {
      select.value = prefs.voiceName;
    }
    var rateInput = document.getElementById('dtRate');
    if (prefs.rate && rateInput) rateInput.value = prefs.rate;
  }

  function buildReaderBar() {
    if (document.getElementById('dtReaderBar')) return;
    var bar = document.createElement('div');
    bar.id = 'dtReaderBar';
    bar.innerHTML =
      '<div class="dt-row"><span class="dt-now" id="dtReaderNow">Nothing playing</span></div>' +
      '<div class="dt-row">' +
        '<select id="dtVoiceSelect"></select>' +
        '<span class="dt-rate">Speed <input type="range" id="dtRate" min="0.6" max="1.6" step="0.1" value="1"></span>' +
        '<button type="button" id="dtPlayPause" title="Play/Pause"><i class="fas fa-play"></i></button>' +
        '<button type="button" class="dt-close" id="dtStop" title="Stop">✕</button>' +
      '</div>' +
      '<div class="dt-note">Voices come from your own browser/device. A custom cloned voice is a planned future upgrade.</div>';
    document.body.appendChild(bar);

    populateVoices();
    if ('speechSynthesis' in window) window.speechSynthesis.onvoiceschanged = populateVoices;

    document.getElementById('dtVoiceSelect').addEventListener('change', saveTtsPrefs);
    document.getElementById('dtRate').addEventListener('change', saveTtsPrefs);
    document.getElementById('dtPlayPause').addEventListener('click', togglePlayPause);
    document.getElementById('dtStop').addEventListener('click', stopReading);
  }

  function setPlayIcon(playing) {
    var btn = document.getElementById('dtPlayPause');
    if (btn) btn.innerHTML = playing ? '<i class="fas fa-pause"></i>' : '<i class="fas fa-play"></i>';
  }

  function startReading(meta) {
    if (!('speechSynthesis' in window)) {
      alert('Your browser does not support reading text aloud. Try Chrome, Edge, or Safari.');
      return;
    }
    buildReaderBar();
    window.speechSynthesis.cancel();
    var text = meta.title + '. ' + (meta.paragraphs.join(' ') || 'No text has been drafted for this document yet.');
    var utt = new SpeechSynthesisUtterance(text);
    var select = document.getElementById('dtVoiceSelect');
    var prefs = ttsPrefs();
    var wanted = (select && select.value) || prefs.voiceName;
    var chosen = null;
    for (var i = 0; i < reader.voices.length; i++) {
      if (reader.voices[i].name === wanted) { chosen = reader.voices[i]; break; }
    }
    if (chosen) utt.voice = chosen;
    utt.rate = Number(document.getElementById('dtRate').value) || 1;
    utt.onend = function () {
      setPlayIcon(false);
      var now = document.getElementById('dtReaderNow');
      if (now) now.textContent = 'Finished: ' + meta.id;
    };
    window.speechSynthesis.speak(utt);
    document.getElementById('dtReaderBar').classList.add('open');
    document.getElementById('dtReaderNow').textContent = 'Reading: ' + meta.id + ' — ' + meta.title;
    setPlayIcon(true);
  }

  function togglePlayPause() {
    if (!('speechSynthesis' in window)) return;
    if (window.speechSynthesis.speaking && !window.speechSynthesis.paused) {
      window.speechSynthesis.pause();
      setPlayIcon(false);
    } else if (window.speechSynthesis.paused) {
      window.speechSynthesis.resume();
      setPlayIcon(true);
    }
  }

  function stopReading() {
    if ('speechSynthesis' in window) window.speechSynthesis.cancel();
    setPlayIcon(false);
    var bar = document.getElementById('dtReaderBar');
    if (bar) bar.classList.remove('open');
  }

  document.addEventListener('click', function (e) {
    var pdfBtn = e.target.closest('[data-dt-pdf]');
    var printBtn = e.target.closest('[data-dt-print]');
    var listenBtn = e.target.closest('[data-dt-listen]');
    if (pdfBtn) downloadPdf(cardMeta(pdfBtn.closest('.doc-card, .tmpl-card')));
    if (printBtn) printOne(printBtn.closest('.doc-card, .tmpl-card'));
    if (listenBtn) startReading(cardMeta(listenBtn.closest('.doc-card, .tmpl-card')));
  });

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', injectToolbars);
  } else {
    injectToolbars();
  }
})();

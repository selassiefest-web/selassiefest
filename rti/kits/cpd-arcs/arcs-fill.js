// Fills CPD's ARCS Partnership Proposal PDF with the kit's answers.
// Works in the browser (window.ArcsFill) and in Node (module.exports). Needs pdf-lib 1.17.1.
(function (root) {
  var MIN_SIZE = 6;

  function boxOf(field) {
    var w = field.acroField.getWidgets()[0];
    var r = w.getRectangle();
    var bs = w.getBorderStyle && w.getBorderStyle();
    var bw = bs ? bs.getWidth() : 0;
    var pad = bw + 1;
    return { width: r.width - pad * 2, height: r.height - pad * 2 };
  }

  function defaultSize(field) {
    var da = field.acroField.getDefaultAppearance() || "";
    var m = da.match(/([\d.]+)\s+Tf/);
    return m ? parseFloat(m[1]) : 10;
  }

  // Largest font size (from the field's own size down to MIN_SIZE) at which `text`
  // fits inside the field box. Returns {size, fits}.
  function fit(P, font, text, box, multiline, maxSize) {
    if (!text) return { size: maxSize, fits: true };
    for (var s = maxSize; s >= MIN_SIZE; s -= 0.25) {
      if (multiline) {
        var lay = P.layoutMultilineText(text, {
          alignment: P.TextAlignment.Left, fontSize: s, font: font,
          bounds: { x: 0, y: 0, width: box.width, height: 100000 }
        });
        if (lay.lines.length * lay.lineHeight <= box.height + 0.5) return { size: s, fits: true };
      } else if (font.widthOfTextAtSize(text, s) <= box.width - 2) {
        return { size: s, fits: true };
      }
    }
    return { size: MIN_SIZE, fits: false };
  }

  // CPD's list boxes scroll, so on paper the selected rows can sit out of view.
  // This appearance shows only the selected options, highlighted, in as many
  // columns as gives the largest readable type. Acrobat redraws the full list
  // if someone clicks into the box, and the selections stay.
  function selectedOnlyAppearance(P, picks, maxSize) {
    return function (field, widget, font) {
      var r = widget.getRectangle();
      var W = r.width - 2, H = r.height - 2;
      var best = null;
      for (var cols = 1; cols <= 3; cols++) {
        var rows = Math.ceil(picks.length / cols);
        var colW = W / cols;
        var size = Math.min(maxSize, (H / rows) / 1.2);
        picks.forEach(function (t) {
          var w = font.widthOfTextAtSize(t, 1) + 3 / Math.max(size, 1);
          size = Math.min(size, (colW - 3) / w);
        });
        if (!best || size > best.size) best = { cols: cols, rows: rows, colW: colW, size: size };
      }
      var lineH = H / best.rows;
      var fontSize = Math.min(best.size, lineH / 1.2);
      var ops = [P.pushGraphicsState()];
      picks.forEach(function (t, i) {
        var c = Math.floor(i / best.rows), row = i % best.rows;
        var x = 1 + c * best.colW, yTop = r.height - 1 - row * lineH;
        ops.push(
          P.setFillingRgbColor(0.6, 0.757, 0.855),
          P.rectangle(x + 0.5, yTop - lineH + 0.5, best.colW - 1, lineH - 1),
          P.fill(),
          P.beginText(),
          P.setFillingRgbColor(0, 0, 0),
          P.setFontAndSize(font.name, fontSize),
          P.moveText(x + 2, yTop - lineH + (lineH - fontSize) / 2 + fontSize * 0.22),
          P.showText(font.encodeText(t)),
          P.endText()
        );
      });
      ops.push(P.popGraphicsState());
      return ops;
    };
  }

  function todayString(fmt, d) {
    d = d || new Date();
    var y = fmt === "m/d/yy" ? String(d.getFullYear()).slice(2) : String(d.getFullYear());
    return (d.getMonth() + 1) + "/" + d.getDate() + "/" + y;
  }

  // Open the blank form and return the field geometry the page needs to measure text live.
  async function inspect(P, pdfBytes) {
    var pdf = await P.PDFDocument.load(pdfBytes);
    var font = await pdf.embedFont(P.StandardFonts.Helvetica);
    var form = pdf.getForm();
    var geo = {};
    form.getFields().forEach(function (f) {
      var name = f.getName();
      if (f instanceof P.PDFTextField) {
        geo[name] = { box: boxOf(f), size: defaultSize(f), multiline: f.isMultiline() };
      }
    });
    return { font: font, geo: geo };
  }

  // values: {key: string | string[]}; fields: ARCS.FIELDS.
  // Returns {bytes, report: [{key, label, size, fits}]}.
  async function fill(P, pdfBytes, fields, values) {
    var pdf = await P.PDFDocument.load(pdfBytes);
    var font = await pdf.embedFont(P.StandardFonts.Helvetica);
    var form = pdf.getForm();
    var report = [];

    fields.forEach(function (fd) {
      var v = values[fd.key];
      if (fd.kind === "radio") {
        var g = form.getRadioGroup(fd.pdf);
        if (v) g.select(v); else g.clear();
      } else if (fd.kind === "select") {
        var dd = form.getDropdown(fd.pdf);
        if (v) dd.select(v); else dd.clear();
      } else if (fd.kind === "multi") {
        var lb = form.getOptionList(fd.pdf);
        var picks = (v || []).filter(function (o) { return fd.options.indexOf(o) >= 0; });
        if (picks.length) lb.select(picks); else lb.clear();
      } else {
        var tf = form.getTextField(fd.pdf);
        var text = String(v == null ? "" : v).trim();
        if (fd.kind === "date" && (text === "" || text.toLowerCase() === "auto")) text = todayString(fd.fmt);
        var multiline = tf.isMultiline();
        var res = fit(P, font, text.replace(/\s+/g, " "), boxOf(tf), multiline, defaultSize(tf));
        tf.setText(text ? text.replace(/\s+/g, " ") : undefined);
        tf.setFontSize(res.size);
        report.push({ key: fd.key, label: fd.label, size: res.size, fits: res.fits });
      }
    });

    form.updateFieldAppearances(font);
    fields.forEach(function (fd) {
      if (fd.kind !== "multi") return;
      var picks = (values[fd.key] || []).filter(function (o) { return fd.options.indexOf(o) >= 0; });
      if (!picks.length) return;
      var lb = form.getOptionList(fd.pdf);
      lb.updateAppearances(font, selectedOnlyAppearance(P, picks, defaultSize(lb)));
    });
    var bytes = await pdf.save();
    return { bytes: bytes, report: report };
  }

  var api = { fit: fit, fill: fill, inspect: inspect, todayString: todayString, MIN_SIZE: MIN_SIZE };
  if (typeof module !== "undefined" && module.exports) module.exports = api;
  else root.ArcsFill = api;
})(typeof window !== "undefined" ? window : globalThis);

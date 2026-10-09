"""Printable Rainbow DJ Lab forms: dj-lab/assets/forms/<name>.html + .pdf.

Fill-in forms list their fields as writing lines; consent forms and the code
of conduct reuse the exact wording from dj-lab/enroll/forms/<name>.md (the
"Full consent wording" section, or Parts 1-2 of the code), so the paper and
online versions never drift. PDFs are printed with headless Microsoft Edge.

    python dj-lab/_build/build_forms.py
"""
import io, os, re, html, subprocess
import markdown

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "assets", "forms")
EDGE = r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"

CHILD = [("Child's first name", 2), ("Last initial", 1), ("Age", 1)]
GUARD = [("Parent/guardian full name", 2), ("Mobile phone", 1), ("Email", 2)]
PERSON3 = lambda title, n: [("__h__", title)] + sum(([("Name", 2), ("Relationship", 1), ("Phone", 1)] for _ in range(n)), [])

FORMS = {
  "registration": {"title": "Registration", "fields": [("__h__", "Child")] + CHILD +
      [("Age group (circle): Little DJs 5-7 / Junior DJs 8-11 / Teen DJs 12-17 / Empress Decks / Grown-Up & Elder", 4),
       ("How does your child learn best? Anything the coach should know?", 4)] + [("__h__", "Parent or guardian")] + GUARD +
      [("Class code (if you have one)", 1)],
      "wording": "Guardian permission statement", "checks": [
        "I am this child's parent or legal guardian and give permission for them to take part in the Rainbow DJ Lab.",
        "We have read and agree to the family and child code of conduct.",
        "I consent to the in-class app recording my child's class activity, as described in the digital tracking consent.",
        "Email me a short recap after each class (optional)."],
      "note": "Also complete: Emergency Contacts, Medical & Allergy, and Authorized Pickup. Optional: Media Consent, Performance Consent."},
  "emergency-contacts": {"title": "Emergency Contacts", "fields": [("__h__", "Child")] + CHILD + PERSON3("Emergency contact 1 (required, not the parent/guardian)", 1) + PERSON3("Emergency contact 2", 1)},
  "medical-allergy": {"title": "Medical & Allergy", "fields": [("__h__", "Child")] + CHILD + [("__h__", "Health"),
       ("Allergies (food, insect, medicine, latex). Write NONE if none.", 4), ("Reaction and what to do", 4),
       ("Epinephrine auto-injector? (circle) YES / NO. If yes, attach a Food Allergy & Anaphylaxis Emergency Care Plan signed by your child's doctor.", 4),
       ("Asthma inhaler or other rescue medicine? Describe.", 4), ("Other medical needs (seizures, diabetes, other)", 4),
       ("Medicine to be given during class (name, dose, time). Requires the Lab's medication authorization; medicine must be in its original pharmacy container.", 4),
       ("Doctor's name and phone (optional)", 4)]},
  "authorized-pickup": {"title": "Authorized Pickup", "fields": [("__h__", "Child")] + CHILD + PERSON3("Adults who may pick up my child (photo ID checked every time)", 4) +
       [("__h__", "Court orders"), ("Is there a custody or court order we must follow? Describe and attach a copy.", 4)],
      "checks": ["My child may sign out and leave on their own at the end of class. (For children 11 and under we strongly recommend an adult pickup. You may withdraw this permission at any time, in writing.)"]},
  "media-consent": {"title": "Media Consent", "fields": [("__h__", "Child")] + CHILD, "wording": "Full consent wording"},
  "performance-consent": {"title": "Performance Consent", "fields": [("__h__", "Child")] + CHILD, "wording": "Full consent wording"},
  "digital-tracking-consent": {"title": "Digital Tracking Consent", "fields": [("__h__", "Child")] + CHILD, "wording": "Full consent wording"},
  "code-of-conduct": {"title": "Code of Conduct", "fields": [("__h__", "Child")] + CHILD, "wording": "CODE"},
}


def md_sections(path):
    text = io.open(path, encoding="utf-8").read()
    text = re.sub(r"^---.*?---\s*", "", text, flags=re.S)
    parts = re.split(r"(?m)^## ", text)
    out = {}
    for p in parts[1:]:
        head, _, body = p.partition("\n")
        out[head.strip()] = body
    return out


def wording_html(name, key):
    secs = md_sections(os.path.join(ROOT, "enroll", "forms", name + ".md"))
    if key == "CODE":
        body = "\n\n".join("## " + k + "\n" + v for k, v in secs.items() if k.startswith("Part "))
    else:
        k = next((k for k in secs if k.lower().startswith(key.lower())), None)
        body = secs.get(k, "") if k else ""
    h = markdown.markdown(body, extensions=["extra", "sane_lists"])
    return re.sub(r'<a href="[^"]*">(.*?)</a>', r"\1", h)  # paper: plain text, no links


def field_html(fields):
    rows, line = [], []
    for label, width in fields:
        if label == "__h__":
            if line: rows.append('<div class="row">%s</div>' % "".join(line)); line = []
            rows.append('<h3>%s</h3>' % html.escape(width)); continue
        cell = '<div class="fld" style="flex:%d"><div class="ln"></div><span>%s</span></div>' % (width, html.escape(label))
        if width >= 4:
            if line: rows.append('<div class="row">%s</div>' % "".join(line)); line = []
            rows.append('<div class="row"><div class="fld big"><span>%s</span><div class="box"></div></div></div>' % html.escape(label))
        else:
            line.append(cell)
            if sum(1 for _ in line) >= 3: rows.append('<div class="row">%s</div>' % "".join(line)); line = []
    if line: rows.append('<div class="row">%s</div>' % "".join(line))
    return "\n".join(rows)


TPL = """<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"><title>{title} | Rainbow DJ Lab form</title><meta name="robots" content="noindex">
<style>
@page {{ size: letter; margin: 0.55in 0.6in; }}
*{{box-sizing:border-box}} body{{font-family: Arial, Helvetica, sans-serif; color:#111; font-size:10.5pt; line-height:1.4; margin:0}}
.hd{{display:flex; align-items:center; gap:12px; border-bottom:4px solid; border-image:linear-gradient(90deg,#E0453A,#F08A24,#F2C230,#2E9E58,#1E8FBF,#3F48B8,#8E44AD) 1; padding-bottom:8px; margin-bottom:10px}}
.hd img{{width:40px; height:40px}} .hd h1{{font-size:17pt; margin:0}} .hd p{{margin:2px 0 0; font-size:8.5pt; color:#444}}
h2{{font-size:12pt; margin:14px 0 6px}} h3{{font-size:10.5pt; margin:12px 0 4px; text-transform:uppercase; letter-spacing:.06em; color:#333}}
.row{{display:flex; gap:14px; margin:6px 0}} .fld{{flex:1; min-width:0}} .fld .ln{{border-bottom:1px solid #222; height:20px}} .fld span{{font-size:8pt; color:#444}}
.fld.big span{{font-size:9pt; color:#222}} .box{{border:1px solid #444; height:46px; border-radius:4px; margin-top:2px}}
.check{{display:flex; gap:8px; margin:6px 0}} .check i{{flex:none; width:13px; height:13px; border:1.5px solid #111; margin-top:2px}}
.word{{font-size:9.5pt}} .word h2{{font-size:11pt}} .word h3{{font-size:10pt; text-transform:none; letter-spacing:0}}
.sig{{margin-top:16px; page-break-inside:avoid}} .note{{background:#F4F1EA; padding:6px 10px; border-radius:4px; font-size:9pt; margin:10px 0}}
.ft{{margin-top:14px; font-size:7.5pt; color:#555; border-top:1px solid #bbb; padding-top:6px}}
</style></head><body>
<div class="hd"><img src="../logo/rainbow-mark.svg" alt=""><div><h1>Rainbow DJ Lab &middot; {title}</h1><p>Ras Tafari Inc. &middot; 7700 S. Stony Island Ave., Chicago, IL 60649 &middot; Stephen Henry, President &middot; 414-909-3279 &middot; stephen@selassiefest.com</p></div></div>
<p class="note">Prefer online? Every form is part of one online registration at selassiefest.com/dj-lab/enroll/register.html. Paper copies are kept locked and are seen only by Lab coaches. Form version 2026-10-08.</p>
{fields}
{wording}
{checks}
{extra}
<div class="sig"><div class="row"><div class="fld" style="flex:3"><div class="ln"></div><span>Parent/guardian signature</span></div><div class="fld" style="flex:2"><div class="ln"></div><span>Printed name</span></div><div class="fld" style="flex:1"><div class="ln"></div><span>Date</span></div></div></div>
<div class="ft">Rainbow DJ Lab is a proposed program of Ras Tafari Inc., a 501(c)(3) nonprofit; no class runs until every launch requirement is met (selassiefest.com/dj-lab/governance/). Emergency: 911. Suspected abuse or neglect: Illinois DCFS Hotline 1-800-25-ABUSE (1-800-252-2873).</div>
</body></html>"""


def main():
    os.makedirs(OUT, exist_ok=True)
    for name, spec in FORMS.items():
        w = spec.get("wording")
        wh = ('<div class="word">%s</div>' % wording_html(name, w)) if w else ""
        if w and not re.sub(r"<[^>]+>", "", wh).strip():
            raise SystemExit("missing wording section for " + name)
        items = list(spec.get("checks", []))
        secs = md_sections(os.path.join(ROOT, "enroll", "forms", name + ".md"))
        for line in secs.get("The choices", "").splitlines():
            m = re.match(r"\s*- \[ \] (.*)", line)
            if m: items.append(re.sub(r"\*\*(.*?)\*\*", lambda mm: mm.group(1), m.group(1)))
        checks = "".join('<div class="check"><i></i><span>%s</span></div>' % html.escape(c) for c in items)
        page = TPL.format(title=html.escape(spec["title"]), fields=field_html(spec["fields"]), wording=wh,
                          checks=('<h3>Please check</h3>' + checks) if checks else "",
                          extra=('<p class="note">%s</p>' % html.escape(spec["note"])) if spec.get("note") else "")
        hp = os.path.join(OUT, name + ".html")
        io.open(hp, "w", encoding="utf-8").write(page)
        pdf = os.path.join(OUT, name + ".pdf")
        subprocess.run([EDGE, "--headless=new", "--disable-gpu", "--no-pdf-header-footer", "--virtual-time-budget=4000",
                        "--print-to-pdf=" + pdf, "file:///" + hp.replace("\\", "/")], capture_output=True)
        print(name, os.path.getsize(pdf) if os.path.exists(pdf) else "NO PDF")


if __name__ == "__main__":
    main()

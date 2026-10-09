"""Build the Rainbow DJ Lab family site: every dj-lab/**/*.md page becomes a
styled .html page beside it (index.md -> index.html), with shared header,
section navigation, status banner and footer.

    python dj-lab/_build/build.py

Repo documents (README, LICENSE, CONTRIBUTING, ...) stay Markdown only.
enroll/register.md renders to register-help.html because register.html is
the hand-built registration form.
"""
import io, os, re, html
import markdown

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
SKIP_FILES = {"README.md", "LICENSE", "CODE_OF_CONDUCT.md", "CONTRIBUTING.md", "SECURITY.md"}
SKIP_DIRS = {"_build", ".github", "live", "portal", "assets"}
RENAME = {"enroll/register.md": "enroll/register-help.html"}

SECTIONS = [
    ("about", "About", ["index", "curriculum", "curriculum-fast-track", "age-groups", "accessibility", "language-access", "instructors", "meet-the-coach", "independence", "community-accountability"]),
    ("enroll", "Enroll", ["index", "register", "schedule", "locations", "transportation-parking", "attendance-absence", "weather-cancellation", "communicable-disease", "exit-withdrawal", "faq", "forms/index"]),
    ("safety", "Safety", ["index", "youth-protection-policy", "enforcement", "staff-screening", "mandated-reporter-training", "substance-free-policy", "arrival-signout", "id-check-protocol", "impaired-parent-protocol", "lost-child-plan", "emergency-action-plan", "active-threat-lockdown", "incident-reporting", "medical-allergy-plan", "epinephrine-protocol", "medication-storage", "first-aid-cpr-roster", "lakefront-weather", "sunscreen-hydration", "restroom-supervision", "hearing-safety", "behavior-emotional-safety", "discipline-ladder", "cooldown-space", "peer-harm-protocol", "report-a-concern", "grievance-procedure"]),
    ("families", "Families", ["index", "handbook", "orientation", "open-door-policy", "session-contact", "feedback-loop", "weekly-digest", "mid-season-checkin", "references"]),
    ("privacy", "Privacy", ["index", "data-privacy-statement", "coppa-compliance", "third-party-vendors", "breach-notification", "retention-deletion", "parent-data-rights", "audit-log", "photos-recordings"]),
    ("performing", "Performing", ["index", "pathway", "opt-out", "event-day-supervision", "sound-crowd-exposure", "transportation", "stage-freeze-protocol", "graduation-guarantee"]),
    ("kids", "For kids", ["index", "first-day", "rules-for-me", "if-you-feel-unsafe", "data-mistakes", "bathroom-and-buddy", "who-to-talk-to", "promises-to-you"]),
    ("journey", "The journey", ["index", "before-day-one", "week-1", "week-4", "week-8", "graduation", "after"]),
    ("governance", "Governance", ["index", "board", "conflict-of-interest", "whistleblower", "financial-transparency", "mou-park-district", "park-district-permits", "data-sharing-agreement-selassiefest", "qality-vendor-agreement", "sole-source-justification-qality", "equipment-use-agreement-qality", "insurance-certificate", "501c3-letter", "advisory-council-vote", "enforcement-self-accountability", "annual-safety-review", "community-accountability-report"]),
]
FORMS_ORDER = ["index", "registration", "emergency-contacts", "medical-allergy", "authorized-pickup", "media-consent", "performance-consent", "digital-tracking-consent", "code-of-conduct"]
SECTION_COLOR = {"about": "--r5", "enroll": "--r4", "safety": "--r1", "families": "--r2", "privacy": "--r6", "performing": "--r7", "kids": "--r3", "journey": "--r4", "governance": "--r6"}


def read_md(path):
    text = io.open(path, encoding="utf-8").read()
    meta = {}
    m = re.match(r"^---\s*\n(.*?)\n---\s*\n", text, re.S)
    if m:
        for line in m.group(1).splitlines():
            if ":" in line:
                k, v = line.split(":", 1)
                meta[k.strip()] = v.strip().strip('"').strip("'")
        text = text[m.end():]
    return meta, text


def out_path(rel):
    if rel in RENAME:
        return RENAME[rel]
    return rel[:-3] + ".html"


def url_for(rel):
    o = out_path(rel)
    return "/dj-lab/" + (o[:-len("index.html")] if o.endswith("index.html") else o)


def collect():
    pages = {}
    for dirpath, dirnames, filenames in os.walk(ROOT):
        relroot = os.path.relpath(dirpath, ROOT).replace("\\", "/")
        top = relroot.split("/")[0]
        if top in SKIP_DIRS:
            dirnames[:] = []
            continue
        for fn in filenames:
            if not fn.endswith(".md") or (relroot == "." and fn in SKIP_FILES):
                continue
            rel = fn if relroot == "." else relroot + "/" + fn
            meta, body = read_md(os.path.join(dirpath, fn))
            pages[rel] = {"meta": meta, "body": body}
    return pages


def title_of(pages, rel, fallback):
    p = pages.get(rel)
    return (p and p["meta"].get("title")) or fallback


def nav_html(pages, current_section):
    items = ['<a href="/dj-lab/"%s>Home</a>' % (' aria-current="page"' if current_section == "" else "")]
    for key, label, _ in SECTIONS:
        items.append('<a href="/dj-lab/%s/"%s>%s</a>' % (key, ' aria-current="page"' if key == current_section else "", label))
    items.append('<a class="live" href="/dj-lab/live/">Live class</a>')
    return "".join(items)


def side_html(pages, section, rel):
    if not section:
        return ""
    sec = next(s for s in SECTIONS if s[0] == section)
    links = []
    for slug in sec[2]:
        r = "%s/%s.md" % (section, slug)
        if r not in pages:
            continue
        name = title_of(pages, r, slug.replace("-", " ").title())
        cur = ' aria-current="page"' if r == rel else ""
        links.append('<a href="%s"%s>%s</a>' % (url_for(r), cur, html.escape(name)))
        if section == "enroll" and slug == "forms/index":
            for f in FORMS_ORDER[1:]:
                fr = "enroll/forms/%s.md" % f
                if fr in pages:
                    links.append('<a class="sub" href="%s"%s>%s</a>' % (url_for(fr), ' aria-current="page"' if fr == rel else "", html.escape(title_of(pages, fr, f))))
    return '<nav class="side" aria-label="%s pages"><div class="lbl">%s</div>%s</nav>' % (sec[1], sec[1], "".join(links))


def crumbs(pages, section, rel, title):
    parts = ['<a href="/dj-lab/">Rainbow DJ Lab</a>']
    if section:
        sec = next(s for s in SECTIONS if s[0] == section)
        if not rel.endswith("/index.md") or rel.count("/") > 1:
            parts.append('<a href="/dj-lab/%s/">%s</a>' % (section, sec[1]))
        if rel.startswith("enroll/forms/") and not rel.endswith("forms/index.md"):
            parts.append('<a href="/dj-lab/enroll/forms/">Forms</a>')
    parts.append(html.escape(title))
    return " &rsaquo; ".join(parts)


def render(pages, rel, page, tpl):
    meta = page["meta"]
    section = rel.split("/")[0] if "/" in rel else ""
    title = meta.get("title") or "Rainbow DJ Lab"
    desc = meta.get("description") or ""
    md = markdown.Markdown(extensions=["extra", "sane_lists", "toc"], extension_configs={"toc": {"permalink": False}})
    body = md.convert(page["body"])
    # Links written as .md by mistake -> .html
    body = re.sub(r'href="(/dj-lab/[^"#]*?)\.md(#[^"]*)?"', lambda m: 'href="%s.html%s"' % (m.group(1), m.group(2) or ""), body)
    body = body.replace('href="/dj-lab/enroll/register.html"', 'href="/dj-lab/enroll/register.html"')
    if not re.match(r"\s*<h1", body):
        lede = ('<p class="lede">%s</p>\n' % html.escape(desc)) if desc else ""
        body = "<h1>%s</h1>\n%s%s" % (html.escape(title), lede, body)
    color = SECTION_COLOR.get(section, "--r5")
    return (tpl.replace("{{TITLE}}", html.escape(title))
               .replace("{{DESC}}", html.escape(desc))
               .replace("{{NAV}}", nav_html(pages, section))
               .replace("{{SIDE}}", side_html(pages, section, rel))
               .replace("{{CRUMBS}}", crumbs(pages, section, rel, title) if rel != "index.md" else "")
               .replace("{{BODY}}", body)
               .replace("{{SECCOLOR}}", color)
               .replace("{{KIDS}}", " kids" if section == "kids" else "")
               .replace("{{LAYOUT}}", "with-side" if section else "no-side"))


def main():
    tpl = io.open(os.path.join(os.path.dirname(__file__), "template.html"), encoding="utf-8").read()
    pages = collect()
    n = 0
    for rel, page in sorted(pages.items()):
        out = os.path.join(ROOT, out_path(rel))
        io.open(out, "w", encoding="utf-8", newline="\n").write(render(pages, rel, page, tpl))
        n += 1
    # Human-readable site map (the family site is noindex while proposed, so
    # there is no sitemap.xml for search engines).
    blocks = ['<h1>Site map</h1>\n<p class="lede">Every page of the Rainbow DJ Lab family site.</p>\n<ul><li><a href="/dj-lab/">Home</a></li><li><a href="/dj-lab/live/">Live class app</a></li><li><a href="/dj-lab/portal/">Portal</a></li><li><a href="/dj-lab/enroll/register.html">Interest list / registration</a></li></ul>']
    for key, label, order in SECTIONS:
        items = []
        for slug in order:
            r = "%s/%s.md" % (key, slug)
            if r in pages:
                items.append('<li><a href="%s">%s</a></li>' % (url_for(r), html.escape(title_of(pages, r, slug))))
            if key == "enroll" and slug == "forms/index":
                for fslug in FORMS_ORDER[1:]:
                    fr = "enroll/forms/%s.md" % fslug
                    if fr in pages:
                        items.append('<li style="margin-left:1.2em"><a href="%s">%s</a> (<a href="/dj-lab/assets/forms/%s.pdf">PDF</a>)</li>' % (url_for(fr), html.escape(title_of(pages, fr, fslug)), fslug))
        blocks.append("<h2>%s</h2>\n<ul>%s</ul>" % (label, "".join(items)))
    page = (tpl.replace("{{TITLE}}", "Site map").replace("{{DESC}}", "Every page of the Rainbow DJ Lab family site.")
               .replace("{{NAV}}", nav_html(pages, "")).replace("{{SIDE}}", "").replace("{{CRUMBS}}", '<a href="/dj-lab/">Rainbow DJ Lab</a> &rsaquo; Site map')
               .replace("{{BODY}}", "\n".join(blocks)).replace("{{SECCOLOR}}", "--r5").replace("{{KIDS}}", "").replace("{{LAYOUT}}", "no-side"))
    io.open(os.path.join(ROOT, "sitemap.html"), "w", encoding="utf-8", newline="\n").write(page)
    print("built", n, "pages + sitemap.html")


if __name__ == "__main__":
    main()

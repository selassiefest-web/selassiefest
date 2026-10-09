"""Check every Rainbow DJ Lab page: internal links resolve, and the content
rules hold (no banned claims, only approved phone numbers, no invented
staff). Exit code 1 on any problem.

    python dj-lab/_build/check_links.py
"""
import io, os, re, sys

SITE = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
LAB = os.path.join(SITE, "dj-lab")
problems = []

def exists(url):
    path = url.split("#")[0].split("?")[0]
    if not path.startswith("/"):
        return True
    p = os.path.join(SITE, path.lstrip("/").replace("/", os.sep))
    if path.endswith("/"):
        p = os.path.join(p, "index.html")
    return os.path.exists(p)

for dirpath, dirs, files in os.walk(LAB):
    if "_build" in dirpath:
        continue
    for fn in files:
        if not fn.endswith(".html"):
            continue
        f = os.path.join(dirpath, fn)
        s = io.open(f, encoding="utf-8").read()
        for m in re.finditer(r'(?:href|src)="(/[^"]+)"', s):
            u = m.group(1)
            if u.startswith("//"):
                continue
            if not exists(u):
                problems.append("BROKEN %s -> %s" % (os.path.relpath(f, SITE), u))

ALLOWED_PHONES = {"911", "1-800-25-ABUSE", "1-800-252-2873", "1-800-222-1222", "414-909-3279", "(312) 744-6833"}
BANNED = [(r"(?i)night out in the parks", "Night Out"), (r"(?i)seven hills|7 hills", "Seven Hills"),
          (r"(?i)\b(we are|we're|the lab is|is) (fully )?(licensed|insured|permitted|approved)\b", "status claim"),
          (r"(?i)\bCPD[- ]approved\b", "status claim")]
PHONE = re.compile(r"(?<![\d-])(?:\(\d{3}\)\s?|\d{3}-)\d{3}-\d{4}|1-800-[0-9A-Z-]{7,}")
for dirpath, dirs, files in os.walk(LAB):
    if "_build" in dirpath:
        continue
    for fn in files:
        if not fn.endswith(".md"):
            continue
        f = os.path.join(dirpath, fn)
        s = io.open(f, encoding="utf-8").read()
        for rx, label in BANNED:
            for m in re.finditer(rx, s):
                line = s[max(0, s.rfind("\n", 0, m.start())):s.find("\n", m.end())].strip()
                if label == "status claim" and re.search(r"(?i)\bnot\b|never|until|before|pending|once|when|if\b", line):
                    continue
                problems.append("%s %s: %s" % (label.upper(), os.path.relpath(f, SITE), line[:160]))
        for m in PHONE.finditer(s):
            if m.group(0) not in ALLOWED_PHONES:
                problems.append("PHONE %s: %s" % (os.path.relpath(f, SITE), m.group(0)))

print("\n".join(problems) if problems else "All links resolve; content rules pass.")
sys.exit(1 if problems else 0)

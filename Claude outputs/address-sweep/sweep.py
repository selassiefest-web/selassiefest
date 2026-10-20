"""Replace Ras Tafari Inc's two outdated addresses with the current office.

Current:  1401 E. 71st St., Chicago, IL 60619
Outdated: 7700 S. Stony Island Ave., Chicago, IL 60649   (second office)
          765 E 154th St, South Holland, IL 60473          (founding address)

Usage:  python sweep.py            dry run (prints counts, changes nothing)
        python sweep.py --apply    writes the changes
Only exact, full-address strings are replaced. Files in SKIP are left alone
because they describe the old address on purpose (legal records, other entities,
or text that needs a hand edit).
"""
import subprocess, sys, re, pathlib

ROOT = pathlib.Path(r"C:\Users\mkepr\Documents\GitHub\selassiefest")
NEW = "1401 E. 71st St., Chicago, IL 60619"

RULES = [
    ("7700 S. Stony Island Ave., Chicago, IL 60649", NEW),
    ("7700 S. Stony Island Ave.<br>Chicago, IL 60649", "1401 E. 71st St.<br>Chicago, IL 60619"),
    ("765 E 154th St, South Holland, IL 60473", NEW),
    ("765 E. 154th St., South Holland, IL 60473", NEW),
    ("765 E. 154th Street, South Holland, Illinois 60473", "1401 E. 71st Street, Chicago, Illinois 60619"),
    ("765 E 154th St. South Holland, IL 60473", NEW),
    ("765 E 154th St<br>South Holland, IL 60473", "1401 E. 71st St.<br>Chicago, IL 60619"),
]

# Left alone on purpose (prefix match on repo-relative posix path).
SKIP = (
    "ventures/", "the-yawd/", "caribbean-cultural-center/",   # other entity (Yawd LLC)
    "supabase/",                                              # live-DB seed data
    "Claude outputs/",                                        # generated letters, own review
    ".github/", ".git/",
    "organization/grants/dcase-cityarts-nap.html",            # hand edit: eligibility box
    "full-spectrum/arcs-status.html",
    "rti/kits/",                                              # factual notes about old records
    "legal/nonprofit-disclosure.html",
    "bbpac",                                                  # separate project
)

TEXT_EXT = {".html", ".md", ".js", ".py", ".txt", ".css", ".json", ".xml", ".svg", ""}

apply = "--apply" in sys.argv
files = subprocess.run(["git", "ls-files"], cwd=ROOT, capture_output=True, text=True,
                       encoding="utf8").stdout.splitlines()
changed, total = 0, 0
for rel in files:
    if rel.startswith(SKIP) or pathlib.Path(rel).suffix.lower() not in TEXT_EXT:
        continue
    p = ROOT / rel
    try:
        s = p.read_bytes().decode("utf8")
    except Exception:
        continue
    n = s
    count = 0
    for old, new in RULES:
        c = n.count(old)
        if c:
            n = n.replace(old, new)
            count += c
    if count:
        changed += 1
        total += count
        if apply:
            p.write_bytes(n.encode("utf8"))
        print(f"{count:3d}  {rel}")
print(f"\n{'APPLIED' if apply else 'DRY RUN'}: {total} replacements in {changed} files")

"""Generates a personalized "Proud Plates for Purpose Partner" badge for
every restaurant that has a logo on file, by compositing that restaurant's
own logo onto the shared template (same background/gold text every time,
only the logo circle changes).

Since restaurant logos vary wildly in shape and background (transparent,
white, colored), each logo is placed on a uniform white medallion with a
thin gold ring first, rather than pasted directly onto the template -- this
keeps every restaurant's badge looking like the same consistent design
regardless of what their own logo looks like.

Jerky Jerk is a special case: its badge was hand-produced already (the
original sample this template was derived from) and is used as-is rather
than regenerated through this pipeline.

Usage:
    python generate-partner-badges.py

Writes generated badges to ./partner_badges/<slug>.jpg (reviewable before
upload) and a partner_badges/upload.sh + partner_badges/badge_paths.sql pair
-- inspect, then run the upload script and apply the SQL, same two-step
pattern as sync-plates-for-purpose-restaurants.py.
"""
import os
import io
import json
import urllib.request
from collections import deque
from PIL import Image, ImageDraw

SCRIPT_DIR = os.path.dirname(__file__)
TEMPLATE_PATH = r"C:\Users\mkepr\Documents\GitHub\the-legacy_images\Plates-for-Purpose-Partner-Template-4x5.png"
JERKY_JERK_SAMPLE_PATH = r"C:\Users\mkepr\Documents\GitHub\the-legacy_images\Plates-for-Purpose-Jerky-Jerk-Partner-Sample-4x5-v8.png"
OUT_DIR = os.path.join(SCRIPT_DIR, "partner_badges")

SUPABASE_URL = "https://xdjbgcqaynnzykrglgnf.supabase.co"
ANON_KEY = "sb_publishable_1B4Musk5YF23XHb_BEOiTA_w1DGM5P4"
LOGOS_BASE = f"{SUPABASE_URL}/storage/v1/object/public/plates-for-purpose-logos"

# Measured by diffing the blank template against the Jerky Jerk sample.
CIRCLE_CENTER = (1079, 1912)
CIRCLE_DIAMETER = 630
GOLD = (229, 169, 60)


def fetch_restaurants():
    req = urllib.request.Request(
        f"{SUPABASE_URL}/rest/v1/plates_for_purpose_restaurants_public?select=slug,business_name,logo_path&logo_path=not.is.null",
        headers={"apikey": ANON_KEY, "Authorization": f"Bearer {ANON_KEY}"},
    )
    with urllib.request.urlopen(req) as resp:
        return json.load(resp)


def strip_flat_background(logo_im, tolerance=18):
    """Some source logos have zero real alpha transparency (fully opaque,
    including a baked-in checkerboard where a "transparent" preview got
    flattened into actual pixels instead of real alpha) -- e.g. the bakery's
    logo. Flood-fills from the four corners over near-matching colors and
    makes only that connected background region transparent, leaving
    anything fully enclosed by real logo content (like a white ring inside
    the emblem) alone since flood fill never reaches it.
    """
    im = logo_im.convert("RGBA")
    w, h = im.size
    px = im.load()

    visited = bytearray(w * h)
    q = deque()

    def seed(x, y):
        idx = y * w + x
        if not visited[idx]:
            visited[idx] = 1
            q.append((x, y))

    for x in range(w):
        seed(x, 0)
        seed(x, h - 1)
    for y in range(h):
        seed(0, y)
        seed(w - 1, y)

    while q:
        x, y = q.popleft()
        r, g, b, a = px[x, y]
        px[x, y] = (r, g, b, 0)
        for nx, ny in ((x + 1, y), (x - 1, y), (x, y + 1), (x, y - 1)):
            if 0 <= nx < w and 0 <= ny < h:
                nidx = ny * w + nx
                if visited[nidx]:
                    continue
                nr, ng, nb, na = px[nx, ny]
                if abs(nr - r) <= tolerance and abs(ng - g) <= tolerance and abs(nb - b) <= tolerance:
                    visited[nidx] = 1
                    q.append((nx, ny))
    return im


def make_medallion(logo_im):
    d = CIRCLE_DIAMETER
    medallion = Image.new("RGBA", (d, d), (0, 0, 0, 0))
    draw = ImageDraw.Draw(medallion)
    draw.ellipse((0, 0, d - 1, d - 1), fill=(255, 255, 255, 255))
    draw.ellipse((4, 4, d - 5, d - 5), outline=GOLD + (255,), width=8)

    # Fit the logo within 80% of the circle, preserving aspect ratio and
    # transparency, centered.
    inner = int(d * 0.8)
    logo = logo_im.convert("RGBA")
    scale = min(inner / logo.width, inner / logo.height)
    new_size = (max(1, round(logo.width * scale)), max(1, round(logo.height * scale)))
    logo = logo.resize(new_size, Image.LANCZOS)
    pos = ((d - new_size[0]) // 2, (d - new_size[1]) // 2)
    medallion.paste(logo, pos, logo)

    # Circular-crop the medallion itself so nothing (incl. a logo's own
    # square corners) pokes out past the gold ring.
    mask = Image.new("L", (d, d), 0)
    ImageDraw.Draw(mask).ellipse((0, 0, d - 1, d - 1), fill=255)
    medallion.putalpha(mask)
    return medallion


def main():
    os.makedirs(OUT_DIR, exist_ok=True)
    template = Image.open(TEMPLATE_PATH).convert("RGB")

    restaurants = fetch_restaurants()
    sql_lines = []
    generated = []

    for r in restaurants:
        slug = r["slug"]
        if slug in ("jerky-jerk", "jerky-jerk-rolling-meadows"):
            continue  # handled separately below
        try:
            with urllib.request.urlopen(f"{LOGOS_BASE}/{r['logo_path']}") as resp:
                logo_bytes = resp.read()
            logo_im = Image.open(io.BytesIO(logo_bytes))
            alpha = logo_im.convert("RGBA").getchannel("A")
            if alpha.getextrema() == (255, 255):
                # No real transparency at all -- likely a flattened
                # "preview checkerboard" background; strip it.
                logo_im = strip_flat_background(logo_im)
        except Exception as e:
            print(f"SKIP {slug}: failed to fetch logo ({e})")
            continue

        medallion = make_medallion(logo_im)
        badge = template.copy().convert("RGBA")
        paste_pos = (CIRCLE_CENTER[0] - CIRCLE_DIAMETER // 2, CIRCLE_CENTER[1] - CIRCLE_DIAMETER // 2)
        badge.paste(medallion, paste_pos, medallion)
        badge = badge.convert("RGB")

        out_path = os.path.join(OUT_DIR, f"{slug}.jpg")
        badge.save(out_path, "JPEG", quality=88, optimize=True)
        generated.append(slug)
        sql_lines.append(f"update plates_for_purpose_restaurants set badge_path = '{slug}.jpg' where slug = '{slug}';")
        print(f"generated {slug}.jpg ({r['business_name']})")

    # Jerky Jerk: use the hand-produced sample directly, no compositing.
    jj_sample = Image.open(JERKY_JERK_SAMPLE_PATH).convert("RGB")
    jj_out = os.path.join(OUT_DIR, "jerky-jerk.jpg")
    jj_sample.save(jj_out, "JPEG", quality=90, optimize=True)
    for slug in ("jerky-jerk", "jerky-jerk-rolling-meadows"):
        sql_lines.append(f"update plates_for_purpose_restaurants set badge_path = 'jerky-jerk.jpg' where slug = '{slug}';")
    generated.append("jerky-jerk (from hand-produced sample)")

    with open(os.path.join(OUT_DIR, "badge_paths.sql"), "w", encoding="utf-8") as f:
        f.write("\n".join(sql_lines) + "\n")

    with open(os.path.join(OUT_DIR, "upload.sh"), "w", encoding="utf-8", newline="\n") as f:
        f.write("#!/bin/bash\nset -e\ncd \"$(dirname \"$0\")\"\n")
        f.write('for f in *.jpg; do\n')
        f.write('  supabase storage cp "$f" "ss:///plates-for-purpose-badges/$f" --linked --experimental --workdir "../.."\n')
        f.write('done\n')

    print(f"\n{len(generated)} badges generated in {OUT_DIR}")
    print("Review them, then:")
    print(f"  bash {os.path.join(OUT_DIR, 'upload.sh')}")
    print(f"  supabase db query --linked -f {os.path.join(OUT_DIR, 'badge_paths.sql')}")


if __name__ == "__main__":
    main()

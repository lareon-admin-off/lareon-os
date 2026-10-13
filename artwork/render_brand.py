#!/usr/bin/env python3
"""Placeholder Lareon marks for the OS (logo, installer welcome image).

Replace by putting your real artwork at artwork/brand/lareon-logo.png
(square, 512x512 or larger, transparent background). The build uses that file
when it exists and only falls back to this generated mark otherwise.

Usage: render_brand.py OUTDIR
"""
import os
import sys

import numpy as np
from PIL import Image, ImageDraw, ImageFilter

ORANGE, VIOLET = np.array([0xff, 0x7c, 0x1f]), np.array([0xa3, 0x5c, 0xf5])


def logo(size=512):
    s = size * 4  # supersample
    y, x = np.mgrid[0:s, 0:s] / s
    t = np.clip((x + y) / 2, 0, 1)[..., None]
    rgb = ORANGE * (1 - t) + VIOLET * t
    mask = Image.new("L", (s, s), 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, s - 1, s - 1], radius=int(s * 0.23), fill=255)
    img = Image.fromarray(np.dstack([rgb, np.zeros((s, s))]).astype(np.uint8), "RGBA")
    img.putalpha(mask)
    # mountain + star glyph in white
    g = Image.new("L", (s, s), 0)
    gd = ImageDraw.Draw(g)
    gd.polygon([(s*.16, s*.76), (s*.42, s*.36), (s*.55, s*.54), (s*.64, s*.44), (s*.84, s*.76)], fill=255)
    cx, cy, r = s*.70, s*.27, s*.075
    pts = []
    for i in range(8):
        import math
        a = math.pi / 4 * i - math.pi / 2
        rr = r if i % 2 == 0 else r * 0.32
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    gd.polygon(pts, fill=255)
    white = Image.new("RGBA", (s, s), (255, 255, 255, 255))
    img = Image.composite(white, img, g)
    return img.resize((size, size), Image.LANCZOS)


def main():
    out = sys.argv[1]
    os.makedirs(out, exist_ok=True)
    logo(512).save(os.path.join(out, "lareon-logo.png"))
    print(os.path.join(out, "lareon-logo.png"))


if __name__ == "__main__":
    main()

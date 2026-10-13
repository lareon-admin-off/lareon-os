#!/usr/bin/env python3
"""Render the Lareon time-of-day wallpaper frames.

This is a direct port of artwork/kit/lareon-scene.js (the real scene from the
Lareon desktop app): the same mountain paths, snow caps, star field, base glow
and veil, laid out exactly as the browser lays them out at 1920x1080 CSS
pixels, drawn at 2x (3840x2160). Colours come from artwork/kit/palettes.css.

Plasma can only show still images, so the smooth blend between the four
palettes is pre-rendered: 4 pure palettes plus 7 in-between steps for each of
the 4 changes = 32 frames, f00.png ... f31.png, in this order around the day:

    f00 night  -> f08 dawn  -> f16 day  -> f24 dusk  -> (back to f00 night)

Usage: render_wallpapers.py OUTDIR [--width 3840 --height 2160] [--only 0,8,16,24]
"""
import argparse
import os
import re

import numpy as np
from PIL import Image, ImageDraw

HERE = os.path.dirname(os.path.abspath(__file__))
PALETTE_CSS = os.path.join(HERE, "kit", "palettes.css")
ORDER = ["night", "dawn", "day", "dusk"]
STEPS = 8  # frames per palette change (1 pure + 7 blends)
SS = 2     # supersampling for smooth mountain edges

# ---- scene geometry, copied from lareon-scene.js ----------------------------
# (viewBox height, layer height in vh, gradient vars, mountain path, snow paths, snow opacity)
LAYERS = [
    (520, 64, ("--m1a", "--m1b"),
     "M-60 520V330L90 250L190 310L330 170L450 290L560 230L700 330L830 120L950 260L1070 190L1200 300L1330 210L1500 330V520Z",
     ["M330 170L292 214L322 206L338 228L354 202L384 214Z",
      "M830 120L784 182L820 172L838 204L858 168L898 184Z"], 1.0),
    (420, 50, ("--m2a", "--m2b"),
     "M-60 420V300L100 220L220 290L360 190L500 300L610 250L740 330L880 210L1010 300L1140 230L1270 310L1400 250L1500 310V420Z",
     ["M360 190L330 224L352 218L366 236L380 216L402 224Z"], 0.6),
    (300, 34, ("--m3a", "--m3b"),
     "M-60 300V210L120 160L260 220L410 140L560 225L700 185L850 240L1000 170L1150 235L1290 190L1500 240V300Z",
     [], 1.0),
]


def parse_path(d):
    """Absolute M/L/V/H/Z only (all the scene uses) -> list of point lists."""
    shapes, pts, x, y = [], [], 0.0, 0.0
    for cmd, args in re.findall(r"([MLVHZ])([^MLVHZ]*)", d):
        nums = [float(n) for n in re.findall(r"-?\d+(?:\.\d+)?", args)]
        if cmd == "M":
            if pts:
                shapes.append(pts)
            x, y = nums[0], nums[1]
            pts = [(x, y)]
        elif cmd == "L":
            for i in range(0, len(nums), 2):
                x, y = nums[i], nums[i + 1]
                pts.append((x, y))
        elif cmd == "V":
            y = nums[0]
            pts.append((x, y))
        elif cmd == "H":
            x = nums[0]
            pts.append((x, y))
        elif cmd == "Z":
            shapes.append(pts)
            pts = []
    if pts:
        shapes.append(pts)
    return shapes


def stars():
    """Same pseudo-random star field as the JS (seed 11, 90 stars)."""
    seed = [11]

    def rnd():
        seed[0] = (seed[0] * 9301 + 49297) % 233280
        return seed[0] / 233280

    out = []
    for _ in range(90):
        x = round(rnd() * 100, 2)
        y = round(rnd() * 100, 2)
        r = round(0.4 + rnd() * 1.3, 2)
        rnd()  # animation delay
        o = round(0.4 + rnd() * 0.6, 2)
        rnd()  # animation duration
        out.append((x, y, r, o))
    return out


# ---- palettes ---------------------------------------------------------------
def parse_color(v):
    v = v.strip()
    if v.startswith("#"):
        h = v[1:]
        if len(h) == 3:
            h = "".join(c * 2 for c in h)
        return np.array([int(h[i:i + 2], 16) for i in (0, 2, 4)] + [255], float) / 255
    m = re.match(r"rgba?\(([^)]*)\)", v)
    if m:
        p = [float(n) for n in m.group(1).split(",")]
        a = p[3] if len(p) > 3 else 1.0
        return np.array([p[0] / 255, p[1] / 255, p[2] / 255, a])
    return float(v)


def load_palettes(path=PALETTE_CSS):
    css = open(path).read()
    pals = {}
    for name, body in re.findall(r"\.p-(\w+)\s*\{([^}]*)\}", css):
        pals[name] = {k.strip(): parse_color(v) for k, v in re.findall(r"(--[\w-]+)\s*:\s*([^;]+)", body)}
    return pals


def blend(a, b, t):
    return {k: a[k] * (1 - t) + b[k] * t for k in a}


def frame_palette(i, pals):
    """Palette for frame i of the 32-frame day cycle."""
    seg, step = divmod(i, STEPS)
    a, b = pals[ORDER[seg]], pals[ORDER[(seg + 1) % len(ORDER)]]
    return blend(a, b, step / STEPS)


# ---- drawing ------------------------------------------------------------------
def over(img, rgb, alpha):
    """Composite rgb (3,) or (h,w,3) with alpha (h,w) onto img in place."""
    a = alpha[..., None]
    img *= 1 - a
    img += np.asarray(rgb, np.float32) * a


def render(pal, W=3840, H=2160):
    dpr = W / 1920.0
    lw, lh = W / dpr, H / dpr  # CSS pixels
    img = np.zeros((H, W, 3), np.float32)
    ys = (np.arange(H) + 0.5) / dpr
    xs = (np.arange(W) + 0.5) / dpr

    # sky: linear-gradient(180deg, sky1, sky2 52%, sky3)
    t = ys / lh
    stops = [(0, pal["--sky1"]), (0.52, pal["--sky2"]), (1, pal["--sky3"])]
    sky = np.stack([np.interp(t, [s[0] for s in stops], [s[1][c] for s in stops]) for c in range(3)], -1)
    img[:] = sky[:, None, :]

    # stars: .stars is inset 0 0 35% 0, so they live in the top 65%
    star_op = float(pal["--star"])
    if star_op > 0.001:
        sw, sh = lw, lh * 0.65
        S = 4
        for x, y, r, o in stars():
            cx, cy, rr = x / 100 * sw * dpr, y / 100 * sh * dpr, r * dpr
            x0, y0 = int(cx - rr - 2), int(cy - rr - 2)
            x1, y1 = int(cx + rr + 3), int(cy + rr + 3)
            m = Image.new("L", ((x1 - x0) * S, (y1 - y0) * S), 0)
            ImageDraw.Draw(m).ellipse([(cx - rr - x0) * S, (cy - rr - y0) * S,
                                       (cx + rr - x0) * S, (cy + rr - y0) * S], fill=255)
            m = np.asarray(m.resize((x1 - x0, y1 - y0), Image.BOX), np.float32) / 255
            ya, yb, xa, xb = max(y0, 0), min(y1, H), max(x0, 0), min(x1, W)
            if ya >= yb or xa >= xb:
                continue
            over(img[ya:yb, xa:xb], (1, 1, 1), m[ya - y0:yb - y0, xa - x0:xb - x0] * o * star_op)

    # glow: radial-gradient(60% 70% at 50% 100%, glow, transparent 70%) in a
    # box 70vh tall at the bottom
    g = pal["--glow"]
    rx, ry = 0.6 * lw, 0.7 * (0.7 * lh)
    d = np.sqrt(((xs[None, :] - lw / 2) / rx) ** 2 + ((ys[:, None] - lh) / ry) ** 2)
    ga = np.clip(1 - d / 0.7, 0, 1) * g[3]
    ga[ys < lh * 0.3, :] = 0
    over(img, g[:3], ga.astype(np.float32))

    # mountain layers (.ly: left/right -4%, bottom 0, height Nvh;
    # svg preserveAspectRatio="xMidYMax slice")
    for vbh, vh, (ga_, gb_), path, snows, snow_op in LAYERS:
        bx0, bw, bh = -0.04 * lw, 1.08 * lw, vh / 100 * lh
        btop = lh - bh
        k = max(bw / 1440, bh / vbh)
        ox = bx0 + (bw - 1440 * k) / 2
        oy = btop + (bh - vbh * k)
        clip_row = int(round(btop * dpr))

        def mask_for(shapes):
            m = Image.new("L", (W * SS, H * SS), 0)
            dr = ImageDraw.Draw(m)
            for s in shapes:
                dr.polygon([((ox + px * k) * dpr * SS, (oy + py * k) * dpr * SS) for px, py in s], fill=255)
            m = np.asarray(m.resize((W, H), Image.BOX), np.float32) / 255
            m[:clip_row, :] = 0  # the layer box clips anything above it
            return m

        shapes = parse_path(path)
        allpts = [p for s in shapes for p in s]
        miny, maxy = min(p[1] for p in allpts), max(p[1] for p in allpts)
        # gradient runs from the path's top to its bottom (objectBoundingBox)
        tt = np.clip(((ys - oy) / k - miny) / (maxy - miny), 0, 1)
        ca, cb = pal[ga_], pal[gb_]
        col = (ca[:3][None, :] * (1 - tt[:, None]) + cb[:3][None, :] * tt[:, None])[:, None, :]
        alpha = (ca[3] * (1 - tt) + cb[3] * tt)[:, None]
        over(img, np.broadcast_to(col, img.shape).astype(np.float32), mask_for(shapes) * alpha)
        if snows:
            sn = pal["--snow"]
            m = mask_for([s for sp in snows for s in parse_path(sp)]) * sn[3] * snow_op
            over(img, sn[:3], m)

    # veil: linear-gradient(180deg, transparent 40%, bg 130%), opacity .55
    va = np.clip((ys / lh - 0.4) / 0.9, 0, 1) * 0.55
    over(img, pal["--bg"][:3], np.repeat(va[:, None], W, 1).astype(np.float32))

    return Image.fromarray((np.clip(img, 0, 1) * 255 + 0.5).astype(np.uint8))


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("outdir")
    ap.add_argument("--width", type=int, default=3840)
    ap.add_argument("--height", type=int, default=2160)
    ap.add_argument("--only", help="comma-separated frame numbers, e.g. 0,8,16,24")
    a = ap.parse_args()
    pals = load_palettes()
    os.makedirs(a.outdir, exist_ok=True)
    frames = [int(n) for n in a.only.split(",")] if a.only else range(len(ORDER) * STEPS)
    for i in frames:
        path = os.path.join(a.outdir, f"f{i:02d}.png")
        render(frame_palette(i, pals), a.width, a.height).save(path, compress_level=9)
        print(path, os.path.getsize(path) // 1024, "KB")


if __name__ == "__main__":
    main()

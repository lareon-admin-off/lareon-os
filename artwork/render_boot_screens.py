#!/usr/bin/env python3
"""Draw the Lareon boot screens' pictures (Plymouth and GRUB).

Plymouth's script language can't do layout or reliable fonts this early in
start-up, so the fixed parts of each screen are drawn here in Geist and the
boot-time script only places them and adds what changes (password dots,
progress, status messages). Logos are the exact brand-kit PNGs, placed (and
scaled) but never redrawn.

Usage: render_boot_screens.py PLYMOUTH_DIR GRUB_LIVE_DIR GRUB_INSTALLED_DIR WALLPAPER_NIGHT_PNG
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

HERE = os.path.dirname(os.path.abspath(__file__))
FONTS = os.path.join(HERE, "brand", "fonts")
LOGO = os.path.join(HERE, "brand", "logos", "lareon-icon-256.png")

BG = (0x13, 0x11, 0x1B)
PANEL = (0x1A, 0x18, 0x24)
PANEL2 = (0x21, 0x1E, 0x2D)
LINES = (0x2B, 0x28, 0x38)
TEXT = (0xEC, 0xE9, 0xF5)
MUTED = (0xA7, 0xA4, 0xBA)
FAINT = (0x74, 0x71, 0x8A)
ORANGE = (0xFF, 0x7C, 0x1F)
MAGENTA = (0xD9, 0x4F, 0xC4)
VIOLET = (0xA3, 0x5C, 0xF5)
CORAL = (0xFF, 0x4F, 0x7A)
S = 2  # draw at 2x and scale down, for smooth edges


def font(weight, size):
    return ImageFont.truetype(os.path.join(FONTS, f"Geist-{weight}.ttf"), size * S)


def mono(size):
    return ImageFont.truetype(os.path.join(FONTS, "GeistMono-Regular.ttf"), size * S)


def canvas(w, h):
    return Image.new("RGBA", (w * S, h * S), (0, 0, 0, 0))


def finish(img, path):
    w, h = img.size
    img.resize((w // S, h // S), Image.LANCZOS).save(path, optimize=True)


def text_center(d, cx, y, text, f, fill):
    w = d.textlength(text, font=f)
    d.text((cx - w / 2, y), text, font=f, fill=fill)


def wrap(d, text, f, width):
    words, lines, cur = text.split(), [], ""
    for w in words:
        t = (cur + " " + w).strip()
        if d.textlength(t, font=f) <= width:
            cur = t
        else:
            lines.append(cur)
            cur = w
    if cur:
        lines.append(cur)
    return lines


def paste_logo(img, x, y, size, opacity=1.0):
    logo = Image.open(LOGO).convert("RGBA").resize((size * S, size * S), Image.LANCZOS)
    if opacity < 1:
        a = logo.getchannel("A").point(lambda v: int(v * opacity))
        logo.putalpha(a)
    img.alpha_composite(logo, (int(x * S), int(y * S)))


def gradient_bar(w, h, radius=None):
    radius = h // 2 if radius is None else radius
    bar = Image.new("RGBA", (w, h))
    stops = [(0.0, ORANGE), (0.6, MAGENTA), (1.0, VIOLET)]
    px = bar.load()
    for x in range(w):
        t = x / max(w - 1, 1)
        for (p0, c0), (p1, c1) in zip(stops, stops[1:]):
            if p0 <= t <= p1:
                u = (t - p0) / (p1 - p0)
                c = tuple(int(c0[i] + (c1[i] - c0[i]) * u) for i in range(3))
        for y in range(h):
            px[x, y] = c + (255,)
    mask = Image.new("L", (w, h), 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, w - 1, h - 1], radius=radius, fill=255)
    bar.putalpha(mask)
    return bar


# ------------------------------------------------------------------ Plymouth
def error_screen(path, title, body, keys, footer):
    W, H = 760, 560
    img = canvas(W, H)
    d = ImageDraw.Draw(img)
    paste_logo(img, W / 2 - 60, 0, 120, opacity=0.55)
    text_center(d, W / 2 * S, 146 * S, title, font("SemiBold", 30), TEXT)
    y = 196
    fb = font("Regular", 16)
    for line in wrap(d, body, fb, 620 * S):
        text_center(d, W / 2 * S, y * S, line, fb, MUTED)
        y += 25
    # options panel
    top = y + 22
    px, pw, row = (W - 520) / 2, 520, 52
    d.rounded_rectangle([px * S, top * S, (px + pw) * S, (top + row * len(keys)) * S],
                        radius=10 * S, fill=PANEL + (255,), outline=LINES + (255,), width=S)
    fk, ft = mono(12.5), font("Regular", 15)
    for i, (key, label) in enumerate(keys):
        ry = top + i * row
        if i:
            d.line([px * S, ry * S, (px + pw) * S, ry * S], fill=LINES + (255,), width=S)
        if i == 0:
            d.rectangle([px * S + S, ry * S + S, (px + pw) * S - S, (ry + row) * S - S], fill=(0xFF, 0x7C, 0x1F, 30))
            d.rectangle([px * S, ry * S, (px + 3) * S, (ry + row) * S], fill=ORANGE + (255,))
        kx, ky, kw, kh = px + 18, ry + 12, 64, 28
        d.rounded_rectangle([kx * S, ky * S, (kx + kw) * S, (ky + kh) * S], radius=6 * S,
                            fill=PANEL2 + (255,), outline=LINES + (255,), width=S)
        text_center(d, (kx + kw / 2) * S, (ky + 6) * S, key, fk, TEXT)
        d.text(((kx + kw + 16) * S, (ry + 15) * S), label, font=ft, fill=TEXT)
    text_center(d, W / 2 * S, (top + row * len(keys) + 28) * S, footer, mono(12.5), FAINT)
    finish(img, path)


def message_screen(path, title, body):
    W, H = 760, 260
    img = canvas(W, H)
    d = ImageDraw.Draw(img)
    paste_logo(img, W / 2 - 60, 0, 120)
    text_center(d, W / 2 * S, 150 * S, title, font("SemiBold", 24), TEXT)
    text_center(d, W / 2 * S, 192 * S, body, font("Regular", 16), MUTED)
    finish(img, path)


def plymouth(out):
    os.makedirs(out, exist_ok=True)
    error_screen(os.path.join(out, "error-drive.png"),
                 "Lareon OS couldn’t start",
                 "A check of your drive found problems it needs to fix first. "
                 "Your files are usually fine. Repairing takes a few minutes.",
                 [("R", "Repair the drive and restart"), ("O", "Recovery options"),
                  ("S", "Shut down"), ("T", "Recovery terminal (advanced)")],
                 "Help: lareon.org/help")
    error_screen(os.path.join(out, "error-generic.png"),
                 "Lareon OS couldn’t start",
                 "Something went wrong while starting. Restarting often fixes it; "
                 "recovery options can start Lareon OS in a simpler way.",
                 [("R", "Restart"), ("O", "Recovery options"),
                  ("S", "Shut down"), ("T", "Recovery terminal (advanced)")],
                 "Help: lareon.org/help")
    message_screen(os.path.join(out, "repairing.png"), "Repairing your drive",
                   "This can take a few minutes. The computer restarts by itself.")
    message_screen(os.path.join(out, "updates.png"), "Installing updates",
                   "Don’t turn off your computer. It restarts by itself when it’s done.")
    # one coral line for a wrong disk password
    img = canvas(760, 30)
    d = ImageDraw.Draw(img)
    text_center(d, 380 * S, 4 * S, "That password didn’t unlock the disk. Try again.",
                font("Regular", 16), CORAL)
    finish(img, os.path.join(out, "wrong-password.png"))
    # progress bar pieces
    track = Image.new("RGBA", (380, 6), (0, 0, 0, 0))
    ImageDraw.Draw(track).rounded_rectangle([0, 0, 379, 5], radius=3, fill=LINES + (255,))
    track.save(os.path.join(out, "bar-track.png"))
    gradient_bar(380, 6).save(os.path.join(out, "bar-fill.png"))


# ------------------------------------------------------------------ GRUB
def nine_slice(out, prefix, fill, border=None, accent_left=None, size=12):
    """GRUB styled-box pieces: prefix_{nw,n,ne,w,c,e,sw,s,se}.png"""
    def save(name, w, h, draw):
        im = Image.new("RGBA", (w, h), (0, 0, 0, 0))
        draw(ImageDraw.Draw(im), w, h)
        im.save(os.path.join(out, f"{prefix}_{name}.png"))
    b = border
    save("c", 4, 4, lambda d, w, h: d.rectangle([0, 0, w, h], fill=fill))
    save("n", 4, 1, lambda d, w, h: d.rectangle([0, 0, w, h], fill=b or fill))
    save("s", 4, 1, lambda d, w, h: d.rectangle([0, 0, w, h], fill=b or fill))
    save("e", 1, 4, lambda d, w, h: d.rectangle([0, 0, w, h], fill=b or fill))
    save("w", 3 if accent_left else 1, 4,
         lambda d, w, h: d.rectangle([0, 0, w, h], fill=accent_left or b or fill))
    for corner in ("nw", "ne", "sw", "se"):
        wide = 3 if (accent_left and corner in ("nw", "sw")) else 1
        col = accent_left if (accent_left and corner in ("nw", "sw")) else (b or fill)
        save(corner, wide, 1, lambda d, w, h, c=col: d.rectangle([0, 0, w, h], fill=c))


def grub_theme(out, wallpaper, heading, sub, menu_top_pct, footer):
    os.makedirs(out, exist_ok=True)
    # background: the night scene, darkened toward the top like the mockups
    bg = Image.open(wallpaper).convert("RGB").resize((1920, 1080), Image.LANCZOS)
    shade = Image.new("RGBA", (1920, 1080))
    d = ImageDraw.Draw(shade)
    for y in range(1080):
        t = y / 1079
        a = int(255 * (0.92 - 0.55 * max(0.0, (t - 0.35) / 0.65)))
        d.line([0, y, 1919, y], fill=BG + (a,))
    bg = Image.alpha_composite(bg.convert("RGBA"), shade).convert("RGB")
    bg.save(os.path.join(out, "background.png"), optimize=True)
    # logo: the exact brand-kit mark, scaled
    Image.open(LOGO).convert("RGBA").resize((64, 64), Image.LANCZOS).save(os.path.join(out, "logo.png"))
    # menu box and selected item
    nine_slice(out, "menu", PANEL + (240,), border=LINES + (255,))
    nine_slice(out, "select", (0x3A, 0x22, 0x1A, 255), accent_left=ORANGE + (255,))
    with open(os.path.join(out, "theme.txt"), "w") as f:
        f.write(f"""# Lareon GRUB theme (made by artwork/render_boot_screens.py)
title-text: ""
desktop-image: "background.png"
desktop-image-scale-method: "crop"
desktop-color: "#13111b"
terminal-font: "Geist Regular 16"
terminal-box: "menu_*.png"

+ image {{
    left = 50%-380
    top = {menu_top_pct - 14}%
    width = 64
    height = 64
    file = "logo.png"
}}
+ label {{
    left = 50%-300
    top = {menu_top_pct - 14}%+4
    width = 680
    height = 36
    text = "{heading}"
    font = "Geist Bold 28"
    color = "#ece9f5"
}}
+ label {{
    id = "__timeout__"
    left = 50%-300
    top = {menu_top_pct - 14}%+40
    width = 680
    height = 22
    text = "{sub}"
    font = "Geist Regular 16"
    color = "#a7a4ba"
}}
+ boot_menu {{
    left = 50%-380
    top = {menu_top_pct}%
    width = 760
    height = 320
    item_font = "Geist Regular 18"
    selected_item_font = "Geist Bold 18"
    item_color = "#ece9f5"
    selected_item_color = "#ffffff"
    item_height = 52
    item_padding = 20
    item_spacing = 4
    icon_width = 0
    icon_height = 0
    menu_pixmap_style = "menu_*.png"
    selected_item_pixmap_style = "select_*.png"
    scrollbar = false
}}
+ label {{
    left = 50%-380
    top = {menu_top_pct}%+340
    width = 760
    height = 22
    text = "{footer}"
    font = "Geist Regular 14"
    color = "#74718a"
}}
""")


def main():
    ply, grub_live, grub_inst, night = sys.argv[1:5]
    plymouth(ply)
    grub_theme(grub_live, night, "Lareon OS @VERSION@",
               "Installing starts automatically in %d seconds",
               40, "Up and Down to choose  ·  Enter to start  ·  E to edit start-up options")
    grub_theme(grub_inst, night, "Recovery options",
               "Starting Lareon OS in %d seconds",
               40, "Up and Down to choose  ·  Enter to start  ·  E to edit start-up options")


if __name__ == "__main__":
    main()

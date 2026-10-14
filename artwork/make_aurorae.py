#!/usr/bin/env python3
"""Generate the Lareon window frame (Aurorae SVG theme).

    python3 artwork/make_aurorae.py packages/lareon-branding/usr/share/aurorae/themes

Writes Lareon/ (dark) and LareonLight/. The frame is the window colour of the
Lareon colour scheme, so title bar and app are one surface; corners are round,
the title is centred, buttons are soft round dots.
"""
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from make_plasma_theme import frame_svg  # noqa: E402

RADIUS = 10
THEMES = {
    "Lareon": dict(text="#ece9f5", muted="#a7a4ba", bg="#1a1824", line=0.16, tx=0.92, tx_in=0.5),
    "LareonLight": dict(text="#1d1832", muted="#4f4a68", bg="#ffffff", line=0.18, tx=0.92, tx_in=0.5),
}


def decoration(t):
    # Active frame and a slightly dimmer inactive one, plus a mask for blur/round corners.
    act = frame_svg(RADIUS, 0, 0, 0, 0, 1.0, t["line"])
    # frame_svg returns a full svg with elements named center/top/...; rename per prefix.
    body = act.split("</defs>", 1)[1].rsplit("</svg>", 1)[0]
    head = act.split("</defs>", 1)[0] + "</defs>"
    w = 2 * RADIUS + 8
    head = head.replace(f'<?xml version="1.0" encoding="UTF-8"?>\n', "")
    out = []
    for prefix, op in (("decoration", 1.0), ("decoration-inactive", 0.0), ("mask", None)):
        b = body
        for name in ("center", "top", "bottom", "left", "right", "topleft", "topright", "bottomleft", "bottomright"):
            b = b.replace(f'id="{name}"', f'id="{prefix}-{name}"')
        for name in ("hint-top-margin", "hint-bottom-margin", "hint-left-margin", "hint-right-margin"):
            b = b.replace(f'id="{name}"', f'id="{prefix}-{name}"')
        if prefix == "decoration-inactive":
            b = b.replace('fill-opacity="1.0"', 'fill-opacity="0.97"')
        if prefix == "mask":
            b = b.replace('class="ColorScheme-Text"', 'class="ColorScheme-Background"')
            b = b.replace('fill-opacity="0.16"', 'fill-opacity="1"').replace('fill-opacity="0.18"', 'fill-opacity="1"')
        out.append(b)
    # Aurorae wants distinct hint margins per prefix, all zero here (layout comes from the rc file).
    return ('<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{w}" viewBox="0 0 {w} {w}">'
            + head.split("<svg", 1)[1].split(">", 1)[1]
            + "".join(out) + "</svg>\n")


def glyph(kind, color, op=1.0, extra=""):
    s = f'stroke="{color}" stroke-opacity="{op}" stroke-width="1.6" stroke-linecap="round" stroke-linejoin="round" fill="none"'
    g = {
        "close": f'<path d="M9.5 9.5 L16.5 16.5 M16.5 9.5 L9.5 16.5" {s}/>',
        "minimize": f'<path d="M9.5 13 L16.5 13" {s}/>',
        "maximize": f'<rect x="9.5" y="9.5" width="7" height="7" rx="1.8" {s}/>',
        "restore": f'<rect x="9.5" y="11.5" width="5.5" height="5.5" rx="1.5" {s}/><path d="M12 9.5 H15.5 A1.5 1.5 0 0 1 17 11 V14.5" {s}/>',
        "alldesktops": f'<circle cx="13" cy="13" r="3" fill="{color}" fill-opacity="{op}"/>',
        "keepabove": f'<path d="M9.5 14.5 L13 11 L16.5 14.5" {s}/>',
        "keepbelow": f'<path d="M9.5 11.5 L13 15 L16.5 11.5" {s}/>',
        "shade": f'<path d="M9.5 10 H16.5 M9.5 14 L13 17 L16.5 14" {s}/>',
        "help": f'<path d="M10.8 10.8 A2.3 2.3 0 1 1 13 13.2 V14.4" {s}/><circle cx="13" cy="16.8" r="0.9" fill="{color}" fill-opacity="{op}"/>',
        "menu": f'<path d="M9.5 10.5 H16.5 M9.5 13 H16.5 M9.5 15.5 H16.5" {s}/>',
        "appmenu": f'<path d="M9.5 10.5 H16.5 M9.5 13 H16.5 M9.5 15.5 H16.5" {s}/>',
    }[kind]
    return g


def button(kind, t):
    red = kind == "close"
    states = {
        "active": (None, t["muted"], 1.0),
        "hover": ("#e5484d" if red else t["text"], "#ffffff" if red else t["text"], 1.0),
        "pressed": ("#c93a3f" if red else t["text"], "#ffffff" if red else t["text"], 1.0),
        "inactive": (None, t["muted"], 0.45),
        "hover-inactive": ("#e5484d" if red else t["text"], "#ffffff" if red else t["text"], 0.9),
        "deactivated": (None, t["muted"], 0.25),
    }
    parts = []
    for prefix, (bgc, fg, op) in states.items():
        bgop = {"hover": 0.14, "pressed": 0.24, "hover-inactive": 0.1}.get(prefix, 0)
        bgel = ""
        if bgc:
            o = 1.0 if (red and prefix in ("hover", "pressed")) else bgop
            if red and prefix == "hover-inactive":
                o = 0.8
            bgel = f'<circle cx="13" cy="13" r="11" fill="{bgc}" fill-opacity="{o}"/>'
        parts.append(f'<g id="{prefix}-center"><rect x="0" y="0" width="26" height="26" fill="none"/>{bgel}{glyph(kind, fg, op)}</g>')
    return ('<?xml version="1.0" encoding="UTF-8"?>\n'
            '<svg xmlns="http://www.w3.org/2000/svg" width="26" height="26" viewBox="0 0 26 26">'
            + "".join(parts) + "</svg>\n")


def themerc(t):
    return f"""[General]
ActiveTextColor={t['text']}
InactiveTextColor={t['muted']}
TitleAlignment=Center
TitleVerticalAlignment=Center
Animation=120
Shadow=false
DecorationPosition=0

[Layout]
BorderLeft=5
BorderRight=5
BorderBottom=5
BorderTop=0
TitleEdgeTop=3
TitleEdgeBottom=2
TitleEdgeLeft=6
TitleEdgeRight=6
TitleEdgeTopMaximized=0
TitleEdgeBottomMaximized=0
TitleEdgeLeftMaximized=0
TitleEdgeRightMaximized=0
TitleBorderLeft=8
TitleBorderRight=8
TitleHeight=38
ButtonWidth=26
ButtonHeight=26
ButtonSpacing=4
ButtonMarginTop=6
ButtonMarginTopMaximized=6
ExplicitButtonSpacer=6
PaddingLeft=0
PaddingRight=0
PaddingTop=0
PaddingBottom=0
"""


def main(root):
    for name, t in THEMES.items():
        d = os.path.join(root, name)
        os.makedirs(d, exist_ok=True)
        with open(os.path.join(d, "decoration.svg"), "w") as f:
            f.write(decoration(t))
        for kind in ("close", "minimize", "maximize", "restore", "alldesktops", "keepabove",
                     "keepbelow", "shade", "help", "menu", "appmenu"):
            with open(os.path.join(d, kind + ".svg"), "w") as f:
                f.write(button(kind, t))
        with open(os.path.join(d, name + "rc"), "w") as f:
            f.write(themerc(t))
        with open(os.path.join(d, "metadata.desktop"), "w") as f:
            f.write(f"[Desktop Entry]\nName={'Lareon' if name == 'Lareon' else 'Lareon Light'}\n"
                    f"Comment=Lareon window frame\nX-KDE-PluginInfo-Name={name}\n"
                    "X-KDE-PluginInfo-Author=Lareon\nX-KDE-PluginInfo-License=LGPL\n")


if __name__ == "__main__":
    main(sys.argv[1])

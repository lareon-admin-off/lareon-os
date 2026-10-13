#!/usr/bin/env python3
"""Generate the Lareon Plasma theme frames (panel, popups, tooltips, widgets).

Plasma draws these as 9-slice frames: four corners, four edges and a centre,
each a named element in one SVG, plus hint-*-margin rectangles for content
padding. Lareon's are rounder than Breeze's and use a hairline border.

    python3 artwork/make_plasma_theme.py packages/lareon-branding/usr/share/plasma/desktoptheme/lareon
"""
import json
import os
import sys

C = 8  # width/height of the stretchy centre


def frame_svg(r, mt, mr, mb, ml, alpha, border_alpha=0.16):
    w = 2 * r + C
    a, b = r, r + C  # cell boundaries
    fill = f'fill="currentColor" fill-opacity="{alpha}" class="ColorScheme-Background"'
    line = f'fill="currentColor" fill-opacity="{border_alpha}" class="ColorScheme-Text"'
    arc_line = f'fill="none" stroke="currentColor" stroke-opacity="{border_alpha}" stroke-width="1" class="ColorScheme-Text"'

    def cell(x, y, cw, ch):
        return f'<rect x="{x}" y="{y}" width="{cw}" height="{ch}" fill="none" stroke="none"/>'

    def g(i, x, y, cw, ch, body):
        return f'<g id="{i}">{cell(x, y, cw, ch)}{body}</g>'

    ri = r - 0.5
    parts = []
    parts.append(g("center", a, a, C, C, f'<rect x="{a}" y="{a}" width="{C}" height="{C}" {fill}/>'))
    parts.append(g("top", a, 0, C, r,
                   f'<rect x="{a}" y="0" width="{C}" height="{r}" {fill}/><rect x="{a}" y="0" width="{C}" height="1" {line}/>'))
    parts.append(g("bottom", a, b, C, r,
                   f'<rect x="{a}" y="{b}" width="{C}" height="{r}" {fill}/><rect x="{a}" y="{w-1}" width="{C}" height="1" {line}/>'))
    parts.append(g("left", 0, a, r, C,
                   f'<rect x="0" y="{a}" width="{r}" height="{C}" {fill}/><rect x="0" y="{a}" width="1" height="{C}" {line}/>'))
    parts.append(g("right", b, a, r, C,
                   f'<rect x="{b}" y="{a}" width="{r}" height="{C}" {fill}/><rect x="{w-1}" y="{a}" width="1" height="{C}" {line}/>'))
    parts.append(g("topleft", 0, 0, r, r,
                   f'<path d="M0,{r} A{r},{r} 0 0 1 {r},0 L{r},{r} Z" {fill}/>'
                   f'<path d="M0.5,{r} A{ri},{ri} 0 0 1 {r},0.5" {arc_line}/>'))
    parts.append(g("topright", b, 0, r, r,
                   f'<path d="M{b},0 A{r},{r} 0 0 1 {w},{r} L{b},{r} Z" {fill}/>'
                   f'<path d="M{b},0.5 A{ri},{ri} 0 0 1 {w-0.5},{r}" {arc_line}/>'))
    parts.append(g("bottomleft", 0, b, r, r,
                   f'<path d="M0,{b} A{r},{r} 0 0 0 {r},{w} L{r},{b} Z" {fill}/>'
                   f'<path d="M0.5,{b} A{ri},{ri} 0 0 0 {r},{w-0.5}" {arc_line}/>'))
    parts.append(g("bottomright", b, b, r, r,
                   f'<path d="M{w},{b} A{r},{r} 0 0 1 {b},{w} L{b},{b} Z" {fill}/>'
                   f'<path d="M{w-0.5},{b} A{ri},{ri} 0 0 1 {b},{w-0.5}" {arc_line}/>'))
    hints = (
        f'<rect id="hint-top-margin" x="0" y="0" width="1" height="{mt}" fill="none"/>'
        f'<rect id="hint-bottom-margin" x="0" y="0" width="1" height="{mb}" fill="none"/>'
        f'<rect id="hint-left-margin" x="0" y="0" width="{ml}" height="1" fill="none"/>'
        f'<rect id="hint-right-margin" x="0" y="0" width="{mr}" height="1" fill="none"/>'
    )
    style = ('<defs><style type="text/css" id="current-color-scheme">'
             '.ColorScheme-Text{color:#e9ecf3;}.ColorScheme-Background{color:#14161f;}'
             '.ColorScheme-Highlight{color:#ff7c1f;}</style></defs>')
    return (f'<?xml version="1.0" encoding="UTF-8"?>\n'
            f'<svg xmlns="http://www.w3.org/2000/svg" width="{w}" height="{w}" viewBox="0 0 {w} {w}">'
            f'{style}{"".join(parts)}{hints}</svg>\n')


# name: (radius, margins top/right/bottom/left)
SHAPES = {
    "widgets/panel-background.svg": (18, 6, 10, 6, 10),
    "widgets/background.svg": (14, 10, 10, 10, 10),
    "dialogs/background.svg": (16, 10, 10, 10, 10),
    "widgets/tooltip.svg": (10, 6, 9, 6, 9),
}
# folder: background opacity
VARIANTS = {"": 0.94, "translucent": 0.72, "opaque": 1.0, "solid": 1.0}


def main(out):
    for folder, alpha in VARIANTS.items():
        for rel, (r, mt, mr, mb, ml) in SHAPES.items():
            path = os.path.join(out, folder, rel)
            os.makedirs(os.path.dirname(path), exist_ok=True)
            with open(path, "w") as f:
                f.write(frame_svg(r, mt, mr, mb, ml, alpha))
    meta = {
        "KPlugin": {
            "Authors": [{"Name": "Lareon"}],
            "Category": "",
            "Description": "The Lareon desktop theme",
            "EnabledByDefault": True,
            "Id": "lareon",
            "License": "LGPL",
            "Name": "Lareon",
            "Version": "1.0",
            "Website": "https://lareon.org",
        },
        "X-Plasma-API": "5.0",
    }
    with open(os.path.join(out, "metadata.json"), "w") as f:
        json.dump(meta, f, indent=4)
        f.write("\n")
    with open(os.path.join(out, "plasmarc"), "w") as f:
        f.write("[AdaptiveTransparency]\nenabled=true\n")


if __name__ == "__main__":
    main(sys.argv[1])

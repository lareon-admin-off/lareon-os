#!/usr/bin/env python3
"""Make the Lareon Plasma colour schemes and the system-wide kdeglobals.

Colours come from artwork/brand/README.md (the Lareon brand kit). Where a
role isn't covered by the kit, the value is marked below:
  [logo]    taken from a colour already used in the Lareon product logos
  [derived] chosen to fit the palette; change freely

Usage: make_color_schemes.py COLOR_SCHEMES_DIR KDEGLOBALS_PATH
"""
import os
import sys

DARK = dict(
    name="Lareon Dark", id="LareonDark",
    bg="#13111b", panel="#1a1824", panel2="#211e2d", lines="#2b2838",
    text="#ece9f5", muted="#a7a4ba", faint="#74718a",
    accent="#ff7c1f", violet="#a35cf5", magenta="#d94fc4",
    on_accent="#13111b",  # dark text on orange: 7.9:1 contrast (white would be 2.6:1)
    link="#a35cf5",
    negative="#ff4f7a",   # [logo] Aster/Dusk coral
    neutral="#ffb347",    # [logo] Aster/Dusk/Ember gold
    positive="#4cc38a",   # [derived] no green in the brand kit
)
LIGHT = dict(
    name="Lareon Light", id="LareonLight",
    bg="#f4effb", text="#1d1832", muted="#4f4a68",
    panel="#ffffff",      # [derived] views and buttons on the light background
    panel2="#ebe4f6",     # [derived] headers, alternate rows
    lines="#d9d0ea",      # [derived]
    faint="#8a84a3",      # [derived]
    accent="#ff7c1f", violet="#a35cf5", magenta="#d94fc4",
    on_accent="#1d1832",
    link="#7a3ed6",       # [derived] darker violet so links are readable on white
    negative="#d93b62",   # [derived] darker coral for light backgrounds
    neutral="#b86e00",    # [derived] darker gold
    positive="#2a9a66",   # [derived]
)


def rgb(h):
    h = h.lstrip("#")
    return ",".join(str(int(h[i:i + 2], 16)) for i in (0, 2, 4))


def group(c, back, alt, fore=None):
    fore = fore or c["text"]
    return {
        "BackgroundAlternate": alt, "BackgroundNormal": back,
        "DecorationFocus": c["accent"], "DecorationHover": c["violet"],
        "ForegroundActive": c["accent"], "ForegroundInactive": c["muted"],
        "ForegroundLink": c["link"], "ForegroundNegative": c["negative"],
        "ForegroundNeutral": c["neutral"], "ForegroundNormal": fore,
        "ForegroundPositive": c["positive"], "ForegroundVisited": c["magenta"],
    }


def scheme(c):
    dark = c is DARK
    window = c["panel"] if dark else c["bg"]
    view = c["bg"] if dark else c["panel"]
    s = {
        "ColorEffects:Disabled": {"Color": "56,56,56", "ColorAmount": "0", "ColorEffect": "0",
                                  "ContrastAmount": "0.65", "ContrastEffect": "1",
                                  "IntensityAmount": "0.1", "IntensityEffect": "2"},
        "ColorEffects:Inactive": {"ChangeSelectionColor": "true", "Color": "112,111,110",
                                  "ColorAmount": "0.025", "ColorEffect": "2", "ContrastAmount": "0.1",
                                  "ContrastEffect": "2", "Enable": "false",
                                  "IntensityAmount": "0", "IntensityEffect": "0"},
        "Colors:Button": group(c, c["panel2"] if dark else c["panel"], c["lines"] if dark else c["panel2"]),
        "Colors:Complementary": group(DARK, DARK["bg"], DARK["panel"]),
        "Colors:Header": group(c, c["bg"] if dark else c["panel2"], c["panel"]),
        "Colors:Header][Inactive": group(c, c["bg"] if dark else c["panel2"], c["panel"]),
        "Colors:Selection": {**group(c, c["accent"], "#e86f15", c["on_accent"]),
                             "ForegroundInactive": c["on_accent"], "ForegroundActive": c["on_accent"]},
        "Colors:Tooltip": group(c, c["panel2"] if dark else c["panel"], c["panel"]),
        "Colors:View": group(c, view, c["panel"] if dark else c["panel2"]),
        "Colors:Window": group(c, window, c["panel2"]),
        "General": {"ColorScheme": c["id"], "Name": c["name"], "shadeSortColumn": "true"},
        "KDE": {"contrast": "4"},
        "WM": {"activeBackground": c["bg"] if dark else c["bg"], "activeBlend": c["text"],
               "activeForeground": c["text"], "inactiveBackground": c["bg"],
               "inactiveBlend": c["muted"], "inactiveForeground": c["faint"]},
    }
    for g in s.values():
        for k, v in g.items():
            if isinstance(v, str) and v.startswith("#"):
                g[k] = rgb(v)
    return s


def write_ini(path, groups, header=""):
    with open(path, "w") as f:
        f.write(header)
        for name, keys in groups.items():
            f.write(f"[{name}]\n")
            for k, v in keys.items():
                f.write(f"{k}={v}\n")
            f.write("\n")


def main():
    out_dir, kdeglobals = sys.argv[1], sys.argv[2]
    os.makedirs(out_dir, exist_ok=True)
    for c in (DARK, LIGHT):
        write_ini(os.path.join(out_dir, c["id"] + ".colors"), scheme(c))

    # System-wide defaults for every user (and the installer, which runs as root).
    # A user's own ~/.config/kdeglobals always wins over this file.
    g = scheme(DARK)
    g["General"].update({
        "AccentColor": rgb(DARK["accent"]),
        "font": "Geist,10,-1,5,50,0,0,0,0,0",
        "menuFont": "Geist,10,-1,5,50,0,0,0,0,0",
        "toolBarFont": "Geist,10,-1,5,50,0,0,0,0,0",
        "smallestReadableFont": "Geist,8,-1,5,50,0,0,0,0,0",
        "fixed": "Geist Mono,10,-1,5,50,0,0,0,0,0",
    })
    g["WM"]["activeFont"] = "Geist,10,-1,5,57,0,0,0,0,0"  # Medium
    # Snappier animations, and Ember as the browser.
    g["KDE"].update({"LookAndFeelPackage": "org.lareon.desktop", "widgetStyle": "kvantum",
                     "AnimationDurationFactor": "0.5"})
    g["General"]["BrowserApplication"] = "ember.desktop"
    g["Icons"] = {"Theme": "Lareon"}
    os.makedirs(os.path.dirname(kdeglobals), exist_ok=True)
    write_ini(kdeglobals, g, "# Lareon OS defaults (generated by artwork/make_color_schemes.py)\n\n")


if __name__ == "__main__":
    main()

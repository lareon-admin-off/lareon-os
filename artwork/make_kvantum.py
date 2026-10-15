#!/usr/bin/env python3
"""Make the Lareon widget styles (Kvantum) from Kvantum's flat themes.

Greys become the Lareon violet-tinted neutrals, blues become Lareon orange.

    python3 artwork/make_kvantum.py packages/lareon-branding/usr/share/Kvantum
"""
import colorsys
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
HEX = re.compile(r"#([0-9a-fA-F]{6})\b")


def conv(hexs, dark):
    r, g, b = (int(hexs[i:i + 2], 16) / 255 for i in (0, 2, 4))
    h, l, s = colorsys.rgb_to_hls(r, g, b)
    hd = h * 360
    if 170 <= hd <= 260 and s > 0.25:          # KDE blue -> Lareon orange
        h, s = 26 / 360, min(1.0, max(s, 0.9))
        l = min(l, 0.62)
    elif s < 0.2:                               # neutral grey -> violet-tinted grey
        if dark:
            if l <= 0.45:
                l = 0.02 + 0.55 * l
            elif l < 0.8:                       # blend back to identity
                t = (l - 0.45) / 0.35
                l = (0.02 + 0.55 * 0.45) * (1 - t) + l * t
            h, s = 255 / 360, 0.17 if l < 0.5 else 0.10
        else:
            s = min(0.55, max(0.06, (l - 0.5) * 1.1)) if l > 0.5 else 0.06
            if l > 0.85:
                l = min(1.0, l + 0.015)
            h = 262 / 360
    r, g, b = colorsys.hls_to_rgb(h, l, s)
    return "#%02x%02x%02x" % (round(r * 255), round(g * 255), round(b * 255))


def recolour(text, dark):
    return HEX.sub(lambda m: conv(m.group(1), dark), text)


DARK = {
    "window.color": "#1a1824", "base.color": "#13111b", "alt.base.color": "#17141f",
    "button.color": "#262236", "light.color": "#2b2838", "mid.light.color": "#262236",
    "dark.color": "#0e0c14", "mid.color": "#211e2d", "highlight.color": "#ff7c1f",
    "inactive.highlight.color": "#7a4a22", "text.color": "#ece9f5", "window.text.color": "#ece9f5",
    "button.text.color": "#ece9f5", "disabled.text.color": "#74718a", "tooltip.text.color": "#ece9f5",
    "highlight.text.color": "#13111b", "link.color": "#a35cf5", "link.visited.color": "#d94fc4",
}
LIGHT = {
    "window.color": "#f4effb", "base.color": "#ffffff", "alt.base.color": "#f8f4fd",
    "button.color": "#ebe4f6", "light.color": "#ffffff", "mid.light.color": "#f1ecf9",
    "dark.color": "#b9b0d0", "mid.color": "#d9d0ea", "highlight.color": "#ff7c1f",
    "inactive.highlight.color": "#f0b88a", "text.color": "#1d1832", "window.text.color": "#1d1832",
    "button.text.color": "#1d1832", "disabled.text.color": "#8a84a3", "tooltip.text.color": "#1d1832",
    "highlight.text.color": "#1d1832", "link.color": "#7a3ed6", "link.visited.color": "#a02fa8",
    "progress.indicator.text.color": "#1d1832",
}


def patch_conf(text, colors, name, comment):
    for k, v in colors.items():
        text, n = re.subn(rf"(?m)^{re.escape(k)}=.*$", f"{k}={v}", text)
        if n == 0:
            text = text.replace("[GeneralColors]\n", f"[GeneralColors]\n{k}={v}\n", 1)
    text = re.sub(r"(?m)^author=.*$", "author=Lareon (based on KvFlat by Tsu Jan)", text)
    text = re.sub(r"(?m)^comment=.*$", f"comment={comment}", text)
    return text


def main(root):
    for name, base, colors, dark in (("Lareon", "KvFlat", DARK, True), ("LareonLight", "KvFlatLight", LIGHT, False)):
        out = os.path.join(root, name)
        os.makedirs(out, exist_ok=True)
        conf = open(os.path.join(HERE, "kvantum", base + ".kvconfig")).read()
        conf = patch_conf(conf, colors, name, "Lareon widget style")
        svg = recolour(open(os.path.join(HERE, "kvantum", base + ".svg")).read(), dark)
        open(os.path.join(out, name + ".kvconfig"), "w").write(conf)
        open(os.path.join(out, name + ".svg"), "w").write(svg)


if __name__ == "__main__":
    main(sys.argv[1])

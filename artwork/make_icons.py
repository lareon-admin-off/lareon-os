#!/usr/bin/env python3
"""Generate the Lareon icon overlay theme: folders in the Lareon violet-to-orange
gradient with a small glyph per kind. Everything else comes from Papirus.

    python3 artwork/make_icons.py packages/lareon-branding/usr/share/icons
"""
import os
import sys

GLYPHS = {
    "documents": '<path d="M26 26h12a2 2 0 0 1 2 2v14a2 2 0 0 1-2 2H26a2 2 0 0 1-2-2V28a2 2 0 0 1 2-2z" /><path d="M28 32h8M28 36h8" stroke="#6b3bb0" stroke-width="1.6" stroke-linecap="round"/>',
    "download": '<path d="M32 26v12m-5-5l5 5 5-5M26 44h12" fill="none" stroke="#fff" stroke-width="2.6" stroke-linecap="round" stroke-linejoin="round"/>',
    "pictures": '<rect x="24" y="27" width="16" height="14" rx="2.5" fill="none" stroke="#fff" stroke-width="2.4"/><circle cx="29" cy="32" r="1.6"/><path d="M25 40l5-5 4 3 5-5" fill="none" stroke="#fff" stroke-width="2.2" stroke-linejoin="round"/>',
    "music": '<path d="M35 26v11a3.4 3.4 0 1 1-2-3.1V29l6-1.5" fill="none" stroke="#fff" stroke-width="2.4" stroke-linecap="round" stroke-linejoin="round"/>',
    "video": '<rect x="23" y="29" width="13" height="11" rx="2.5" fill="none" stroke="#fff" stroke-width="2.4"/><path d="M36 33l5-3v10l-5-3z"/>',
    "home": '<path d="M32 27l8 7v8H24v-8z" fill="none" stroke="#fff" stroke-width="2.4" stroke-linejoin="round"/>',
    "desktop": '<rect x="23" y="27" width="18" height="12" rx="2.5" fill="none" stroke="#fff" stroke-width="2.4"/><path d="M29 43h6" stroke="#fff" stroke-width="2.4" stroke-linecap="round"/>',
    "plain": "",
}

NAMES = {
    "folder": "plain", "folder-open": "plain", "inode-directory": "plain",
    "folder-documents": "documents", "folder-download": "download", "folder-downloads": "download",
    "folder-pictures": "pictures", "folder-music": "music", "folder-video": "video", "folder-videos": "video",
    "folder-templates": "plain", "folder-public": "plain", "folder-publicshare": "plain",
    "folder-desktop": "desktop", "user-desktop": "desktop", "user-home": "home", "folder-home": "home",
    "folder-remote": "plain", "folder-favorites": "plain", "folder-activities": "plain",
}


def folder(glyph, openf=False):
    front = ('<path d="M6 24a4 4 0 0 1 4-4h44a4 4 0 0 1 4 4v28a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4z" fill="url(#f)"/>'
             if not openf else
             '<path d="M10 27h46a3 3 0 0 1 2.9 3.8l-4.4 20A4 4 0 0 1 50.6 54H10a4 4 0 0 1-4-4V31a4 4 0 0 1 4-4z" fill="url(#f)"/>')
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
            '<defs><linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#7a3fd1"/><stop offset="1" stop-color="#a02fa8"/></linearGradient>'
            '<linearGradient id="f" x1="0" y1="0" x2="0.4" y2="1"><stop offset="0" stop-color="#b872ff"/><stop offset="0.55" stop-color="#d94fc4"/><stop offset="1" stop-color="#ff7c1f"/></linearGradient></defs>'
            '<path d="M6 17a4 4 0 0 1 4-4h14l5 5h25a4 4 0 0 1 4 4v28a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4z" fill="url(#b)"/>'
            + front + f'<g fill="#fff">{GLYPHS[glyph]}</g></svg>\n')


def main(root):
    for theme, parent in (("Lareon", "Papirus-Dark"), ("LareonLight", "Papirus-Light")):
        d = os.path.join(root, theme)
        pl = os.path.join(d, "scalable", "places")
        os.makedirs(pl, exist_ok=True)
        for name, g in NAMES.items():
            with open(os.path.join(pl, name + ".svg"), "w") as f:
                f.write(folder(g, openf=name == "folder-open"))
        with open(os.path.join(d, "index.theme"), "w") as f:
            f.write(f"[Icon Theme]\nName={theme}\nComment=Lareon folders on top of Papirus\n"
                    f"Inherits={parent},breeze-dark,breeze,hicolor\nDirectories=scalable/places\n\n"
                    "[scalable/places]\nSize=64\nMinSize=16\nMaxSize=512\nType=Scalable\nContext=Places\n")


if __name__ == "__main__":
    main(sys.argv[1])

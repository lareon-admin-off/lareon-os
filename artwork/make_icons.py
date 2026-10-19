#!/usr/bin/env python3
"""Generate the Lareon icon overlay theme: folders in the Lareon violet-to-orange
gradient with a small glyph per kind. Everything else comes from Papirus.

    python3 artwork/make_icons.py packages/lareon-branding/usr/share/icons
"""
import math
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
            '<defs><linearGradient id="b" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#5a38a8"/><stop offset="1" stop-color="#7a3a9e"/></linearGradient>'
            '<linearGradient id="f" x1="0" y1="0" x2="0.4" y2="1"><stop offset="0" stop-color="#a35cf5"/><stop offset="0.55" stop-color="#d94fc4"/><stop offset="1" stop-color="#ff7c1f"/></linearGradient></defs>'
            '<path d="M6 17a4 4 0 0 1 4-4h14l5 5h25a4 4 0 0 1 4 4v28a4 4 0 0 1-4 4H10a4 4 0 0 1-4-4z" fill="url(#b)"/>'
            + front + f'<g fill="#fff">{GLYPHS[glyph]}</g></svg>\n')


# ---------------------------------------------------------------- app icons
# One family: a dark tile with a brand-gradient glyph, like the Lareon app.
GRADS = {
    "violet": ("#9a5cff", "#5b2fb8"),
    "ember":  ("#ffa04a", "#e5531a"),
    "dusk":   ("#5a7bff", "#7a3fd1"),
    "night":  ("#5b6478", "#2a3040"),
    "leaf":   ("#4fd1a0", "#1f8f78"),
}
W = 'fill="none" stroke="url(#s)" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"'


def gear():
    pts = []
    for i in range(16):
        a = math.pi * 2 * i / 16
        r = 17 if i % 2 == 0 else 13.5
        for da in (-0.09, 0.09):
            pts.append((32 + r * math.cos(a + da), 32 + r * math.sin(a + da)))
    d = "M" + " L".join(f"{x:.1f} {y:.1f}" for x, y in pts) + "z"
    return f'<path d="{d}" {W}/><circle cx="32" cy="32" r="6" {W}/>'


APP_GLYPHS = {
    "files": f'<path d="M15 22a3 3 0 0 1 3-3h9l4 4h15a3 3 0 0 1 3 3v19a3 3 0 0 1-3 3H18a3 3 0 0 1-3-3z" {W}/>',
    "terminal": f'<path d="M19 22l11 10-11 10" {W}/><path d="M34 43h12" {W}/>',
    "store": f'<path d="M17 25h30l-2 22H19z" {W}/><path d="M25 25v-3a7 7 0 0 1 14 0v3" {W}/>',
    "settings": gear(),
    "text": f'<path d="M20 20h24M20 29h24M20 38h14" {W}/><path d="M40 46l9-9 3 3-9 9h-3z" {W}/>',
    "picture": f'<rect x="16" y="19" width="32" height="26" rx="4" {W}/><circle cx="26" cy="28" r="3" {W}/><path d="M17 43l10-9 7 6 6-5 8 7" {W}/>',
    "document": f'<path d="M22 16h14l8 8v24H22z" {W}/><path d="M36 16v8h8M27 33h12M27 40h12" {W}/>',
    "calc": f'<rect x="19" y="15" width="26" height="34" rx="4" {W}/><path d="M25 24h14M26 33h2M32 33h2M38 33h2M26 40h2M32 40h2M38 40h2" {W}/>',
    "archive": f'<rect x="16" y="19" width="32" height="10" rx="3" {W}/><path d="M19 29v16h26V29M28 36h8" {W}/>',
    "capture": f'<path d="M18 26v-6h6M40 20h6v6M46 38v6h-6M24 44h-6v-6" {W}/><circle cx="32" cy="32" r="5" {W}/>',
    "monitor": f'<path d="M15 33h9l4-11 8 22 4-11h9" {W}/>',
    "info": f'<circle cx="32" cy="32" r="15" {W}/><path d="M32 30v9" {W}/><circle cx="32" cy="24" r="1.2" {W}/>',
    "globe": f'<circle cx="32" cy="32" r="15" {W}/><path d="M17 32h30M32 17c-8 8-8 22 0 30M32 17c8 8 8 22 0 30" {W}/>',
    "install": f'<path d="M32 17v20m-8-8l8 8 8-8M19 46h26" {W}/>',
    "bluetooth": f'<path d="M23 25l18 14-9 7V18l9 7-18 14" {W}/>',
    "update": f'<path d="M45 26a14 14 0 0 0-25-3M19 38a14 14 0 0 0 25 3" {W}/><path d="M20 15v8h8M44 49v-8h-8" {W}/>',
    "audio": f'<path d="M18 28h7l9-8v24l-9-8h-7z" {W}/><path d="M40 26a9 9 0 0 1 0 12M45 21a16 16 0 0 1 0 22" {W}/>',
    "video": f'<rect x="15" y="22" width="25" height="20" rx="4" {W}/><path d="M40 29l9-5v16l-9-5" {W}/>',
    "pdf": f'<path d="M22 16h14l8 8v24H22z" {W}/><path d="M36 16v8h8M27 38c4-8 6-8 5 0s6 0 6-2" {W}/>',
    "code": f'<path d="M26 22l-10 10 10 10M38 22l10 10-10 10M34 19l-4 26" {W}/>',
    "disk": f'<rect x="15" y="24" width="34" height="18" rx="5" {W}/><path d="M22 33h2M40 33h2" {W}/>',
    "usb": f'<path d="M32 46V22M32 22l-5 6M32 22l5 4M32 36l-7-5v-3M32 32l7-4" {W}/><circle cx="32" cy="48" r="2.5" {W}/>',
    "disc": f'<circle cx="32" cy="32" r="16" {W}/><circle cx="32" cy="32" r="4" {W}/>',
    "computer": f'<rect x="15" y="19" width="34" height="23" rx="4" {W}/><path d="M25 47h14M32 42v5" {W}/>',
    "trash": f'<path d="M19 24h26M28 24v-4h8v4M22 24l2 22h16l2-22M28 31v10M36 31v10" {W}/>',
    "network": f'<path d="M18 30a20 20 0 0 1 28 0M23 36a13 13 0 0 1 18 0" {W}/><circle cx="32" cy="43" r="2" {W}/>',
    "sheet": f'<rect x="17" y="17" width="30" height="30" rx="4" {W}/><path d="M17 27h30M17 37h30M27 17v30" {W}/>',
    "slides": f'<rect x="16" y="20" width="32" height="22" rx="4" {W}/><path d="M32 42v6M24 48h16" {W}/>',
    "font": f'<path d="M20 46l10-26 10 26M24 38h12M44 24v6M41 27h6" {W}/>',
    "package": f'<path d="M32 16l15 8v16l-15 8-15-8V24zM17 24l15 8 15-8M32 32v16" {W}/>',
}

APPS = {  # icon name -> (glyph, gradient)
    "org.kde.dolphin": ("files", "dusk"),
    "system-file-manager": ("files", "dusk"),
    "org.kde.konsole": ("terminal", "night"),
    "utilities-terminal": ("terminal", "night"),
    "plasmadiscover": ("store", "leaf"),
    "org.kde.discover": ("store", "leaf"),
    "preferences-system": ("settings", "night"),
    "systemsettings": ("settings", "night"),
    "org.kde.systemsettings": ("settings", "night"),
    "org.kde.kwrite": ("text", "violet"),
    "kwrite": ("text", "violet"),
    "org.kde.gwenview": ("picture", "ember"),
    "gwenview": ("picture", "ember"),
    "org.kde.okular": ("document", "dusk"),
    "okular": ("document", "dusk"),
    "accessories-calculator": ("calc", "violet"),
    "org.kde.kcalc": ("calc", "violet"),
    "org.kde.ark": ("archive", "ember"),
    "ark": ("archive", "ember"),
    "org.kde.spectacle": ("capture", "dusk"),
    "spectacle": ("capture", "dusk"),
    "org.kde.plasma-systemmonitor": ("monitor", "leaf"),
    "utilities-system-monitor": ("monitor", "leaf"),
    "org.kde.kinfocenter": ("info", "dusk"),
    "kinfocenter": ("info", "dusk"),
    "firefox-esr": ("globe", "ember"),
    "firefox": ("globe", "ember"),
    "web-browser": ("globe", "ember"),
    "lareon-install": ("install", "ember"),
    "org.kde.bluedevil": ("bluetooth", "dusk"),
    "lareon-updates": ("update", None),
    "system-software-update": ("update", None),
    "org.kde.discover.notifier": ("update", None),
    "preferences-system-network": ("network", None),
    "org.kde.plasma.networkmanagement": ("network", None),
    "preferences-system-bluetooth": ("bluetooth", "dusk"),
}


# Other kinds of icons, same family
MIMES = {
    "text-x-generic": "text", "text-plain": "text", "application-pdf": "pdf",
    "image-x-generic": "picture", "audio-x-generic": "audio", "video-x-generic": "video",
    "application-zip": "archive", "application-x-compressed-tar": "archive", "application-x-archive": "archive",
    "application-x-generic": "document", "application-octet-stream": "document", "unknown": "document",
    "text-x-script": "code", "text-x-python": "code", "text-html": "code", "text-x-csrc": "code",
    "application-json": "code", "application-x-shellscript": "code",
    "x-office-document": "document", "x-office-spreadsheet": "sheet", "x-office-presentation": "slides",
    "application-x-font-ttf": "font", "font-x-generic": "font", "application-vnd.debian.binary-package": "package",
    "application-x-deb": "package", "application-x-executable": "package",
}
DEVICES = {
    "drive-harddisk": "disk", "drive-removable-media": "usb", "drive-removable-media-usb": "usb",
    "drive-optical": "disc", "media-optical": "disc", "computer": "computer", "computer-laptop": "computer",
    "network-wired": "network", "network-workgroup": "network",
}
PLACES_EXTRA = {"user-trash": "trash", "user-trash-full": "trash", "folder-network": "network"}


def app_icon(glyph, grad=None):
    """Dark tile like the Lareon app's panels; the glyph carries the brand
    gradient (orange at the bottom to violet at the top, as in the logo)."""
    return ('<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 64 64">'
            '<defs>'
            '<linearGradient id="t" x1="0" y1="0" x2="0" y2="1"><stop offset="0" stop-color="#2a2639"/><stop offset="1" stop-color="#17141f"/></linearGradient>'
            '<linearGradient id="s" gradientUnits="userSpaceOnUse" x1="14" y1="50" x2="50" y2="14">'
            '<stop offset="0" stop-color="#ff7c1f"/><stop offset=".6" stop-color="#d94fc4"/><stop offset="1" stop-color="#a35cf5"/></linearGradient>'
            '</defs>'
            '<rect x="4" y="4" width="56" height="56" rx="15" fill="url(#t)"/>'
            '<rect x="4.5" y="4.5" width="55" height="55" rx="14.5" fill="none" stroke="#fff" stroke-opacity=".10"/>'
            + APP_GLYPHS[glyph] + '</svg>\n')


def main(root):
    for theme, parent in (("Lareon", "Papirus-Dark"), ("LareonLight", "Papirus-Light")):
        d = os.path.join(root, theme)
        pl = os.path.join(d, "scalable", "places")
        os.makedirs(pl, exist_ok=True)
        for name, g in NAMES.items():
            with open(os.path.join(pl, name + ".svg"), "w") as f:
                f.write(folder(g, openf=name == "folder-open"))
        ap = os.path.join(d, "scalable", "apps")
        os.makedirs(ap, exist_ok=True)
        for name, (g, grad) in APPS.items():
            with open(os.path.join(ap, name + ".svg"), "w") as f:
                f.write(app_icon(g, grad))
        for sub, table in (("mimetypes", MIMES), ("devices", DEVICES), ("places", PLACES_EXTRA)):
            dd = os.path.join(d, "scalable", sub)
            os.makedirs(dd, exist_ok=True)
            for name, g in table.items():
                with open(os.path.join(dd, name + ".svg"), "w") as f:
                    f.write(app_icon(g))
        with open(os.path.join(d, "index.theme"), "w") as f:
            f.write(f"[Icon Theme]\nName={theme}\nComment=Lareon folders and app icons on top of Papirus\n"
                    f"Inherits={parent},breeze-dark,breeze,hicolor\nDirectories=scalable/places,scalable/apps,scalable/mimetypes,scalable/devices\n\n"
                    "[scalable/places]\nSize=64\nMinSize=16\nMaxSize=512\nType=Scalable\nContext=Places\n\n"
                    "[scalable/apps]\nSize=64\nMinSize=16\nMaxSize=512\nType=Scalable\nContext=Applications\n\n"
                    "[scalable/mimetypes]\nSize=64\nMinSize=16\nMaxSize=512\nType=Scalable\nContext=MimeTypes\n\n"
                    "[scalable/devices]\nSize=64\nMinSize=16\nMaxSize=512\nType=Scalable\nContext=Devices\n")


if __name__ == "__main__":
    main(sys.argv[1])

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
    "display": f'<rect x="14" y="19" width="36" height="24" rx="4" {W}/><path d="M26 49h12M32 43v6" {W}/>',
    "keyboard": f'<rect x="14" y="22" width="36" height="22" rx="4" {W}/><path d="M21 29h2M28 29h2M35 29h2M42 29h1M22 37h20" {W}/>',
    "mouse": f'<rect x="21" y="15" width="22" height="34" rx="11" {W}/><path d="M32 15v13" {W}/>',
    "touchpad": f'<rect x="15" y="20" width="34" height="24" rx="4" {W}/><path d="M15 38h34M32 38v6" {W}/>',
    "power": f'<path d="M32 16v15" {W}/><path d="M23 22a15 15 0 1 0 18 0" {W}/>',
    "clock": f'<circle cx="32" cy="32" r="15" {W}/><path d="M32 23v10l7 4" {W}/>',
    "language": f'<path d="M17 23h18M26 19v4M21 23c1 6 5 10 11 12M31 23c-1 6-5 10-11 12" {W}/><path d="M33 47l7-18 7 18M35 42h10" {W}/>',
    "lock": f'<rect x="19" y="29" width="26" height="19" rx="5" {W}/><path d="M24 29v-5a8 8 0 0 1 16 0v5M32 37v4" {W}/>',
    "palette": f'<path d="M32 16a16 16 0 1 0 0 32c3 0 4-2 3-4s0-4 3-4h4c3 0 5-2 5-5 0-10-7-19-15-19z" {W}/><circle cx="24" cy="30" r="1.5" {W}/><circle cx="31" cy="24" r="1.5" {W}/><circle cx="39" cy="27" r="1.5" {W}/>',
    "bell": f'<path d="M20 40c3-3 3-6 3-11a9 9 0 0 1 18 0c0 5 0 8 3 11zM29 46a3.5 3.5 0 0 0 6 0" {W}/>',
    "user": f'<circle cx="32" cy="25" r="7" {W}/><path d="M18 47c2-8 8-11 14-11s12 3 14 11" {W}/>',
    "users": f'<circle cx="26" cy="26" r="6" {W}/><path d="M14 46c1-7 6-10 12-10s11 3 12 10M38 21a6 6 0 0 1 0 11M43 36c4 1 6 4 7 8" {W}/>',
    "shield": f'<path d="M32 15l14 5v11c0 9-6 15-14 18-8-3-14-9-14-18V20z" {W}/><path d="M26 32l4 4 8-8" {W}/>',
    "printer": f'<path d="M23 25v-8h18v8M23 41h-5V27h28v14h-5" {W}/><rect x="23" y="35" width="18" height="12" rx="2" {W}/>',
    "battery": f'<rect x="14" y="23" width="32" height="18" rx="4" {W}/><path d="M50 29v6M21 29v6M27 29v6" {W}/>',
    "apps": f'<rect x="17" y="17" width="12" height="12" rx="3" {W}/><rect x="35" y="17" width="12" height="12" rx="3" {W}/><rect x="17" y="35" width="12" height="12" rx="3" {W}/><rect x="35" y="35" width="12" height="12" rx="3" {W}/>',
    "shortcut": f'<path d="M25 25h14v14H25zM25 25a5 5 0 1 1-5-5h5zM39 25a5 5 0 1 0 5-5h-5zM25 39a5 5 0 1 0-5 5h5zM39 39a5 5 0 1 1 5 5h-5z" {W}/>',
    "person": f'<circle cx="32" cy="19" r="4" {W}/><path d="M18 27l14 3 14-3M32 30v8M25 48l7-10 7 10" {W}/>',
    "rocket": f'<path d="M32 16c7 4 10 11 9 20l-9 5-9-5c-1-9 2-16 9-20z" {W}/><circle cx="32" cy="29" r="3" {W}/><path d="M23 36l-6 6 7-1M41 36l6 6-7-1M32 41v7" {W}/>',
    "window": f'<rect x="15" y="19" width="34" height="26" rx="5" {W}/><path d="M15 27h34M21 23h1M26 23h1" {W}/>',
    "windows": f'<rect x="14" y="22" width="26" height="20" rx="4" {W}/><path d="M24 22v-2a4 4 0 0 1 4-4h18a4 4 0 0 1 4 4v14a4 4 0 0 1-4 4h-6" {W}/>',
    "search": f'<circle cx="29" cy="29" r="11" {W}/><path d="M37 37l10 10" {W}/>',
    "drop": f'<path d="M32 15c7 9 12 14 12 21a12 12 0 0 1-24 0c0-7 5-12 12-21z" {W}/>',
    "cursor": f'<path d="M22 17l22 12-9 3-4 9z" {W}/>',
    "star": f'<path d="M32 16l5 11 12 1-9 8 3 12-11-7-11 7 3-12-9-8 12-1z" {W}/>',
    "camera": f'<path d="M16 25h8l3-5h10l3 5h8v20H16z" {W}/><circle cx="32" cy="34" r="6" {W}/>',
    "mic": f'<rect x="26" y="15" width="12" height="20" rx="6" {W}/><path d="M20 31a12 12 0 0 0 24 0M32 43v6M26 49h12" {W}/>',
    "phone": f'<rect x="22" y="14" width="20" height="36" rx="5" {W}/><path d="M29 44h6" {W}/>',
    "mail": f'<rect x="15" y="20" width="34" height="24" rx="4" {W}/><path d="M17 23l15 12 15-12" {W}/>',
    "calendar": f'<rect x="16" y="20" width="32" height="28" rx="5" {W}/><path d="M16 29h32M24 16v7M40 16v7" {W}/>',
    "warning": f'<path d="M32 17l16 28H16z" {W}/><path d="M32 28v8M32 40v.5" {W}/>',
    "error": f'<circle cx="32" cy="32" r="16" {W}/><path d="M25 25l14 14M39 25L25 39" {W}/>',
    "question": f'<circle cx="32" cy="32" r="16" {W}/><path d="M26 27a6 6 0 1 1 8 5c-2 1-2 2-2 4M32 41v.5" {W}/>',
    "check": f'<circle cx="32" cy="32" r="16" {W}/><path d="M24 33l6 6 11-12" {W}/>',
    "link": f'<path d="M28 36a7 7 0 0 0 10 0l6-6a7 7 0 0 0-10-10l-2 2M36 28a7 7 0 0 0-10 0l-6 6a7 7 0 0 0 10 10l2-2" {W}/>',
    "share": f'<circle cx="43" cy="21" r="5" {W}/><circle cx="21" cy="32" r="5" {W}/><circle cx="43" cy="43" r="5" {W}/><path d="M26 29l12-6M26 35l12 6" {W}/>',
    "cloud": f'<path d="M22 43a8 8 0 0 1-1-16 11 11 0 0 1 21 2 7 7 0 0 1 0 14z" {W}/>',
    "help": f'<circle cx="32" cy="32" r="16" {W}/><path d="M27 27a5 5 0 1 1 7 4c-2 1-2 2-2 4M32 41v.5" {W}/>',
    "log-out": f'<path d="M27 17H19v30h8M35 25l8 7-8 7M43 32H27" {W}/>',
    "moon": f'<path d="M40 18a15 15 0 1 0 6 25 12 12 0 0 1-6-25z" {W}/>',
    "eject": f'<path d="M20 36l12-16 12 16zM20 43h24" {W}/>',
    "game": f'<rect x="14" y="23" width="36" height="20" rx="10" {W}/><path d="M23 29v8M19 33h8M41 31h1M45 35h1" {W}/>',
    "wallet": f'<rect x="15" y="21" width="34" height="24" rx="5" {W}/><path d="M15 29h34M41 35h3" {W}/>',
    "home": f'<path d="M17 31l15-13 15 13M21 28v18h22V28" {W}/>',
    "edit": f'<path d="M18 46l3-10 20-20 7 7-20 20z" {W}/>',
    "tag": f'<path d="M17 17h14l17 17-14 14-17-17z" {W}/><circle cx="25" cy="25" r="2" {W}/>',
    "sync": f'<path d="M45 26a14 14 0 0 0-25-3M19 38a14 14 0 0 0 25 3" {W}/>',
    "chart": f'<path d="M18 46V18M18 46h28M25 38v-8M33 38V24M41 38v-4" {W}/>',
    "toolbox": f'<rect x="15" y="25" width="34" height="21" rx="4" {W}/><path d="M25 25v-4a3 3 0 0 1 3-3h8a3 3 0 0 1 3 3v4M15 34h34" {W}/>',
    "dots": f'<circle cx="22" cy="32" r="2" {W}/><circle cx="32" cy="32" r="2" {W}/><circle cx="42" cy="32" r="2" {W}/>',
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



SETTINGS = {  # icon name -> glyph. Everything System Settings and the shell ask for by name.
    # appearance
    "preferences-desktop-theme-global": "palette", "preferences-desktop-theme": "palette",
    "preferences-desktop-color": "drop", "preferences-desktop-theme-applications": "palette",
    "preferences-desktop-icons": "apps", "preferences-desktop-font": "font",
    "preferences-desktop-cursors": "cursor", "preferences-desktop-wallpaper": "picture",
    "preferences-desktop-theme-windowdecorations": "window", "preferences-desktop-screensaver": "lock",
    "preferences-system-splash": "rocket", "preferences-desktop-effects": "star",
    "preferences-desktop-text-to-speech": "audio", "preferences-desktop-notification": "bell",
    "preferences-desktop-notification-bell": "bell", "system-lock-screen": "lock",
    "preferences-system-login": "user", "preferences-desktop-user": "user", "system-users": "users",
    "user-identity": "user", "avatar-default": "user", "preferences-desktop-user-password": "lock",
    # workspace
    "preferences-system-windows": "windows", "preferences-system-windows-actions": "windows",
    "preferences-system-windows-move": "windows", "preferences-system-tabbox": "windows",
    "preferences-system-windows-effect": "star", "preferences-desktop-activities": "star",
    "preferences-desktop-virtual": "windows", "preferences-desktop-launch-feedback": "rocket",
    "preferences-desktop-keyboard-shortcut": "shortcut", "preferences-desktop-keyboard": "keyboard",
    "preferences-desktop-default-applications": "apps", "preferences-desktop-filetype-association": "document",
    "preferences-desktop-locale": "language", "preferences-desktop-locale-spelling": "language",
    "preferences-system-time": "clock", "preferences-system-session-services": "toolbox",
    "preferences-system-startup": "rocket", "preferences-system-search": "search",
    "preferences-system-power-management": "battery", "preferences-system-power": "power",
    "preferences-desktop-accessibility": "person", "preferences-desktop-peripherals": "mouse",
    "preferences-desktop-display": "display", "preferences-desktop-display-color": "drop",
    "preferences-desktop-display-randr": "display", "preferences-desktop-multimedia": "audio",
    "preferences-desktop-sound": "audio", "preferences-desktop-online-accounts": "cloud",
    "preferences-online-accounts": "cloud", "preferences-desktop-gestures": "touchpad",
    "preferences-desktop-tablet": "touchpad", "preferences-desktop-remote-desktop": "display",
    "preferences-desktop-navigation": "cursor", "preferences-desktop-menu": "apps",
    # privacy and security
    "preferences-system-privacy": "shield", "preferences-security": "shield", "security-high": "shield",
    "preferences-system-firewall": "shield", "preferences-desktop-cryptography": "lock",
    "kwalletmanager": "wallet", "kwallet": "wallet", "preferences-system-privacy-activities": "shield",
    # hardware
    "input-keyboard": "keyboard", "input-mouse": "mouse", "input-touchpad": "touchpad",
    "input-tablet": "touchpad", "input-gaming": "game", "input-gamepad": "game",
    "video-display": "display", "video-display-brightness": "display", "kscreen": "display",
    "audio-card": "audio", "audio-headphones": "audio", "audio-headset": "mic",
    "audio-input-microphone": "mic", "audio-speakers": "audio", "multimedia-player": "audio",
    "printer": "printer", "preferences-desktop-printer": "printer", "preferences-system-printer": "printer",
    "smartphone": "phone", "phone": "phone", "kdeconnect": "phone", "camera-photo": "camera",
    "camera-web": "camera", "camera-video": "camera", "battery": "battery", "battery-full": "battery",
    "preferences-system-bluetooth": "bluetooth", "bluetooth": "bluetooth",
    "preferences-system-network": "network", "preferences-system-network-wired": "network",
    "preferences-system-network-wireless": "network", "network-wireless": "network", "network-wired": "network",
    "preferences-system-network-proxy": "network", "preferences-system-network-share": "share",
    "preferences-system-network-vpn": "shield", "preferences-system-firewall-new": "shield",
    "network-server": "computer", "preferences-system-sharing": "share",
    # categories and general
    "preferences-system": "settings", "preferences-other": "settings", "preferences-desktop": "settings",
    "configure": "settings", "settings-configure": "settings", "applications-system": "settings",
    "applications-all": "apps", "applications-other": "apps", "applications-internet": "globe",
    "applications-multimedia": "audio", "applications-office": "document", "applications-graphics": "picture",
    "applications-games": "game", "applications-development": "code", "applications-accessories": "toolbox",
    "applications-utilities": "toolbox", "applications-education": "star", "applications-science": "chart",
    "applications-engineering": "settings", "applications-science-and-math": "calc",
    "preferences-system-network-and-connectivity": "network", "plasma": "home", "plasmashell": "home",
    "kde": "home", "start-here-kde": "home", "start-here": "home", "distributor-logo": "home",
    "system-run": "terminal", "system-search": "search", "system-software-install": "store",
    "system-software-update": "update", "system-reboot": "sync", "system-restart": "sync",
    "system-shutdown": "power", "system-suspend": "moon", "system-hibernate": "moon", "system-log-out": "log-out",
    "system-switch-user": "users", "preferences-system-kde-connect": "phone",
    "help-about": "info", "help-contents": "help", "help-browser": "help", "help-faq": "help",
    "dialog-information": "info", "dialog-warning": "warning", "dialog-error": "error",
    "dialog-question": "question", "dialog-ok": "check", "dialog-ok-apply": "check",
    "emblem-important": "warning", "emblem-default": "check", "emblem-favorite": "star",
    "internet-mail": "mail", "mail-client": "mail", "kmail": "mail", "office-calendar": "calendar",
    "korganizer": "calendar", "accessories-text-editor": "text", "accessories-character-map": "language",
    "accessories-dictionary": "document", "accessories-camera": "camera", "accessories-screenshot": "capture",
    "applets-screenshooter": "capture", "internet-web-browser": "globe", "internet-chat": "mail",
    "text-editor": "text", "kate": "text", "kcolorchooser": "drop", "color-management": "drop",
    "preferences-color": "drop", "fonts": "font", "preferences-desktop-fonts": "font",
    "document-open": "files", "folder-open-symbolic": "files", "baloo": "search", "krunner": "search",
    "kfind": "search", "org.kde.kfind": "search", "kmenuedit": "apps", "org.kde.kmenuedit": "apps",
    "org.kde.plasma.emojier": "star", "preferences-desktop-emoticons": "star", "face-smile": "star",
    "plasma-browser-integration": "globe", "org.kde.plasma.digitalclock": "clock",
    "preferences-system-time-clock": "clock", "org.kde.kscreen": "display", "org.kde.kdeconnect.app": "phone",
    "org.kde.kwalletmanager5": "wallet", "org.kde.kwalletmanager": "wallet",
    "org.kde.kmousetool": "mouse", "org.kde.kmag": "search", "org.kde.kmousetool.desktop": "mouse",
    "org.kde.drkonqi": "warning", "drkonqi": "warning", "tools-report-bug": "warning", "bug": "warning",
    "org.kde.kinfocenter": "info", "hwinfo": "chart", "preferences-system-performance": "chart",
    "utilities-system-monitor": "monitor", "preferences-system-os-updates": "update",
    "plasma-discover": "store", "discover": "store", "emblem-downloads": "install",
    "folder-cloud": "cloud", "network-workgroup-symbolic": "network", "applications-science-symbolic": "chart",
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
    for theme, parent in (("Lareon", "LareonBase,Papirus-Dark"), ("LareonLight", "LareonBaseLight,Papirus-Light")):
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
        sp = os.path.join(d, "scalable", "apps")
        for name, g in SETTINGS.items():
            if g in APP_GLYPHS:
                with open(os.path.join(sp, name + ".svg"), "w") as f:
                    f.write(app_icon(g))
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

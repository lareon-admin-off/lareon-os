#!/bin/bash
# Build the Lareon OS ISO. Runs as root inside a Debian 13 (trixie)
# container; .github/workflows/build-iso.yml does this for you.
#
#   VERSION=0.1.0 ./build.sh          full build -> out/lareon-os-0.1.0-amd64.iso
#   ./build.sh --packages-only        just the Lareon .deb packages (fast check)
#
# Optional environment:
#   LAREON_RELEASES_TOKEN   GitHub token that can read the Lareon app repos
#                           (only needed if those repos are private)
#   MAX_ISO_BYTES           size limit, default 2000000000 (GitHub's 2 GB cap)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")" && pwd)"
VERSION="${VERSION:-$(cat "$ROOT/VERSION")}"
WORK="$ROOT/work"
OUT="$ROOT/out"
MAX_ISO_BYTES="${MAX_ISO_BYTES:-2000000000}"
APP_REPOS=("lareon-admin-off/lareon-desktop" "lareon-admin-off/ember")

say()  { printf '\n\033[1;38;2;255;124;31m==> %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

rm -rf "$WORK"
mkdir -p "$WORK" "$OUT"

# ------------------------------------------------------------ 1. artwork
say "Rendering artwork"
cp -a "$ROOT/packages" "$WORK/packages"
find "$WORK/packages" -name __pycache__ -prune -exec rm -rf {} +
WALL="$WORK/packages/lareon-timeofday/usr/share/lareon/wallpapers/timeofday"
mkdir -p "$WALL"
# The real Lareon scene (artwork/kit), 4 palettes + blends = 32 frames
python3 "$ROOT/artwork/render_wallpapers.py" "$WALL"
for i in $(seq -w 0 31); do
    [ -f "$WALL/f$i.png" ] || die "wallpaper frame f$i.png is missing"
done

# Lareon brand kit: exact files, copied as they are (never redrawn)
BRAND="$ROOT/artwork/brand"
LOGOS="$BRAND/logos"
for f in lareon-icon.svg lareon-icon-256.png lareon-icon-512.png lareon-app-icon.png \
         fledge-logo.svg fledge-logo-256.png fledge-logo-512.png \
         aster-logo.svg aster-logo-256.png aster-logo-512.png \
         dusk-logo.svg dusk-logo-256.png dusk-logo-512.png \
         ember-logo.svg ember-logo-256.png ember-logo-512.png; do
    [ -f "$LOGOS/$f" ] || die "artwork/brand/logos/$f is missing (it comes from the Lareon brand kit)"
done
BP="$WORK/packages/lareon-branding"
HI="$BP/usr/share/icons/hicolor"
install_icon() {  # icon-name  brand-kit-file-prefix
    install -Dm644 "$LOGOS/$2.svg"     "$HI/scalable/apps/$1.svg"
    install -Dm644 "$LOGOS/$2-256.png" "$HI/256x256/apps/$1.png"
    install -Dm644 "$LOGOS/$2-512.png" "$HI/512x512/apps/$1.png"
}
install_icon lareon        lareon-icon   # the company mark = the OS logo
install_icon lareon-fledge fledge-logo
install_icon lareon-aster  aster-logo
install_icon lareon-dusk   dusk-logo
install_icon lareon-ember  ember-logo
install -Dm644 "$LOGOS/lareon-icon-512.png" "$BP/usr/share/pixmaps/lareon-logo.png"
install -Dm644 "$LOGOS/lareon-app-icon.png" "$BP/usr/share/pixmaps/lareon-desktop.png"
install -Dm644 "$LOGOS/lareon-icon-256.png" "$BP/usr/share/plymouth/themes/lareon/lareon.png"

# Geist fonts. The static files cover the weights the desktop uses; the
# variable files are the same family again, and installing both makes apps
# pick between duplicates unpredictably.
for f in Geist-Regular Geist-Medium Geist-SemiBold Geist-Bold GeistMono-Regular GeistMono-Medium; do
    [ -f "$BRAND/fonts/$f.ttf" ] || die "artwork/brand/fonts/$f.ttf is missing"
    install -Dm644 "$BRAND/fonts/$f.ttf" "$BP/usr/share/fonts/truetype/geist/$f.ttf"
done
install -Dm644 "$BRAND/fonts/OFL.txt" "$BP/usr/share/fonts/truetype/geist/OFL.txt"
install -Dm644 "$BRAND/fonts/OFL.txt" "$BP/usr/share/doc/lareon-branding/geist-OFL.txt"

# Colour schemes and system-wide desktop defaults
python3 "$ROOT/artwork/make_color_schemes.py" "$BP/usr/share/color-schemes" "$BP/etc/xdg/kdeglobals"

# Global themes (System Settings > Colors & Themes > Global Theme)
LNF="$BP/usr/share/plasma/look-and-feel"
make_theme() {  # id  name  description  scheme  icons  splash-bg  splash-track  preview-frame
    local d="$LNF/$1"
    cp -a "$LNF/lareon-template" "$d"
    install -Dm644 "$LOGOS/lareon-icon.svg" "$d/contents/splash/images/lareon-icon.svg"
    sed -i -e "s/@ID@/$1/g" -e "s/@NAME@/$2/g" -e "s/@DESCRIPTION@/$3/g" -e "s/@SCHEME@/$4/g" \
           -e "s/@ICONS@/$5/g" -e "s/@BG@/$6/g" -e "s/@TRACK@/$7/g" \
           "$d/metadata.json" "$d/contents/defaults" "$d/contents/splash/Splash.qml"
    python3 - "$WALL/f$8.png" "$d/contents/previews" <<'PY'
import os, sys
from PIL import Image
src, out = sys.argv[1:3]
im = Image.open(src).convert("RGB")
im.resize((1920, 1080), Image.LANCZOS).save(os.path.join(out, "fullscreenpreview.jpg"), quality=88)
im.resize((480, 270), Image.LANCZOS).save(os.path.join(out, "preview.png"))
PY
}
make_theme org.lareon.desktop       "Lareon Dark"  "The Lareon OS look, dark"  LareonDark  breeze-dark "#13111b" "#2b2838" 00
make_theme org.lareon.desktop.light "Lareon Light" "The Lareon OS look, light" LareonLight breeze      "#f4effb" "#d9d0ea" 16
rm -rf "$LNF/lareon-template"

# ------------------------------------------------------------ 2. packages
say "Building Lareon packages ($VERSION)"
# fill in @VERSION@ in every text file
{ grep -rlI '@VERSION@' "$WORK/packages" || true; } | while read -r f; do
    sed -i "s/@VERSION@/$VERSION/g" "$f"
done
mkdir -p "$WORK/debs"
for p in "$WORK"/packages/*/; do
    name="$(basename "$p")"
    find "$p" -type d -exec chmod 755 {} +
    find "$p" -type f ! -path '*/DEBIAN/*' -exec chmod 644 {} +
    [ -f "$p/usr/bin/$name" ] && chmod 755 "$p/usr/bin/$name"
    for s in postinst prerm postrm preinst; do
        [ -f "$p/DEBIAN/$s" ] && chmod 755 "$p/DEBIAN/$s"
    done
    dpkg-deb --root-owner-group -Zxz --build "$p" "$WORK/debs/${name}_${VERSION}_all.deb" >/dev/null
    echo "built ${name}_${VERSION}_all.deb"
done
cp "$WORK"/debs/*.deb "$OUT/"

if [ "${1:-}" = "--packages-only" ]; then
    say "Done: packages in $OUT"
    exit 0
fi

# ------------------------------------------------------------ 3. live-build tree
cp -a "$ROOT/live" "$WORK/live"
LIVE="$WORK/live"
# (git doesn't store empty folders, so make the ones live-build expects)
mkdir -p "$LIVE/config/packages.chroot" "$LIVE/config/package-lists"
cp "$WORK"/debs/*.deb "$LIVE/config/packages.chroot/"

CAL="$LIVE/config/includes.chroot_after_packages/etc/calamares/branding/lareon"
sed -i "s/@VERSION@/$VERSION/g" "$CAL/branding.desc"
cp "$LOGOS/lareon-icon-256.png" "$LOGOS/lareon-icon-512.png" "$CAL/"
python3 - "$WALL" "$CAL" <<'PY'
import os, sys
from PIL import Image
wall, cal = sys.argv[1:3]
# installer slides: the Lareon scene at dusk, night, dawn and day
for i, f in enumerate([24, 0, 8, 16], 1):
    Image.open(os.path.join(wall, f"f{f:02d}.png")).convert("RGB").resize((1280, 720), Image.LANCZOS) \
        .save(os.path.join(cal, f"slide-{i}.jpg"), quality=88)
PY

# ------------------------------------------------------------ 4. Lareon apps
say "Looking for Linux builds of the Lareon apps"
EXTRA_PKGS=()
have_ember=false
for repo in "${APP_REPOS[@]}"; do
    auth=()
    [ -n "${LAREON_RELEASES_TOKEN:-}" ] && auth=(-H "Authorization: Bearer $LAREON_RELEASES_TOKEN")
    json="$(curl -fsSL "${auth[@]}" "https://api.github.com/repos/$repo/releases/latest" 2>/dev/null || true)"
    url="$(printf '%s' "$json" | python3 -c '
import json, sys
try:
    assets = json.load(sys.stdin).get("assets", [])
except Exception:
    assets = []
for a in assets:
    n = a["name"].lower()
    if n.endswith(".deb") and ("amd64" in n or "x86_64" in n or "x64" in n):
        print(a["browser_download_url"]); break
' || true)"
    if [ -n "$url" ]; then
        echo "$repo: $url"
        curl -fsSL "${auth[@]}" -H "Accept: application/octet-stream" -o "$LIVE/config/packages.chroot/$(basename "$url")" "$url"
        [[ "$repo" == */ember ]] && have_ember=true
    else
        warn "$repo has no amd64 .deb in its latest release; it won't be preinstalled"
    fi
done
if ! $have_ember; then
    warn "no Ember .deb, so adding firefox-esr so the image still has a browser"
    EXTRA_PKGS+=(firefox-esr)
fi

# ------------------------------------------------------------ 5. package names
say "Checking package names against Debian 13"
apt-get update -qq
LIST="$LIVE/config/package-lists/lareon.list.chroot"
: > "$LIST"
missing=()
while read -r p; do
    apt-cache show "$p" >/dev/null 2>&1 || missing+=("$p")
    echo "$p" >> "$LIST"
done < <(grep -hvE '^\s*(#|$)' "$ROOT/packagelists/required.list"; printf '%s\n' "${EXTRA_PKGS[@]+"${EXTRA_PKGS[@]}"}")
[ ${#missing[@]} -eq 0 ] || die "required packages not found in Debian 13: ${missing[*]}"
while read -r p; do
    if apt-cache show "$p" >/dev/null 2>&1; then
        echo "$p" >> "$LIST"
    else
        warn "optional package '$p' not in Debian 13; skipping it"
    fi
done < <(grep -hvE '^\s*(#|$)' "$ROOT/packagelists/optional.list")
echo "$(wc -l < "$LIST") packages listed"

# ------------------------------------------------------------ 6. build
say "Building the ISO (this takes a while)"
cd "$LIVE"
lb clean --purge >/dev/null 2>&1 || true
lb config
lb build

iso="$(ls -1 "$LIVE"/*.iso 2>/dev/null | head -n1 || true)"
[ -n "$iso" ] || die "live-build finished without an ISO; see build.log"
final="$OUT/lareon-os-${VERSION}-amd64.iso"
mv "$iso" "$final"
cp "$LIVE/build.log" "$OUT/build-${VERSION}.log" 2>/dev/null || true
(cd "$OUT" && sha256sum "$(basename "$final")" > "$(basename "$final").sha256")

size=$(stat -c %s "$final")
say "ISO: $(basename "$final"), $((size / 1000000)) MB"
if [ "$size" -gt "$MAX_ISO_BYTES" ]; then
    die "ISO is $((size / 1000000)) MB, over the $((MAX_ISO_BYTES / 1000000)) MB limit. Trim optional.list (firmware is the biggest part) or raise MAX_ISO_BYTES."
fi

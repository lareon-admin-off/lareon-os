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

BRAND="$WORK/brand"
mkdir -p "$BRAND"
if [ -f "$ROOT/artwork/brand/lareon-logo.png" ]; then
    cp "$ROOT/artwork/brand/lareon-logo.png" "$BRAND/"
else
    warn "artwork/brand/lareon-logo.png not found; using the placeholder mark"
    python3 "$ROOT/artwork/render_brand.py" "$BRAND"
fi
mkdir -p "$WORK/packages/lareon-branding/usr/share/pixmaps"
cp "$BRAND/lareon-logo.png" "$WORK/packages/lareon-branding/usr/share/pixmaps/lareon-logo.png"
mkdir -p "$WORK/packages/lareon-branding/usr/share/icons/hicolor/256x256/apps"
python3 - "$BRAND/lareon-logo.png" "$WORK/packages/lareon-branding/usr/share/icons/hicolor/256x256/apps/lareon.png" <<'PY'
import sys
from PIL import Image
Image.open(sys.argv[1]).convert("RGBA").resize((256, 256), Image.LANCZOS).save(sys.argv[2])
PY

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
python3 - "$WALL" "$CAL" "$BRAND/lareon-logo.png" <<'PY'
import os, sys
from PIL import Image
wall, cal, logo = sys.argv[1:4]
# installer slides: dusk, night, dawn, day frames
for i, f in enumerate([24, 0, 8, 16], 1):
    Image.open(os.path.join(wall, f"f{f:02d}.png")).convert("RGB").resize((1280, 720), Image.LANCZOS) \
        .save(os.path.join(cal, f"slide-{i}.jpg"), quality=88)
lg = Image.open(logo).convert("RGBA")
lg.resize((128, 128), Image.LANCZOS).save(os.path.join(cal, "logo.png"))
lg.resize((256, 256), Image.LANCZOS).save(os.path.join(cal, "welcome.png"))
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

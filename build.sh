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

# ------------------------------------------------------------ 0. preflight
# Every file the build reads, checked up front so a missing one is reported
# straight away (all of them at once) instead of half way through.
REQUIRED_FILES=(
    VERSION
    artwork/render_wallpapers.py artwork/make_color_schemes.py
    artwork/kit/palettes.css artwork/kit/lareon-scene.js
    artwork/brand/fonts/OFL.txt
    packagelists/required.list packagelists/optional.list
    packages/lareon-timeofday/DEBIAN/control
    packages/lareon-timeofday/usr/bin/lareon-timeofday
    packages/lareon-branding/DEBIAN/control
    packages/lareon-branding/DEBIAN/postinst
    packages/lareon-branding/usr/share/lareon/os-release
    packages/lareon-branding/usr/share/lareon/issue
    packages/lareon-branding/usr/share/lareon/issue.net
    packages/lareon-branding/usr/share/plymouth/themes/lareon/lareon.plymouth
    packages/lareon-branding/usr/share/plymouth/themes/lareon/lareon.script
    live/auto/config
    artwork/render_boot_screens.py
    apps/lareon-ui/CMakeLists.txt
    packages/lareon-ui/DEBIAN/control
    packages/lareon-live/DEBIAN/control
    packages/lareon-live/etc/calamares/branding/lareon/branding.desc
    packages/lareon-live/etc/calamares/branding/lareon/welcomeq.qml
    live/config/hooks/normal/0900-lareon-bootmenu.hook.binary
)
for theme in org.lareon.desktop org.lareon.desktop.light; do
    for f in metadata.json contents/defaults contents/splash/Splash.qml \
             contents/layouts/org.kde.plasma.desktop-layout.js; do
        REQUIRED_FILES+=("packages/lareon-branding/usr/share/plasma/look-and-feel/$theme/$f")
    done
done
for f in lareon-icon.svg lareon-icon-256.png lareon-icon-512.png lareon-app-icon.png \
         fledge-logo.svg fledge-logo-256.png fledge-logo-512.png \
         aster-logo.svg aster-logo-256.png aster-logo-512.png \
         dusk-logo.svg dusk-logo-256.png dusk-logo-512.png \
         ember-logo.svg ember-logo-256.png ember-logo-512.png; do
    REQUIRED_FILES+=("artwork/brand/logos/$f")
done
for f in Geist-Regular Geist-Medium Geist-SemiBold Geist-Bold GeistMono-Regular GeistMono-Medium; do
    REQUIRED_FILES+=("artwork/brand/fonts/$f.ttf")
done
missing=()
for f in "${REQUIRED_FILES[@]}"; do
    [ -f "$ROOT/$f" ] || missing+=("$f")
done
if [ ${#missing[@]} -gt 0 ]; then
    printf '\033[1;31merror:\033[0m these files are missing from the repo:\n' >&2
    printf '  %s\n' "${missing[@]}" >&2
    exit 1
fi

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

# Global themes (System Settings > Colors & Themes > Global Theme). Both theme
# folders are committed as real files; the build only adds the Lareon mark for
# the splash screen and the preview pictures.
LNF="$BP/usr/share/plasma/look-and-feel"
finish_theme() {  # theme-id  preview-frame
    local d="$LNF/$1"
    for f in metadata.json contents/defaults contents/splash/Splash.qml \
             contents/layouts/org.kde.plasma.desktop-layout.js; do
        [ -f "$d/$f" ] || die "packages/lareon-branding/usr/share/plasma/look-and-feel/$1/$f is missing"
    done
    install -Dm644 "$LOGOS/lareon-icon.svg" "$d/contents/splash/images/lareon-icon.svg"
    rm -rf "$d/contents/previews"   # always regenerated, so stale files can't linger
    mkdir -p "$d/contents/previews"
    python3 - "$WALL/f$2.png" "$d/contents/previews" <<'PY'
import os, sys
from PIL import Image
src, out = sys.argv[1:3]
im = Image.open(src).convert("RGB")
im.resize((1920, 1080), Image.LANCZOS).save(os.path.join(out, "fullscreenpreview.jpg"), quality=88)
im.resize((480, 270), Image.LANCZOS).save(os.path.join(out, "preview.png"))
PY
}
finish_theme org.lareon.desktop       00   # dark: night frame
finish_theme org.lareon.desktop.light 16   # light: day frame

# Boot screens (Plymouth pictures, GRUB themes for the USB stick and installed system)
GRUB_LIVE="$WORK/grub-live"
python3 "$ROOT/artwork/render_boot_screens.py" "$BP/usr/share/plymouth/themes/lareon" \
    "$GRUB_LIVE" "$BP/usr/share/grub/themes/lareon" "$WALL/f00.png"
if command -v grub-mkfont >/dev/null 2>&1; then
    for d in "$GRUB_LIVE" "$BP/usr/share/grub/themes/lareon"; do
        for sz in 14 16 18; do grub-mkfont -n Geist -s $sz -o "$d/geist-regular-$sz.pf2" "$BRAND/fonts/Geist-Regular.ttf"; done
        for sz in 18 28; do grub-mkfont -n Geist -s $sz -o "$d/geist-bold-$sz.pf2" "$BRAND/fonts/Geist-Bold.ttf"; done
    done
else
    warn "grub-mkfont not found: boot menus will use GRUB's default font"
fi

# Installer branding: exact logos and wallpaper slides
CAL="$WORK/packages/lareon-live/etc/calamares/branding/lareon"
cp "$LOGOS/lareon-icon-256.png" "$LOGOS/lareon-icon-512.png" "$CAL/"
python3 - "$WALL" "$CAL" <<'PY'
import os, sys
from PIL import Image
wall, cal = sys.argv[1:3]
for i, f in enumerate([24, 0, 8, 16], 1):
    Image.open(os.path.join(wall, f"f{f:02d}.png")).convert("RGB").resize((1280, 720), Image.LANCZOS) \
        .save(os.path.join(cal, f"slide-{i}.jpg"), quality=88)
PY

# lareon-ui (C++/Qt). SKIP_UI_BUILD=1 skips it (and lareon-live) on machines without Qt.
if [ "${SKIP_UI_BUILD:-}" = 1 ]; then
    warn "SKIP_UI_BUILD=1: not building lareon-ui or lareon-live"
    rm -rf "$WORK/packages/lareon-ui" "$WORK/packages/lareon-live"
else
    say "Compiling lareon-ui"
    command -v cmake >/dev/null || die "cmake and Qt 6 dev packages are needed (or set SKIP_UI_BUILD=1)"
    cmake -S "$ROOT/apps/lareon-ui" -B "$WORK/build-ui" -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr >/dev/null
    cmake --build "$WORK/build-ui" -j"$(nproc)"
    DESTDIR="$WORK/packages/lareon-ui" cmake --install "$WORK/build-ui" >/dev/null
    mkdir -p "$WORK/shlibs/debian"
    printf 'Source: lareon-ui\n\nPackage: lareon-ui\nArchitecture: amd64\n' > "$WORK/shlibs/debian/control"
    shlibs=$(cd "$WORK/shlibs" && dpkg-shlibdeps -O -e"$WORK/packages/lareon-ui/usr/bin/lareon-ui" 2>/dev/null | sed -n 's/^shlibs:Depends=//p')
    [ -n "$shlibs" ] || die "dpkg-shlibdeps found no libraries for lareon-ui"
    sed -i "s|@SHLIBS@|$shlibs|" "$WORK/packages/lareon-ui/DEBIAN/control"
fi

# ------------------------------------------------------------ 2. packages
say "Building Lareon packages ($VERSION)"
# fill in @VERSION@ in every text file
{ grep -rlI '@VERSION@' "$WORK/packages" || true; } | while read -r f; do
    sed -i "s/@VERSION@/$VERSION/g" "$f"
done
# .gitkeep files only exist so git keeps empty folders; they don't ship
find "$WORK/packages" -name .gitkeep -delete
mkdir -p "$WORK/debs"
for p in "$WORK"/packages/*/; do
    name="$(basename "$p")"
    find "$p" -type d -exec chmod 755 {} +
    find "$p" -type f ! -path '*/DEBIAN/*' -exec chmod 644 {} +
    for x in "$p"usr/bin/* "$p"usr/lib/lareon/* "$p"etc/grub.d/*; do
        [ -f "$x" ] && chmod 755 "$x"
    done
    for s in postinst prerm postrm preinst; do
        [ -f "$p/DEBIAN/$s" ] && chmod 755 "$p/DEBIAN/$s"
    done
    arch=$(sed -n 's/^Architecture: //p' "$p/DEBIAN/control")
    dpkg-deb --root-owner-group -Zxz --build "$p" "$WORK/debs/${name}_${VERSION}_${arch}.deb" >/dev/null
    echo "built ${name}_${VERSION}_${arch}.deb"
done
cp "$WORK"/debs/*.deb "$OUT/"

if [ "${1:-}" = "--packages-only" ]; then
    say "Done: packages in $OUT"
    exit 0
fi

# ------------------------------------------------------------ 3. live-build tree
cp -a "$ROOT/live" "$WORK/live"
LIVE="$WORK/live"
find "$LIVE" -name .gitkeep -delete
# (git doesn't store empty folders, so make the ones live-build expects)
mkdir -p "$LIVE/config/packages.chroot" "$LIVE/config/package-lists"
cp "$WORK"/debs/*.deb "$LIVE/config/packages.chroot/"

# Lareon GRUB theme for the USB stick (the boot menu hook uses it)
mkdir -p "$LIVE/config/includes.binary/boot/grub"
cp -a "$GRUB_LIVE" "$LIVE/config/includes.binary/boot/grub/lareon"
sed -i "s/@VERSION@/$VERSION/g" "$LIVE/config/includes.binary/boot/grub/lareon/theme.txt"

# ------------------------------------------------------------ 4. Lareon apps
say "Looking for Linux builds of the Lareon apps"
EXTRA_PKGS=()
have_ember=false
for repo in "${APP_REPOS[@]}"; do
    # built from source by the workflow (app-debs/): preferred over releases
    built="$(ls -1 "$ROOT"/app-debs/"$(basename "$repo")"_*.deb 2>/dev/null | head -n1 || true)"
    if [ -n "$built" ]; then
        echo "$repo: using $(basename "$built")"
        cp "$built" "$LIVE/config/packages.chroot/"
        [[ "$repo" == */ember ]] && have_ember=true
        continue
    fi
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
# An app package must not ship a file one of our packages already owns (for
# example the Lareon icon): dpkg refuses to install it and the build stops.
# Our copy wins; the clashing files are taken out of the app package.
say "Checking the app packages for files that clash with ours"
OURS="$(mktemp)"
for d in "$WORK"/debs/*.deb; do
    dpkg-deb -c "$d" | awk '$1 !~ /^d/ {sub(/^\.\//, "", $6); print "/" $6}'
done | sort -u > "$OURS"
for d in "$LIVE"/config/packages.chroot/*.deb; do
    [ -e "$WORK/debs/$(basename "$d")" ] && continue          # one of ours
    clash="$(dpkg-deb -c "$d" | awk '$1 !~ /^d/ {sub(/^\.\//, "", $6); print "/" $6}' | sort -u | comm -12 - "$OURS" || true)"
    [ -z "$clash" ] && continue
    echo "$(basename "$d"): dropping files we already ship:"; echo "$clash" | sed 's/^/    /'
    tmp="$(mktemp -d)"
    dpkg-deb -R "$d" "$tmp"
    while IFS= read -r f; do rm -f "$tmp$f"; done <<< "$clash"
    dpkg-deb --root-owner-group -Zxz -b "$tmp" "$d.new" >/dev/null && mv "$d.new" "$d"
    rm -rf "$tmp"
done
rm -f "$OURS"

# The apps' own menu entries are replaced by ours, so the icon is always the
# Lareon one and the dock launchers (lareon.desktop, ember.desktop) always
# point at a real program.
say "Writing the menu entries for the Lareon apps"
write_entry() {  # root  exe  Name  Comment  Icon  Categories
    local root="$1" exe="$2" bin=""
    if [ -e "$root/usr/bin/$exe" ] || [ -L "$root/usr/bin/$exe" ]; then
        bin="/usr/bin/$exe"
    else
        bin="$(cd "$root" && find opt -maxdepth 2 -name "$exe" -type f 2>/dev/null | head -n1 || true)"
        [ -n "$bin" ] && bin="/$bin"
    fi
    [ -z "$bin" ] && { warn "no '$exe' program inside the package"; return 1; }
    rm -f "$root"/usr/share/applications/*.desktop
    mkdir -p "$root/usr/share/applications"
    cat > "$root/usr/share/applications/$exe.desktop" <<EOT
[Desktop Entry]
Type=Application
Name=$3
Comment=$4
Exec=$bin %U
Icon=$5
Terminal=false
Categories=$6
StartupWMClass=$exe
StartupNotify=true
EOT
}
for d in "$LIVE"/config/packages.chroot/*.deb; do
    [ -e "$WORK/debs/$(basename "$d")" ] && continue
    pkg="$(dpkg-deb -f "$d" Package)"
    case "$pkg" in
        lareon-desktop) exe=lareon; name="Lareon"; comment="Your Lareon apps in one place"; icon=lareon; cats="Network;Office;" ;;
        ember)          exe=ember;  name="Ember";  comment="The Lareon web browser";        icon=lareon-ember; cats="Network;WebBrowser;" ;;
        *) continue ;;
    esac
    tmp="$(mktemp -d)"
    dpkg-deb -R "$d" "$tmp"
    if write_entry "$tmp" "$exe" "$name" "$comment" "$icon" "$cats"; then
        dpkg-deb --root-owner-group -Zxz -b "$tmp" "$d.new" >/dev/null && mv "$d.new" "$d"
        echo "$pkg: menu entry $exe.desktop (icon $icon)"
    fi
    rm -rf "$tmp"
done

if ! $have_ember; then
    warn "no Ember .deb, so adding firefox-esr so the image still has a browser"
    EXTRA_PKGS+=(firefox-esr)
    # the dock still has a browser in Ember's place
    mkdir -p "$LIVE/config/includes.chroot_after_packages/usr/share/applications"
    cat > "$LIVE/config/includes.chroot_after_packages/usr/share/applications/ember.desktop" <<'EOT'
[Desktop Entry]
Type=Application
Name=Web Browser
Exec=firefox-esr %u
Icon=web-browser
Terminal=false
Categories=Network;WebBrowser;
EOT
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

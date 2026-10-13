#!/bin/bash
# Check that the project builds from a clean checkout, the way GitHub sees it.
#
#   tools/check-clean-checkout.sh                 check this folder
#   tools/check-clean-checkout.sh lareon-os.zip   check a zip before uploading it
#
# It copies the project into a temporary folder, makes a git repository of it,
# makes a fresh `git clone` (so only files git keeps are there: no empty
# folders, nothing from .gitignore), then runs the tests and
# `./build.sh --packages-only` there. Needs git, python3 with Pillow and numpy,
# and dpkg-deb (Debian/Ubuntu). Your own folder is never changed.
set -euo pipefail

SRC="${1:-$(cd "$(dirname "$0")/.." && pwd)}"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

echo "==> Preparing a clean copy in $TMP"
if [ -f "$SRC" ]; then
    mkdir "$TMP/unzipped"
    python3 -c 'import sys, zipfile; zipfile.ZipFile(sys.argv[1]).extractall(sys.argv[2])' "$SRC" "$TMP/unzipped"
    # the zip has one top folder (lareon-os/)
    top="$(find "$TMP/unzipped" -mindepth 1 -maxdepth 1 -type d | head -n1)"
    [ -n "$top" ] && [ -f "$top/build.sh" ] || { echo "error: no build.sh at the top of the zip" >&2; exit 1; }
    # zip files may not keep the "executable" mark; git on GitHub does, so restore it
    chmod +x "$top/build.sh" "$top"/tools/*.sh "$top"/live/auto/* \
             "$top"/live/config/hooks/normal/*.hook.chroot \
             "$top"/packages/lareon-timeofday/usr/bin/lareon-timeofday 2>/dev/null || true
else
    mkdir "$TMP/unzipped"
    top="$TMP/unzipped/lareon-os"
    cp -a "$SRC" "$top"
    rm -rf "$top/.git" "$top/work" "$top/out"
fi

git -C "$top" init -q
git -C "$top" add -A
git -C "$top" -c user.name=check -c user.email=check@lareon.invalid commit -qm "clean checkout check"
git clone -q "$top" "$TMP/clone"
cd "$TMP/clone"
echo "    $(git ls-files | wc -l) files tracked by git"

echo "==> Running the time-of-day tests"
python3 tests/test_timeofday.py | tail -n 1

echo "==> Running ./build.sh --packages-only"
./build.sh --packages-only

echo "==> Checking the packages"
for d in out/*.deb; do
    dpkg-deb --info "$d" >/dev/null
    echo "    ok  $(basename "$d")  ($(stat -c %s "$d") bytes)"
done
if dpkg-deb -c out/lareon-branding_*_all.deb | grep -q '\.gitkeep'; then
    echo "error: .gitkeep files ended up in a package" >&2; exit 1
fi
echo "==> Clean checkout builds."

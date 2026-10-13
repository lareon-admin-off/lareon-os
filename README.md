# Lareon OS

A desktop operating system from Lareon, built on Debian 13 ("trixie") with
KDE Plasma 6. It runs any Linux app, and comes with the Lareon look: the
Lareon mountains wallpaper that follows the time of day, a Lareon-branded
installer, and privacy by default.

This repository is **stage 1: the proof of concept** (see [ROADMAP.md](ROADMAP.md)).

## What's in it

| Path | What it is |
|---|---|
| `artwork/kit/` | The real Lareon scene and palettes, from the Lareon desktop app |
| `artwork/render_wallpapers.py` | Draws the scene as 32 still frames (4 palettes + blends), 3840×2160 |
| `artwork/brand/` | The Lareon brand kit: logos, Geist fonts, colours (exact files, never redrawn) |
| `artwork/make_color_schemes.py` | Turns the brand colours into the Lareon Dark and Light colour schemes |
| `docs/LANGUAGES.md` | The 17 languages for the installer and first-boot setup (stage 2) |
| `packages/lareon-timeofday/` | The wallpaper switcher (`lareon-timeofday`) and its timers |
| `packages/lareon-branding/` | System name, boot menu name, sign-in screen, desktop defaults |
| `live/` | Debian live-build settings for the ISO, installer look, build hooks |
| `packagelists/` | What goes on the image: `required.list` and `optional.list` |
| `build.sh` | Builds everything; run by GitHub Actions |
| `tests/` | Checks for the time-of-day schedule |

## Building

Everything builds on GitHub Actions; you don't need Linux on your own machine.

1. Push this folder to a new GitHub repo (for example `lareon-admin-off/lareon-os`).
   Make the repo **public**: free accounts get only 500 MB of Actions storage on
   private repos, and one ISO is bigger than that.
2. Every push runs the fast **packages** job (about 5 minutes): lints the
   scripts, tests the schedule, builds the two Lareon packages.
3. To build the ISO: **Actions → Build Lareon OS → Run workflow**, or push a
   tag like `v0.1.0`. It takes 30–60 minutes. The ISO appears under the run's
   **Artifacts** as a zip (kept 14 days). Download it, unzip, and publish it
   yourself.
4. If the build fails, download the `build-log` artifact and look near the end.

The build stops before the slow part if a required package name doesn't
exist in Debian 13, and drops optional ones with a warning (shown in the log).

### Size

GitHub Releases caps each file at 2 GB, so the build fails if the ISO is
over 2,000 MB. Expect roughly 1.5–2 GB. If it's over:
- the biggest optional part is hardware firmware in `packagelists/optional.list`;
- `firefox-esr` (~250 MB) is only added when there is no Linux build of Ember.

### Lareon apps

The build looks at the latest releases of `lareon-admin-off/lareon-desktop`
and `lareon-admin-off/ember` for an `amd64` `.deb` file and preinstalls any it
finds. If those repos are private, add a repo secret `LAREON_RELEASES_TOKEN`
(a GitHub token with read access to them).

### Brand kit

`artwork/brand/` is the Lareon brand kit, used exactly as supplied:

| File | Where it appears |
|---|---|
| `lareon-icon.svg` / `-256` / `-512` | The OS logo: app launcher button, About page, installer, boot screen, sign-in splash (icon name `lareon`) |
| `lareon-app-icon.png` | Lareon desktop app icon (`/usr/share/pixmaps/lareon-desktop.png`) |
| `fledge-`, `aster-`, `dusk-`, `ember-logo` | Installed as icons `lareon-fledge`, `lareon-aster`, `lareon-dusk`, `lareon-ember` for each product's launcher entry |
| `Geist-*.ttf`, `GeistMono-*.ttf` | System interface font and monospace font, for every app (static weights; the variable files stay in the repo) |
| Colours in `README.md` | Lareon Dark (default) and Lareon Light colour schemes and global themes |

To update a logo, replace the file in `artwork/brand/logos/` with the same name.
The build stops if any expected file is missing.

## The time-of-day wallpaper

`lareon-timeofday` blends the scene through night, dawn, day and dusk on the
computer's clock (schedule in the script's header), checks every 5 minutes,
and catches up straight after the computer wakes from sleep. The sign-in
screen follows the same schedule.

If someone picks a different wallpaper in Plasma, it leaves their choice
alone. `lareon-timeofday enable` turns it back on. Per-user settings live in
`~/.config/lareon/timeofday.conf` (including `follow_sun=true` to line dawn
and dusk up with real sunrise and sunset, worked out offline).

To preview the frames on any computer with Python:

```
pip install pillow numpy
python3 artwork/render_wallpapers.py preview --width 1920 --height 1080
```

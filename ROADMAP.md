# Lareon OS roadmap

Base: **Debian 13 "trixie" + KDE Plasma 6**, installer **Calamares**.

Why this base:
- **Plasma** is built to be restyled: global themes, colour schemes, panel
  layouts, launcher, sign-in and lock screens are all swappable without
  forking anything. GNOME's apps deliberately resist theming. Every KDE app
  (Files, Photos, PDF, Calculator, System Monitor) picks up the Lareon look for
  free, which is what keeps the custom-app count low.
- **Debian over Ubuntu**: no Snap store, no Ubuntu telemetry prompts, no
  Canonical branding to strip out, and Debian's signed boot files work with
  Secure Boot as long as we don't rebuild the kernel.
- **Calamares** is Qt like Plasma, and its screens can be rewritten in QML,
  which is how the installer gets a real Lareon look rather than a recolour.

Effort sizes: **S** = days, **M** = a couple of weeks, **L** = a month or more,
for one person working part-time.

---

## Stage 1 — Proof of concept (this repo)  · S
- [x] Debian 13 + Plasma live image, built by GitHub Actions, size-checked under 2 GB
- [x] Real Lareon scene, 32 frames, blending night → dawn → day → dusk on the clock
- [x] Same frame on desktop, lock screen and sign-in screen
- [x] System name "Lareon OS" that survives Debian upgrades (`dpkg-divert`)
- [x] Installer with Lareon colours, logo and slideshow (Debian's install steps)
- [x] Flathub in Discover; telemetry pinned off
- [ ] **You:** first CI build, test in a VM ([TESTING.md](TESTING.md))
- [x] Lareon brand kit: logos, Geist fonts, Lareon Dark/Light themes, boot screen, sign-in splash

## Stage 1.5 — Lareon update channel  · S  (do before anyone installs it for real)
Right now Lareon's own pieces only update by reinstalling. Before real users:
- An apt repository for `lareon-*` packages, built by Actions and hosted free
  on GitHub Pages (packages are tiny; only the ISO is big).
- A signing key for it. **Keep this key safe**: whoever holds it can push
  software to every Lareon OS machine. Store it only as a GitHub secret.
- Debian's own security updates already flow from Debian; nothing to do there.

## Stage 2 — Install and set up with no desktop showing  · M–L

**Rule: nobody sees the desktop until setup is finished.** Mockups of the whole
flow are in the "setup flow" PNGs (boot menu, installer, first-start setup).

### 2a. The USB stick boots straight into the installer  · S–M
- Lareon boot menu (GRUB theme) with **Install Lareon OS** as the default
  (starts by itself after 8 seconds), then **Try Lareon OS without
  installing**, **Install with safe graphics** and **Firmware settings**.
- "Install" starts a special session that runs only the installer, full
  screen: no panel, no desktop, no other apps. Mostly configuration: the live
  system signs in automatically to a session whose only program is Calamares
  in a bare window manager, and closing it restarts or shuts down.
- "Try" keeps today's live desktop, so people can check Wi-Fi, sound and the
  screen before erasing anything. Keep it: without it, broken hardware is only
  discovered after the drive is wiped.

### 2b. The installer itself: three short steps  · M
- **Language**: the 17 languages and flags in `docs/LANGUAGES.md` (Darija with
  the Algerian flag; Arabic, Farsi and Darija right to left), plus keyboard.
  Lareon's own screens reuse the Lareon desktop app's translations. Calamares'
  built-in text comes from the Calamares project, which has no Darija, so those
  bits would show in Arabic or English for Darija.
- **Drive**: erase / install next to Windows / manual, plus "Encrypt the drive"
  with its password. Calamares' partitioning logic, restyled, not rebuilt:
  partitioning is where bugs lose people's data.
- **Install**: progress with the Lareon slideshow, then restart.
- No user account in the installer. Calamares' "OEM" mode installs the system
  and leaves account creation to the first start.
- Built with Calamares' QML pages so every page can follow the Lareon layout
  (full screen, step bar, Back/Continue).

### 2c. First-start setup, before the desktop exists  · M–L
- On the first start the computer goes to a full-screen Lareon setup instead of
  the sign-in screen. Steps: **Wi-Fi**, **your account** (name, username,
  password, computer name, picture), **Lareon account** (sign in, create one,
  or skip), **look** (Lareon Dark / Light, time-of-day wallpaper), **privacy**
  (crash reports ask/never, real sunrise from time zone only, automatic update
  checks), then **"You're all set"** → the desktop appears for the first time.
- Lareon account sign-in lives here, not in the installer: the user is online
  and the sign-in goes straight into their own account.
- This replaces the stage 5 welcome tour (one custom app, not two).
- Technically it's a small app that runs once with permission to create the
  first user, then removes itself. KDE has been building a first-start setup
  tool of its own (Plasma Setup); check its state before writing ours, since
  restyling it would be less code to maintain.
- Risk to test hard: if setup crashes halfway, the computer must still be
  usable (it reopens setup on the next start rather than leaving no account).

## Stage 3 — Lareon Settings and Files  · M
- **Lareon Settings**: a friendly home screen (Display, Wi-Fi, Sound, Accounts,
  Updates, Wallpaper) where each tile opens the real Plasma settings page for
  it. Building our own replacements for those pages would mean re-doing them
  every Plasma release.
- Wallpaper page: on/off, follow sunrise/sunset, set my town.
- **Files**: Dolphin with Lareon styling, a Dusk notes shortcut in the
  sidebar and Lareon right-click actions. Not a new file manager.

## Stage 4 — Lareon shell  · L
- Done in stage 1: Lareon Dark/Light global themes, colour schemes, Geist
  fonts, launcher mark, boot screen, sign-in splash.
- Next: a Lareon Plasma style (panel and widget shapes), custom launcher if
  Kickoff can't be styled far enough (a QML widget), boot menu theme, own
  sign-in screen (SDDM QML theme), sound set.

## Stage 5 — Lareon apps and Aster  · M
- Preinstall the Lareon desktop app and Ember: needs Linux `.deb` builds in
  their repos (the build picks them up automatically).
- **Aster hotkey**: a global shortcut (e.g. Meta+Space) that opens Aster.
  Needs the Lareon desktop app to accept something like `lareon://aster` or
  `--aster` to jump straight to it.
- First-start setup (stage 2c) covers the welcome tour: account, Lareon sign-in, theme, privacy.

### Custom apps: keep it to three
| Need | Use |
|---|---|
| Lareon Settings | **custom** (home screen over real settings) |
| First-start setup | **custom** (stage 2c; or a restyled KDE Plasma Setup) |
| Aster helper | the Lareon desktop app + a hotkey |
| Notes / Dusk | Dusk inside the Lareon desktop app |
| Files | Dolphin, restyled |
| Text editor | KWrite |
| Photos | Gwenview |
| PDF | Okular |
| Calculator | KCalc |
| System monitor | Plasma System Monitor |
| Terminal | Konsole |
| App store | Discover + Flathub |
| Office, media | LibreOffice, VLC from Flathub (they follow the system colours) |

---

## Honest risks

- **An OS is a forever commitment.** Debian does the heavy security work, but
  you'll still rebuild the ISO after Debian point releases, test Plasma
  updates, and plan the move to the next Debian release. Budget for that, or
  the project quietly rots.
- **Don't write a shell from scratch.** A new panel/launcher/window manager is
  years of work for a team. Restyling Plasma gets 90% of the "its own system"
  feel for a small fraction.
- **Secure Boot** only keeps working while we use Debian's signed kernel and
  bootloader unchanged. The firmware boot entry will say "debian"; renaming it
  breaks booting on Secure Boot machines.
- **Hardware** is the part you can't fully test: NVIDIA graphics, unusual
  Wi-Fi chips and laptops' sleep behaviour are where Linux distros get bad
  reviews. Test on every machine you can borrow.
- **Some third-party installers check for "Debian" or "Ubuntu"** by name. Lareon
  OS says it's like Debian, which covers most, but test a few popular ones
  (Chrome, VS Code, Steam).
- **Support load**: people will email help@lareon.org about printers and Wi-Fi.

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
- [ ] **You:** real logo into `artwork/brand/lareon-logo.png`

## Stage 1.5 — Lareon update channel  · S  (do before anyone installs it for real)
Right now Lareon's own pieces only update by reinstalling. Before real users:
- An apt repository for `lareon-*` packages, built by Actions and hosted free
  on GitHub Pages (packages are tiny; only the ISO is big).
- A signing key for it. **Keep this key safe**: whoever holds it can push
  software to every Lareon OS machine. Store it only as a GitHub secret.
- Debian's own security updates already flow from Debian; nothing to do there.

## Stage 2 — The Lareon installer  · M–L
- Own Calamares settings instead of Debian's, using the QML versions of the
  screens (`welcomeq`, `localeq`, `keyboardq`, `usersq`, `summaryq`) so each
  page can be laid out in the Lareon style.
- Language: the same 17 languages and flags as the Lareon app. *Send me the
  list.* Calamares itself is translated by its own project; languages it
  doesn't cover will show partly in English inside the installer.
- Drives: Calamares' partition screen (erase disk / alongside / manual) plus
  the encryption checkbox. Restyle it, don't rebuild it: partitioning is where
  bugs lose people's data.
- Theme choice (light/dark): small custom QML page.
- **Recommendation: move Lareon account sign-in to the first-boot welcome
  tour, not the installer.** The installer often runs without Wi-Fi, and a
  sign-in made there has to be carried into the new system, which is extra
  code handling passwords. On first boot the user is online and in their own
  account.

## Stage 3 — Lareon Settings and Files  · M
- **Lareon Settings**: a friendly home screen (Display, Wi-Fi, Sound, Accounts,
  Updates, Wallpaper) where each tile opens the real Plasma settings page for
  it. Building our own replacements for those pages would mean re-doing them
  every Plasma release.
- Wallpaper page: on/off, follow sunrise/sunset, set my town.
- **Files**: Dolphin with Lareon styling, a Dusk notes shortcut in the
  sidebar and Lareon right-click actions. Not a new file manager.

## Stage 4 — Lareon shell  · L
- A Plasma global theme package: panel layout, launcher, light and dark colour
  schemes with the orange (#ff7c1f) to violet (#a35cf5) gradient, your fonts.
  *Send me the font files and check their licences allow redistribution.*
- Custom launcher if Kickoff can't be styled far enough (a QML widget).
- Boot animation (Plymouth), boot menu theme, sign-in screen (own SDDM QML
  theme), sound set.

## Stage 5 — Lareon apps and Aster  · M
- Preinstall the Lareon desktop app and Ember: needs Linux `.deb` builds in
  their repos (the build picks them up automatically).
- **Aster hotkey**: a global shortcut (e.g. Meta+Space) that opens Aster.
  Needs the Lareon desktop app to accept something like `lareon://aster` or
  `--aster` to jump straight to it.
- First-boot welcome tour: Lareon account sign-in, theme, wallpaper, privacy.

### Custom apps: keep it to three
| Need | Use |
|---|---|
| Lareon Settings | **custom** (home screen over real settings) |
| Welcome tour | **custom** |
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

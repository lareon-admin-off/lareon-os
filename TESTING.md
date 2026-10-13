# Testing Lareon OS

Tick through this after each ISO build. Anything that fails: note what you
saw, and send me the output of the commands in "Collecting details".

## 1. Virtual machine first

Easiest: **GNOME Boxes** or **virt-manager** on Linux, **VirtualBox** on
Windows/Mac. Give it 4 GB RAM, 2 CPUs, a 30 GB disk.
VirtualBox: Settings → System → tick **Enable EFI**; Display → **VMSVGA**, 128 MB.

Test once with EFI on and once with it off (older "BIOS" PCs boot differently).

### Live session
- [ ] Boot menu appears and starts the live system
- [ ] Reaches the Plasma desktop without asking for a password
- [ ] Wallpaper is the Lareon mountains, at the right time of day
- [ ] Open Konsole and run `lareon-timeofday status`: frame and schedule look right
- [ ] `lareon-timeofday table` lists the day's changes
- [ ] **Watch it change**: run these, wait for each, check the wallpaper
      ```
      sudo timedatectl set-ntp false
      sudo date -s "05:15"; systemctl --user start lareon-timeofday.service
      sudo date -s "12:00"; systemctl --user start lareon-timeofday.service
      sudo date -s "18:30"; systemctl --user start lareon-timeofday.service
      sudo date -s "22:00"; systemctl --user start lareon-timeofday.service
      sudo timedatectl set-ntp true
      ```
      Expect: half-way night→dawn, day, dusk (a few stars), night (lots of stars).
- [ ] Lock the screen (Meta+L): same scene behind the clock
- [ ] Pick a different wallpaper in Plasma, wait 6 minutes: your pick stays
- [ ] `lareon-timeofday enable` brings the Lareon scene back
- [ ] System Settings → About this System says **Lareon OS 0.1.0** with the logo
- [ ] `cat /etc/os-release` says Lareon OS
- [ ] Discover opens and can find a Flathub app
- [ ] Sound plays (YouTube in the browser, or any video)

### Installer
- [ ] App launcher → **Install Lareon OS** opens the installer with Lareon colours and logo
- [ ] Slideshow plays during install
- [ ] Install with **Erase disk**, no encryption → reboot → signs in, wallpaper works
- [ ] Install again with **Encrypt system** → asks for the password at boot → works
- [ ] Boot menu says **Lareon OS**
- [ ] Sign-in screen shows the mountains at the current time of day
- [ ] Run `sudo apt update && sudo apt full-upgrade`, reboot: still **Lareon OS**
      in About and `/etc/os-release` (this is the upgrade-proof branding)

## 2. Real hardware

Write the ISO to a USB stick with **balenaEtcher** or **Rufus** (choose "DD
image" if Rufus asks). Boot it from the firmware's boot menu (often F12,
F11, F8 or Esc).

Try the live session before installing; nothing is changed on the computer
until you run the installer.

- [ ] Boots with **Secure Boot ON** (don't turn it off for the test)
- [ ] Screen at the right resolution; external monitor works
- [ ] Wi-Fi connects; Bluetooth finds a device
- [ ] Sound from speakers and headphones; volume keys
- [ ] Touchpad, including two-finger scroll
- [ ] Brightness keys (laptops)
- [ ] Close the lid / sleep, wait, wake: wallpaper catches up to the right time
      within a few seconds
- [ ] Battery percentage shows (laptops)
- [ ] Webcam works (in any video call site)
- [ ] Shut down and restart work cleanly

Record the computer model and anything odd.

## Collecting details

```
lareon-timeofday status
journalctl -b -p err --no-pager | tail -50
sudo dmesg | grep -iE "firmware|error" | tail -30
lspci -nnk | grep -A3 -iE "vga|network|audio"
```

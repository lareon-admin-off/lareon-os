// Lareon OS default desktop.
//   top:    a slim bar - clock on the left, tray on the right
//   left:   a floating rail - the Lareon mark (all apps), then Lareon, Ember, Files, ...
//   behind: the time-of-day wallpaper
// The stock Plasma panel is loaded first and removed only once the new bars
// exist, so if anything below fails the desktop still comes up with a panel.
loadTemplate("org.kde.plasma.desktop.defaultPanel")

function lareonTry(fn) { try { fn() } catch (e) {} }

var oldPanels = panels()
var built = false
try {
    // ---- top bar: clock on the left, tray on the right, nothing else ----
    var top = new Panel
    top.location = "top"
    lareonTry(function () { top.height = 30 })
    lareonTry(function () { top.floating = false })
    lareonTry(function () { top.lengthMode = "fill" })
    lareonTry(function () { top.opacity = "translucent" })

    var clock = top.addWidget("org.kde.plasma.digitalclock")
    lareonTry(function () {
        clock.currentConfigGroup = ["Appearance"]
        clock.writeConfig("showDate", "true")
        clock.writeConfig("dateFormat", "custom")
        clock.writeConfig("customDateFormat", "ddd d MMM")
        clock.writeConfig("use24hFormat", "2")
    })
    top.addWidget("org.kde.plasma.panelspacer")
    top.addWidget("org.kde.plasma.systemtray")

    // ---- left rail: the Lareon mark opens every app, then the pinned apps ----
    var dock = new Panel
    dock.location = "left"
    lareonTry(function () { dock.height = 62 })
    lareonTry(function () { dock.floating = true })
    lareonTry(function () { dock.lengthMode = "fit" })
    lareonTry(function () { dock.alignment = "center" })

    var grid = dock.addWidget("org.kde.plasma.kickerdash")
    lareonTry(function () {
        grid.currentConfigGroup = ["General"]
        grid.writeConfig("icon", "lareon")
        grid.writeConfig("useCustomButtonImage", "true")
        grid.writeConfig("customButtonImage", "lareon")
    })
    var tasks = dock.addWidget("org.kde.plasma.icontasks")
    lareonTry(function () {
        tasks.currentConfigGroup = ["General"]
        tasks.writeConfig("launchers",
            "applications:lareon.desktop,applications:ember.desktop," +
            "applications:org.kde.dolphin.desktop,applications:org.kde.discover.desktop," +
            "applications:org.kde.konsole.desktop,applications:systemsettings.desktop")
        tasks.writeConfig("showOnlyCurrentDesktop", "false")
        tasks.writeConfig("iconSpacing", "3")
        tasks.writeConfig("indicateAudioStreams", "true")
    })
    built = true
} catch (e) {
    built = false
}

if (built) {
    for (var i = 0; i < oldPanels.length; i++) {
        lareonTry(function () { oldPanels[i].remove() })
    }
}

var desktops = desktopsForActivity(currentActivity())
for (var d = 0; d < desktops.length; d++) {
    desktops[d].wallpaperPlugin = "org.kde.image"
    desktops[d].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"]
    desktops[d].writeConfig("Image", "file:///var/lib/lareon/timeofday/current.png")
}

// A large clock on the desktop itself, the first thing you see
lareonTry(function () {
    var ds = desktopsForActivity(currentActivity())
    var big = ds[0].addWidget("org.kde.plasma.digitalclock", 90, 70, 460, 190)
    big.currentConfigGroup = ["Appearance"]
    big.writeConfig("autoFontAndSize", "false")
    big.writeConfig("fontFamily", "Geist")
    big.writeConfig("fontSize", "64")
    big.writeConfig("fontWeight", "500")
    big.writeConfig("showDate", "true")
    big.writeConfig("dateDisplayFormat", "BesideTime")
    big.writeConfig("dateFormat", "custom")
    big.writeConfig("customDateFormat", "dddd d MMMM")
    big.writeConfig("use24hFormat", "2")
    big.writeConfig("showSeconds", "Never")
})

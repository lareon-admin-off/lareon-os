// Lareon OS default desktop.
//   top:    a slim bar - app grid on the left, clock in the middle, tray on the right
//   bottom: a floating dock with only app icons (Lareon, Ember, Files, ...)
//   behind: the time-of-day wallpaper
// The stock Plasma panel is loaded first and removed only once the new bars
// exist, so if anything below fails the desktop still comes up with a panel.
loadTemplate("org.kde.plasma.desktop.defaultPanel")

function lareonTry(fn) { try { fn() } catch (e) {} }

var oldPanels = panels()
var built = false
try {
    // ---- top bar ----
    var top = new Panel
    top.location = "top"
    lareonTry(function () { top.height = 32 })
    lareonTry(function () { top.floating = false })
    lareonTry(function () { top.lengthMode = "fill" })
    lareonTry(function () { top.opacity = "translucent" })

    var grid = top.addWidget("org.kde.plasma.kickerdash")
    lareonTry(function () {
        grid.currentConfigGroup = ["General"]
        grid.writeConfig("icon", "lareon")
        grid.writeConfig("useCustomButtonImage", "true")
        grid.writeConfig("customButtonImage", "lareon")
    })
    top.addWidget("org.kde.plasma.panelspacer")
    var clock = top.addWidget("org.kde.plasma.digitalclock")
    lareonTry(function () {
        clock.currentConfigGroup = ["Appearance"]
        clock.writeConfig("showDate", "true")
        clock.writeConfig("dateFormat", "shortDate")
        clock.writeConfig("use24hFormat", "2")
    })
    top.addWidget("org.kde.plasma.panelspacer")
    top.addWidget("org.kde.plasma.systemtray")

    // ---- bottom dock ----
    var dock = new Panel
    dock.location = "bottom"
    lareonTry(function () { dock.height = 54 })
    lareonTry(function () { dock.floating = true })
    lareonTry(function () { dock.lengthMode = "fit" })
    lareonTry(function () { dock.alignment = "center" })
    var tasks = dock.addWidget("org.kde.plasma.icontasks")
    lareonTry(function () {
        tasks.currentConfigGroup = ["General"]
        tasks.writeConfig("launchers",
            "applications:lareon.desktop,applications:ember.desktop," +
            "applications:org.kde.dolphin.desktop,applications:org.kde.discover.desktop," +
            "applications:org.kde.konsole.desktop,applications:systemsettings.desktop")
        tasks.writeConfig("showOnlyCurrentDesktop", "false")
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

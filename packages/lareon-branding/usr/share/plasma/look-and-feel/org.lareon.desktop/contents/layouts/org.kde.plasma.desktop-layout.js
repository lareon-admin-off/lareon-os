// Lareon OS default desktop: Plasma's standard bottom panel, with the
// Lareon mark on the app launcher and the time-of-day wallpaper.
loadTemplate("org.kde.plasma.desktop.defaultPanel")

var allPanels = panels()
for (var i = 0; i < allPanels.length; i++) {
    var launchers = allPanels[i].widgets("org.kde.plasma.kickoff")
    for (var j = 0; j < launchers.length; j++) {
        launchers[j].currentConfigGroup = ["General"]
        launchers[j].writeConfig("icon", "lareon")
    }
}

var desktops = desktopsForActivity(currentActivity())
for (var d = 0; d < desktops.length; d++) {
    desktops[d].wallpaperPlugin = "org.kde.image"
    desktops[d].currentConfigGroup = ["Wallpaper", "org.kde.image", "General"]
    desktops[d].writeConfig("Image", "file:///var/lib/lareon/timeofday/current.png")
}

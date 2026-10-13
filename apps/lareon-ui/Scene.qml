import QtQuick
import Lareon

// Full-screen Lareon background: the time-of-day mountains, faded into the
// dark background at the top so text stays readable.
Rectangle {
    color: Theme.bg

    // The sign-in screen's current frame (kept up to date by lareon-timeofday),
    // or a fixed frame if that isn't available (e.g. in demo screenshots).
    property url frame: Sys.exists("/var/lib/lareon/timeofday/current.png")
                        ? "file:///var/lib/lareon/timeofday/current.png"
                        : "file:///usr/share/lareon/wallpapers/timeofday/f08.png"

    Image {
        id: mountains
        anchors.fill: parent
        source: parent.frame
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignBottom
        opacity: 0.38
        asynchronous: true
    }
    // fade: dark at the top, mountains showing at the bottom
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: Theme.bg }
            GradientStop { position: 0.35; color: Theme.bg }
            GradientStop { position: 0.85; color: Qt.rgba(0.075, 0.067, 0.106, 0.0) }
        }
    }
}

import QtQuick 2.15
import calamares.slideshow 1.0

// Shown while files are copied. Slide images are frames of the Lareon
// wallpaper (dusk, night, dawn, day), copied in by build.sh as slide-*.jpg.
Presentation {
    id: presentation

    Timer {
        interval: 7000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    component LareonSlide: Slide {
        property alias image: bg.source
        property alias title: heading.text
        property alias body: copy.text
        Image {
            id: bg
            anchors.fill: parent
            fillMode: Image.PreserveAspectCrop
        }
        Rectangle {
            anchors.fill: parent
            gradient: Gradient {
                GradientStop { position: 0.35; color: "#00000000" }
                GradientStop { position: 1.0;  color: "#e613111b" }
            }
        }
        Image {
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 28
            source: "lareon-icon-256.png"
            sourceSize.width: 44
            sourceSize.height: 44
        }
        Column {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 36
            spacing: 10
            Text {
                id: heading
                color: "#ece9f5"
                font.family: "Geist"
                font.pixelSize: 30
                font.weight: Font.DemiBold
                wrapMode: Text.WordWrap
                width: parent.width
            }
            Text {
                id: copy
                color: "#a7a4ba"
                font.family: "Geist"
                font.pixelSize: 16
                wrapMode: Text.WordWrap
                width: parent.width
            }
        }
    }

    LareonSlide {
        image: "slide-1.jpg"
        title: qsTr("Welcome to Lareon OS")
        body: qsTr("A calm, private desktop that runs the apps you already use.")
    }
    LareonSlide {
        image: "slide-2.jpg"
        title: qsTr("A desktop that follows the sun")
        body: qsTr("The Lareon mountains move from dawn to day to dusk to night with your computer's clock, and the stars come out in the evening.")
    }
    LareonSlide {
        image: "slide-3.jpg"
        title: qsTr("Private by default")
        body: qsTr("No telemetry, no ads, no tracking. Lareon OS doesn't send anything about you anywhere.")
    }
    LareonSlide {
        image: "slide-4.jpg"
        title: qsTr("Thousands of apps")
        body: qsTr("Get apps from Discover and Flathub, or install any Debian package.")
    }

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }
}

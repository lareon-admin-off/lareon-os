/* Lareon installer: shown while Lareon OS is being installed (step 4, Install).
   Calamares draws its progress bar under this (styled in stylesheet.qss).
   Slide pictures are frames of the Lareon wallpaper (slide-1..4.jpg). */
import QtQuick 2.15
import calamares.slideshow 1.0

Presentation {
    id: presentation

    Timer {
        interval: 7000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Rectangle {
        anchors.fill: parent
        color: "#13111b"
        z: -2
    }

    Column {
        id: heading
        x: Math.max(36, (parent.width - 820) / 2)
        y: 40
        width: Math.min(parent.width - 72, 820)
        spacing: 8
        z: 2
        Text {
            text: qsTr("Installing Lareon OS")
            color: "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            width: parent.width
            wrapMode: Text.WordWrap
            text: qsTr("You can step away. The computer restarts by itself when it’s done.")
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 17
        }
    }

    component LareonSlide: Slide {
        property alias image: bg.source
        property alias title: titleText.text
        property alias body: bodyText.text
        Rectangle {
            id: card
            // same column as the heading: up to 820 px wide, centred
            x: Math.max(36, (parent.width - 820) / 2)
            y: 170
            width: Math.min(parent.width - 72, 820)
            height: Math.min(parent.height - y - 24, width * 0.42)
            radius: 12
            color: "#1a1824"
            border.color: "#2b2838"
            clip: true
            Image {
                id: bg
                anchors.fill: parent
                anchors.margins: 1
                fillMode: Image.PreserveAspectCrop
            }
            Rectangle {
                anchors.fill: parent
                gradient: Gradient {
                    GradientStop { position: 0.4; color: "#0013111b" }
                    GradientStop { position: 1.0; color: "#e613111b" }
                }
            }
            Column {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                anchors.margins: 28
                spacing: 6
                Text {
                    id: titleText
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: "#ece9f5"
                    font.family: "Geist"
                    font.pixelSize: 24
                    font.weight: Font.DemiBold
                }
                Text {
                    id: bodyText
                    width: parent.width
                    wrapMode: Text.WordWrap
                    color: "#a7a4ba"
                    font.family: "Geist"
                    font.pixelSize: 15
                }
            }
        }
    }

    LareonSlide {
        image: "slide-2.jpg"
        title: qsTr("A desktop that follows the sun")
        body: qsTr("The Lareon mountains move from dawn to day to dusk to night with your computer’s clock, and the stars come out in the evening.")
    }
    LareonSlide {
        image: "slide-1.jpg"
        title: qsTr("Private by default")
        body: qsTr("No telemetry, no ads, no tracking. Lareon OS doesn’t send anything about you anywhere.")
    }
    LareonSlide {
        image: "slide-3.jpg"
        title: qsTr("One Lareon account")
        body: qsTr("Fledge, Aster, Dusk and Ember with one free account. You can sign in during setup, or skip it.")
    }
    LareonSlide {
        image: "slide-4.jpg"
        title: qsTr("Thousands of apps")
        body: qsTr("Get apps from Discover and Flathub, or install any Debian package.")
    }

    function onActivate() { presentation.currentSlide = 0; }
    function onLeave() { }
}

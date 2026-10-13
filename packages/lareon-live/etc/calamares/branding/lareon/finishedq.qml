/* Lareon installer, last page: installed. Restarts by itself after a short
   countdown (or straight away with the button). After the restart, the
   first-start setup opens, full screen. */
import io.calamares.core 1.0
import io.calamares.ui 1.0

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Item {
    id: page
    property int seconds: 10

    Timer {
        id: countdown
        interval: 1000
        repeat: true
        onTriggered: {
            page.seconds--
            if (page.seconds <= 0) {
                stop()
                config.doRestart(true)
            }
        }
    }

    Rectangle { anchors.fill: parent; color: "#13111b" }
    Image {
        anchors.fill: parent
        source: "file:///var/lib/lareon/timeofday/current.png"
        fillMode: Image.PreserveAspectCrop
        verticalAlignment: Image.AlignBottom
        opacity: 0.38
    }
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            GradientStop { position: 0.0; color: "#13111b" }
            GradientStop { position: 0.35; color: "#13111b" }
            GradientStop { position: 0.85; color: "#0013111b" }
        }
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -60
        spacing: 0
        Image {
            Layout.alignment: Qt.AlignHCenter
            source: "file:/" + Branding.imagePath(Branding.ProductLogo)
            sourceSize.width: 240
            sourceSize.height: 240
            Layout.preferredWidth: 120
            Layout.preferredHeight: 120
            fillMode: Image.PreserveAspectFit
        }
        Text {
            Layout.topMargin: 28
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("%1 is installed").arg(Branding.string(Branding.ProductName))
            color: "#ece9f5"
            font.family: "Geist"
            font.pixelSize: 40
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 12
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Restarting in %1 seconds. Take out the USB stick when the screen goes dark.").arg(page.seconds)
            color: "#a7a4ba"
            font.family: "Geist"
            font.pixelSize: 17
        }
        Button {
            id: now
            Layout.topMargin: 36
            Layout.alignment: Qt.AlignHCenter
            implicitHeight: 48
            leftPadding: 28
            rightPadding: 28
            hoverEnabled: true
            text: qsTr("Restart now")
            onClicked: { countdown.stop(); config.doRestart(true) }
            contentItem: Text {
                text: now.text
                color: "#13111b"
                font.family: "Geist"
                font.pixelSize: 16
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
            background: Rectangle { radius: 9; color: now.hovered ? "#ff8f3d" : "#ff7c1f" }
        }
    }

    function onActivate() {
        page.seconds = 10
        countdown.start()
    }
    function onLeave() {
        countdown.stop()
    }
}

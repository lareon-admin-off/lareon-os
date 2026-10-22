import QtQuick
import QtQuick.Layouts
import Lareon

// Shown while installing: a few things worth knowing, one at a time.
Item {
    id: root
    implicitWidth: 560
    implicitHeight: 74
    property int idx: 0
    readonly property var tips: [
        { head: qsTr("Settings that do the job"), body: qsTr("Wi-Fi, sound, display, power and more live in one calm window.") },
        { head: qsTr("Private by default"), body: qsTr("No telemetry, no ads, no tracking. Ever.") },
        { head: qsTr("Wallpaper that follows the sun"), body: qsTr("The Lareon mountains move from dawn to night with your clock.") },
        { head: qsTr("Make it yours"), body: qsTr("Pick an accent colour and how lively things move, right after you restart.") },
        { head: qsTr("Almost nothing to learn"), body: qsTr("Press the Meta key to open Lareon Home, and search anything.") }
    ]

    Timer {
        interval: 5000
        running: root.visible
        repeat: true
        onTriggered: fade.restart()
    }
    SequentialAnimation {
        id: fade
        NumberAnimation { target: box; property: "opacity"; to: 0; duration: 280 }
        ScriptAction { script: root.idx = (root.idx + 1) % root.tips.length }
        NumberAnimation { target: box; property: "opacity"; to: 1; duration: 380 }
    }

    Column {
        id: box
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 6
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.tips[root.idx].head
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 18
            font.weight: Font.DemiBold
        }
        Text {
            width: 520
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.Wrap
            text: root.tips[root.idx].body
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 15
        }
    }
}

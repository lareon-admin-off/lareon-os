import QtQuick
import QtQuick.Layouts
import Lareon

// Installed. Restart into the new system.
Item {
    id: root
    property var install
    property bool restarting: false
    property bool stuck: false
    property int seconds: 15

    function restart() {
        if (restarting) {
            return
        }
        restarting = true
        countdown.stop()
        stuckTimer.start()
        root.install.helperCall("reboot", undefined, function(code) { })
    }

    // restarts by itself, so nobody has to find the button
    Timer {
        id: countdown
        interval: 1000
        repeat: true
        running: !root.restarting
        onTriggered: {
            root.seconds -= 1
            if (root.seconds <= 0) {
                root.restart()
            }
        }
    }
    // if the restart doesn't happen, say what to do instead of showing nothing
    Timer {
        id: stuckTimer
        interval: 20000
        onTriggered: root.stuck = true
    }

    ColumnLayout {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -50
        spacing: 0

        LIcon {
            Layout.alignment: Qt.AlignHCenter
            size: 120
            source: Theme.logo
        }
        Text {
            Layout.topMargin: 28
            Layout.alignment: Qt.AlignHCenter
            text: qsTr("Lareon OS is installed")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 42
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 12
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            Layout.maximumWidth: 600
            wrapMode: Text.Wrap
            text: root.stuck ? qsTr("Lareon OS is installed, but this computer didn’t restart by itself. Turn it off and on again (in a virtual machine, stop and start it) and it will start into Lareon OS.")
                : root.restarting ? qsTr("Restarting…")
                : qsTr("Restarting in %1 seconds. If you started from a USB stick, take it out first.").arg(root.seconds)
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }
        LButton {
            Layout.topMargin: 38
            Layout.alignment: Qt.AlignHCenter
            kind: "primary"
            size: 48
            text: qsTr("Restart now") + "  ›"
            enabled: !root.restarting
            onClicked: root.restart()
        }
    }
}

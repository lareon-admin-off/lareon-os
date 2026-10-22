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
        backup.start()
    }
    // if the helper didn't restart it, ask the system directly, then again with force
    Timer {
        id: backup
        interval: 4000
        repeat: true
        property int tries: 0
        onTriggered: {
            tries += 1
            if (tries === 1) Sys.startDetached("sudo", ["-n", "systemctl", "reboot", "--force"])
            else if (tries === 2) Sys.startDetached("sudo", ["-n", "/sbin/reboot", "-f"])
            else if (tries === 3) Sys.startDetached("sudo", ["-n", "sh", "-c", "echo 1 > /proc/sys/kernel/sysrq; echo b > /proc/sysrq-trigger"])
            else stop()
        }
    }

    onVisibleChanged: if (visible) seconds = 15

    // restarts by itself, so nobody has to find the button.
    // Only counts while this page is the one on screen (all pages exist from the start).
    Timer {
        id: countdown
        interval: 1000
        repeat: true
        running: root.visible && root.StackLayout.isCurrentItem && !root.restarting
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
            text: root.stuck ? qsTr("Lareon OS is installed, but this computer didn’t restart by itself. Turn it off and on again (in a virtual machine, stop and start it). If the install disc starts again, pick “Start Lareon OS (installed on this computer)”.")
                : root.restarting ? qsTr("Restarting…")
                : qsTr("Restarting in %1 seconds, then Lareon OS starts by itself. If you started from a USB stick, take it out when the screen goes dark.").arg(root.seconds)
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
        LButton {
            visible: root.stuck
            Layout.topMargin: 12
            Layout.alignment: Qt.AlignHCenter
            kind: "ghost"
            text: qsTr("Shut down instead")
            onClicked: Sys.startDetached("sudo", ["-n", "systemctl", "poweroff", "--force"])
        }
    }

    // a little celebration, once
    Item {
        id: confetti
        anchors.fill: parent
        visible: root.visible
        clip: true
        z: 5
        Repeater {
            model: 44
            delegate: Rectangle {
                id: piece
                required property int index
                readonly property real startX: Math.random() * confetti.width
                readonly property real drift: (Math.random() - 0.5) * 160
                width: 6 + Math.random() * 6
                height: width * 1.6
                radius: 2
                x: startX
                y: -30
                opacity: 0
                color: index % 4 === 0 ? "#ff7c1f" : (index % 4 === 1 ? "#d94fc4" : (index % 4 === 2 ? "#a35cf5" : "#ece9f5"))
                SequentialAnimation {
                    running: confetti.visible && root.StackLayout.isCurrentItem
                    PauseAnimation { duration: Math.random() * 900 }
                    ParallelAnimation {
                        NumberAnimation { target: piece; property: "y"; from: -30; to: confetti.height + 30; duration: 2600 + Math.random() * 1800; easing.type: Easing.InQuad }
                        NumberAnimation { target: piece; property: "x"; from: piece.startX; to: piece.startX + piece.drift; duration: 3600; easing.type: Easing.InOutSine }
                        NumberAnimation { target: piece; property: "rotation"; from: 0; to: 360 * (index % 2 === 0 ? 2 : -2); duration: 3600 }
                        SequentialAnimation {
                            NumberAnimation { target: piece; property: "opacity"; to: 1; duration: 200 }
                            PauseAnimation { duration: 2600 }
                            NumberAnimation { target: piece; property: "opacity"; to: 0; duration: 800 }
                        }
                    }
                }
            }
        }
    }
}

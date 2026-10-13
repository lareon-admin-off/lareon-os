import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Shown by the installer session when Calamares reports a failed install.
//   --set log=/tmp/lareon-install.log   the installer's session log (a copy)
// Exit codes for the session: 0 = try again, 2 = close (go to the live desktop)
Item {
    id: root

    readonly property string logPath: Sys.args.log || "/tmp/lareon-install.log"
    readonly property string logText: Sys.demo ? demoLog : Sys.readFile(logPath)
    property string savedTo: ""

    readonly property string demoLog:
        "unpackfs: copying filesystem.squashfs → /tmp/calamares-root\n" +
        "rsync: write failed on \"/usr/lib/x86_64-linux-gnu/libQt6Gui.so.6\": Input/output error (5)\n" +
        "ERROR: Installation failed: Unpacking image 3 of 3 (rsync exit code 23)\n"

    // The few log lines that explain what went wrong.
    function keyLines() {
        const lines = logText.split("\n")
        const hits = []
        for (const l of lines) {
            if (/error|failed|fail:|no space|i\/o/i.test(l)) {
                hits.push(l.replace(/^\d{2}:\d{2}:\d{2}\s+\[\d+\]:\s*/, "").trim())
            }
        }
        return hits.slice(-6)
    }
    readonly property var details: keyLines()

    function hint() {
        const t = logText.toLowerCase()
        if (t.indexOf("no space") >= 0) return qsTr("Hint: the drive or partition is too small for Lareon OS.")
        if (t.indexOf("input/output error") >= 0 || t.indexOf("i/o error") >= 0) return qsTr("Hint: this is usually a faulty USB stick or a loose drive cable.")
        if (t.indexOf("bootloader") >= 0 || t.indexOf("grub") >= 0) return qsTr("Hint: the computer’s start-up settings (UEFI) may block installing a boot loader.")
        return ""
    }

    Scene { anchors.fill: parent }

    TopBar {
        id: top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        title: qsTr("Install Lareon OS")
        steps: [qsTr("Language"), qsTr("Keyboard"), qsTr("Drive"), qsTr("Install")]
        current: 3
    }

    ColumnLayout {
        anchors.top: top.bottom
        anchors.topMargin: 78
        anchors.horizontalCenter: parent.horizontalCenter
        width: 820
        spacing: 0

        RowLayout {
            spacing: 18
            Rectangle {
                width: 56
                height: 56
                radius: 28
                color: Qt.rgba(0.85, 0.23, 0.38, 0.18)
                border.color: Theme.danger
                border.width: 2
                Text {
                    anchors.centerIn: parent
                    text: "✕"
                    color: Theme.danger
                    font.pixelSize: 24
                    font.weight: Font.Bold
                }
            }
            Text {
                text: qsTr("Lareon OS couldn’t be installed")
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 32
                font.weight: Font.DemiBold
            }
        }

        Text {
            Layout.topMargin: 16
            Layout.fillWidth: true
            wrapMode: Text.Wrap
            text: qsTr("The installer stopped before it finished, so this computer won’t start Lareon OS from its drive yet. The drive may already be partly changed. The USB stick is fine: you can try again now.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 16
            lineHeight: 1.25
        }

        Text {
            Layout.topMargin: 24
            text: qsTr("What happened")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 14
            font.weight: Font.DemiBold
        }
        Rectangle {
            Layout.topMargin: 8
            Layout.fillWidth: true
            Layout.preferredHeight: detailCol.implicitHeight + 28
            radius: 8
            color: Theme.bg
            border.color: Theme.lines
            Column {
                id: detailCol
                anchors.fill: parent
                anchors.margins: 14
                spacing: 4
                Repeater {
                    model: root.details.length > 0 ? root.details : [qsTr("The installer didn’t say why. The full log has the details.")]
                    Text {
                        width: detailCol.width
                        text: modelData
                        wrapMode: Text.WrapAnywhere
                        color: /error|failed/i.test(modelData) ? Theme.danger : Theme.muted
                        font.family: Theme.mono
                        font.pixelSize: 12.5
                    }
                }
                Text {
                    visible: root.hint() !== ""
                    width: detailCol.width
                    text: root.hint()
                    wrapMode: Text.Wrap
                    color: Theme.muted
                    font.family: Theme.mono
                    font.pixelSize: 12.5
                }
            }
        }

        RowLayout {
            Layout.topMargin: 18
            spacing: 8
            LButton {
                size: 36
                text: qsTr("Save log…")
                onClicked: {
                    const target = Sys.homePath() + "/lareon-install-log.txt"
                    if (Sys.demo || Sys.writeFile(target, root.logText)) root.savedTo = target
                }
            }
            LButton {
                size: 36
                text: qsTr("Copy details")
                onClicked: Sys.copyText(root.details.join("\n") + (root.hint() !== "" ? "\n" + root.hint() : ""))
            }
            Text {
                Layout.leftMargin: 8
                visible: root.savedTo !== ""
                text: qsTr("Saved to %1").arg(root.savedTo)
                color: Theme.good
                font.family: Theme.font
                font.pixelSize: 13
            }
        }
        Text {
            Layout.topMargin: 14
            text: qsTr("Help: lareon.org/help")
            color: Theme.faint
            font.family: Theme.font
            font.pixelSize: 13
        }
    }

    RowLayout {
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 64
        width: 820
        spacing: 10
        Item { Layout.fillWidth: true }
        LButton {
            text: qsTr("Close installer")
            onClicked: Sys.quit(2)
        }
        LButton {
            kind: "primary"
            text: "↻  " + qsTr("Try again")
            onClicked: Sys.quit(0)
        }
    }
}

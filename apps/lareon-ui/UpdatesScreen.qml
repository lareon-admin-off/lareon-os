import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Software updates for Lareon OS. Looking for updates needs no password;
// installing asks for it once.
Item {
    id: root

    // checking | uptodate | available | installing | done | failed | error
    property string phase: "checking"
    property int count: 0
    property var packages: []
    property string message: ""
    property string logTail: ""
    property int checkId: -1
    property int installId: -1

    readonly property string tools: "/usr/lib/lareon/"

    function check() {
        phase = "checking"
        message = ""
        if (Sys.demo) {
            count = 14
            packages = ["linux-image-amd64", "plasma-desktop", "firefox-esr", "lareon-branding"]
            phase = "available"
            return
        }
        checkId = Sys.run("pkexec", [tools + "lareon-update-check"])
    }

    function install() {
        phase = "installing"
        logTail = ""
        if (Sys.demo) {
            return
        }
        installId = Sys.run("pkexec", [tools + "lareon-update-install"])
        poll.start()
    }

    Connections {
        target: Sys
        function onFinished(id, exitCode, out, err) {
            if (id === root.checkId) {
                if (exitCode !== 0) {
                    root.message = qsTr("Couldn't check for updates. Try again in a moment.")
                    root.phase = "error"
                    return
                }
                try {
                    const r = JSON.parse(out)
                    root.count = r.count
                    root.packages = r.packages
                    root.message = r.error
                    root.phase = r.error !== "" && r.count === 0 ? "error" : (r.count > 0 ? "available" : "uptodate")
                } catch (e) {
                    root.message = qsTr("Couldn't check for updates. Try again in a moment.")
                    root.phase = "error"
                }
            } else if (id === root.installId) {
                poll.stop()
                if (exitCode === 126 || exitCode === 127) {
                    root.message = qsTr("The password wasn't entered, so nothing was installed.")
                    root.phase = "available"
                    return
                }
                const s = Sys.readFile("/var/lib/lareon/update-status").trim()
                root.phase = s === "done" ? "done" : "failed"
            }
        }
    }

    Timer {
        id: poll
        interval: 800
        repeat: true
        onTriggered: {
            const t = Sys.readFile("/var/log/lareon-update.log").split("\n").filter(l => l.trim() !== "")
            root.logTail = t.slice(-4).join("\n")
        }
    }

    Component.onCompleted: check()

    Rectangle {
        anchors.fill: parent
        color: Theme.bg
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 32
        spacing: 20

        RowLayout {
            spacing: 16
            LIcon {
                size: 44
                source: Theme.logo
            }
            Text {
                text: qsTr("Updates")
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 26
                font.weight: Font.DemiBold
            }
        }

        // status card
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            radius: Theme.radius
            color: Theme.panel
            border.width: 1
            border.color: Theme.lines

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 24
                spacing: 12

                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 20
                    font.weight: Font.Medium
                    text: root.phase === "checking" ? qsTr("Looking for updates…")
                        : root.phase === "uptodate" ? qsTr("Lareon OS is up to date")
                        : root.phase === "available" ? (root.count === 1 ? qsTr("1 update is ready") : qsTr("%1 updates are ready").arg(root.count))
                        : root.phase === "installing" ? qsTr("Installing updates…")
                        : root.phase === "done" ? qsTr("Updates installed")
                        : root.phase === "failed" ? qsTr("Some updates didn’t install")
                        : qsTr("Couldn’t check for updates")
                }
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 14
                    text: root.phase === "done" ? qsTr("Restart when you’re ready to finish. Your work stays safe until then.")
                        : root.phase === "failed" ? qsTr("Check your internet connection and try again.")
                        : root.phase === "installing" ? qsTr("Keep this computer on. You can keep using it.")
                        : root.message
                    visible: text !== ""
                }

                Flickable {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    contentHeight: listText.implicitHeight
                    visible: root.phase === "available" || root.phase === "installing"
                    Text {
                        id: listText
                        width: parent.width
                        wrapMode: Text.Wrap
                        color: root.phase === "installing" ? Theme.faint : Theme.muted
                        font.family: root.phase === "installing" ? Theme.mono : Theme.font
                        font.pixelSize: root.phase === "installing" ? 12 : 14
                        lineHeight: 1.35
                        text: root.phase === "installing" ? root.logTail : root.packages.join("\n") + (root.count > root.packages.length ? "\n…" : "")
                    }
                }
                Item {
                    Layout.fillHeight: true
                    visible: !(root.phase === "available" || root.phase === "installing")
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            Item { Layout.fillWidth: true }
            LButton {
                text: qsTr("Check again")
                visible: root.phase === "uptodate" || root.phase === "error" || root.phase === "failed"
                onClicked: root.check()
            }
            LButton {
                text: qsTr("Restart now")
                kind: "primary"
                visible: root.phase === "done"
                onClicked: Sys.startDetached("systemctl", ["reboot"])
            }
            LButton {
                text: qsTr("Later")
                kind: "ghost"
                visible: root.phase === "done"
                onClicked: Sys.quit(0)
            }
            LButton {
                text: qsTr("Install updates")
                kind: "primary"
                visible: root.phase === "available"
                onClicked: root.install()
            }
        }
    }
}

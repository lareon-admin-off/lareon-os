import QtQuick
import QtQuick.Layouts
import Lareon

// "Files closed unexpectedly". Opened by lareon-crash-watch when an app of
// this user crashes (systemd-coredump records it; no memory dump is kept).
//   --set name=Files --set icon=/usr/share/icons/.../dolphin.svg
//   --set exe=/usr/bin/dolphin --set launch=/usr/share/applications/org.kde.dolphin.desktop
//   --set signal=SIGSEGV --set time="2026-10-12 17:15"
Item {
    id: root
    implicitHeight: col.implicitHeight

    readonly property string appName: Sys.args.name || qsTr("An app")
    readonly property bool canReopen: (Sys.args.exe || "") !== ""
    property bool showDetails: false
    property string savedTo: ""

    readonly property string details:
        qsTr("App") + ": " + appName + "\n" +
        qsTr("Program") + ": " + (Sys.args.exe || "?") + "\n" +
        qsTr("Reason") + ": " + (Sys.args.signal || "?") + "\n" +
        qsTr("When") + ": " + (Sys.args.time || "?") + "\n" +
        "Lareon OS " + (Sys.args.version || "")

    ColumnLayout {
        id: col
        width: parent.width
        spacing: 0

        RowLayout {
            Layout.fillWidth: true
            Layout.margins: 26
            Layout.bottomMargin: 20
            spacing: 18
            LIcon {
                Layout.alignment: Qt.AlignTop
                size: 56
                source: Sys.args.icon ? "file://" + Sys.args.icon : Theme.logo
            }
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                Text {
                    text: qsTr("%1 closed unexpectedly").arg(root.appName)
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 17
                    font.weight: Font.DemiBold
                }
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: qsTr("Sorry about that. You can open it again now. If this keeps happening, saving a report and sending it to help@lareon.org helps Lareon fix it.")
                    color: Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 14
                    lineHeight: 1.2
                }
                Text {
                    Layout.fillWidth: true
                    Layout.topMargin: 6
                    wrapMode: Text.Wrap
                    text: qsTr("Reports are only saved if you choose to, and stay on this computer. They say what the app was doing, never your files or folder names.")
                    color: Theme.faint
                    font.family: Theme.font
                    font.pixelSize: 13
                    lineHeight: 1.2
                }
                Rectangle {
                    visible: root.showDetails
                    Layout.fillWidth: true
                    Layout.topMargin: 8
                    Layout.preferredHeight: detailText.implicitHeight + 20
                    radius: 8
                    color: Theme.bg
                    border.color: Theme.lines
                    Text {
                        id: detailText
                        anchors.fill: parent
                        anchors.margins: 10
                        text: root.details
                        color: Theme.muted
                        font.family: Theme.mono
                        font.pixelSize: 12
                        wrapMode: Text.WrapAnywhere
                    }
                }
                Text {
                    visible: root.savedTo !== ""
                    text: qsTr("Saved to %1").arg(root.savedTo)
                    color: Theme.good
                    font.family: Theme.font
                    font.pixelSize: 13
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 64
            color: Theme.bg
            Rectangle { width: parent.width; height: 1; color: Theme.lines }
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 8
                LButton {
                    size: 34
                    text: qsTr("Save report…")
                    visible: (Sys.args.reports || "ask") !== "never"
                    onClicked: {
                        const stamp = (Sys.args.time || "").replace(/[^0-9]/g, "")
                        const target = Sys.homePath() + "/" + root.appName.replace(/[^A-Za-z0-9]+/g, "-") + "-crash-" + stamp + ".txt"
                        if (Sys.demo || Sys.writeFile(target, root.details + "\n")) root.savedTo = target
                    }
                }
                LButton {
                    size: 34
                    text: root.showDetails ? qsTr("Hide details") : qsTr("Details")
                    onClicked: root.showDetails = !root.showDetails
                }
                Item { Layout.fillWidth: true }
                LButton {
                    size: 34
                    text: qsTr("Close")
                    onClicked: Sys.quit(0)
                }
                LButton {
                    size: 34
                    kind: "primary"
                    visible: root.canReopen
                    text: qsTr("Reopen %1").arg(root.appName)
                    onClicked: {
                        if (!Sys.demo) {
                            if (Sys.args.launch) Sys.startDetached("kioclient", ["exec", Sys.args.launch])
                            else Sys.startDetached(Sys.args.exe, [])
                        }
                        Sys.quit(0)
                    }
                }
            }
        }
    }
}

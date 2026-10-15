import QtQuick
import QtQuick.Layouts
import Lareon

// Installed. Restart into the new system.
Item {
    id: root
    property var install

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
            text: qsTr("Restart to finish. If you started from a USB stick, take it out first.")
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
            onClicked: {
                root.install.helperCall("reboot", undefined, function(code) { Sys.quit(0) })
            }
        }
    }
}

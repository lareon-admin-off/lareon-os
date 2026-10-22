import QtQuick
import QtQuick.Layouts
import Lareon

// The install stopped. Say what happened; "Try again" goes back to the drive.
Item {
    id: root
    property var install

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Lareon OS couldn’t be installed")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            Layout.fillWidth: true
            text: root.install.error !== "" ? root.install.error : qsTr("Something went wrong.")
            wrapMode: Text.Wrap
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }
        Rectangle {
            Layout.topMargin: 26
            Layout.fillWidth: true
            Layout.preferredHeight: 250
            radius: 10
            color: Theme.panel
            border.color: Theme.lines
            border.width: 1
            clip: true
            Text {
                anchors.fill: parent
                anchors.margins: 14
                text: root.install.logTail
                color: Theme.muted
                font.family: Theme.mono
                font.pixelSize: 12
                wrapMode: Text.WrapAnywhere
                elide: Text.ElideRight
            }
        }
        RowLayout {
            Layout.topMargin: 26
            Layout.fillWidth: true
            LButton {
                kind: "ghost"
                text: qsTr("Close")
                onClicked: Sys.quit(2)
            }
            Item { Layout.fillWidth: true }
            LButton {
                kind: "primary"
                size: 46
                text: qsTr("Try again")
                onClicked: { root.install.error = ""; root.install.page = root.install.pgDrive }
            }
        }
        Item { Layout.fillHeight: true }
    }
}

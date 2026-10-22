import QtQuick
import QtQuick.Layouts
import Lareon

// Step 5: one last look before anything is erased.
Item {
    id: root
    property var install

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Ready to install")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Here is what will happen. Nothing changes until you choose Install.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        LCard {
            Layout.topMargin: 28
            Layout.fillWidth: true
            Layout.preferredHeight: 190
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 22
                spacing: 14
                Repeater {
                    model: [
                        { k: qsTr("Language"), v: root.install.languageName() },
                        { k: qsTr("Keyboard"), v: root.install.keyboard.toUpperCase() },
                        { k: qsTr("Install on"), v: root.install.diskName !== "" ? root.install.diskName : root.install.disk }
                    ]
                    delegate: RowLayout {
                        required property var modelData
                        Layout.fillWidth: true
                        Text { Layout.preferredWidth: 150; text: modelData.k; color: Theme.muted; font.family: Theme.font; font.pixelSize: 16 }
                        Text { Layout.fillWidth: true; text: modelData.v; color: Theme.text; font.family: Theme.font; font.pixelSize: 17; font.weight: Font.Medium; elide: Text.ElideRight }
                    }
                }
            }
        }

        Rectangle {
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: warnRow.implicitHeight + 32
            radius: 12
            color: Qt.rgba(1, 0.70, 0.30, 0.10)
            border.width: 1
            border.color: Qt.rgba(1, 0.70, 0.30, 0.45)
            RowLayout {
                id: warnRow
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14
                Text { text: "!"; color: "#ffb45e"; font.family: Theme.font; font.pixelSize: 22; font.weight: Font.Bold }
                Text {
                    Layout.fillWidth: true
                    wrapMode: Text.Wrap
                    text: qsTr("Everything on this drive will be erased, including other systems and files. Back up anything you want to keep first.")
                    color: "#ffd9b0"
                    font.family: Theme.font
                    font.pixelSize: 15
                }
            }
        }

        // the person says it out loud
        RowLayout {
            Layout.topMargin: 22
            spacing: 14
            LToggle {
                checked: root.install.understood
                onToggled: (on) => root.install.understood = on
            }
            Text {
                text: qsTr("I understand this drive will be erased")
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 16
            }
        }
        Item { Layout.fillHeight: true }
    }
}

import QtQuick
import QtQuick.Layouts
import Lareon

// Step 4: Lareon Dark or Lareon Light, and the time-of-day wallpaper.
Item {
    id: root
    property var setup

    component ThemeCard: LCard {
        id: card
        property string key
        property string label
        property url preview
        property var setup
        selected: setup ? setup.theme === key : false
        Layout.fillWidth: true
        Layout.preferredHeight: 300
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 14
            spacing: 12
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 8
                color: Theme.bg
                border.color: Theme.lines
                clip: true
                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: card.preview
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                }
            }
            Row {
                spacing: 10
                LRadio { checked: card.selected; anchors.verticalCenter: parent.verticalCenter }
                Text {
                    text: card.label
                    color: Theme.text
                    font.family: Theme.font
                    font.pixelSize: 15.5
                    font.weight: Font.DemiBold
                }
            }
        }
        MouseArea {
            anchors.fill: parent
            cursorShape: Qt.PointingHandCursor
            onClicked: card.setup.theme = card.key
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Choose your look")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Change it any time in Settings.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 16.5
        }

        RowLayout {
            Layout.topMargin: 34
            Layout.fillWidth: true
            spacing: 16
            ThemeCard { setup: root.setup; key: "dark"; label: qsTr("Lareon Dark"); preview: "file:///usr/share/lareon/setup/preview-dark.png" }
            ThemeCard { setup: root.setup; key: "light"; label: qsTr("Lareon Light"); preview: "file:///usr/share/lareon/setup/preview-light.png" }
        }

        LCard {
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: 76
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 20
                anchors.rightMargin: 20
                spacing: 16
                Column {
                    Layout.fillWidth: true
                    spacing: 4
                    Text {
                        text: qsTr("Wallpaper follows the time of day")
                        color: Theme.text
                        font.family: Theme.font
                        font.pixelSize: 15.5
                        font.weight: Font.DemiBold
                    }
                    Text {
                        text: qsTr("Dawn, day, dusk and night, from your clock.")
                        color: Theme.muted
                        font.family: Theme.font
                        font.pixelSize: 13.8
                    }
                }
                LToggle {
                    checked: root.setup.timeOfDay
                    onToggled: (on) => root.setup.timeOfDay = on
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}

import QtQuick
import QtQuick.Controls.Basic
import QtQuick.Layouts
import Lareon

// Where you are, so the clock is right from the first start.
Item {
    id: root
    property var install
    property var all: Sys.demo ? ["Africa/Algiers", "America/New_York", "Asia/Tokyo", "Europe/London", "Europe/Paris"] : Sys.timeZones()
    property string query: ""
    readonly property var shown: all.filter(z => query === "" || z.toLowerCase().replace(/_/g, " ").indexOf(query.toLowerCase()) >= 0)

    function pretty(z) {
        const parts = z.split("/")
        return parts[parts.length - 1].replace(/_/g, " ")
    }
    function region(z) {
        const parts = z.split("/")
        return parts.length > 1 ? parts[0].replace(/_/g, " ") : ""
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Where are you?")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("This sets your clock. You can change it later in Settings.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        LCard {
            Layout.topMargin: 26
            Layout.fillWidth: true
            Layout.preferredHeight: 84
            selected: true
            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 22
                anchors.rightMargin: 22
                spacing: 16
                Rectangle {
                    Layout.preferredWidth: 48
                    Layout.preferredHeight: 48
                    radius: 24
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: Theme.accent }
                        GradientStop { position: 1.0; color: Theme.violet }
                    }
                    Text { anchors.centerIn: parent; text: "◉"; color: "white"; font.pixelSize: 24 }
                }
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    Text { text: root.pretty(root.install.timeZone); color: Theme.text; font.family: Theme.font; font.pixelSize: 22; font.weight: Font.DemiBold }
                    Text { text: root.region(root.install.timeZone) + "  ·  " + root.install.timeZone; color: Theme.muted; font.family: Theme.font; font.pixelSize: 14 }
                }
            }
        }

        Rectangle {
            Layout.topMargin: 16
            Layout.fillWidth: true
            Layout.preferredHeight: 42
            radius: 21
            color: Theme.panel2
            border.width: 1
            border.color: find.activeFocus ? Theme.accent : Theme.lines
            TextInput {
                id: find
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                verticalAlignment: TextInput.AlignVCenter
                color: Theme.text
                font.family: Theme.font
                font.pixelSize: 15
                clip: true
                onTextChanged: root.query = text
                Text {
                    anchors.fill: parent
                    verticalAlignment: Text.AlignVCenter
                    visible: find.text === ""
                    text: qsTr("Search for your city")
                    color: Theme.faint
                    font: find.font
                }
            }
        }

        ListView {
            Layout.topMargin: 10
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            spacing: 2
            model: root.shown
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { }
            delegate: Rectangle {
                required property string modelData
                readonly property bool isOn: modelData === root.install.timeZone
                width: ListView.view.width
                height: 40
                radius: 12
                color: isOn ? Qt.rgba(1, 0.486, 0.122, 0.16) : (hov.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
                HoverHandler { id: hov; cursorShape: Qt.PointingHandCursor }
                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 16
                    anchors.rightMargin: 16
                    Text { text: root.pretty(modelData); color: isOn ? "white" : Theme.text; font.family: Theme.font; font.pixelSize: 15; font.weight: isOn ? Font.Medium : Font.Normal }
                    Item { Layout.fillWidth: true }
                    Text { text: root.region(modelData); color: Theme.faint; font.family: Theme.font; font.pixelSize: 13 }
                }
                TapHandler { onTapped: { root.install.timeZone = modelData; root.install.zoneTouched = true } }
            }
        }
    }
}

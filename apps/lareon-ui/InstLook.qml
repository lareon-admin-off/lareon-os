import QtQuick
import QtQuick.Layouts
import Lareon

// Dark or light, and an accent colour. The pictures show the real thing.
Item {
    id: root
    property var install
    readonly property var accents: ["#ff7c1f", "#d94fc4", "#a35cf5", "#3d8bff", "#2fbf7a", "#ff4f5e"]

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
            text: qsTr("You’ll see it the moment Lareon OS starts. Change it any time.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        RowLayout {
            Layout.topMargin: 30
            Layout.fillWidth: true
            spacing: 16
            Repeater {
                model: [{ key: "dark", label: qsTr("Lareon Dark") }, { key: "light", label: qsTr("Lareon Light") }]
                delegate: LCard {
                    id: card
                    required property var modelData
                    selected: root.install.theme === modelData.key
                    Layout.fillWidth: true
                    Layout.preferredHeight: 290
                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 14
                        spacing: 12
                        MiniDesktop {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            implicitWidth: 100
                            implicitHeight: 100
                            accent: root.install.accent
                            dark: modelData.key === "dark"
                        }
                        Row {
                            spacing: 10
                            LRadio { checked: card.selected; anchors.verticalCenter: parent.verticalCenter }
                            Text { text: modelData.label; color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                        }
                    }
                    TapHandler { onTapped: root.install.theme = modelData.key }
                    HoverHandler { cursorShape: Qt.PointingHandCursor }
                }
            }
        }

        Row {
            Layout.topMargin: 22
            Layout.alignment: Qt.AlignHCenter
            spacing: 16
            Repeater {
                model: root.accents
                delegate: Rectangle {
                    required property string modelData
                    width: 38
                    height: 38
                    radius: 19
                    color: modelData
                    border.width: root.install.accent === modelData ? 3 : 0
                    border.color: "white"
                    scale: ah.hovered ? 1.12 : 1
                    Behavior on scale { NumberAnimation { duration: 120 } }
                    HoverHandler { id: ah; cursorShape: Qt.PointingHandCursor }
                    TapHandler { onTapped: root.install.accent = modelData }
                }
            }
        }
        Item { Layout.fillHeight: true }
    }
}

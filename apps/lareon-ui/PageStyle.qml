import QtQuick
import QtQuick.Layouts
import Lareon

// Step 5: make it yours. An accent colour, how lively things move, the start-up sound.
// The picture on the right follows every choice.
Item {
    id: root
    property var setup

    readonly property var accents: [
        { name: qsTr("Orange"), hex: "#ff7c1f" }, { name: qsTr("Pink"), hex: "#d94fc4" },
        { name: qsTr("Violet"), hex: "#a35cf5" }, { name: qsTr("Blue"), hex: "#3d8bff" },
        { name: qsTr("Green"), hex: "#2fbf7a" }, { name: qsTr("Red"), hex: "#ff4f5e" }
    ]
    readonly property var motions: [
        { label: qsTr("Calm"), value: "calm" }, { label: qsTr("Lively"), value: "lively" }, { label: qsTr("Off"), value: "off" }
    ]

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Text {
            text: qsTr("Make it yours")
            color: Theme.text
            font.family: Theme.font
            font.pixelSize: 36
            font.weight: Font.DemiBold
        }
        Text {
            Layout.topMargin: 10
            text: qsTr("Pick what feels right. Every choice can be changed later in Settings.")
            color: Theme.muted
            font.family: Theme.font
            font.pixelSize: 17
        }

        RowLayout {
            Layout.topMargin: 34
            Layout.fillWidth: true
            spacing: 36

            ColumnLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: 26

                ColumnLayout {
                    spacing: 12
                    Text { text: qsTr("Accent colour"); color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                    Row {
                        spacing: 14
                        Repeater {
                            model: root.accents
                            delegate: Rectangle {
                                required property var modelData
                                width: 40
                                height: 40
                                radius: 20
                                color: modelData.hex
                                border.width: root.setup.accent === modelData.hex ? 3 : 0
                                border.color: "white"
                                scale: sh.hovered ? 1.12 : 1
                                Behavior on scale { NumberAnimation { duration: 120 } }
                                HoverHandler { id: sh; cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.setup.accent = modelData.hex }
                            }
                        }
                    }
                }

                ColumnLayout {
                    spacing: 12
                    Text { text: qsTr("How things move"); color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                    Row {
                        spacing: 8
                        Repeater {
                            model: root.motions
                            delegate: Rectangle {
                                required property var modelData
                                readonly property bool isOn: root.setup.motion === modelData.value
                                width: lbl.implicitWidth + 36
                                height: 38
                                radius: 19
                                color: isOn ? Qt.rgba(1, 0.486, 0.122, 0.22) : Theme.panel2
                                border.width: 1
                                border.color: isOn ? Theme.accent : Theme.lines
                                Behavior on color { ColorAnimation { duration: 140 } }
                                Text { id: lbl; anchors.centerIn: parent; text: modelData.label; color: isOn ? "white" : Theme.muted; font.family: Theme.font; font.pixelSize: 14 }
                                HoverHandler { cursorShape: Qt.PointingHandCursor }
                                TapHandler { onTapped: root.setup.motion = modelData.value }
                            }
                        }
                    }
                }

                RowLayout {
                    spacing: 14
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        Text { text: qsTr("Start-up sound"); color: Theme.text; font.family: Theme.font; font.pixelSize: 16; font.weight: Font.DemiBold }
                        Text { text: qsTr("A short chime when Lareon OS starts."); color: Theme.muted; font.family: Theme.font; font.pixelSize: 14 }
                    }
                    LToggle {
                        checked: root.setup.startupSound
                        onToggled: (on) => root.setup.startupSound = on
                    }
                }
            }

            MiniDesktop {
                Layout.alignment: Qt.AlignTop
                Layout.preferredWidth: 400
                Layout.preferredHeight: 252
                accent: root.setup.accent
                dark: root.setup.theme !== "light"
                name: root.setup.firstName()
            }
        }
        Item { Layout.fillHeight: true }
    }
}

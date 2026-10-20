import QtQuick
import QtQuick.Layouts
import Lareon

// A row of choices, one selected. options: [{ label: "...", value: ... }]
Rectangle {
    id: root
    property var options: []
    property var current
    signal picked(var value)

    implicitHeight: 38
    implicitWidth: row.implicitWidth + 8
    radius: 19
    color: Theme.bg
    border.width: 1
    border.color: Theme.lines

    Row {
        id: row
        anchors.centerIn: parent
        spacing: 2
        Repeater {
            model: root.options
            delegate: Rectangle {
                required property var modelData
                readonly property bool isOn: root.current === modelData.value
                width: label.implicitWidth + 28
                height: 30
                radius: 15
                color: isOn ? Qt.rgba(1, 0.486, 0.122, 0.22) : (hov.hovered ? Qt.rgba(1, 1, 1, 0.06) : "transparent")
                border.width: isOn ? 1 : 0
                border.color: Qt.rgba(1, 0.486, 0.122, 0.55)
                Behavior on color { ColorAnimation { duration: 140 } }
                HoverHandler { id: hov; cursorShape: Qt.PointingHandCursor }
                Text {
                    id: label
                    anchors.centerIn: parent
                    text: modelData.label
                    color: isOn ? "white" : Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 13
                    font.weight: isOn ? Font.Medium : Font.Normal
                }
                TapHandler { onTapped: root.picked(modelData.value) }
            }
        }
    }
}

import QtQuick
import Lareon

// Card surface. selected = orange outline and soft ring.
Rectangle {
    property bool selected: false
    radius: Theme.radius
    color: selected ? Qt.rgba(0.17, 0.12, 0.13, 0.95) : Qt.rgba(0.102, 0.094, 0.141, 0.92)
    border.width: 1
    border.color: selected ? Theme.accent : Theme.lines

    Rectangle {
        anchors.fill: parent
        anchors.margins: -4
        radius: parent.radius + 4
        color: "transparent"
        border.width: 3
        border.color: parent.selected ? Theme.accentRing : "transparent"
        z: -1
    }
}

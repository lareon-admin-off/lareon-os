import QtQuick
import Lareon

// On/off switch.
Rectangle {
    id: root
    property bool checked: false
    signal toggled(bool checked)

    width: 42
    height: 24
    radius: 12
    color: checked ? Theme.accent : Theme.lines
    Behavior on color { ColorAnimation { duration: 120 } }

    Rectangle {
        width: 18
        height: 18
        radius: 9
        y: 3
        x: root.checked ? 21 : 3
        color: root.checked ? "white" : Theme.muted
        Behavior on x { NumberAnimation { duration: 120 } }
    }

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            root.checked = !root.checked
            root.toggled(root.checked)
        }
    }
}

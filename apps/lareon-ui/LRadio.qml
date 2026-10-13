import QtQuick
import Lareon

// Round radio mark (the circle only).
Rectangle {
    property bool checked: false
    width: 20
    height: 20
    radius: 10
    color: checked ? Theme.accent : "transparent"
    border.width: 2
    border.color: checked ? Theme.accent : Theme.lines
    Rectangle {
        anchors.centerIn: parent
        width: 8
        height: 8
        radius: 4
        visible: parent.checked
        color: Theme.panel
    }
}

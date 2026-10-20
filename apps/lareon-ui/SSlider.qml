import QtQuick
import QtQuick.Layouts
import Lareon

// A slider with the brand gradient. moved() fires while dragging, committed() on release.
Item {
    id: tr
    property real value: 0.5
    property real from: 0
    property real to: 1
    signal moved(real v)
    signal committed(real v)

    implicitWidth: 240
    implicitHeight: 28
    Layout.preferredWidth: 240
    Layout.preferredHeight: 28
    opacity: enabled ? 1 : 0.4

    readonly property real frac: to === from ? 0 : Math.max(0, Math.min(1, (value - from) / (to - from)))

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: 6
        radius: 3
        color: Theme.lines
        Rectangle {
            width: parent.width * tr.frac
            height: parent.height
            radius: 3
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: Theme.accent }
                GradientStop { position: 1.0; color: Theme.magenta }
            }
        }
    }
    Rectangle {
        id: knob
        width: 18
        height: 18
        radius: 9
        color: "white"
        anchors.verticalCenter: parent.verticalCenter
        x: tr.frac * (tr.width - width)
        scale: area.pressed ? 1.18 : 1
        Behavior on scale { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
    }
    MouseArea {
        id: area
        anchors.fill: parent
        enabled: tr.enabled
        cursorShape: Qt.PointingHandCursor
        function at(mx) {
            const f = Math.max(0, Math.min(1, (mx - knob.width / 2) / (width - knob.width)))
            return tr.from + f * (tr.to - tr.from)
        }
        onPressed: mouse => tr.moved(at(mouse.x))
        onPositionChanged: mouse => { if (pressed) tr.moved(at(mouse.x)) }
        onReleased: mouse => tr.committed(at(mouse.x))
    }
}

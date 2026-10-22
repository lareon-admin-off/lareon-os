import QtQuick
import Lareon

// A small picture of the Lareon desktop that follows the choices made so far.
Rectangle {
    id: root
    property color accent: "#ff7c1f"
    property bool dark: true
    property string name: ""
    implicitWidth: 430
    implicitHeight: 270
    radius: 14
    clip: true
    border.width: 1
    border.color: Theme.lines

    readonly property color ink: dark ? "#ece9f5" : "#1d1832"
    readonly property color surface: dark ? "#1a1824" : "#f7f3fb"
    readonly property color surface2: dark ? "#211e2d" : "#ece5f5"

    gradient: Gradient {
        GradientStop { position: 0.0; color: root.dark ? "#2a1636" : "#f1dff7" }
        GradientStop { position: 0.55; color: root.dark ? "#13111b" : "#ffe9d6" }
        GradientStop { position: 1.0; color: root.dark ? "#3a1f12" : "#ffd2b0" }
    }

    // top bar
    Rectangle {
        width: parent.width
        height: 20
        color: Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.85)
        Text {
            anchors.centerIn: parent
            text: Qt.formatTime(new Date(), "h:mm")
            color: root.ink
            font.family: Theme.font
            font.pixelSize: 10
        }
        Rectangle { x: 10; anchors.verticalCenter: parent.verticalCenter; width: 8; height: 8; radius: 4; color: root.accent; Behavior on color { ColorAnimation { duration: 220 } } }
    }

    // dock
    Rectangle {
        x: 8
        y: 34
        width: 34
        height: parent.height - 46
        radius: 12
        color: Qt.rgba(root.surface.r, root.surface.g, root.surface.b, 0.85)
        Column {
            anchors.centerIn: parent
            spacing: 9
            Repeater {
                model: 5
                delegate: Rectangle {
                    required property int index
                    width: 22
                    height: 22
                    radius: 7
                    color: index === 0 ? root.accent : root.surface2
                    border.width: index === 0 ? 0 : 1
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    Behavior on color { ColorAnimation { duration: 220 } }
                }
            }
        }
    }

    // a window
    Rectangle {
        x: 64
        y: 44
        width: parent.width - 96
        height: parent.height - 72
        radius: 10
        color: root.surface
        border.width: 1
        border.color: Qt.rgba(1, 1, 1, root.dark ? 0.10 : 0.5)
        Rectangle {
            width: parent.width
            height: 3
            radius: 1
            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: root.accent }
                GradientStop { position: 1.0; color: "#a35cf5" }
            }
        }
        Row {
            x: 10
            y: 11
            spacing: 5
            Repeater { model: 3; delegate: Rectangle { width: 7; height: 7; radius: 3.5; color: index === 0 ? "#ff5f57" : (index === 1 ? "#febc2e" : "#28c840"); required property int index } }
        }
        Text {
            x: 14
            y: 32
            text: root.name !== "" ? qsTr("Hello, %1").arg(root.name) : qsTr("Hello")
            color: root.ink
            font.family: Theme.font
            font.pixelSize: 15
            font.weight: Font.DemiBold
        }
        Rectangle {
            x: 14
            y: 62
            width: parent.width - 28
            height: 6
            radius: 3
            color: root.surface2
            Rectangle { width: parent.width * 0.62; height: parent.height; radius: 3; color: root.accent; Behavior on color { ColorAnimation { duration: 220 } } }
        }
        Row {
            x: 14
            y: 82
            spacing: 8
            Rectangle {
                width: 64
                height: 24
                radius: 12
                color: root.accent
                Behavior on color { ColorAnimation { duration: 220 } }
                Text { anchors.centerIn: parent; text: qsTr("Continue"); color: "#13111b"; font.family: Theme.font; font.pixelSize: 10; font.weight: Font.DemiBold }
            }
            Rectangle {
                width: 40
                height: 22
                radius: 11
                anchors.verticalCenter: parent.verticalCenter
                color: root.accent
                Behavior on color { ColorAnimation { duration: 220 } }
                Rectangle { x: 20; y: 2; width: 18; height: 18; radius: 9; color: "white" }
            }
        }
    }
}

import QtQuick
import Lareon

// "① Wi-Fi —— ② You —— ③ …" step indicator.
Row {
    id: root
    property var steps: []
    property int current: 0
    spacing: 6

    Repeater {
        model: root.steps
        Row {
            spacing: 6
            Rectangle {
                visible: index > 0
                width: 22
                height: 1.5
                color: Theme.lines
                anchors.verticalCenter: parent.verticalCenter
            }
            Rectangle {
                width: 22
                height: 22
                radius: 11
                anchors.verticalCenter: parent.verticalCenter
                color: index < root.current ? Theme.panel2 : (index === root.current ? Theme.accent : "transparent")
                border.width: index <= root.current ? 0 : 1.5
                border.color: Theme.lines
                Text {
                    anchors.centerIn: parent
                    text: index < root.current ? "✓" : (index + 1)
                    color: index === root.current ? Theme.onAccent : Theme.muted
                    font.family: Theme.font
                    font.pixelSize: 11.5
                    font.weight: Font.DemiBold
                }
            }
            Text {
                text: modelData
                anchors.verticalCenter: parent.verticalCenter
                color: index === root.current ? Theme.text : (index < root.current ? Theme.muted : Theme.faint)
                font.family: Theme.font
                font.pixelSize: 13
                font.weight: index === root.current ? Font.Medium : Font.Normal
            }
        }
    }
}

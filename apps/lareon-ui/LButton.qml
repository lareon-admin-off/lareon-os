import QtQuick
import QtQuick.Controls.Basic
import Lareon

// Lareon button. kind: "primary" (orange), "normal", "ghost" (text only)
Button {
    id: control
    property string kind: "normal"
    property int size: 42

    implicitHeight: size
    leftPadding: 22
    rightPadding: 22
    font.family: Theme.font
    font.pixelSize: size >= 42 ? 15 : 13
    font.weight: kind === "primary" ? Font.DemiBold : Font.Medium
    hoverEnabled: true

    contentItem: Text {
        text: control.text
        font: control.font
        color: !control.enabled ? Theme.faint
             : control.kind === "primary" ? Theme.textOnAccent
             : control.kind === "ghost" ? Theme.muted : Theme.text
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }

    background: Rectangle {
        radius: Theme.fieldRadius
        color: control.kind === "ghost" ? (control.hovered ? Qt.rgba(1, 1, 1, 0.05) : "transparent")
             : control.kind === "primary" ? (!control.enabled ? Theme.lines : (control.hovered ? Theme.accentHover : Theme.accent))
             : (control.hovered ? Theme.lines : Theme.panel2)
        border.width: control.kind === "normal" ? 1 : 0
        border.color: control.visualFocus ? Theme.accent : Theme.lines
    }
}

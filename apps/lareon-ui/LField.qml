import QtQuick
import QtQuick.Controls.Basic
import Lareon

// Lareon text field with an optional label above it.
Column {
    id: root
    property alias label: caption.text
    property alias text: field.text
    property alias placeholder: field.placeholderText
    property alias echoMode: field.echoMode
    property alias field: field
    property bool invalid: false
    // re-emitted from the inner field so users write onEdited / onAccepted
    signal edited(string value)
    signal accepted()
    spacing: 7

    Text {
        id: caption
        visible: text !== ""
        color: Theme.muted
        font.family: Theme.font
        font.pixelSize: 13
        font.weight: Font.Medium
        leftPadding: 2
    }

    TextField {
        id: field
        width: root.width
        height: 44
        leftPadding: 14
        rightPadding: 14
        color: Theme.text
        placeholderTextColor: Theme.faint
        selectionColor: Theme.accent
        selectedTextColor: Theme.onAccent
        font.family: Theme.font
        font.pixelSize: 15
        passwordCharacter: "•"
        onTextEdited: root.edited(text)
        onAccepted: root.accepted()
        background: Rectangle {
            radius: Theme.fieldRadius
            color: Theme.bg
            border.width: 1
            border.color: root.invalid ? Theme.danger : (field.activeFocus ? Theme.accent : Theme.lines)
            Rectangle {
                anchors.fill: parent
                anchors.margins: -3
                radius: Theme.fieldRadius + 3
                color: "transparent"
                border.width: 3
                border.color: field.activeFocus ? Theme.accentRing : "transparent"
            }
        }
    }
}
